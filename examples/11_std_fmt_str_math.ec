import "std/fmt" as fmt
import "std/str" as str
import "std/math" as math

fn main() {
    fmt.println("std ready")
    fmt.print("len")
    fmt.println(str.len("hello"))
    fmt.println(str.eq("same", "same"))
    fmt.println(math.abs(-7))
    fmt.println(math.sqrt(9.0))
}
