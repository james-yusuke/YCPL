# 実装状況

[English](status.en.md) | [Docs index](README.ja.md)

```text
Feature status
├─ examples で安定扱い
├─ 実験中
└─ 予約済み、未実装
```

## examples で安定扱い

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

## 実験中

```text
experimental
├─ ycc-ycpl lexer/parser self-hosting compiler
├─ tiny i32 subset 用の ycc-ycpl checker、LLVM IR emitter、native build
├─ bootstrap ycc 経由の ycc-ycpl build/build-ir stage driver
├─ bundled std の intrinsic fn
├─ sprintf
├─ cast
├─ new([]T)
├─ user-defined variadic functions
├─ pointer-heavy expressions
├─ nested/inline structs
├─ runtime slice returns
└─ broad C/Unix FFI
```

## セルフホスト進行状況

```text
self-hosting
├─ bootstrap/cpp
│  ├─ 現行 C++ compiler
│  └─ codegen と native build はまだここが担当
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
   ├─ 生成された stage2 binary parse/check/build-ir compiler/ycpl
   ├─ 生成された stage2 binary build compiler/ycpl -o <stage3-out>
   ├─ 生成された stage2 binary build examples/54_self_codegen_arithmetic.yc と renamed copy
   ├─ ycc-ycpl build compiler/ycpl -o <out>
   └─ 未対応 input はまだ bootstrap ycc に委譲
```

```text
stage-2 self-host gate
├─ compiler/ycpl source discovery は nested src/**/*.yc file を traversal
├─ resolver は shell-backed traversal の前に unsafe project path を拒否
├─ project parse/check は AST 由来の count、body node digest、return digest、main presence を出す
├─ project parse/check は body node transition digest と local/assign/call/return edge count を出す
├─ body if/for node は std/llvm 経由で conditional branch と loop block に lower
├─ tiny single-file codegen は local declaration、assignment、call、arithmetic、return を LLVM C API wrapper で lower
├─ YCPL_NO_BOOTSTRAP=1 の project build-ir は valid LLVM IR を生成
├─ project build-ir は std/llvm の alloca/store/load/call/ret wrapper で local_return.ll を生成
├─ project build-ir は std/llvm の statement/expression lowering wrapper で project_body.ll を生成
├─ merged.ll は local、assignment、call、return、transition、if/for control flow 用の LLVM-wrapper-generated node probe を含む
├─ merged.ll は LLVM-wrapper-generated project statement/expression lowering を呼び出す
├─ project_body.ll は local/assignment/call/return body node を専用 alloca/load/store/call lowering に分岐
├─ project_body.ll は source-derived zero-argument i32 constant-return function を lower
├─ project_body.ll は parser-owned per-function body slot と全関数 aggregate body data を alloca/call/conditional/loop IR に lower
├─ project parse/check と生成 IR は per-function body slot table の count/max/digest を gate する
├─ project parse/check は body-node arena 由来の identifier/literal/type/control payload table count と digest を出す
├─ project parse/check は local symbol、assignment target、call target、return symbol/literal、type ref、control ref の semantic role count を出す
├─ project parse/check は function、struct、std import、alias、visibility、digest の declaration/import/module symbol summary を出す
├─ project parse/check は function signature と call-site arity summary を parser count と照合する
├─ project parse/check は function signature と call-site の parser-owned semantic node table を保持する
├─ project parse/check は primary/call/member/index/binary/unary expression の parser-owned expression node table を保持する
├─ 生成 project IR は expression table count/digest を gate し、project_body.ll 経由で lower する
├─ project parse/check と project_body.ll は per-function expression slot count、max slot size、digest を保持する
├─ project_body.ll は per-function body-node lowering と per-function expression node/slot/digest lowering を結合する
├─ project_body.ll は identifier/literal/call/member/index/binary/unary expression node kind を専用 LLVM lowering path に分岐する
├─ project_body.ll は binary operator tag を保持し、LLVM add/sub/mul/sdiv/srem/icmp 命令へ lower する
├─ project_body.ll は 1024-cap / 600+ node の expression sequence lowering pass 用に function_expr_lowered_nodes と function_expression_sequence_lowered を保持する
├─ 生成された stage2/stage3 IR は ycpl_stage_expr_lowered_floor で expression lowering floor を gate する
├─ project_body.ll は compiler/ycpl body slot 0 から 31 までの per-function lowering function を生成する
├─ project_body.ll は compiler/ycpl body slot 0 から 383 までの range bucket lowering function を生成する
├─ project_body.ll は metadata/source position/payload table/semantic role 付き可変長 statement/expression body-node arena を node-sequence alloca/branch/loop IR に lower
├─ project parse/check は typed AST shape count と typed digest を出す
├─ 生成 project IR は function、body-node、expression-table、typed AST、signature node table、symbol signature/arity、main-presence、return-expression global を使う
├─ YCPL_NO_BOOTSTRAP=1 の project build は native AST smoke binary を生成
├─ 生成された stage2 binary は stage3 LLVM IR を出力
├─ 生成された stage2 binary は native stage3 compiler-smoke output を build
├─ 生成された stage3 binary は parse/check/build-ir compiler/ycpl に対応し、llc-valid な stage4 LLVM IR を出力する
├─ 生成された stage2 binary は source 内容で tiny examples を実行可能 IR に lower
└─ compiler として等価な native ycc-ycpl は次の実装ステップ
```

## 予約済みだが未実装

```text
enum interface match is go defer select switch or type importas
```

```text
reserved token
├─ 将来構文との衝突を防ぐ
└─ parser/codegen support は未実装
```

`none` は optional type ではなく null literal です。import した関数の直接呼びは
拒否されます。LSP navigation は現在、full project index ではなく開いている
document を走査します。
