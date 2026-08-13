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
      src = inputs.nput.lib.mkOutOfStoreSymlink "${flakePath}/nput/ydog-1/.config/${pkgs.lib.removePrefix ".config/" name}";
    })
    configFileEntries;
in
  configEntries
  // {
    ".gitconfig".src = inputs.nput.lib.mkOutOfStoreSymlink "${flakePath}/nput/ydog-1/.gitconfig";
  }
