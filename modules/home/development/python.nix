{
  lib,
  pkgs,
  ...
}: let
  pipCompletion = pkgs.runCommand "pip-zsh-completion" {} ''
    mkdir -p "$out/share/zsh/pip-completion"
    printf '%s\n' '#compdef -P pip[0-9.]#' > "$out/share/zsh/pip-completion/_pip"
    cat ${pkgs.python3Packages.pip}/share/zsh/site-functions/_pip >> "$out/share/zsh/pip-completion/_pip"
  '';
in {
  home.packages = [pkgs.python3 pkgs.python3Packages.pip];

  programs.zsh.initContent = lib.mkOrder 540 ''
    fpath=(${pipCompletion}/share/zsh/pip-completion $fpath)
  '';
}
