# Projects and Modules

YCPL can compile a single file or a project directory.

## Single File

Build one source file and write LLVM IR to an output directory:

```sh
build/ecc examples/01_hello.ec -o /tmp/YCPL_hello
```

The compiler emits `.ll` IR. Use `llc` and `clang` to turn it into an executable.

## Project Layout

Recommended project layout:

```text
my_project/
  YCPL.json
  src/
    main.ec
    math.ec
```

`YCPL.json`:

```json
{
  "name": "my_project",
  "version": "0.1.0",
  "entry": "src/main.ec",
  "src": ["src/"],
  "output": "build/"
}
```

Fields:

- `name`: project name.
- `version`: project version string.
- `entry`: intended entry source. The current compiler records this but links
  all files under `src`.
- `src`: source directories scanned recursively for `.ec` files.
- `output`: directory for generated LLVM IR.

Build from a project root:

```sh
build/ecc build
```

## Module Rules

Each module file may declare its module name:

```YCPL
module math
```

Public declarations are exported:

```YCPL
pub fn add(a i32, b i32) i32 {
    return a + b
}
```

Import by source path:

```YCPL
import "math" as math

fn main() {
    result := math.add(1, 2)
    println(result)
}
```

If `as` is omitted, the alias is the last path segment:

```YCPL
import "math/basic"

fn main() {
    result := basic.square(5)
    println(result)
}
```

Module rules:

- Imports are resolved to files and then linked into one program.
- Imported functions are called through their alias.
- Direct calls are allowed only inside the same module.
- Non-`pub` functions and structs are private to their module.
- Public function LLVM symbols are mangled as `module__name`; `main` stays
  `main`.
- Duplicate public symbol names are allowed across different modules because
  calls resolve through aliases.

Standard library modules are resolved from bundled YCPL source files under
`stl/std`:

```YCPL
import "std/fmt" as fmt
import "std/array" as array
```

The resolver searches project source directories first, then walks upward from
the project root looking for `stl/std/<module>.ec`. If the bundled source is not
available, known `std/*` modules may fall back to compiler-provided virtual
symbols for compatibility, but repository examples exercise the source modules.

The standard library source may contain bodyless declarations:

```YCPL
extern fn c_strlen(s string) i64 as "strlen"
pub intrinsic fn println(value... any)
```

`extern fn` creates an external LLVM prototype. `intrinsic fn` is accepted only
inside bundled `std` modules and routes to compiler/runtime bridge code.
