{
  pkgs,
  config,
  lib,
  ...
}: let
  pi = pkgs.writeShellApplication {
    name = "pi";
    text = ''
      OPENROUTER_API_KEY="$(cat ${config.sops.secrets.openrouter_api_key.path})"
      export OPENROUTER_API_KEY
      exec ${lib.getExe pkgs.llm-agents.pi} "$@"
    '';
  };
in {
  programs.pi-coding-agent = {
    enable = true;
    package = pi;
  };
  sops.secrets.openrouter_api_key = {};
}
