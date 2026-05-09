{pkgs, ...}: {
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd 'uwsm start hyprland.desktop'";
      user = "greeter";
    };
  };

  services.xserver.xkb = {
    layout = "jp";
    variant = "";
  };

  services.printing.enable = true;

  security.pam.services.hyprlock = {};

  programs.firefox.enable = true;
  programs.zsh.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config.common.default = ["hyprland" "gtk"];
  };
}
