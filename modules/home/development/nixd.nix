{
  homeConfigName,
  nixosConfigName,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    nixd
  ];

  xdg.configFile."nvim/lsp/nixd.lua".text = ''
    return {
      cmd = { "${pkgs.nixd}/bin/nixd" },
      filetypes = { "nix" },
      root_markers = { "flake.nix", ".git" },
      settings = {
        nixd = {
          nixpkgs = {
            expr = "import <nixpkgs> { }",
          },
          formatting = {
            command = { "${pkgs.alejandra}/bin/alejandra" },
          },
          options = {
            nixos = {
              expr = '(builtins.getFlake (toString ./.)).nixosConfigurations.${nixosConfigName}.options',
            },
            home_manager = {
              expr = '(builtins.getFlake (toString ./.)).homeConfigurations."${homeConfigName}".options',
            },
          },
        },
      },
    }
  '';
}
