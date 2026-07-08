# YCPL Language Syntax

[Japanese](language.ja.md) | [Docs index](README.en.md)

Formal grammar: [YCPL EBNF](grammar/ycpl.ebnf)

```text
.yc file
├─ optional module/package declaration
├─ imports
├─ functions, structs, enums, type aliases, externs, intrinsics
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
module package import pub extern intrinsic fn struct enum type const owned
if else for in switch case default return break continue defer scope as
true false none byte
```

`case` and `default` are labels inside `switch` bodies.

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
├─ map slice: []Map<string, T>
├─ owned:     owned T
├─ map:       Map<string, T>
├─ alias:     type Score = i32
├─ enum:      enum Color { Red, Green }
└─ nested:    [][]T
```

Runtime slices use `{ data, len, cap, elem_size }`. Values created by
`std/array`, `std/mem`, `std/bytes`, `std/json`, and `std2/map` are allocated
through the statically linked YCPL runtime. The old free helpers remain as
compatibility releases while precise destructors for arbitrary composite values
are completed.
In the bootstrap C++ compiler, `owned T` is accepted as an ownership-intent type
qualifier and currently has the same ABI as `T`.
`Map<string, T>` is accepted as a map-handle type. In the current bootstrap
ABI it lowers as an opaque pointer, while `std/map` and `std2/map` still expose
runtime-backed key/value arrays for storage.

```YCPL
enum Color {
    Red = 2,
    Green,
    Blue = 8,
}

type Score = i32
type Symbols = Map<string, i32>
```

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

switch color {
    case Color.Red {
        println("red")
    }
    case Green {
        println("green")
    }
    default {
        println("other")
    }
}
```

`switch` uses `switch expression { case expression { ... } default { ... } }`.
The self-host checker/codegen path currently leads with i32 selectors and
integer literal cases.

## defer, scope, and UFCS

The bootstrap C++ compiler supports `defer`. `defer expr` or `defer { ... }`
runs just before the current function exits, in LIFO order.

```YCPL
b: owned Bytes := bytes.from_string("YCPL")
defer b.free()
```

`scope name { ... }` is a named lexical scope for making temporary work regions
explicit.

When exactly one imported module exposes a matching public function,
`value.method(x)` is treated as `module.method(value, x)`. For example,
`b.free()` is sugar for `bytes.free(b)`.
