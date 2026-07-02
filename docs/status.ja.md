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
   └─ 未対応 input はまだ bootstrap ycc に委譲
```

```text
stage-2 self-host gate
├─ compiler/ycpl は resolver 内の固定 project source list で扱う
├─ project parse/check は AST 由来の count と digest を出す
├─ YCPL_NO_BOOTSTRAP=1 の project build-ir は valid LLVM IR を生成
├─ YCPL_NO_BOOTSTRAP=1 の project build は native AST smoke binary を生成
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
