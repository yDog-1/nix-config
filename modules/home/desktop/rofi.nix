{
  inputs,
  pkgs,
  ...
}: let
  catppuccin-rofi-theme = pkgs.writeText "catppuccin-rofi-mocha.rasi" ''
    @import "${inputs.catppuccin-rofi}/themes/catppuccin-mocha.rasi"
    @import "${inputs.catppuccin-rofi}/catppuccin-default.rasi"
  '';
in {
  programs.rofi = {
    enable = true;
    settings = {
      kb-move-char-forward = "Right";
      show-icons = true;
    };
    theme = {
      "@import" = "${catppuccin-rofi-theme}";
    };
  };
}
