import "std/array" as array
import "std/fmt" as fmt

struct Pair {
    left i32
    right i32
}

fn main() {
    first := array.new([]i32, 1)
    first = array.append(first, 1)
    first = array.append(first, 2)

    second := array.new([]i32, 1)
    second = array.append(second, 3)
    second = array.append(second, 4)

    rows := array.new([][]i32, 1)
    rows = array.append(rows, first)
    rows = array.append(rows, second)

    pairs := array.new([]Pair, 1)
    pairs = array.append(pairs, Pair{left: 5, right: 6})
    pairs = array.append(pairs, Pair{left: 7, right: 8})

    total: i32 := 0

    for row in rows {
        for value in row {
            total += value
        }
    }

    for pair in pairs {
        total += pair.left
        total += pair.right
    }

    fmt.println(total)

    array.free(first)
    array.free(second)
    array.free(rows)
    array.free(pairs)
}
