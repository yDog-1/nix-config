{
  pkgs,
  _config,
  ...
}: let
  sheldonConfig = {
    shell = "zsh";

    plugins = {
      powerlevel10k = {
        github = "romkatv/powerlevel10k";
      };

      fast-syntax-highlighting = {
        github = "zdharma-continuum/fast-syntax-highlighting";
      };

      "zeno.zsh" = {
        github = "yuki-yano/zeno.zsh";
        hooks.post = ''
          bindkey ' '  zeno-auto-snippet
          bindkey '^m' zeno-auto-snippet-and-accept-line
          bindkey '^i' zeno-completion
          bindkey '^r' zeno-history-selection
          bindkey '^x' zeno-insert-snippet
          bindkey '^g' zeno-ghq-cd
        '';
      };

      zsh-completions = {
        github = "zsh-users/zsh-completions";
        hooks.post = ''
          # FPATHにzsh-completionsを追加
          FPATH=$HOME/.local/share/sheldon/repos/github.com/zsh-users/zsh-completions/src:$FPATH
          # 補完システムを初期化
          autoload -Uz compinit
          compinit
        '';
      };

      zsh-autosuggestions = {
        github = "zsh-users/zsh-autosuggestions";
        hooks.post = ''
          bindkey '^[l'  autosuggest-accept
        '';
      };
    };
  };
in {
  # Sheldonパッケージをインストール
  home.packages = with pkgs; [
    sheldon
  ];

  # Sheldon設定ファイルをNixで管理
  xdg.configFile."sheldon/plugins.toml".source =
    (pkgs.formats.toml {}).generate "plugins.toml" sheldonConfig;

  # ZshでSheldonを初期化
  programs.zsh = {
    # zsh-autosuggestions - Sheldon経由で管理されるため、Nixでは無効化
    autosuggestion.enable = false;

    initContent = ''
      command -v sheldon >/dev/null 2>&1 && eval "$(sheldon source)"
      # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
      [[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"
    '';

    sessionVariables = {
      ZENO_GIT_CAT = "bat --color=always";
      ZENO_GIT_TREE = "exa --tree";
    };
  };
}
