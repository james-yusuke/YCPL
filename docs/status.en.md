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
   ├─ nested source folders: src/ast, src/codegen, src/parser, ...
   ├─ ycc-ycpl lex <file.yc>
   ├─ ycc-ycpl parse <file.yc>
   ├─ ycc-ycpl check examples/53_self_codegen_main.yc
   ├─ ycc-ycpl build-ir-self examples/53_self_codegen_main.yc -o <out>
   ├─ ycc-ycpl build examples/54_self_codegen_arithmetic.yc -o <out>
   ├─ ycc-ycpl build examples/56_self_codegen_call_assignment.yc -o <out>
   ├─ ycc-ycpl parse compiler/ycpl
   ├─ ycc-ycpl check compiler/ycpl
   ├─ YCPL_NO_BOOTSTRAP=1 ycc-ycpl build-ir compiler/ycpl -o <out>
   ├─ YCPL_NO_BOOTSTRAP=1 ycc-ycpl build compiler/ycpl -o <out>
   ├─ generated stage2 binary parse/check/build-ir compiler/ycpl
   ├─ generated stage2 binary build compiler/ycpl -o <stage3-out>
   ├─ generated stage2 binary build examples/54_self_codegen_arithmetic.yc and renamed copies
   ├─ ycc-ycpl build compiler/ycpl -o <out>
   └─ unsupported inputs still delegate to bootstrap ycc
```

```text
stage-2 self-host gate
├─ compiler/ycpl source discovery traverses nested src/**/*.yc files
├─ resolver rejects unsafe project paths before shell-backed traversal
├─ project parse/check emits AST-derived counts, body node digest, return digest, and main presence
├─ tiny single-file codegen lowers local declarations, assignments, calls, arithmetic, and returns through LLVM C API wrappers
├─ YCPL_NO_BOOTSTRAP=1 project build-ir emits valid LLVM IR
├─ project build-ir writes local_return.ll via std/llvm alloca/store/load/call/ret wrappers
├─ project build-ir writes project_body.ll via std/llvm statement/expression lowering wrappers
├─ merged.ll includes the LLVM-wrapper-generated node probe for local, assignment, call, and return counts
├─ merged.ll calls LLVM-wrapper-generated project statement/expression lowering
├─ project_body.ll lowers source-derived zero-argument i32 constant-return functions
├─ project parse/check emits typed AST shape counts and a typed digest
├─ generated project IR uses function, body-node, typed-AST, main-presence, and return-expression globals
├─ YCPL_NO_BOOTSTRAP=1 project build emits a native AST smoke binary
├─ generated stage2 binary emits stage3 LLVM IR
├─ generated stage2 binary builds native stage3 smoke output
├─ generated stage2 binary lowers tiny examples to executable IR by source content
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
