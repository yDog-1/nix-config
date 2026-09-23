{profiles, ...} @ args: let
  mkProfile = profile: profileConfig: let
    entries = import (./. + "/${profile}") (args // profileConfig);
  in
    entries;
in
  builtins.mapAttrs mkProfile profiles
