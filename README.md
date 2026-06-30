# YCPL

[日本語](README-JA.md) | [English docs](docs/README.en.md) | [日本語 docs](docs/README.ja.md)

YCPL is an experimental systems-programming language with a C++ compiler,
LLVM backend, bundled YCPL standard library, examples, and a YCPL-written LSP.
Source files use the `.yc` extension.

```text
.yc source
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
├─ Language
│  ├─ static types
│  ├─ slices
│  ├─ structs
│  └─ modules
├─ Compiler
│  ├─ C++20
│  ├─ LLVM
│  └─ project builds
├─ Standard library
│  ├─ std/fmt
│  ├─ std/array
│  ├─ std/mem
│  └─ std/json
└─ Tooling
   ├─ VSCode
   ├─ native LSP
   └─ regression examples
```

## Current Shape

```text
Repository
├─ src/             lexer, parser, AST, resolver, codegen
├─ cli/ycc/         command-line compiler
├─ stl/std/         YCPL standard library modules
├─ examples/        .yc smoke/regression programs
├─ tools/lsp/       LSP written in YCPL
├─ editors/vscode/  language extension
└─ docs/            English/Japanese documentation
```

| Area | Status |
|---|---|
| Stability | Very early alpha, not production-ready |
| Source extension | `.yc` |
| Build output | LLVM IR (`.ll`) |
| Project config | `YCPL.json` |
| Compiler binary | `ycc` |

## Build

```text
Developer
   |
   | cmake -DLLVM_DIR=/path/to/llvm ..
   v
CMake ---- locates ----> LLVM 18+
   |
   | make
   v
build/ycc
```

```sh
mkdir build
cd build
cmake -DLLVM_DIR=/your/llvm/path/cmake ..
make
```

## Compile

```text
Single file:
  examples/01_hello.yc -> build/ycc -> LLVM IR

Project:
  YCPL.json -> scan src/*.yc -> build/ycc build -> LLVM IR
```

```sh
build/ycc examples/01_hello.yc -o /tmp/ycpl_hello
cd examples/04_module_project && ../../build/ycc build
```

## Language Snapshot

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

## Docs

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

- [Language syntax](docs/language.en.md)
- [Projects and modules](docs/projects.en.md)
- [Standard library](docs/stdlib.en.md)
- [Implementation status](docs/status.en.md)
- [YCPL LSP](tools/lsp/README.md)

## Editor And LSP

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

## Test Map

```text
examples/run_tests.sh
├─ single-file positive tests
├─ project builds
├─ expected compile failures
└─ expected runtime failures
```

```sh
examples/run_tests.sh
```
