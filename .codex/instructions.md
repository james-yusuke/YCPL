# Codex Notes

Work on feature branches. For this task, use the `codex` branch.

## Skills

- Use `$ycpl-development` for YCPL language, compiler, runtime, stdlib, LSP,
  editor, and documentation implementation.
- Use `$ycpl-verification` for bootstrap/self-host builds, fixed-point checks,
  conformance, CI diagnosis, LSP protocol tests, and VSIX verification.

## Build and test

Use the repository root as the working directory.

```sh
bazel build //:ycc
bazel test //...
cmake -S . -B build -DLLVM_DIR=/usr/lib/llvm-22/cmake
cmake --build build
examples/run_tests.sh
npm ci --prefix editors/vscode/language-server
npm run check --prefix editors/vscode/language-server
npm ci --prefix editors/vscode/extension
npm run check --prefix editors/vscode/extension
tools/lsp/run_tests.sh
```

The project targets LLVM 22. Use `scripts/setup-llvm.sh 22` on Ubuntu systems
to install apt.llvm.org packages and unversioned `clang`, `llc`, and
`llvm-config` shims. Bazel uses `llvm-config` to derive include and link flags.

## Guardrails

- Keep raw C, POSIX, runtime, and LLVM declarations in `stl/c`; change it only
  when the requested behavior crosses that ABI boundary.
- Keep high-level and managed APIs in `stl/std`.
- Do not edit `PROJECT_STATUS.md` or `PROJECT_STATUS_JA.md` unless explicitly
  requested; they are personal project statements.
- Keep generated build output out of commits.
- Prefer small changes that match the existing C++20 compiler, YCPL standard
  library, and editor support layout.
- Update examples or focused tests when compiler behavior changes.
