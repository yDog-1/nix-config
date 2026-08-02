_: let
  prefixEntries = prefix: entries:
    builtins.listToAttrs (map (name: {
      name = "${prefix}/${name}";
      value = entries.${name};
    }) (builtins.attrNames entries));

  configRoot = ./.config;
  configEntries = prefixEntries ".config" (import ./file-tree.nix configRoot);
in
  configEntries
  // {
    # Lazy.nvim updates this lockfile itself, so it must not be a symlink.
    ".config/nvim/lazy-lock.json" =
      configEntries.".config/nvim/lazy-lock.json"
      // {
        method = "copy";
      };
  }
  // {
    ".gitconfig".src = ./.gitconfig;
  }
