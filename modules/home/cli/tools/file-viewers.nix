{
  programs.bat = {
    enable = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd zo"];
  };
}
