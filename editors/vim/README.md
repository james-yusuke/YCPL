# YCPL Vim Support

This directory contains Vim runtime files for editing `.yc` sources.

## Install from this checkout

Add the runtime directory to Vim's runtime path:

```vim
set runtimepath^=/path/to/YCPL/editors/vim
filetype plugin indent on
syntax on
```

For a plugin manager, point it at this repository and use `editors/vim` as the
runtime root if the manager supports subdirectories.

## Features

- Detects `*.yc` files as `ycpl`;
- highlights YCPL keywords, primitive types, imports, declarations, strings,
  numbers, comments, and common operators;
- applies 4-space indentation for brace-delimited blocks;
- sets YCPL buffer defaults such as `commentstring`, `expandtab`, and
  `shiftwidth`;
- supports current `type`, `cast`, `switch`/`case`/`default`, `Vec<T>` and
  `Map<K,V>` syntax, binary literals, and nested block comments;
- ignores braces inside comments and strings when indenting;
- registers the YCPL server automatically when
  [vim-lsp](https://github.com/prabirshrestha/vim-lsp) emits `User lsp_setup`.

## Language server

Install vim-lsp alongside this runtime. Server discovery prefers the checkout's
`tools/lsp/build/YCPL-lsp`, then `YCPL-lsp` on `PATH`, then the built TypeScript
server under `editors/vscode/language-server/dist`. Build either server first:

```sh
tools/lsp/build.sh
# Portable alternative:
npm ci --prefix editors/vscode/language-server
npm run build --prefix editors/vscode/language-server
```

Override discovery with an argv list in your vimrc (paths with spaces work):

```vim
let g:ycpl_lsp_command = ['/path/to/YCPL-lsp']
" Or force the portable server:
" let g:ycpl_lsp_command = ['node', '/path/to/dist/src/server.js', '--stdio']
```

Set `g:ycpl_lsp_enabled = 0` to disable automatic vim-lsp registration when using
another client. No key mappings are replaced. Configure completion and mappings
using the [vim-lsp setup instructions](https://github.com/prabirshrestha/vim-lsp#registering-servers).

## Smoke test

From the repository root:

```sh
vim -Nu NONE -n +'set rtp^=editors/vim' +'filetype plugin indent on' +'syntax on' +'edit examples/basics/hello.yc' +q
vim -Nu NONE -n -es -S editors/vim/test/runtime.vim
```
