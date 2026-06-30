module std.fs

import "std/mem" as mem

extern fn c_open(path string, flags i32, mode i32) i32 as "open"
extern fn c_close(fd i32) i32 as "close"
extern fn c_read(fd i32, buf string, count i32) i32 as "read"

pub fn exists(path string) bool {
    fd := c_open(path, 0, 0)
    if fd < 0 {
        return false
    }

    c_close(fd)
    return true
}

pub fn read_file(path string) string {
    fd := c_open(path, 0, 0)
    if fd < 0 {
        return none
    }

    buf: string := mem.calloc(65536, 1)
    c_read(fd, buf, 65535)
    c_close(fd)
    return buf
}

pub fn uri_to_path(uri string) string {
    if uri[0] == 'f' && uri[1] == 'i' && uri[2] == 'l' && uri[3] == 'e' && uri[4] == ':' {
        return uri + 7
    }

    return uri
}
