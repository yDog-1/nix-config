{pkgs, ...}: let
  codex = pkgs.writeShellScriptBin "codex" ''
    exec "${pkgs.bun}/bin/bunx" "@openai/codex@latest" "$@"
  '';
  npx = "${pkgs.nodejs}/bin/npx";
  uvx = "${pkgs.uv}/bin/uvx";
in {
  home.packages = [
    codex
  ];
  programs.codex = {
    enable = true;
    package = null;
    settings = {
      approval_policy = "on-request";
      web_search = "live";
      features = {
        collaboration_modes = true;
        multi_agent = true;
      };
      tui = {
        status_line = [
          "git-branch"
          "model-name"
          "context-remaining"
          "five-hour-limit"
          "weekly-limit"
        ];
      };
      mcp_servers = {
        context7 = {
          command = "${npx}";
          args = [
            "-y"
            "@upstash/context7-mcp"
          ];
        };
        serena = {
          command = "${uvx}";
          args = [
            "--from"
            "git+https://github.com/oraios/serena"
            "serena"
            "start-mcp-server"
            "--context=chatgpt"
            "--open-web-dashboard=false"
          ];
        };
        memory = {
          command = "${npx}";
          args = [
            "-y"
            "@modelcontextprotocol/server-memory"
          ];
        };
      };
    };
  };
}
