directory: let
  collectFiles = path:
    builtins.concatMap (name: let
      child = path + "/${name}";
      kind = (builtins.readDir path).${name};
    in
      if kind == "directory"
      then collectFiles child
      else if kind == "regular" && name != "default.nix"
      then [child]
      else []) (builtins.attrNames (builtins.readDir path));

  files = collectFiles directory;
  directoryPrefix = "${toString directory}/";
in
  builtins.listToAttrs (map (file: let
      fileName = toString file;
    in {
      name = builtins.substring (builtins.stringLength directoryPrefix) (builtins.stringLength fileName - builtins.stringLength directoryPrefix) fileName;
      value.src = file;
    })
    files)
