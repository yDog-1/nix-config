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

  configFileEntries = prefixEntries ".config" (import ./file-tree.nix ./.config);
  configEntries =
    builtins.mapAttrs (name: _: {
      # Keep dotfiles outside the Nix store so they survive garbage collection.
      src = inputs.layat.lib.mkOutOfStoreSymlink "${flakePath}/layat/ydog-1/.config/${pkgs.lib.removePrefix ".config/" name}";
    })
    configFileEntries;

  vimFileEntries = prefixEntries ".vim" (import ./file-tree.nix ./.vim);
  vimEntries =
    builtins.mapAttrs (name: _: {
      src = inputs.layat.lib.mkOutOfStoreSymlink "${flakePath}/layat/ydog-1/.vim/${pkgs.lib.removePrefix ".vim/" name}";
    })
    vimFileEntries;
in
  configEntries
  // vimEntries
  // {
    ".gitconfig".src = inputs.layat.lib.mkOutOfStoreSymlink "${flakePath}/layat/ydog-1/.gitconfig";
    ".vimrc".src = inputs.layat.lib.mkOutOfStoreSymlink "${flakePath}/layat/ydog-1/.vimrc";
  }
