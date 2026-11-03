{pkgs, ...}: let
  catppuccin = import ../../../lib/style/catppuccin-colors.nix;
  c = catppuccin.colors;
  swaync = "${pkgs.swaynotificationcenter}/bin/swaync-client";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  powerMenu = pkgs.writeText "waybar-power-menu.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <interface>
      <object class="GtkMenu" id="menu">
        <child>
          <object class="GtkMenuItem" id="logout">
            <property name="label">󰍃 ログアウト</property>
          </object>
        </child>
        <child>
          <object class="GtkMenuItem" id="reboot">
            <property name="label">󰜉 再起動</property>
          </object>
        </child>
        <child>
          <object class="GtkMenuItem" id="shutdown">
            <property name="label">󰐥 シャットダウン</property>
          </object>
        </child>
      </object>
    </interface>
  '';
in {
  # Layout and rounded modules inspired by notdanna/hypr.dots (waybar/purple).
  # Hyprland launches the bar through UWSM; do not start a second systemd instance.
  programs.waybar = {
    enable = true;
    systemd.enable = false;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 40;
      margin-top = 6;
      margin-left = 12;
      margin-right = 12;
      spacing = 4;
      exclusive = true;
      fixed-center = true;
      reload_style_on_change = true;

      modules-left = ["hyprland/window" "group/system"];
      modules-center = ["hyprland/workspaces"];
      modules-right = ["group/control-center" "tray" "custom/notifications" "clock" "custom/power"];

      "hyprland/window" = {
        format = "{title}";
        max-length = 35;
        separate-outputs = true;
      };
      "hyprland/workspaces" = {
        format = "{name}";
        on-click = "activate";
        all-outputs = false;
        show-special = false;
        sort-by-number = true;
      };
      "group/system" = {
        orientation = "horizontal";
        drawer = {
          transition-duration = 300;
          transition-left-to-right = true;
        };
        modules = ["custom/system" "cpu" "memory" "disk"];
      };
      "custom/system" = {
        format = "󰍛";
        tooltip-format = "システム情報";
      };
      cpu = {
        format = "󰘚 {usage}%";
        interval = 5;
      };
      memory = {
        format = " {percentage}%";
        interval = 5;
      };
      disk = {
        format = "󰆼 {percentage_used}%";
        path = "/";
        interval = 600;
      };
      "group/control-center" = {
        orientation = "horizontal";
        modules = ["pulseaudio" "network"];
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰖁";
        format-icons = {
          headphone = "󰋋";
          headset = "󰋎";
          default = ["󰕿" "󰖀" "󰕾"];
        };
        tooltip-format = "{desc}\n左クリック: 音量パネル / 右クリック: ミュート";
        on-click = "${swaync} -t -sw";
        on-click-right = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-middle = "${pkgs.pavucontrol}/bin/pavucontrol";
        on-scroll-up = "${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
        on-scroll-down = "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        smooth-scrolling-threshold = 1;
      };
      network = {
        format-wifi = "󰤨";
        format-ethernet = "󰈀";
        format-disconnected = "󰖪";
        tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ipaddr}";
        tooltip-format-ethernet = "{ifname}\n{ipaddr}";
        tooltip-format-disconnected = "未接続";
        interval = 5;
      };
      tray = {
        spacing = 8;
        icon-size = 18;
      };
      "custom/notifications" = {
        format = "{icon} {text}";
        return-type = "json";
        exec = "${swaync} -swb";
        restart-interval = 5;
        on-click = "${swaync} -t -sw";
        on-click-right = "${swaync} -d -sw";
        escape = true;
        tooltip = false;
        format-icons = {
          notification = "󱅫";
          none = "󰂚";
          dnd-notification = "󰂛";
          dnd-none = "󰂛";
          inhibited-notification = "󰂚";
          inhibited-none = "󰂚";
          dnd-inhibited-notification = "󰂛";
          dnd-inhibited-none = "󰂛";
        };
      };
      clock = {
        format = "{:%Y/%m/%d (%a) %H:%M}";
        tooltip-format = "<tt><big>{calendar}</big></tt>";
        calendar = {
          mode = "month";
          on-scroll = 1;
          format = {
            months = "<span color='${c.text}'><b>{}</b></span>";
            weekdays = "<span color='${c.lavender}'><b>{}</b></span>";
            today = "<span color='${c.mauve}'><b><u>{}</u></b></span>";
          };
        };
        actions = {
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
      };
      # GTK menus and tooltips open into the free space below this top bar.
      "custom/power" = {
        format = "";
        tooltip-format = "セッション";
        menu = "on-click";
        menu-file = "${powerMenu}";
        menu-actions = {
          logout = "${pkgs.uwsm}/bin/uwsm stop";
          reboot = "${pkgs.systemd}/bin/systemctl reboot";
          shutdown = "${pkgs.systemd}/bin/systemctl poweroff";
        };
      };
    };
    style = ''
      * {
        font-family: "PlemolJP Console NF", "Noto Sans CJK JP", sans-serif;
        font-size: 13px;
        font-weight: bold;
        border: none;
        border-radius: 0;
        box-shadow: none;
        text-shadow: none;
        min-height: 0;
      }

      window#waybar {
        background: ${c.base};
        color: ${c.text};
        border: 2px solid alpha(${c.mauve}, 0.25);
        border-radius: 12px;
      }

      #window, #clock, #custom-power, #custom-system {
        padding: 0 10px;
        color: ${c.mauve};
      }

      #cpu, #memory, #disk, #custom-notifications, #tray, #control-center {
        margin: 5px 3px;
        padding: 0 8px;
        background: ${c.surface0};
        color: ${c.lavender};
        border-radius: 10px;
      }

      #workspaces { margin: 0 4px; }
      #workspaces button {
        padding: 0 8px;
        margin: 4px 2px;
        color: ${c.overlay1};
        background: transparent;
        border-radius: 8px;
      }
      #workspaces button.active { color: ${c.mauve}; }
      #workspaces button.urgent { color: ${c.red}; }
      #workspaces button:hover, #custom-power:hover {
        background: ${c.surface0};
        color: ${c.text};
      }
      #pulseaudio, #network { padding: 0 5px; }
      #pulseaudio.muted { color: ${c.overlay1}; }
      #network.disconnected, #custom-power { color: ${c.red}; }
      #custom-notifications.dnd-notification,
      #custom-notifications.dnd-none { color: ${c.overlay1}; }

      tooltip, menu {
        background: ${c.base};
        color: ${c.text};
        border: 1px solid ${c.mauve};
        border-radius: 10px;
        padding: 8px;
      }
      tooltip label { color: ${c.text}; padding: 4px; }
      menuitem { padding: 10px 16px; border-radius: 6px; }
      menuitem:hover { background: ${c.surface0}; }
    '';
  };
}
