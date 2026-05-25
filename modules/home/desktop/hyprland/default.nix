{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    package = null;
    portalPackage = null;
    systemd.enable = true;
    extraConfig = builtins.readFile ./hyprland.lua;
  };
}
