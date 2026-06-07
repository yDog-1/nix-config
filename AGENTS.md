# AGENTS.md

## Repo Shape

- This is a Nix flake for one machine/user: `ydog-1` on `x86_64-linux`; the only flake outputs to verify are `nixosConfigurations.ydog-1` and `homeConfigurations."ydog-1"`.
- System configuration starts at `hosts/ydog-1/default.nix`; hardware config is `hosts/ydog-1/hardware-configuration.nix`, and reusable NixOS config lives under `modules/nixos`.
- Home Manager starts at `home/ydog-1/default.nix`; reusable user config lives under `modules/home`, with aggregators such as `modules/home/desktop/default.nix` importing sibling modules.
- Keep new reusable config in `modules/nixos/<area>/default.nix`, `modules/home/<area>/default.nix`, or a narrowly named sibling module, then import it from the host/home entrypoint or an existing aggregator.

## Commands

- Run `nix flake check` for basic evaluation; there is no README, CI, task runner, custom `checks`, or formatter config in this checkout.
- Build system changes with `nix build .#nixosConfigurations.ydog-1.config.system.build.toplevel` before suggesting `sudo nixos-rebuild switch --flake .#ydog-1`.
- Build Home Manager changes with `nix build .#homeConfigurations.ydog-1.activationPackage` before suggesting `home-manager switch --flake .#ydog-1`.
- If a change touches shared inputs, `flake.lock`, fonts, NVIDIA/Hyprland, or modules imported by both sides, run both build commands when practical.

## Repo-Specific Gotchas

- `modules/home/desktop/hyprland.nix` sets `wayland.windowManager.hyprland.package = null` and `portalPackage = null` because Hyprland itself is enabled by NixOS in `modules/nixos/desktop.nix`; do not add a second Home Manager Hyprland package unless intentionally changing that split.
- `modules/home/ai/opencode/default.nix` generates `~/.config/opencode/opencode.json` through `mcp-servers-nix`; repo-local `opencode.json` is not expected at the project root.
- The `update-flake` helper in `modules/home/shell/functions/system-update.nix` operates on `$HOME/nix-config` and runs `home-manager switch --flake "$NIX_CONFIG_DIR#ydog-1"`.
- `modules/nixos/networking.nix` currently sets `networking.hostName = "nixos"` even though the flake output/user is `ydog-1`; do not silently rename it as cleanup.
- `system.stateVersion = "25.11"` and `home.stateVersion = "25.05"` are state compatibility pins; do not bump them as part of unrelated edits.

## Style

- Use two-space Nix indentation and keep larger attribute sets/lists one item per line, matching the existing files.
- Prefer small, feature-named modules over expanding host or home entrypoints with unrelated settings.
- Existing commits use concise imperative messages, often Conventional Commit style such as `feat(drive): add drive mounts configuration` or `fix(hyprland): fix workspace config that had wrong syntax`.
