{pkgs, ...}: {
  home.packages = with pkgs; [
    ristretto
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
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
