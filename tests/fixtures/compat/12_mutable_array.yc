import "std/array" as array
import "std/fmt" as fmt

fn main() {
    xs := array.new([]i32, 1)

    xs = array.append(xs, 10)
    xs = array.append(xs, 20)
    array.set(xs, 1, 30)

    fmt.println(array.len(xs))
    fmt.println(array.cap(xs))
    fmt.println(array.get(xs, 0))
    fmt.println(array.get(xs, 1))

    array.free(xs)
}
