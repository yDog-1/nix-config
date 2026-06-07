{
  imports = [
    ../../modules/home/desktop
    ../../modules/home/cli
    ../../modules/home/shell
    ../../modules/home/ai
    ../../modules/home/skk
    ../../modules/home/secrets
  ];

  home.username = "ydog-1";
  home.homeDirectory = "/home/ydog-1";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
