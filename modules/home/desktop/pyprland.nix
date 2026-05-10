{config, ...}: {
  xdg.configFile."pypr/config.toml".text = ''
    [pyprland]
    plugins = ["scratchpads"]

    [scratchpads.vim_anywhere]
    command = "wezterm start --class vim-anywhere -- ${config.home.profileDirectory}/bin/zsh -lc 'exec ${config.home.profileDirectory}/bin/vim-anywhere-editor'"
    class = "vim-anywhere"
    size = "80% 70%"
    position = "10% 10%"
    lazy = true
  '';
}
