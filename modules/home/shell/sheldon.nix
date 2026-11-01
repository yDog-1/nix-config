{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      sheldon
    ];
  };

  programs.zsh = {
    autosuggestion.enable = false;

    initContent = ''
      if [[ -t 0 && -t 1 && -o zle ]]; then
        command -v sheldon >/dev/null 2>&1 && eval "$(sheldon source)"

        fzf_default_completion=expand-or-complete
        source <(${pkgs.fzf}/bin/fzf --zsh)
        (( ''${+widgets[zeno-completion]} )) && bindkey '^I' zeno-completion
      fi
    '';

    sessionVariables = {
      DENO_SQLITE_PATH = "${pkgs.sqlite.out}/lib/libsqlite3.so";
      ZENO_GIT_CAT = "bat --color=always";
      ZENO_GIT_TREE = "eza --tree";
    };
  };
}
