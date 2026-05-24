{
  imports = [
    ../../modules/home/desktop
    ../../modules/home/packages
    ../../modules/home/shell
    ../../modules/home/tools
    ../../modules/home/development
    ../../modules/home/gaming
    ../../modules/home/skk
    ../../modules/home/codex
    ../../modules/home/opencode
  ];

  home.username = "ydog-1";
  home.homeDirectory = "/home/ydog-1";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
