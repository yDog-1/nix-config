{
  pkgs,
  inputs,
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
      git = {
        enable = true;
      };
      memory = {
        enable = true;
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
        bash = "ask";
        webfetch = "allow";
      };
      mcp = {
        tavily = {
          type = "remote";
          url = "https://mcp.tavily.com/mcp";
          oauth = {};
          enabled = true;
        };
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
          tools = {
            write = false;
            edit = false;
            bash = false;
            git_git_commit = false;
            git_git_add = false;
            git_git_reset = false;
            "git_git_create*" = false;
            "serena_create*" = false;
            "serena_replace*" = false;
            "serena_insert*" = false;
            serena_execute_shell_command = false;
          };
        };
        "code-reviewer" = {
          description = "Reviews code for best practices and potential issues";
          mode = "subagent";
          prompt = "You are a code reviewer. Focus on security, performance, and maintainability.";
          tools = {
            write = false;
            edit = false;
            "serena_create*" = false;
            "serena_replace*" = false;
            "serena_insert*" = false;
            serena_execute_shell_command = false;
          };
        };
      };
    };
  };
in {
  xdg.configFile."opencode/opencode.json".source = opencodeConfig;

  programs.opencode = {
    enable = true;
  };
}
