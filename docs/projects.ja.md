# プロジェクトとモジュール

[English](projects.en.md) | [Docs index](README.ja.md)

YCPL は明示した `.yc` ファイル、または `YCPL.json` を持つプロジェクトを
コンパイルできます。

```mermaid
flowchart LR
    FileMode["File mode"] --> Input["build/ecc examples/01_hello.yc"]
    ProjectMode["Project mode"] --> Config["YCPL.json"]
    Config --> Scan["src dirs から .yc を走査"]
    Input --> Resolve["modules 解決"]
    Scan --> Resolve
    Resolve --> IR[".ll を出力"]
```

## 単一ファイル

```sh
build/ecc examples/01_hello.yc -o /tmp/ycpl_hello
```

## プロジェクト構成

```mermaid
flowchart TD
    Project["my_project/"] --> Config["YCPL.json"]
    Project --> Src["src/"]
    Src --> Main["main.yc"]
    Src --> Math["math.yc"]
    Config --> Entry["entry: src/main.yc"]
    Config --> SrcDirs["src: [src/]"]
    Config --> Output["output: build/"]
```

```json
{
  "name": "my_project",
  "version": "0.1.0",
  "entry": "src/main.yc",
  "src": ["src/"],
  "output": "build/"
}
```

| フィールド | 意味 |
|---|---|
| `name` | プロジェクト名 |
| `version` | バージョン文字列 |
| `entry` | 想定エントリソース |
| `src` | 再帰的に `.yc` を探すソースディレクトリ |
| `output` | 生成 LLVM IR の出力先 |

```sh
build/ecc build
```

## import 解決

```mermaid
flowchart TD
    Import["import path"] --> Relative[". で始まる relative import"]
    Import --> SourceDirs["project source dirs"]
    Import --> Std["bundled stl/std"]
    Relative --> RelFile["path.yc or path/index.yc"]
    SourceDirs --> SrcFile["path.yc or path/index.yc"]
    Std --> StdFile["stl/std/path.yc or index.yc"]
```

## 公開範囲

```mermaid
flowchart LR
    ModuleA["module math"] --> Pub["pub fn add"]
    ModuleA --> Private["fn helper"]
    Pub --> Importer["importer は math.add を呼べる"]
    Private --> Hidden["module 外から不可視"]
```

```YCPL
module math

pub fn add(a i32, b i32) i32 {
    return a + b
}
```

```YCPL
import "math" as math

fn main() {
    result := math.add(1, 2)
}
```

import した関数は `alias.symbol(...)` で呼びます。公開関数の LLVM symbol は
`module__name` に mangle され、`main` は `main` のままです。
