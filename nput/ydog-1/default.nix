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

  storeConfigEntries = prefixEntries ".config" (import ./file-tree.nix ./.config);
  configEntries =
    builtins.mapAttrs (name: _: {
      # Keep dotfiles outside the Nix store so they survive garbage collection.
      src = inputs.nput.lib.mkOutOfStoreSymlink "${flakePath}/nput/ydog-1/.config/${pkgs.lib.removePrefix ".config/" name}";
    })
    storeConfigEntries;
in
  configEntries
  // {
    # Lazy.nvim updates this lockfile itself, so it must not be a symlink.
    ".config/nvim/lazy-lock.json" =
      storeConfigEntries.".config/nvim/lazy-lock.json"
      // {
        method = "copy";
      };
  }
  // {
    ".gitconfig".src = inputs.nput.lib.mkOutOfStoreSymlink "${flakePath}/nput/ydog-1/.gitconfig";
  }
