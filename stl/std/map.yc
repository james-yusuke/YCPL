module std.map

import "std/array" as array
import "std/str" as str

pub fn find(keys []string, key string) i32 {
    if key == none {
        return -1
    }

    i: i32 := 0
    for (; i < array.len(keys); i++) {
        current := array.get(keys, i)
        if current != none && str.eq(current, key) {
            return i
        }
    }

    return -1
}

pub fn first_empty(keys []string) i32 {
    i: i32 := 0
    for (; i < array.len(keys); i++) {
        if array.get(keys, i) == none {
            return i
        }
    }

    return -1
}

pub fn has(keys []string, key string) bool {
    return find(keys, key) >= 0
}

pub fn get(keys []string, values []string, key string) string {
    i := find(keys, key)
    if i < 0 {
        return none
    }

    return array.get(values, i)
}

pub fn put(keys []string, values []string, key string, value string) i32 {
    i := find(keys, key)
    if i < 0 {
        i = first_empty(keys)
    }

    if i < 0 {
        return -1
    }

    array.set(keys, i, key)
    array.set(values, i, value)
    return i
}

pub fn remove(keys []string, values []string, key string) {
    i := find(keys, key)
    if i >= 0 {
        array.set(keys, i, none)
        array.set(values, i, none)
    }
}

pub fn get_i32(keys []string, values []i32, key string, missing i32) i32 {
    i := find(keys, key)
    if i < 0 {
        return missing
    }

    return array.get(values, i)
}

pub fn put_i32(keys []string, values []i32, key string, value i32) i32 {
    i := find(keys, key)
    if i < 0 {
        i = first_empty(keys)
    }

    if i < 0 {
        return -1
    }

    array.set(keys, i, key)
    array.set(values, i, value)
    return i
}

pub fn free(keys []string, values []string) {
    array.free(keys)
    array.free(values)
}
