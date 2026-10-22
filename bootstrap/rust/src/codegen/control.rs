use super::*;

impl Generator<'_> {
    pub(super) fn run(&mut self) -> R<String> {
        for i in 0..self.funcs.len() {
            let f = self.funcs[i].clone();
            if let Some(body) = f.ast.body {
                self.file = f.file;
                self.span = f.ast.span;
                self.current = i;
                self.depth = 0;
                self.locals.clear();
                self.defers.clear();
                self.loops.clear();
                let entry = self.l.block(f.value, "entry")?;
                self.l.position(entry)?;
                if f.ast.name == "main" {
                    self.rt0("yc_runtime_init")?;
                }
                self.rt0("yc_frame_push")?;
                for (i, (n, _)) in f.ast.params.iter().enumerate() {
                    let t = f.params[i].clone();
                    let a = self.stack(&t, n)?;
                    self.store(self.l.param(f.value, i as u32)?, a)?;
                    self.locals.push(Local {
                        name: n.clone(),
                        addr: a,
                        t,
                        constant: false,
                        depth: 0,
                    });
                }
                if f.ast.ret != Ty::Void && !self.has_return(body) {
                    return Err("non-void function is missing an explicit return".into());
                }
                self.stmt(body)?;
                if !self.l.terminated() {
                    self.cleanup()?;
                    let v = if f.ret == Ty::Void {
                        Vec::new()
                    } else {
                        vec![self.null(&f.ret)?.0]
                    };
                    self.l.op("ret", None, &v, "", 0)?;
                }
            }
        }
        self.l.ir()
    }
    pub(super) fn has_return(&self, s: S) -> bool {
        match &self.project.files[self.file].stmts[s].kind {
            StmtKind::Return(_) => true,
            StmtKind::Block(v, _) => v.iter().any(|&s| self.has_return(s)),
            StmtKind::If(_, a, b) => self.has_return(*a) || b.is_some_and(|s| self.has_return(s)),
            StmtKind::For(_, _, _, b) | StmtKind::ForIn(_, _, b) => self.has_return(*b),
            StmtKind::Switch(_, v) => v.iter().any(|(_, s)| self.has_return(*s)),
            _ => false,
        }
    }
    pub(super) fn cleanup(&self) -> R<()> {
        for _ in 0..=self.depth {
            self.rt0("yc_frame_pop")?;
        }
        if self.funcs[self.current].ast.name == "main" {
            self.rt0("yc_runtime_shutdown")?;
        }
        Ok(())
    }
    pub(super) fn deferred(&mut self, mark: usize) -> R<()> {
        let todo = self.defers[mark..].to_vec();
        for s in todo.into_iter().rev() {
            self.stmt(s)?;
        }
        Ok(())
    }
    pub(super) fn stmt(&mut self, s: S) -> R<()> {
        if self.l.terminated() {
            return Ok(());
        }
        let node = self.project.files[self.file].stmts[s].clone();
        self.span = node.span;
        match node.kind {
            StmtKind::Block(v, own) => {
                let locals = self.locals.len();
                let mark = self.defers.len();
                if own {
                    self.rt0("yc_frame_push")?;
                    self.depth += 1;
                }
                for s in v {
                    self.stmt(s)?;
                }
                if !self.l.terminated() {
                    self.deferred(mark)?;
                    if own {
                        self.rt0("yc_frame_pop")?;
                    }
                }
                if own {
                    self.depth -= 1;
                }
                self.defers.truncate(mark);
                self.locals.truncate(locals);
            }
            StmtKind::Let(n, typ, e, constant) => {
                let v = self.expr(e)?;
                let t = if let Some(t) = typ {
                    let t = self.resolve(self.file, &t)?;
                    if v.t == Ty::None && !t.pointer() {
                        return Err("none can only initialize pointer or string types".into());
                    }
                    if (matches!(t, Ty::Vec(_)) || matches!(v.t, Ty::Vec(_))) && t != v.t {
                        return Err("Vec value cannot initialize a different declared type".into());
                    }
                    t
                } else {
                    if v.t == Ty::None {
                        return Err("none requires an explicit pointer or string type".into());
                    }
                    v.t.clone()
                };
                let v = self.coerce(v, &t)?;
                let addr = self.stack(&t, &n)?;
                self.store(v.v, addr)?;
                self.locals.push(Local {
                    name: n,
                    addr,
                    t,
                    constant,
                    depth: self.depth,
                });
            }
            StmtKind::Assign(e, op, rhs) => {
                let place = self.place(e)?;
                if place.constant {
                    return Err("cannot assign to const".into());
                }
                let value = self.expr(rhs)?;
                let value = if op != "=" {
                    let left = self.load(&place.t, place.addr, "compound.old")?;
                    self.binary(&op[..op.len() - 1], left, value)?
                } else {
                    value
                };
                let value = self.coerce(value, &place.t)?;
                if self.depth > place.depth {
                    self.escape(&value, self.depth - place.depth)?;
                }
                if let Some(owner) = place.owner {
                    if matches!(
                        self.project.files[self.file].exprs[e].kind,
                        ExprKind::Index(..)
                    ) {
                        let old = self.load(&place.t, place.addr, "vec.replace.old")?;
                        self.replace(owner, &old, &value)?;
                    } else {
                        self.field_children(owner, &value)?;
                    }
                }
                self.store(value.v, place.addr)?;
            }
            StmtKind::Expr(e) => {
                self.expr(e)?;
            }
            StmtKind::Return(expr) => {
                let ret = self.funcs[self.current].ret.clone();
                let value = if let Some(e) = expr {
                    if self.funcs[self.current].ast.ret == Ty::Void
                        && self.funcs[self.current].ast.name != "main"
                    {
                        return Err("void function cannot return a value".into());
                    }
                    let v = self.expr(e)?;
                    Some(self.coerce(v, &ret)?)
                } else if ret == Ty::Void {
                    None
                } else if self.funcs[self.current].ast.name == "main" {
                    Some(Val {
                        v: self.c(&Ty::I32, 0)?,
                        t: Ty::I32,
                    })
                } else {
                    return Err("non-void function requires a return value".into());
                };
                self.deferred(0)?;
                if let Some(v) = &value {
                    self.escape(v, self.depth + 1)?;
                    // Legacy aggregate APIs can return allocations that have not
                    // yet been attached to their aggregate's ownership graph.
                    // Preserve the same frame escape as the other YCPL seeds.
                    if matches!(v.t, Ty::Struct(_)) {
                        self.rt0("yc_move_frame_to_parent")?;
                    }
                }
                self.cleanup()?;
                self.l.op(
                    "ret",
                    None,
                    &value.map_or(Vec::new(), |v| vec![v.v.0]),
                    "",
                    0,
                )?;
            }
            StmtKind::If(c, yes, no) => {
                let v = self.expr(c)?;
                let c = self.boolean(v)?;
                let y = self.block("if.then")?;
                let n = self.block("if.else")?;
                let done = self.block("if.end")?;
                self.branch(c, y, n)?;
                self.l.position(y)?;
                self.stmt(yes)?;
                self.br(done)?;
                self.l.position(n)?;
                if let Some(s) = no {
                    self.stmt(s)?;
                }
                self.br(done)?;
                self.l.position(done)?;
            }
            StmtKind::For(init, c, post, body) => {
                let locals = self.locals.len();
                if let Some(s) = init {
                    self.stmt(s)?;
                }
                let check = self.block("for.cond")?;
                let b = self.block("for.body")?;
                let p = self.block("for.post")?;
                let done = self.block("for.end")?;
                self.br(check)?;
                self.l.position(check)?;
                let cond = if let Some(e) = c {
                    let v = self.expr(e)?;
                    self.boolean(v)?
                } else {
                    self.c(&Ty::Bool, 1)?
                };
                self.branch(cond, b, done)?;
                self.l.position(b)?;
                self.loops.push(Loop {
                    done,
                    next: Some(p),
                    defers: self.defers.len(),
                    depth: self.depth,
                });
                self.stmt(body)?;
                self.loops.pop();
                self.br(p)?;
                self.l.position(p)?;
                if let Some(e) = post {
                    self.expr(e)?;
                }
                self.br(check)?;
                self.l.position(done)?;
                self.locals.truncate(locals);
            }
            StmtKind::ForIn(n, e, body) => {
                let v = self.expr(e)?;
                let range = v.t.integer();
                let elem = if range {
                    Ty::I32
                } else {
                    v.t.element().ok_or("for-in requires a collection")?
                };
                let len = if range {
                    self.coerce(v.clone(), &Ty::I64)?.v
                } else if v.t == Ty::String {
                    self.rt("strlen", &Ty::I64, &[self.ptr(v.v)])?.v
                } else {
                    self.hload(v.v, 1)?
                };
                let ix = self.stack(&Ty::I64, "for.index")?;
                self.store(self.i(0)?, ix)?;
                let item = self.stack(&elem, &n)?;
                let count = self.locals.len();
                self.locals.push(Local {
                    name: n,
                    addr: item,
                    t: elem.clone(),
                    depth: self.depth,
                    constant: false,
                });
                let check = self.block("forin.cond")?;
                let b = self.block("forin.body")?;
                let post = self.block("forin.post")?;
                let done = self.block("forin.end")?;
                self.br(check)?;
                self.l.position(check)?;
                let i = self.load(&Ty::I64, ix, "for.index")?.v;
                let cond = self.l.op("lt", None, &[i.0, len.0], "for.more", 0)?;
                self.branch(cond, b, done)?;
                self.l.position(b)?;
                if range {
                    self.store(self.coerce(self.int(i), &elem)?.v, item)?;
                } else {
                    let data = if v.t == Ty::String {
                        v.v
                    } else {
                        self.hload(v.v, 0)?
                    };
                    let ptr = self.gep(&elem, data, i, "for.item")?;
                    self.store(self.load(&elem, ptr, "for.value")?.v, item)?;
                }
                self.loops.push(Loop {
                    done,
                    next: Some(post),
                    defers: self.defers.len(),
                    depth: self.depth,
                });
                self.stmt(body)?;
                self.loops.pop();
                self.br(post)?;
                self.l.position(post)?;
                let old = self.load(&Ty::I64, ix, "index")?.v;
                let next = self
                    .l
                    .op("add", None, &[old.0, self.i(1)?.0], "index.next", 0)?;
                self.store(next, ix)?;
                self.br(check)?;
                self.l.position(done)?;
                self.locals.truncate(count);
            }
            StmtKind::Switch(e, cases) => {
                let v = self.expr(e)?;
                let v = self.coerce(v, &Ty::I32)?;
                let done = self.block("switch.end")?;
                let mut args = vec![v.v.0, done.0];
                let mut bodies = Vec::new();
                for (case, body) in cases {
                    let block = self.block("switch.case")?;
                    if let Some(e) = case {
                        let c = self.expr(e)?;
                        let c = self.coerce(c, &Ty::I32)?;
                        args.extend([c.v.0, block.0]);
                    } else {
                        args[1] = block.0;
                    }
                    bodies.push((block, body));
                }
                self.l.op("switch", None, &args, "", 0)?;
                self.loops.push(Loop {
                    done,
                    next: None,
                    defers: self.defers.len(),
                    depth: self.depth,
                });
                for (b, s) in bodies {
                    self.l.position(b)?;
                    self.stmt(s)?;
                    self.br(done)?;
                }
                self.loops.pop();
                self.l.position(done)?;
            }
            StmtKind::Break | StmtKind::Continue => {
                let cont = matches!(node.kind, StmtKind::Continue);
                let target = self
                    .loops
                    .iter()
                    .rev()
                    .find(|l| !cont || l.next.is_some())
                    .cloned()
                    .ok_or("break/continue used outside of loop")?;
                self.deferred(target.defers)?;
                for _ in target.depth..self.depth {
                    self.rt0("yc_frame_pop")?;
                }
                self.br(if cont {
                    target.next.unwrap()
                } else {
                    target.done
                })?;
            }
            StmtKind::Defer(s) => self.defers.push(s),
        }
        Ok(())
    }
}
