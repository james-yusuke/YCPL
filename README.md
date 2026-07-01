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
                                                               |
                                                               v
                                                        native binary
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
| Build output | Native binary via `ycc build`; LLVM IR via `ycc build-ir` |
| Project config | `YCPL.json` |
| Compiler binary | `ycc` |

## Build

```text
Developer
   |
   | bazel build //:ycc
   v
Bazel ---- configures ----> LLVM 22 via llvm-config
   |
   v
bazel-bin/ycc
```

```sh
eval "$(scripts/setup-llvm.sh 22 --print-env)"
bazel build //:ycc
bazel test //...
```

`scripts/setup-llvm.sh` does not create `/usr` or `/usr/local` symlinks. It
prints `LLVM_CONFIG`, `LLVM_BINDIR`, `LLVM_DIR`, and a PATH prefix instead.
This keeps Ubuntu, Docker, and macOS arm/Homebrew installs separate from system
tooling. The Bazel and CMake builds link against the LLVM library directory
reported by `llvm-config` and add that directory to the build rpath, so LLVM
shared libraries do not need to be copied or linked into `/usr`.

This follows the same practical model used by Odin: prefer an explicit
`LLVM_CONFIG`, detect package-manager LLVM installs, and avoid requiring users
to mutate global system paths.

CMake is still available when LLVM 22 is installed on the system:

```sh
cmake -S . -B build
cmake --build build
```

For explicit paths:

```sh
LLVM_CONFIG=/opt/homebrew/opt/llvm@22/bin/llvm-config bazel build //:ycc
LLVM_DIR=/opt/homebrew/opt/llvm@22/lib/cmake/llvm cmake -S . -B build
```

## Compile

```text
Single file:
  examples/01_hello.yc -> ycc build -> native binary
  examples/01_hello.yc -> ycc build-ir -> LLVM IR

Project:
  YCPL.json -> scan src/*.yc -> ycc build -> native binary
  YCPL.json -> scan src/*.yc -> ycc build-ir -> LLVM IR
```

```sh
bazel run //:ycc -- build examples/01_hello.yc -o /tmp/ycpl_hello
bazel run //:ycc -- build-ir examples/01_hello.yc -o /tmp/ycpl_hello
cd examples/04_module_project && ../../bazel-bin/ycc build
```

## LLVM C API From YCPL

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

Programs importing `std/llvm` can call LLVM's C API directly. `ycc build`
auto-links LLVM when generated IR references `LLVM...` symbols; `--link-llvm`
is available when you want to force that path.

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
