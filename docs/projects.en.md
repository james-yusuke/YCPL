# Projects And Modules

[Japanese](projects.ja.md) | [Docs index](README.en.md)

YCPL compiles either explicit `.yc` files or a project rooted by `YCPL.json`.

```text
File mode:
  bazel run //:ycc -- build examples/basics/hello.yc
      |
      v
  resolve modules -> write .ll -> llc -> clang -> binary
  bazel run //:ycc -- run examples/basics/hello.yc
      |
      v
  build native binary -> execute it

Project mode:
  YCPL.json -> scan source dirs recursively in deterministic path order
      |
      v
  ycc build     -> write .ll -> llc -> clang -> binary
  ycc run       -> build native binary -> execute it
  ycc build-ir  -> write .ll only
```

## Single File

```sh
bazel run //:ycc -- build examples/basics/hello.yc -o /tmp/ycpl_hello
bazel run //:ycc -- run examples/basics/hello.yc -o /tmp/ycpl_hello
bazel run //:ycc -- build-ir examples/basics/hello.yc -o /tmp/ycpl_hello
```

## LLVM Toolchain Paths

```text
Preferred:
  LLVM_CONFIG=/path/to/llvm-config bazel build //:ycc
  LLVM_DIR=/path/to/lib/cmake/llvm cmake -S . -B build

Supported common prefixes:
  Ubuntu:     /usr/lib/llvm-22
  macOS arm:  /opt/homebrew/opt/llvm@22
  macOS x86:  /usr/local/opt/llvm@22
```

YCPL does not require linking LLVM tools into `/usr` or `/usr/local/bin`.
Use `eval "$(scripts/setup-llvm.sh 22 --print-env)"` when you want the helper
script to export paths for the current shell. Build rules also add the LLVM
library directory from `llvm-config --libdir` to rpath, so Homebrew or
`/usr/lib/llvm-22` shared libraries can stay in their package-managed location.
This mirrors Odin's development setup: `LLVM_CONFIG` is the override point,
package-manager installs are detected, and global symlinks are not required.

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
| `output` | Directory for generated LLVM IR, object files, and native binaries |

```sh
../../bazel-bin/ycc build
../../bazel-bin/ycc build-ir
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
