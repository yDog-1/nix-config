{pkgs, ...}: {
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    browsed.enable = true;
    webInterface = true;
    drivers = [
      pkgs.epson-escpr
    ];
  };

  hardware.sane = {
    enable = true;
    extraBackends = [
      pkgs.sane-airscan
      pkgs.epsonscan2
    ];
  };
}
