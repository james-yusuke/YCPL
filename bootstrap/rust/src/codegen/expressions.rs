use super::*;

impl Generator<'_> {
    pub(super) fn expr(&mut self, e: E) -> R<Val> {
        let node = self.project.files[self.file].exprs[e].clone();
        self.span = node.span;
        match node.kind {
            ExprKind::Int(n) => {
                let t = if n > i32::MAX as u64 {
                    Ty::I64
                } else {
                    Ty::I32
                };
                Ok(Val {
                    v: self.c(&t, n as i64)?,
                    t,
                })
            }
            ExprKind::Real(n) => Ok(Val {
                v: self.l.constant(1, self.lt(&Ty::F64)?, 0, n, "")?,
                t: Ty::F64,
            }),
            ExprKind::Str(s) => Ok(Val {
                v: self.string(&s)?,
                t: Ty::String,
            }),
            ExprKind::Char(c) => Ok(Val {
                v: self.c(&Ty::Char, c as i64)?,
                t: Ty::Char,
            }),
            ExprKind::Bool(b) => Ok(Val {
                v: self.c(&Ty::Bool, i64::from(b))?,
                t: Ty::Bool,
            }),
            ExprKind::None => Ok(Val {
                v: self.null(&Ty::None)?,
                t: Ty::None,
            }),
            ExprKind::Type(_) => Err("type expression cannot be used as a runtime value".into()),
            ExprKind::Id(n) => {
                if let Some(l) = self.local(&n) {
                    return self.load(&l.t, l.addr, "local.load");
                }
                if let Some(v) = self.enum_value(&n) {
                    return Ok(Val {
                        v: self.c(&Ty::I32, v)?,
                        t: Ty::I32,
                    });
                }
                Err(format!("unknown identifier: {n}"))
            }
            ExprKind::Member(base, name) => {
                if let ExprKind::Id(n) = &self.project.files[self.file].exprs[base].kind
                    && let Some(v) = self.enum_value(&format!("{n}.{name}"))
                {
                    return Ok(Val {
                        v: self.c(&Ty::I32, v)?,
                        t: Ty::I32,
                    });
                }
                let p = self.place(e)?;
                self.load(&p.t, p.addr, "member.load")
            }
            ExprKind::Index(..) => {
                let p = self.place(e)?;
                self.load(
                    &p.t,
                    p.addr,
                    if matches!(p.t, Ty::Struct(_)) {
                        "load_struct_value_dyn"
                    } else {
                        "index.load"
                    },
                )
            }
            ExprKind::Unary(op, e) => {
                if op == "&" {
                    let p = self.place(e)?;
                    return Ok(Val {
                        v: p.addr,
                        t: Ty::Ptr(Box::new(p.t)),
                    });
                }
                if op == "*" {
                    let p = self.place_unary(e)?;
                    return self.load(&Ty::I32, p.addr, "deref.load");
                }
                if op == "++" || op == "--" {
                    return self.increment(e, &op, false);
                }
                let v = self.expr(e)?;
                if op == "!" {
                    let b = self.boolean(v)?;
                    return Ok(Val {
                        v: self
                            .l
                            .op("eq", None, &[b.0, self.c(&Ty::Bool, 0)?.0], "not", 0)?,
                        t: Ty::Bool,
                    });
                }
                if op == "+" {
                    return Ok(v);
                }
                let zero = if op == "~" {
                    self.c(&v.t, -1)?
                } else {
                    self.null(&v.t)?
                };
                let op = if op == "~" { "xor" } else { "sub" };
                Ok(Val {
                    v: self.l.op(op, None, &[zero.0, v.v.0], "unary", 0)?,
                    t: v.t,
                })
            }
            ExprKind::Post(op, e) => self.increment(e, &op, true),
            ExprKind::Binary(op, a, b) => {
                if op == "&&" || op == "||" {
                    let value = self.expr(a)?;
                    let test = self.boolean(value)?;
                    let slot = self.stack(&Ty::Bool, "short.result")?;
                    self.store(test, slot)?;
                    let rhs = self.block("short.rhs")?;
                    let done = self.block("short.end")?;
                    self.branch(
                        test,
                        if op == "&&" { rhs } else { done },
                        if op == "&&" { done } else { rhs },
                    )?;
                    self.l.position(rhs)?;
                    let v = self.expr(b)?;
                    self.store(self.boolean(v)?, slot)?;
                    self.br(done)?;
                    self.l.position(done)?;
                    return self.load(&Ty::Bool, slot, "short.result");
                }
                let a = self.expr(a)?;
                let b = self.expr(b)?;
                self.binary(&op, a, b)
            }
            ExprKind::Call(c, args) => self.call(c, args),
            ExprKind::Struct(t, fields) => {
                let t = self.resolve(self.file, &t)?;
                let Ty::Struct(i) = t else {
                    return Err("unknown struct type".into());
                };
                let mut v = self.null(&t)?;
                for (name, e) in fields {
                    let (j, field) = self.structs[i]
                        .fields
                        .iter()
                        .enumerate()
                        .find(|(_, f)| f.0 == name)
                        .ok_or_else(|| format!("unknown field {name}"))?;
                    let typ = field.1.clone();
                    let value = self.expr(e)?;
                    let value = self.coerce(value, &typ)?;
                    v = self.op("insert", &t, &[v.0, value.v.0], "struct.init", j as u64)?;
                }
                Ok(Val { v, t })
            }
            ExprKind::Vec(t, capacity) => {
                let t = self.resolve(self.file, &t)?;
                let cap = if let Some(e) = capacity {
                    let v = self.expr(e)?;
                    if !v.t.integer() {
                        return Err("Vec capacity must be an integer".into());
                    }
                    self.coerce(v, &Ty::I64)?.v
                } else {
                    self.i(0)?
                };
                let elem = t.element().unwrap();
                let v = self.array_new(&elem, cap)?;
                Ok(Val { v, t })
            }
            ExprKind::Array(es, annotation) => {
                let mut vals = Vec::new();
                for e in es {
                    vals.push(self.expr(e)?);
                }
                let t = if let Some(t) = annotation {
                    self.resolve(self.file, &t)?
                } else {
                    Ty::Slice(Box::new(vals.first().map_or(Ty::I64, |v| v.t.clone())))
                };
                let elem = t.element().ok_or("array requires element type")?;
                let n = vals.len() as i64;
                let arr = self.array_new(&elem, self.i(n.max(1))?)?;
                self.store(self.i(n)?, self.hfield(arr, 1)?)?;
                let data = self.hload(arr, 0)?;
                for (i, v) in vals.into_iter().enumerate() {
                    let v = self.coerce(v, &elem)?;
                    self.store(
                        v.v,
                        self.gep(&elem, data, self.i(i as i64)?, "array.literal.slot")?,
                    )?;
                    self.children(arr, &v)?;
                }
                Ok(Val { v: arr, t })
            }
        }
    }
    pub(super) fn enum_value(&self, n: &str) -> Option<i64> {
        self.enums
            .get(&(self.file, n.to_owned()))
            .copied()
            .or_else(|| {
                self.enums
                    .iter()
                    .find(|((_, name), _)| name == n)
                    .map(|(_, v)| *v)
            })
    }
    pub(super) fn binary(&self, op: &str, a: Val, b: Val) -> R<Val> {
        if (op == "+" || op == "-") && (a.t.pointer() || b.t.pointer()) {
            if a.t.pointer() && b.t.pointer() {
                let a = self.coerce(a, &Ty::I64)?;
                let b = self.coerce(b, &Ty::I64)?;
                return self.binary(op, a, b);
            }
            let (ptr, index) = if a.t.pointer() { (a, b) } else { (b, a) };
            let mut ix = self.coerce(index, &Ty::I64)?.v;
            if op == "-" {
                ix = self
                    .l
                    .op("sub", None, &[self.i(0)?.0, ix.0], "negative.index", 0)?;
            }
            let elem = ptr.t.element().unwrap_or(Ty::Byte);
            return Ok(Val {
                v: self.gep(&elem, ptr.v, ix, "pointer.offset")?,
                t: ptr.t,
            });
        }
        let common = if a.t.pointer() || b.t.pointer() {
            if a.t.pointer() {
                a.t.clone()
            } else {
                b.t.clone()
            }
        } else if a.t == Ty::F64 || b.t == Ty::F64 {
            Ty::F64
        } else if a.t.float() || b.t.float() {
            Ty::F32
        } else if a.t.bits().max(b.t.bits()) > 32 {
            Ty::I64
        } else {
            Ty::I32
        };
        let a = self.coerce(a, &common)?;
        let b = self.coerce(b, &common)?;
        let llvm = match op {
            "+" => "add",
            "-" => "sub",
            "*" => "mul",
            "/" => "div",
            "%" => "rem",
            "&" => "and",
            "|" => "or",
            "^" => "xor",
            "<<" => "shl",
            ">>" => "shr",
            "==" => "eq",
            "!=" => "ne",
            "<" => "lt",
            "<=" => "le",
            ">" => "gt",
            ">=" => "ge",
            _ => return Err(format!("unsupported operator {op}")),
        };
        let t = if matches!(llvm, "eq" | "ne" | "lt" | "le" | "gt" | "ge") {
            Ty::Bool
        } else {
            common
        };
        Ok(Val {
            v: self.l.op(llvm, None, &[a.v.0, b.v.0], llvm, 0)?,
            t,
        })
    }
    pub(super) fn increment(&mut self, e: E, op: &str, post: bool) -> R<Val> {
        let p = self.place(e)?;
        if p.constant {
            return Err("cannot assign to const".into());
        }
        let old = self.load(&p.t, p.addr, "post.old")?;
        let one = Val {
            v: self.c(&Ty::I32, 1)?,
            t: Ty::I32,
        };
        let new = self.binary(if op == "++" { "+" } else { "-" }, old.clone(), one)?;
        let new = self.coerce(new, &p.t)?;
        self.store(new.v, p.addr)?;
        Ok(if post { old } else { new })
    }
    pub(super) fn place_unary(&mut self, e: E) -> R<Place> {
        let v = self.expr(e)?;
        let t = v.t.element().ok_or("dereference requires a pointer")?;
        Ok(Place {
            addr: v.v,
            t,
            owner: None,
            depth: self.depth,
            constant: false,
        })
    }
    pub(super) fn place(&mut self, e: E) -> R<Place> {
        match self.project.files[self.file].exprs[e].kind.clone() {
            ExprKind::Id(n) => {
                let l = self
                    .local(&n)
                    .ok_or_else(|| format!("unknown identifier: {n}"))?;
                Ok(Place {
                    addr: l.addr,
                    t: l.t,
                    owner: None,
                    depth: l.depth,
                    constant: l.constant,
                })
            }
            ExprKind::Unary(op, e) if op == "*" => self.place_unary(e),
            ExprKind::Index(base, ix) => {
                let v = self.expr(base)?;
                let i = self.expr(ix)?;
                let i = self.coerce(i, &Ty::I64)?.v;
                let elem =
                    v.t.element()
                        .ok_or("index requires a collection or pointer")?;
                let (data, owner) = if matches!(v.t, Ty::Slice(_) | Ty::Vec(_)) {
                    let len = self.hload(v.v, 1)?;
                    let bad = self.l.op(
                        "ugt",
                        None,
                        &[
                            i.0,
                            self.l
                                .op("sub", None, &[len.0, self.i(1)?.0], "last.index", 0)?
                                .0,
                        ],
                        "index.outside",
                        0,
                    )?;
                    let empty = self
                        .l
                        .op("eq", None, &[len.0, self.i(0)?.0], "index.empty", 0)?;
                    let bad = self
                        .l
                        .op("or", None, &[bad.0, empty.0], "index.invalid", 0)?;
                    self.guard(bad, "bounds")?;
                    (self.hload(v.v, 0)?, Some(v.v))
                } else {
                    (v.v, None)
                };
                let addr = self.gep(&elem, data, i, "index.addr")?;
                Ok(Place {
                    addr,
                    t: elem,
                    owner,
                    depth: self.depth,
                    constant: false,
                })
            }
            ExprKind::Member(base, name) => {
                // Resolve an lvalue once: indexes and calls may have side effects.
                let original = match &self.project.files[self.file].exprs[base].kind {
                    ExprKind::Id(_) | ExprKind::Member(..) | ExprKind::Index(..) => {
                        Some(self.place(base)?)
                    }
                    ExprKind::Unary(op, _) if op == "*" => Some(self.place(base)?),
                    _ => None,
                };
                let (typ, addr, owner, depth, constant) = if let Some(p) = original {
                    match p.t {
                        Ty::Struct(i) => (i, p.addr, p.owner, p.depth, p.constant),
                        Ty::Ptr(t) => {
                            let Ty::Struct(i) = *t else {
                                return Err("member access requires a struct".into());
                            };
                            let pointer = self
                                .load(&Ty::Ptr(Box::new(Ty::Struct(i))), p.addr, "struct.pointer")?
                                .v;
                            (i, pointer, Some(pointer), self.depth, false)
                        }
                        _ => return Err("member access requires a struct".into()),
                    }
                } else {
                    let v = self.expr(base)?;
                    match v.t {
                        Ty::Struct(i) => {
                            let ptr = self.stack(&Ty::Struct(i), "struct.value")?;
                            self.store(v.v, ptr)?;
                            (i, ptr, None, self.depth, false)
                        }
                        Ty::Ptr(t) => {
                            let Ty::Struct(i) = *t else {
                                return Err("member access requires a struct".into());
                            };
                            (i, v.v, Some(v.v), self.depth, false)
                        }
                        _ => return Err("member access requires a struct".into()),
                    }
                };
                let (index, field) = self.structs[typ]
                    .fields
                    .iter()
                    .enumerate()
                    .find(|(_, f)| f.0 == name)
                    .ok_or_else(|| format!("unknown struct field {name}"))?;
                let field_type = field.1.clone();
                let addr = self.field(self.struct_types[typ], addr, index, "field.addr")?;
                Ok(Place {
                    addr,
                    t: field_type,
                    owner,
                    depth,
                    constant,
                })
            }
            _ => Err("expression is not assignable".into()),
        }
    }
}
