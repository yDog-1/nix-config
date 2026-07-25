{
  config,
  pkgs,
  ...
}: {
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

    "org/nemo/window-state" = {
      sidebar-bookmark-breakpoint = 5;
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

  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file://${config.home.homeDirectory}/Documents Documents
    file://${config.home.homeDirectory}/Downloads Downloads
    file://${config.home.homeDirectory}/Music Music
    file://${config.home.homeDirectory}/Pictures Pictures
    file://${config.home.homeDirectory}/Videos Videos
  '';
}
