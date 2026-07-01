# Claude Notes

This repository contains the YCPL compiler, standard library, examples, LSP,
and editor integrations.

## Common commands

```sh
cmake -S . -B build -DLLVM_DIR=/usr/lib/llvm-18/cmake
cmake --build build
examples/run_tests.sh
npm ci --prefix editors/vscode
npm run check --prefix editors/vscode
tools/lsp/run_tests.sh
```

## Project conventions

- Source files use `.yc`.
- The bundled standard library lives under `stl/std`.
- `stl/c` is reserved for future C runtime work and should stay untouched
  unless requested.
- Editor integrations live under `editors`.
- Pull requests should pass the GitHub Actions CI workflow before merge.
