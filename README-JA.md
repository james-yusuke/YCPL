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
├─ src/             lexer, parser, AST, resolver, codegen
├─ cli/ycc/         コマンドラインコンパイラ
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
| ビルド出力 | LLVM IR (`.ll`) |
| プロジェクト設定 | `YCPL.json` |
| コンパイラバイナリ | `ycc` |

## ビルド

```text
開発者
   |
   | bazel build //:ycc
   v
Bazel ---- 設定 ----> llvm-config 経由の LLVM 22
   |
   v
bazel-bin/ycc
```

```sh
scripts/setup-llvm.sh 22
bazel build //:ycc
bazel test //...
```

LLVM 22 を system に入れている場合は CMake も使えます。

```sh
cmake -S . -B build -DLLVM_DIR=/path/to/llvm-22/cmake
cmake --build build
```

## コンパイル

```text
単一ファイル:
  examples/01_hello.yc -> ycc -> LLVM IR

プロジェクト:
  YCPL.json -> src/*.yc を走査 -> ycc build -> LLVM IR
```

```sh
bazel run //:ycc -- examples/01_hello.yc -o /tmp/ycpl_hello
cd examples/04_module_project && ../../bazel-bin/ycc build
```

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
```

```sh
examples/run_tests.sh
```
