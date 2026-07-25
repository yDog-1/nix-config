{pkgs, ...}: {
  home.packages = [
    pkgs.sioyek
  ];

  xdg.configFile."sioyek/keys_user.config".text = ''
    # Keep document navigation consistent with Vim.
    move_left h
    move_down j
    move_up k
    move_right l

    screen_down <C-d>
    screen_up <C-u>
    next_page <C-f>
    previous_page <C-b>
  '';
}
