# YCPL

[日本語](README-JA.md) | [English docs](docs/README.en.md) | [日本語 docs](docs/README.ja.md)

YCPL is an experimental systems-programming language with a C++ compiler,
LLVM backend, statically linked managed runtime, bundled YCPL standard library,
examples, and a YCPL-written LSP.
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
                                           native binary + YCPL runtime
```

```text
YCPL
├─ Language
│  ├─ static types
│  ├─ slices
│  ├─ structs
│  ├─ owned / defer / scope / UFCS sugar
│  └─ modules
├─ Compiler
│  ├─ C++20
│  ├─ LLVM
│  └─ project builds
├─ Standard library
│  ├─ std/fmt
│  ├─ std/array
│  ├─ std/mem managed allocator
│  ├─ std/json
│  └─ std folder modules
├─ Runtime
│  ├─ static yc_runtime object
│  ├─ function-frame cleanup
│  └─ array/map/bytes/text/json child destructors
└─ Tooling
   ├─ VSCode
   ├─ native LSP
   └─ regression examples
```

## Current Shape

```text
Repository
├─ bootstrap/cpp/   C++ bootstrap compiler, with src/cli and split codegen subsystems
├─ compiler/ycpl/   YCPL-written compiler, lex/parse milestone
├─ bootstrap/cpp/runtime/ static managed allocation runtime linked into native outputs
├─ stl/std/         YCPL standard library modules
├─ examples/        .yc smoke/regression programs
├─ tools/lsp/       LSP written in YCPL
├─ editors/vscode/  VS Code extension and TypeScript LSP packages
└─ docs/            English/Japanese documentation
```

| Area | Status |
|---|---|
| Stability | Very early alpha, not production-ready |
| Source extension | `.yc` |
| Build output | Native binary via `ycc build`; LLVM IR via `ycc build-ir`; build-and-run via `ycc run` |
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
  examples/01_hello.yc -> ycc run -> native binary, then execute it
  examples/01_hello.yc -> ycc build-ir -> LLVM IR

Project:
  YCPL.json -> scan src/**/*.yc deterministically -> ycc build -> native binary
  YCPL.json -> scan src/**/*.yc deterministically -> ycc build-ir -> LLVM IR
```

```sh
bazel run //:ycc -- build examples/01_hello.yc -o /tmp/ycpl_hello
bazel run //:ycc -- run examples/01_hello.yc -o /tmp/ycpl_hello
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
   ├─ emits LLVM IR for i32 main, C-style main(argc i32, argv *string), locals, assignments, zero-through-eight-argument helper/extern calls, arithmetic, and returns
   ├─ predeclares function signatures so main can call helpers defined later in the file
   ├─ builds that subset to native binary without bootstrap ycc
   ├─ parses/checks compiler/ycpl by traversing src/**/*.yc
   ├─ tracks function-name digest and main presence from project AST
   ├─ stores parser-owned body statement node arenas in ast/body and parser/body
   ├─ tracks body node transition digest and local/assign/call/return edges
   ├─ lowers body if/for node counts into LLVM C API conditional and loop blocks
   ├─ tracks function-body token/digest summaries for local/call/control-flow structure
   ├─ tracks return-expression counts and digest from function bodies
   ├─ emits local/assignment/call/return node probe IR through std/llvm C API wrappers
   ├─ emits project statement/expression lowering IR through std/llvm C API wrappers
   ├─ dispatches local/assignment/call/return body nodes into dedicated alloca/load/store/call lowering
   ├─ folds lowered local/assignment/call/return node state back into each generated function-body return value
   ├─ lowers semantic roles into symbol-env, value-state, control-state, assignment/call/return value-flow IR
   ├─ lowers compiler/ycpl parser body arenas for per-function slots and all-function aggregate data into LLVM alloca/call/branch/loop IR
   ├─ gates per-function body slot table counts, max size, and digest in parse/check and generated IR
   ├─ tracks identifier/literal/type/control payload tables from parser-owned body-node arenas
   ├─ tracks semantic role tables for local symbols, assignment targets, call targets, return symbols/literals, type refs, and control refs
   ├─ builds declaration/import/module symbol summaries for functions, structs, std imports, aliases, visibility, and digests
   ├─ cross-checks function signature and call-site arity summaries against parser counts and stores them in generated IR
   ├─ stores parser-owned semantic node tables for function signatures and call sites
   ├─ stores parser-owned expression node tables for primary/call/member/index/binary/unary expressions
   ├─ cross-checks expression node tables against parser expression, call, member, and index counts
   ├─ tracks per-function expression slot counts, max slot size, and digest from parser-owned expression tables
   ├─ feeds per-function expression tables into function body LLVM lowering
   ├─ dispatches identifier/literal/call/member/index/binary/unary expression nodes into dedicated LLVM lowering paths
   ├─ preserves binary operator tags and lowers add/sub/mul/div/rem/compare nodes through LLVM arithmetic/comparison wrappers
   ├─ accumulates expression node value-state and folds it into the function-body environment lowering
   ├─ feeds expression value-state back into assignment, return, and body value-state lowering
   ├─ lowers per-function expression nodes from statement-owned body-node counts before finishing tail expressions
   ├─ exposes parser-owned statement-expression link counts, tail expression counts, and digest through project parse/check and generated IR gates
   ├─ records else/break/continue/for-in body nodes and lowers them through control-surface LLVM wrapper paths
   ├─ lowers an expanded per-function expression node sequence into project_body.ll with a 1024-node cap instead of only tiny representative samples
   ├─ carries the 600+ expression lowering floor into generated stage2/stage3 IR self-checks
   ├─ emits per-function LLVM lowering functions for the first sixty-four compiler/ycpl function bodies
   ├─ emits range bucket LLVM lowering for compiler/ycpl function bodies 0 through 447
   ├─ emits individual per-function LLVM lowerers beyond the first 64, including ycpl_project_function_body_400
   ├─ lowers variable-length body-node arenas with metadata/source positions, payload tables, and semantic roles into node-sequence LLVM IR blocks
   ├─ lowers zero-argument i32 constant-return functions from compiler/ycpl sources
   ├─ emits project LLVM IR for compiler/ycpl with YCPL_NO_BOOTSTRAP=1
   ├─ builds that project AST IR to a native smoke binary without bootstrap ycc
   ├─ generated stage2 binary supports parse/check/build-ir compiler/ycpl
   ├─ generated stage2 binary can build native stage3 compiler-smoke output
   ├─ generated stage3 binary supports parse/check/build-ir/build compiler/ycpl and emits stage4 LLVM IR/native output
   ├─ generated stage4 binary supports parse/check/build-ir/build compiler/ycpl and emits stage5 LLVM IR/native output
   ├─ generated stage3 binary lowers tiny arithmetic, call/assignment, control-flow, else/helper, one-argument i32 helper-call, multi-helper chain, two-argument helper-call, and forward helper-call inputs to distinct IR/native output by source content
   ├─ generated stage2 binary lowers tiny arithmetic, call/assignment, control-flow, else/helper, one-argument i32 helper-call, multi-helper chain, two-argument helper-call, and forward helper-call inputs to distinct IR by source content
   ├─ generated stage2/stage3 binaries reject unsupported file build-ir inputs instead of returning project compiler IR
   └─ delegates unsupported build/build-ir inputs to bootstrap ycc
```

```text
compiler/ycpl
├─ src/ast       tagged structs with kind i32 and body node sequence records
├─ src/checker   tiny i32 typed subset gate and project AST gate
├─ src/codegen   LLVM C API tiny statement IR, node IR, and project AST IR emission
├─ src/driver    self-native build and bootstrap stage driver
├─ src/lexer     token stream, nested comments, string/char checks
├─ src/parser    current grammar surface, body node extraction, recovery diagnostics
├─ src/resolver  YCPL.json project root and nested src/**/*.yc traversal
└─ src/source    bounded file loading
```

```sh
bazel-bin/ycc-ycpl lex examples/01_hello.yc
bazel-bin/ycc-ycpl parse examples/01_hello.yc
bazel-bin/ycc-ycpl check examples/53_self_codegen_main.yc
bazel-bin/ycc-ycpl build-ir-self examples/53_self_codegen_main.yc -o /tmp/ycpl-self-tiny
bazel-bin/ycc-ycpl build examples/54_self_codegen_arithmetic.yc -o /tmp/ycpl-self-native
bazel-bin/ycc-ycpl build examples/56_self_codegen_call_assignment.yc -o /tmp/ycpl-self-call
bazel-bin/ycc-ycpl build examples/57_self_codegen_control_flow.yc -o /tmp/ycpl-self-control
bazel-bin/ycc-ycpl build examples/58_self_codegen_else_helper.yc -o /tmp/ycpl-self-else
bazel-bin/ycc-ycpl build examples/59_self_codegen_param_call.yc -o /tmp/ycpl-self-param
bazel-bin/ycc-ycpl build examples/60_self_codegen_helper_chain.yc -o /tmp/ycpl-self-chain
bazel-bin/ycc-ycpl build examples/61_self_codegen_two_arg_call.yc -o /tmp/ycpl-self-twoarg
bazel-bin/ycc-ycpl build-ir-self examples/99_self_codegen_main_args.yc -o /tmp/ycpl-self-main-args
bazel-bin/ycc-ycpl build examples/62_self_codegen_forward_call.yc -o /tmp/ycpl-self-forward
bazel-bin/ycc-ycpl parse compiler/ycpl
bazel-bin/ycc-ycpl check compiler/ycpl
bazel-bin/ycc-ycpl build-ir compiler/ycpl -o /tmp/ycpl-self-ir
# also writes /tmp/ycpl-self-ir/local_return.ll via std/llvm and merges its node probe into merged.ll
bazel-bin/ycc-ycpl build compiler/ycpl -o /tmp/ycpl-self-native
YCPL_NO_BOOTSTRAP=1 bazel-bin/ycc-ycpl build-ir compiler/ycpl -o /tmp/ycpl-strict
YCPL_NO_BOOTSTRAP=1 bazel-bin/ycc-ycpl build compiler/ycpl -o /tmp/ycpl-strict-native
```

```text
stage-2 gate
├─ compiler/ycpl project parse/check is handled by ycc-ycpl
├─ nested source folders such as src/ast and src/codegen are discovered through src/**/*.yc traversal
├─ tiny arithmetic/call/control-flow/else-helper/helper-call/extern-call builds, including eight-argument calls, can run with YCPL_NO_BOOTSTRAP=1
├─ project build-ir runs without bootstrap fallback
├─ project build-ir emits local_return.ll and project_body.ll through LLVM C API wrappers
├─ merged.ll includes the LLVM-wrapper-generated node probe for local, assignment, call, return, transitions, and if/for control flow
├─ merged.ll calls LLVM-wrapper-generated project statement/expression lowering
├─ project_body.ll includes source-derived constant-return, parser-owned per-function slots, all-function body lowering, and metadata/payload/semantic-role-rich body-node arena lowering
├─ project_body.ll accumulates lowered local/assignment/call/return node state per function and returns it through function_body_lowered_total
├─ project_body.ll lowers semantic-role data into symbol environment, value state, control state, and assignment/call/return value-flow IR
├─ project parse/check and generated IR now gate declaration/import/module symbol table summaries
├─ project parse/check and generated IR gate parser-owned expression node tables and digests
├─ project_body.ll lowers per-function expression slot metadata into LLVM-wrapper-generated IR
├─ project_body.ll now combines body-node lowering with per-function expression node/slot/digest lowering
├─ project_body.ll dispatches parser-owned expression node kinds into identifier/literal/call/member/index/binary/unary LLVM IR lowering
├─ project_body.ll lowers parser-owned binary operator tags into LLVM add/sub/mul/sdiv/srem/icmp instructions
├─ project_body.ll accumulates function_expr_value_state and folds function_expr_lowered_value_state into function_body_expr_value_environment
├─ project_body.ll lowers parser-owned else/break/continue/for-in control-surface nodes
├─ project_body.ll records function_expr_lowered_nodes and function_expression_sequence_lowered for the expanded 600+ node expression lowering sequence
├─ generated stage2/stage3 IR gates the expression lowering floor with ycpl_stage_expr_lowered_floor
├─ project_body.ll emits per-function lowerers ycpl_project_function_body_0 through ycpl_project_function_body_63 plus dynamic 64+ lowerers such as ycpl_project_function_body_400
├─ project_body.ll emits range bucket lowerers ycpl_project_function_body_range_0_63 through ycpl_project_function_body_range_384_447
├─ project_body.ll folds dynamic per-function calls through function_body_all_individual_lowered
├─ project parse/check emits typed AST shape counts and a typed digest from src/ast/shape.yc
├─ project AST IR contains function symbol, body node, expression-table, typed-AST, main-presence, and return-expression gates
├─ project AST IR can be lowered to a native smoke binary
├─ generated stage2 binary can emit stage3 LLVM IR
├─ generated stage2 binary can invoke llc/clang to build stage3 native output
├─ generated stage3 native output can parse/check compiler/ycpl and emit llc-valid stage4 IR/native output
├─ generated stage4 native output can parse/check compiler/ycpl and emit llc-valid stage5 IR/native output
├─ generated stage3 native output lowers tiny arithmetic, call/assignment, control-flow, else/helper, one-argument i32 helper-call, multi-helper chain, two-argument helper-call, and forward helper-call inputs to native exit code 13
├─ generated stage2/stage3 native output rejects unsupported file build-ir input instead of returning project compiler IR
├─ generated stage2 binary builds examples/54, examples/59, examples/60, examples/61, examples/62, and renamed copies to native exit code 13
└─ full compiler-equivalent build/native codegen remains the next stage
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
- [Contributing](CONTRIBUTING.md)
- [Security policy](SECURITY.md)

## Editor And LSP

```text
VSCode
  |
  v
editors/vscode/extension -- LSP --> editors/vscode/language-server
  |
  v
workspace index / diagnostics / symbols / semantic tokens
  |
  v
hover / completion / references / formatting / rename / code actions
```

```sh
npm ci --prefix editors/vscode/language-server
npm run check --prefix editors/vscode/language-server
npm ci --prefix editors/vscode/extension
npm run check --prefix editors/vscode/extension
```

The older YCPL-written protocol server remains under `tools/lsp/` and is still
covered by `tools/lsp/run_tests.sh`.

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
