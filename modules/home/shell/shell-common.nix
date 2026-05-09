{_pkgs, ...}: {
  # 共通環境変数
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "\${BROWSER:-\"vivaldi\"}";
    LC_ALL = "en_US.UTF-8";

    # Node.js Management
    NVM_DIR = "$HOME/.nvm";

    # Python Management
    PYENV_ROOT = "$HOME/.pyenv";

    # Other Tools
    DPRINT_INSTALL = "$HOME/.dprint";
  };

  # 共通パス設定
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.bun/bin"
    "$PYENV_ROOT/bin"
    "$DPRINT_INSTALL/bin"
  ];
}
