{
  inputs,
  pkgs,
  ...
}: {
  hardware.xpadneo.enable = true;

  programs.steam = {
    enable = true;
  };

  services.wivrn = {
    enable = true;
    autoStart = false;
    openFirewall = true;
    steam.importOXRRuntimes = true;
    package = pkgs.wivrn.override {cudaSupport = true;};
    config = {
      enable = true;
      json.application = pkgs.wayvr;
    };
  };

  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = false;
    openFirewall = true;
    # Boost 1.89 stalls on this host's broken RDRAND implementation.
    package = pkgs.sunshine.override {
      boost = inputs.nixpkgs-25-05.legacyPackages.${pkgs.stdenv.hostPlatform.system}.boost;
    };
  };
}
