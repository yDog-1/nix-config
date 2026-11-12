{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  opencodeCompletion = pkgs.runCommand "opencode-zsh-completion" {} ''
    export HOME="$TMPDIR"
    ${pkgs.llm-agents.opencode2}/bin/opencode2 --completions zsh > "$out"
  '';
  opencode = pkgs.writeShellApplication {
    name = "opencode";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      OPENROUTER_API_KEY="$(cat ${config.sops.secrets.openrouter_api_key.path})"
      export OPENROUTER_API_KEY
      # A private server inherits the tmux pane of this client for vt hooks.
      case "''${1-}" in
        run|mini)
          command="$1"
          shift
          for arg in "$@"; do
            case "$arg" in
              --) break ;;
              --standalone|--server|--server=*) exec ${pkgs.llm-agents.opencode2}/bin/opencode2 "$command" "$@" ;;
            esac
          done
          set -- "$command" --standalone "$@"
          ;;
        acp|api|auth|debug|mcp|models|pair|plugin|reload|serve|service|session|stats|uninstall|update|upgrade)
          ;;
        *)
          for arg in "$@"; do
            case "$arg" in
              --standalone|--server|--server=*) exec ${pkgs.llm-agents.opencode2}/bin/opencode2 "$@" ;;
            esac
          done
          set -- --standalone "$@"
          ;;
      esac
      exec ${pkgs.llm-agents.opencode2}/bin/opencode2 "$@"
    '';
  };
  worktrunkCommitMessage = pkgs.writeShellApplication {
    name = "worktrunk-commit-message";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      config_dir="$(mktemp -d)"
      trap 'rm -rf "$config_dir"' EXIT
      cp ${./commit-message.json} "$config_dir/opencode.json"
      env -u OPENCODE_CONFIG -u OPENCODE_CONFIG_CONTENT \
        OPENCODE_CONFIG_DIR="$config_dir" \
        OPENCODE_CONFIG_PROJECT_DISABLE=true \
        OPENCODE_DISABLE_CLAUDE_CODE=true \
        ${opencode}/bin/opencode run --agent commit-message "$@"
    '';
  };
  opencodeConfig = inputs.mcp-servers-nix.lib.mkConfig pkgs {
    flavor = "opencode";
    fileName = "opencode.json";

    programs.tavily = {
      enable = true;
      passwordCommand.TAVILY_API_KEY = [
        "cat"
        "${config.sops.secrets.tavily_api_key.path}"
      ];
    };

    settings = builtins.fromJSON (builtins.readFile ./opencode.json);
  };
  opencodeVdeTmuxPlugin =
    builtins.replaceStrings
    ["@vde-tmux@"]
    ["${pkgs.vde-tmux}"]
    (builtins.readFile ./vde-tmux-v2.ts);
in {
  xdg.configFile = {
    "opencode/AGENTS.md".source = ./AGENTS.md;
    "opencode/opencode.json".source = opencodeConfig;
    "opencode/plugins/vde-tmux.ts".text = opencodeVdeTmuxPlugin;
  };

  home.packages = [worktrunkCommitMessage];

  programs = {
    opencode = {
      package = opencode;
      enable = true;
    };

    zsh.initContent = lib.mkOrder 1500 ''
      source ${opencodeCompletion}
    '';
  };

  sops.secrets.tavily_api_key = {};
  sops.secrets.openrouter_api_key = {};
}
