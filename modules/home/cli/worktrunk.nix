{
  lib,
  pkgs,
  ...
}: {
  home.packages = [pkgs.worktrunk];

  # Must run after compinit so the dynamic wt completion can register itself.
  programs.zsh.initContent = lib.mkOrder 1500 ''
    eval "$(${pkgs.worktrunk}/bin/wt config shell init zsh)"
  '';
}
