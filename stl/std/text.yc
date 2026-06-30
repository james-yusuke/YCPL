module std.text

import "std/mem" as mem
import "std/str" as str

struct StringBuilder {
    data string
    len i32
    cap i32
}

extern fn c_strstr(haystack string, needle string) string as "strstr"
extern fn c_memcpy(dst string, src string, size i64) string as "memcpy"

pub fn len(s string) i32 {
    return str.len(s)
}

pub fn contains(s string, needle string) bool {
    return c_strstr(s, needle) != none
}

pub fn starts_with(s string, prefix string) bool {
    i: i32 := 0
    n := str.len(prefix)

    for (; i < n; i++) {
        if s[i] != prefix[i] {
            return false
        }
    }

    return true
}

pub fn find(s string, needle string) i32 {
    n := str.len(s)
    m := str.len(needle)
    if m == 0 {
        return 0
    }

    i: i32 := 0
    for (; i <= n - m; i++) {
        ok := true
        j: i32 := 0
        for (; j < m; j++) {
            if s[i + j] != needle[j] {
                ok = false
            }
        }
        if ok {
            return i
        }
    }

    return -1
}

pub fn find_from(s string, needle string, start i32) i32 {
    n := str.len(s)
    m := str.len(needle)
    if m == 0 {
        return start
    }

    i := start
    for (; i <= n - m; i++) {
        ok := true
        j: i32 := 0
        for (; j < m; j++) {
            if s[i + j] != needle[j] {
                ok = false
            }
        }
        if ok {
            return i
        }
    }

    return -1
}

pub fn slice(s string, start i32, count i32) string {
    out: string := mem.calloc(count + 1, 1)
    i: i32 := 0
    for (; i < count; i++) {
        out[i] = s[start + i]
    }

    return out
}

pub fn count_char(s string, ch i32) i32 {
    total: i32 := 0
    i: i32 := 0
    n := str.len(s)

    for (; i < n; i++) {
        if s[i] == (ch) {
            total += 1
        }
    }

    return total
}

pub fn line_of_offset(s string, offset i32) i32 {
    line: i32 := 0
    i: i32 := 0
    for (; i < offset; i++) {
        if s[i] == 10 {
            line += 1
        }
    }

    return line
}

pub fn column_of_offset(s string, offset i32) i32 {
    col: i32 := 0
    i: i32 := 0
    for (; i < offset; i++) {
        if s[i] == 10 {
            col = 0
        } else {
            col += 1
        }
    }

    return col
}

pub fn utf16_col(s string, offset i32) i32 {
    return column_of_offset(s, offset)
}

pub fn builder_new(cap i32) string {
    data: string := mem.calloc(cap + 1, 1)
    return data
}

pub fn builder_append(dst string, at i32, src string) i32 {
    n := str.len(src)
    c_memcpy(dst + at, src, n)
    return at + n
}

pub fn builder_free(b string) {
    mem.free(b)
}
