{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/boot.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/fonts
    ../../modules/nixos/input.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/mounts.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/packages.nix
    ../../modules/nixos/scan-print.nix
    ../../modules/nixos/sound.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/gaming.nix
  ];

  system.stateVersion = "25.11";
}
