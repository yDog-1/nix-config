{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    sops
  ];

  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    defaultSopsFile = ../../../secrets/default.yaml;
    defaultSymlinkPath = "${config.xdg.configHome}/sops-nix/secrets";
  };
}
