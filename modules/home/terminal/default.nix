{pkgs, ...}: {
  imports = [
    ./herdr.nix
    ./kitty.nix
    ./tmux.nix
  ];

  home.sessionVariables.TERMINAL = "kitty";
  home.packages = [pkgs.zellij];
}
