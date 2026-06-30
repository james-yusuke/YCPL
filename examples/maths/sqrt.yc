fn isqrt(x i32) i32 {
    if (x <= 0) {
        return 0
    }

    res: i32 := 0
    bit: i32 := 1 << 30

    for {
        if !(bit > x) {
            break
        }
        bit = bit >> 2
    }

    for {
        if (bit == 0) {
            break
        }

        test: i32 := res + bit

        if (x >= test) {
            x = x - test
            res = (res >> 1) + bit
        } else {
            res = res >> 1
        }

        bit = bit >> 2
    }

    return res
}

fn main() {
    println(isqrt(100 << 5))
    println(isqrt(9))
}
