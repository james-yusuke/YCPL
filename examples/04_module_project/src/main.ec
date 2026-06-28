import "math" as math

fn main() {
    sum: i32 := math.add(10, 20)
    println(sum)
    
    product: i32 := math.mul(5, 6)
    println(product)

    sum = math.sub(product, 10)

    println(sum)

    result: i32 := math.div(sum, 2)

    println(result)
}
