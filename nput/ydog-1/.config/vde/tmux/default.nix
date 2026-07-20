{pkgs}: let
  catppuccin = import ../../../../../lib/style/catppucin-colors.nix;

  colorNames = [
    "base"
    "sky"
    "mauve"
    "red"
    "sapphire"
    "subtext1"
    "surface0"
    "surface1"
    "text"
    "yellow"
    "peach"
  ];

  placeholders = map (name: "@${name}@") colorNames;
  colors = map (name: catppuccin.colors.${name}) colorNames;
in
  pkgs.writeText "vde-tmux-config.yml" (
    builtins.replaceStrings
    placeholders
    colors
    (builtins.readFile ./config.yml)
  )
