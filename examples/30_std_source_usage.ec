import "std/array" as array
import "std/fmt" as fmt
import "std/math" as math
import "std/mem" as mem
import "std/str" as str

fn main() {
    fmt.println(str.len("source"))
    fmt.println(str.eq("core", "core"))
    fmt.println(math.abs(-9))
    fmt.println(math.pow(2.0, 3.0))
    fmt.println(math.sin(0.0))
    fmt.println(math.cos(0.0))

    size := mem.sizeof(i32)
    ptr := mem.alloc(size)
    mem.set(ptr, 0, size)
    fmt.println(*ptr)
    mem.free(ptr)

    xs := array.new([]i32, 2)
    xs = array.append(xs, 2)
    xs = array.append(xs, 4)
    xs = array.append(xs, 6)
    xs = array.append(xs, 8)
    array.set(xs, 2, 10)

    total: i32 := 0
    for value in xs {
        total += value
    }

    fmt.println(array.len(xs))
    fmt.println(total)

    array.free(xs)
}
