{pkgs, ...}: let
  wallpapers = import ./wallpaper-sources.nix;
in {
  home.file = builtins.listToAttrs (map
    (wallpaper: {
      name = "Pictures/Wallpapers/${wallpaper.name}";
      value.source = pkgs.fetchurl {
        inherit (wallpaper) url hash;
      };
    })
    wallpapers);

  xdg.configFile."waypaper/config.ini".text = ''
    [Settings]
    language = en
    folder = ~/Pictures/Wallpapers
    backend = hyprpaper
    monitors = all
    fill = Fill
    use_xdg_state = True
  '';
}
