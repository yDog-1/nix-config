{pkgs, ...}: {
  home.packages = with pkgs; [
    zsh
    zellij

    vim
    neovim
    tree-sitter

    tldr
    jq
    yq
    curl
    wget

    git
    gh
    lazygit
    delta

    podman
    imagemagick
    ghostscript
    chezmoi

    go
    nodejs
    deno
    bun
    pnpm
    python3
    python3Packages.pip
    uv
    cargo
    rustc
    gdscript-formatter
    gcc

    xclip
    wl-clipboard
  ];

  programs.zsh.shellAliases = {
    "docker" = "podman";
  };
}
