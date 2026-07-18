{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  mcp-servers = inputs.mcp-servers-nix;
  opencodeConfig = mcp-servers.lib.mkConfig pkgs {
    flavor = "opencode";
    fileName = "opencode.json";

    programs = {
      context7 = {
        enable = true;
      };
      tavily = {
        enable = true;
        passwordCommand = {
          TAVILY_API_KEY = [
            "cat"
            "${config.sops.secrets.tavily_api_key.path}"
          ];
        };
      };
    };

    settings = {
      "$schema" = "https://opencode.ai/config.json";
      instructions = [
        "CLAUDE.md"
        "AGENTS.md"
      ];
      permission = {
        edit = "ask";
        bash = {
          "*" = "ask";
          "git blame *" = "allow";
          "git branch" = "allow";
          "git branch --list" = "allow";
          "git branch --show-current" = "allow";
          "git config --get *" = "allow";
          "git config --get-all *" = "allow";
          "git config --get-regexp *" = "allow";
          "git config --get-urlmatch *" = "allow";
          "git config --list *" = "allow";
          "git describe *" = "allow";
          "git diff *" = "allow";
          "git grep *" = "allow";
          "git log *" = "allow";
          "git ls-files *" = "allow";
          "git remote" = "allow";
          "git remote -v" = "allow";
          "git remote get-url *" = "allow";
          "git rev-parse *" = "allow";
          "git show *" = "allow";
          "git stash list *" = "allow";
          "git status *" = "allow";
          "git tag" = "allow";
          "git tag --list" = "allow";
        };
        webfetch = "allow";
      };
      agent = {
        build = {
          mode = "primary";
          tools = {
            "*" = true;
          };
          permission = {
            edit = "allow";
            bash = "allow";
            webfetch = "allow";
          };
        };
        plan = {
          mode = "primary";
          permission = {
            edit = "deny";
          };
        };
      };
    };
  };
in {
  home.sessionVariables = {
    OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
  };

  xdg.configFile."opencode/opencode.json".source = opencodeConfig;

  programs.opencode = {
    package = pkgs.llm-agents.opencode;
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
}
