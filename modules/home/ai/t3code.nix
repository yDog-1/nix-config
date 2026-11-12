{
  config,
  lib,
  pkgs,
  ...
}: let
  t3Service = pkgs.writeShellApplication {
    name = "t3code-service";
    runtimeInputs = [pkgs.coreutils pkgs.tailscale];
    text = ''
      OPENROUTER_API_KEY="$(cat ${lib.escapeShellArg config.sops.secrets.openrouter_api_key.path})"
      export OPENROUTER_API_KEY
      tailscaleIp="$(tailscale ip -4)"
      test -n "$tailscaleIp"
      exec ${pkgs.llm-agents.t3code}/bin/t3 serve --host "$tailscaleIp" --port 3773
    '';
  };
  t3Completion = pkgs.runCommand "t3-zsh-completion" {} ''
    export HOME="$TMPDIR"
    ${pkgs.llm-agents.t3code}/bin/t3 --completions zsh > "$out"
  '';
in {
  sops.secrets.openrouter_api_key = {};

  systemd.user.services.t3code = {
    Unit = {
      Requires = ["sops-nix.service"];
      After = ["sops-nix.service"];
    };
    Service = {
      WorkingDirectory = config.home.homeDirectory;
      ExecStart = lib.getExe t3Service;
      Restart = "on-failure";
      RestartSec = 5;
      UMask = "0077";
    };
    Install.WantedBy = ["default.target"];
  };

  home.packages = [
    pkgs.llm-agents.t3code
    pkgs.llm-agents.t3code.desktop
  ];

  xdg.desktopEntries.t3code = {
    name = "T3 Code";
    genericName = "AI coding agent";
    comment = "Launch the T3 Code desktop app";
    exec = "${pkgs.llm-agents.t3code.desktop}/bin/t3code-desktop";
    terminal = false;
    categories = ["Development"];
  };

  programs.zsh.initContent = lib.mkOrder 1500 ''
    source ${t3Completion}
  '';
}
