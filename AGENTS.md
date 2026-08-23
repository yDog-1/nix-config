# AGENTS.md

## Configuration Boundaries

- This flake has three independently applied outputs for one `x86_64-linux` machine: `nixosConfigurations.ydog-1`, standalone `homeConfigurations."ydog-1"`, and `nput.x86_64-linux.ydog-1`. Applying one does not apply the others.
- NixOS starts at `hosts/ydog-1/default.nix`; Home Manager starts at `home/ydog-1/default.nix`. Nix modules are not auto-discovered, so import new modules from those entrypoints or an existing `modules/{nixos,home}` aggregator.
- `nput/ydog-1/file-tree.nix` automatically includes every regular file below `nput/ydog-1/.config`; these files and `.gitconfig` become live out-of-store symlinks, not Home Manager files.
- The checkout path is intentionally fixed at `/home/ydog-1/nix-config`: both `programs.nh.flake` and nput's out-of-store symlinks depend on it. Do not make the configuration relocation-safe as incidental cleanup.
- The overlays in `flake.nix` apply to Home Manager, checks, packages, and the dev shell, but not to the separately constructed NixOS `pkgs`. Do not assume a package override used by Home Manager exists in NixOS.

## Commands

- `nix fmt` runs all repository hooks over all files: actionlint, alejandra, deadnix, statix, and stylua. It is not formatting-only.
- `nix flake check --print-build-logs` is the main local check; it runs the hooks and builds both the NixOS closure and Home Manager activation package.
- Focused builds are `nix build .#nixosConfigurations.ydog-1.config.system.build.toplevel` and `nix build .#homeConfigurations.ydog-1.activationPackage`.
- CI additionally builds every `packages.x86_64-linux` output; the current local equivalent is `nix build --no-link .#ai-usagebar .#nput`.
- Changes under `nput/` need the separate manifest check `nix build --no-link .#nput.x86_64-linux.ydog-1`; this output is not covered by the package build above.
- Apply configuration only when requested: `nh os switch`, `home-manager switch --flake .#ydog-1`, and `nix develop --command nput apply ydog-1` apply the NixOS, Home Manager, and nput outputs respectively.

## Ownership Gotchas

- NixOS owns the Hyprland package, greetd/UWSM session, Xwayland, and portals in `modules/nixos/desktop.nix`. Home Manager only places the native `hyprland.lua`; do not enable `wayland.windowManager.hyprland` or add another Hyprland package/portal there.
- Edit `modules/home/desktop/hyprland/hyprland.lua` directly; Hyprland loads it as native configuration and `nix fmt` formats it with stylua.
- OpenCode's editable base config is `modules/home/ai/opencode/opencode.json`. `default.nix` merges MCP settings into the generated `~/.config/opencode/opencode.json`; do not add a root `opencode.json` or edit the generated target.
- Neovim ownership is split: nput owns the ordinary files under `nput/ydog-1/.config/nvim`, while Home Manager owns the wrapped executable and generated `nvim/lsp/nixd.lua`.
- Treat `hosts/ydog-1/hardware-configuration.nix` as generated hardware data; put normal system changes in `modules/nixos` despite the generated file's stale `/etc/nixos/configuration.nix` comment.
- Sunshine is deliberately sourced from `nixpkgs-25-05` in `modules/nixos/gaming.nix`, while the rest of the flake tracks unstable. Do not normalize that pin without checking the compatibility reason.

## Secrets And Compatibility

- `secrets/default.yaml` contains encrypted SOPS data and may be committed; the private age key is external at `${XDG_CONFIG_HOME}/sops/age/keys.txt` and is required for Home Manager activation.
- `.sops.yaml` only matches `secrets/*.yaml`, not nested secret directories.
- `networking.hostName` intentionally remains `nixos`, despite the output and user being named `ydog-1`.
- `system.stateVersion = "25.11"` and `home.stateVersion = "25.05"` are compatibility pins, not package versions; never bump them during unrelated work.
