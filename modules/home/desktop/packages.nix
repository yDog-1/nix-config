{pkgs, ...}: {
  home.packages = with pkgs; [
    rofi
    waybar
    hyprshot
    hypridle
    hyprlock
    hyprpaper
    nwg-displays
    pyprland
    wtype
    xdg-utils
    polkit_gnome

    libsForQt5.qt5ct
    qt6Packages.qt6ct
    kdePackages.qtstyleplugin-kvantum
  ];
}
