#!/usr/bin/env bash
set -euo pipefail

setup="${1:-$(cd "$(dirname "$0")/../.." && pwd)/scripts/setup-llvm.sh}"
if [[ "$setup" != /* ]]; then setup="$PWD/$setup"; fi
work="$(mktemp -d "${TMPDIR:-/tmp}/ycpl-llvm-setup.XXXXXX")"
trap 'rm -rf "$work"' EXIT
mkdir "$work/bin"
export YCPL_TEST_LLVM_PREFIX="$work/not installed yet"
export YCPL_TEST_BREW_LOG="$work/brew.log"
cat > "$work/bin/uname" <<'EOF'
#!/usr/bin/env bash
printf 'Darwin\n'
EOF
cat > "$work/bin/brew" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "$1" in
  --prefix) printf '%s\n' "$YCPL_TEST_LLVM_PREFIX" ;;
  install)
    test "$2" = llvm@22
    mkdir -p "$YCPL_TEST_LLVM_PREFIX/bin"
    printf '#!/usr/bin/env bash\nprintf "22.1.0\\n"\n' > "$YCPL_TEST_LLVM_PREFIX/bin/llvm-config"
    chmod +x "$YCPL_TEST_LLVM_PREFIX/bin/llvm-config"
    printf 'install\n' >> "$YCPL_TEST_BREW_LOG"
    ;;
  *) exit 1 ;;
esac
EOF
chmod +x "$work/bin/uname" "$work/bin/brew"
export PATH="$work/bin:$PATH"
# Homebrew returns a prefix even for a formula that has not been installed.
"$setup" 22 > "$work/first.env"
test -x "$YCPL_TEST_LLVM_PREFIX/bin/llvm-config"
grep -q 'export LLVM_CONFIG=' "$work/first.env"
"$setup" 22 > "$work/second.env"
test "$(wc -l < "$YCPL_TEST_BREW_LOG" | tr -d ' ')" = 1
cmp "$work/first.env" "$work/second.env"
printf 'LLVM setup installs an absent Homebrew formula exactly once\n'
