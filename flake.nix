{
  description = "Home Manager configuration of ydog-1";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    moralerspace-hw = {
      url = "https://github.com/yuru7/moralerspace/releases/download/v2.0.0/MoralerspaceHW_v2.0.0.zip";
      flake = false;
    };
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    nixos-hardware,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    inherit nixos-hardware;
  in {
    nixosConfigurations.ydog-1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;}; # Pass inputs to homeManagerConfiguration
      modules =
        [
          ./hosts/ydog-1
        ]
        ++ (with nixos-hardware.nixosModules; [
          common-cpu-amd
          common-gpu-nvidia-nonprime
          common-pc-ssd
        ]);
    };

    homeConfigurations."ydog-1" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {inherit inputs;}; # Pass inputs to homeManagerConfiguration

      modules = [./home/ydog-1];
    };
  };
}
