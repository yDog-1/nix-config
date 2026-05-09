{
  _pkgs,
  _config,
  ...
}: {
  imports = [
    ./zsh-environment.nix
    ./zsh-keybindings.nix
  ];

  programs.zsh = {
    enable = true;

    # 履歴設定
    history = {
      size = 10000;
      save = 10000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
      extended = true;
    };

    # Zshオプション
    autocd = true; # ディレクトリ名だけでcd

    # その他のZshオプション
    initContent = ''
      # 補完システムを最初に初期化
      autoload -Uz compinit
      compinit

      # 補完の詳細設定
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' group-name '''
      zstyle ':completion:*:descriptions' format '%B%d%b'

      # ディレクトリスタック
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT

      # コマンド履歴
      setopt HIST_REDUCE_BLANKS
      setopt HIST_VERIFY
      setopt BANG_HIST

      # その他の便利なオプション
      setopt INTERACTIVE_COMMENTS
      setopt NO_BEEP
      setopt EXTENDED_GLOB
    '';
  };
}
