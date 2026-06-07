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
    ristretto
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
      "image/avif" = "org.xfce.ristretto.desktop";
      "image/bmp" = "org.xfce.ristretto.desktop";
      "image/gif" = "org.xfce.ristretto.desktop";
      "image/jpeg" = "org.xfce.ristretto.desktop";
      "image/png" = "org.xfce.ristretto.desktop";
      "image/svg+xml" = "org.xfce.ristretto.desktop";
      "image/tiff" = "org.xfce.ristretto.desktop";
      "image/webp" = "org.xfce.ristretto.desktop";
    };
  };
}
