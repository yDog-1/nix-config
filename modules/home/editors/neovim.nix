{
  config,
  lib,
  pkgs,
  ...
}: let
  nvim = pkgs.writeShellApplication {
    name = "nvim";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      OPENROUTER_API_KEY="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.openrouter_api_key.path})"
      export OPENROUTER_API_KEY
      exec ${pkgs.neovim}/bin/nvim "$@"
    '';
  };
  nvimKitty = pkgs.writeShellApplication {
    name = "nvim-kitty";
    text = ''
      exec ${pkgs.kitty}/bin/kitty -- ${pkgs.zsh}/bin/zsh -lic \
        'exec ${nvim}/bin/nvim -- "$@"' nvim-kitty "$@"
    '';
  };
  textMimeTypes = [
    "text/plain"
    "text/markdown"
    "text/x-rst"
    "text/x-nix"
    "text/x-shellscript"
    "text/x-python"
    "text/x-lua"
    "text/x-c"
    "text/x-c++"
    "text/x-chdr"
    "text/x-c++hdr"
    "text/x-java"
    "text/x-rust"
    "text/x-go"
    "text/x-makefile"
    "text/html"
    "text/css"
    "text/javascript"
    "text/csv"
    "text/tab-separated-values"
    "text/x-log"
    "application/json"
    "application/ld+json"
    "application/x-ndjson"
    "application/yaml"
    "application/x-yaml"
    "text/yaml"
    "application/toml"
    "application/xml"
    "text/xml"
    "application/javascript"
    "application/x-shellscript"
    "application/x-desktop"
    "application/x-ini"
  ];
  textApplications = lib.genAttrs textMimeTypes (_: ["nvim-kitty.desktop"]);
in {
  home.packages = [
    nvim
  ];

  sops.secrets.openrouter_api_key = {};

  xdg.desktopEntries.nvim-kitty = {
    name = "Neovim (kitty)";
    genericName = "Text Editor";
    comment = "Edit text files with Neovim in kitty";
    exec = "${nvimKitty}/bin/nvim-kitty %F";
    icon = "nvim";
    terminal = false;
    categories = ["Utility" "TextEditor"];
    mimeType = textMimeTypes;
  };

  xdg.mimeApps = {
    enable = true;
    associations.added = textApplications;
    defaultApplications = removeAttrs textApplications ["text/html"];
  };
}
