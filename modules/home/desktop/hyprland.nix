{
  lib,
  pkgs,
  ...
}: let
  lua = lib.generators.mkLuaInline;
  exec = command: lua "hl.dsp.exec_cmd(${builtins.toJSON command})";
  bind = key: dispatcher: {
    _args = [
      key
      dispatcher
    ];
  };
  bindMouse = key: dispatcher: {
    _args = [
      key
      dispatcher
      {mouse = true;}
    ];
  };
  env = name: value: {
    _args = [
      name
      value
    ];
  };
in {
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    package = null;
    portalPackage = null;
    systemd.enable = true;

    settings = {
      mod._var = "SUPER";
      terminal._var = "wezterm";
      browser._var = "vivaldi --ozone-platform=wayland";

      monitor = [
        {
          output = "DP-3";
          mode = "2560x1440@144.0";
          position = "0x0";
          scale = 1.0;
        }
        {
          output = "HDMI-A-1";
          mode = "1920x1080@75.0";
          position = "2560x360";
          scale = 1.0;
        }
      ];

      workspace_rule = [
        {
          workspace = "1";
          monitor = "DP-3";
          default = true;
        }
        {
          workspace = "2";
          monitor = "DP-3";
        }
        {
          workspace = "3";
          monitor = "DP-3";
        }
        {
          workspace = "4";
          monitor = "DP-3";
        }
        {
          workspace = "5";
          monitor = "DP-3";
        }
        {
          workspace = "6";
          monitor = "HDMI-A-1";
          default = true;
        }
        {
          workspace = "7";
          monitor = "HDMI-A-1";
        }
        {
          workspace = "8";
          monitor = "HDMI-A-1";
        }
        {
          workspace = "9";
          monitor = "HDMI-A-1";
        }
        {
          workspace = "10";
          monitor = "HDMI-A-1";
        }
      ];

      env = [
        (env "XDG_CURRENT_DESKTOP" "Hyprland")
        (env "XDG_SESSION_DESKTOP" "Hyprland")
        (env "XDG_SESSION_TYPE" "wayland")
        (env "QT_QPA_PLATFORM" "wayland;xcb")
        (env "LIBVA_DRIVER_NAME" "nvidia")
        (env "GBM_BACKEND" "nvidia-drm")
        (env "__GLX_VENDOR_LIBRARY_NAME" "nvidia")
      ];

      config = {
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          force_default_wallpaper = 0;
        };

        input = {
          kb_layout = "jp";
          follow_mouse = 1;
          accel_profile = "flat";
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

        cursor = {
          default_monitor = "DP-3";
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

      bind =
        [
          (bind (lua ''mod .. " + T"'') (lua "hl.dsp.exec_cmd(terminal)"))
          (bind (lua ''mod .. " + B"'') (lua "hl.dsp.exec_cmd(browser)"))
          (bind (lua ''mod .. " + Space"'') (exec "rofi -show drun"))
          (bind (lua ''mod .. " + E"'') (exec "nemo"))
          (bind (lua ''mod .. " + Q"'') (lua "hl.dsp.window.close()"))
          (bind (lua ''mod .. " + SHIFT + M"'') (lua "hl.dsp.exit()"))
          (bind (lua ''mod .. " + G"'') (lua ''hl.dsp.window.float({ action = "toggle" })''))
          (bind (lua ''mod .. " + I"'') (exec "vim-anywhere-wayland"))
          (bind (lua ''mod .. " + F"'') (lua "hl.dsp.window.fullscreen()"))
          (bind (lua ''mod .. " + left"'') (lua ''hl.dsp.focus({ direction = "left" })''))
          (bind (lua ''mod .. " + right"'') (lua ''hl.dsp.focus({ direction = "right" })''))
          (bind (lua ''mod .. " + up"'') (lua ''hl.dsp.focus({ direction = "up" })''))
          (bind (lua ''mod .. " + down"'') (lua ''hl.dsp.focus({ direction = "down" })''))
          (bind (lua ''mod .. " + H"'') (lua ''hl.dsp.focus({ direction = "left" })''))
          (bind (lua ''mod .. " + L"'') (lua ''hl.dsp.focus({ direction = "right" })''))
          (bind (lua ''mod .. " + K"'') (lua ''hl.dsp.focus({ direction = "up" })''))
          (bind (lua ''mod .. " + J"'') (lua ''hl.dsp.focus({ direction = "down" })''))
          (bind (lua ''mod .. " + SHIFT + left"'') (lua ''hl.dsp.window.move({ direction = "left" })''))
          (bind (lua ''mod .. " + SHIFT + right"'') (lua ''hl.dsp.window.move({ direction = "right" })''))
          (bind (lua ''mod .. " + SHIFT + up"'') (lua ''hl.dsp.window.move({ direction = "up" })''))
          (bind (lua ''mod .. " + SHIFT + down"'') (lua ''hl.dsp.window.move({ direction = "down" })''))
          (bind (lua ''mod .. " + SHIFT + H"'') (lua ''hl.dsp.window.move({ direction = "left" })''))
          (bind (lua ''mod .. " + SHIFT + L"'') (lua ''hl.dsp.window.move({ direction = "right" })''))
          (bind (lua ''mod .. " + SHIFT + K"'') (lua ''hl.dsp.window.move({ direction = "up" })''))
          (bind (lua ''mod .. " + SHIFT + J"'') (lua ''hl.dsp.window.move({ direction = "down" })''))
          (bind (lua ''mod .. " + CTRL + H"'') (lua ''hl.dsp.focus({ workspace = "-1" })''))
          (bind (lua ''mod .. " + CTRL + L"'') (lua ''hl.dsp.focus({ workspace = "+1" })''))
          (bind "Print" (exec "hyprshot -m window -o ~/Pictures/Screenshots"))
          (bindMouse (lua ''mod .. " + mouse:272"'') (lua "hl.dsp.window.drag()"))
          (bindMouse (lua ''mod .. " + mouse:273"'') (lua "hl.dsp.window.resize()"))
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
              in [
                (bind (lua ''mod .. " + ${key}"'') (lua "hl.dsp.focus({ workspace = ${toString ws} })"))
                (bind (lua ''mod .. " + SHIFT + ${key}"'') (lua "hl.dsp.window.move({ workspace = ${toString ws} })"))
              ]
            )
            10)
        );
    };

    extraConfig = ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("ironbar")
        hl.exec_cmd("${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1")
        hl.exec_cmd("pypr")
        hl.exec_cmd("waypaper --random")
        hl.exec_cmd("while true; do sleep 600; waypaper --random; done")
        hl.exec_cmd("fcitx5-remote -r")
        hl.exec_cmd("fcitx5 -d --replace")
      end)
    '';
  };
}
