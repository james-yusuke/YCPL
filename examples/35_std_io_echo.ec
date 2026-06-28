import "std/io" as io
import "std/mem" as mem

fn main() {
    buf: string := mem.calloc(64, 1)
    n := io.read(0, buf, 63)
    io.write(1, buf, n)
    mem.free(buf)
}
