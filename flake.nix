{
  description = "Home Manager configuration of ydog-1";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    moralerspace-hw = {
      url = "https://github.com/yuru7/moralerspace/releases/download/v2.0.0/MoralerspaceHW_v2.0.0.zip";
      flake = false;
    };
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-yazi = {
      url = "github:catppuccin/yazi";
      flake = false;
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
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    ...
  }: let
    configurations = {
      ydog-1 = rec {
        system = "x86_64-linux";
        userName = "ydog-1";
        nixosConfigName = "ydog-1";
        homeConfigName = userName;
        hostPath = ./hosts/ydog-1;
        homePath = ./home/ydog-1;
      };
    };
    cfg = configurations.ydog-1;
    flakePath = "/home/${cfg.userName}/nix-config";
    system = cfg.system;
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
    checks.${system} = {
      pre-commit-check = inputs.git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
        };
      };

      nixos-ydog-1 = self.nixosConfigurations.ydog-1.config.system.build.toplevel;
      home-ydog-1 = self.homeConfigurations."ydog-1".activationPackage;
    };

    formatter.${system} = let
      inherit (self.checks.${system}.pre-commit-check.config) package configFile;
    in
      pkgs.writeShellScriptBin "pre-commit-run" ''
        ${pkgs.lib.getExe package} run --all-files --config ${configFile}
      '';

    devShells.${system}.default = let
      inherit (self.checks.${system}.pre-commit-check) shellHook enabledPackages;
    in
      pkgs.mkShell {
        inherit shellHook;
        buildInputs = enabledPackages;
      };

    nixosConfigurations.${cfg.nixosConfigName} = nixpkgs.lib.nixosSystem {
      inherit (cfg) system;
      specialArgs = {
        inherit inputs flakePath;
      };
      modules =
        [
          cfg.hostPath
          inputs.nix-index-database.nixosModules.default
        ]
        ++ (with nixos-hardware.nixosModules; [
          common-cpu-amd
          common-gpu-nvidia-nonprime
          common-pc-ssd
        ]);
    };

    homeConfigurations.${cfg.homeConfigName} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit inputs;
        inherit (cfg) nixosConfigName homeConfigName;
      };

      modules = [cfg.homePath];
    };
  };
}
