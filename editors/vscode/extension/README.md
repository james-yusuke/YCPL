# YCPL for Visual Studio Code

YCPL language support with a native self-hosted Language Server when available
and a bundled TypeScript fallback everywhere else.

## Language Server selection

`YCPL.server.mode` defaults to `auto`. The extension selects:

1. `YCPL.server.path`
2. `tools/lsp/build/YCPL-lsp` in an open workspace
3. `YCPL-lsp` on `PATH`
4. the TypeScript server bundled in the VSIX

Use `native` to require the YCPL-written server or `typescript` to force the
portable fallback. The status bar and YCPL Output channel show the active
server. Changes to server settings restart the client automatically.

Both servers provide completion, hover, definition/declaration/type
definition/implementation, references, rename, symbols, signature help,
semantic tokens, formatting, folding, selection ranges, highlights, inlay
hints, code actions, code lenses, and call hierarchy.

## Compiler commands

The Command Palette contains check, build, build-ir, run, Language Server
restart, and output commands. The extension discovers the self-hosted `ycc`
through `YCPL.compiler.path`, `bazel-bin/ycc`, `build/ycc`, then `PATH`.
Bootstrap executables are intentionally ignored.

A parent `YCPL.json` selects project mode; otherwise the active `.yc` file is
used. `YCPL.checkOnSave` is enabled by default with a 300ms debounce.
Compiler output in `file:line:column: message` format is published as editor
diagnostics. Builds use `.ycpl/build` unless `YCPL.outputDirectory` is changed.

`YCPL.stlRoot` and `YCPL.runtimeSource` override `YCPL_STL_ROOT` and
`YCPL_RUNTIME_SRC`. `YCPL.run.arguments` is passed after `--`.

## Build, test, and package

From the repository root:

```sh
npm ci --prefix editors/vscode/language-server
npm run check --prefix editors/vscode/language-server
npm ci --prefix editors/vscode/extension
npm run check --prefix editors/vscode/extension
npm run test:extension --prefix editors/vscode/extension
tools/lsp/build.sh
npm run test:extension:native --prefix editors/vscode/extension
npm run package --prefix editors/vscode/extension
npm run check-package --prefix editors/vscode/extension
```

The VSIX is written to
`editors/vscode/extension/artifacts/ycpl-vscode.vsix`. It contains the
extension, grammar, snippets, icon, and bundled TypeScript server, but no
platform-specific native executable.

For interactive development, run `YCPL: Debug VSCode Extension` from the
repository workspace.
