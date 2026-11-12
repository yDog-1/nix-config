{
  inputs,
  pkgs,
  self,
  system,
}: {
  zsh-command-completions =
    pkgs.runCommand "zsh-command-completions-tests" {
      nativeBuildInputs = [pkgs.zsh pkgs.coreutils pkgs.gnugrep pkgs.python3Packages.pip inputs.layat.packages.${system}.layat];
    } ''
      export HOME="$TMPDIR/home"
      export ZDOTDIR="$HOME"
      export XDG_CONFIG_HOME="$HOME/.config"
      export XDG_CACHE_HOME="$HOME/.cache"
      export TERM=xterm-256color
      export NIX_PROFILES=${pkgs.python3Packages.pip}
      mkdir -p "$HOME"
      cp ${self.homeConfigurations.ydog-1.config.home.file."./.zshrc".source} "$HOME/.zshrc"
      zsh -f ${../modules/home/shell/completions/test.zsh}
      touch "$out"
    '';

  sheldon-sync =
    pkgs.runCommand "sheldon-sync-tests" {
      nativeBuildInputs = [pkgs.bash pkgs.coreutils pkgs.diffutils];
    } ''
      bash ${../modules/home/shell/sheldon/test-sync.sh} ${../modules/home/shell/sheldon/sync.sh}
      touch "$out"
    '';

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
  layat-ydog-1 = self.layat.${system}.ydog-1;
}
