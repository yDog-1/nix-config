{pkgs, ...}: {
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
