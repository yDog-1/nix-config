{
  inputs,
  pkgs,
  self,
  system,
}: let
  inherit (self.checks.${system}.pre-commit-check) shellHook enabledPackages;
in
  pkgs.mkShell {
    inherit shellHook;
    buildInputs = enabledPackages;
    packages = [
      inputs.layat.packages.${system}.layat
    ];
  }
