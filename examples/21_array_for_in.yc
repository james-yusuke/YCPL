import "std/array" as array
import "std/fmt" as fmt

fn main() {
    xs := array.new([]i32, 2)
    xs = array.append(xs, 1)
    xs = array.append(xs, 2)
    xs = array.append(xs, 3)
    xs = array.append(xs, 4)
    xs = array.append(xs, 5)

    total: i32 := 0
    for value in xs {
        total += value
    }

    fmt.println(total)
    array.free(xs)
}
