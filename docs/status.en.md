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
├─ std: fmt, array, mem, str, math, io, fs, os, text, json, map
└─ tooling: examples, YCPL LSP v0.4, C++ bootstrap ycc
```

## Experimental

```text
experimental
├─ ycc-ycpl lexer/parser self-hosting compiler
├─ ycc-ycpl checker, LLVM IR emitter, and native build for tiny i32 subset
├─ ycc-ycpl build/build-ir stage driver through bootstrap ycc
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

## Self-Hosting Track

```text
self-hosting
├─ bootstrap/cpp
│  ├─ current C++ compiler
│  └─ still owns codegen and native builds
└─ compiler/ycpl
   ├─ source/diag/lexer/parser/cli modules
   ├─ ycc-ycpl lex <file.yc>
   ├─ ycc-ycpl parse <file.yc>
   ├─ ycc-ycpl check examples/53_self_codegen_main.yc
   ├─ ycc-ycpl build-ir-self examples/53_self_codegen_main.yc -o <out>
   ├─ ycc-ycpl build examples/54_self_codegen_arithmetic.yc -o <out>
   ├─ ycc-ycpl parse compiler/ycpl
   ├─ ycc-ycpl check compiler/ycpl
   ├─ YCPL_NO_BOOTSTRAP=1 ycc-ycpl build-ir compiler/ycpl -o <out>
   ├─ YCPL_NO_BOOTSTRAP=1 ycc-ycpl build compiler/ycpl -o <out>
   ├─ ycc-ycpl build compiler/ycpl -o <out>
   └─ unsupported inputs still delegate to bootstrap ycc
```

```text
stage-2 self-host gate
├─ compiler/ycpl has a fixed project source list in resolver
├─ project parse/check emits AST-derived counts and digest
├─ YCPL_NO_BOOTSTRAP=1 project build-ir emits valid LLVM IR
├─ YCPL_NO_BOOTSTRAP=1 project build emits a native AST smoke binary
└─ compiler-equivalent native ycc-ycpl is still the next implementation step
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
