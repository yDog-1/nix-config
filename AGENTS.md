# AGENTS.md

## Repo Shape

- This is a single-machine Nix flake for `ydog-1` on `x86_64-linux`; the meaningful outputs are `nixosConfigurations.ydog-1` and `homeConfigurations."ydog-1"`.
- System config starts at `hosts/ydog-1/default.nix`; hardware config is `hosts/ydog-1/hardware-configuration.nix`; reusable NixOS modules live under `modules/nixos`.
- Home Manager starts at `home/ydog-1/default.nix`; reusable user modules live under `modules/home`, with aggregators like `modules/home/desktop/default.nix` importing sibling modules.
- Keep new reusable config in a feature-named file/directory under `modules/nixos` or `modules/home`, then import it from the host/home entrypoint or an existing aggregator.

## Commands

- `nix flake check` runs the pre-commit hooks plus full NixOS and Home Manager build checks defined in `flake.nix`; it is not just a light evaluation.
- Use `nix fmt` for formatting; it runs the flake formatter backed by `git-hooks.nix` (`alejandra` for Nix and `stylua` for Lua).
- For focused system verification, run `nix build .#nixosConfigurations.ydog-1.config.system.build.toplevel`.
- For focused Home Manager verification, run `nix build .#homeConfigurations.ydog-1.activationPackage`.
- If a change touches shared flake inputs, `flake.lock`, fonts, NVIDIA/Hyprland, or modules used by both sides, run both focused build commands when practical.

## Repo-Specific Gotchas

- `modules/home/desktop/hyprland/default.nix` sets `wayland.windowManager.hyprland.package = null` and `portalPackage = null` because Hyprland itself is enabled by NixOS in `modules/nixos/desktop.nix`; do not add a second Home Manager Hyprland package unless intentionally changing that split.
- Hyprland Home Manager config uses `configType = "lua"` and reads `modules/home/desktop/hyprland/hyprland.lua`; remember `nix fmt` also formats Lua via `stylua`.
- `modules/home/ai/opencode/default.nix` generates `~/.config/opencode/opencode.json` through `mcp-servers-nix`; repo-local `opencode.json` is not expected at the project root.
- SOPS Home Manager config reads secrets from `secrets/default.yaml` and uses the age key at `${config.xdg.configHome}/sops/age/keys.txt`; do not assume secret material is in the repo.
- `modules/nixos/networking.nix` currently sets `networking.hostName = "nixos"` even though the flake output/user is `ydog-1`; do not silently rename it as cleanup.
- `system.stateVersion = "25.11"` and `home.stateVersion = "25.05"` are compatibility pins; do not bump them as part of unrelated edits.

## Style

- Use two-space Nix indentation and keep larger attribute sets/lists one item per line, matching the existing files.
- Prefer small, feature-named modules over expanding host or home entrypoints with unrelated settings.
- Existing commits use concise imperative messages, often Conventional Commit style such as `feat(drive): add drive mounts configuration` or `fix(hyprland): fix workspace config that had wrong syntax`.
