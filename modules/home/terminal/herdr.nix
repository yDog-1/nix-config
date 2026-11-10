{pkgs, ...}: {
  home.packages = [
    pkgs.herdr
    pkgs.herdr-core
  ];
}
