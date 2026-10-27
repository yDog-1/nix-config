{
  systemd.user.services.input-remapper-autoload = {
    Unit = {
      Description = "Load Input Remapper presets for the graphical session";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      # The patched executable and daemon are provided together by NixOS.
      ExecStart = "/run/current-system/sw/bin/input-remapper-control --command autoload";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
