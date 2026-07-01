LLVM_COMPONENTS = [
    "core",
    "irreader",
    "executionengine",
    "native",
    "nativecodegen",
    "orcjit",
    "support",
]

def _run_llvm_config(ctx, llvm_config, args):
    result = ctx.execute([llvm_config] + args)
    if result.return_code != 0:
        fail("llvm-config failed: {}\n{}".format(" ".join(args), result.stderr))
    return result.stdout.strip()

def _words(value):
    return [word for word in value.split(" ") if word]

def _llvm_config_repo_impl(ctx):
    llvm_config_env = ctx.os.environ.get("LLVM_CONFIG")
    llvm_config = llvm_config_env if llvm_config_env else ctx.attr.llvm_config
    llvm_config_path = ctx.which(llvm_config)
    if llvm_config_path == None:
        fail("Could not find llvm-config. Install LLVM 22 or set LLVM_CONFIG=/path/to/llvm-config.")

    version = _run_llvm_config(ctx, llvm_config_path, ["--version"])
    major = int(version.split(".")[0])
    min_major_env = ctx.os.environ.get("YCPL_LLVM_MIN_VERSION")
    min_major = int(min_major_env) if min_major_env else ctx.attr.min_major
    if major < min_major:
        fail("LLVM {} is too old; YCPL requires LLVM {} or newer. Set LLVM_CONFIG to LLVM {} llvm-config.".format(version, min_major, min_major))

    include_dir = _run_llvm_config(ctx, llvm_config_path, ["--includedir"])
    ldflags = _words(_run_llvm_config(ctx, llvm_config_path, ["--ldflags"]))
    libs = _words(_run_llvm_config(ctx, llvm_config_path, ["--libs"] + LLVM_COMPONENTS))
    system_libs = _words(_run_llvm_config(ctx, llvm_config_path, ["--system-libs"] + LLVM_COMPONENTS))
    cxxflags = _words(_run_llvm_config(ctx, llvm_config_path, ["--cxxflags"]))

    defines = []
    copts = []
    for flag in cxxflags:
        if flag.startswith("-D"):
            defines.append(flag[2:])
        elif flag.startswith("-std=") or flag.startswith("-I"):
            continue
        else:
            copts.append(flag)

    ctx.symlink(include_dir, "include")
    ctx.file(
        "BUILD.bazel",
        """
load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "llvm",
    hdrs = glob(["include/**/*"]),
    includes = ["include"],
    defines = {defines},
    copts = {copts},
    linkopts = {linkopts},
)
""".format(
            defines = repr(defines),
            copts = repr(copts),
            linkopts = repr(ldflags + libs + system_libs),
        ),
    )

llvm_config_repository = repository_rule(
    implementation = _llvm_config_repo_impl,
    attrs = {
        "llvm_config": attr.string(default = "llvm-config"),
        "min_major": attr.int(default = 22),
    },
    environ = [
        "LLVM_CONFIG",
        "YCPL_LLVM_MIN_VERSION",
    ],
)

def _llvm_config_extension_impl(ctx):
    llvm_config_repository(name = "llvm_config")

llvm_config_extension = module_extension(
    implementation = _llvm_config_extension_impl,
)
