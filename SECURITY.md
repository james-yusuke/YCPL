# Security Policy

YCPL is an experimental compiler and language runtime project. The compiler is
not production-ready yet, but security reports are still welcome, especially
around parsing, project traversal, native build execution, LLVM linking, and
generated code behavior.

## Supported Versions

Only the latest commit on `main` is considered supported. Security fixes may not
be backported to older commits, tags, forks, or archived bootstrap snapshots.

## Reporting a Vulnerability

Please do not open a public GitHub issue for a suspected vulnerability.

Use GitHub Security Advisories / Private Vulnerability Reporting when available,
or another private GitHub contact path. Include as much of the following as you
can:

- A short description of the issue
- Affected commit, OS, architecture, and LLVM version
- Reproduction steps or a minimal `.yc` file
- Expected behavior and actual behavior
- Potential impact
- Whether the issue requires `ycc`, `ycc-ycpl`, Bazel, CMake, or native build

I will try to acknowledge reports promptly. Because YCPL is still early-stage,
fix timelines may vary by severity and by whether the report affects the
bootstrap compiler, the YCPL compiler, or the build driver.

## Scope

Security-sensitive areas include:

- Unsafe project path traversal or shell command construction
- Buffer overflows, unchecked writes, or unbounded file loading
- Crashes on malformed source that should produce diagnostics
- Incorrect LLVM/linker discovery that mutates system paths
- Generated native binaries that behave differently from checked source
- C/LLVM FFI wrappers that expose invalid signatures or unsafe calls

Out of scope:

- Issues that require arbitrary local write access to the repository
- Vulnerabilities in third-party LLVM, Bazel, CMake, or system toolchains
- Denial-of-service reports based only on extremely large generated files during
  active self-hosting development, unless they also show an unchecked memory
  safety issue

Thank you for helping make YCPL safer.
