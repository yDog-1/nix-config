# Repository guidance

## Outputs and ownership

- This flake targets one `x86_64-linux` machine and exposes three independently applied outputs: `nixosConfigurations.ydog-1`, `homeConfigurations."ydog-1"`, and `layat.x86_64-linux.ydog-1`.
- NixOS starts at `hosts/ydog-1/default.nix`; standalone Home Manager starts at `home/ydog-1/default.nix`. Nix modules are not auto-discovered: import additions from these entrypoints or an existing module aggregator.
- `layat/ydog-1/file-tree.nix` auto-collects regular files in `.config` and `.vim`; `.gitconfig` and `.vimrc` are also layat-managed. They become out-of-store symlinks to this checkout, which is intentionally fixed at `/home/ydog-1/nix-config` (`programs.nh.flake` uses the same path).
- NixOS owns Hyprland, greetd/UWSM, Xwayland, and portals (`modules/nixos/desktop.nix`); Home Manager only places `modules/home/desktop/hyprland/hyprland.lua`. Do not enable a second Home Manager Hyprland module/package or portal.
- Neovim dotfiles belong to layat; Home Manager provides the wrapped executable and generated `nvim/lsp/nixd.lua`.
- OpenCode's editable base config is `modules/home/ai/opencode/opencode.json`; Home Manager generates the live config and merges MCP settings. Do not edit the generated target.
- Flake overlays apply to Home Manager, checks, packages, and the dev shell, but not the separately constructed NixOS `pkgs`.

## Checks

- `nix flake check --print-build-logs` runs repository hooks and builds the NixOS closure and Home Manager activation package.
- `nix fmt` runs all hooks over all files (actionlint, alejandra, deadnix, statix, stylua), not just formatters.
- For focused builds, use `nix build .#nixosConfigurations.ydog-1.config.system.build.toplevel` or `nix build .#homeConfigurations.ydog-1.activationPackage`.
- CI's package builds can be checked locally with `nix build --no-link .#ai-usagebar .#layat`. Changes under `layat/` also require `nix build --no-link .#layat.x86_64-linux.ydog-1`.

## Compatibility and secrets

- Treat `hosts/ydog-1/hardware-configuration.nix` as generated hardware data; put normal system changes in `modules/nixos`.
- Preserve `networking.hostName = "nixos"` and the existing `system.stateVersion` / `home.stateVersion` values; these are intentional compatibility choices.
- Sunshine uses Boost from `nixpkgs-25-05` because Boost 1.89 stalls on this host's RDRAND implementation; avoid removing this override without checking compatibility.
- SOPS age private key is external at `${XDG_CONFIG_HOME}/sops/age/keys.txt` and is needed for Home Manager activation. `.sops.yaml` only matches `secrets/*.yaml` (not nested paths); encrypted `secrets/default.yaml` is repository data.
