{pkgs, ...}: {
  home.packages = with pkgs; [
    tldr
    jq
    yq
    curl
    wget
    imagemagick
    ghostscript
    sad
  ];
}
