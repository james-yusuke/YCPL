import "std/fmt" as fmt
import "std/mem" as mem

fn main() {
    size := mem.sizeof(i32)
    src := mem.alloc(size)
    dst := mem.alloc(size)

    mem.set(src, 1, size)
    mem.copy(dst, src, size)

    fmt.println(size)
    fmt.println(*dst)

    mem.free(src)
    mem.free(dst)
}
