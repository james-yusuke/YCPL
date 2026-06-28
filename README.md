# YCPL

**YCPL is a new programming language designed for system programming.**

## Project Highlights

- **LLVM-based**  
  YCPL employs LLVM as its backend, enabling state-of-the-art optimization and multi-platform support.
- **Not Even Beta Yet**  
  This project is in a very early alpha phase and hasn't reached beta status. It is not stable, not for production use, and may undergo significant design and syntax changes.
- **For System Programming**  
  Its primary target is low-level development, such as OS, compilers, and middleware, valuing performance, powerful type representation, and low-level access.

## Design Details

- **Modern Syntax**  
  The syntax is influenced by C-family languages, Go, and Rust.
- **Type System**  
  Statically typed with partial type inference. Structs, pointers, slice arrays, and function types are supported.
- **LLVM IR Generation**  
  The compiler produces LLVM IR from its AST, which can then be compiled for various architectures.
- **CLI / Toolchain**  
  The `ecc` command builds `.ec` files or entire project directories (generating combined LLVM IR). More build options and output targets are planned for the future.

## Dependencies & Building

- **CMake Build System**
- **LLVM 18 or newer recommended**
- A `Dockerfile` is provided for an easy build environment (Ubuntu + LLVM 18 + required dev packages).
- A `.devcontainer/` setup is provided for containerized development with LLVM 18 and Git over SSH.

```sh
# Minimal build procedure
$ mkdir build
$ cd build
$ cmake -DLLVM_DIR=/your/llvm/path/cmake ..
$ make
```

## Project Layout

- `src/` ... Lexical analysis (lexer), parser, AST, and LLVM codegen
- `cli/` ... Command-line interface implementation
- `stl/std/` ... Bundled YCPL source standard library modules
- `tools/lsp/` ... YCPL-authored LSP v0.4 source, build script, and fixtures
- `editors/vscode/` ... VSCode language contribution, snippets, and LSP launcher
- `docs/` ... Current language syntax, project/module rules, and implementation status
- `examples/` ... Executable examples and regression smoke tests
- `tests/` ... (planned for future)

## Language Documentation

The current supported syntax is documented in `docs/`:

- `docs/language.md` ... Syntax, types, statements, expressions, and builtins
- `docs/projects.md` ... Project layout, `YCPL.json`, modules, and imports
- `docs/stdlib.md` ... `std/fmt`, `std/array`, `std/mem`, `std/str`, `std/math`, and LSP foundation modules
- `docs/status.md` ... Stable, experimental, and reserved syntax

## Current Foundation

- Alias-qualified modules: `import "std/fmt" as fmt`, then `fmt.println(...)`
- Manual memory and mutable runtime slices through `std/mem` and `std/array`
- YCPL source standard library modules in `stl/std`, with a small compiler
  intrinsic bridge for formatting, runtime slices, and `mem.sizeof(Type)`
- Example regression suite with exact stdout checks and expected-failure tests
  (`examples/run_tests.sh`, currently 52 cases)
- YCPL-authored LSP v0.4 native server with JSON-RPC framing, full-text
  document sync, syntax diagnostics, hover, snippet completion,
  documentSymbol, semantic tokens, formatting, folding, signature help,
  definition/declaration, type definition, references, document highlight,
  prepareRename, rename, selection range, workspace symbol, and VSCode launcher
  files for Remote Dev Container usage

## VSCode LSP

The supported editor path is VSCode Remote Dev Containers. Open the repository
inside the devcontainer, let `postCreateCommand` install the extension
dependencies, then build or auto-build the native server:

```sh
tools/lsp/build.sh
```

The VSCode extension lives in `editors/vscode`. By default it resolves
`${workspaceFolder}/tools/lsp/build/YCPL-lsp` and can run `tools/lsp/build.sh`
on activation when no explicit `YCPL.server.path` is configured. A Linux LSP
binary built in the devcontainer cannot be launched directly by a macOS host
VSCode extension host; use Remote Containers or set `YCPL.server.path` to a
host-native binary.

Quick editor smoke test:

1. Open this repository with **Dev Containers: Reopen in Container**.
2. Run `npm ci --prefix editors/vscode`,
   `bash .devcontainer/install-vscode-extension.sh`, and `tools/lsp/build.sh`.
3. Run **Developer: Reload Window** so the Remote Container extension host
   rescans the linked local YCPL extension.
4. Open an `.ec` file, confirm the bottom-right language mode says `YCPL`, and
   check syntax colors, semantic colors, snippets
   (`main` then Tab), hover, completion, format document, folding, go to
   definition/declaration, go to type definition, find references, workspace
   symbol, rename symbol, and diagnostics.
5. For protocol regression, run `tools/lsp/run_tests.sh`.

---

If you need more details about syntax, the type system, roadmap, or how to contribute, let me know!
