# YCPL C++ Bootstrap

This directory contains the C++ seed and reference compiler. The standard
compiler is the self-hosted implementation in `compiler/ycpl`; Bazel exposes
this C++ implementation as `ycc-bootstrap` for stage1 generation and
differential verification.

## Layout

```text
src/cli/        ycc command-line driver and thin executable entry point
src/lexer/      tokenization
src/parser/     recursive-descent parser
src/ast/        AST data structures and debug printer
src/module/     YCPL.json loading, module resolution, and project linking
src/codegen/    LLVM IR generation, split into core/scope/dispatch/pipeline
```

The `ycc-bootstrap` entry point is wired through `src/cli/ycc.cpp`, which only
calls `ycpl::bootstrap_cli::run_ycc`. Keep command-line behavior there, and keep
compiler pipeline logic in the narrower lexer/parser/module/codegen areas so
the reference implementation remains reviewable and useful for differential
testing.

`src/codegen` follows the same rule: `core.cpp`, `scope.cpp`, `dispatch.cpp`,
and `pipeline.cpp` contain the stable backend shell, while feature-specific
lowering stays in clearly named subdirectories such as `expressions`,
`arrays`, `types`, `structures`, and `runtime`.

Array lowering uses explicit role names because it is one of the trickiest
pieces to port:

- `arrays/layout.h`: the in-memory `YCPLArrayHeader` shape.
- `arrays/access.h`: header normalization, bounds checks, and element data
  pointer calculation.
- `arrays/index_value.h`: `a[i]` as an expression value.
- `arrays/index_address.h`: `a[i]` as an assignable address.
- `arrays/append_intrinsic.h`: `array.append` growth and element copy lowering.

## LLVM Policy

The C++ seed/reference compiler must not mutate `/usr` or system paths. Native builds
should discover LLVM tools in this order:

1. Explicit environment variables such as `LLVM_CONFIG`, `LLVM_BINDIR`, `LLC`,
   and `CLANG`.
2. Package-manager prefixes such as Homebrew and distro LLVM directories.
3. The regular `PATH` as a last resort.

When generated IR references the LLVM C API, `llvm-config` is used to collect
linker flags instead of hard-coding system library paths.
