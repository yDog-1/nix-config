{lib, ...}: let
  inherit (import ../../../lib/style/catppuccin-colors.nix) colors;
  popup = import ../../../lib/style/popup.nix;
  colorCss = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: color: "@define-color ${name} ${color};") colors);
in {
  services.swaync = {
    enable = true;
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
      widgets = ["title" "dnd" "notifications"];
      widget-config = {
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "Clear all";
        };
        dnd.text = "Do not disturb";
      };
    };
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
      .widget-dnd { margin: 0 8px 12px; color: @on_surface_variant; }
      .widget-dnd > switch { background: @surface_container_high; border-radius: ${toString popup.radius}px; }
      .widget-dnd > switch:checked { background: @primary; }
      .widget-dnd > switch slider { background: @foreground; border-radius: ${toString popup.radius}px; }
      .widget-dnd > switch:checked slider { background: @crust; }
    '';
  };
}
