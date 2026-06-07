{pkgs, ...}: {
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
    nemo
    nemo-fileroller
    file-roller
    ffmpegthumbnailer
    simple-scan
    system-config-printer
    pavucontrol

    libsForQt5.qt5ct
    qt6Packages.qt6ct
    kdePackages.qtstyleplugin-kvantum
  ];

  dconf.settings = {
    "org/nemo/preferences" = {
      show-hidden-files = true;
    };

    "org/cinnamon/desktop/default-applications/terminal" = {
      exec = "wezterm";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "nemo.desktop";
    };
  };
}
