use crate::ast::{Error, Result, Span};
use std::path::Path;
#[derive(Clone, Debug)]
pub struct Token {
    pub text: String,
    pub span: Span,
    pub kind: u8,
} // 0 syntax/identifier, 1 int, 2 real, 3 string, 4 char, 5 raw
pub fn lex(path: &Path, source: &str) -> Result<Vec<Token>> {
    let b = source.as_bytes();
    let (mut i, mut line, mut col) = (0, 1, 1);
    let mut out = Vec::new();
    let advance = |i: &mut usize, line: &mut usize, col: &mut usize| {
        if b[*i] == b'\n' {
            *line += 1;
            *col = 1;
        } else {
            *col += 1;
        }
        *i += 1;
    };
    while i < b.len() {
        let start = i;
        let span = Span { line, col };
        let mut kind = 0;
        let err = |m: &str| Error {
            file: path.into(),
            span,
            message: m.into(),
        };
        if b[i] == b' ' || b[i] == b'\t' || b[i] == b'\r' {
            advance(&mut i, &mut line, &mut col);
            continue;
        }
        if b[i..].starts_with(b"//") {
            while i < b.len() && b[i] != b'\n' {
                advance(&mut i, &mut line, &mut col);
            }
            continue;
        }
        if b[i..].starts_with(b"/*") {
            let mut depth = 1;
            advance(&mut i, &mut line, &mut col);
            advance(&mut i, &mut line, &mut col);
            while i < b.len() && depth > 0 {
                if b[i..].starts_with(b"/*") {
                    depth += 1;
                    advance(&mut i, &mut line, &mut col);
                    advance(&mut i, &mut line, &mut col);
                } else if b[i..].starts_with(b"*/") {
                    depth -= 1;
                    advance(&mut i, &mut line, &mut col);
                    advance(&mut i, &mut line, &mut col);
                } else {
                    advance(&mut i, &mut line, &mut col);
                }
            }
            if depth != 0 {
                return Err(err("unclosed block comment"));
            }
            continue;
        }
        if b[i].is_ascii_alphabetic() || b[i] == b'_' {
            while i < b.len() && (b[i].is_ascii_alphanumeric() || b[i] == b'_') {
                advance(&mut i, &mut line, &mut col);
            }
        } else if b[i].is_ascii_digit() {
            kind = 1;
            let radix_literal = b[i] == b'0' && matches!(b.get(i + 1), Some(b'x' | b'b'));
            while i < b.len()
                && (b[i].is_ascii_digit()
                    || b[i] == b'_'
                    || (radix_literal && b[i].is_ascii_alphabetic()))
            {
                advance(&mut i, &mut line, &mut col);
            }
            if !radix_literal
                && i < b.len()
                && b[i] == b'.'
                && b.get(i + 1).is_some_and(u8::is_ascii_digit)
            {
                kind = 2;
                advance(&mut i, &mut line, &mut col);
                while i < b.len() && b[i].is_ascii_digit() {
                    advance(&mut i, &mut line, &mut col);
                }
            }
            if !radix_literal && i < b.len() && (b[i] == b'e' || b[i] == b'E') {
                kind = 2;
                advance(&mut i, &mut line, &mut col);
                if i < b.len() && (b[i] == b'+' || b[i] == b'-') {
                    advance(&mut i, &mut line, &mut col);
                }
                if !b.get(i).is_some_and(u8::is_ascii_digit) {
                    return Err(err("expected digits in float exponent"));
                }
                while i < b.len() && b[i].is_ascii_digit() {
                    advance(&mut i, &mut line, &mut col);
                }
            }
        } else if b[i] == b'"' || b[i] == b'\'' || b[i] == b'`' {
            let q = b[i];
            kind = if q == b'\'' {
                4
            } else if q == b'`' {
                5
            } else {
                3
            };
            advance(&mut i, &mut line, &mut col);
            let mut closed = false;
            while i < b.len() {
                if b[i] == q {
                    advance(&mut i, &mut line, &mut col);
                    closed = true;
                    break;
                }
                if b[i] == b'\n' && q != b'`' {
                    break;
                }
                if b[i] == b'\\' && q != b'`' {
                    advance(&mut i, &mut line, &mut col);
                    if i >= b.len() {
                        break;
                    }
                }
                advance(&mut i, &mut line, &mut col);
            }
            if !closed {
                return Err(err(if q == b'\'' {
                    "unterminated/invalid char literal"
                } else {
                    "unterminated string literal"
                }));
            }
            if q == b'\'' && decode(&source[start..i], false).len() != 1 {
                return Err(err("unterminated/invalid char literal"));
            }
        } else {
            let len = [
                "...", ":=", "==", "!=", "<=", ">=", "&&", "||", "<<", ">>", "+=", "-=", "*=",
                "/=", "%=", "++", "--", "->", "<-",
            ]
            .iter()
            .find(|s| b[i..].starts_with(s.as_bytes()))
            .map_or(1, |s| s.len());
            for _ in 0..len {
                advance(&mut i, &mut line, &mut col);
            }
        }
        let text = source
            .get(start..i)
            .ok_or_else(|| err("unexpected non-ASCII character outside a string"))?
            .to_owned();
        out.push(Token { text, span, kind });
    }
    out.push(Token {
        text: String::new(),
        span: Span { line, col },
        kind: 0,
    });
    Ok(out)
}
pub fn decode(s: &str, raw: bool) -> String {
    let b = &s.as_bytes()[1..s.len() - 1];
    if raw {
        return String::from_utf8_lossy(b).into_owned();
    }
    let mut v = Vec::new();
    let mut i = 0;
    while i < b.len() {
        if b[i] == b'\\' && i + 1 < b.len() {
            i += 1;
            v.push(match b[i] {
                b'n' => 10,
                b'r' => 13,
                b't' => 9,
                b'0' => 0,
                x => x,
            });
        } else {
            v.push(b[i]);
        }
        i += 1;
    }
    String::from_utf8_lossy(&v).into_owned()
}
