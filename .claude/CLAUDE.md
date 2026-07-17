# Claude Notes

This repository contains the YCPL compiler, standard library, examples, LSP,
and editor integrations.

## Skills

- Use `$ycpl-development` for YCPL language, compiler, runtime, stdlib, LSP,
  editor, and documentation implementation.
- Use `$ycpl-verification` for bootstrap/self-host builds, fixed-point checks,
  conformance, CI diagnosis, LSP protocol tests, and VSIX verification.

## Common commands

```sh
scripts/setup-llvm.sh 22
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

## Project conventions

- Source files use `.yc`.
- The bundled standard library lives under `stl/std`.
- Raw C, POSIX, runtime, and LLVM declarations belong in `stl/c`; high-level
  managed APIs belong in `stl/std`.
- Do not edit `PROJECT_STATUS.md` or `PROJECT_STATUS_JA.md` unless explicitly
  requested; they are personal project statements.
- Editor integrations live under `editors`.
- Pull requests should pass the GitHub Actions CI workflow before merge.
