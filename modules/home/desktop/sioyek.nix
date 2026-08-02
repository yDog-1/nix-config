{pkgs, ...}: {
  home.packages = [
    # Sioyek cannot create a Wayland EGL context with the NVIDIA driver.
    (pkgs.symlinkJoin {
      name = "sioyek";
      paths = [pkgs.sioyek];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram "$out/bin/sioyek" \
          --set QT_QPA_PLATFORM xcb
      '';
    })
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
