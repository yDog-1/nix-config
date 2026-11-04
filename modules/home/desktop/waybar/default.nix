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
  swaync = "${pkgs.swaynotificationcenter}/bin/swaync-client";
  windowRules = pkgs.runCommand "waybar-window-rules.json" {nativeBuildInputs = [python];} ''
    python -c 'import json, json5; print(json.dumps(json5.load(open("${upstream}/dots/waybar/purple/modules.jsonc"))["hyprland/window"]["rewrite"]))' > "$out"
  '';
  window = pkgs.writeShellApplication {
    name = "waybar-window";
    runtimeInputs = [pkgs.python3];
    text = ''
      exec python3 ${./window.py} ${windowRules}
    '';
  };
  record = pkgs.writeShellApplication {
    name = "waybar-record";
    runtimeInputs = with pkgs; [coreutils jq libnotify slurp systemd wf-recorder xdg-user-dirs];
    text = builtins.readFile ./record.sh;
  };
  media = pkgs.writeShellApplication {
    name = "waybar-browser-media";
    runtimeInputs = [pkgs.python3 pkgs.playerctl];
    text = ''
      exec python3 ${./media.py} "$@"
    '';
  };
  audio = pkgs.writeShellApplication {
    name = "waybar-audio-output";
    runtimeInputs = [pkgs.python3 pkgs.pulseaudio pkgs.libnotify config.programs.rofi.finalPackage];
    text = ''
      exec python3 ${./audio.py} ${./audio.rasi}
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
  # Keep the upstream layout while applying local interaction preferences.
  overrides = {
    pulseaudio = {
      on-click = lib.getExe audio;
      on-click-right = "${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
      on-click-middle = "${pkgs.pavucontrol}/bin/pavucontrol";
      on-scroll-up = "${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
      on-scroll-down = "${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
    };
    network.on-click = lib.getExe network;
    "custom/window" = {
      format = "{text}";
      return-type = "json";
      exec = lib.getExe window;
      interval = 1;
      tooltip = false;
      max-length = 35;
    };
    "custom/playerlabel" = {
      exec = lib.getExe media;
      interval = 2;
      hide-empty-text = true;
      on-click = "${lib.getExe media} previous";
      on-click-middle = "${lib.getExe media} play-pause";
      on-click-right = "${lib.getExe media} next";
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
      python ${./configure.py} ${upstream}/dots/waybar/purple "$overridesFile" "$out"
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
      + builtins.replaceStrings [''@import "../matugen/matugen-waybar.css";'' "#window"] ["" "#custom-window"] (builtins.readFile "${upstream}/dots/waybar/purple/style.css");
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
