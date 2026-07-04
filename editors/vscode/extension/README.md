# YCPL VS Code Extension

This extension is a thin VS Code client for the YCPL language server. It does
not parse YCPL source code; all language intelligence flows through the Language
Server Protocol.

## Build

```sh
npm ci --prefix ../language-server
npm run build --prefix ../language-server
npm ci
npm run build
```

From the repository root:

```sh
npm ci --prefix editors/vscode/language-server
npm run build --prefix editors/vscode/language-server
npm ci --prefix editors/vscode/extension
npm run build --prefix editors/vscode/extension
```

## Debug

Open the repository in VS Code, run the `YCPL: Debug VSCode Extension`
configuration, and open a `.yc` file in the Extension Development Host.

The extension starts `editors/vscode/language-server/dist/src/server.js` by default.
Set `YCPL.server.path` to an external `ycpl-language-server` executable when
testing a packaged or YCPL-native server.

## Editing Features

The language server provides YCPL-aware completion, hover, navigation,
diagnostics, formatting, semantic tokens, inlay hints, code actions, and code
lens. Standard-library member completion also supports import edits: typing
`fmt.` and accepting `println` inserts `import "std/fmt" as fmt` when the alias
is not already imported.

## Package

After both packages are built, package this folder with `vsce package` or your
preferred marketplace pipeline.
