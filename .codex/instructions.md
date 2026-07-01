# Codex Notes

Work on feature branches. For this task, use the `codex` branch.

## Build and test

Use the repository root as the working directory.

```sh
bazel build //:ycc
bazel test //...
cmake -S . -B build -DLLVM_DIR=/usr/lib/llvm-22/cmake
cmake --build build
examples/run_tests.sh
npm ci --prefix editors/vscode
npm run check --prefix editors/vscode
tools/lsp/run_tests.sh
```

The project targets LLVM 22. Use `scripts/setup-llvm.sh 22` on Ubuntu systems
to install apt.llvm.org packages and unversioned `clang`, `llc`, and
`llvm-config` shims. Bazel uses `llvm-config` to derive include and link flags.

## Guardrails

- Do not change `stl/c` unless the task explicitly asks for C runtime work.
- Keep generated build output out of commits.
- Prefer small changes that match the existing C++20 compiler, YCPL standard
  library, and editor support layout.
- Update examples or focused tests when compiler behavior changes.
