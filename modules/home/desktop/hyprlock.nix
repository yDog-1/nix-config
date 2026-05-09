{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "300, 56";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          placeholder_text = "Password";
          fail_text = "Authentication failed";
          outline_thickness = 2;
          rounding = 8;
        }
      ];

      label = [
        {
          text = "$TIME";
          font_size = 64;
          position = "0, 80";
          monitor = "";
        }
        {
          text = "cmd[update:1000] date +'%Y-%m-%d %A'";
          font_size = 18;
          position = "0, 20";
          monitor = "";
        }
      ];
    };
  };
}
