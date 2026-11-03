{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  upstream = inputs.hypr-dots;
  python = pkgs.python3.withPackages (ps: [ps.json5]);
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  swaync = "${pkgs.swaynotificationcenter}/bin/swaync-client";
  record = pkgs.writeShellApplication {
    name = "waybar-record";
    runtimeInputs = with pkgs; [coreutils jq libnotify slurp systemd wf-recorder xdg-user-dirs];
    text = builtins.readFile ./waybar/record.sh;
  };
  updates = pkgs.writeShellApplication {
    name = "waybar-updates";
    runtimeInputs = [pkgs.python3];
    text = ''
      exec python3 ${./waybar/updates.py} /home/ydog-1/nix-config/flake.lock
    '';
  };
  networkPython = pkgs.python3.withPackages (ps: [ps.pygobject3]);
  network = pkgs.writeShellApplication {
    name = "waybar-network";
    runtimeInputs = with pkgs; [config.programs.rofi.finalPackage libnotify networkmanager networkmanagerapplet procps kitty];
    text = ''
      export GI_TYPELIB_PATH="${lib.makeSearchPath "lib/girepository-1.0" [pkgs.networkmanager pkgs.glib]}''${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"
      exec ${networkPython}/bin/python3 ${upstream}/dots/rofi/network/network.py "$@"
    '';
  };
  # Only executable paths / host compatibility override the upstream modules.
  overrides = {
    pulseaudio = {
      on-click = "${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
      on-click-middle = "${pkgs.pavucontrol}/bin/pavucontrol";
      on-scroll-up = "${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
      on-scroll-down = "${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
    };
    network.on-click = lib.getExe network;
    "custom/updates" = {
      exec = lib.getExe updates;
      hide-empty-text = true;
    };
    "custom/playerlabel" = {
      exec = ''${playerctl} -p spotify metadata --format '{"text": "{{artist}} : {{markup_escape(title)}}", "tooltip": "Spotify : {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F'';
      on-click = ''${pkgs.bash}/bin/bash -c 'player=$(${playerctl} -l | ${pkgs.gnugrep}/bin/grep -E "spotify|cider" | ${pkgs.coreutils}/bin/head -n 1); ${playerctl} -p "$player" previous' '';
      on-click-middle = ''${pkgs.bash}/bin/bash -c 'player=$(${playerctl} -l | ${pkgs.gnugrep}/bin/grep -E "spotify|cider" | ${pkgs.coreutils}/bin/head -n 1); ${playerctl} -p "$player" play-pause' '';
      on-click-right = ''${pkgs.bash}/bin/bash -c 'player=$(${playerctl} -l | ${pkgs.gnugrep}/bin/grep -E "spotify|cider" | ${pkgs.coreutils}/bin/head -n 1); ${playerctl} -p "$player" next' '';
    };
    "custom/record".on-click = "${lib.getExe record} fullscreen";
    "custom/section".on-click = "${lib.getExe record} section";
    "custom/stop".on-click = "${lib.getExe record} stop";
    "custom/notifications" = {
      # Waybar 0.15 requires the named placeholder when combined with {icon}.
      format = "{text} {icon}";
      exec-if = "${pkgs.coreutils}/bin/test -x ${swaync}";
      exec = "${swaync} -swb";
      on-click = "${swaync} -t -sw";
      on-click-right = "${swaync} -d -sw";
    };
    "custom/weather".exec = "${pkgs.wttrbar}/bin/wttrbar --custom-indicator '{ICON}{temp_C}°C'";
  };
  generated =
    pkgs.runCommand "waybar-hypr-dots-config" {
      nativeBuildInputs = [python];
      overridesFile = pkgs.writeText "waybar-overrides.json" (builtins.toJSON overrides);
    } ''
      python ${./waybar/configure.py} ${upstream}/dots/waybar/purple "$overridesFile" "$out"
    '';
in {
  home.packages = [pkgs.nerd-fonts.jetbrains-mono];
  programs.waybar = {
    enable = true;
    # Started once by Hyprland through UWSM.
    systemd.enable = false;
    style =
      ''
        @import "${upstream}/dots/waybar/matugen/matugen-waybar.css";
        /* Referenced but undefined in upstream; use its primary accent. */
        @define-color main-color @primary;
      ''
      + builtins.replaceStrings [''@import "../matugen/matugen-waybar.css";''] [""] (builtins.readFile "${upstream}/dots/waybar/purple/style.css");
  };
  xdg.configFile = {
    "waybar/config".source = generated;
    # The upstream network popup already anchors northeast, 54px below the top.
    "rofi/network/style.rasi".source = "${upstream}/dots/rofi/network/style.rasi";
    "rofi/network/fonts.rasi".text = ''
      * { font: "JetBrainsMono Nerd Font 10"; }
    '';
    "rofi/network/matugen/matugen-rofi.rasi".source = "${upstream}/dots/rofi/matugen/matugen-rofi.rasi";
    "networkmanager-dmenu/config.ini".text = ''
      [dmenu_passphrase]
      obscure = true
      [editor]
      terminal = kitty
    '';
  };
}
