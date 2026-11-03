{config, ...}: {
  xdg.configFile."pypr/config.toml".text = ''
    [pyprland]
    plugins = ["scratchpads"]

    [scratchpads.vim_anywhere]
    # wl-copy outlives the editor and retains the PTY; close on script exit instead.
    command = "kitty --class vim-anywhere -o close_on_child_death=yes -- ${config.home.profileDirectory}/bin/zsh -lc 'exec ${config.home.profileDirectory}/bin/vim-anywhere-editor'"
    class = "vim-anywhere"
    size = "80% 70%"
    position = "10% 10%"
    lazy = true
  '';
}
