{
  services.evdevremapkeys = {
    enable = true;
    settings = {
      devices = [
        {
          input_name = "Getech HUGE TrackBall";
          output_name = "ELECOM HUGE Remapped";
          remappings = {
            BTN_TASK = ["BTN_MIDDLE"];
          };
        }
      ];
    };
  };
}
