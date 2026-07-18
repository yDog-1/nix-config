{pkgs, ...}: let
  gtrashCompletion =
    pkgs.runCommand "gtrash-completion" {
      buildInputs = [pkgs.gtrash];
    } ''
      mkdir -p $out/share/zsh/site-functions
      ${pkgs.gtrash}/bin/gtrash completion zsh > $out/share/zsh/site-functions/_gtrash
    '';
in {
  home.packages = with pkgs; [
    gtrash
    gtrashCompletion
  ];

  programs.zsh.enableCompletion = false;
}
