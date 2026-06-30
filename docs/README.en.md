# YCPL Documentation

[Japanese](README.ja.md) | [Repository README](../README.md)

These docs describe the syntax and toolchain supported by the current compiler.
YCPL source files use `.yc`.

```mermaid
flowchart LR
    Docs["docs"] --> Language["language.en.md"]
    Docs --> Projects["projects.en.md"]
    Docs --> Stdlib["stdlib.en.md"]
    Docs --> Status["status.en.md"]
    Language --> Examples["examples/*.yc"]
    Projects --> Config["YCPL.json"]
    Stdlib --> STL["stl/std/*.yc"]
    Status --> Tests["examples/run_tests.sh"]
```

| Start Here | Covers |
|---|---|
| [Language Syntax](language.en.md) | Syntax, types, statements, expressions |
| [Projects and Modules](projects.en.md) | `YCPL.json`, imports, module visibility |
| [Standard Library](stdlib.en.md) | `std/*` source modules and intrinsic bridges |
| [Implementation Status](status.en.md) | Stable, experimental, and reserved features |
| [YCPL LSP](../tools/lsp/README.md) | Editor protocol support |

```mermaid
flowchart TD
    Rule["Documented here"] --> Supported["Supported by current examples"]
    Missing["Not documented"] --> TreatAs["Unsupported or reserved"]
    Experimental["Marked experimental"] --> MayChange["May change without compatibility"]
```
