"""Optional Rust-seeded stages; the standard C++ seed chain stays independent."""

def rust_seed_stages(name):
    """Declare three YCPL compiler stages built from the Rust seed.

    Args:
        name: Prefix for the generating rules.
    """
    inputs = native.glob(["compiler/ycpl/**", "stl/**"]) + [":yc_runtime_src"]
    previous = ":ycc-bootstrap-rust"
    for stage in [1, 2, 3]:
        output = "ycc-stage%d-from-rust" % stage
        native.genrule(
            name = "%s_stage%d_bin" % (name, stage),
            srcs = inputs,
            outs = [output],
            cmd = "YCC=$$(pwd)/$(execpath %s) && OUT=$$(pwd)/$(@D)/rust-stage%d && mkdir -p $$OUT && $$YCC build compiler/ycpl -o $$OUT && cp $$OUT/merged $@" % (previous, stage),
            tools = [previous],
            executable = True,
        )
        previous = ":" + output
