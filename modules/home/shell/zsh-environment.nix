{
  _pkgs,
  _config,
  ...
}: {
  programs.zsh = {
    # 環境初期化スクリプト
    envExtra = ''
      # Secrets
      if [ -f ~/.secrets.env ]; then
        source ~/.secrets.env
      fi
    '';

    profileExtra = ''
      # Homebrew
      if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      elif [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      elif command -v brew >/dev/null 2>&1; then
        eval "$(brew shellenv)"
      fi

      # Node.js Management
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
      command -v nodenv >/dev/null 2>&1 && eval "$(nodenv init - zsh)"

      # Python Management
      command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init - zsh)"

      # Terraform completion
      [ -f "/usr/bin/terraform" ] && complete -C /usr/bin/terraform terraform

      # Deno environment
      [ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"
      [ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
    '';
  };
}
