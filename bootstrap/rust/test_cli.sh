#!/usr/bin/env bash
set -euo pipefail

root="${TEST_SRCDIR:-}/${TEST_WORKSPACE:-_main}"
if [ -z "${TEST_SRCDIR:-}" ]; then
  root="$(cd "$(dirname "$0")/../.." && pwd)"
fi
seed="${1:-$root/bootstrap/rust/target/release/ycc-bootstrap-rust}"
if [[ "$seed" != /* ]]; then seed="$PWD/$seed"; fi
export YCPL_STL_ROOT="$root/stl"
export YCPL_RUNTIME_SRC="$root/bootstrap/cpp/runtime/yc_runtime.c"
work="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-rust-cli.XXXXXX")"
trap 'rm -rf "$work"' EXIT
cd "$work"
mkdir 'project with spaces $(literal)'
cd 'project with spaces $(literal)'
cat > 'a file.yc' <<'EOF'
import "std/fmt" as fmt
fn main(argc i32, argv *string) {
    fmt.println("Hello World")
    if argc > 1 { fmt.println(argv[1]) }
}
EOF
"$seed" help | grep -q 'build-ir'
"$seed" lex 'a file.yc' > lex.log
"$seed" parse 'a file.yc' > parse.log
"$seed" check 'a file.yc'
"$seed" resolve 'a file.yc'
"$seed" ll 'a file.yc' -o 'IR with spaces'
cmp 'IR with spaces/merged.ll' 'IR with spaces/a file.ll'
"$seed" run 'a file.yc' --keep-obj -o 'native with spaces' -- 'argument with spaces' > run.log
grep -qx 'Hello World' run.log
grep -qx 'argument with spaces' run.log
test -f 'native with spaces/merged.o'
test -f 'native with spaces/yc_runtime.o'
mkdir src
cp 'a file.yc' src/main.yc
printf '{"src":["src"],"output":"configured output"}\n' > YCPL.json
ln -s . src/cycle
"$seed" build-ir .
test -f 'configured output/merged.ll'
"$seed" build-ir . -o 'explicit output'
test -f 'explicit output/merged.ll'
printf '#!/usr/bin/env bash\nprintf "21.1.0\\n"\n' > fake-llvm-config
chmod +x fake-llvm-config
if LLVM_CONFIG="$PWD/fake-llvm-config" "$seed" build-ir 'a file.yc' -o invalid-version > version.log 2>&1; then
  printf 'LLVM major mismatch was accepted\n' >&2
  exit 1
fi
grep -q 'requires LLVM 22' version.log
test ! -e invalid-version/merged.ll
printf 'fn main() {\n  println(1, }\n' > malformed.yc
if "$seed" check malformed.yc > malformed.log 2>&1; then exit 1; fi
grep -q "malformed.yc:2:.*expected ')'" malformed.log
printf 'Rust CLI, paths, arguments, project output, cycles and LLVM version verified\n'
