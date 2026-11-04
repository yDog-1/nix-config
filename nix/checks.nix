{
  inputs,
  pkgs,
  self,
  system,
}: {
  pre-commit-check = inputs.git-hooks.lib.${system}.run {
    src = ../.;
    hooks = {
      actionlint.enable = true;
      alejandra.enable = true;
      deadnix.enable = true;
      prettier.enable = true;
      statix = {
        enable = true;
        pass_filenames = true;
        entry = "${pkgs.writeShellScript "statix-pre-commit" ''
          set -e

          for file in "$@"; do
            ${pkgs.lib.getExe pkgs.statix} check --format errfmt "$file"
          done
        ''}";
      };
      stylua = {
        enable = true;
        types_or = ["lua"];
      };
    };
  };

  nixos-ydog-1 = self.nixosConfigurations.ydog-1.config.system.build.toplevel;
  home-ydog-1 = self.homeConfigurations."ydog-1".activationPackage;
}
