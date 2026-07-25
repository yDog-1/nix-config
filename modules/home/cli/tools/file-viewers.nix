{
  programs = {
    bat.enable = true;
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
