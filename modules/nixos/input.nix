{pkgs, ...}: {
  hardware.opentabletdriver.enable = true;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = [pkgs.fcitx5-skk];
    fcitx5.waylandFrontend = true;
    fcitx5.settings.inputMethod = {
      "Groups/0" = {
        Name = "Default";
        DefaultLayout = "";
        DefaultIM = "keyboard-jp";
      };
      "Groups/0/Items/0" = {
        Name = "skk";
        Layout = "jp";
      };
      "Groups/0/Items/1" = {
        Name = "keyboard-jp";
        Layout = "";
      };
      GroupOrder = {
        "0" = "Default";
      };
    };
  };
}
