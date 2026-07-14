{
  lib,
  pkgs,
  ...
}: let
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
  configFile = (pkgs.formats.yaml {}).generate "evdevremapkeys-config.yaml" settings;
  evdevremapkeys = pkgs.evdevremapkeys.override {
    python3Packages = pkgs.python313Packages;
  };
in {
  services.evdevremapkeys = {
    enable = true;
    inherit settings;
  };

  # evdevremapkeys creates virtual input devices through /dev/uinput.
  systemd.services.evdevremapkeys.serviceConfig = {
    ExecStart = lib.mkForce "${lib.getExe evdevremapkeys} --config-file ${configFile}";
    SupplementaryGroups = ["uinput"];
  };
}
