{
  inputs,
  lib,
  pkgs,
  ...
}: let
  layat = inputs.layat.packages.${pkgs.stdenv.hostPlatform.system}.layat;
  layatCompletion = pkgs.runCommand "layat-zsh-completion" {} ''
    ${lib.getExe layat} completion zsh > "$out"
  '';
in {
  programs.zsh.initContent = lib.mkOrder 1500 ''
    source ${layatCompletion}
  '';
}
