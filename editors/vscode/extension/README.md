# YCPL for Visual Studio Code

YCPL 0.4 provides editing, project tasks, Test Explorer, coverage and native debugging.
[日本語ガイド](https://github.com/james-yusuke/YCPL/blob/main/docs/editor.ja.md)

## Setup

Install LLVM 22 and build the self-hosted `ycc`. Set `YCPL.compiler.path` to that
executable; bootstrap executables are excluded from automatic discovery. Configure
`YCPL.stlRoot` and `YCPL.runtimeSource` when working outside the YCPL repository.
**YCPL: Show Environment** displays the selected paths; **Configure Compiler** opens
an executable picker. Compiler execution requires a trusted workspace.

The bundled TypeScript language server is the default. It provides the complete
editing and refactoring features below. `YCPL.server.mode = auto` checks a configured
`YCPL.server.path`, workspace `tools/lsp/build/YCPL-lsp`, then `PATH`, and falls back
to TypeScript if the native server cannot initialize. `native` requires that server.
The native server provides the common protocol features; advanced extraction and
import actions use the TypeScript server. The status bar shows the active server.
Settings changes and **Restart Language Server** restart it safely.

## Editing and projects

| Area | YCPL support |
|---|---|
| IntelliSense | Completion, stdlib auto imports, signatures, hover, snippets, semantic highlighting |
| Navigation | Definition, declaration, type definition, references, rename, workspace/document symbols, call hierarchy, highlights, reference lenses |
| Formatting | Document and range formatting; preserves multiline raw strings, nested comments and character literals; format on save |
| Imports | Add Import, Organize Imports, remove unused aliases, organize on save; preserves attached comments and side-effect imports |
| Refactoring | Extract expression to variable, extract whole statements to function with pointer captures, inline a constant literal, fill an empty struct with primitive fields |
| Diagnostics | Parser diagnostics while editing; real compiler diagnostics on save and Check; task problem matcher |
| Projects | New Project, local playground, `YCPL.json` completion/validation, multi-root indexing, check/build/build-ir/run tasks |
| Code generation | Generate Tests creates visible TODOs that return false; Toggle Test File switches implementation and test |

Refactorings are offered only where the current resolver can preserve semantics.
Extraction rejects control-flow exits and escaping locals; inlining rejects mutable
or nonliteral initializers. Rename rejects keywords, invalid names and collisions.
Go interface implementation and struct-tag rewriting do not have equivalents in
YCPL's current language. YCPL has no Go module/package vulnerability database.

Build commands use `.ycpl/build` unless `YCPL.outputDirectory` is configured. A
parent `YCPL.json` selects project mode. **Open Local Playground** creates an isolated
source under `.ycpl/playground`, even inside a project. **Run** opens a terminal
with the compiled executable; `YCPL.run.arguments` is passed literally. Interactive
input works. Build, check, test and profile operations support cancellation.

## Tests, benchmarks and property checks

Put public boolean functions in `*_test.yc`:

```yc
import "./math.yc" as math

pub fn test_add() bool { return math.add(20, 22) == 42 }
pub fn benchmark_add() bool { return math.add(1, 2) == 3 }
pub fn fuzz_identity(seed i32) bool { return math.add(seed, 0) == seed }
```

Test Explorer discovers these signatures and provides Run, Debug and Coverage
profiles. Commands run the workspace, current file or function at the cursor;
Run Test lenses are clickable. True passes, false fails, build errors are reported
as errors, and cancelled tests are skipped. Generated runners use relative imports
and temporary per-run directories, which are removed afterwards.

`YCPL.testing.benchmarkIterations` controls benchmark repetitions. Timings report
real elapsed time and ns/op **including process startup**, without claiming
microbenchmark isolation. `fuzz_*` checks use consecutive deterministic i32 seeds;
`YCPL.testing.fuzzIterations` and `fuzzStartSeed` control them. Failures print the
seed for reproduction. These are seeded property checks, without a coverage-guided
mutation engine, corpus minimization or automatic input generation for other types.

Coverage uses LLVM's GCOV instrumentation and executed line counts. Test Explorer
shows covered/uncovered source lines in workspace files; helper functions reached
through imports are included. There is no guessed or synthetic coverage. LLVM 22
`opt`, `clang`, `llvm-cov` and the clang profile runtime must be installed.

## Debugging

**Debug Current File or Project**, F5, Debug Test at Cursor and Test Explorer Debug
use LLVM 22 `lldb-dap`. It is discovered from `LLVM_BINDIR`, LLVM installation paths
or `PATH`; set `YCPL.debug.adapterPath` to override. Builds use the self-hosted
compiler's `-g` flag and unoptimized LLVM code. Source breakpoints, stepping, stack
frames, parameters and local values are available. Structs carry field metadata;
recursive/managed containers currently expose their underlying handles rather than
Go-style collection visualizers. Debug objects are retained until the session ends.

```json
{
  "type": "ycpl",
  "request": "launch",
  "name": "YCPL: Debug",
  "program": "${file}",
  "args": ["literal argument"],
  "console": "integratedTerminal"
}
```

Existing native executables, `attach` by pid and LLDB `coreFile` configurations are
also supported. On Ubuntu install `lldb-22`; macOS Homebrew `llvm@22` includes the
adapter. Remote/container sessions use the workspace extension's execution host;
no remote deployment configuration is generated automatically.

## Profiling

- **Collect Execution Profile** instruments LLVM IR and opens exact function/block
  counts from `llvm-profdata`. This is not CPU or allocation sampling.
- **Collect CPU Samples** uses macOS `sample` for `YCPL.profiling.duration` seconds,
  then stops the owned target; Linux uses `perf record`/`perf report` until exit.
  Linux requires a kernel configuration that permits perf events.
- **Collect Memory Profile** uses macOS `leaks --atExit`, or Linux Valgrind Massif
  with `ms_print`. Install these system tools before using the command.

Reports and raw data are retained under `.ycpl/profiles`. Program arguments and
compiler environment overrides apply to every profile. Process output is bounded,
commands never pass through a shell, and cancellation terminates owned children.

## Build and reverify

From the repository root:

```sh
eval "$(scripts/setup-llvm.sh 22 --print-env)"
npm ci --prefix editors/vscode/language-server
npm ci --prefix editors/vscode/extension
npm run check --prefix editors/vscode/language-server
npm run check --prefix editors/vscode/extension
YCC="$PWD/bazel-bin/ycc" tests/test_development_workflows.sh
tools/lsp/run_tests.sh
npm run test:extension --prefix editors/vscode/extension
npm run test:extension:native --prefix editors/vscode/extension
npm run check-package --prefix editors/vscode/extension
```

Use `npm run format --prefix editors/vscode/extension` to apply the checked
Prettier configuration. The VSIX at `editors/vscode/extension/artifacts/ycpl-vscode.vsix`
contains both JavaScript bundles, grammar, snippets and project schema, without
source, tests or node_modules. Integration tests extract that VSIX and exercise
actual test success/failure, coverage, profiles and an LLDB source breakpoint.
Set `YCPL_TEST_COMPILER` to another self-hosted compiler and
`VSCODE_EXECUTABLE_PATH` to a local VS Code executable to reuse installations.
CI runs the packaged workflows on macOS and Ubuntu.
