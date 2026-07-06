# YCPL Language Syntax

[Japanese](language.ja.md) | [Docs index](README.en.md)

Formal grammar: [YCPL EBNF](grammar/ycpl.ebnf)

```text
.yc file
├─ optional module/package declaration
├─ imports
├─ functions, structs, externs, intrinsics
└─ fn main() entry
```

## Source Files

| Rule | Current support |
|---|---|
| Extension | `.yc` |
| Statement separator | newline |
| Comments | `// line`, nested `/* block */` |
| Top-level runtime code | rejected by codegen |

```text
fn main() { ... }       -> runtime code allowed
top-level statement     -> rejected by codegen
```

## Identifiers And Keywords

Identifiers start with a letter or `_`, followed by letters, digits, or `_`.

```text
module package import pub extern intrinsic fn struct const
if else for in return break continue as
true false none byte
```

Reserved tokens such as `enum`, `switch`, and `type` are intentionally not part of
the supported grammar yet. They are documented in
[Implementation status](status.en.md#reserved-but-not-implemented).

## Modules And Imports

```text
module math.basic
    |
    v
pub fn square
    |
    v
import "math/basic" as math
    |
    v
math.square(5)
```

```YCPL
module math.basic

pub fn square(x i32) i32 {
    return x * x
}
```

```YCPL
import "math/basic" as math

fn main() {
    result := math.square(5)
}
```

Imported functions must be called through their alias. Same-module functions
may be called directly. `pub fn` and `pub struct` are exported.

## Functions

```text
fn name(param Type, other Type) ReturnType {
    statements
}
```

```YCPL
pub fn add(a i32, b i32) i32 {
    return a + b
}

extern fn c_strlen(s string) i64 as "strlen"
```

`intrinsic fn` is accepted only inside bundled `std` modules.

## Types

```text
Types
├─ primitive: i32 i64 bool char byte string float double void size_t
├─ pointer:   *T
├─ slice:     []T
└─ nested:    [][]T
```

Runtime slices use `{ data, len, cap, elem_size }` and are manually managed
when created by `std/array`.

## Variables And Literals

```text
name := value          inferred mutable binding
name: Type := value    explicit mutable binding
const name := value    immutable binding
name = value           assignment to existing binding
```

```YCPL
count := 10
name: string := "YCPL"
const label: string := "stable"
```

Supported literals include integers, floats, chars, strings, raw strings,
booleans, `none`, arrays, and byte arrays.

## Operators And Control Flow

```text
high precedence
  call, index, member, ++, --
  !, -, +, ++, --, *, &
  *, /, %, +, -, shifts, comparisons, ==, !=
  &&, ||
low precedence
```

```YCPL
if score >= 80 {
    println("pass")
} else {
    println("retry")
}

for i := 0; i < 10; i++ {
    println(i)
}

for value in xs {
    println(value)
}
```
