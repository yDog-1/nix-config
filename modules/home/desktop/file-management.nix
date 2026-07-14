{pkgs, ...}: {
  home.packages = with pkgs; [
    nemo
    nemo-fileroller
    file-roller
    ffmpegthumbnailer
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
