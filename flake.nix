{
  description = "Home Manager configuration of ydog-1";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.numtide.com"
      "https://ydog-1-nur.cachix.org"
      "https://ydog-1-nix-config.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "ydog-1-nur.cachix.org-1:gw4tWFtMdLnDn2k1EMrkgUrheq8/zi8mjPQKto5PyDs="
      "ydog-1-nix-config.cachix.org-1:yCE3ozC5QbXbEyPRnjZ0zft52t0q3EEcS8IZwRUkaFE="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-25-05.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comfyui-gtx1080-nix = {
      url = "github:yDog-1/comfyui-gtx1080-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ydog-nur = {
      url = "github:yDog-1/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
    };
    layat = {
      url = "github:yasunori0418/layat";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ast-grep-skill = {
      url = "github:ast-grep/agent-skill";
      flake = false;
    };

    catppuccin-yazi = {
      url = "github:catppuccin/yazi";
      flake = false;
    };
    catppuccin-rofi = {
      url = "github:catppuccin/rofi";
      flake = false;
    };
    hypr-dots = {
      url = "github:notdanna/hypr.dots/111a2840ea3caeb1bd1b3a850b4bf8253af0f738";
      flake = false;
    };
    tmux-open-nvim = {
      url = "github:trevarj/tmux-open-nvim";
      flake = false;
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    llm-agents,
    agent-skills,
    ydog-nur,
    ...
  }: let
    configurations = {
      ydog-1 = rec {
        system = "x86_64-linux";
        userName = "ydog-1";
        homeDirectory = "/home/${userName}";
        nixosConfigName = "ydog-1";
        homeConfigName = userName;
        hostPath = ./hosts/ydog-1;
        homePath = ./home/ydog-1;
      };
    };
    cfg = configurations.ydog-1;
    layatProfiles = {
      ydog-1.homeDirectory = cfg.homeDirectory;
    };
    flakePath = "${cfg.homeDirectory}/nix-config";
    inherit (cfg) system;
    pkgs = import nixpkgs {
      inherit system;

      config.allowUnfree = true;

      overlays = [
        ydog-nur.overlays.default
        llm-agents.overlays.shared-nixpkgs
      ];
    };
    inherit nixos-hardware;
  in {
    checks.${system} = import ./nix/checks.nix {
      inherit inputs pkgs self system;
    };

    formatter.${system} = let
      inherit (self.checks.${system}.pre-commit-check.config) package configFile;
    in
      pkgs.writeShellScriptBin "pre-commit-run" ''
        ${pkgs.lib.getExe package} run --all-files --config ${configFile}
      '';

    packages.${system} = {
      inherit (pkgs) ai-usagebar;
      layat = inputs.layat.packages.${system}.layat;
    };

    layat.${system} =
      builtins.mapAttrs (_: entries:
        inputs.layat.lib.mkManifest {
          inherit pkgs entries;
          root = inputs.layat.lib.homeRoot;
        })
      (import ./layat {
        inherit flakePath inputs pkgs;
        profiles = layatProfiles;
      });

    devShells.${system}.default = import ./nix/devshell.nix {
      inherit inputs pkgs self system;
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
        inherit (cfg) homeConfigName homeDirectory nixosConfigName userName;
      };

      modules = [
        cfg.homePath
        inputs.comfyui-gtx1080-nix.homeModules.default
        agent-skills.homeManagerModules.default
        inputs.sops-nix.homeManagerModules.sops
      ];
    };
  };
}
