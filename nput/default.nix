{profiles, ...} @ args: let
  mkProfile = profile: profileConfig: let
    entries = import (./. + "/${profile}/.config") (args // profileConfig);
  in
    builtins.listToAttrs (map (name: {
      name = ".config/${name}";
      value = entries.${name};
    }) (builtins.attrNames entries));
in
  builtins.mapAttrs mkProfile profiles
