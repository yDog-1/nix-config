{pkgs, ...}: let
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
          bindkey ' ' zeno-auto-snippet
          bindkey '^m' zeno-auto-snippet-and-accept-line
          bindkey '^i' zeno-completion
          bindkey '^r' zeno-history-selection
          bindkey '^x' zeno-insert-snippet
          bindkey '^g' zeno-ghq-cd
        '';
      };

      zsh-completions = {
        github = "zsh-users/zsh-completions";
        apply = ["fpath:src"];
      };

      zsh-autosuggestions = {
        github = "zsh-users/zsh-autosuggestions";
        hooks.post = ''
          bindkey '^[l' autosuggest-accept
        '';
      };
    };
  };
in {
  home = {
    packages = with pkgs; [
      sheldon
    ];

    file.".p10k.zsh".source = ./p10k.zsh;
  };

  xdg.configFile = {
    "sheldon/plugins.toml".source =
      (pkgs.formats.toml {}).generate "plugins.toml" sheldonConfig;

    "zeno/config.yml".source = ./zeno/config.yml;
  };

  programs.zsh = {
    autosuggestion.enable = false;

    initContent = ''
      command -v sheldon >/dev/null 2>&1 && eval "$(sheldon source)"
      [[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"
    '';

    sessionVariables = {
      ZENO_GIT_CAT = "bat --color=always";
      ZENO_GIT_TREE = "eza --tree";
    };
  };
}
