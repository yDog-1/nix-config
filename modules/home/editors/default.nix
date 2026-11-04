{pkgs, ...}: {
  imports = [./neovim.nix];

  home.packages = with pkgs; [vim tree-sitter];
}
