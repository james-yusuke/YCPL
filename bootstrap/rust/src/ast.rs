use std::path::PathBuf;
pub type E = usize;
pub type S = usize;
#[derive(Clone, Copy, Debug, Default)]
pub struct Span {
    pub line: usize,
    pub col: usize,
}
#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum Ty {
    Void,
    Bool,
    Byte,
    Char,
    I32,
    I64,
    F32,
    F64,
    String,
    Any,
    Meta,
    Generic,
    None,
    Named(String),
    Struct(usize),
    Ptr(Box<Ty>),
    Slice(Box<Ty>),
    Vec(Box<Ty>),
    Map(Box<Ty>, Box<Ty>),
}
impl Ty {
    pub fn named(s: &str) -> Self {
        match s {
            "void" => Self::Void,
            "bool" => Self::Bool,
            "byte" | "i8" => Self::Byte,
            "char" => Self::Char,
            "i32" => Self::I32,
            "i64" | "size_t" => Self::I64,
            "float" | "f32" => Self::F32,
            "double" | "f64" => Self::F64,
            "string" => Self::String,
            "any" => Self::Any,
            "Type" => Self::Meta,
            "T" => Self::Generic,
            _ => Self::Named(s.into()),
        }
    }
    pub fn pointer(&self) -> bool {
        matches!(
            self,
            Self::Ptr(_)
                | Self::String
                | Self::Slice(_)
                | Self::Vec(_)
                | Self::Map(..)
                | Self::Any
                | Self::None
        )
    }
    pub fn integer(&self) -> bool {
        self.bits() > 0
    }
    pub fn bits(&self) -> u64 {
        match self {
            Self::Bool => 1,
            Self::Byte | Self::Char => 8,
            Self::I32 => 32,
            Self::I64 => 64,
            _ => 0,
        }
    }
    pub fn float(&self) -> bool {
        matches!(self, Self::F32 | Self::F64)
    }
    pub fn element(&self) -> Option<Ty> {
        match self {
            Self::Ptr(t) | Self::Slice(t) | Self::Vec(t) => Some(*t.clone()),
            Self::String => Some(Self::Char),
            _ => None,
        }
    }
}
#[derive(Clone, Debug)]
pub enum ExprKind {
    Int(u64),
    Real(f64),
    Str(String),
    Char(u8),
    Bool(bool),
    None,
    Id(String),
    Type(Ty),
    Unary(String, E),
    Binary(String, E, E),
    Call(E, Vec<E>),
    Member(E, String),
    Index(E, E),
    Post(String, E),
    Array(Vec<E>, Option<Ty>),
    Struct(Ty, Vec<(String, E)>),
    Vec(Ty, Option<E>),
}
#[derive(Clone, Debug)]
pub struct Expr {
    pub kind: ExprKind,
    pub span: Span,
}
#[derive(Clone, Debug)]
pub enum StmtKind {
    Block(Vec<S>, bool),
    Let(String, Option<Ty>, E, bool),
    Assign(E, String, E),
    Expr(E),
    Return(Option<E>),
    If(E, S, Option<S>),
    For(Option<S>, Option<E>, Option<E>, S),
    ForIn(String, E, S),
    Switch(E, Vec<(Option<E>, S)>),
    Break,
    Continue,
    Defer(S),
}
#[derive(Clone, Debug)]
pub struct Stmt {
    pub kind: StmtKind,
    pub span: Span,
}
#[derive(Clone, Debug)]
pub struct Function {
    pub name: String,
    pub params: Vec<(String, Ty)>,
    pub ret: Ty,
    pub body: Option<S>,
    pub public: bool,
    pub external: bool,
    pub intrinsic: bool,
    pub variadic: bool,
    pub link: String,
    pub span: Span,
}
#[derive(Clone, Debug)]
pub enum Decl {
    Function(Function),
    Struct(String, Vec<(String, Ty)>, bool),
    Alias(String, Ty, bool),
    Enum(String, Vec<(String, i64)>, bool),
}
#[derive(Clone, Debug, Default)]
pub struct File {
    pub path: PathBuf,
    pub module: String,
    pub imports: Vec<(String, String)>,
    pub declarations: Vec<Decl>,
    pub exprs: Vec<Expr>,
    pub stmts: Vec<Stmt>,
}
#[derive(Clone, Debug)]
pub struct Error {
    pub file: PathBuf,
    pub span: Span,
    pub message: String,
}
impl std::fmt::Display for Error {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{}:{}:{}: {}",
            self.file.display(),
            self.span.line,
            self.span.col,
            self.message
        )
    }
}
impl std::error::Error for Error {}
pub type Result<T> = std::result::Result<T, Error>;
