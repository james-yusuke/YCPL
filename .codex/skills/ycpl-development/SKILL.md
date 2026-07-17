---
name: ycpl-development
description: Implement and maintain the YCPL language, C++ seed compiler, self-hosted YCPL compiler, managed runtime, standard library, native/TypeScript LSPs, and VS Code extension. Use for changes to .yc syntax or semantics, compiler frontend/backend code, stl/std or stl/c APIs, ownership behavior, LLVM lowering, examples, diagnostics, editor tooling, or YCPL documentation.
---

# YCPL Development

Implement YCPL changes in the correct layer and keep the C++ seed and self-hosted compiler behavior aligned.

## Establish scope

Read the repository instructions and the smallest relevant source set before editing. Use these sources of truth:

- Language and grammar: `docs/language.ja.md`, `docs/language.en.md`, `docs/grammar/ycpl.ebnf`
- Managed ownership and `Vec<T>`: `docs/memory.ja.md`, `docs/memory.en.md`
- Self-host architecture: `docs/self-hosting.ja.md`, `docs/self-hosting.en.md`
- Standard library and C boundary: `docs/stdlib.ja.md`, `docs/stdlib.en.md`
- Project behavior: `docs/projects.ja.md`, `docs/projects.en.md`
- Test layout: `tests/README.md`

Do not edit `PROJECT_STATUS.md` or `PROJECT_STATUS_JA.md` unless the user explicitly asks; they are personal project statements.

## Choose the owning layer

- Put seed/reference parsing, checking, and LLVM lowering in `bootstrap/cpp`.
- Put the canonical compiler implementation in `compiler/ycpl`; `ProgramAst` and `AstArena` are the frontend representation.
- Put raw C, POSIX, runtime, and LLVM declarations in `stl/c`.
- Put safe language-level APIs and compatibility facades in `stl/std`.
- Put allocator implementation in `bootstrap/cpp/runtime`; do not expose manual `free` through new safe APIs.
- Prefer managed `Vec<T>`, `Bytes`, maps, strings, and Result types over direct `std/mem` use. Keep direct allocator use out of `compiler/ycpl`.
- Update both `tools/lsp` and `editors/vscode/language-server` when editor protocol behavior must match.
- Update the VS Code grammar and snippets when public syntax changes.

Only modify `stl/c` when the requested behavior crosses a raw ABI boundary. Do not place high-level helpers there.

## Implement language changes

For new or changed syntax and semantics:

1. Add the behavior to the C++ seed so it can produce the next compiler stage.
2. Add the same parse, resolution, type-check, and lowering behavior to `compiler/ycpl`.
3. Preserve the same public ABI and diagnostics across both implementations.
4. Add a focused positive, negative, or runtime fixture under `tests/fixtures` for subtle behavior.
5. Update grammar, language docs, LSP parsing/tokens, and snippets when user-visible syntax changes.

Never add a stage1-or-later fallback to `ycc-bootstrap`. The normal compiler must not recognize bootstrap routing variables or flags.

## Preserve compiler invariants

- Keep source, module, symbol, global, and block ordering deterministic.
- Avoid absolute workspace paths in meaningful IR.
- Verify every generated LLVM module.
- Implement C variadic default promotions: `bool` to zero-extended `i32`, narrow integers to `i32`, and `float` to `double`.
- Preserve managed ownership across return, assignment, aggregate fields, `defer`, `scope`, and loop unwind.
- Use `file_id + node_id` or resolved symbol IDs for cross-file references.
- Do not reintroduce fixed limits for locals, functions, arguments, fields, or AST nodes.
- Treat `[]T` as a non-growing view and `Vec<T>` as a managed shared handle.

## Maintain the standard library

- Keep each public module entry at `stl/std/<module>/index.yc`.
- Split distinct responsibilities into explicit import paths such as `std/json/scanner`; do not rely on implicit multi-file module merging.
- Preserve shipped compatibility APIs unless removal is explicitly requested, but exclude deprecated/raw APIs from new examples and completion lists.
- Return purpose-specific `{ ok, value, message }` results for new fallible APIs; include `offset` when parsing or decoding positions matter.
- Keep `std/llvm` as a compatibility facade and raw LLVM declarations in `c/llvm`.

## Finish through the matching surface

Use `$ycpl-verification` after implementation. Also exercise the changed behavior directly:

- Compiler/language: compile and run the focused `.yc` fixture.
- Standard library: run an example that calls the new public API.
- LSP: send the affected JSON-RPC request through `tools/lsp/run_tests.sh`.
- VS Code: package the VSIX and load the packaged extension, not the source tree.

Do not commit generated `build`, Bazel, LLVM IR, object, binary, `node_modules`, or VSIX outputs.
