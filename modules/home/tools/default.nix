{
  inputs,
  pkgs,
  _config,
  ...
}: let
  catppuccin = import ../desktop/catppuccin-colors.nix;
  catppuccinYazi = pkgs.runCommand "catppuccin-yazi-${catppuccin.flavor}-${catppuccin.accent}" {} ''
    mkdir -p $out
    cp ${inputs.catppuccin-yazi}/themes/${catppuccin.flavor}/catppuccin-${catppuccin.flavor}-${catppuccin.accent}.toml $out/flavor.toml
  '';
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
      catppuccin-mocha-mauve = catppuccinYazi;
    };
    theme = {
      flavor = {
        dark = "catppuccin-mocha-mauve";
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

  # 参考: https://zenn.dev/ril/articles/introduce-nix-search-tv
  programs.television = {
    enable = true;
    enableZshIntegration = true;
    channels.nix = let
      nix-search-tv = "${pkgs.nix-search-tv}/bin/nix-search-tv";
      bat = "${pkgs.bat}/bin/bat";
    in {
      metadata = {
        name = "nix";
        description = "Search nix options and packages";
      };

      source.command = "${nix-search-tv} print";
      preview.command = ''
        ${nix-search-tv} preview "$(${bat} <<'EOS'
        {}
        EOS
        )"
      '';
      actions.run = {
        command = ''nix run {replace:s/\/ /#/g}'';
        mode = "fork";
      };
      actions.shell = {
        command = ''nix shell {replace:s/\/ /#/g}'';
        mode = "execute";
      };
      actions.homepage = {
        command = ''xdg-open "$(${nix-search-tv} homepage {})"'';
        mode = "fork";
      };
      actions.source = {
        command = ''xdg-open "$(${nix-search-tv} source {})"'';
        mode = "fork";
      };
    };
  };

  programs.nix-search-tv = {
    enable = true;
    package = pkgs.nix-search-tv;
    settings = {
      indexes = ["nixpkgs" "home-manager" "nixos"];
    };
  };
}
