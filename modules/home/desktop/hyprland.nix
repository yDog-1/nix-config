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

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
      };

      monitor = [
        "DP-3,2560x1440@144.0,0x0,1.0"
        "HDMI-A-1,1920x1080@75.0,2560x360,1.0"
      ];

      workspace = [
        "1, monitor:DP-3, default:true"
        "2, monitor:DP-3"
        "3, monitor:DP-3"
        "4, monitor:DP-3"
        "5, monitor:DP-3"
        "6, monitor:HDMI-A-1, default:true"
        "7, monitor:HDMI-A-1"
        "8, monitor:HDMI-A-1"
        "9, monitor:HDMI-A-1"
        "10, monitor:HDMI-A-1"
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
        accel_profile = "flat";
        touchpad = {
          natural_scroll = true;
        };
      };

      device = [
        {
          name = "getech-huge-trackball-1";
          accel_profile = "adaptive";
        }
        {
          name = "logitech-g603-1";
          sensitivity = 0.4;
        }
      ];

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
        "ironbar"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "pypr"
        # first, run waypaper
        "waypaper --random"
        # automatically change wallpaper every 10 minutes
        "while true; do sleep 600; waypaper --random; done"
        "fcitx5-remote -r"
        "fcitx5 -d --replace"
        "vicinae server"
      ];

      bind =
        [
          "$mod, T, exec, $terminal"
          "$mod, B, exec, $browser"
          "$mod, Space, exec, vicinae toggle"
          "$mod, E, exec, $terminal start -- yazi"
          "$mod, Q, killactive"
          "$mod SHIFT, M, exit"
          "$mod, G, togglefloating"
          "$mod, I, exec, vim-anywhere-wayland"
          "$mod, F, fullscreen"
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
          "$mod CTRL, H, workspace, -1"
          "$mod CTRL, L, workspace, +1"
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
