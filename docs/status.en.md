# Implementation Status

[日本語](status.ja.md) | [Docs index](README.en.md)

YCPL has reached a fully self-hosted fixed point. The standard `ycc` compiler
is implemented in YCPL. The C++ implementation remains as `ycc-bootstrap` for
the initial seed and differential verification only.

## Compiler Chain

```text
ycc-bootstrap (C++ seed/reference)
    -> ycc-stage1
    -> ycc-stage2
    -> ycc-stage3
    -> ycc
       └─ ycc-ycpl (compatibility alias)
```

- The C++ executable is called only to generate stage1.
- Build, check, and code generation from stage2 onward have no bootstrap fallback.
- `build-ir-self` is a deprecated alias of `build-ir`.
- LLVM 22, `llc`, `clang`, and the C runtime remain external foundations.

## Front End

- `ProgramAst` and `AstArena` are the only canonical AST representation.
- File IDs follow a stable sort of project-relative paths.
- Cross-file references retain file/node IDs and resolved symbol IDs.
- Source discovery follows symlinks with `stat` and prevents cycles with device/inode tracking.
- Locals, functions, arguments, and struct fields use dynamic arenas without the former fixed limits.
- Declarations, types, literals, operators, assignments, functions, structs, enums, aliases, pointers, slices, maps, ownership, defer, scope, switch, loops, UFCS, externs, intrinsics, and variadics are resolved on the real AST.

## LLVM Backend

- Named types, structs, functions, and externs are declared before bodies are lowered.
- Primitive, pointer, slice, struct, array, map, alias, and enum ABIs are supported.
- Resolved AST directly lowers short-circuit logic, bounds checks, break/continue, switch, LIFO defer, scope unwind, compound assignment, casts, UFCS, and variadic calls.
- Managed-allocation function/scope frames, escape, child ownership, and main initialization/shutdown are emitted by the compiler.
- Every generated module must pass the LLVM verifier.
- Fixture names, source digests, embedded stage IR, and large probe IR are not used to select generated programs.

## C API Boundary

Raw C and LLVM declarations live under `stl/c/*`. The compiler uses `c/llvm`,
`c/stdlib`, and `c/yc_runtime` for its external boundary. `stl/std/*` contains
language-level APIs.

## Driver

`ycc` supports `YCPL.json`, file and directory inputs, `build`, `build-ir`,
`run`, `debug`, `lex`, `parse`, `check`, `resolve`, `help`, `-o`, `--keep-obj`,
`--link-llvm`, and program arguments after `--`.

The runtime is resolved in this order:

1. `YCPL_RUNTIME_LIB`
2. `libyc_runtime.a` adjacent to the compiler executable
3. the development runtime selected by `YCPL_RUNTIME_SRC`

## Verification

- Reusable conformance harness: 70/70 cases
- All examples, stdlib, `c/*` FFI, projects/modules, and runtime ownership tests
- Negative exit classes, source locations, and diagnostic substrings
- Dynamic locals, functions, arguments, and struct fields
- The compiler itself, hello, compound stdlib examples, and the LSP protocol
- Exact stage2/stage3 equality after LLVM 22 canonicalization
- `bazel test //...`

The fixed-point test runs `llvm-as` and `llvm-dis`, then stabilizes only the
ModuleID, source filename, and output path metadata. Target triples, data
layouts, symbols, and instructions remain part of the comparison.

## Project Position

The language and toolchain remain early alpha. Reimplementing LLVM or the C
runtime in YCPL and expanding the LSP are outside this milestone. The C++
compiler remains as a seed/reference implementation, while normal `ycc`
operation is completed entirely by the YCPL implementation.
