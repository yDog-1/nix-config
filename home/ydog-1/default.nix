{
  homeDirectory,
  userName,
  ...
}: {
  imports = [
    ../../modules/home/desktop
    ../../modules/home/development
    ../../modules/home/editors
    ../../modules/home/terminal
    ../../modules/home/tools
    ../../modules/home/shell
    ../../modules/home/ai
    ../../modules/home/input
    ../../modules/home/secrets
  ];

  home = {
    username = userName;
    inherit homeDirectory;
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
