import "std/array" as array
import "std/fmt" as fmt

fn main() {
    xs := array.new([]i32, 0)

    for (i: i32 := 0; i < 1000; i++) {
        xs = array.append(xs, i)
    }

    total: i32 := 0
    for value in xs {
        total += value
    }

    fmt.println(array.len(xs))
    fmt.println(total)

    array.free(xs)
}
