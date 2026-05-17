{
  services.vicinae = {
    enable = true;
    # systemd = {
    #   enable = true;
    #   autoStart = true;
    #   environment = {
    #     USE_LAYER_SHELL = 1;
    #   };
    # };
    settings = {
      close_on_focus_loss = true;
      font = {
        size = 14;
        family = "Moralerspace Argon HW";
      };
      theme = {
        dark = {
          name = "catppuccin-mocha";
        };
      };
      launcher_window = {
        opacity = 0.8;
      };
    };
  };
}
