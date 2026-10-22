//! YCPL type resolution and lowering, implemented entirely in Rust.

mod calls;
mod collections;
mod control;
mod expressions;
mod ir;

use crate::{
    ast::*,
    llvm::{Block, Llvm, Type, Value},
    project::Project,
};
use std::collections::{BTreeMap, BTreeSet};
type R<T> = std::result::Result<T, String>;
#[derive(Clone)]
struct Structure {
    name: String,
    file: usize,
    fields: Vec<(String, Ty)>,
}
#[derive(Clone)]
struct Func {
    file: usize,
    ast: Function,
    ret: Ty,
    params: Vec<Ty>,
    ft: Type,
    value: Value,
}
#[derive(Clone)]
struct Val {
    v: Value,
    t: Ty,
}
#[derive(Clone)]
struct Local {
    name: String,
    addr: Value,
    t: Ty,
    constant: bool,
    depth: usize,
}
#[derive(Clone)]
struct Place {
    addr: Value,
    t: Ty,
    owner: Option<Value>,
    depth: usize,
    constant: bool,
}
#[derive(Clone)]
struct Loop {
    done: Block,
    next: Option<Block>,
    defers: usize,
    depth: usize,
}
pub struct Generator<'a> {
    project: &'a Project,
    l: Llvm,
    structs: Vec<Structure>,
    struct_types: Vec<Type>,
    funcs: Vec<Func>,
    names: BTreeMap<(usize, String), usize>,
    aliases: BTreeMap<(usize, String), Ty>,
    enums: BTreeMap<(usize, String), i64>,
    locals: Vec<Local>,
    defers: Vec<S>,
    loops: Vec<Loop>,
    file: usize,
    span: Span,
    current: usize,
    depth: usize,
    header: Type,
}
pub fn emit(project: &Project) -> Result<String> {
    let mut g = Generator::new(project).map_err(|m| Error {
        file: project.files[0].path.clone(),
        span: Span { line: 1, col: 1 },
        message: m,
    })?;
    let r = g.run();
    r.map_err(|message| Error {
        file: project.files[g.file].path.clone(),
        span: g.span,
        message,
    })
}
impl<'a> Generator<'a> {
    fn new(project: &'a Project) -> R<Self> {
        let l = Llvm::new();
        let header = l.typ(5, 0, &[], "YCPLArrayHeader")?;
        let ptr = l.typ(4, 0, &[], "")?;
        let int = l.typ(1, 64, &[], "")?;
        l.body(header, &[ptr, int, int, int])?;
        let mut g = Self {
            project,
            l,
            structs: Vec::new(),
            struct_types: Vec::new(),
            funcs: Vec::new(),
            names: BTreeMap::new(),
            aliases: BTreeMap::new(),
            enums: BTreeMap::new(),
            locals: Vec::new(),
            defers: Vec::new(),
            loops: Vec::new(),
            file: 0,
            span: Span { line: 1, col: 1 },
            current: 0,
            depth: 0,
            header,
        };
        let mut declared = BTreeSet::new();
        for (file, f) in project.files.iter().enumerate() {
            for d in &f.declarations {
                let name = match d {
                    Decl::Function(fun) => &fun.name,
                    Decl::Struct(name, ..) | Decl::Alias(name, ..) | Decl::Enum(name, ..) => name,
                };
                if !declared.insert((f.module.clone(), name.clone())) {
                    return Err(format!("duplicate declaration: {}.{name}", f.module));
                }
                match d {
                    Decl::Struct(n, fields, _) => {
                        g.structs.push(Structure {
                            name: n.clone(),
                            file,
                            fields: fields.clone(),
                        });
                        let llvm_name = if g.structs.iter().filter(|s| s.name == *n).count() > 1 {
                            format!("{}__{}", f.module.replace('.', "__"), n)
                        } else {
                            n.clone()
                        };
                        g.struct_types.push(g.l.typ(5, 0, &[], &llvm_name)?);
                    }
                    Decl::Alias(n, t, _) => {
                        g.aliases.insert((file, n.clone()), t.clone());
                    }
                    Decl::Enum(n, variants, _) => {
                        g.aliases.insert((file, n.clone()), Ty::I32);
                        for (v, num) in variants {
                            g.enums.insert((file, v.clone()), *num);
                            g.enums.insert((file, format!("{n}.{v}")), *num);
                        }
                    }
                    _ => {}
                }
            }
        }
        for (file, name) in g.aliases.keys() {
            g.resolve(*file, &Ty::Named(name.clone()))?;
        }
        for i in 0..g.structs.len() {
            let file = g.structs[i].file;
            let fields = g.structs[i]
                .fields
                .clone()
                .into_iter()
                .map(|(n, t)| Ok((n, g.resolve(file, &t)?)))
                .collect::<R<Vec<_>>>()?;
            g.structs[i].fields = fields;
        }
        let mut sized = BTreeSet::new();
        for i in 0..g.structs.len() {
            g.check_struct_size(i, &mut BTreeSet::new(), &mut sized)?;
        }
        for i in 0..g.structs.len() {
            let fields = g.structs[i]
                .fields
                .iter()
                .map(|(_, t)| g.lt(t))
                .collect::<R<Vec<_>>>()?;
            g.l.body(g.struct_types[i], &fields)?;
        }
        for (file, f) in project.files.iter().enumerate() {
            for d in &f.declarations {
                if let Decl::Function(fun) = d {
                    if fun.intrinsic
                        && !f.module.starts_with("std.")
                        && !(f.module == "c.llvm" && fun.name == "vec_data_i64")
                    {
                        return Err("intrinsic functions are only allowed in std modules".into());
                    }
                    let ret = if fun.name == "main" {
                        Ty::I32
                    } else {
                        g.resolve(file, &fun.ret)?
                    };
                    let params = fun
                        .params
                        .iter()
                        .map(|(_, t)| g.resolve(file, t))
                        .collect::<R<Vec<_>>>()?;
                    let mut types = vec![g.lt(&ret)?];
                    for t in &params {
                        types.push(g.lt(t)?);
                    }
                    let ft = g.l.typ(7, u64::from(fun.variadic), &types, "")?;
                    let link = if !fun.link.is_empty() {
                        fun.link.clone()
                    } else if fun.external || fun.name == "main" {
                        fun.name.clone()
                    } else {
                        format!("{}__{}", f.module.replace(['.', '/', '-'], "__"), fun.name)
                    };
                    let value = g.l.func(&link, ft)?;
                    let index = g.funcs.len();
                    g.names.insert((file, fun.name.clone()), index);
                    g.funcs.push(Func {
                        file,
                        ast: fun.clone(),
                        ret,
                        params,
                        ft,
                        value,
                    });
                }
            }
        }
        Ok(g)
    }
    fn resolve(&self, file: usize, t: &Ty) -> R<Ty> {
        self.resolve_type(file, t, &mut BTreeSet::new())
    }

    fn check_struct_size(
        &self,
        id: usize,
        visiting: &mut BTreeSet<usize>,
        sized: &mut BTreeSet<usize>,
    ) -> R<()> {
        if sized.contains(&id) {
            return Ok(());
        }
        if !visiting.insert(id) {
            return Err(format!("recursive value type: {}", self.structs[id].name));
        }
        for (_, t) in &self.structs[id].fields {
            if let Ty::Struct(child) = t {
                self.check_struct_size(*child, visiting, sized)?;
            }
        }
        visiting.remove(&id);
        sized.insert(id);
        Ok(())
    }

    fn type_in(&self, file: usize, name: &str, public: bool) -> Option<(usize, Ty)> {
        let module = &self.project.files[file].module;
        for (owner, source) in self.project.files.iter().enumerate() {
            if source.module != *module {
                continue;
            }
            for declaration in &source.declarations {
                let (n, exported) = match declaration {
                    Decl::Struct(n, _, exported)
                    | Decl::Alias(n, _, exported)
                    | Decl::Enum(n, _, exported) => (n, exported),
                    _ => continue,
                };
                if n != name || (public && !exported) {
                    continue;
                }
                let t = if let Some(alias) = self.aliases.get(&(owner, name.to_owned())) {
                    alias.clone()
                } else {
                    Ty::Struct(
                        self.structs
                            .iter()
                            .position(|s| s.file == owner && s.name == name)?,
                    )
                };
                return Some((owner, t));
            }
        }
        None
    }

    fn resolve_type(&self, file: usize, t: &Ty, visiting: &mut BTreeSet<(usize, String)>) -> R<Ty> {
        Ok(match t {
            Ty::Named(name) => {
                let target = if let Some((alias, name)) = name.split_once('.') {
                    self.project.imports[file]
                        .get(alias)
                        .and_then(|&dep| self.type_in(dep, name, true))
                } else if let Some(target) = self.type_in(file, name, false) {
                    Some(target)
                } else {
                    let targets = self.project.imports[file]
                        .values()
                        .filter_map(|&dep| self.type_in(dep, name, true))
                        .collect::<BTreeSet<_>>();
                    if targets.len() > 1 {
                        return Err(format!("ambiguous type: {name}"));
                    }
                    targets.into_iter().next()
                };
                let (owner, target) = target.ok_or_else(|| format!("unknown type: {name}"))?;
                let key = (owner, name.clone());
                if !visiting.insert(key.clone()) {
                    return Err(format!("cyclic type alias: {name}"));
                }
                let result = self.resolve_type(owner, &target, visiting)?;
                visiting.remove(&key);
                result
            }
            Ty::Ptr(t) => Ty::Ptr(Box::new(self.resolve_type(file, t, visiting)?)),
            Ty::Slice(t) => Ty::Slice(Box::new(self.resolve_type(file, t, visiting)?)),
            Ty::Vec(t) => Ty::Vec(Box::new(self.resolve_type(file, t, visiting)?)),
            Ty::Map(k, v) => Ty::Map(
                Box::new(self.resolve_type(file, k, visiting)?),
                Box::new(self.resolve_type(file, v, visiting)?),
            ),
            t => t.clone(),
        })
    }
}
