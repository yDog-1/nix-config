{
  inputs,
  pkgs,
  ...
}: {
  hardware.xpadneo.enable = true;

  programs.steam = {
    enable = true;
  };

  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = false;
    openFirewall = true;
    package = inputs.nixpkgs-25-05.legacyPackages.${pkgs.system}.sunshine;
  };
}
