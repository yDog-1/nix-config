{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      sheldon
    ];

    file.".p10k.zsh".source = ./p10k.zsh;
  };

  programs.zsh = {
    autosuggestion.enable = false;

    initContent = ''
      if [[ -t 0 && -t 1 && -o zle ]]; then
        command -v sheldon >/dev/null 2>&1 && eval "$(sheldon source)"

        fzf_default_completion=expand-or-complete
        source <(${pkgs.fzf}/bin/fzf --zsh)
        (( ''${+widgets[zeno-completion]} )) && bindkey '^I' zeno-completion

        [[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"
      fi
    '';

    sessionVariables = {
      ZENO_GIT_CAT = "bat --color=always";
      ZENO_GIT_TREE = "eza --tree";
    };
  };
}
