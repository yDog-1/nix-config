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
    lua-language-server
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
    tailwindcss-language-server
    nixd
    python313Packages.python-lsp-server

    # Linters
    gitlint
    gitleaks
    hadolint
    yamllint
    markdownlint-cli
    golangci-lint
    typos

    # Formatters
    stylua
    # Temporary measures for https://github.com/NixOS/nixpkgs/issues/509480
    gotoolsWithoutModernize
    alejandra

    # Tools
    gomodifytags
  ];
}
