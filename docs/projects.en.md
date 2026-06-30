# Projects And Modules

[Japanese](projects.ja.md) | [Docs index](README.en.md)

YCPL compiles either explicit `.yc` files or a project rooted by `YCPL.json`.

```text
File mode:
  build/ycc examples/01_hello.yc
      |
      v
  resolve modules -> write .ll

Project mode:
  YCPL.json -> scan source dirs for .yc
      |
      v
  resolve modules -> write .ll
```

## Single File

```sh
build/ycc examples/01_hello.yc -o /tmp/ycpl_hello
```

## Project Layout

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

| Field | Meaning |
|---|---|
| `name` | Project name |
| `version` | Project version string |
| `entry` | Intended entry source |
| `src` | Source directories scanned recursively for `.yc` |
| `output` | Directory for generated LLVM IR |

```sh
build/ycc build
```

## Import Resolution

```text
import path
├─ relative path starting with .
│  └─ path.yc or path/index.yc
├─ project source directories
│  └─ path.yc or path/index.yc
└─ bundled standard library
   └─ stl/std/path.yc or stl/std/path/index.yc
```

## Visibility

```text
module math
├─ pub fn add     -> importer can call math.add(...)
└─ fn helper      -> private to module
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
