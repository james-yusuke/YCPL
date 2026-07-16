# YCPL Documentation

[Japanese](README.ja.md) | [Repository README](../README.md)

These docs describe the syntax and toolchain supported by the current compiler.
YCPL source files use `.yc`. The standard `ycc` is self-hosted; the C++
implementation remains available as the seed/reference `ycc-bootstrap`.

```text
docs/
├─ README.en.md      English index
├─ README.ja.md      Japanese index
├─ language.*.md     syntax, types, statements, expressions
├─ memory.*.md       Vec, slices, and managed ownership
├─ self-hosting.*.md compiler stages and fixed-point verification
├─ projects.*.md     YCPL.json, imports, visibility
├─ stdlib.*.md       std/* source modules
└─ status.*.md       stable, experimental, reserved features
```

| Start Here | Covers |
|---|---|
| [Language Syntax](language.en.md) | Syntax, types, statements, expressions |
| [Vec and Memory Ownership](memory.en.md) | `Vec<T>`, `[]T`, and managed ownership |
| [Self-hosting Verification](self-hosting.en.md) | Bootstrap-to-stage3 generation and checks |
| [Projects and Modules](projects.en.md) | `YCPL.json`, imports, module visibility |
| [Standard Library](stdlib.en.md) | `std/*` source modules and intrinsic bridges |
| [Implementation Status](status.en.md) | Stable, experimental, and reserved features |
| [YCPL LSP](../tools/lsp/README.md) | Editor protocol support |
| [VS Code extension](../editors/vscode/extension/README.md) | Native LSP selection, compiler commands, and VSIX packaging |

```text
Documented here        -> supported by current examples
Not documented here    -> unsupported or reserved
Marked experimental    -> may change without compatibility
```
