# Forward lock options, including --update and --reinstall, before preparing
# dependencies. If locking or caching fails, propagate the error to the caller.
sheldon lock "$@"

zeno_root="${ZENO_ROOT:-${SHELDON_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/sheldon}/repos/github.com/yuki-yano/zeno.zsh}"
deno cache --node-modules-dir=auto --no-lock --no-check "$zeno_root/src/cli.ts"
