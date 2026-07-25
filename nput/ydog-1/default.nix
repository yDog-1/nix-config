{...}: let
  prefixEntries = prefix: entries:
    builtins.listToAttrs (map (name: {
      name = "${prefix}/${name}";
      value = entries.${name};
    }) (builtins.attrNames entries));

  configRoot = ./.config;
  specialConfigDirectories = ["nvim"];
  configDirectories =
    builtins.filter (name:
      (builtins.readDir configRoot).${name} == "directory") (builtins.attrNames (builtins.readDir configRoot));

  genericConfigEntries = builtins.listToAttrs (map (name: {
    name = ".config/${name}";
    value.src = configRoot + "/${name}";
  }) (builtins.filter (name: !(builtins.elem name specialConfigDirectories)) configDirectories));

  nvimSources = import ./file-tree.nix ./.config/nvim;
  nvimEntries = prefixEntries ".config/nvim" nvimSources;
in
  genericConfigEntries
  // nvimEntries
  // {
    # Lazy.nvim updates this lockfile itself, so it must not be a symlink.
    ".config/nvim/lazy-lock.json" =
      nvimEntries.".config/nvim/lazy-lock.json"
      // {
        method = "copy";
      };
  }
  // {
    ".gitconfig".src = ./.gitconfig;
  }
