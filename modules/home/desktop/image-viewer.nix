{pkgs, ...}: {
  home.packages = with pkgs; [
    gthumb
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/avif" = "org.gnome.gthumb.desktop";
      "image/bmp" = "org.gnome.gthumb.desktop";
      "image/gif" = "org.gnome.gthumb.desktop";
      "image/jpeg" = "org.gnome.gthumb.desktop";
      "image/png" = "org.gnome.gthumb.desktop";
      "image/svg+xml" = "org.gnome.gthumb.desktop";
      "image/svg+xml-compressed" = "org.gnome.gthumb.desktop";
      "image/tiff" = "org.gnome.gthumb.desktop";
      "image/webp" = "org.gnome.gthumb.desktop";
    };
  };
}
