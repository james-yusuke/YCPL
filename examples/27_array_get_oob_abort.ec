import "std/array" as array
import "std/fmt" as fmt

fn main() {
    xs := array.new([]i32, 1)
    xs = array.append(xs, 10)
    fmt.println(array.get(xs, 1))
    array.free(xs)
}
