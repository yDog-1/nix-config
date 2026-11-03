let
  catppuccin = import ../../../lib/style/catppucin-colors.nix;
  c = catppuccin.colors;
in {
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";

    font = {
      name = "Moralerspace Argon HW";
      size = 13.0;
    };

    # Keep Kitty's automatic shell integration instead of sourcing it from Home Manager.
    shellIntegration.mode = null;

    settings = {
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      wayland_enable_ime = false;
      background_opacity = 0.80;
      # On Linux, background blur is handled by the compositor (Hyprland).
      window_padding_width = 0;
      window_margin_width = 0;
      # Do not restore a maximized window state on startup.
      remember_window_size = false;
      confirm_os_window_close = 0;
      hide_window_decorations = true;
      tab_bar_style = "hidden";
      cursor_shape = "block";
      cursor_blink_interval = 0;

      # Preserve the mauve accents used before switching to the packaged theme.
      selection_background = c.mauve;
      active_border_color = c.mauve;
    };
  };
}
