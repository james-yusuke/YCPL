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
├─ bootstrap/cpp/   C++ bootstrap compiler implementation
├─ compiler/ycpl/   YCPL-written compiler, lex/parse milestone
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
| Compiler binaries | `ycc` bootstrap, `ycc-ycpl` self-hosting compiler in progress |

## Build

```text
Developer
   |
   | bazel build //:ycc //:ycc-ycpl
   v
Bazel ---- configures ----> LLVM 22 via llvm-config
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

## Self Hosting

```text
Transition
├─ ycc
│  ├─ C++ bootstrap compiler
│  ├─ builds native binaries and LLVM IR
│  └─ remains the default compiler
└─ ycc-ycpl
   ├─ written in YCPL
   ├─ lexes and parses YCPL sources
   ├─ type-checks a tiny self-codegen subset
   ├─ emits LLVM IR for i32 main, locals, assignments, arithmetic
   ├─ builds that subset to native binary without bootstrap ycc
   ├─ parses/checks compiler/ycpl as an explicit project source set
   ├─ emits project LLVM IR for compiler/ycpl with YCPL_NO_BOOTSTRAP=1
   ├─ builds that project AST IR to a native smoke binary without bootstrap ycc
   └─ delegates unsupported build/build-ir inputs to bootstrap ycc
```

```text
compiler/ycpl
├─ source  bounded file loading
├─ diag    file/line/column diagnostics
├─ lexer   token stream, nested comments, string/char checks
├─ ast     tagged structs with kind i32
├─ parser  current grammar surface and recovery diagnostics
├─ checker tiny i32 typed subset gate and project AST gate
├─ irgen   LLVM C API IR emission and project AST IR emission
├─ driver  self-native build and bootstrap stage driver
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
├─ compiler/ycpl project parse/check is handled by ycc-ycpl
├─ tiny arithmetic build can run with YCPL_NO_BOOTSTRAP=1
├─ project build-ir runs without bootstrap fallback
├─ project AST IR can be lowered to a native smoke binary
└─ compiler-equivalent native ycc-ycpl remains the next stage
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

bazel test //:ycc_ycpl_test
├─ ycc-ycpl lex smoke test
├─ all non-failure examples parse
└─ stable lexer/parser diagnostics for malformed fixtures
```

```sh
bazel test //:examples_test //:lsp_protocol_test //:ycc_ycpl_test
```
