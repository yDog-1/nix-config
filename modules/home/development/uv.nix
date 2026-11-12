{
  lib,
  pkgs,
  ...
}: let
  uvxCompletion = pkgs.runCommand "uvx-zsh-completion" {} ''
    ${pkgs.uv}/bin/uvx --generate-shell-completion zsh > "$out"
  '';
in {
  home.packages = [pkgs.uv];

  programs.zsh.initContent = lib.mkOrder 1500 ''
    source ${uvxCompletion}
  '';
}
