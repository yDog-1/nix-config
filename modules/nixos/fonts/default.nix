{
  inputs,
  lib,
  pkgs,
  ...
}: {
  fonts = {
    packages = with pkgs;
      [
        noto-fonts-cjk-serif
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        (callPackage ./moralerspace-hw.nix {inherit inputs;})
      ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

    fontDir.enable = true;
    fontconfig = {
      defaultFonts = {
        serif = ["Noto Serif CJK JP" "Noto Color Emoji"];
        sansSerif = ["Noto Sans CJK JP" "Noto Color Emoji"];
        monospace = ["Moralerspace Argon HW" "JetBrainsMono Nerd Font" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };
}
