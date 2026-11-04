{
  lib,
  pkgs,
  ...
}: let
  goCompletion =
    pkgs.runCommand "go-zsh-completion" {
      nativeBuildInputs = [pkgs.carapace];
    } ''
      carapace go zsh > "$out"
      substituteInPlace "$out" \
        --replace-fail 'carapace go zsh' '${lib.getExe pkgs.carapace} go zsh'
    '';
in {
  home.packages = [pkgs.go];

  # Register after the manually initialized compinit, even with a cached compdump.
  programs.zsh.initContent = lib.mkOrder 1500 ''
    source ${goCompletion}
  '';
}
