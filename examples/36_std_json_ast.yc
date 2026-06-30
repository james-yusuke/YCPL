import "std/fmt" as fmt
import "std/json" as json
import "std/mem" as mem

struct Point {
    x i32
    y i32
}

fn main() {
    point := Point{x: 1, y: 2}
    value := json.parse("{\"id\":42,\"ok\":true,\"name\":\"YCPL\",\"items\":[1,{\"nested\":\"yes\"}],\"point\":{\"x\":3,\"y\":4}}")
    name := json.get_string(value, "name")
    items := json.get(value, "items")
    item1 := json.at(items, 1)
    nested := json.get_string(item1, "nested")
    point_json := json.get(value, "point")
    roundtrip := json.stringify(point_json)

    fmt.println(json.kind(value))
    fmt.println(json.get_i32(value, "id"))
    fmt.println(json.get_bool(value, "ok"))
    fmt.println(name)
    fmt.println(json.len(items))
    fmt.println(nested)
    fmt.println(json.get_i32(point_json, "x") + json.get_i32(point_json, "y") + point.x + point.y)
    fmt.println(roundtrip)

    mem.free(name)
    mem.free(nested)
    mem.free(roundtrip)
    json.free(value)
}
