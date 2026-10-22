use super::*;

impl Generator<'_> {
    pub(super) fn array_new(&self, elem: &Ty, cap: Value) -> R<Value> {
        let size = self.l.size(self.lt(elem)?)?.max(1);
        let negative = self
            .l
            .op("lt", None, &[cap.0, self.i(0)?.0], "capacity.negative", 0)?;
        self.guard(negative, "capacity")?;
        let too_big = self.l.op(
            "ugt",
            None,
            &[cap.0, self.i((i64::MAX as u64 / size) as i64)?.0],
            "capacity.overflow",
            0,
        )?;
        self.guard(too_big, "capacity.overflow")?;
        let header = self
            .rt(
                "yc_calloc",
                &Ty::String,
                &[
                    self.int(self.i(1)?),
                    self.int(self.i(self.l.size(self.header)? as i64)?),
                ],
            )?
            .v;
        let zero = self
            .l
            .op("eq", None, &[cap.0, self.i(0)?.0], "capacity.zero", 0)?;
        let alloc = self.l.op(
            "select",
            None,
            &[zero.0, self.i(1)?.0, cap.0],
            "allocation.capacity",
            0,
        )?;
        let data = self
            .rt(
                "yc_calloc",
                &Ty::String,
                &[self.int(alloc), self.int(self.i(size as i64)?)],
            )?
            .v;
        let oom = self.l.op(
            "eq",
            None,
            &[header.0, self.null(&Ty::String)?.0],
            "header.null",
            0,
        )?;
        self.guard(oom, "header.oom")?;
        let oom = self.l.op(
            "eq",
            None,
            &[data.0, self.null(&Ty::String)?.0],
            "data.null",
            0,
        )?;
        self.guard(oom, "data.oom")?;
        self.store(data, self.hfield(header, 0)?)?;
        self.store(self.i(0)?, self.hfield(header, 1)?)?;
        self.store(cap, self.hfield(header, 2)?)?;
        self.store(self.i(size as i64)?, self.hfield(header, 3)?)?;
        self.children(header, &self.ptr(data))?;
        Ok(header)
    }
    pub(super) fn array_slot(&self, header: Value, elem: &Ty, index: Value) -> R<Value> {
        let len = self.hload(header, 1)?;
        let neg = self
            .l
            .op("lt", None, &[index.0, self.i(0)?.0], "bounds.negative", 0)?;
        let high = self.l.op("ge", None, &[index.0, len.0], "bounds.high", 0)?;
        let bad = self
            .l
            .op("or", None, &[neg.0, high.0], "bounds.invalid", 0)?;
        self.guard(bad, "bounds")?;
        self.gep(elem, self.hload(header, 0)?, index, "array.slot")
    }
    pub(super) fn reserve(&self, arr: &Val, requested: Value) -> R<()> {
        let cap = self.hload(arr.v, 2)?;
        let neg = self.l.op(
            "lt",
            None,
            &[requested.0, self.i(0)?.0],
            "vec.reserve.negative",
            0,
        )?;
        self.guard(neg, "vec.reserve")?;
        let elem = arr.t.element().ok_or("reserve requires collection")?;
        let size = self.l.size(self.lt(&elem)?)?.max(1);
        let too_big = self.l.op(
            "ugt",
            None,
            &[requested.0, self.i((i64::MAX as u64 / size) as i64)?.0],
            "vec.reserve.overflow",
            0,
        )?;
        self.guard(too_big, "vec.reserve.overflow")?;
        let grow = self.block("array.grow")?;
        let done = self.block("array.grown")?;
        let needed = self
            .l
            .op("gt", None, &[requested.0, cap.0], "array.needs.grow", 0)?;
        self.branch(needed, grow, done)?;
        self.l.position(grow)?;
        let old = self.hload(arr.v, 0)?;
        let data = self
            .rt(
                "yc_calloc",
                &Ty::String,
                &[self.int(requested), self.int(self.i(size as i64)?)],
            )?
            .v;
        let oom = self.l.op(
            "eq",
            None,
            &[data.0, self.null(&Ty::String)?.0],
            "grow.null",
            0,
        )?;
        self.guard(oom, "grow.oom")?;
        let len = self.hload(arr.v, 1)?;
        let bytes = self.l.op(
            "mul",
            None,
            &[len.0, self.i(size as i64)?.0],
            "array.copy.bytes",
            0,
        )?;
        self.l
            .op("memcpy", None, &[data.0, old.0, bytes.0], "", 0)?;
        self.rt(
            "yc_replace_child",
            &Ty::Void,
            &[self.ptr(arr.v), self.ptr(old), self.ptr(data)],
        )?;
        self.rt("yc_release", &Ty::Void, &[self.ptr(old)])?;
        self.store(data, self.hfield(arr.v, 0)?)?;
        self.store(requested, self.hfield(arr.v, 2)?)?;
        self.br(done)?;
        self.l.position(done)?;
        Ok(())
    }
    pub(super) fn append(&self, arr: Val, v: Val, return_index: bool) -> R<Val> {
        let elem = arr.t.element().ok_or("append requires collection")?;
        if matches!(arr.t, Ty::Vec(_)) && v.t != elem {
            return Err("Vec.push value type does not match element type".into());
        }
        let v = self.coerce(v, &elem)?;
        let len = self.hload(arr.v, 1)?;
        let cap = self.hload(arr.v, 2)?;
        let next = self
            .l
            .op("add", None, &[len.0, self.i(1)?.0], "array.new.len", 0)?;
        let twice = self
            .l
            .op("mul", None, &[cap.0, self.i(2)?.0], "array.twice", 0)?;
        let greater = self
            .l
            .op("gt", None, &[twice.0, next.0], "array.growth", 0)?;
        let growth = self.l.op(
            "select",
            None,
            &[greater.0, twice.0, next.0],
            "array.growth.capacity",
            0,
        )?;
        let full = self.l.op("ge", None, &[len.0, cap.0], "array.full", 0)?;
        let requested = self.l.op(
            "select",
            None,
            &[full.0, growth.0, cap.0],
            "array.capacity",
            0,
        )?;
        self.reserve(&arr, requested)?;
        let ptr = self.gep(&elem, self.hload(arr.v, 0)?, len, "array.append.slot")?;
        self.store(v.v, ptr)?;
        self.children(arr.v, &v)?;
        self.store(next, self.hfield(arr.v, 1)?)?;
        if return_index {
            self.coerce(self.int(len), &Ty::I32)
        } else {
            Ok(arr)
        }
    }
    pub(super) fn vec_method(&mut self, arr: Val, name: &str, args: Vec<E>) -> R<Val> {
        let arity = match name {
            "push" | "reserve" => 1,
            "len" | "capacity" | "as_slice" | "clear" => 0,
            _ => return Err(format!("unknown Vec method {name}")),
        };
        if args.len() != arity {
            return Err(format!("Vec.{name} expects {arity} argument(s)"));
        }
        match name {
            "push" => {
                if args.len() != 1 {
                    return Err("Vec.push expects one argument".into());
                }
                let v = self.expr(args[0])?;
                self.append(arr, v, true)
            }
            "len" | "capacity" => {
                let h = self.hload(arr.v, if name == "len" { 1 } else { 2 })?;
                self.coerce(self.int(h), &Ty::I32)
            }
            "as_slice" => Ok(Val {
                v: arr.v,
                t: Ty::Slice(Box::new(arr.t.element().unwrap())),
            }),
            "reserve" => {
                let v = self.expr(args[0])?;
                let v = self.coerce(v, &Ty::I64)?;
                self.reserve(&arr, v.v)?;
                Ok(Val {
                    v: self.i(0)?,
                    t: Ty::I64,
                })
            }
            "clear" => {
                let elem = arr.t.element().unwrap();
                let slot = self.stack(&Ty::I64, "vec.clear.index")?;
                self.store(self.i(0)?, slot)?;
                let test = self.block("vec.clear.test")?;
                let body = self.block("vec.clear.body")?;
                let done = self.block("vec.clear.end")?;
                self.br(test)?;
                self.l.position(test)?;
                let i = self.load(&Ty::I64, slot, "vec.clear.index")?.v;
                let len = self.hload(arr.v, 1)?;
                let more = self.l.op("lt", None, &[i.0, len.0], "vec.clear.more", 0)?;
                self.branch(more, body, done)?;
                self.l.position(body)?;
                let ptr = self.gep(&elem, self.hload(arr.v, 0)?, i, "vec.clear.slot")?;
                self.release(&self.load(&elem, ptr, "vec.clear.old")?)?;
                self.store(self.null(&elem)?, ptr)?;
                let next = self
                    .l
                    .op("add", None, &[i.0, self.i(1)?.0], "vec.clear.next", 0)?;
                self.store(next, slot)?;
                self.br(test)?;
                self.l.position(done)?;
                self.store(self.i(0)?, self.hfield(arr.v, 1)?)?;
                Ok(Val {
                    v: self.i(0)?,
                    t: Ty::I64,
                })
            }
            _ => Err(format!("unknown Vec method {name}")),
        }
    }
}
