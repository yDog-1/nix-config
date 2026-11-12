{
  lib,
  pkgs,
  ...
}: let
  t3Completion = pkgs.runCommand "t3-zsh-completion" {} ''
    export HOME="$TMPDIR"
    ${pkgs.llm-agents.t3code}/bin/t3 --completions zsh > "$out"
  '';
in {
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
