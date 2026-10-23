{
  config,
  pkgs,
  ...
}: let
  clipboardHistory = pkgs.writeShellApplication {
    name = "clipboard-history";
    runtimeInputs = [
      config.programs.rofi.finalPackage
      config.services.cliphist.package
      config.services.cliphist.clipboardPackage
      pkgs.coreutils
    ];
    text = ''
      history="$(cliphist list)"
      if [ -z "$history" ]; then
        exit 0
      fi

      if ! selection="$(printf '%s\n' "$history" | rofi -dmenu -no-custom -p Clipboard)"; then
        exit 0
      fi
      if [ -z "$selection" ]; then
        exit 0
      fi

      # Decode completely before touching the clipboard; keep binary data out of shell variables.
      decoded="$(mktemp)"
      trap 'rm -f -- "$decoded"' EXIT
      printf '%s\n' "$selection" | cliphist decode > "$decoded"
      wl-copy < "$decoded"
    '';
  };
in {
  services.cliphist = {
    enable = true;
    allowImages = true;
    systemdTargets = ["graphical-session.target"];
  };

  home.packages = [clipboardHistory];
}
