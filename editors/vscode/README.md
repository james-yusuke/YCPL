# YCPL VSCode Extension

This extension is intended to run in the VSCode Remote Dev Container extension
host.

Install Node dependencies:

```sh
npm ci --prefix editors/vscode
```

Build the native Linux LSP binary:

```sh
tools/lsp/build.sh
```

If `YCPL.server.path` is empty, the launcher tries
`${workspaceFolder}/tools/lsp/build/YCPL-lsp`, then the development checkout
relative path, then `YCPL-lsp` on `PATH`. With `YCPL.server.buildOnActivate`
enabled, it runs `tools/lsp/build.sh` automatically when the workspace binary is
missing.

Do not launch the devcontainer-built Linux binary from a macOS host extension
host. Open the repository in the devcontainer, or set `YCPL.server.path` to a
host-native `YCPL-lsp` binary.

The extension contributes:

- TextMate syntax highlighting for `.ec` files;
- semantic token colorization for namespaces, types, functions, variables,
  fields/properties, keywords, strings, numbers, operators, and comments;
- snippets for `main`, `fn`, `struct`, imports, loops, and common std calls;
- Go-like 4-space indentation defaults and block/comment enter rules;
- a stdio LSP launcher for diagnostics, completion, semantic tokens,
  formatting, folding ranges, hover, signature help, document symbols,
  definition/declaration, type definition, references, document highlight,
  prepareRename, rename, selection range, and workspace symbol.

## VSCode Test Steps

Use the extension from inside the Remote Dev Container. The Linux `YCPL-lsp`
binary built here is not intended to be launched by the macOS host extension
host.

1. Run the CLI checks:

   ```sh
   npm ci --prefix editors/vscode
   bash .devcontainer/install-vscode-extension.sh
   npm run check --prefix editors/vscode
   tools/lsp/run_tests.sh
   ```

2. Build the server manually once:

   ```sh
   tools/lsp/build.sh
   ```

3. Run **Developer: Reload Window** in VSCode so the Remote Container extension
   host rescans the linked local extension. You can also start an Extension
   Development Host from VSCode with this folder as the extension under
   development.

4. Open an `.ec` file and check these editor features:

   - the bottom-right language mode says `YCPL`;
   - keywords, primitive types, strings, comments, operators, functions, struct
     names, module aliases, and fields have distinct colors;
   - typing `main` then Tab expands the main-function snippet;
   - `fmt.` shows completion items and snippets;
   - hover and signature help appear on known std calls;
   - **Format Document** applies 4-space block formatting;
   - folding appears on functions/structs;
   - **Go to Definition**, **Go to Declaration**, **Go to Type Definition**,
     **Find References**, **Rename Symbol**, **Go to Symbol in Workspace**, and
     document highlights work across currently open YCPL files;
   - malformed code publishes diagnostics in the Problems panel.

5. If the server does not start, open **Output: YCPL Language Server** and check
   the resolved binary path. Set `YCPL.server.path` explicitly if needed.
