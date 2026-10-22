use super::*;

impl Generator<'_> {
    pub(super) fn lt(&self, t: &Ty) -> R<Type> {
        match t {
            Ty::Void => self.l.typ(0, 0, &[], ""),
            Ty::F32 => self.l.typ(2, 0, &[], ""),
            Ty::F64 => self.l.typ(3, 0, &[], ""),
            Ty::Struct(i) => Ok(self.struct_types[*i]),
            t if t.integer() => self.l.typ(1, t.bits(), &[], ""),
            Ty::Named(_) => self.lt(&self.resolve(self.file, t)?),
            _ => self.l.typ(4, 0, &[], ""),
        }
    }
    pub(super) fn op(&self, op: &str, t: &Ty, args: &[u64], name: &str, aux: u64) -> R<Value> {
        self.l.op(op, Some(self.lt(t)?), args, name, aux)
    }
    pub(super) fn c(&self, t: &Ty, n: i64) -> R<Value> {
        self.l.constant(0, self.lt(t)?, n as u64, 0.0, "")
    }
    pub(super) fn i(&self, n: i64) -> R<Value> {
        self.c(&Ty::I64, n)
    }
    pub(super) fn null(&self, t: &Ty) -> R<Value> {
        self.l.constant(2, self.lt(t)?, 0, 0.0, "")
    }
    pub(super) fn string(&self, s: &str) -> R<Value> {
        self.l.constant(3, self.lt(&Ty::String)?, 0, 0.0, s)
    }
    pub(super) fn load(&self, t: &Ty, addr: Value, name: &str) -> R<Val> {
        Ok(Val {
            v: self.op("load", t, &[addr.0], name, 0)?,
            t: t.clone(),
        })
    }
    pub(super) fn store(&self, v: Value, a: Value) -> R<()> {
        self.l.op("store", None, &[v.0, a.0], "", 0)?;
        Ok(())
    }
    pub(super) fn stack(&self, t: &Ty, name: &str) -> R<Value> {
        self.op("alloca", t, &[], name, 0)
    }
    pub(super) fn field(&self, typ: Type, addr: Value, i: usize, name: &str) -> R<Value> {
        self.l.op("field", Some(typ), &[addr.0], name, i as u64)
    }
    pub(super) fn hfield(&self, header: Value, i: usize) -> R<Value> {
        self.field(self.header, header, i, "header.field")
    }
    pub(super) fn hload(&self, header: Value, i: usize) -> R<Value> {
        Ok(self
            .load(
                if i == 0 { &Ty::String } else { &Ty::I64 },
                self.hfield(header, i)?,
                "header.load",
            )?
            .v)
    }
    pub(super) fn gep(&self, t: &Ty, base: Value, index: Value, name: &str) -> R<Value> {
        self.op("gep", t, &[base.0, index.0], name, 0)
    }
    pub(super) fn rt(&self, name: &str, ret: &Ty, args: &[Val]) -> R<Val> {
        let mut ts = vec![self.lt(ret)?];
        for a in args {
            ts.push(self.lt(&a.t)?);
        }
        let ft = self.l.typ(7, 0, &ts, "")?;
        let f = self.l.func(name, ft)?;
        let mut vs = vec![f.0];
        vs.extend(args.iter().map(|a| a.v.0));
        let v = self.l.op("call", Some(ft), &vs, "runtime.call", 0)?;
        Ok(Val { v, t: ret.clone() })
    }
    pub(super) fn rt0(&self, name: &str) -> R<()> {
        self.rt(name, &Ty::Void, &[])?;
        Ok(())
    }
    pub(super) fn ptr(&self, v: Value) -> Val {
        Val { v, t: Ty::String }
    }
    pub(super) fn int(&self, v: Value) -> Val {
        Val { v, t: Ty::I64 }
    }
    pub(super) fn escape(&self, v: &Val, levels: usize) -> R<()> {
        if levels == 0 {
            return Ok(());
        }
        if v.t.pointer() {
            self.rt(
                "yc_move_to_ancestor",
                &Ty::String,
                &[self.ptr(v.v), self.int(self.i(levels as i64)?)],
            )?;
        } else if let Ty::Struct(i) = v.t {
            for (j, (_, t)) in self.structs[i].fields.iter().enumerate() {
                let e = self.op("extract", t, &[v.v.0], "escape.field", j as u64)?;
                self.escape(&Val { v: e, t: t.clone() }, levels)?;
            }
        }
        Ok(())
    }
    pub(super) fn children(&self, parent: Value, v: &Val) -> R<()> {
        if v.t.pointer() {
            self.rt(
                "yc_attach_child",
                &Ty::Void,
                &[self.ptr(parent), self.ptr(v.v)],
            )?;
        } else if let Ty::Struct(i) = v.t {
            for (j, (_, t)) in self.structs[i].fields.iter().enumerate() {
                let e = self.op("extract", t, &[v.v.0], "child.field", j as u64)?;
                self.children(parent, &Val { v: e, t: t.clone() })?;
            }
        }
        Ok(())
    }
    pub(super) fn release(&self, v: &Val) -> R<()> {
        if v.t.pointer() {
            self.rt("yc_release", &Ty::Void, &[self.ptr(v.v)])?;
        } else if let Ty::Struct(i) = v.t {
            for (j, (_, t)) in self.structs[i].fields.iter().enumerate() {
                let e = self.op("extract", t, &[v.v.0], "release.field", j as u64)?;
                self.release(&Val { v: e, t: t.clone() })?;
            }
        }
        Ok(())
    }
    pub(super) fn field_children(&self, parent: Value, v: &Val) -> R<()> {
        if v.t.pointer() {
            self.rt(
                "yc_attach_child_to_owner",
                &Ty::Void,
                &[self.ptr(parent), self.ptr(v.v)],
            )?;
        } else if let Ty::Struct(i) = v.t {
            for (j, (_, t)) in self.structs[i].fields.iter().enumerate() {
                let field = self.op("extract", t, &[v.v.0], "field.child", j as u64)?;
                self.field_children(
                    parent,
                    &Val {
                        v: field,
                        t: t.clone(),
                    },
                )?;
            }
        }
        Ok(())
    }
    pub(super) fn replace(&self, parent: Value, old: &Val, new: &Val) -> R<()> {
        if old.t.pointer() {
            let changed = self
                .l
                .op("ne", None, &[old.v.0, new.v.0], "vec.replace.changed", 0)?;
            let release = self.block("vec.replace.release")?;
            let done = self.block("vec.replace.end")?;
            self.branch(changed, release, done)?;
            self.l.position(release)?;
            self.rt(
                "yc_replace_child",
                &Ty::Void,
                &[self.ptr(parent), self.ptr(old.v), self.ptr(new.v)],
            )?;
            self.release(old)?;
            self.br(done)?;
            self.l.position(done)?;
        } else if let Ty::Struct(i) = old.t {
            for (j, (_, t)) in self.structs[i].fields.iter().enumerate() {
                let a = self.op("extract", t, &[old.v.0], "old.child", j as u64)?;
                let b = self.op("extract", t, &[new.v.0], "new.child", j as u64)?;
                self.replace(
                    parent,
                    &Val { v: a, t: t.clone() },
                    &Val { v: b, t: t.clone() },
                )?;
            }
        }
        Ok(())
    }
    pub(super) fn coerce(&self, v: Val, t: &Ty) -> R<Val> {
        if v.t == *t {
            return Ok(v);
        }
        if v.t.pointer() && t.pointer() {
            return Ok(Val {
                v: v.v,
                t: t.clone(),
            });
        }
        if (v.t.integer() || v.t.float() || v.t.pointer())
            && (t.integer() || t.float() || t.pointer())
        {
            let signed = v.t != Ty::Bool;
            let h = self.op(
                "cast",
                t,
                &[v.v.0],
                if t.bits() > v.t.bits() {
                    if signed { "sext" } else { "zext" }
                } else {
                    "cast"
                },
                u64::from(signed),
            )?;
            return Ok(Val { v: h, t: t.clone() });
        }
        Err(format!("cannot convert {:?} to {t:?}", v.t))
    }
    pub(super) fn boolean(&self, v: Val) -> R<Value> {
        if v.t == Ty::Bool {
            return Ok(v.v);
        }
        self.l
            .op("ne", None, &[v.v.0, self.null(&v.t)?.0], "truth", 0)
    }
    pub(super) fn local(&self, n: &str) -> Option<Local> {
        self.locals.iter().rev().find(|l| l.name == n).cloned()
    }
    pub(super) fn block(&self, name: &str) -> R<Block> {
        self.l.block(self.funcs[self.current].value, name)
    }
    pub(super) fn br(&self, to: Block) -> R<()> {
        if !self.l.terminated() {
            self.l.op("br", None, &[to.0], "", 0)?;
        }
        Ok(())
    }
    pub(super) fn branch(&self, c: Value, yes: Block, no: Block) -> R<()> {
        self.l.op("cond", None, &[c.0, yes.0, no.0], "", 0)?;
        Ok(())
    }
    pub(super) fn guard(&self, bad: Value, name: &str) -> R<()> {
        let abort = self.block(&format!("{name}.abort"))?;
        let ok = self.block(&format!("{name}.ok"))?;
        self.branch(bad, abort, ok)?;
        self.l.position(abort)?;
        self.rt0("abort")?;
        self.l.op("unreachable", None, &[], "", 0)?;
        self.l.position(ok)?;
        Ok(())
    }
}
