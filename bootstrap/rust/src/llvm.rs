//! Safe, typed handles scoped at runtime to their owning C++ LLVM session.
use crate::bridge::ffi;
use std::{cell::RefCell, collections::BTreeMap};
#[derive(Clone, Copy, Debug)]
pub struct Type(pub(crate) u64);
#[derive(Clone, Copy, Debug)]
pub struct Value(pub(crate) u64);
#[derive(Clone, Copy, Debug)]
pub struct Block(pub(crate) u64);
pub struct Llvm {
    pub(crate) session: RefCell<cxx::UniquePtr<ffi::Session>>,
    types: RefCell<BTreeMap<String, Type>>,
}
pub type R<T> = std::result::Result<T, String>;
impl Llvm {
    pub fn new() -> R<Self> {
        Ok(Self {
            session: RefCell::new(ffi::new_session("yc").map_err(|e| e.to_string())?),
            types: RefCell::new(BTreeMap::new()),
        })
    }
    pub fn typ(&self, kind: u8, n: u64, args: &[Type], name: &str) -> R<Type> {
        let key = format!("{kind}:{n}:{args:?}:{name}");
        if let Some(&t) = self.types.borrow().get(&key) {
            return Ok(t);
        }
        let t = Type(
            self.session
                .borrow_mut()
                .pin_mut()
                .type_create(kind, n, &args.iter().map(|t| t.0).collect::<Vec<_>>(), name)
                .map_err(|e| e.to_string())?,
        );
        self.types.borrow_mut().insert(key, t);
        Ok(t)
    }
    pub fn body(&self, t: Type, fields: &[Type]) -> R<()> {
        self.session
            .borrow_mut()
            .pin_mut()
            .type_body(t.0, &fields.iter().map(|t| t.0).collect::<Vec<_>>())
            .map_err(|e| e.to_string())
    }
    pub fn size(&self, t: Type) -> R<u64> {
        self.session
            .borrow()
            .type_size(t.0)
            .map_err(|e| e.to_string())
    }
    pub fn constant(&self, kind: u8, t: Type, bits: u64, real: f64, text: &str) -> R<Value> {
        self.session
            .borrow_mut()
            .pin_mut()
            .constant(kind, t.0, bits, real, text)
            .map(Value)
            .map_err(|e| e.to_string())
    }
    pub fn func(&self, name: &str, t: Type) -> R<Value> {
        self.session
            .borrow_mut()
            .pin_mut()
            .function(name, t.0)
            .map(Value)
            .map_err(|e| e.to_string())
    }
    pub fn param(&self, f: Value, i: u32) -> R<Value> {
        self.session
            .borrow_mut()
            .pin_mut()
            .parameter(f.0, i)
            .map(Value)
            .map_err(|e| e.to_string())
    }
    pub fn block(&self, f: Value, name: &str) -> R<Block> {
        self.session
            .borrow_mut()
            .pin_mut()
            .block(f.0, name)
            .map(Block)
            .map_err(|e| e.to_string())
    }
    pub fn position(&self, b: Block) -> R<()> {
        self.session
            .borrow_mut()
            .pin_mut()
            .position(b.0)
            .map_err(|e| e.to_string())
    }
    pub fn terminated(&self) -> bool {
        self.session.borrow().terminated()
    }
    pub fn op(&self, op: &str, t: Option<Type>, args: &[u64], name: &str, aux: u64) -> R<Value> {
        self.session
            .borrow_mut()
            .pin_mut()
            .instruction(op, t.map_or(0, |t| t.0), args, name, aux)
            .map(Value)
            .map_err(|e| e.to_string())
    }
    pub fn ir(&self) -> R<String> {
        self.session.borrow().ir().map_err(|e| e.to_string())
    }
}
