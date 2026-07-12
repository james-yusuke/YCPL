import "stats" as stats
import "std/array" as array
import "std/fmt" as fmt

struct Total {
    value i32
}

fn main() {
    xs := array.new([]i32, 2)

    for (i: i32 := 0; i < 5; i++) {
        xs = array.append(xs, i)
    }

    total := Total{value: stats.sum(xs)}
    fmt.println(total.value)

    array.free(xs)
}
