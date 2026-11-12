{pkgs, ...}: {
  imports = [
    ./herdr.nix
    ./ghostty.nix
    ./tmux.nix
  ];

  home.sessionVariables.TERMINAL = "ghostty";
  home.packages = [pkgs.zellij];
}
