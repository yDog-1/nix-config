{
  lib,
  pkgs,
  ...
}: let
  wallpapers = import ./wallpaper-sources.nix;
in {
  services.hyprpaper.enable = true;

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

  systemd.user.services.waypaper-random = {
    Unit = {
      Description = "Set a random wallpaper";
      Requires = ["hyprpaper.service"];
      After = ["hyprpaper.service"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.waypaper} --random";
    };
  };

  systemd.user.timers.waypaper-random = {
    Unit = {
      Description = "Periodically set a random wallpaper";
      PartOf = ["graphical-session.target"];
    };
    Timer = {
      OnActiveSec = "1s";
      OnUnitActiveSec = "10m";
      Unit = "waypaper-random.service";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
