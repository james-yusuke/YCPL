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
lens. Standard-library completion includes module functions such as
`bytes.from_string`, `hex.encode`, and `base64.decode`; accepting one inserts the
missing `import "std/..." as ...` line when needed. Member completion also
supports import edits: typing `fmt.` and accepting `println` inserts
`import "std/fmt" as fmt` when the alias is not already imported.

Syntax highlighting and snippets cover current control/type syntax including
`switch`, `case`, `default`, `enum`, `type`, `defer`, `scope`, and `owned`.
The language server also indexes `std/.../index.yc` modules and offers UFCS
method-style completions such as `b.free()` when an imported module has a
matching first-parameter type.

## Package

After both packages are built, package this folder with `vsce package` or your
preferred marketplace pipeline.
