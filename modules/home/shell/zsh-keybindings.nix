{
  _pkgs,
  _config,
  lib,
  ...
}: {
  programs.zsh = {
    # Vi mode設定
    defaultKeymap = "viins";

    initContent = lib.mkOrder 100 ''
      # jjでノーマルモードに移行
      bindkey -M viins 'jj' vi-cmd-mode

      # j で履歴を進む (vicmdモード)
      bindkey -M vicmd 'j' down-line-or-history

      # k で履歴を戻る (vicmdモード)
      bindkey -M vicmd 'k' up-line-or-history

      # Ctrl-p で履歴を遡る
      bindkey -M viins '^P' up-line-or-search

      # Ctrl-n で履歴を進む
      bindkey -M viins '^N' down-line-or-search

      # Ctrl-o でNeovimでコマンドを編集
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey "^O" edit-command-line
    '';
  };
}
