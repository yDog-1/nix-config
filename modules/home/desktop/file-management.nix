{
  config,
  lib,
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
    defaultApplications =
      {
        "inode/directory" = "nemo.desktop";
      }
      // lib.genAttrs [
        "application/bzip2"
        "application/gzip"
        "application/vnd.ms-cab-compressed"
        "application/vnd.rar"
        "application/x-7z-compressed"
        "application/x-7z-compressed-tar"
        "application/x-ace"
        "application/x-alz"
        "application/x-ar"
        "application/x-archive"
        "application/x-arj"
        "application/x-brotli"
        "application/x-bzip-brotli-tar"
        "application/x-bzip"
        "application/x-bzip-compressed-tar"
        "application/x-bzip1"
        "application/x-bzip1-compressed-tar"
        "application/x-bzip3"
        "application/x-bzip3-compressed-tar"
        "application/x-cabinet"
        "application/x-compress"
        "application/x-compressed-tar"
        "application/x-cpio"
        "application/x-gtar"
        "application/x-gzip"
        "application/x-lha"
        "application/x-lhz"
        "application/x-lrzip"
        "application/x-lrzip-compressed-tar"
        "application/x-lz4"
        "application/x-lz4-compressed-tar"
        "application/x-lzip"
        "application/x-lzip-compressed-tar"
        "application/x-lzma"
        "application/x-lzma-compressed-tar"
        "application/x-lzop"
        "application/x-rar"
        "application/x-rar-compressed"
        "application/x-rzip"
        "application/x-rzip-compressed-tar"
        "application/x-stuffit"
        "application/x-tar"
        "application/x-tarz"
        "application/x-tzo"
        "application/x-xar"
        "application/x-xz"
        "application/x-xz-compressed-tar"
        "application/x-zip"
        "application/x-zip-compressed"
        "application/x-zoo"
        "application/x-zstd-compressed-tar"
        "application/zip"
        "application/zstd"
      ] (_: "org.gnome.FileRoller.desktop");
  };

  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file://${config.home.homeDirectory}/Documents Documents
    file://${config.home.homeDirectory}/Downloads Downloads
    file://${config.home.homeDirectory}/Music Music
    file://${config.home.homeDirectory}/Pictures Pictures
    file://${config.home.homeDirectory}/Videos Videos
  '';
}
