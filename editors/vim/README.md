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
  `shiftwidth`.

## Smoke test

From the repository root:

```sh
vim -Nu NONE -n +'set rtp^=editors/vim' +'filetype plugin indent on' +'syntax on' +'edit examples/01_hello.yc' +q
```
