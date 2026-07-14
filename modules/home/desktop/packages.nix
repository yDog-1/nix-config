{pkgs, ...}: {
  imports = [
    ./image-viewer.nix
    ./file-management.nix
  ];

  home.packages = with pkgs; [
    hyprshot
    hypridle
    hyprlock
    hyprpaper
    waypaper
    nwg-displays
    pyprland
    wtype
    xrandr
    xdg-utils
    polkit_gnome

    gnome-disk-utility
    baobab
    simple-scan
    system-config-printer
    pavucontrol

    heroic
    discord
    wezterm

    libsForQt5.qt5ct
    qt6Packages.qt6ct
    kdePackages.qtstyleplugin-kvantum
  ];
}
