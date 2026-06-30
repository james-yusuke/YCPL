# Implementation Status

[Japanese](status.ja.md) | [Docs index](README.en.md)

```mermaid
flowchart LR
    Feature["Feature"] --> Stable["Stable enough for examples"]
    Feature --> Experimental["Experimental"]
    Feature --> Reserved["Reserved, not implemented"]
```

## Stable Enough For Examples

```mermaid
mindmap
  root((stable))
    source
      yc extension
      YCPL.json
    modules
      module/package
      import as alias
      pub visibility
    functions
      fn
      extern fn
      main
    data
      structs
      pointers
      slices
      none
    flow
      if/else
      for
      for-in
      break/continue
    std
      fmt
      array
      mem
      str
      math
      io/fs/text/json/map
    tooling
      examples
      YCPL LSP v0.4
```

## Experimental

```mermaid
flowchart TD
    Exp["Experimental"] --> Intrinsic["intrinsic fn in bundled std"]
    Exp --> Sprintf["sprintf"]
    Exp --> Cast["cast"]
    Exp --> New["new([]T)"]
    Exp --> Variadic["variadic user functions"]
    Exp --> PointerHeavy["pointer-heavy expressions"]
    Exp --> InlineStructs["nested/inline structs"]
    Exp --> SliceReturns["runtime slice returns"]
    Exp --> BroadFFI["broad C/Unix FFI"]
```

## Reserved But Not Implemented

```text
enum interface match is go defer select switch or type importas
```

```mermaid
flowchart LR
    Reserved["reserved token"] --> Reason["prevents future syntax collision"]
    Reserved --> NoParser["no parser/codegen support yet"]
```

Notes: `none` is a null literal, not an optional type; imported direct calls are
rejected; LSP navigation currently scans open documents rather than a full
project index.
