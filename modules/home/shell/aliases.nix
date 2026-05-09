{
  _pkgs,
  _config,
  ...
}: {
  programs.zsh = {
    shellAliases = {
      # ファイル操作
      "ls" = "eza";
      "ll" = "eza -alF";
      "la" = "eza -A";
      "l" = "eza -F";
      "tree" = "eza --tree";
      "rm" = "gtrash put --rm-mode";
      "cleantrash" = "gtrash find --rm";

      # 便利コマンド
      "reload" = "source ~/.zshrc";
      "path" = "echo $PATH | tr ':' '\n'";

    };
  };
}
