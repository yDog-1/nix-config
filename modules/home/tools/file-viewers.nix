{
  programs = {
    bat = {
      enable = true;
      config.theme = "Catppuccin Mocha";
    };
    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = ["--cmd zo"];
    };
  };
}
