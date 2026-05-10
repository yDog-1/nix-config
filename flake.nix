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
    # taskbar for wayland
    # It's provided from the nixpkgs, but it version is 0.18.0.
    # I wanna use vertical volume slider, which is added in 0.19.0. (issue#1305)
    # The version isn't released yet, but the master branch has the feature.
    ironbar.url = "github:JakeStanger/ironbar";
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
    pkgs = import nixpkgs {
      inherit system;

      overlays = [
        (final: prev: {
          ironbar = inputs.ironbar.packages.${system}.default;
        })
      ];
    };
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
