let
  flake = builtins.getFlake (builtins.getEnv "PWD");
  system = builtins.currentSystem;
  lib = {
    # Follow nested package sets, but never descend into derivations.
    collect = prefix: value: let
      result = builtins.tryEval (
        if builtins.isAttrs value && (value.type or null) == "derivation"
        then [prefix]
        else if builtins.isAttrs value
        then builtins.concatMap (name: lib.collect "${prefix}.${builtins.toJSON name}" value.${name}) (builtins.attrNames value)
        else []
      );
    in
      if result.success
      then result.value
      else [];
    configurations = output: suffix:
      map (name: ".#${output}.${builtins.toJSON name}.${suffix}") (builtins.attrNames (flake.${output} or {}));
  };
in
  builtins.concatMap (output: lib.collect ".#${output}.${system}" (flake.${output}.${system} or {})) [
    "packages"
    "checks"
    "devShells"
    "formatter"
    "layat"
  ]
  ++ lib.configurations "nixosConfigurations" "config.system.build.toplevel"
  ++ lib.configurations "homeConfigurations" "activationPackage"
