fn rand_u32() i32 {
    seed: i32 := 2463534242
    seed = seed ^ (seed << 13)
    seed = seed ^ (seed >> 17)
    seed = seed ^ (seed << 5)
    return seed
}

fn rand_range(min i32, max i32) i32 {
    r: i32 := rand_u32()
    return min + (r % (max - min + 1))
}

fn main() {
    println(rand_u32())
}