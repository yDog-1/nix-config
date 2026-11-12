{
  lib,
  pkgs,
  ...
}: let
  rustcCompletion = pkgs.runCommand "rustc-zsh-completion" {} ''
    ${lib.getExe pkgs.carapace} rustc zsh > "$out"
    substituteInPlace "$out" \
      --replace-fail 'carapace rustc zsh' '${lib.getExe pkgs.carapace} rustc zsh'
  '';
  rustdocCompletion = pkgs.runCommand "rustdoc-zsh-completion" {} ''
    ${lib.getExe pkgs.carapace} rustdoc zsh > "$out"
    substituteInPlace "$out" \
      --replace-fail 'carapace rustdoc zsh' '${lib.getExe pkgs.carapace} rustdoc zsh'
  '';
in {
  home.packages = [pkgs.cargo pkgs.rustc];

  programs.zsh.initContent = lib.mkOrder 1500 ''
    source ${rustcCompletion}
    source ${rustdocCompletion}
  '';
}
