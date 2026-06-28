# YCPL Language Syntax

This page defines the YCPL syntax supported by the current compiler.

## Source Files

- Source files use the `.ec` extension.
- Statements are separated by newlines.
- Semicolons are required inside C-style `for` clauses only.
- `// line comments` and nested `/* block comments */` are supported.
- Top-level executable statements are rejected by code generation. Put runtime
  code inside `fn main()`.

## Identifiers and Keywords

Identifiers start with a letter or `_`, followed by letters, digits, or `_`.

Reserved keywords:

```text
module package import pub extern intrinsic fn struct enum interface const mut
if else match for in return break continue as is go defer select switch
true false none or type importas byte
```

Some keywords are reserved before they are implemented. See
[Implementation Status](status.md).

## Modules and Imports

A source file may start with a module/package declaration:

```YCPL
module math.basic
```

`package` is accepted as an alias of `module`.

Imports use a string path relative to a configured source directory:

```YCPL
import "math/basic" as math
```

`import "path" as alias` is the v1 module form. Imported declarations must be
called through the alias:

```YCPL
result := math.square(5)
```

`import "path"` is also accepted. Without `as`, the alias is the last path
segment:

```YCPL
import "std/fmt"

fn main() {
    fmt.println("hello")
}
```

Rules:

- Same-module functions may be called directly.
- Imported functions must be called as `alias.symbol(...)`.
- `pub fn` and `pub struct` are visible to importing modules.
- Non-`pub` module declarations are private.
- Imported direct calls such as `square(5)` are rejected when `square` comes
  from another module.
- LLVM symbols are module-mangled as `module__name`; `main` stays `main`.

## Functions

Function syntax:

```YCPL
fn name(param Type, other Type) ReturnType {
    return expression
}
```

Rules:

- Parameters are written as `name Type`.
- Return type is written after `)`, with no `->`.
- Omit the return type for `void` functions.
- `pub fn` exports a function from a module.
- `fn main()` is the program entry point.
- `extern fn` declares a bodyless external function. Use `as "symbol"` when
  the YCPL name differs from the linked C/LLVM symbol.
- `intrinsic fn` is accepted only in bundled `std` modules and is rejected in
  normal user modules.

Example:

```YCPL
pub fn add(a i32, b i32) i32 {
    return a + b
}
```

External declaration example:

```YCPL
extern fn c_strlen(s string) i64 as "strlen"

pub fn len(s string) i64 {
    return c_strlen(s)
}
```

Standard library intrinsic declaration example:

```YCPL
module std.fmt

pub intrinsic fn println(value... any)
```

## Types

Currently supported type names:

```text
i32 i64 bool char byte string float double void size_t
```

Composite types:

```YCPL
*i32       // pointer to i32
[]i32      // runtime slice of i32 values
[]string   // runtime slice of strings
[][]i32    // runtime slice of []i32 slice values
```

`string` is represented as a C string pointer (`*i8`). `byte` and `char` are
8-bit integer values.

Runtime slices use the layout `{ data, len, cap, elem_size }`. Slice values
created by `std/array` are manually managed and must be released with
`array.free(xs)`.

## Variables

Use `:=` for a new variable with inferred type:

```YCPL
count := 10
```

Use `name: Type := value` for an explicit type:

```YCPL
enabled: bool := true
name: string := "YCPL"
```

Use `=` to assign an existing variable:

```YCPL
count = count + 1
```

Use compound assignment for numeric variables, array indices, and struct fields:

```YCPL
count += 1
xs[0] *= 2
point.x -= 3
```

Variables are mutable by default. `mut` is accepted as an explicit mutable
declaration:

```YCPL
mut name: string := "YCPL"
name = "YCPL v1.2"
```

`const` makes the binding immutable:

```YCPL
const label: string := "stable"
```

`const xs` prevents `xs = ...`, but it does not freeze memory reachable through
the slice or pointer.

## Literals

Supported literal forms:

```YCPL
123
0xff
0b1010
3.14
'A'
"hello\n"
`raw string`
true
false
none
```

`none` is a null literal for pointer and `string` values. It is valid for
pointer/string initialization, assignment, return, and equality comparison. It
is not a general optional value and cannot initialize integer or float values.

Byte arrays:

```YCPL
bytes := byte[65, 66, 67]
text := byte "ABC"
```

## Operators

Expression precedence, from high to low:

```text
postfix:       call(), index[], member., x++, x--
unary:         ! - + ++ -- * &
multiplicative * / %
additive       + -
shift          << >>
comparison     < > <= >=
equality       == !=
logical and    &&
logical or     ||
```

Supported assignment forms:

```YCPL
name := expression
name: Type := expression
target = expression
target += expression
target -= expression
target *= expression
target /= expression
target %= expression
```

## Control Flow

`if` and `else if`:

```YCPL
if score >= 80 {
    println("pass")
} else {
    println("retry")
}
```

C-style `for`:

```YCPL
for (i: i32 := 0; i < 10; i++) {
    println(i)
}
```

Range-style `for` over an integer:

```YCPL
for i in 5 {
    println(i) // 0 through 4
}
```

String iteration:

```YCPL
for ch in "abc" {
    println(ch)
}
```

Array value iteration:

```YCPL
import "std/array" as array

fn main() {
    xs := array.new([]i32, 2)
    xs = array.append(xs, 1)
    xs = array.append(xs, 2)

    total: i32 := 0
    for value in xs {
        total += value
    }

    array.free(xs)
}
```

`break` and `continue` are supported inside loops.

## Structs

Struct declaration:

```YCPL
struct Point {
    x i32
    y i32
}
```

Struct literal and member access:

```YCPL
p := Point{x: 3, y: 4}
println(p.x)
```

Use `pub struct` to export a struct from a module.

## Standard Library and Builtins

Prefer alias-qualified standard library imports:

```YCPL
import "std/fmt" as fmt
import "std/array" as array
import "std/mem" as mem
```

Stable v1.3 modules:

```text
std/fmt    print, println, printf
std/array  new, len, cap, append, get, set, free
std/mem    alloc, calloc, realloc, free, copy, set, sizeof
std/str    len, eq, cmp, copy
std/math   abs, pow, sin, cos, sqrt
std/io     read, write, write_str, read_stdin_all, send_lsp_body
std/fs     exists, read_file, uri_to_path
std/text   find, contains, starts_with, line/column helpers
std/json   tagged JsonValue parse/stringify/get helpers and JSON-RPC helpers
std/map    linear string map helpers for caller-owned arrays
```

These modules are resolved from bundled YCPL source files under `stl/std`.
Low-level runtime operations such as formatted printing, runtime slices, and
`mem.sizeof(Type)` are declared as private compiler/runtime intrinsics inside
the standard library source.

Array example:

```YCPL
import "std/array" as array
import "std/fmt" as fmt

fn main() {
    xs := array.new([]i32, 1)
    xs = array.append(xs, 10)
    xs = array.append(xs, 20)
    array.set(xs, 1, 30)
    fmt.println(array.get(xs, 1))
    array.free(xs)
}
```

Manual memory example:

```YCPL
import "std/mem" as mem

fn main() {
    size := mem.sizeof(i32)
    ptr := mem.alloc(size)
    mem.set(ptr, 0, size)
    mem.free(ptr)
}
```

Memory rules:

- YCPL v1 uses manual memory management.
- Values returned by `array.new` must be released with `array.free`.
- Values returned by `mem.alloc`, `mem.calloc`, or `mem.realloc` must be
  released with `mem.free`.
- `array.append` may grow storage and returns the updated slice. Always write
  `xs = array.append(xs, value)`.
- `array.get`, `array.set`, and index access perform bounds checks and abort on
  out-of-bounds access.
- Nested arrays are manually managed. Free each inner array, then free the outer
  array.
- Using an array after `array.free` is undefined behavior in v1.2; runtime
  tracking is not implemented.

Legacy global builtins still accepted by the compiler:

Stable builtins used by examples:

```YCPL
println(value)
printf(format, ...)
len(value)
append(array, value)
```

Experimental builtins:

```YCPL
sprintf(buffer, format, ...)
cast(Type, value)
new([]Type)
```

The compiler also predeclares several C/Unix FFI functions. Those declarations
are implementation details until documented examples cover them.
