{pkgs, ...}: {
  home.packages = with pkgs; [
    zellij

    vim
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

    imagemagick
    ghostscript

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

    ghq
    sad
  ];
}
