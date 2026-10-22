use super::*;

impl Generator<'_> {
    pub(super) fn function_named(&self, file: usize, name: &str, public: bool) -> Option<usize> {
        if let Some(&i) = self.names.get(&(file, name.to_owned()))
            && (!public || self.funcs[i].ast.public)
        {
            return Some(i);
        }
        let module = &self.project.files[file].module;
        self.funcs
            .iter()
            .enumerate()
            .find(|(_, f)| {
                self.project.files[f.file].module == *module
                    && f.ast.name == name
                    && (!public || f.ast.public)
            })
            .map(|(i, _)| i)
    }
    pub(super) fn call(&mut self, callee: E, args: Vec<E>) -> R<Val> {
        let expr = self.project.files[self.file].exprs[callee].kind.clone();
        let mut args = args;
        let index = match expr {
            ExprKind::Id(n) => {
                if self.function_named(self.file, &n, false).is_none()
                    && matches!(
                        n.as_str(),
                        "print" | "println" | "printf" | "len" | "new" | "cast" | "sizeof"
                    )
                {
                    return self.intrinsic("", &n, args);
                }
                self.function_named(self.file, &n, false).ok_or_else(|| {
                    format!("unknown function: {n}; imported symbols must use an alias")
                })?
            }
            ExprKind::Member(base, n) => {
                if let ExprKind::Id(alias) = &self.project.files[self.file].exprs[base].kind
                    && let Some(&dep) = self.project.imports[self.file].get(alias)
                {
                    let i = self
                        .function_named(dep, &n, true)
                        .ok_or_else(|| format!("no public function '{n}' in module {alias}"))?;
                    if self.funcs[i].ast.intrinsic {
                        return self.intrinsic(&self.project.files[dep].module.clone(), &n, args);
                    }
                    return self.call_function(i, args);
                }
                let object = self.expr(base)?;
                if matches!(object.t, Ty::Vec(_)) {
                    return self.vec_method(object, &n, args);
                }
                let mut matches = BTreeSet::new();
                for &dep in self.project.imports[self.file].values() {
                    if let Some(i) = self.function_named(dep, &n, true)
                        && self.funcs[i]
                            .params
                            .first()
                            .is_some_and(|t| *t == object.t || (t.pointer() && object.t.pointer()))
                    {
                        matches.insert(i);
                    }
                }
                if matches.len() != 1 {
                    return Err(format!("ambiguous or unknown UFCS method {n}"));
                }
                args.insert(0, base);
                return self.invoke(*matches.iter().next().unwrap(), args, Some(object));
            }
            _ => return Err("call requires a function".into()),
        };
        self.call_function(index, args)
    }
    pub(super) fn call_function(&mut self, index: usize, args: Vec<E>) -> R<Val> {
        self.invoke(index, args, None)
    }

    fn invoke(&mut self, index: usize, args: Vec<E>, mut receiver: Option<Val>) -> R<Val> {
        let f = self.funcs[index].clone();
        if args.len() < f.params.len() || (!f.ast.variadic && args.len() != f.params.len()) {
            return Err(format!("wrong argument count for {}", f.ast.name));
        }
        if f.ast.intrinsic {
            return self.intrinsic_receiver(
                &self.project.files[f.file].module.clone(),
                &f.ast.name,
                args,
                receiver,
            );
        }
        let mut values = vec![f.value.0];
        for (i, e) in args.into_iter().enumerate() {
            let mut v = if i == 0 {
                if let Some(value) = receiver.take() {
                    value
                } else {
                    self.expr(e)?
                }
            } else {
                self.expr(e)?
            };
            if let Some(t) = f.params.get(i) {
                if f.ast.external
                    && matches!(v.t, Ty::Slice(_) | Ty::Vec(_))
                    && matches!(t, Ty::Ptr(_))
                {
                    v.v = self.hload(v.v, 0)?;
                    v.t = t.clone();
                }
                v = self.coerce(v, t)?;
            } else {
                if v.t == Ty::F32 {
                    v = self.coerce(v, &Ty::F64)?;
                } else if v.t.integer() && v.t.bits() < 32 {
                    v = self.coerce(v, &Ty::I32)?;
                }
            }
            values.push(v.v.0);
        }
        let v = self.l.op("call", Some(f.ft), &values, "call", 0)?;
        Ok(Val { v, t: f.ret })
    }
    pub(super) fn type_expr(&self, e: E) -> R<Ty> {
        match &self.project.files[self.file].exprs[e].kind {
            ExprKind::Type(t) => self.resolve(self.file, t),
            ExprKind::Id(n) => self.resolve(self.file, &Ty::named(n)),
            _ => Err("expected type argument".into()),
        }
    }
    pub(super) fn intrinsic(&mut self, module: &str, name: &str, args: Vec<E>) -> R<Val> {
        self.intrinsic_receiver(module, name, args, None)
    }

    fn argument(&mut self, args: &[E], i: usize, receiver: &Option<Val>) -> R<Val> {
        if i == 0
            && let Some(value) = receiver
        {
            return Ok(value.clone());
        }
        self.expr(args[i])
    }

    fn intrinsic_receiver(
        &mut self,
        module: &str,
        name: &str,
        args: Vec<E>,
        receiver: Option<Val>,
    ) -> R<Val> {
        let arity = match (module, name) {
            ("", "cast") => Some(2..=2),
            ("", "len" | "sizeof" | "new") | ("c.llvm", "vec_data_i64") => Some(1..=1),
            ("std.array", "new" | "make") => Some(1..=2),
            ("std.array", "len" | "cap" | "free") => Some(1..=1),
            ("std.array", "append" | "push" | "get") => Some(2..=2),
            ("std.array", "set") => Some(3..=3),
            _ => None,
        };
        if arity.is_some_and(|range| !range.contains(&args.len())) {
            return Err(format!("wrong argument count for {name}"));
        }
        if matches!(name, "print" | "println" | "printf")
            && (module.is_empty() || module == "std.fmt")
        {
            let mut vals = Vec::new();
            for i in 0..args.len() {
                vals.push(self.argument(&args, i, &receiver)?);
            }
            let mut fmt = String::new();
            let mut call = Vec::new();
            if name == "printf" {
                if vals.is_empty() {
                    return Err("printf requires a format".into());
                }
                call.push(vals.remove(0));
                for v in vals {
                    let t = if v.t == Ty::F32 {
                        Ty::F64
                    } else if v.t.integer() && v.t.bits() < 32 {
                        Ty::I32
                    } else {
                        v.t.clone()
                    };
                    call.push(self.coerce(v, &t)?);
                }
            } else {
                for (i, v) in vals.into_iter().enumerate() {
                    if i > 0 {
                        fmt.push(' ');
                    }
                    let t = if v.t.pointer() {
                        fmt.push_str("%s");
                        Ty::String
                    } else if v.t.float() {
                        fmt.push_str("%f");
                        Ty::F64
                    } else {
                        fmt.push_str("%lld");
                        Ty::I64
                    };
                    call.push(self.coerce(v, &t)?);
                }
                if name == "println" {
                    fmt.push('\n');
                }
                call.insert(0, self.ptr(self.string(&fmt)?));
            }
            let ft = self
                .l
                .typ(7, 1, &[self.lt(&Ty::I32)?, self.lt(&Ty::String)?], "")?;
            let f = self.l.func("printf", ft)?;
            let mut vs = vec![f.0];
            vs.extend(call.iter().map(|v| v.v.0));
            return Ok(Val {
                v: self.l.op("call", Some(ft), &vs, "call_printf", 0)?,
                t: Ty::I32,
            });
        }
        if module == "c.llvm" && name == "vec_data_i64" {
            let v = self.argument(&args, 0, &receiver)?;
            return Ok(Val {
                v: self.hload(v.v, 0)?,
                t: Ty::Ptr(Box::new(Ty::Byte)),
            });
        }
        if name == "cast" {
            if args.len() != 2 {
                return Err("cast expects two arguments".into());
            }
            let t = self.type_expr(args[0])?;
            let v = self.expr(args[1])?;
            return self.coerce(v, &t);
        }
        if name == "sizeof" {
            if args.len() != 1 {
                return Err("sizeof expects one type".into());
            }
            let t = self.type_expr(args[0])?;
            let size = if matches!(t, Ty::Slice(_) | Ty::Vec(_)) {
                self.l.size(self.header)?
            } else {
                self.l.size(self.lt(&t)?)?
            };
            return Ok(self.int(self.i(size as i64)?));
        }
        if name == "new" && module.is_empty() {
            if args.len() != 1 {
                return Err("new expects a type".into());
            }
            let t = self.type_expr(args[0])?;
            let size = self.l.size(self.lt(&t)?)?;
            let v = self
                .rt(
                    "yc_calloc",
                    &Ty::String,
                    &[self.int(self.i(1)?), self.int(self.i(size as i64)?)],
                )?
                .v;
            return Ok(Val {
                v,
                t: Ty::Ptr(Box::new(t)),
            });
        }
        if module == "std.array" {
            match name {
                "new" | "make" => {
                    if args.is_empty() {
                        return Err("array.new first argument must be a slice type".into());
                    }
                    let t = self.type_expr(args[0])?;
                    let Ty::Slice(elem) = &t else {
                        return Err("array.new first argument must be a slice type".into());
                    };
                    let capacity = if let Some(&e) = args.get(1) {
                        let v = self.expr(e)?;
                        self.coerce(v, &Ty::I64)?.v
                    } else {
                        self.i(0)?
                    };
                    let v = self.array_new(elem, capacity)?;
                    return Ok(Val { v, t });
                }
                "len" | "cap" => {
                    let v = self.argument(&args, 0, &receiver)?;
                    let v = self.hload(v.v, if name == "len" { 1 } else { 2 })?;
                    return self.coerce(self.int(v), &Ty::I32);
                }
                "append" | "push" => {
                    let arr = self.argument(&args, 0, &receiver)?;
                    let value = self.expr(args[1])?;
                    return self.append(arr, value, false);
                }
                "get" | "set" => {
                    let arr = self.argument(&args, 0, &receiver)?;
                    let i = self.expr(args[1])?;
                    let i = self.coerce(i, &Ty::I64)?.v;
                    let elem = arr.t.element().ok_or("array.get expects a slice")?;
                    let ptr = self.array_slot(arr.v, &elem, i)?;
                    if name == "get" {
                        return self.load(
                            &elem,
                            ptr,
                            if matches!(elem, Ty::Struct(_)) {
                                "load_struct_value_dyn"
                            } else {
                                "array.get"
                            },
                        );
                    }
                    let v = self.expr(args[2])?;
                    let v = self.coerce(v, &elem)?;
                    self.children(arr.v, &v)?;
                    self.store(v.v, ptr)?;
                    return Ok(Val {
                        v: self.i(0)?,
                        t: Ty::I64,
                    });
                }
                "free" => {
                    let v = self.argument(&args, 0, &receiver)?;
                    self.release(&v)?;
                    return Ok(Val {
                        v: self.i(0)?,
                        t: Ty::I64,
                    });
                }
                _ => {}
            }
        }
        if name == "len" && module.is_empty() {
            let v = self.argument(&args, 0, &receiver)?;
            if v.t == Ty::String {
                let out = self.rt("strlen", &Ty::I64, &[v])?;
                return self.coerce(out, &Ty::I32);
            }
            let v = self.hload(v.v, 1)?;
            return self.coerce(self.int(v), &Ty::I32);
        }
        Err(format!("unsupported intrinsic {module}.{name}"))
    }
}
