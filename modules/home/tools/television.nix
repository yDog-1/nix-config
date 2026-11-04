{pkgs, ...}: let
  catppuccin = import ../../../lib/style/catppuccin-colors.nix;
  c = catppuccin.colors;
in {
  # 参考: https://zenn.dev/ril/articles/introduce-nix-search-tv
  programs.television = {
    enable = true;
    enableZshIntegration = false;
    settings.ui.theme = "catppuccin-mocha-mauve";
    themes.catppuccin-mocha-mauve = {
      # Omit background to retain terminal transparency.
      border_fg = c.overlay0;
      text_fg = c.text;
      dimmed_text_fg = c.overlay0;
      input_text_fg = c.mauve;
      result_count_fg = c.mauve;
      result_name_fg = c.blue;
      result_line_number_fg = c.yellow;
      result_value_fg = c.lavender;
      selection_fg = c.green;
      selection_bg = c.surface0;
      match_fg = c.mauve;
      preview_title_fg = c.peach;
      channel_mode_fg = c.base;
      channel_mode_bg = c.mauve;
      remote_control_mode_fg = c.base;
      remote_control_mode_bg = c.green;
      action_picker_mode_fg = c.base;
      action_picker_mode_bg = c.blue;
    };
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
      actions = {
        run = {
          command = ''nix run {replace:s/\/ /#/g}'';
          mode = "fork";
        };
        shell = {
          command = ''nix shell {replace:s/\/ /#/g}'';
          mode = "execute";
        };
        homepage = {
          command = ''xdg-open "$(${nix-search-tv} homepage {})"'';
          mode = "fork";
        };
        source = {
          command = ''xdg-open "$(${nix-search-tv} source {})"'';
          mode = "fork";
        };
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
