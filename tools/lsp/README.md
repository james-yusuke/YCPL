# YCPL LSP

This is the v0.4 YCPL language server written in YCPL.

Build the native binary:

```sh
tools/lsp/build.sh
```

Run protocol fixtures:

```sh
tools/lsp/run_tests.sh
```

The server speaks JSON-RPC over stdio with `Content-Length` framing and supports
initialize, shutdown, full-text document sync notifications, diagnostics, hover,
snippet-aware completion, documentSymbol, semantic tokens, formatting, range
formatting, folding ranges, signature help, definition, declaration,
typeDefinition, references, document highlight, prepareRename, rename,
selectionRange, and workspace/symbol responses.

v0.4 keeps the implementation lightweight but editor-complete enough for daily
YCPL editing:

- documents are stored in fixed-capacity YCPL `[]string` slots;
- the receive loop keeps incomplete headers/bodies across reads and handles
  multiple frames per read;
- diagnostics cover unclosed block comments, strings, braces, and direct std
  calls such as `println(...)` after importing `std/fmt`, plus basic malformed
  import/function declarations;
- completion returns core keywords, primitive types, snippets, std modules, and
  common std calls;
- documentSymbol extracts module, struct, and function symbols from the stored
  source;
- semantic tokens classify namespaces, types, functions, variables, properties,
  keywords, strings, numbers, operators, and comments;
- definition/declaration detects functions, structs, local variables, function
  parameters, for-in variables, and struct fields;
- typeDefinition can jump from a variable with an explicit or inferred struct
  type to the corresponding struct declaration;
- references, rename, and workspace/symbol scan every currently open YCPL
  document tracked by the LSP.

Full semantic project analysis, unopened-file indexing, import graph indexing,
formatting through a full AST, and type-aware rename are reserved for the next
LSP phase.
