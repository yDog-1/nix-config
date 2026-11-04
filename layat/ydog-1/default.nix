{
  flakePath,
  inputs,
  pkgs,
  ...
}: let
  prefixEntries = prefix: entries:
    builtins.listToAttrs (map (name: {
      name = "${prefix}/${name}";
      value = entries.${name};
    }) (builtins.attrNames entries));

  configFileEntries = prefixEntries ".config" (import ../lib/file-tree.nix ./files/.config);
  configEntries =
    builtins.mapAttrs (name: _: {
      # Keep dotfiles outside the Nix store so they survive garbage collection.
      src = inputs.layat.lib.mkOutOfStoreSymlink "${flakePath}/layat/ydog-1/files/.config/${pkgs.lib.removePrefix ".config/" name}";
    })
    configFileEntries;

  vimFileEntries = prefixEntries ".vim" (import ../lib/file-tree.nix ./files/.vim);
  vimEntries =
    builtins.mapAttrs (name: _: {
      src = inputs.layat.lib.mkOutOfStoreSymlink "${flakePath}/layat/ydog-1/files/.vim/${pkgs.lib.removePrefix ".vim/" name}";
    })
    vimFileEntries;
in
  configEntries
  // vimEntries
  // {
    # Place once as a writable file; GTK applications manage subsequent edits.
    ".config/gtk-3.0/bookmarks" = {
      src = ./files/.config/gtk-3.0/bookmarks;
      method = "copy";
    };
    ".gitconfig".src = inputs.layat.lib.mkOutOfStoreSymlink "${flakePath}/layat/ydog-1/files/.gitconfig";
    ".vimrc".src = inputs.layat.lib.mkOutOfStoreSymlink "${flakePath}/layat/ydog-1/files/.vimrc";
  }
