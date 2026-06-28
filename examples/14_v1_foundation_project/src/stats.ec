module stats

import "std/array" as array

pub fn sum(xs []i32) i32 {
    total: i32 := 0

    for (i: i32 := 0; i < array.len(xs); i++) {
        total = total + array.get(xs, i)
    }

    return total
}
