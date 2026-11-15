{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  upstream = inputs.hypr-dots;
  inherit (import ../../../../lib/style/catppuccin-colors.nix) colors;
  popup = import ../../../../lib/style/popup.nix;
  iconRise = 2048;
  raiseIcon = icon: "<span rise='${toString iconRise}'>${icon}</span>";
  bluetoothIcons = pkgs.runCommand "waybar-bluetooth-icons" {nativeBuildInputs = [pkgs.imagemagick];} ''
    mkdir -p "$out"
    for icon in 'blueman-tray:󰂯' 'blueman-active:󰂱' 'blueman-disabled:󰂲'; do
      name="''${icon%%:*}"
      glyph="''${icon#*:}"
      magick -background none -fill '${colors.base}' \
        -font ${pkgs.plemoljp-nf}/share/fonts/truetype/PlemolJPConsoleNF-Regular.ttf \
        -pointsize 16 -size 16x16 -gravity center "label:$glyph" "$out/$name.png"
    done
  '';
  colorCss = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: color: "@define-color ${name} ${color};") colors);
  audioTheme = pkgs.writeText "waybar-audio.rasi" (builtins.replaceStrings
    ["#e4e1e9" "#cba6f7" "#0b0a10" "#4c3349" "#ffd7f3" "#313244" "@popup-font@" "@popup-radius@"]
    [colors.text colors.mauve colors.base colors.surface1 colors.text colors.surface0 "${popup.fontFamily} ${toString popup.fontSize}px" "${toString popup.radius}px"]
    (builtins.readFile ./audio.rasi));
  python = pkgs.python3.withPackages (ps: [ps.json5]);
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  swaync = "${pkgs.swaynotificationcenter}/bin/swaync-client";
  popupPython = pkgs.python3.withPackages (ps: [ps.pygobject3]);
  notifications = pkgs.writeShellApplication {
    name = "waybar-notifications";
    runtimeInputs = [pkgs.libnotify];
    text = ''
      exec ${popupPython}/bin/python3 ${./notifications.py} "$@"
    '';
  };
  audio = pkgs.writeShellApplication {
    name = "waybar-audio-output";
    runtimeInputs = [pkgs.python3 pkgs.pulseaudio pkgs.libnotify config.programs.rofi.finalPackage];
    text = ''
      exec python3 ${./audio.py} ${audioTheme} "$@"
    '';
  };
  logoutLayout = pkgs.writeText "wlogout-layout" (lib.concatMapStringsSep "\n" builtins.toJSON [
    {
      label = "suspend";
      action = "${pkgs.systemd}/bin/systemctl suspend";
      text = "󰤄";
      keybind = "s";
    }
    {
      label = "logout";
      action = "${pkgs.uwsm}/bin/uwsm stop";
      text = "󰍃";
      keybind = "l";
    }
    {
      label = "reboot";
      action = "${pkgs.systemd}/bin/systemctl reboot";
      text = "󰜉";
      keybind = "r";
    }
    {
      label = "shutdown";
      action = "${pkgs.systemd}/bin/systemctl poweroff";
      text = "⏻";
      keybind = "p";
    }
  ]);
  logoutStyle = pkgs.writeText "wlogout-style.css" ''
    ${colorCss}
    window { background: transparent; }
    button {
      background: @base;
      color: @text;
      border: none;
      border-radius: ${toString popup.radius}px;
      min-width: 56px;
      min-height: 56px;
      padding: 0;
      font-family: "${popup.fontFamily}";
      font-size: ${toString (popup.fontSize * 2)}px;
    }
    button label { margin: 0 0 12px; }
    button#suspend label, button#reboot label { margin-right: 1px; }
    button#logout label { margin-right: 2px; }
    button#shutdown label { margin-right: 3px; }
    button:hover, button:focus { background: @surface1; color: @text; }
    button#shutdown:hover { background: @red; color: @crust; }
  '';
  logout = pkgs.writeShellApplication {
    name = "waybar-logout";
    runtimeInputs = [pkgs.hyprland];
    text = ''
      export GDK_LIBRARY="${pkgs.gtk3}/lib/libgdk-3.so.0"
      exec ${pkgs.python3}/bin/python3 ${./logout.py} "$@" ${lib.getExe pkgs.wlogout} ${logoutLayout} ${logoutStyle}
    '';
  };
  usage = pkgs.writeShellApplication {
    name = "waybar-usage";
    runtimeInputs = [pkgs.util-linux];
    text = ''
      exec ${pkgs.python3}/bin/python3 ${./usage.py} "$@"
    '';
  };
  # Keep the upstream layout while applying local interaction preferences.
  overrides = {
    pulseaudio = {
      format = "${raiseIcon "{icon}"} {volume}%";
      format-bluetooth = "${raiseIcon "{icon}"} {volume}%";
      format-muted = raiseIcon "󰖁";
      tooltip = true;
      tooltip-format = "{desc}";
      on-click = lib.getExe audio;
      on-click-right = "${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
      on-click-middle = "${pkgs.pavucontrol}/bin/pavucontrol";
      on-scroll-up = "${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
      on-scroll-down = "${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
    };
    "pulseaudio#microphone" = {
      format = "{format_source}";
      format-muted = "{format_source}";
      format-bluetooth = "{format_source}";
      format-source = "${raiseIcon ""} {volume}%";
      format-source-muted = raiseIcon "";
      on-click = "${lib.getExe audio} source";
      on-click-right = "${pactl} set-source-mute @DEFAULT_SOURCE@ toggle";
      on-click-middle = "${pkgs.pavucontrol}/bin/pavucontrol --tab=4";
      on-scroll-up = "${pactl} set-source-volume @DEFAULT_SOURCE@ +5%";
      on-scroll-down = "${pactl} set-source-volume @DEFAULT_SOURCE@ -5%";
      tooltip = true;
      tooltip-format = "{source_desc}";
    };
    "custom/input-method" = {
      format = "{text}";
      return-type = "json";
      exec = "${popupPython}/bin/python3 ${./input-method.py}";
      on-click = "${pkgs.qt6Packages.fcitx5-configtool}/bin/fcitx5-config-qt";
      interval = 1;
    };
    "custom/window" = {
      format = raiseIcon "";
      on-click = lib.getExe logout;
      tooltip = false;
    };
    clock = {
      tooltip = false;
    };
    "custom/date" = {
      exec = "LC_TIME=ja_JP.UTF-8 ${pkgs.coreutils}/bin/date '+%Y/%-m/%-d(%a)'";
      interval = 60;
      align = 1;
      tooltip = false;
    };
    tray = {
      icon-size = 16;
      spacing = 10;
    };
    "custom/cpu" = {
      format = "${raiseIcon "󰘚"} {text}";
      exec = "${lib.getExe usage} cpu";
      return-type = "json";
      interval = 5;
    };
    "custom/memory" = {
      format = "${raiseIcon ""} {text}";
      exec = "${lib.getExe usage} memory";
      return-type = "json";
      interval = 5;
    };
    "custom/disk" = {
      format = "${raiseIcon "󰆼"} {text}";
      exec = "${lib.getExe usage} disk";
      return-type = "json";
      interval = 5;
    };
    "custom/notifications" = {
      # Waybar 0.15 requires the named placeholder when combined with {icon}.
      format = "{text} ${raiseIcon "{icon}"}";
      exec-if = "${pkgs.coreutils}/bin/test -x ${swaync}";
      exec = "${swaync} -swb";
      on-click = lib.getExe notifications;
      on-click-right = "${swaync} -d -sw";
    };
    "custom/weather" = {
      exec = "${pkgs.wttrbar}/bin/wttrbar --lang ja --custom-indicator '{ICON}{temp_C}°C' | ${pkgs.python3}/bin/python3 ${./weather.py}";
      interval = 600;
      exec-on-event = false;
      align = 0;
    };
  };
  generated =
    pkgs.runCommand "waybar-hypr-dots-config" {
      nativeBuildInputs = [python];
      overridesFile = pkgs.writeText "waybar-overrides.json" (builtins.toJSON overrides);
    } ''
      python ${./configure.py} ${upstream}/dots/waybar/purple "$overridesFile" "$out"
    '';
in {
  home.packages = [pkgs.nerd-fonts.jetbrains-mono pkgs.wlogout];
  programs.waybar = {
    enable = true;
    # Started once by Hyprland through UWSM.
    systemd.enable = false;
    style =
      ''
        @import "${upstream}/dots/waybar/matugen/matugen-waybar.css";
        ${colorCss}
        @define-color main-color @mauve;
      ''
      + builtins.replaceStrings [''@import "../matugen/matugen-waybar.css";'' "#window"] ["" "#custom-window"] (builtins.readFile "${upstream}/dots/waybar/purple/style.css")
      + ''
        window#waybar { background: @base; color: @text; border: none; border-radius: 0; }
        window#waybar * { background: transparent; border: none; font-family: "PlemolJP Console NF"; font-size: 15px; }
        @define-color segment_logo @red;
        @define-color segment_workspace @peach;
        @define-color segment_apps @yellow;
        @define-color segment_tray @green;
        @define-color segment_input @blue;
        @define-color segment_audio @lavender;
        @define-color segment_notifications @mauve;
        window#waybar #workspaces { background: @segment_workspace; margin: 0; border-radius: 0; }
        window#waybar #workspaces button {
          color: @crust;
          font-size: 15px;
          min-height: 0;
          min-width: 0;
          margin: 0;
          padding: 0 5px;
          border-radius: 0;
        }
        window#waybar #workspaces button label { font-weight: normal; font-style: normal; }
        window#waybar #workspaces button:hover { background: @surface1; color: @text; }
        window#waybar #workspaces button.active { background: transparent; color: @crust; box-shadow: none; }
        window#waybar #workspaces button.active label { font-weight: bold; font-style: italic; text-decoration-line: underline; text-decoration-color: @crust; }
        window#waybar #custom-window { color: @crust; background: @segment_logo; margin: 0; padding: 0 8px; border-radius: 0; }
        window#waybar #clock, window#waybar #custom-weather { color: @text; }
        window#waybar #custom-cpu, window#waybar #custom-memory, window#waybar #custom-disk,
        window#waybar #pulseaudio, window#waybar #custom-input-method,
        window#waybar #custom-notifications, window#waybar #tray { color: @crust; }
        window#waybar #tray { background: @segment_tray; }
        window#waybar #apps { background: @segment_apps; }
        window#waybar #custom-input-method { background: @segment_input; }
        window#waybar #audio { background: @segment_audio; }
        window#waybar #custom-notifications, window#waybar #power { background: @segment_notifications; border-radius: 0; margin: 0; }
        window#waybar #custom-segment-left, window#waybar #custom-segment-left-apps, window#waybar #custom-segment-left-end,
        window#waybar #custom-segment-tray, window#waybar #custom-segment-input,
        window#waybar #custom-segment-audio, window#waybar #custom-segment-notifications {
          font-size: 24px; margin: -3px 0; padding: 0;
        }
        window#waybar #custom-segment-left { color: @segment_logo; background: @segment_workspace; }
        window#waybar #custom-segment-left-apps { color: @segment_workspace; background: @segment_apps; }
        window#waybar #custom-segment-left-end { color: @segment_apps; background: @base; }
        window#waybar #custom-segment-tray { color: @segment_tray; background: @base; }
        window#waybar #custom-segment-input { color: @segment_input; background: @segment_tray; }
        window#waybar #custom-segment-audio { color: @segment_audio; background: @segment_input; }
        window#waybar #custom-segment-notifications { color: @segment_notifications; background: @segment_audio; }
        window#waybar #pulseaudio.muted { color: @surface1; }
        window#waybar #custom-weather { min-width: 140px; padding: 0 0 0 10px; margin: 0; }
        window#waybar #custom-date { min-width: 140px; padding: 0 10px 0 0; margin: 0; color: transparent; }
        window#waybar #date-clock:hover #custom-date { color: @text; }
        window#waybar #clock { margin: 0; }
        window#waybar #custom-cpu, window#waybar #custom-memory, window#waybar #custom-disk,
        window#waybar #custom-notifications, window#waybar #power-profiles-daemon,
        window#waybar #bluetooth { margin: 0; padding: 0 5px; }
        window#waybar #custom-memory, window#waybar #custom-disk { margin-left: 2px; }
        window#waybar #custom-notifications { padding-right: 8px; }
        window#waybar #tray { margin: 0; border-radius: 0; }
        window#waybar #tray:hover #custom-tray-toggle { color: transparent; }
        window#waybar #pulseaudio.microphone { padding: 0 5px; }
        window#waybar #custom-input-method { padding: 0 5px; }
        tooltip, menu, window#waybar menu {
          background: @base;
          color: @text;
          border: none;
          border-radius: ${toString popup.radius}px;
          font-family: "${popup.fontFamily}";
          font-size: ${toString popup.fontSize}px;
        }
        tooltip label { color: @text; font-family: "${popup.fontFamily}"; font-size: ${toString popup.fontSize}px; padding: 6px 8px; }
        menu menuitem, menu menuitem label, window#waybar menu menuitem, window#waybar menu menuitem label {
          font-family: "${popup.fontFamily}";
          font-size: ${toString popup.fontSize}px;
        }
        menu menuitem check, menu menuitem radio, window#waybar menu menuitem check, window#waybar menu menuitem radio {
          color: @text;
        }
        menu menuitem:hover, window#waybar menu menuitem:hover {
          background: @surface1;
          color: @text;
        }
      '';
  };
  xdg.configFile = {
    "waybar/config".source = generated;
  };
  xdg.dataFile =
    lib.genAttrs (map (name: "icons/${config.gtk.iconTheme.name}/16x16/status/${name}.png") ["blueman-tray" "blueman-active" "blueman-disabled"])
    (path: {source = "${bluetoothIcons}/${baseNameOf path}";});
}
