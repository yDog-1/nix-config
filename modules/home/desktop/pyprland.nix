{
  config,
  lib,
  pkgs,
  ...
}: {
  xdg.configFile."pypr/config.toml".text = ''
    [pyprland]
    plugins = ["scratchpads"]

    [scratchpads.vim_anywhere]
    command = "ghostty --class=com.ydog.vim_anywhere --working-directory=${config.home.homeDirectory} --gtk-single-instance=false --quit-after-last-window-closed=true --command=\"exec ${config.home.profileDirectory}/bin/zsh -lc 'exec ${config.home.profileDirectory}/bin/vim-anywhere-editor'\""
    class = "com.ydog.vim_anywhere"
    size = "80% 70%"
    position = "10% 10%"
    lazy = true
  '';

  # The daemon reads its config at startup and reloads only on a Hyprland
  # config reload, so a switch would otherwise leave it launching the previous
  # terminal.
  home.activation.reloadPyprland = lib.hm.dag.entryAfter ["linkGeneration"] ''
    if ${pkgs.procps}/bin/pgrep -f ${lib.escapeShellArg "${pkgs.pyprland}"} >/dev/null; then
      run ${lib.getExe pkgs.pyprland} reload || true
    fi
  '';
}
