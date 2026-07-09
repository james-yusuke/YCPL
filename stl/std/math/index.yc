module std.math

extern fn c_pow(a double, b double) double as "pow"
extern fn c_sin(x double) double as "sin"
extern fn c_cos(x double) double as "cos"
extern fn c_sqrt(x double) double as "sqrt"

pub fn abs(x i32) i32 {
    if x < 0 {
        return -x
    }

    return x
}

pub fn pow(a double, b double) double {
    return c_pow(a, b)
}

pub fn sin(x double) double {
    return c_sin(x)
}

pub fn cos(x double) double {
    return c_cos(x)
}

pub fn sqrt(x double) double {
    return c_sqrt(x)
}
