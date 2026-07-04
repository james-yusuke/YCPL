# C++ Bootstrap Codegen

The C++ backend is intentionally split by migration boundary. Keep this layout
while `compiler/ycpl` ports the compiler one subsystem at a time.

```text
core.cpp          LLVM module/builder setup, primitive LLVM helpers, IR output
scope.cpp         local symbol/type/const lookup and expression type hints
dispatch.cpp      AST expression/statement dispatch
pipeline.cpp      program-level generation order and LLVM verification
codegen.cpp       includes header-defined subsystem implementations once
internal/         private bootstrap-only include glue

arrays/           array header layout, checked element access, literals, append
assignment/       assignment and compound assignment
branches/         if/else branch lowering
expressions/      unary/binary expression lowering
formatting/       print/format intrinsics
functions/        function signatures and function body lowering
literals/         literals, identifiers, byte arrays
loops/            for and for-in lowering
postfix/          postfix expression lowering
runtime/          std intrinsics and lazy C function declaration
structures/       struct types, literals, member access
types/            type-name shape helpers shared by codegen domains
variables/        variable declaration and type name lowering
```

File names should describe the lowering role (`if_stmt.h`, `array_literal.h`,
`index_value.h`, `index_address.h`, `type_resolver.h`, `c_symbols.h`) rather
than mirror token names or grammar keywords. Shared runtime mechanics should
live in named helpers: `runtime/value_casts.h` owns LLVM value coercions,
`arrays/access.h` owns `YCPLArrayHeader` pointer/field/bounds-check operations,
`arrays/index_value.h` and `arrays/index_address.h` split expression reads from
assignable-address lowering, and
`types/type_shape.h` owns lightweight type-name suffix parsing. This keeps the C++
bootstrap easy to compare with the YCPL self-host modules as they gain
equivalent AST lowering.

`runtime/c_symbols.h` must remain lazy: declare C/LLVM-facing symbols only when
the AST actually calls them. Native linking should continue to rely on the CLI's
`LLVM_CONFIG` / `LLVM_BINDIR` / `LLC` / `CLANG` discovery rather than mutating
`/usr` or hard-coding system paths.
