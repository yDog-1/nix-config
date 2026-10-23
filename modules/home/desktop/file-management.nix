{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    xarchiver
    ffmpegthumbnailer
  ];

  xfconf.settings.thunar = {
    "last-show-hidden" = true;
  };

  xdg = {
    configFile = {
      "xfce4/helpers.rc".text = ''
        TerminalEmulator=wezterm
      '';

      "Thunar/uca.xml" = {
        # Replace the default action file created by Thunar on first launch.
        force = true;
        text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <actions>
            <action>
              <icon>utilities-terminal</icon>
              <name>Open Terminal Here</name>
              <unique-id>1792674492960118-1</unique-id>
              <command>${pkgs.wezterm}/bin/wezterm start --cwd %f</command>
              <description>Open WezTerm in this directory</description>
              <patterns>*</patterns>
              <startup-notify/>
              <directories/>
            </action>
          </actions>
        '';
      };

      "gtk-3.0/bookmarks".text = ''
        file://${config.home.homeDirectory}/Documents Documents
        file://${config.home.homeDirectory}/Downloads Downloads
        file://${config.home.homeDirectory}/Music Music
        file://${config.home.homeDirectory}/Pictures Pictures
        file://${config.home.homeDirectory}/Videos Videos
      '';
    };

    dataFile."xfce4/helpers/wezterm.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Type=X-XFCE-Helper
      Name=WezTerm
      Icon=org.wezfurlong.wezterm
      X-XFCE-Category=TerminalEmulator
      X-XFCE-Commands=${pkgs.wezterm}/bin/wezterm start --cwd .;
      X-XFCE-CommandsWithParameter=${pkgs.wezterm}/bin/wezterm start --cwd . -- %s;
    '';

    mimeApps = {
      enable = true;
      defaultApplications =
        {
          "inode/directory" = "thunar.desktop";
        }
        // lib.genAttrs [
          "application/gzip"
          "application/vnd.ms-cab-compressed"
          "application/vnd.rar"
          "application/x-7z-compressed"
          "application/x-archive"
          "application/x-arj"
          "application/x-bzip"
          "application/x-bzip-compressed-tar"
          "application/x-bzip1"
          "application/x-bzip1-compressed-tar"
          "application/x-bzip3"
          "application/x-bzip3-compressed-tar"
          "application/x-compress"
          "application/x-compressed-tar"
          "application/x-cpio"
          "application/x-lha"
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
          "application/x-rzip"
          "application/x-rzip-compressed-tar"
          "application/x-tar"
          "application/x-tarz"
          "application/x-tzo"
          "application/x-xz"
          "application/x-xz-compressed-tar"
          "application/x-zstd-compressed-tar"
          "application/zip"
          "application/zstd"
        ] (_: "xarchiver.desktop");
    };
  };
}
