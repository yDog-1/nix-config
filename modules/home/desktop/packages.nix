{pkgs, ...}: {
  imports = [
    ./image-viewer.nix
    ./file-management.nix
  ];

  home.sessionVariables.TERMINAL = "kitty";

  home.packages = with pkgs; [
    hyprshot
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
    easyeffects

    heroic
    discord
    llm-agents.chatgpt
    (proton-authenticator.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [makeWrapper];
      postFixup =
        (old.postFixup or "")
        + ''
          wrapProgram $out/bin/proton-authenticator \
            --set WEBKIT_DISABLE_DMABUF_RENDERER 1
        '';
    }))
    anki
    krita

    libsForQt5.qt5ct
    qt6Packages.qt6ct
    kdePackages.qtstyleplugin-kvantum
  ];
}
