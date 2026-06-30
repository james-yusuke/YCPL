# YCPL

[English](README.md) | [English docs](docs/README.en.md) | [日本語 docs](docs/README.ja.md)

YCPL は、システムプログラミング向けの実験的な言語です。C++ 製コンパイラ、
LLVM バックエンド、YCPL で書かれた標準ライブラリ、サンプル、LSP を含みます。
ソース拡張子は `.yc` です。

```mermaid
flowchart LR
    Source[".yc ソース"] --> Lexer["Lexer"]
    Lexer --> Parser["Parser"]
    Parser --> AST["AST"]
    AST --> Resolver["Module resolver"]
    Resolver --> Codegen["LLVM IR codegen"]
    Codegen --> IR[".ll 出力"]
    IR --> Native["llc + clang"]
```

```mermaid
mindmap
  root((YCPL))
    言語
      静的型
      スライス
      構造体
      モジュール
    コンパイラ
      C++20
      LLVM
      プロジェクトビルド
    標準ライブラリ
      std/fmt
      std/array
      std/mem
      std/json
    ツール
      VSCode
      ネイティブLSP
      回帰サンプル
```

## 全体像

```mermaid
flowchart TB
    repo["Repository"] --> src["src/: lexer, parser, AST, resolver, codegen"]
    repo --> cli["cli/ecc/: コマンドラインコンパイラ"]
    repo --> stl["stl/std/: YCPL 標準ライブラリ"]
    repo --> examples["examples/: .yc サンプルと回帰テスト"]
    repo --> lsp["tools/lsp/: YCPL 製 LSP"]
    repo --> vscode["editors/vscode/: 言語拡張"]
    repo --> docs["docs/: 英語/日本語ドキュメント"]
```

| 項目 | 状態 |
|---|---|
| 安定性 | かなり初期の alpha、production 非推奨 |
| ソース拡張子 | `.yc` |
| ビルド出力 | LLVM IR (`.ll`) |
| プロジェクト設定 | `YCPL.json` |
| 主なエディタ導線 | VSCode Remote Dev Containers |

## ビルド

```mermaid
sequenceDiagram
    participant Dev as 開発者
    participant CMake as CMake
    participant LLVM as LLVM 18+
    participant ECC as ecc
    Dev->>CMake: cmake -DLLVM_DIR=/path/to/llvm ..
    CMake->>LLVM: headers/libs を検出
    Dev->>CMake: make
    CMake->>ECC: コンパイラ生成
```

```sh
mkdir build
cd build
cmake -DLLVM_DIR=/your/llvm/path/cmake ..
make
```

## コンパイル

```mermaid
flowchart LR
    Single["examples/01_hello.yc"] --> Cmd1["build/ecc examples/01_hello.yc -o /tmp/ycpl_hello"]
    Project["プロジェクト"] --> Config["YCPL.json"]
    Config --> Cmd2["build/ecc build"]
    Cmd1 --> LL["LLVM IR"]
    Cmd2 --> LL
```

```sh
build/ecc examples/01_hello.yc -o /tmp/ycpl_hello
cd examples/04_module_project && ../../build/ecc build
```

## 言語スナップショット

```mermaid
flowchart TD
    Module["module math"] --> Public["pub fn add(...)"]
    Import["import \"math\" as math"] --> Call["math.add(1, 2)"]
    Types["i32, i64, bool, string, *T, []T"] --> Values["変数、リテラル、構造体"]
    Flow["if / for / break / continue"] --> Main["fn main()"]
```

```YCPL
import "std/fmt" as fmt

fn main() {
    fmt.println("Hello World")
}
```

## ドキュメント

```mermaid
flowchart LR
    Root["README.md"] --> EN["docs/*.en.md"]
    RootJA["README-JA.md"] --> JA["docs/*.ja.md"]
    EN --> LanguageEN["language.en.md"]
    EN --> ProjectsEN["projects.en.md"]
    EN --> StdEN["stdlib.en.md"]
    EN --> StatusEN["status.en.md"]
    JA --> LanguageJA["language.ja.md"]
    JA --> ProjectsJA["projects.ja.md"]
    JA --> StdJA["stdlib.ja.md"]
    JA --> StatusJA["status.ja.md"]
```

- [言語構文](docs/language.ja.md)
- [プロジェクトとモジュール](docs/projects.ja.md)
- [標準ライブラリ](docs/stdlib.ja.md)
- [実装状況](docs/status.ja.md)
- [YCPL LSP](tools/lsp/README.md)

## エディタと LSP

```mermaid
flowchart LR
    VSCode["VSCode"] --> Extension["YCPL extension"]
    Extension --> Watcher["**/*.yc watcher"]
    Extension --> Server["tools/lsp/build/YCPL-lsp"]
    Server --> Features["hover, completion, symbols, semantic tokens, formatting, rename"]
```

```sh
npm ci --prefix editors/vscode
tools/lsp/build.sh
tools/lsp/run_tests.sh
```

## テスト

```mermaid
flowchart TD
    Tests["examples/run_tests.sh"] --> Positive["単一ファイル成功系"]
    Tests --> Projects["プロジェクトビルド"]
    Tests --> CompileFail["コンパイル失敗期待"]
    Tests --> RuntimeFail["実行時失敗期待"]
    Positive --> LLVM["LLVM IR チェック"]
    Projects --> Config["YCPL.json"]
```

```sh
examples/run_tests.sh
```
