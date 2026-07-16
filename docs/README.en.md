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
├─ projects.*.md     YCPL.json, imports, visibility
├─ stdlib.*.md       std/* source modules
└─ status.*.md       stable, experimental, reserved features
```

| Start Here | Covers |
|---|---|
| [Language Syntax](language.en.md) | Syntax, types, statements, expressions |
| [Projects and Modules](projects.en.md) | `YCPL.json`, imports, module visibility |
| [Standard Library](stdlib.en.md) | `std/*` source modules and intrinsic bridges |
| [Implementation Status](status.en.md) | Stable, experimental, and reserved features |
| [YCPL LSP](../tools/lsp/README.md) | Editor protocol support |

```text
Documented here        -> supported by current examples
Not documented here    -> unsupported or reserved
Marked experimental    -> may change without compatibility
```
