{
  inputs,
  pkgs,
  ...
}: let
  catppuccin = import ../../../../lib/style/catppucin-colors.nix;
  catppuccinYazi = pkgs.runCommand "catppuccin-yazi-${catppuccin.flavor}-${catppuccin.accent}" {} ''
    mkdir -p $out
    cp ${inputs.catppuccin-yazi}/themes/${catppuccin.flavor}/catppuccin-${catppuccin.flavor}-${catppuccin.accent}.toml $out/flavor.toml
  '';
in {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    flavors = {
      catppuccin-mocha-mauve = catppuccinYazi;
    };
    theme = {
      flavor = {
        dark = "catppuccin-mocha-mauve";
      };
    };
  };
}
