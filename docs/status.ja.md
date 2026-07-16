# 実装状況

[English](status.en.md) | [Docs index](README.ja.md)

YCPLは完全セルフホストの固定点まで到達しています。標準コンパイラ
`ycc`はYCPL実装で、C++版は初回seedと差分検証専用の
`ycc-bootstrap`として残しています。

## コンパイラ構成

```text
ycc-bootstrap (C++ seed/reference)
    -> ycc-stage1
    -> ycc-stage2
    -> ycc-stage3
    -> ycc
       └─ ycc-ycpl (互換alias)
```

- C++版を呼ぶのはstage1生成だけです。
- stage2以降のbuild/check/codegenにbootstrap fallbackはありません。
- `build-ir-self`は`build-ir`のdeprecated aliasです。
- LLVM 22、`llc`、`clang`、C runtimeは外部基盤として維持します。

## フロントエンド

- `ProgramAst/AstArena`が唯一のcanonical ASTです。
- file IDはproject-relative pathの安定ソート順で決まります。
- cross-file参照はfile/node IDとresolved symbol IDで保持します。
- source探索は`stat`でsymlinkを追跡し、device/inodeで循環を防止します。
- AST node列、project files、symbols、imports、localsは`Vec<T>`ベースの動的arenaで保持します。
- 64以上のlocals/functions、32以上のarguments、4フィールド以上のstructを回帰試験し、旧固定上限を撤廃しています。
- 宣言、型、literal、演算子、代入、関数、struct、enum、alias、pointer、slice、Map、owned、defer、scope、switch、for/for-in、UFCS、extern/intrinsic/variadicを実AST上で解決します。
- `compiler/ycpl`は直接`std/mem`をimportせず、AST・resolver・project loaderの可変長データを`Vec<T>`で保持します。

## LLVM backend

- named type/struct、function/extern宣言を先に作り、その後でbodyをlowerします。
- primitive、pointer、slice、Vec、struct、array、Map、alias、enumのABIを扱います。
- short-circuit、bounds check、break/continue、switch、defer LIFO、scope unwind、compound assignment、cast、UFCS、variadic callをresolved ASTから直接lowerします。
- managed allocationのfunction/scope frame、escape、child ownership、main init/shutdownを挿入します。
- 生成moduleは必ずLLVM verifierを通します。
- fixture名やsource digestによるIR選択、埋め込みstage IR、巨大probe IRは使いません。

## C API境界

raw C/LLVM宣言の正規の配置先は`stl/c/*`です。compilerは`c/llvm`、
`c/stdlib`、`c/yc_runtime`経由で外部APIを利用します。既存の互換wrapperを除き、
`stl/std/*`は言語レベルの標準APIです。

## driver

`ycc`は`YCPL.json`、file/directory入力、`build`、`build-ir`、`run`、
`debug`、`lex`、`parse`、`check`、`resolve`、`help`、`-o`、
`--keep-obj`、`--link-llvm`、`--`引数を扱います。

C runtimeは次の順で解決します。

1. `YCPL_RUNTIME_LIB`
2. 実行ファイル隣接の`libyc_runtime.a`
3. 開発環境の`YCPL_RUNTIME_SRC`

## 検証済み

- 任意compiler実行ファイルへ適用できるconformance harness: 77/77 PASS
- 全examples、stdlib、`c/*` FFI、project/module、runtime ownership
- 全negative fixtureの終了分類と診断位置・substring
- Vecの拡張、共有handle、managed要素、nested Vec、index overwrite、clear
- dynamic locals/functions/arguments/struct fields
- compiler自身、hello、複合stdlib、LSP protocol
- stage2/stage3 IRのLLVM 22 canonicalize後の完全一致
- `bazel test //...` PASS

固定点テストは`llvm-as -> llvm-dis`後、ModuleID、source filename、出力先の
絶対pathだけを安定化します。target triple、data layout、symbol、命令は比較から
除外しません。

## 現在の位置づけ

言語とtoolchainはまだearly alphaです。今回の完了範囲にLLVM/C runtimeの
YCPL再実装とLSP機能拡張は含みません。C++版はseed/referenceとして維持し、
通常の`ycc`処理はYCPL版だけで完結します。
