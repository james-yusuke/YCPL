import "std/array" as array
import "std/fmt" as fmt

struct Box {
    value i32
}

fn main() {
    x: i32 := 10
    x += 5
    x -= 3
    x *= 2
    x /= 4
    x %= 4

    xs := array.new([]i32, 2)
    xs = array.append(xs, 3)
    xs = array.append(xs, 4)
    xs[0] += 7
    xs[1] *= 3

    box := Box{value: 5}
    box.value += x

    fmt.println(x + array.get(xs, 0) + array.get(xs, 1) + box.value)

    array.free(xs)
}
