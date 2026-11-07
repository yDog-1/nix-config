set -euo pipefail

script=$(realpath "$1")
root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT
mkdir -p "$root/bin" "$root/home"
export HOME="$root/home" TEST_LOG="$root/calls"
export PATH="$root/bin:$PATH"
unset ZENO_ROOT SHELDON_DATA_DIR XDG_DATA_HOME

printf '#!%s\n' "$(command -v bash)" > "$root/bin/sheldon"
cat >> "$root/bin/sheldon" <<'EOF'
printf 'sheldon' >> "$TEST_LOG"
printf ' <%s>' "$@" >> "$TEST_LOG"
printf '\n' >> "$TEST_LOG"
exit "${SHELDON_STATUS:-0}"
EOF
printf '#!%s\n' "$(command -v bash)" > "$root/bin/deno"
cat >> "$root/bin/deno" <<'EOF'
printf 'deno' >> "$TEST_LOG"
printf ' <%s>' "$@" >> "$TEST_LOG"
printf '\n' >> "$TEST_LOG"
exit "${DENO_STATUS:-0}"
EOF
chmod +x "$root/bin/"*

check() {
  local expected_root="$1"
  shift
  : > "$TEST_LOG"
  bash -euo pipefail "$script" "$@"
  printf 'sheldon <lock>' > "$root/expected"
  if (( $# )); then
    printf ' <%s>' "$@" >> "$root/expected"
  fi
  printf '\ndeno <cache> <--node-modules-dir=auto> <--no-lock> <--no-check> <%s/src/cli.ts>\n' \
    "$expected_root" >> "$root/expected"
  diff -u "$root/expected" "$TEST_LOG"
}

check "$HOME/.local/share/sheldon/repos/github.com/yuki-yano/zeno.zsh"
export XDG_DATA_HOME="$root/xdg data"
check "$XDG_DATA_HOME/sheldon/repos/github.com/yuki-yano/zeno.zsh" --update
export SHELDON_DATA_DIR="$root/sheldon data"
check "$SHELDON_DATA_DIR/repos/github.com/yuki-yano/zeno.zsh" --reinstall
export ZENO_ROOT="$root/custom zeno"
check "$ZENO_ROOT" --update --reinstall

# Never attempt preparation after a failed plugin update.
: > "$TEST_LOG"
export SHELDON_STATUS=42
status=0
bash -euo pipefail "$script" --update || status=$?
[[ $status == 42 ]]
[[ $(wc -l < "$TEST_LOG") == 1 ]]
unset SHELDON_STATUS

# Cache failures must not silently report a successful synchronization.
export DENO_STATUS=43
status=0
bash -euo pipefail "$script" || status=$?
[[ $status == 43 ]]
echo 'sheldon-sync tests passed'
