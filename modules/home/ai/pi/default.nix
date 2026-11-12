{
  config,
  lib,
  pkgs,
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
  piCompletion = pkgs.runCommand "pi-zsh-completion" {} ''
    ${lib.getExe pkgs.carapace} pi zsh > "$out"
    substituteInPlace "$out" \
      --replace-fail 'carapace pi zsh' '${lib.getExe pkgs.carapace} pi zsh'
  '';
in {
  programs.pi-coding-agent = {
    enable = true;
    package = pi;
  };

  programs.zsh.initContent = lib.mkOrder 1500 ''
    source ${piCompletion}
  '';

  sops.secrets.openrouter_api_key = {};
}
