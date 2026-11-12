let
  catppuccin = import ../../../lib/style/catppuccin-colors.nix;
in {
  nixpkgs.overlays = [
    (_final: prev: {
      ghostty = prev.symlinkJoin {
        name = "ghostty-no-ime";
        paths = [prev.ghostty];
        nativeBuildInputs = [prev.makeWrapper];
        postBuild = ''
          wrapProgram "$out/bin/ghostty" \
            --set GTK_IM_MODULE none
        '';
        meta = prev.ghostty.meta;
      };
    })
  ];

  programs.ghostty = {
    enable = true;
    enableZshIntegration = false;
    settings = {
      theme = "Catppuccin Mocha";
      font-family = "PlemolJP Console NF";
      font-size = 13;
      background-opacity = 0.8;
      window-padding-x = 0;
      window-padding-y = 0;
      window-decoration = false;
      gtk-tabs-location = "hidden";
      confirm-close-surface = false;
      cursor-style = "block";
      cursor-style-blink = false;
      selection-background = catppuccin.colors.mauve;
    };
  };
}
