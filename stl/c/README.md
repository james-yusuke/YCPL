# YCPL C API bindings

This directory is the canonical home for thin, public declarations of C,
POSIX, runtime, and LLVM APIs. Each module follows the header or ABI surface
that declares the corresponding functions:

```text
c/
├─ stdlib   malloc, calloc, realloc, free, getenv, system
├─ string   memcpy, memset, memcmp, strlen, strcmp, strcpy, strstr
├─ stdio    fopen, fputs, fclose, popen, pclose, fgets
├─ math     pow, sin, cos, sqrt
├─ unistd   close, read, write
├─ fcntl    open
├─ llvm     LLVM 22 C API
├─ yc_runtime compiler-support source traversal
└─ sys/stat mkdir
```

Import a binding with its `c/` path:

```YCPL
import "c/string" as cstr

fn main() i32 {
    return cstr.strcmp("YCPL", "YCPL")
}
```

These modules intentionally expose raw foreign-function boundaries. Managed
allocation, ownership, and higher-level convenience APIs belong in `std`.
New raw bindings should be added here rather than under `stl/std`. Compatibility
wrappers already present in `std` may remain while callers migrate.

`c/llvm` also provides narrow `Vec<i64>` argument bridges for LLVM APIs that
require contiguous arrays of references. The raw backing pointer is kept
inside the binding module and is not exposed as a general `Vec<T>` conversion.
