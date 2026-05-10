{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = true;

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "wezterm";
      "$browser" = "vivaldi --ozone-platform=wayland";

      source = [
        "~/.config/hypr/monitors.conf"
      ];

      env = [
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "QT_QPA_PLATFORM,wayland;xcb"
        "LIBVA_DRIVER_NAME,nvidia"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];

      input = {
        kb_layout = "jp";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        layout = "dwindle";
      };

      decoration = {
        rounding = 6;
        blur = {
          enabled = true;
          size = 4;
          passes = 2;
        };
      };

      animations.enabled = true;

      exec-once = [
        "waybar"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "pypr"
        "fcitx5-remote -r"
        "fcitx5 -d --replace"
      ];

      bind =
        [
          "$mod, T, exec, $terminal"
          "$mod, B, exec, $browser"
          "$mod, D, exec, rofi -show drun"
          "$mod, E, exec, $terminal start -- yazi"
          "$mod, Q, killactive"
          "$mod SHIFT, M, exit"
          "$mod, G, togglefloating"
          "$mod, I, exec, vim-anywhere-wayland"
          "$mod, F, fullscreen"
          "$mod CTRL, L, exec, loginctl lock-session"
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, L, movewindow, r"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, J, movewindow, d"
          ", Print, exec, hyprshot -m window -o ~/Pictures/Screenshots"
        ]
        ++ (
          builtins.concatLists (builtins.genList (
              i: let
                ws = i + 1;
                key = toString (
                  if ws == 10
                  then 0
                  else ws
                );
                workspace = toString ws;
              in [
                "$mod, ${key}, workspace, ${workspace}"
                "$mod SHIFT, ${key}, movetoworkspace, ${workspace}"
              ]
            )
            10)
        );

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}
