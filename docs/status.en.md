# Implementation Status

[Japanese](status.ja.md) | [Docs index](README.en.md)

```text
Feature status
├─ stable enough for examples
├─ experimental
└─ reserved, not implemented
```

## Stable Enough For Examples

```text
stable
├─ source: yc extension, YCPL.json
├─ modules: module/package, import as alias, pub visibility
├─ functions: fn, extern fn, main
├─ data: structs, pointers, slices, none
├─ flow: if/else, for, for-in, break/continue
├─ std: fmt, array, mem, str, math, io, fs, text, json, map
└─ tooling: examples, YCPL LSP v0.4
```

## Experimental

```text
experimental
├─ intrinsic fn in bundled std
├─ sprintf
├─ cast
├─ new([]T)
├─ variadic user functions
├─ pointer-heavy expressions
├─ nested/inline structs
├─ runtime slice returns
└─ broad C/Unix FFI
```

## Reserved But Not Implemented

```text
enum interface match is go defer select switch or type importas
```

```text
reserved token
├─ prevents future syntax collision
└─ has no parser/codegen support yet
```

Notes: `none` is a null literal, not an optional type; imported direct calls are
rejected; LSP navigation currently scans open documents rather than a full
project index.
