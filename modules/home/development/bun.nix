{
  lib,
  pkgs,
  ...
}: let
  bunxCompletion = pkgs.writeTextDir "share/zsh/bun-completion/_bunx" ''
    #compdef bunx
    source ${pkgs.bun}/share/zsh/site-functions/_bun
    _bunx() {
      local -a words=(bun x "''${words[@]:1}")
      local -i CURRENT=$((CURRENT + 1))
      _bun "$@"
    }
    _bunx "$@"
  '';
in {
  home.packages = [pkgs.bun];

  programs.zsh.initContent = lib.mkOrder 540 ''
    fpath=(${bunxCompletion}/share/zsh/bun-completion $fpath)
  '';
}
