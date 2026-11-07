{
  config,
  lib,
  pkgs,
  ...
}: let
  sheldonSync = pkgs.writeShellApplication {
    name = "sheldon-sync";
    runtimeInputs = [pkgs.sheldon pkgs.deno];
    text = ''
      export DENO_SQLITE_PATH="${pkgs.sqlite.out}/lib/libsqlite3.so"
      ${builtins.readFile ./sync.sh}
    '';
  };
in {
  xdg.configFile."sheldon/plugins.toml".source = ./plugins.toml;

  home = {
    packages = [
      pkgs.sheldon
      sheldonSync
    ];

    # Synchronize against the newly linked config, including on first install.
    # Do not use --update: switching configuration must respect existing pins.
    activation.prepareSheldon = lib.hm.dag.entryAfter ["linkGeneration"] ''
      run ${pkgs.coreutils}/bin/env \
        SHELDON_CONFIG_DIR=${lib.escapeShellArg "${config.xdg.configHome}/sheldon"} \
        ${lib.getExe sheldonSync}
    '';
  };

  programs.zsh = {
    autosuggestion.enable = false;

    initContent = ''
      # sheldon-sync prepares dependencies at activation/plugin update time.
      export ZENO_DISABLE_EXECUTE_CACHE_COMMAND=1
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
