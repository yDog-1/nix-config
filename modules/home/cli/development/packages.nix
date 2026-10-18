{pkgs, ...}: let
  gotoolsWithoutModernize = pkgs.symlinkJoin {
    name = "gotools-without-modernize";
    paths = [pkgs.gotools];
    postBuild = ''
      rm -f "$out/bin/modernize"
    '';
  };
in {
  home.packages = with pkgs; [
    # LSP Servers
    arduino-language-server
    clang-tools
    emmylua-ls
    typescript-language-server
    gopls
    golangci-lint-langserver
    sqls
    graphql-language-service-cli
    vscode-langservers-extracted
    yaml-language-server
    terraform-ls
    taplo
    astro-language-server
    svelte-language-server
    tailwindcss-language-server
    python313Packages.python-lsp-server

    # Linters
    gitlint
    gitleaks
    hadolint
    yamllint
    markdownlint-cli
    golangci-lint
    typos
    ruff # Also provides Python formatting for Conform.

    # Formatters
    stylua
    # Temporary measures for https://github.com/NixOS/nixpkgs/issues/509480
    gotoolsWithoutModernize
    alejandra

    # Tools
    arduino-cli
    gomodifytags
  ];
}
