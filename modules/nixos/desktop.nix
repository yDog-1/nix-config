{pkgs, ...}: {
  services = {
    greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd 'uwsm start hyprland.desktop'";
        user = "greeter";
      };
    };
    xserver.xkb = {
      layout = "jp";
      variant = "";
    };
    gvfs.enable = true;
    tumbler.enable = true;
    udisks2.enable = true;
  };

  programs = {
    dconf.enable = true;
    zsh.enable = true;
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config.common.default = ["hyprland" "gtk"];
  };
}
