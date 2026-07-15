# YCPL C API bindings

This directory contains thin, public declarations for C and POSIX APIs. Each
module follows the header that declares the corresponding functions:

```text
c/
├─ stdlib   malloc, calloc, realloc, free, getenv, system
├─ string   memcpy, memset, memcmp, strlen, strcmp, strcpy, strstr
├─ stdio    fopen, fputs, fclose, popen, pclose, fgets
├─ math     pow, sin, cos, sqrt
├─ unistd   close, read, write
├─ fcntl    open
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
