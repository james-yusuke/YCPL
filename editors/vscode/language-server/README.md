# YCPL Language Server

The YCPL language server is a TypeScript ES module implementation of the
Language Server Protocol. It is separate from the VS Code extension and can be
run by any LSP-capable editor.

## Architecture

- `analysis/parser.ts` extracts editor-facing scopes, declarations, references,
  imports, calls, and lightweight diagnostics from YCPL source.
- `analysis/workspaceIndex.ts` stores the incremental workspace symbol and
  reference index keyed by `SymbolID`, not by identifier text.
- `analysis/workspaceScanner.ts` lazily scans `.yc` files, skipping build and
  dependency directories.
- `analysis/stdlib.ts` discovers YCPL standard-library modules, exported
  functions, and exported structs from `stl/std`.
- `compiler/compilerBridge.ts` defines the boundary for reusing the real YCPL
  compiler lexer, parser, AST, symbol table, type checker, formatter, and
  diagnostics without coupling LSP providers to compiler internals.
- `lsp/providers.ts` implements completion, hover, definition, references,
  rename, symbols, signature help, semantic tokens, diagnostics, formatting,
  folding, selection ranges, highlights, inlay hints, code actions, code lens,
  implementations, and call hierarchy.
- Standard-library function and member completion can attach LSP
  `additionalTextEdits`, so accepting `bytes.from_string` or `fmt.println`-style
  completions can add the missing `import` line.
- `server.ts` wires the providers to `vscode-languageserver`.

## Symbol Resolution

Each declaration receives a stable `SymbolID` and belongs to a concrete scope.
References are resolved through the current scope, parent scopes, and the module
root before LSP providers see them. Go to Definition, Find References, Rename,
Hover, semantic highlighting, code lens, signature help, and call hierarchy use
the resolved `SymbolID` instead of global name matching, so shadowed locals and
same-named symbols in different files remain independent.

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
