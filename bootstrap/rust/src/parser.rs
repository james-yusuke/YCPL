use crate::{
    ast::*,
    lexer::{self, Token},
};
use std::path::Path;
pub fn parse(path: &Path, source: &str) -> Result<File> {
    let tokens = lexer::lex(path, source)?;
    let mut p = Parser {
        tokens,
        pos: 0,
        file: File {
            path: path.into(),
            ..File::default()
        },
    };
    p.program()?;
    Ok(p.file)
}
struct Parser {
    tokens: Vec<Token>,
    pos: usize,
    file: File,
}
impl Parser {
    fn at(&self) -> &str {
        &self.tokens[self.pos].text
    }
    fn span(&self) -> Span {
        self.tokens[self.pos].span
    }
    fn bump(&mut self) -> Token {
        let t = self.tokens[self.pos].clone();
        if self.pos + 1 < self.tokens.len() {
            self.pos += 1;
        }
        t
    }
    fn is(&self, s: &str) -> bool {
        self.at() == s
    }
    fn take(&mut self, s: &str) -> bool {
        if self.is(s) {
            self.bump();
            true
        } else {
            false
        }
    }
    fn err<T>(&self, s: impl Into<String>) -> Result<T> {
        Err(Error {
            file: self.file.path.clone(),
            span: self.span(),
            message: s.into(),
        })
    }
    fn expect(&mut self, s: &str, msg: &str) -> Result<()> {
        if self.take(s) { Ok(()) } else { self.err(msg) }
    }
    fn lines(&mut self) {
        while self.take("\n") || self.take(";") {}
    }
    fn ident(&mut self, msg: &str) -> Result<String> {
        if self
            .at()
            .as_bytes()
            .first()
            .is_some_and(|x| x.is_ascii_alphabetic() || *x == b'_')
        {
            Ok(self.bump().text)
        } else {
            self.err(msg)
        }
    }
    fn gt(&mut self) -> Result<()> {
        if self.take(">") {
            Ok(())
        } else if self.is(">>") {
            self.tokens[self.pos].text = ">".into();
            Ok(())
        } else {
            self.err("expected '>' after parameterized type")
        }
    }
    fn typ(&mut self) -> Result<Ty> {
        self.take("owned");
        if self.take("*") || self.take("&") {
            return Ok(Ty::Ptr(Box::new(self.typ()?)));
        }
        if self.take("[") {
            self.expect("]", "expected ']' in slice type")?;
            return Ok(Ty::Slice(Box::new(self.typ()?)));
        }
        let mut n = self.ident("expected type name")?;
        while self.take(".") {
            n.push('.');
            n.push_str(&self.ident("expected type name")?);
        }
        if self.take("<") {
            let t = self.typ()?;
            if n == "Vec" {
                self.gt()?;
                return Ok(Ty::Vec(Box::new(t)));
            }
            self.expect(",", "expected ',' in Map type")?;
            let v = self.typ()?;
            self.gt()?;
            return Ok(Ty::Map(Box::new(t), Box::new(v)));
        }
        Ok(Ty::named(&n))
    }
    fn e(&mut self, k: ExprKind, span: Span) -> E {
        let i = self.file.exprs.len();
        self.file.exprs.push(Expr { kind: k, span });
        i
    }
    fn s(&mut self, k: StmtKind, span: Span) -> S {
        let i = self.file.stmts.len();
        self.file.stmts.push(Stmt { kind: k, span });
        i
    }
    fn program(&mut self) -> Result<()> {
        self.lines();
        while !self.at().is_empty() {
            let span = self.span();
            let public = self.take("pub");
            if self.take("module") || self.take("package") {
                let mut n = self.ident("expected module/package name")?;
                while self.take(".") {
                    n.push('.');
                    n.push_str(&self.ident("expected module/package name")?);
                }
                self.file.module = n;
            } else if self.take("import") {
                let tok = self.bump();
                if tok.kind != 3 {
                    return self.err("expected import string");
                }
                let path = lexer::decode(&tok.text, false);
                let alias = if self.take("as") {
                    self.ident("expected alias after 'as'")?
                } else {
                    path.rsplit('/').next().unwrap_or("").into()
                };
                self.file.imports.push((path, alias));
            } else if self.take("struct") {
                let name = self.ident("expected struct name")?;
                self.expect("{", "expected '{' in struct")?;
                self.lines();
                let mut fields = Vec::new();
                while !self.is("}") {
                    if self.at().is_empty() {
                        return self.err("expected '}' to close struct");
                    }
                    self.take("pub");
                    let name = self.ident("expected field name")?;
                    self.take(":");
                    let t = self.typ()?;
                    fields.push((name, t));
                    self.take(",");
                    self.lines();
                }
                self.bump();
                self.file
                    .declarations
                    .push(Decl::Struct(name, fields, public));
            } else if self.take("enum") {
                let name = self.ident("expected enum name")?;
                self.expect("{", "expected '{' in enum")?;
                self.lines();
                let mut fields = Vec::new();
                let mut v = 0;
                while !self.is("}") {
                    let n = self.ident("expected enum variant")?;
                    if self.take("=") {
                        let neg = self.take("-");
                        let t = self.bump();
                        v = parse_int(&t.text).map_err(|m| Error {
                            file: self.file.path.clone(),
                            span: t.span,
                            message: m,
                        })? as i64;
                        if neg {
                            v = -v;
                        }
                    }
                    fields.push((n, v));
                    v = v.checked_add(1).ok_or_else(|| Error {
                        file: self.file.path.clone(),
                        span,
                        message: "enum value overflow".into(),
                    })?;
                    self.take(",");
                    self.lines();
                }
                self.bump();
                self.file
                    .declarations
                    .push(Decl::Enum(name, fields, public));
            } else if self.take("type") {
                let n = self.ident("expected alias name")?;
                self.take("=");
                let t = self.typ()?;
                self.file.declarations.push(Decl::Alias(n, t, public));
            } else {
                let external = self.take("extern");
                let intrinsic = self.take("intrinsic");
                self.expect("fn", "expected function declaration")?;
                let name = self.ident("expected function or method name")?;
                self.expect("(", "expected '(' after function name")?;
                let mut params = Vec::new();
                let mut variadic = false;
                while !self.is(")") {
                    self.lines();
                    let n = self.ident("expected parameter name")?;
                    self.take(":");
                    let pre = self.take("...");
                    let t = self.typ()?;
                    let post = self.take("...");
                    if pre || post {
                        variadic = true;
                    } else {
                        params.push((n, t));
                    }
                    if !self.take(",") {
                        break;
                    }
                }
                self.expect(")", "expected ')' after parameters")?;
                let ret = if !matches!(self.at(), "{" | "\n" | "" | "as" | ";") {
                    self.typ()?
                } else {
                    Ty::Void
                };
                let link = if self.take("as") {
                    let t = self.bump();
                    if t.kind != 3 {
                        return self.err("expected external link name");
                    }
                    lexer::decode(&t.text, false)
                } else {
                    String::new()
                };
                let body = if self.is("{") {
                    Some(self.block(false)?)
                } else {
                    None
                };
                if external && body.is_some() {
                    return self.err("extern function cannot have a body");
                }
                self.file.declarations.push(Decl::Function(Function {
                    name,
                    params,
                    ret,
                    body,
                    public,
                    external,
                    intrinsic,
                    variadic,
                    link,
                    span,
                }));
            }
            self.lines();
        }
        Ok(())
    }
    fn block(&mut self, standalone: bool) -> Result<S> {
        let span = self.span();
        self.expect("{", "expected '{' to start block")?;
        self.lines();
        let mut v = Vec::new();
        while !self.is("}") {
            if self.at().is_empty() {
                return self.err("expected '}' to end block");
            }
            let before = self.pos;
            v.push(self.stmt()?);
            if before == self.pos {
                return self.err("parser made no progress");
            }
            self.lines();
        }
        self.bump();
        Ok(self.s(StmtKind::Block(v, standalone), span))
    }
    fn stmt(&mut self) -> Result<S> {
        self.lines();
        let span = self.span();
        if self.is("{") {
            return self.block(true);
        }
        if self.take("return") {
            let e = if matches!(self.at(), "\n" | ";" | "}" | "") {
                None
            } else {
                Some(self.expr(0)?)
            };
            return Ok(self.s(StmtKind::Return(e), span));
        }
        if self.take("break") {
            return Ok(self.s(StmtKind::Break, span));
        }
        if self.take("continue") {
            return Ok(self.s(StmtKind::Continue, span));
        }
        if self.take("defer") {
            let s = if self.is("{") {
                self.block(false)?
            } else {
                self.stmt()?
            };
            return Ok(self.s(StmtKind::Defer(s), span));
        }
        if self.take("if") {
            let c = self.expr(0)?;
            let yes = self.block(false)?;
            let save = self.pos;
            self.lines();
            let no = if self.take("else") {
                Some(if self.is("if") {
                    self.stmt()?
                } else {
                    self.block(false)?
                })
            } else {
                self.pos = save;
                None
            };
            return Ok(self.s(StmtKind::If(c, yes, no), span));
        }
        if self.take("switch") {
            let e = self.expr(0)?;
            self.expect("{", "expected '{' after switch")?;
            self.lines();
            let mut cases = Vec::new();
            while !self.is("}") {
                let v = if self.take("case") {
                    Some(self.expr(0)?)
                } else {
                    self.expect("default", "expected 'case' or 'default' in switch")?;
                    None
                };
                let b = self.block(false)?;
                cases.push((v, b));
                self.lines();
            }
            self.bump();
            return Ok(self.s(StmtKind::Switch(e, cases), span));
        }
        if self.take("for") {
            let paren = self.take("(");
            if !paren && self.is("{") {
                let b = self.block(false)?;
                return Ok(self.s(StmtKind::For(None, None, None, b), span));
            }
            if !paren
                && self
                    .tokens
                    .get(self.pos + 1)
                    .is_some_and(|t| t.text == "in")
            {
                let n = self.bump().text;
                self.bump();
                let e = self.expr(0)?;
                let b = self.block(false)?;
                return Ok(self.s(StmtKind::ForIn(n, e, b), span));
            }
            let mut init = None;
            let mut cond = None;
            let mut post = None;
            if !self.is(";") {
                let first = self.stmt_simple()?;
                if self.is(";") {
                    init = Some(first);
                } else if let StmtKind::Expr(e) = self.file.stmts[first].kind {
                    cond = Some(e);
                } else {
                    return self.err("expected ';' after for initializer");
                }
            }
            if self.take(";") {
                if !self.is(";") {
                    cond = Some(self.expr(0)?);
                }
                self.expect(";", "expected ';' in for")?;
                if !self.is(")") && !self.is("{") {
                    post = Some(self.expr(0)?);
                }
            }
            if paren {
                self.expect(")", "expected ')' after for")?;
            }
            let body = self.block(false)?;
            return Ok(self.s(StmtKind::For(init, cond, post, body), span));
        }
        if self.is("else") {
            return self.err("unexpected token in expression: misplaced else");
        }
        self.stmt_simple()
    }
    fn stmt_simple(&mut self) -> Result<S> {
        let span = self.span();
        let constant = self.take("const");
        let name = self.at().to_owned();
        if constant
            || self
                .tokens
                .get(self.pos + 1)
                .is_some_and(|t| t.text == ":" || t.text == ":=")
        {
            self.ident("expected variable name")?;
            let typ = if self.take(":") {
                Some(self.typ()?)
            } else {
                None
            };
            if !self.take(":=") && !self.take("=") {
                return self.err("expected ':=' after declaration");
            }
            let e = self.expr(0)?;
            return Ok(self.s(StmtKind::Let(name, typ, e, constant), span));
        }
        let e = self.expr(0)?;
        if matches!(self.at(), "=" | "+=" | "-=" | "*=" | "/=" | "%=") {
            let op = self.bump().text;
            let rhs = self.expr(0)?;
            return Ok(self.s(StmtKind::Assign(e, op, rhs), span));
        }
        Ok(self.s(StmtKind::Expr(e), span))
    }
    fn expr(&mut self, min: u8) -> Result<E> {
        let mut left = self.primary()?;
        loop {
            let op = self.at().to_owned();
            let prec = match op.as_str() {
                "||" => 1,
                "&&" => 2,
                "|" => 3,
                "^" => 4,
                "&" => 5,
                "==" | "!=" => 6,
                "<" | "<=" | ">" | ">=" => 7,
                "<<" | ">>" => 8,
                "+" | "-" => 9,
                "*" | "/" | "%" => 10,
                _ => 0,
            };
            if prec == 0 || prec < min {
                break;
            }
            let span = self.bump().span;
            let rhs = self.expr(prec + 1)?;
            left = self.e(ExprKind::Binary(op, left, rhs), span);
        }
        Ok(left)
    }
    fn primary(&mut self) -> Result<E> {
        let span = self.span();
        let tok = self.tokens[self.pos].clone();
        let mut e = if matches!(self.at(), "!" | "-" | "+" | "*" | "&" | "++" | "--" | "~") {
            let op = self.bump().text;
            let rhs = self.primary()?;
            self.e(ExprKind::Unary(op, rhs), span)
        } else if self.take("(") {
            let e = self.expr(0)?;
            self.expect(")", "expected ')' after expression")?;
            e
        } else if self.is("[") {
            self.bump();
            if self.take("]") {
                let elem = self.typ()?;
                let t = Ty::Slice(Box::new(elem));
                if self.take("{") {
                    let vals = self.elements("}")?;
                    self.e(ExprKind::Array(vals, Some(t)), span)
                } else {
                    self.e(ExprKind::Type(t), span)
                }
            } else {
                let vals = self.elements("]")?;
                self.e(ExprKind::Array(vals, None), span)
            }
        } else if tok.kind == 1 {
            self.bump();
            let n = parse_int(&tok.text).map_err(|message| Error {
                file: self.file.path.clone(),
                span,
                message,
            })?;
            self.e(ExprKind::Int(n), span)
        } else if tok.kind == 2 {
            self.bump();
            let n = tok.text.parse::<f64>().map_err(|_| Error {
                file: self.file.path.clone(),
                span,
                message: "invalid float".into(),
            })?;
            self.e(ExprKind::Real(n), span)
        } else if tok.kind == 3 || tok.kind == 5 {
            self.bump();
            self.e(ExprKind::Str(lexer::decode(&tok.text, tok.kind == 5)), span)
        } else if tok.kind == 4 {
            self.bump();
            self.e(
                ExprKind::Char(lexer::decode(&tok.text, false).as_bytes()[0]),
                span,
            )
        } else if self.take("true") {
            self.e(ExprKind::Bool(true), span)
        } else if self.take("false") {
            self.e(ExprKind::Bool(false), span)
        } else if self.take("none") {
            self.e(ExprKind::None, span)
        } else if self.is("Vec") && self.tokens.get(self.pos + 1).is_some_and(|t| t.text == "<") {
            let t = self.typ()?;
            self.expect("{", "expected '{' after Vec<T>")?;
            self.lines();
            let cap = if self.take("capacity") {
                self.expect(":", "expected ':' after capacity")?;
                Some(self.expr(0)?)
            } else {
                None
            };
            self.take(",");
            self.lines();
            self.expect("}", "expected '}' to close Vec literal")?;
            self.e(ExprKind::Vec(t, cap), span)
        } else if self
            .at()
            .as_bytes()
            .first()
            .is_some_and(|b| b.is_ascii_alphabetic() || *b == b'_')
        {
            let n = self.bump().text;
            self.e(ExprKind::Id(n), span)
        } else {
            return self.err("unexpected token in expression");
        };
        loop {
            if self.take("(") {
                let mut args = Vec::new();
                self.lines();
                let cname = if let ExprKind::Id(ref n) = self.file.exprs[e].kind {
                    n.clone()
                } else {
                    String::new()
                };
                if cname == "cast" && !self.is(")") {
                    let t = self.typ()?;
                    let a = self.e(ExprKind::Type(t), span);
                    args.push(a);
                    self.expect(",", "expected ',' in cast")?;
                }
                while !self.is(")") {
                    if self.is("}") || self.at().is_empty() {
                        return self.err("expected ')' in call");
                    }
                    args.push(self.expr(0)?);
                    self.lines();
                    if !self.take(",") {
                        break;
                    }
                    self.lines();
                }
                self.expect(")", "expected ')' in call")?;
                e = self.e(ExprKind::Call(e, args), span);
            } else if self.take("[") {
                let ix = self.expr(0)?;
                self.expect("]", "expected ']' after index")?;
                e = self.e(ExprKind::Index(e, ix), span);
            } else if self.take(".") {
                let m = self.ident("expected member name")?;
                e = self.e(ExprKind::Member(e, m), span);
            } else if self.is("++") || self.is("--") {
                let op = self.bump().text;
                e = self.e(ExprKind::Post(op, e), span);
            } else if self.is("{") && (self.struct_start() || self.empty_struct_start(e)) {
                let n = match &self.file.exprs[e].kind {
                    ExprKind::Id(n) => n.clone(),
                    _ => break,
                };
                self.bump();
                self.lines();
                let mut fields = Vec::new();
                while !self.is("}") {
                    let n = self.ident("expected field name in struct literal")?;
                    self.expect(":", "expected ':' in struct literal")?;
                    let v = self.expr(0)?;
                    fields.push((n, v));
                    if self.take(",") {
                        self.lines();
                    } else {
                        self.lines();
                        if !self.is("}") {
                            return self.err("expected '}' to close struct literal");
                        }
                    }
                }
                self.bump();
                e = self.e(ExprKind::Struct(Ty::named(&n), fields), span);
            } else {
                break;
            }
        }
        Ok(e)
    }
    fn struct_start(&self) -> bool {
        let mut i = self.pos + 1;
        while self.tokens.get(i).is_some_and(|t| t.text == "\n") {
            i += 1;
        }
        self.tokens.get(i + 1).is_some_and(|t| t.text == ":")
    }
    fn empty_struct_start(&self, e: E) -> bool {
        let ExprKind::Id(name) = &self.file.exprs[e].kind else {
            return false;
        };
        let mut i = self.pos + 1;
        while self.tokens.get(i).is_some_and(|t| t.text == "\n") {
            i += 1;
        }
        self.tokens.get(i).is_some_and(|t| t.text == "}")
            && self
                .file
                .declarations
                .iter()
                .any(|d| matches!(d, Decl::Struct(n, ..) if n == name))
    }
    fn elements(&mut self, end: &str) -> Result<Vec<E>> {
        self.lines();
        let mut v = Vec::new();
        while !self.is(end) {
            v.push(self.expr(0)?);
            self.lines();
            if !self.take(",") {
                break;
            }
            self.lines();
        }
        self.expect(end, "expected end of array literal")?;
        Ok(v)
    }
}
fn parse_int(s: &str) -> std::result::Result<u64, String> {
    let s = s.replace('_', "");
    if let Some(n) = s.strip_prefix("0x") {
        u64::from_str_radix(n, 16)
    } else if let Some(n) = s.strip_prefix("0b") {
        u64::from_str_radix(n, 2)
    } else {
        s.parse()
    }
    .map_err(|_| "integer literal out of range".into())
}
