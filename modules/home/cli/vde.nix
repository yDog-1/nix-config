{pkgs, ...}: let
  colors = (import ../../../lib/style/catppucin-colors.nix).colors;
  vdeConfig = {
    statusline = {
      category = {
        format = " {category} ";
        inactive_format = " {category} ";
        colors = {
          fg = colors.base;
          bg = colors.sapphire;
        };
        inactive_colors = {
          fg = colors.subtext1;
          bg = colors.surface0;
        };
      };
      sessions = {
        separator = "";
        current = {
          format = " {session} ";
          colors = {
            fg = colors.base;
            bg = colors.sapphire;
          };
        };
        other = {
          format = " {session} ";
          colors = {
            fg = colors.subtext1;
            bg = colors.surface0;
          };
        };
      };
      windows = {
        separator = "";
        current = {
          format = " {index}:{window} ";
          colors = {
            fg = colors.base;
            bg = colors.mauve;
          };
        };
        other = {
          format = " {index} {window} ";
          colors = {
            fg = colors.subtext1;
            bg = colors.surface0;
          };
        };
        last = {
          fg = colors.text;
          bg = colors.surface1;
        };
        bell = {
          fg = colors.base;
          bg = colors.yellow;
        };
        activity = {
          fg = colors.base;
          bg = colors.peach;
        };
      };
      attention.colors = {
        fg = colors.base;
        bg = colors.red;
      };
      session_badge.chip.bg = colors.surface0;
    };
    sidebar = {
      header.colors = {
        fg = colors.base;
        bg = colors.sapphire;
        outer_bg = colors.base;
      };
      colors = {
        selection_bg = colors.surface1;
        selection_bar = colors.mauve;
        header_active_bg = colors.sapphire;
        header_filter_bg = colors.surface0;
        header_total_bg = colors.surface0;
        active_bg = colors.surface0;
      };
    };
  };
in {
  xdg.configFile."vde/tmux/config.yml".source =
    (pkgs.formats.yaml {}).generate "vde-tmux-config.yml" vdeConfig;
}
