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

def _candidate_paths(ctx, min_major):
    candidates = []
    llvm_config_env = ctx.os.environ.get("LLVM_CONFIG")
    if llvm_config_env:
        candidates.append(llvm_config_env)

    llvm_bindir_env = ctx.os.environ.get("LLVM_BINDIR")
    if llvm_bindir_env:
        candidates.append("{}/llvm-config".format(llvm_bindir_env.rstrip("/")))

    llvm_dir_env = ctx.os.environ.get("LLVM_DIR")
    if llvm_dir_env:
        candidates.append("{}/../../../bin/llvm-config".format(llvm_dir_env.rstrip("/")))

    candidates.extend([
        "/opt/homebrew/opt/llvm@{}/bin/llvm-config".format(min_major),
        "/opt/homebrew/opt/llvm/bin/llvm-config",
        "/usr/local/opt/llvm@{}/bin/llvm-config".format(min_major),
        "/usr/local/opt/llvm/bin/llvm-config",
        "/usr/lib/llvm-{}/bin/llvm-config".format(min_major),
        "llvm-config-{}".format(min_major),
        "llvm-config{}".format(min_major),
        ctx.attr.llvm_config,
        "llvm-config",
    ])
    return candidates

def _resolve_llvm_config(ctx, min_major):
    checked = []
    for candidate in _candidate_paths(ctx, min_major):
        if not candidate or candidate in checked:
            continue
        checked.append(candidate)
        if candidate.startswith("/"):
            result = ctx.execute([candidate, "--version"], quiet = True)
            if result.return_code == 0:
                return candidate
        else:
            path = ctx.which(candidate)
            if path != None:
                return path
    fail("""Could not find llvm-config for LLVM {min_major}+.

Set one of:
  LLVM_CONFIG=/absolute/path/to/llvm-config
  LLVM_BINDIR=/absolute/path/to/llvm/bin
  LLVM_DIR=/absolute/path/to/lib/cmake/llvm

Common locations checked:
  /opt/homebrew/opt/llvm@{min_major}/bin/llvm-config
  /opt/homebrew/opt/llvm/bin/llvm-config
  /usr/local/opt/llvm@{min_major}/bin/llvm-config
  /usr/local/opt/llvm/bin/llvm-config
  /usr/lib/llvm-{min_major}/bin/llvm-config
""".format(min_major = min_major))

def _llvm_config_repo_impl(ctx):
    min_major_env = ctx.os.environ.get("YCPL_LLVM_MIN_VERSION")
    min_major = int(min_major_env) if min_major_env else ctx.attr.min_major
    llvm_config_path = _resolve_llvm_config(ctx, min_major)

    version = _run_llvm_config(ctx, llvm_config_path, ["--version"])
    major = int(version.split(".")[0])
    if major < min_major:
        fail("LLVM {} is too old; YCPL requires LLVM {} or newer. Set LLVM_CONFIG to LLVM {} llvm-config.".format(version, min_major, min_major))

    include_dir = _run_llvm_config(ctx, llvm_config_path, ["--includedir"])
    lib_dir = _run_llvm_config(ctx, llvm_config_path, ["--libdir"])
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
            linkopts = repr(ldflags + libs + system_libs + ["-Wl,-rpath,{}".format(lib_dir)]),
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
        "LLVM_BINDIR",
        "LLVM_DIR",
        "YCPL_LLVM_MIN_VERSION",
    ],
)

def _llvm_config_extension_impl(ctx):
    llvm_config_repository(name = "llvm_config")

llvm_config_extension = module_extension(
    implementation = _llvm_config_extension_impl,
)
