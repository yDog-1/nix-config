{pkgs, ...}: {
  home.packages = with pkgs; [
    podman
  ];

  programs.zsh.shellAliases = {
    "docker" = "podman";
  };
}
