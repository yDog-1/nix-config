let
  catppuccin = import ../../../lib/style/catppuccin-colors.nix;
  c = catppuccin.colors;
in {
  programs.fzf = {
    enable = true;
    enableZshIntegration = false;
    colors = {
      bg = "-1";
      "bg+" = c.surface0;
      fg = c.text;
      "fg+" = c.text;
      hl = c.red;
      "hl+" = c.red;
      header = c.blue;
      info = c.mauve;
      pointer = c.mauve;
      marker = c.mauve;
      prompt = c.mauve;
      spinner = c.rosewater;
      border = c.overlay0;
      "preview-bg" = "-1";
      "preview-fg" = c.text;
    };
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--preview 'bat --color=always --style=numbers --line-range=:50 {}'"
    ];
  };
}
