# YCPL

[English](README.md) | [English docs](docs/README.en.md) | [日本語 docs](docs/README.ja.md)

YCPLは、セルフホストコンパイラ、LLVM 22 backend、static linkされる
managed runtime、標準ライブラリ、examples、YCPL製LSPを含む実験的な
システムプログラミング言語です。ソースファイルの拡張子は`.yc`です。

```text
.yc source -> lexer -> canonical AST -> resolver/type checker -> LLVM C API
                                                               |
                                                               v
                                                        LLVM IR (.ll)
                                                               |
                                                               v
                                                          llc + clang
                                                               |
                                                               v
                                                 native binary + runtime
```

## リポジトリ構成

```text
bootstrap/cpp/          C++ seed/reference compiler
compiler/ycpl/          セルフホストYCPLコンパイラ
bootstrap/cpp/runtime/  外部managed-allocation runtime
stl/c/                  C APIおよびLLVM API宣言
stl/std/                YCPL標準ライブラリ
examples/               言語、stdlib、project examples
tests/                  conformance、negative、project、runtime fixtures
tools/lsp/              YCPLで実装したLSP
```

YCPLはearly alphaであり、production用途にはまだ適していません。コンパイラは
単一ファイルと`YCPL.json` projectを受け付け、`build-ir`でLLVM IR、`build`で
native binaryを生成し、`run`でbuild後に実行します。

## ビルド

LLVM 22、`llc`、`clang`は外部依存として必要です。

```sh
eval "$(scripts/setup-llvm.sh 22 --print-env)"
bazel build //:ycc //:ycc-bootstrap //:ycc-ycpl
bazel test //...
```

Bazelのコンパイラ生成チェーンは次のとおりです。

```text
ycc-bootstrap (C++ seed/reference)
    -> ycc-stage1
    -> ycc-stage2
    -> ycc-stage3
    -> ycc
       └─ ycc-ycpl (互換alias)
```

C++ seedが生成するのはstage1だけです。stage2はstage1、stage3はstage2によって
生成されます。標準の`ycc`はstage3であり、通常のコマンド処理からC++実行
ファイルへ戻る経路はありません。`build-ir-self`は`build-ir`のdeprecated
aliasとしてのみ残っています。

`scripts/setup-llvm.sh`はsystem symlinkを作らず、`LLVM_CONFIG`、
`LLVM_BINDIR`、`LLVM_DIR`、PATH prefixを出力します。C++ seed/reference実装は
CMakeでもbuildできます。

```sh
cmake -S . -B build
cmake --build build
```

## コンパイル

```sh
bazel run //:ycc -- build examples/basics/hello.yc -o /tmp/ycpl-hello
bazel run //:ycc -- run examples/basics/hello.yc -o /tmp/ycpl-hello
bazel run //:ycc -- build-ir examples/basics/hello.yc -o /tmp/ycpl-ir

cd examples/projects/module_project
../../../bazel-bin/ycc build
```

driver commandは`build`、`build-ir`、`run`、`debug`、`lex`、`parse`、
`check`、`resolve`、`help`です。`-o`、`--keep-obj`、`--link-llvm`、
`--`以降のprogram argumentsも扱います。

runtimeは次の順で解決します。

1. `YCPL_RUNTIME_LIB`
2. コンパイラ実行ファイルに隣接する`libyc_runtime.a`
3. 開発ツリーで`YCPL_RUNTIME_SRC`が示すruntime source

標準ライブラリのsource rootは`YCPL_STL_ROOT`で指定できます。Bazel runfilesと
開発ツリーからの実行では自動的に解決されます。

## セルフホスト

`ProgramAst`と`AstArena`がコンパイラ唯一のfrontend表現です。各ファイルには
安定したfile IDが割り当てられ、cross-file参照は解決済みfile/node IDと
symbol IDを使用します。動的arenaによって、以前存在したlocals、functions、
arguments、struct fieldsの固定上限はなくなりました。

backendはnamed type、function、externを先に宣言し、その後でfunction bodyを
lowerします。struct、enum、alias、pointer、slice、array、Map、call、UFCS、
short-circuit、bounds check、loop、switch、defer/scope unwind、cast、variadic、
managed ownership transitionを含む解決済みASTをLLVM C APIへ直接lowerします。
生成moduleは必ずLLVM verifierを通ります。

source discoveryは`stat`でsymlinkを追跡し、訪問済みdevice/inodeで循環を防ぎます。
設定された`src` rootを再帰走査し、project-relative pathでsortしてからfile IDを
割り当てます。

fixed-point testはstage2とstage3でコンパイラを再生成し、両方のIRをLLVM 22の
`llvm-as`と`llvm-dis`へ通します。module/source path metadataだけを安定化した後、
byte単位で完全一致することを要求します。target triple、data layout、symbol、
instructionは比較対象から除外しません。

## 言語機能

conformance対象にはprimitive type、pointer、slice、array、struct、enum、alias、
`Vec<T>`、`Map`、`none`、`owned`、function、extern/intrinsic/variadic call、module/import
alias/public visibility、`if`、`switch`、`for`、`for-in`、`break`、`continue`、
`defer`、`scope`、UFCS callが含まれます。

`Vec<T>`はコンパイラ組み込みのmanaged動的配列です。`Vec<T>{}`または
`Vec<T>{capacity: n}`で構築し、`push`、`len`、`capacity`、`reserve`、`clear`、
index read/write、`as_slice`を使用できます。Vecのコピーは同じhandleを共有し、
`[]T`は拡張できないviewとして区別されます。raw pointer取得や利用者による
`free`は公開APIにありません。

`none`はoptional typeではなくnull literalです。managed allocationは決定的な
function/scope frameで管理されます。returnされたrootはcallerへ移動し、array、
Vec、map、text、bytes、jsonのownership graphはchildとともに解放されます。

## C APIとLLVM API

外部C APIの正規の配置先は`stl/c/*`です。コンパイラはLLVM 22との境界に
`c/llvm`、C/runtimeとの境界に`c/stdlib`と`c/yc_runtime`を使用します。
既存の互換wrapperを除き、`stl/std/*`には言語レベルのAPIを配置します。

## テスト

```sh
# 任意のcompiler executableへ同じconformance oracleを適用
tests/run_conformance.sh ./bazel-bin/ycc

# fixed point、examples、runtime、LSP、全Bazel target
bazel test //:self_host_stage_test //:ycc_ycpl_test
bazel test //...
```

conformance suiteは全examples、stdlib、`c/*` FFI、project/module build、runtime
ownership、negative fixtureの終了分類・位置・診断messageを検査します。Bazelの
fixed-point testはstage2/stage3実行環境からseed/fallback変数とbootstrap binaryも
取り除きます。

## ドキュメント

- [言語リファレンス](docs/language.ja.md)
- [Vecとメモリ所有](docs/memory.ja.md)
- [セルフホストの検証](docs/self-hosting.ja.md)
- [文法](docs/grammar/ycpl.ebnf)
- [標準ライブラリ](docs/stdlib.ja.md)
- [現在の実装状況](docs/status.ja.md)
- [Examples](examples/README.md)
- [Tests](tests/README.md)
