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
├─ tiny single-file codegen は local declaration、assignment、call、arithmetic、return を LLVM C API wrapper で lower
├─ YCPL_NO_BOOTSTRAP=1 の project build-ir は valid LLVM IR を生成
├─ project build-ir は std/llvm の alloca/store/load/call/ret wrapper で local_return.ll を生成
├─ project build-ir は std/llvm の statement/expression lowering wrapper で project_body.ll を生成
├─ merged.ll は local、assignment、call、return count 用の LLVM-wrapper-generated node probe を含む
├─ merged.ll は LLVM-wrapper-generated project statement/expression lowering を呼び出す
├─ project_body.ll は source-derived zero-argument i32 constant-return function を lower
├─ project parse/check は typed AST shape count と typed digest を出す
├─ 生成 project IR は function、body-node、typed AST、main-presence、return-expression global を使う
├─ YCPL_NO_BOOTSTRAP=1 の project build は native AST smoke binary を生成
├─ 生成された stage2 binary は stage3 LLVM IR を出力
├─ 生成された stage2 binary は native stage3 smoke output を build
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
