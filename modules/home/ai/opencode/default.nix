{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  opencode = pkgs.writeShellApplication {
    name = "opencode";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      OPENROUTER_API_KEY="$(cat ${config.sops.secrets.openrouter_api_key.path})"
      export OPENROUTER_API_KEY
      exec ${pkgs.llm-agents.opencode}/bin/opencode "$@"
    '';
  };
  opencodeVdeTmuxPlugin =
    builtins.replaceStrings
    ["@vde-tmux@"]
    ["${pkgs.vde-tmux}"]
    (builtins.readFile ./vde-tmux.ts);
in {
  home.sessionVariables = {
    OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
  };

  xdg.configFile."opencode/plugins/vde-tmux.ts".text = opencodeVdeTmuxPlugin;

  programs.opencode = {
    package = opencode;
    enable = true;
  };

  programs.agent-skills = {
    enable = true;
    sources = {
      ast-grep = {
        path = inputs.ast-grep-skill;
        subdir = "ast-grep/skills";
      };
      agent-browser = {
        path = inputs.agent-browser-skill;
        subdir = "skills";
      };
      awesome-copilot = {
        path = inputs.awesome-copilot;
        subdir = "skills";
      };
    };

    # reference to "https://github.com/ryoppippi/dotfiles/blob/c6c366b8fde0851ded440c9560f860af2a235490/nix/modules/home/agent-skills.nix#L46"
    skills.explicit = {
      ast-grep = let
        astGrepBin = lib.getExe pkgs.ast-grep;
      in {
        from = "ast-grep";
        path = "ast-grep";
        packages = [pkgs.ast-grep];
        transform = {
          original,
          dependencies,
        }: let
          patched =
            builtins.replaceStrings
            ["| ast-grep " "ast-grep scan " "ast-grep run "]
            ["| ${astGrepBin} " "${astGrepBin} scan " "${astGrepBin} run "]
            original;
        in ''
          ${patched}

          ${dependencies}
        '';
      };
      agent-browser = let
        agentBrowserBin = lib.getExe pkgs.llm-agents.agent-browser;
      in {
        from = "agent-browser";
        path = "agent-browser";
        packages = [pkgs.llm-agents.agent-browser];
        transform = {original, ...}:
          builtins.replaceStrings
          [
            "Bash(agent-browser:*), Bash(npx agent-browser:*)"
            "Install: `npm i -g agent-browser && agent-browser install`\n\n"
            "agent-browser skills "
            "`agent-browser`"
          ]
          [
            "Bash(${agentBrowserBin}:*)"
            ""
            "${agentBrowserBin} skills "
            "`${agentBrowserBin}`"
          ]
          original;
      };
      git-commit = {
        from = "awesome-copilot";
        path = "git-commit";
      };
    };

    targets = {
      # For general-purpose tools also used by OpenCode.
      agents = {
        enable = true;
        dest = "$HOME/.agents/skills";
        structure = "symlink-tree";
      };
    };
  };

  sops.secrets.tavily_api_key = {};
  sops.secrets.openrouter_api_key = {};
}
