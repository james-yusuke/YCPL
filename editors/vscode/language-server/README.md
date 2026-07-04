# YCPL Language Server

The YCPL language server is a TypeScript ES module implementation of the
Language Server Protocol. It is separate from the VS Code extension and can be
run by any LSP-capable editor.

## Architecture

- `analysis/parser.ts` extracts editor-facing declarations, references, imports,
  calls, and lightweight diagnostics from YCPL source.
- `analysis/workspaceIndex.ts` stores the incremental workspace symbol and
  reference index.
- `analysis/workspaceScanner.ts` lazily scans `.yc` files, skipping build and
  dependency directories.
- `analysis/stdlib.ts` discovers YCPL standard-library modules and exported
  functions.
- `compiler/compilerBridge.ts` defines the boundary for reusing the real YCPL
  compiler lexer, parser, AST, symbol table, type checker, formatter, and
  diagnostics without coupling LSP providers to compiler internals.
- `lsp/providers.ts` implements completion, hover, definition, references,
  rename, symbols, signature help, semantic tokens, diagnostics, formatting,
  folding, selection ranges, highlights, inlay hints, code actions, code lens,
  implementations, and call hierarchy.
- Standard-library member completion can attach LSP `additionalTextEdits`, so
  accepting `fmt.println`-style completions can add the missing `import` line.
- `server.ts` wires the providers to `vscode-languageserver`.

## Build And Test

```sh
npm ci
npm run check
```

From the repository root:

```sh
npm ci --prefix editors/vscode/language-server
npm run check --prefix editors/vscode/language-server
```

## Compiler Integration

`NullCompilerBridge` is intentionally small. Replace it with an implementation
that calls the YCPL compiler frontend when that API is stable. The VS Code
extension does not need to change because it only speaks LSP.
