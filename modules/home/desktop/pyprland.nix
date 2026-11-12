{config, ...}: {
  xdg.configFile."pypr/config.toml".text = ''
    [pyprland]
    plugins = ["scratchpads"]

    [scratchpads.vim_anywhere]
    command = "ghostty --class=com.ydog.vim_anywhere -e ${config.home.profileDirectory}/bin/zsh -lc 'exec ${config.home.profileDirectory}/bin/vim-anywhere-editor'"
    class = "com.ydog.vim_anywhere"
    size = "80% 70%"
    position = "10% 10%"
    lazy = true
  '';
}
