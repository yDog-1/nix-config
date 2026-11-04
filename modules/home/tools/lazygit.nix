let
  catppuccin = import ../../../lib/style/catppuccin-colors.nix;
  c = catppuccin.colors;
in {
  programs.lazygit = {
    enable = true;
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableNushellIntegration = false;
    enableZshIntegration = false;
    settings.gui.theme = {
      activeBorderColor = [c.mauve "bold"];
      inactiveBorderColor = [c.overlay2];
      searchingActiveBorderColor = [c.yellow];
      optionsTextColor = [c.blue];
      selectedLineBgColor = [c.surface0];
      inactiveViewSelectedLineBgColor = [c.overlay0];
      cherryPickedCommitFgColor = [c.mauve];
      cherryPickedCommitBgColor = [c.surface1];
      markedBaseCommitFgColor = [c.blue];
      markedBaseCommitBgColor = [c.yellow];
      unstagedChangesColor = [c.red];
      defaultFgColor = [c.text];
      authorColors."*" = c.lavender;
    };
  };
}
