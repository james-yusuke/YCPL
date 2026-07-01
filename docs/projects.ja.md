# プロジェクトとモジュール

[English](projects.en.md) | [Docs index](README.ja.md)

YCPL は明示した `.yc` ファイル、または `YCPL.json` を持つプロジェクトを
コンパイルできます。

```text
File mode:
  bazel run //:ycc -- build examples/01_hello.yc
      |
      v
  modules 解決 -> .ll 出力 -> llc -> clang -> binary

Project mode:
  YCPL.json -> source dirs から .yc を走査
      |
      v
  ycc build     -> .ll 出力 -> llc -> clang -> binary
  ycc build-ir  -> .ll だけ出力
```

## 単一ファイル

```sh
bazel run //:ycc -- build examples/01_hello.yc -o /tmp/ycpl_hello
bazel run //:ycc -- build-ir examples/01_hello.yc -o /tmp/ycpl_hello
```

## LLVM ツールチェーンのパス

```text
推奨:
  LLVM_CONFIG=/path/to/llvm-config bazel build //:ycc
  LLVM_DIR=/path/to/lib/cmake/llvm cmake -S . -B build

対応する代表的な prefix:
  Ubuntu:     /usr/lib/llvm-22
  macOS arm:  /opt/homebrew/opt/llvm@22
  macOS x86:  /usr/local/opt/llvm@22
```

YCPL は LLVM tools を `/usr` や `/usr/local/bin` に link する必要がありません。
helper script で現在の shell に path を渡す場合は
`eval "$(scripts/setup-llvm.sh 22 --print-env)"` を使います。build rule は
`llvm-config --libdir` の LLVM library directory を rpath に入れるため、Homebrew
や `/usr/lib/llvm-22` の shared library を package 管理された場所に置いたまま使えます。
これは Odin の開発 setup と同じ考え方です。`LLVM_CONFIG` を override point にし、
package manager が入れた LLVM を検出し、global symlink を要求しません。

## プロジェクト構成

```text
my_project/
├─ YCPL.json
└─ src/
   ├─ main.yc
   └─ math.yc
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
| `output` | LLVM IR、object file、native binary の出力先 |

```sh
../../bazel-bin/ycc build
../../bazel-bin/ycc build-ir
```

## import 解決

```text
import path
├─ . で始まる relative path
│  └─ path.yc or path/index.yc
├─ project source directories
│  └─ path.yc or path/index.yc
└─ bundled standard library
   └─ stl/std/path.yc or stl/std/path/index.yc
```

## 公開範囲

```text
module math
├─ pub fn add     -> importer は math.add(...) を呼べる
└─ fn helper      -> module 内だけ
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
