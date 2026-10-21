# YCPL Use Cases and Local Verification

[日本語](usage.ja.md) | [Docs index](README.en.md)

YCPL combines LLVM 22 native code generation, a managed runtime, a standard library,
a self-hosted compiler, and an LSP. Small local command-line tools and data
transformations are useful first projects.

| Use case | Available implementation | Starting point |
|---|---|---|
| Inspect or aggregate JSON configuration | `std/json`, `std/fs`, `std/text`, `Vec<T>` | `examples/stdlib/foundation.yc`, `json.yc` |
| Transform text and bytes | UTF-8, hex, base32/base64, bytes | `examples/stdlib/encoding.yc`, `bytes_hex_hash.yc` |
| Build a multi-file CLI | `YCPL.json`, modules/imports, process argument APIs | `examples/projects/module_project/`, `stl/std/os/index.yc` |
| Study compilers and language tools | AST, type resolution, LLVM lowering, fixed-point comparison, LSP | `compiler/ycpl/`, `tools/lsp/` |

Check required APIs and failure behavior before building a network service or
deploying to production. YCPL is early alpha; compatibility and memory-safety
guarantees are still evolving. Raw pointers and `c/*` require C-level care.

## Run Local Verification

Install LLVM 22, CMake, a C/C++ compiler, Node.js, npm, and Python 3. Install the
editor dependencies from their lockfiles once:

```sh
npm ci --prefix editors/vscode/language-server
npm ci --prefix editors/vscode/extension
scripts/verify-local.sh
```

The script builds the C++ seed through CMake, checks the runtime with AddressSanitizer
and UndefinedBehaviorSanitizer, runs seed conformance, builds stages 1–3, compares
stage2/stage3 LLVM IR exactly, and runs conformance with both stages. It also tests
the LSPs, packages and inspects the VSIX, and finally builds and runs Hello World.
It reuses the same fixed-point oracle as Bazel.

On a desktop, also load the packaged VSIX into VS Code for integration tests:

```sh
YCPL_VERIFY_VSCODE_GUI=1 scripts/verify-local.sh
```

Version resolution and downloading the test version of VS Code require network access.
To repeat the dependency advisory checks with network access:

```sh
npm audit --prefix editors/vscode/language-server
npm audit --prefix editors/vscode/extension
```

See `.github/workflows/ci.yml` for Linux linker and POSIX settings. Explicit
`LLVM_CONFIG`, `CLANG`, `LLC`, and `LINKFLAGS` overrides are preserved.

## Use the Verified Compiler

The self-hosted executable is `build/local-verification/stage3/merged`:

```sh
build/local-verification/stage3/merged run examples/stdlib/foundation.yc -o build/demo-foundation
build/local-verification/stage3/merged run examples/stdlib/encoding.yc -o build/demo-encoding
build/local-verification/stage3/merged run examples/projects/module_project -o build/demo-modules
```

The former `scope name { ... }` syntax has been removed. Replace it with an ordinary
`{ ... }` block, which still supports `defer` and managed temporary cleanup.
See `examples/basics/defer_blocks.yc`. The word `scope` is now an ordinary identifier.
