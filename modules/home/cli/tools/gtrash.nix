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
  ];

  programs.zsh = {
    enableCompletion = false;

    completionInit = ''
      source ${gtrashCompletion}/share/zsh/site-functions/_gtrash
    '';
  };
}
