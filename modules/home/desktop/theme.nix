{
  config,
  pkgs,
  ...
}: let
  catppuccin = import ./catppuccin-colors.nix;
  gtkTheme = pkgs.catppuccin-gtk.override {
    accents = [catppuccin.accent];
    variant = catppuccin.flavor;
  };
  iconTheme = pkgs.catppuccin-papirus-folders.override {
    accent = catppuccin.accent;
    flavor = catppuccin.flavor;
  };
  kvantumTheme = pkgs.catppuccin-kvantum.override {
    accent = catppuccin.accent;
    variant = catppuccin.flavor;
  };
in {
  home.packages = [
    kvantumTheme
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 16;
  };

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-mauve-standard";
      package = gtkTheme;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = iconTheme;
    };

    gtk4 = {
      theme = config.gtk.theme;
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=catppuccin-mocha-mauve
  '';

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = config.gtk.theme.name;
    icon-theme = config.gtk.iconTheme.name;
  };
}
