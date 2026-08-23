{
  homeDirectory,
  userName,
  ...
}: {
  imports = [
    ../../modules/home/desktop
    ../../modules/home/cli
    ../../modules/home/shell
    ../../modules/home/ai
    ../../modules/home/skk
    ../../modules/home/secrets
  ];

  home = {
    username = userName;
    inherit homeDirectory;
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
