#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
ycc="${YCC:-$root/bazel-bin/ycc}"
work="$(mktemp -d "${TMPDIR:-/tmp}/ycpl development.XXXXXX")"
trap 'rm -rf "$work"' EXIT
export YCPL_STL_ROOT="${YCPL_STL_ROOT:-$root/stl}"
export YCPL_RUNTIME_SRC="${YCPL_RUNTIME_SRC:-$root/bootstrap/cpp/runtime/yc_runtime.c}"
mkdir -p "$work/lib"
cat > "$work/value.yc" <<'YC'
pub fn answer() i32 { return 42 }
YC
cat > "$work/lib/math.yc" <<'YC'
import "../value.yc" as value
pub fn answer() i32 { return value.answer() }
YC
ln -s ../value.yc "$work/lib/alias.yc"
cat > "$work/main.yc" <<'YC'
import "./lib/math.yc" as math
import "./lib/alias.yc" as alias
import "std/fmt" as fmt
fn main(argc i32, argv *string) i32 {
    fmt.println(math.answer() + alias.answer())
    if argc > 1 { fmt.println(argv[1]) }
    return 0
}
YC
"$ycc" build "$work/main.yc" -o "$work/output with spaces" > "$work/build.log" 2>&1
test "$("$work/output with spaces/merged")" = 84
literal='$(touch injected) ; `echo unsafe` "quoted"'
(cd "$work" && "$ycc" run main.yc -o 'run output' -- "$literal") > "$work/run.log" 2>&1
test ! -e "$work/injected"
grep -Fqx -- "$literal" "$work/run.log"
grep -Fxq 84 "$work/run.log"
for option in -o --output; do
  (cd "$work" && "$ycc" run main.yc -- "$option" 'program data') > "$work/options.log" 2>&1
  grep -Fqx -- "$option" "$work/options.log"
  test -x "$work/build/merged"
  test ! -e "$work/program data"
done
# A symlink back to the main module must reuse its parsed identity.
ln -s main.yc "$work/cycle.yc"
printf 'import "./cycle.yc" as cycle\n' > "$work/cyclic.yc"
mv "$work/main.yc" "$work/main-body"
printf 'import "./cyclic.yc" as ring\n' > "$work/main.yc"
cat "$work/main-body" >> "$work/main.yc"
if ! "$ycc" check "$work/cyclic.yc" > "$work/cycle.log" 2>&1; then
  cat "$work/cycle.log" >&2
  exit 1
fi
printf 'Development workflows: relative imports, symlink identity, spaced paths, literal argv and option separator passed\n'
