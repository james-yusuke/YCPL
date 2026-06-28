fn gcd(a i32, b i32) i32 {
    x: i32 := a
    y: i32 := b

    for {
        if (y == 0) {
            break
        }

        t: i32 := x % y
        x = y
        y = t
    }

    if (x < 0) {
        return 0
    }

    return x
}

fn main() {
    println(gcd(84, 36))
}