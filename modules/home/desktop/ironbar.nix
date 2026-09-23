{pkgs, ...}: let
  catppuccin = import ../../../lib/style/catppucin-colors.nix;
  c = catppuccin.colors;
  alpha = catppuccin.withAlpha;
  layout = {
    controlHeight = 35;
    edgeMargin = 12;
    topMargin = 6;
    islandRadius = 10;
    padding = {
      button = 10;
      clock = 10;
      workspace = 10;
    };
  };
in {
  home.packages = [
    pkgs.ironbar
  ];

  xdg.configFile."ironbar/config.yaml".text = ''
    icon_theme: Papirus-Dark
    position: top
    anchor_to_edges: true
    height: ${toString layout.controlHeight}
    margin:
      top: ${toString layout.topMargin}
      left: ${toString layout.edgeMargin}
      right: ${toString layout.edgeMargin}
    exclusive_zone: true
    popup_gap: 8
    popup_autohide: true
    start:
    - type: custom
      bar:
      - type: box
        name: workspace-island
        class: island
        halign: start
        valign: center
        widgets:
        - type: workspaces
          hidden:
            - 'special:S-vim_anywhere'
    center:
    - type: custom
      bar:
      - type: box
        name: clock-island
        class: island
        halign: center
        valign: center
        widgets:
        - type: clock
          format: '%Y/%m/%d (%a) %H:%M'
    end:
    - type: custom
      bar:
      - type: box
        name: status-island
        class: island
        halign: end
        valign: center
        widgets:
        - type: box
          class: status-item
          halign: center
          valign: center
          widgets:
          - type: tray
        - type: box
          class: status-item
          halign: center
          valign: center
          widgets:
          - type: volume
            format: '{icon}'
            mute_format: '{icon}'
            sink_slider_orientation: horizontal
            source_slider_orientation: horizontal
        - type: box
          class: status-item
          halign: center
          valign: center
          widgets:
          - type: custom
            name: power-menu
            class: power-menu
            bar:
            - type: button
              name: power-btn
              label: 
              on_click: popup:toggle
            popup:
            - type: box
              orientation: vertical
              widgets:
              - type: label
                name: header
                label: Session
              - type: box
                name: buttons
                widgets:
                - type: button
                  class: power-btn
                  label: <span>󰐥</span>
                  on_click: '!shutdown now'
                - type: button
                  class: power-btn
                  label: <span>󰍃</span>
                  on_click: '!uwsm stop'
                - type: button
                  class: power-btn
                  label: <span>󰜉</span>
                  on_click: '!reboot'
        - type: box
          class: status-item
          halign: center
          valign: center
          widgets:
          - type: notifications
  '';

  xdg.configFile."ironbar/style.css".text = ''
    * {
        font-family: "Noto Sans CJK JP", sans-serif;
        font-size: 15px;
        border: none;
        box-shadow: none;
    }

    .background, #bar {
        background: transparent;
    }

    #bar #start, #bar #center, #bar #end {
        background: transparent;
        padding: 0;
    }

    #workspace-island, #clock-island, #status-island {
        background-color: ${c.base};
        border: none;
        border-radius: ${toString layout.islandRadius}px;
        box-shadow: 0 4px 14px ${alpha c.crust "99"};
        margin: 0;
        padding: 0;
    }

    box, button, label, calendar, popover {
        background-color: transparent;
    }

    button {
        border-radius: ${toString layout.islandRadius}px;
        color: ${c.text};
        min-height: ${toString layout.controlHeight}px;
        min-width: 28px;
        padding: 0 ${toString layout.padding.button}px;
    }

    .tray {
        min-height: ${toString layout.controlHeight}px;
    }

    button:hover {
        background-color: ${c.surface0};
    }

    button:active {
        background-color: ${c.surface1};
    }

    popover contents {
        background-color: ${c.base};
        border: 1px solid ${alpha c.mauve "66"};
        border-radius: 14px;
        box-shadow: 0 6px 20px ${alpha c.crust "B3"};
        padding: 0;
    }

    .popup {
        padding: 14px;
    }

    dropdown popover row:hover, dropdown popover row:focus, dropdown popover row:selected {
        background-color: ${c.surface0};
    }

    radio {
        -gtk-icon-filter: hue-rotate(45deg) contrast(0.6);
        margin-right: 8px;
    }

    .popup-clock .calendar-clock {
        font-size: 1.4em;
        margin-bottom: 4px;
    }

    .popup-clock .calendar .today {
        background-color: ${c.mauve};
        color: ${c.crust};
        border-radius: 6px;
    }

    .popup-volume .device-box {
        padding-right: 14px;
        margin-right: 14px;
        border-right: 1px solid ${c.surface1};
    }

    scale highlight {
        background-color: ${c.mauve};
        border-radius: 999px;
    }

    slider {
        background-color: ${c.text};
        border-radius: 999px;
    }

    .workspaces .item {
        color: ${c.subtext0};
        margin: 0;
        padding: 0 ${toString layout.padding.workspace}px;
    }

    .workspaces .item.focused {
        background-color: ${c.mauve};
        color: ${c.crust};
    }

    .workspaces .item.urgent {
        background-color: ${c.red};
        color: ${c.crust};
    }

    .clock {
        font-weight: 600;
        padding: 0 ${toString layout.padding.clock}px;
    }

    button:focus, button:focus-visible, button:active {
        outline: none;
        outline-offset: 0;
        border: none;
        background-color: transparent;
        background-image: none;
        box-shadow: none;
    }

    .tray popover contents {
        padding: 12px;
    }

    .notifications .count {
        background-color: ${c.mauve};
        color: ${c.crust};
        border-radius: 999px;
        font-size: 0.72em;
        padding: 2px 4px;
    }

    .popup-power-menu #header {
        font-size: 1.15em;
        font-weight: 600;
        margin-bottom: 10px;
    }

    .popup-power-menu .power-btn {
        border: 1px solid ${c.surface1};
        border-radius: 10px;
        padding: 0 16px;
    }

    .popup-power-menu .power-btn label {
        font-size: 2em;
    }

    .popup-power-menu #buttons > * + * {
        margin-left: 12px;
    }
  '';
}
