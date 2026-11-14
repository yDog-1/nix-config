{flakePath, ...}: {
  nixpkgs.config.allowUnfree = true;

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  nix = {
    daemonIOSchedClass = "idle";

    settings = {
      auto-optimise-store = true;
      min-free = 10 * 1024 * 1024 * 1024;
      max-free = 20 * 1024 * 1024 * 1024;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };

  programs.nix-index-database.comma.enable = true;

  programs.nh = {
    enable = true;
    flake = flakePath;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 14d --keep 5";
    };
  };
}
