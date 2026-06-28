module std.io

import "std/fmt" as fmt
import "std/mem" as mem
import "std/str" as str

extern fn c_read(fd i32, buf string, count i32) i32 as "read"
extern fn c_write(fd i32, buf string, count i32) i32 as "write"

pub fn read(fd i32, buf string, count i32) i32 {
    return c_read(fd, buf, count)
}

pub fn write(fd i32, buf string, count i32) i32 {
    return c_write(fd, buf, count)
}

pub fn write_str(fd i32, text string) i32 {
    return c_write(fd, text, str.len(text))
}

pub fn print_raw(text string) {
    c_write(1, text, str.len(text))
}

pub fn read_stdin_all(cap i32) string {
    buf: string := mem.calloc(cap + 1, 1)
    c_read(0, buf, cap)
    return buf
}

pub fn send_lsp_body(body string) {
    fmt.printf("Content-Length: %lld\r\n\r\n%s", str.len(body), body)
}
