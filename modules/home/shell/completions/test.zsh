emulate -LR zsh
setopt no_unset

if [[ ${1-} == --child ]]; then
  setopt err_exit pipe_fail
  for command in uvx lazygit opencode layat pi fzf rustc rustdoc bunx; do
    if [[ -z ${_comps[$command]-} ]]; then
      print -u2 -r -- "Missing completion registration for $command"
      exit 1
    fi
  done
  pip_pattern='pip[0-9.]#'
  if [[ ${_postpatcomps[$pip_pattern]-} != _pip ]]; then
    print -u2 -r -- 'Missing pip/pip3 pattern registration'
    exit 1
  fi
  pip_files=(${^fpath}/_pip(N))
  if [[ $pip_files[1] == $NIX_PROFILES/share/zsh/site-functions/_pip ]]; then
    print -u2 -r -- "Wrong pip completion precedence: $pip_files[1]"
    exit 1
  fi
  unsetopt err_exit
  typeset -a candidates
  typeset result_file=$2
  compadd() {
    local -a added
    builtin compadd -A added "$@"
    candidates+=("${added[@]}")
    builtin compadd "$@"
  }
  capture-completion() {
    compstate[vared]=''
    _main_complete
    print -rl -- "${candidates[@]}" > "$result_file"
  }
  zle -C capture-completion .complete-word capture-completion
  bindkey '^I' capture-completion
  print -r -- COMPLETION-READY
  vared -c completion_line
  print -r -- COMPLETION-DONE
  exit
fi

setopt err_exit pipe_fail
zmodload zsh/zpty
script=${0:A}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

check-candidate() {
  local line=$1 expected=$2 terminal
  local result=$work/candidates
  rm -f "$result"
  [[ $startup != fresh ]] || rm -f "$HOME/.zcompdump"
  zpty completion zsh -d -i "$script" --child "$result"
  zpty -r completion terminal '*COMPLETION-READY*'
  if [[ $terminal == *'command not found'* || $terminal == *'no such file or directory'* || $terminal == *'compadd: '* ]]; then
    print -u2 -r -- "Shell startup failed: ${(qqq)terminal}"
    zpty -d completion
    return 1
  fi
  zpty -w -n completion "$line"$'\t\n'
  if ! zpty -r completion terminal '*COMPLETION-DONE*'; then
    print -u2 -r -- "Completion did not finish for ${(qqq)line}: ${(qqq)terminal}"
    zpty -d completion
    return 1
  fi
  zpty -d completion
  if [[ ! -f $result ]] || ! grep -qE -- "^${expected}[[:space:]]*$" "$result"; then
    print -u2 -r -- "Missing candidate ${(qqq)expected} for ${(qqq)line}: ${(qqq)terminal}"
    [[ ! -f $result ]] || print -u2 -r -- "Candidates: $(<$result)"
    return 1
  fi
  print -r -- "Completed ${(qqq)line} with ${(qqq)expected}"
}

for startup in fresh cached; do
  print -r -- "Testing $startup compinit through generated Home Manager .zshrc"
  check-candidate 'bunx --silen' --silent
  check-candidate 'uvx --ver' --version
  check-candidate 'lazygit --ver' --version
  check-candidate 'opencode upg' upgrade
  check-candidate 'pi --ver' --version
  check-candidate 'fzf --ver' --version
  check-candidate 'rustc --ver' --version
  check-candidate 'rustdoc --ver' --version
  check-candidate 'layat app' apply
  check-candidate 'pip ins' install
  check-candidate 'pip3 ins' install
  [[ -s $HOME/.zcompdump ]]
done
print -r -- 'Completion registrations and candidates passed'
