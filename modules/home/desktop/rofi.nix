{
  inputs,
  pkgs,
  ...
}: let
  catppuccin-rofi-theme = pkgs.writeText "catppuccin-rofi-mocha.rasi" ''
    @import "${inputs.catppuccin-rofi}/themes/catppuccin-mocha.rasi"
    @import "${inputs.catppuccin-rofi}/catppuccin-default.rasi"
  '';
in {
  xdg.desktopEntries.reboot-to-firmware = {
    name = "UEFI設定へ再起動";
    comment = "UEFI設定画面へ再起動します";
    exec = "${pkgs.wezterm}/bin/wezterm start -- /run/wrappers/bin/sudo ${pkgs.systemd}/bin/systemctl reboot --firmware-setup";
    icon = "system-reboot";
    terminal = false;
    categories = ["System"];
    settings.Keywords = "UEFI;BIOS;firmware;";
  };

  programs.rofi = {
    enable = true;
    settings = {
      kb-move-char-forward = "Right";
      kb-element-next = "";
      kb-element-prev = "";
      kb-mode-next = "Tab,Shift+Right,Control+Tab";
      kb-mode-previous = "ISO_Left_Tab,Shift+Left,Control+ISO_Left_Tab";
      kb-accept-entry = "Control+m,Return,KP_Enter";
      kb-remove-to-eol = "";
      kb-row-down = "Down,Control+n,Control+j";
      kb-row-up = "Up,Control+p,Control+k";
      modi = "drun,run,ssh,window";
      show-icons = true;
    };
    theme = {
      "@import" = "${catppuccin-rofi-theme}";
    };
  };
}
