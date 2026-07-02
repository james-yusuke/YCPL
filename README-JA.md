# YCPL

[English](README.md) | [English docs](docs/README.en.md) | [日本語 docs](docs/README.ja.md)

YCPL は、システムプログラミング向けの実験的な言語です。C++ 製コンパイラ、
LLVM バックエンド、YCPL で書かれた標準ライブラリ、サンプル、LSP を含みます。
ソース拡張子は `.yc` です。

```text
.yc ソース
    |
    v
+--------+   +--------+   +-----+   +-----------------+   +----------+
| Lexer  |-->| Parser |-->| AST |-->| Module resolver |-->| Codegen  |
+--------+   +--------+   +-----+   +-----------------+   +----------+
                                                               |
                                                               v
                                                     LLVM IR (.ll)
                                                               |
                                                               v
                                                          llc + clang
                                                               |
                                                               v
                                                        native binary
```

```text
YCPL
├─ 言語
│  ├─ 静的型
│  ├─ スライス
│  ├─ 構造体
│  └─ モジュール
├─ コンパイラ
│  ├─ C++20
│  ├─ LLVM
│  └─ プロジェクトビルド
├─ 標準ライブラリ
│  ├─ std/fmt
│  ├─ std/array
│  ├─ std/mem
│  └─ std/json
└─ ツール
   ├─ VSCode
   ├─ ネイティブ LSP
   └─ 回帰サンプル
```

## 全体像

```text
Repository
├─ bootstrap/cpp/   C++ bootstrap compiler 実装
├─ compiler/ycpl/   YCPL 製 compiler、lex/parse milestone
├─ stl/std/         YCPL 標準ライブラリ
├─ examples/        .yc サンプルと回帰テスト
├─ tools/lsp/       YCPL 製 LSP
├─ editors/vscode/  言語拡張
└─ docs/            英語/日本語ドキュメント
```

| 項目 | 状態 |
|---|---|
| 安定性 | かなり初期の alpha、production 非推奨 |
| ソース拡張子 | `.yc` |
| ビルド出力 | `ycc build` は native binary、`ycc build-ir` は LLVM IR (`.ll`) |
| プロジェクト設定 | `YCPL.json` |
| コンパイラバイナリ | `ycc` bootstrap、`ycc-ycpl` self-hosting compiler 作業中 |

## ビルド

```text
開発者
   |
   | bazel build //:ycc //:ycc-ycpl
   v
Bazel ---- 設定 ----> llvm-config 経由の LLVM 22
   |
   +----> bazel-bin/ycc       C++ bootstrap compiler
   |
   +----> bazel-bin/ycc-ycpl  YCPL compiler scaffold
```

```sh
eval "$(scripts/setup-llvm.sh 22 --print-env)"
bazel build //:ycc //:ycc-ycpl
bazel test //...
```

`scripts/setup-llvm.sh` は `/usr` や `/usr/local` に LLVM の symlink を作りません。
代わりに `LLVM_CONFIG`、`LLVM_BINDIR`、`LLVM_DIR`、PATH prefix を出力します。
Ubuntu、Docker、macOS arm/Homebrew の LLVM を system tooling から分離して扱えます。
Bazel と CMake は `llvm-config` が返す LLVM library directory に link し、その
directory を build rpath に入れるため、LLVM shared library を `/usr` にコピーしたり
link したりする必要はありません。

この方針は Odin と同じ実用モデルです。明示的な `LLVM_CONFIG` を優先し、
package manager が入れた LLVM を検出し、利用者に global system path の変更を
要求しません。

LLVM 22 を system に入れている場合は CMake も使えます。

```sh
cmake -S . -B build
cmake --build build
```

明示的に指定する場合:

```sh
LLVM_CONFIG=/opt/homebrew/opt/llvm@22/bin/llvm-config bazel build //:ycc
LLVM_DIR=/opt/homebrew/opt/llvm@22/lib/cmake/llvm cmake -S . -B build
```

## コンパイル

```text
単一ファイル:
  examples/01_hello.yc -> ycc build -> native binary
  examples/01_hello.yc -> ycc build-ir -> LLVM IR

プロジェクト:
  YCPL.json -> src/*.yc を走査 -> ycc build -> native binary
  YCPL.json -> src/*.yc を走査 -> ycc build-ir -> LLVM IR
```

```sh
bazel run //:ycc -- build examples/01_hello.yc -o /tmp/ycpl_hello
bazel run //:ycc -- build-ir examples/01_hello.yc -o /tmp/ycpl_hello
cd examples/04_module_project && ../../bazel-bin/ycc build
```

## セルフホスト

```text
移行段階
├─ ycc
│  ├─ C++ bootstrap compiler
│  ├─ native binary と LLVM IR を生成
│  └─ まだ default compiler のまま
└─ ycc-ycpl
   ├─ YCPL で実装
   ├─ YCPL source を lex/parse
   ├─ 小さな self-codegen subset を型検査
   ├─ i32 main、local、assignment、arithmetic は LLVM IR を直接生成
   ├─ その subset は bootstrap ycc なしで native binary まで生成
   ├─ compiler/ycpl を明示 project source set として parse/check
   ├─ YCPL_NO_BOOTSTRAP=1 で compiler/ycpl の project LLVM IR を生成
   ├─ project AST IR を bootstrap ycc なしで native smoke binary に変換
   └─ 未対応の build/build-ir input は bootstrap ycc に委譲
```

```text
compiler/ycpl
├─ source  bounded file loading
├─ diag    file/line/column diagnostics
├─ lexer   token stream、nested comments、string/char checks
├─ ast     kind i32 の tagged structs
├─ parser  current grammar surface と recovery diagnostics
├─ checker tiny i32 typed subset gate と project AST gate
├─ irgen   LLVM C API IR emission と project AST IR emission
├─ driver  self-native build と bootstrap stage driver
└─ cli     ycc-ycpl lex / parse / check / build-ir-self / build
```

```sh
bazel-bin/ycc-ycpl lex examples/01_hello.yc
bazel-bin/ycc-ycpl parse examples/01_hello.yc
bazel-bin/ycc-ycpl check examples/53_self_codegen_main.yc
bazel-bin/ycc-ycpl build-ir-self examples/53_self_codegen_main.yc -o /tmp/ycpl-self-tiny
bazel-bin/ycc-ycpl build examples/54_self_codegen_arithmetic.yc -o /tmp/ycpl-self-native
bazel-bin/ycc-ycpl parse compiler/ycpl
bazel-bin/ycc-ycpl check compiler/ycpl
bazel-bin/ycc-ycpl build-ir compiler/ycpl -o /tmp/ycpl-self-ir
bazel-bin/ycc-ycpl build compiler/ycpl -o /tmp/ycpl-self-native
YCPL_NO_BOOTSTRAP=1 bazel-bin/ycc-ycpl build-ir compiler/ycpl -o /tmp/ycpl-strict
YCPL_NO_BOOTSTRAP=1 bazel-bin/ycc-ycpl build compiler/ycpl -o /tmp/ycpl-strict-native
```

```text
stage-2 gate
├─ compiler/ycpl project parse/check は ycc-ycpl 側で処理
├─ tiny arithmetic build は YCPL_NO_BOOTSTRAP=1 で実行可能
├─ project build-ir は bootstrap fallback なしで実行
├─ project AST IR は native smoke binary まで変換可能
└─ compiler として等価な native ycc-ycpl は次段で対応
```

## YCPL から LLVM C API を呼ぶ

```text
YCPL source -> extern fn ... as "LLVM..." -> ycc build
                                                |
                                                v
                                      llvm-config link flags
```

```sh
LLVM_CONFIG=/opt/homebrew/opt/llvm@22/bin/llvm-config \
  bazel-bin/ycc build examples/50_llvm_c_api.yc -o /tmp/ycpl_llvm
```

`std/llvm` を import したプログラムは LLVM の C API を直接呼べます。
生成 IR が `LLVM...` symbol を参照している場合、`ycc build` は LLVM を自動 link
します。明示したい場合は `--link-llvm` も使えます。

## 言語スナップショット

```text
module math        import "math" as math
    |                       |
    v                       v
pub fn add(...)  ---->  math.add(1, 2)

i32 / i64 / bool / string / *T / []T
if / for / break / continue
fn main()
```

```YCPL
import "std/fmt" as fmt

fn main() {
    fmt.println("Hello World")
}
```

## ドキュメント

```text
README.md
└─ docs/*.en.md
   ├─ language.en.md
   ├─ projects.en.md
   ├─ stdlib.en.md
   └─ status.en.md

README-JA.md
└─ docs/*.ja.md
   ├─ language.ja.md
   ├─ projects.ja.md
   ├─ stdlib.ja.md
   └─ status.ja.md
```

- [言語構文](docs/language.ja.md)
- [プロジェクトとモジュール](docs/projects.ja.md)
- [標準ライブラリ](docs/stdlib.ja.md)
- [実装状況](docs/status.ja.md)
- [YCPL LSP](tools/lsp/README.md)

## エディタと LSP

```text
VSCode
  |
  v
YCPL extension -- watches --> **/*.yc
  |
  v
tools/lsp/build/YCPL-lsp
  |
  v
hover / completion / symbols / semantic tokens / formatting / rename
```

```sh
npm ci --prefix editors/vscode
tools/lsp/build.sh
tools/lsp/run_tests.sh
```

## テスト

```text
examples/run_tests.sh
├─ 単一ファイル成功系
├─ プロジェクトビルド
├─ コンパイル失敗期待
└─ 実行時失敗期待

bazel test //:ycc_ycpl_test
├─ ycc-ycpl lex smoke test
├─ failure ではない examples 全件の parse
└─ 壊れた入力に対する lexer/parser 診断の固定
```

```sh
bazel test //:examples_test //:lsp_protocol_test //:ycc_ycpl_test
```
