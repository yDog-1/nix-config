{
  flakePath,
  inputs,
  pkgs,
  ...
}: let
  inherit (pkgs) lib;

  files = lib.fileset.toList (
    lib.fileset.fileFilter
    (file: file.type == "regular" && file.name != "default.nix")
    ./files
  );

  entries = lib.listToAttrs (map (file: let
      name = lib.removePrefix "${toString ./files}/" (toString file);
    in {
      inherit name;
      # Keep dotfiles outside the Nix store so they survive garbage collection.
      value.src = inputs.layat.lib.mkOutOfStoreSymlink "${flakePath}/layat/ydog-1/files/${name}";
    })
    files);
in
  entries
  // {
    # Place once as a writable file; GTK applications manage subsequent edits.
    ".config/gtk-3.0/bookmarks" = {
      src = ./files/.config/gtk-3.0/bookmarks;
      method = "copy";
    };
  }
