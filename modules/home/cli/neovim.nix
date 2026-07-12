{
  config,
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
in {
  home.packages = [
    nvim
  ];

  sops.secrets.openrouter_api_key = {};
}
