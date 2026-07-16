# YCPL Examples

This directory contains user-facing programs written with the current YCPL
syntax and managed standard-library APIs. Compiler regression inputs live in
`../tests/fixtures` so unsupported or compatibility-only syntax does not get
mixed into normal examples.

## Basics

- `basics/hello.yc`: hello world
- `basics/variables_and_types.yc`: declarations and primitive types
- `basics/control_flow.yc`: `if`, loops, `break`, and `continue`
- `basics/arrays.yc` and `basics/array_iteration.yc`: arrays and iteration
- `basics/structs.yc`: structs and member access
- `basics/enum_switch_alias.yc`: enums, switch, and type aliases
- `basics/defer_scope.yc`: deferred actions and lexical scopes

## Standard Library

- `stdlib/managed_collections.yc`: Go-style arrays, maps, and text helpers
- `stdlib/managed_runtime.yc`: managed values returned across function frames
- `stdlib/bytes_hex_hash.yc`: bytes, hexadecimal encoding, and hashes
- `stdlib/base64.yc` and `stdlib/encoding.yc`: managed encoding APIs
- `stdlib/json.yc`: JSON values and non-owning views
- `stdlib/io_echo.yc`: file-descriptor I/O with a managed byte buffer
- `stdlib/foundation.yc`: text, Vec sorting, strict JSON, paths, and UTF-8

No public example requires `free`. Raw allocation and compatibility APIs are
tested only under `tests/fixtures/compat` and `tests/fixtures/runtime`.

## Projects

- `projects/module_project/`: basic multi-file project
- `projects/multi_module/`: nested modules and imports

Build a single file or project with:

```sh
bazel run //:ycc -- build examples/basics/hello.yc
bazel run //:ycc -- build examples/projects/module_project
```
