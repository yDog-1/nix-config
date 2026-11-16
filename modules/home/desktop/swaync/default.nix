{
  lib,
  pkgs,
  ...
}: let
  inherit (import ../../../../lib/style/catppuccin-colors.nix) colors;
  popup = import ../../../../lib/style/popup.nix;
  brightness = pkgs.writeShellApplication {
    name = "swaync-display-brightness";
    runtimeInputs = [pkgs.ddcutil pkgs.libnotify];
    text = ''exec ${pkgs.python3}/bin/python3 ${./brightness.py} "$@"'';
  };
  # SwayNC runs widget commands through `/bin/sh -c "…"`, so helpers are
  # wrapped into quote-free absolute paths.
  idleInhibit = pkgs.writeShellApplication {
    name = "swaync-idle-inhibit";
    runtimeInputs = [pkgs.systemd];
    text = builtins.readFile ./idle-inhibit.sh;
  };
  regionScreenshot = pkgs.writeShellApplication {
    name = "swaync-region-screenshot";
    runtimeInputs = [pkgs.coreutils pkgs.hyprshot pkgs.swaynotificationcenter];
    text = builtins.readFile ./region-screenshot.sh;
  };
  rulesTheme = pkgs.writeText "swaync-rules.rasi" (builtins.replaceStrings
    ["#e4e1e9" "#cba6f7" "#0b0a10" "#4c3349" "#ffd7f3" "#313244" "@popup-font@" "@popup-radius@"]
    [colors.text colors.mauve colors.base colors.surface1 colors.text colors.surface0 "${popup.fontFamily} ${toString popup.fontSize}px" "${toString popup.radius}px"]
    (builtins.readFile ./rules.rasi));
  appRules = pkgs.writeShellApplication {
    name = "swaync-app-rules";
    runtimeInputs = [pkgs.libnotify pkgs.python3 pkgs.rofi pkgs.swaynotificationcenter];
    text = ''
      export SWAYNC_RULES_THEME=${rulesTheme}
      exec ${pkgs.python3}/bin/python3 ${./rules.py} "$@"
    '';
  };
  # SwayNC only reads rules from the file it is started with, so the daemon
  # runs on a merged copy that the picker can rewrite.
  baseConfig = (pkgs.formats.json {}).generate "swaync-base.json" settings;
  slider = display: label: {
    label = "󰍹 ${label}";
    min = 0;
    max = 100;
    min_limit = 0;
    max_limit = 100;
    value_scale = 0;
    cmd_getter = "${brightness}/bin/swaync-display-brightness ${display} get";
    cmd_setter = "${brightness}/bin/swaync-display-brightness ${display} set $value";
  };
  settings = {
    positionX = "right";
    positionY = "top";
    # Layer-shell already excludes the bar's reserved zone; add only the gap.
    control-center-margin-top = 8;
    control-center-margin-bottom = 12;
    control-center-margin-right = 20;
    control-center-margin-left = 0;
    control-center-width = 420;
    control-center-height = 600;
    fit-to-screen = true;
    layer = "overlay";
    control-center-layer = "overlay";
    cssPriority = "user";
    notification-icon-size = 40;
    notification-body-image-height = 100;
    notification-body-image-width = 200;
    notification-window-width = 420;
    timeout = 10;
    timeout-low = 5;
    timeout-critical = 0;
    keyboard-shortcuts = true;
    image-visibility = "when-available";
    transition-time = 0;
    hide-on-clear = true;
    hide-on-action = true;
    widgets = ["slider#lg" "slider#pixio" "mpris" "buttons-grid" "title" "dnd" "notifications"];
    scripts.record-app = {
      exec = "${appRules}/bin/swaync-app-rules record";
      "run-on" = "receive";
    };
    widget-config = {
      "slider#lg" = slider "lg" "LG MP59G";
      "slider#pixio" = slider "pixio" "Pixio PX277h/PX276h";
      mpris = {
        image-size = 64;
        image-radius = 8;
      };
      buttons-grid = {
        buttons-per-row = 2;
        actions = [
          {
            label = "󰅶 Idle inhibit";
            type = "toggle";
            command = "${idleInhibit}/bin/swaync-idle-inhibit toggle";
            update-command = "${idleInhibit}/bin/swaync-idle-inhibit state";
          }
          {
            label = "󰆟 Region shot";
            command = "${regionScreenshot}/bin/swaync-region-screenshot";
          }
          {
            label = "󱨩 App rules";
            command = "${appRules}/bin/swaync-app-rules pick";
          }
        ];
      };
      title = {
        text = "󰂚 Notifications";
        clear-all-button = true;
        button-text = "󰗩 Clear all";
      };
      dnd.text = "󰂛 Do not disturb";
    };
  };
  colorCss = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: color: "@define-color ${name} ${color};") colors);
in {
  services.swaync = {
    enable = true;
    inherit settings;
    style = ''
      ${colorCss}
      @define-color surface_container_lowest @base;
      @define-color surface_container @surface0;
      @define-color surface_container_high @surface1;
      @define-color foreground @text;
      @define-color on_surface_variant @subtext1;
      @define-color primary @mauve;
      @define-color outline_variant @surface1;
      @define-color outline @overlay1;
      @define-color error @red;
      @define-color tertiary_container @surface1;
      @define-color on_tertiary_container @text;

      * {
        font-family: "${popup.fontFamily}", "Noto Sans CJK JP", sans-serif;
        font-size: ${toString popup.fontSize}px;
        border: none;
        text-shadow: none;
      }
      .control-center {
        background: @surface_container_lowest;
        color: @foreground;
        border: none;
        border-radius: ${toString popup.radius}px;
        padding: 12px;
      }
      .control-center-list, .blank-window, .floating-notifications {
        background: transparent;
      }
      .floating-notifications { padding-top: 48px; }
      .notification-row { outline: none; margin: 4px 0; }
      .notification {
        background: @surface_container;
        color: @foreground;
        border: none;
        border-radius: ${toString popup.radius}px;
        margin: 4px 8px;
        padding: 0;
        box-shadow: none;
      }
      .notification-default-action {
        background: transparent;
        border-radius: ${toString popup.radius}px;
        padding: 12px;
      }
      .notification-default-action:hover, .notification-action:hover {
        background: alpha(@tertiary_container, 0.7);
      }
      .notification-content { padding: 0; background: transparent; }
      .summary { color: @foreground; font-weight: bold; font-size: ${toString popup.fontSize}px; }
      .body { color: @on_surface_variant; font-size: ${toString popup.fontSize}px; }
      .time { color: @outline; font-size: ${toString popup.fontSize}px; margin-right: 8px; }
      .notification-group-header { color: @primary; font-weight: bold; }
      .notification-action {
        color: @on_tertiary_container;
        background: @tertiary_container;
        border: none;
        border-radius: ${toString popup.radius}px;
        padding: 8px 12px;
        margin: 4px;
      }
      .close-button {
        background: @surface_container_high;
        color: @on_surface_variant;
        border: none;
        border-radius: ${toString popup.radius}px;
        min-width: 24px;
        min-height: 24px;
        padding: 0;
        margin: 6px;
        box-shadow: none;
      }
      .close-button:hover { background: @tertiary_container; color: @on_tertiary_container; }
      .widget-slider { margin: 4px 8px 12px; color: @on_surface_variant; }
      .widget-slider label { min-width: 170px; }
      .widget-slider scale { min-height: 24px; }
      .widget-slider scale trough { background: @surface_container_high; border-radius: ${toString popup.radius}px; min-height: 6px; }
      .widget-slider scale highlight { background: @primary; border-radius: ${toString popup.radius}px; }
      .widget-slider scale slider { background: @foreground; border-radius: 100%; min-width: 16px; min-height: 16px; }
      .widget-mpris { margin: 4px 8px 12px; }
      .widget-mpris-player { background: @surface_container; color: @foreground; border-radius: ${toString popup.radius}px; padding: 8px; }
      .widget-mpris-player button { background: transparent; color: @foreground; border-radius: ${toString popup.radius}px; }
      .widget-mpris-player button:hover { background: @tertiary_container; }
      .widget-title { color: @foreground; font-size: ${toString popup.fontSize}px; font-weight: bold; margin: 4px 8px 12px; }
      .widget-title > button {
        background: @surface_container;
        color: @on_surface_variant;
        border: none;
        border-radius: ${toString popup.radius}px;
        padding: 6px 10px;
        font-size: ${toString popup.fontSize}px;
        box-shadow: none;
      }
      .widget-title > button:hover { background: @tertiary_container; color: @on_tertiary_container; }
      .widget-buttons-grid { margin: 4px 8px 12px; }
      .widget-buttons-grid flowboxchild > button {
        background: @surface_container;
        color: @on_surface_variant;
        border: none;
        border-radius: ${toString popup.radius}px;
        padding: 8px 10px;
        font-size: ${toString popup.fontSize}px;
        box-shadow: none;
      }
      .widget-buttons-grid flowboxchild > button:hover {
        background: @tertiary_container;
        color: @on_tertiary_container;
      }
      .widget-buttons-grid flowboxchild > button.toggle:checked {
        background: @primary;
        color: @crust;
      }
      .widget-dnd { margin: 0 8px 12px; color: @on_surface_variant; }
      .widget-dnd > switch { background: @surface_container_high; border-radius: ${toString popup.radius}px; }
      .widget-dnd > switch:checked { background: @primary; }
      .widget-dnd > switch slider { background: @foreground; border-radius: ${toString popup.radius}px; }
      .widget-dnd > switch:checked slider { background: @crust; }
    '';
  };

  systemd.user.services.swaync.Service = {
    Environment = ["SWAYNC_BASE_CONFIG=${baseConfig}"];
    ExecStart = lib.mkForce "${appRules}/bin/swaync-app-rules run";
  };
}
