# Projects And Modules

[Japanese](projects.ja.md) | [Docs index](README.en.md)

YCPL compiles either explicit `.yc` files or a project rooted by `YCPL.json`.

```mermaid
flowchart LR
    FileMode["File mode"] --> Input["build/ecc examples/01_hello.yc"]
    ProjectMode["Project mode"] --> Config["YCPL.json"]
    Config --> Scan["scan src dirs for .yc"]
    Input --> Resolve["resolve modules"]
    Scan --> Resolve
    Resolve --> IR["write .ll"]
```

## Single File

```sh
build/ecc examples/01_hello.yc -o /tmp/ycpl_hello
```

## Project Layout

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

| Field | Meaning |
|---|---|
| `name` | Project name |
| `version` | Project version string |
| `entry` | Intended entry source |
| `src` | Source directories scanned recursively for `.yc` |
| `output` | Directory for generated LLVM IR |

```sh
build/ecc build
```

## Import Resolution

```mermaid
flowchart TD
    Import["import path"] --> Relative["relative import starts with ."]
    Import --> SourceDirs["project source dirs"]
    Import --> Std["bundled stl/std"]
    Relative --> RelFile["path.yc or path/index.yc"]
    SourceDirs --> SrcFile["path.yc or path/index.yc"]
    Std --> StdFile["stl/std/path.yc or index.yc"]
```

## Visibility

```mermaid
flowchart LR
    ModuleA["module math"] --> Pub["pub fn add"]
    ModuleA --> Private["fn helper"]
    Pub --> Importer["importer can call math.add"]
    Private --> Hidden["not visible outside module"]
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

Imported functions must be called as `alias.symbol(...)`. Public function LLVM
symbols are mangled as `module__name`; `main` stays `main`.
