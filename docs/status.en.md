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
├─ project parse/check emits body node transition digest and local/assign/call/return edge counts
├─ body if/for nodes lower through std/llvm into conditional branch and loop blocks
├─ tiny single-file codegen lowers local declarations, assignments, calls, arithmetic, and returns through LLVM C API wrappers
├─ YCPL_NO_BOOTSTRAP=1 project build-ir emits valid LLVM IR
├─ project build-ir writes local_return.ll via std/llvm alloca/store/load/call/ret wrappers
├─ project build-ir writes project_body.ll via std/llvm statement/expression lowering wrappers
├─ merged.ll includes the LLVM-wrapper-generated node probe for local, assignment, call, return, transitions, and if/for control flow
├─ merged.ll calls LLVM-wrapper-generated project statement/expression lowering
├─ project_body.ll dispatches local/assignment/call/return body nodes into dedicated alloca/load/store/call lowering
├─ project_body.ll lowers source-derived zero-argument i32 constant-return functions
├─ project_body.ll lowers parser-owned per-function body slots and all-function aggregate body data into alloca/call/conditional/loop IR
├─ project parse/check and generated IR gate per-function body slot table counts, max size, and digest
├─ project parse/check exposes identifier/literal/type/control payload table counts and digest from body-node arenas
├─ project parse/check exposes semantic role counts for local symbols, assignment targets, call targets, return symbols/literals, type refs, and control refs
├─ project parse/check exposes declaration/import/module symbol summaries for functions, structs, std imports, aliases, visibility, and digests
├─ project parse/check cross-checks function signature and call-site arity summaries against parser counts
├─ project parse/check stores parser-owned semantic node tables for function signatures and call sites
├─ project parse/check stores parser-owned expression node tables for primary/call/member/index/binary/unary expressions
├─ generated project IR gates expression table counts/digests and lowers them through project_body.ll
├─ project parse/check and project_body.ll now track per-function expression slot counts, max slot size, and digest
├─ project_body.ll combines per-function body-node lowering with per-function expression node/slot/digest lowering
├─ project_body.ll dispatches identifier/literal/call/member/index/binary/unary expression node kinds into dedicated LLVM lowering paths
├─ project_body.ll preserves binary operator tags and lowers them into LLVM add/sub/mul/sdiv/srem/icmp instructions
├─ project_body.ll now tracks function_expr_lowered_nodes and function_expression_sequence_lowered for a 1024-cap, 600+ node expression sequence lowering pass
├─ generated stage2/stage3 IR now gates the expression lowering floor with ycpl_stage_expr_lowered_floor
├─ project_body.ll emits per-function lowering functions for compiler/ycpl body slots 0 through 31
├─ project_body.ll emits range bucket lowering functions for compiler/ycpl body slots 0 through 383
├─ project_body.ll lowers variable-length statement/expression body-node arenas with metadata/source positions/payload tables/semantic roles into node-sequence alloca/branch/loop IR
├─ project parse/check emits typed AST shape counts and a typed digest
├─ generated project IR uses function, body-node, expression-table, typed-AST, signature node table, symbol signature/arity, main-presence, and return-expression globals
├─ YCPL_NO_BOOTSTRAP=1 project build emits a native AST smoke binary
├─ generated stage2 binary emits stage3 LLVM IR
├─ generated stage2 binary builds native stage3 compiler-smoke output
├─ generated stage3 binary supports parse/check/build-ir compiler/ycpl and emits llc-valid stage4 LLVM IR
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
