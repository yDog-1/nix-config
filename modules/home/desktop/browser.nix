{pkgs, ...}: {
  home.packages = with pkgs; [
    vivaldi
  ];

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
  };
}
