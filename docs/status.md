# Implementation Status

This page separates stable syntax from reserved or experimental syntax.

## Stable Enough for Examples

- `.ec` source files
- `module` and `package` declarations
- `import "path" as alias`
- `import "path"` with implicit last-segment alias
- Alias-qualified calls such as `fmt.println(...)`
- `pub fn`, `fn`, parameters, return types
- Bodyless `extern fn ... as "c_symbol"` declarations
- `struct`, struct literals, field access
- `i32`, `i64`, `bool`, `char`, `byte`, `string`, `float`, `double`
- `*T` pointers, `[]T` runtime slices, and nested slices such as `[][]i32`
- `:=`, `name: Type := value`, `=`, `+=`, `-=`, `*=`, `/=`, and `%=`
- `const` binding immutability and explicit `mut`
- `none` as a pointer/string null literal
- `if`, `else`, `else if`
- Short-circuit `&&` and `||`
- C-style `for`
- `for name in integer`
- `for name in string`
- `for name in []T` array value iteration
- `break`, `continue`
- Integer, float, string, raw string, char, bool, array, and byte-array literals
- `std/fmt`, `std/array`, `std/mem`, `std/str`, `std/math`, `std/io`,
  `std/fs`, `std/text`, `std/json`, and `std/map` as bundled YCPL source
  modules under `stl/std`
- YCPL-authored LSP v0.4 native server under `tools/lsp`
  - JSON-RPC `Content-Length` frame parsing
  - fixed-capacity full-text document store
  - diagnostics for unclosed comments, strings, braces, and direct imported
    std calls
  - initialize, shutdown, hover, snippet-aware completion, documentSymbol,
    semantic tokens, formatting, range formatting, folding ranges, signature
    help, definition/declaration, type definition, references, document
    highlight, prepareRename, rename, selection range, and workspace symbol
    responses
- Legacy global `println`, `printf`, `len`, `append`

## Experimental

- `intrinsic fn` declarations for bundled `std` modules only
- `sprintf`
- `cast`
- `new([]T)`
- Variadic user-defined functions
- Pointer-heavy expressions
- Nested/inline structs
- Runtime slice return values from user-defined YCPL functions
- Broad C/Unix FFI beyond documented `extern fn` declarations
- Fully pure standard library implementation without compiler/runtime
  intrinsics

## Reserved But Not Implemented

These tokens are reserved so future syntax cannot collide with user identifiers:

```text
enum interface match is go defer select switch or type importas
```

Notes:

- Imported direct calls are intentionally rejected in v1. Use
  `alias.symbol(...)`.
- `none` is a null literal, not an optional type.
- `match`, `select`, and `switch` have no parser/codegen support yet.
- `enum` and `interface` have no parser/codegen support yet.
- Optional types such as `T?` are not implemented.
- `intrinsic` is reserved for the bundled standard library bridge and is
  rejected in normal user modules.
- `std/json` currently provides a tagged `JsonValue` view API and JSON-RPC
  helpers. It does not yet provide mutable object/array builders.
- The LSP v0.4 navigation features scan currently open YCPL documents.
  Unopened-file indexing, import-graph indexing, type-aware rename, and full
  project semantic analysis are not implemented yet.
