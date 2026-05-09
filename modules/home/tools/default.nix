{
  pkgs,
  _config,
  ...
}: let
  gtrashCompletion =
    pkgs.runCommand "gtrash-completion" {
      buildInputs = [pkgs.gtrash];
    } ''
      mkdir -p $out/share/zsh/site-functions
      ${pkgs.gtrash}/bin/gtrash completion zsh > $out/share/zsh/site-functions/_gtrash
    '';
in {
  home.packages = with pkgs; [
    ghq
    fd
    bat
    yazi
    sad
    gtrash
  ];

  # fzf - ファジーファインダー
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--preview 'bat --color=always --style=numbers --line-range=:50 {}'"
    ];
  };

  # bat - catの代替
  programs.bat = {
    enable = true;
  };

  # eza - lsの代替
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  # zoxide - スマートディレクトリジャンプ
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd zo"];
  };

  # ripgrep - grepの代替
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--max-columns=150"
      "--max-columns-preview"
      "--smart-case"
    ];
  };

  # fd - findの代替
  programs.fd = {
    enable = true;
    hidden = true;
    ignores = [
      ".git/"
      "node_modules/"
      "*.pyc"
    ];
  };

  # direnv - 環境変数の自動ロード
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # yazi - TUIファイルマネージャ
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    flavors = {
      monokai-vibrant = pkgs.fetchFromGitHub {
        owner = "sanjinso";
        repo = "monokai-vibrant.yazi";
        rev = "main";
        sha256 = "sha256-f3IaeDJ4gZf5glk4RIVQ1/DqH0ON2Sv5UzGvdAnLEbw=";
      };
    };
    theme = {
      flavor = {
        dark = "monokai-vibrant";
      };
    };
  };

  # opencode
  home.sessionVariables = {
    OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
  };

  # Zsh関数とキーバインドの追加
  programs.zsh = {
    enableCompletion = false;

    completionInit = ''
      source ${gtrashCompletion}/share/zsh/site-functions/_gtrash
    '';
  };
}
