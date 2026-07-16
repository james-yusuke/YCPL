# C++ Seed/Reference Codegen

The C++ backend is intentionally split along compiler subsystem boundaries.
Keep this layout so the seed/reference implementation remains easy to compare
with the self-hosted compiler in `compiler/ycpl`.

```text
core.cpp          LLVM module/builder setup, primitive LLVM helpers, IR output
scope.cpp         local symbol/type/const lookup and expression type hints
dispatch.cpp      AST expression/statement dispatch
pipeline.cpp      program-level generation order and LLVM verification
codegen.cpp       includes header-defined subsystem implementations once
internal/         private bootstrap-only include glue

arrays/           array header layout, checked element access, literals, append, std/array intrinsics
assignment/       assignment and compound assignment
branches/         if/else branch lowering
expressions/      unary/binary expression lowering
formatting/       print/println/printf/sprintf intrinsics
functions/        function signatures and function body lowering
literals/         literals, identifiers, byte arrays
loops/            for and for-in lowering
postfix/          postfix expression lowering
runtime/          std mem/str/math intrinsics, casts, len/new, lazy C declarations
structures/       struct types, literals, member access
types/            type-name shape helpers shared by codegen domains
variables/        variable declaration and type name lowering
```

File names should describe the lowering role (`if_stmt.h`, `array_literal.h`,
`index_value.h`, `index_address.h`, `type_resolver.h`, `c_symbols.h`) rather
than mirror token names or grammar keywords. Shared runtime mechanics should
live in named helpers: `formatting/print.h` owns `fmt.print`, `runtime/value_casts.h` owns LLVM value coercions,
`arrays/access.h` owns `YCPLArrayHeader` pointer/field/bounds-check operations,
`arrays/index_value.h` and `arrays/index_address.h` split expression reads from
assignable-address lowering, `arrays/std_intrinsics.h` owns `std/array` calls, and
`runtime/memory_intrinsics.h`, `runtime/string_intrinsics.h`, and
`runtime/math_intrinsics.h` own their matching `std` domains. `types/type_shape.h`
owns lightweight type-name suffix parsing. This keeps the C++ reference
implementation easy to compare with the equivalent YCPL AST lowering.

`runtime/c_symbols.h` must remain lazy: declare C/LLVM-facing symbols only when
the AST actually calls them. Native linking should continue to rely on the CLI's
`LLVM_CONFIG` / `LLVM_BINDIR` / `LLC` / `CLANG` discovery rather than mutating
`/usr` or hard-coding system paths.
