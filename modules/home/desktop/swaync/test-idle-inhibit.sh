#!/usr/bin/env bash
set -u

script="${1:?usage: test-idle-inhibit.sh <idle-inhibit.sh>}"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/bin"
flag="$tmp/hypridle-active"
{
  # No /usr/bin/env inside the Nix build sandbox.
  printf '#!%s\n' "$(command -v bash)"
  cat <<'STUB'
case "$*" in
  "--user is-active --quiet hypridle.service") [ -e "$STUB_ACTIVE_FLAG" ] && exit 0 || exit 3 ;;
  "--user start hypridle.service") : > "$STUB_ACTIVE_FLAG" ;;
  "--user stop hypridle.service") rm -f "$STUB_ACTIVE_FLAG" ;;
  *) echo "unexpected systemctl call: $*" >&2; exit 1 ;;
esac
STUB
} > "$tmp/bin/systemctl"
chmod +x "$tmp/bin/systemctl"
export PATH="$tmp/bin:$PATH"
export STUB_ACTIVE_FLAG="$flag"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

expect_state() {
  local got
  got=$(bash "$script" state) || fail "state exited non-zero"
  [ "$got" = "$1" ] || fail "state = '$got', want '$1'"
}

expect_toggle() {
  local want=$1 running
  shift
  env "$@" bash "$script" toggle || fail "toggle exited non-zero"
  if [ -e "$flag" ]; then running=started; else running=stopped; fi
  [ "$running" = "$want" ] || fail "hypridle $running after toggle, want $want"
}

# hypridle running means idle is not inhibited
: > "$flag"
expect_state FALSE

# A toggle click reports the state the button just moved to
expect_toggle stopped SWAYNC_TOGGLE_STATE=true
expect_state TRUE
expect_toggle started SWAYNC_TOGGLE_STATE=false
expect_state FALSE

# Missing env (e.g. manual run) falls back to resuming idle handling
expect_toggle stopped SWAYNC_TOGGLE_STATE=true
expect_toggle started
expect_state FALSE

bash "$script" bogus 2> /dev/null && fail "unknown action accepted"

echo "idle-inhibit ok"
