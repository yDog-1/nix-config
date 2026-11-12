{pkgs, ...}: {
  imports = [
    ./ghostty.nix
    ./tmux.nix
  ];

  home.sessionVariables.TERMINAL = "ghostty";
  home.packages = [pkgs.zellij];
}
