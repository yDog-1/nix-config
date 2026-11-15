# Repository guidance

## Outputs and ownership

- This flake targets one `x86_64-linux` machine and exposes three independently applied outputs: `nixosConfigurations.ydog-1`, `homeConfigurations."ydog-1"`, and `layat.x86_64-linux.ydog-1`.
- NixOS starts at `hosts/ydog-1/default.nix`; standalone Home Manager starts at `home/ydog-1/default.nix`. Nix modules are not auto-discovered: import additions from these entrypoints or an existing module aggregator.
- `layat/ydog-1/default.nix` uses `pkgs.lib.fileset` to auto-collect regular files under `layat/ydog-1/files/`, excluding `default.nix` and symlinks. Paths relative to `files/` are placed under the home directory. GTK bookmarks use a place-once copy; other files become out-of-store symlinks to this checkout, which is intentionally fixed at `/home/ydog-1/nix-config` (`programs.nh.flake` uses the same path).
- NixOS owns Hyprland, greetd/UWSM, Xwayland, and portals (`modules/nixos/desktop.nix`); Home Manager only places `modules/home/desktop/hyprland/hyprland.lua`. Do not enable a second Home Manager Hyprland module/package or portal.
- Neovim dotfiles belong to layat; Home Manager provides the wrapped executable and generated `nvim/after/lsp/nixd.lua`. Place local LSP overrides in `after/lsp/` so they take precedence over nvim-lspconfig defaults.
- When adding a command, check whether shell completions are provided automatically or require explicit configuration. If no completions are provided by default, check whether Carapace supports the command. Add completion setup when needed.
- Sheldon configuration belongs to Home Manager at `modules/home/shell/sheldon/plugins.toml`, not layat. Activation runs `sheldon-sync` after `linkGeneration` to prepare plugin dependencies; interactive startup must not repeat that preparation.
- OpenCode's editable base config is `modules/home/ai/opencode/opencode.json`; Home Manager generates the live config and merges MCP settings. Do not edit the generated target. `cli.json` is managed by layat under `layat/ydog-1/files/.config/opencode/`.
- Flake overlays apply to Home Manager, checks, packages, and the dev shell, but not the separately constructed NixOS `pkgs`.

## Waybar dependencies

- Waybar configuration and helper scripts live in `modules/home/desktop/waybar/`. Hyprland starts Waybar through UWSM; Home Manager's Waybar systemd service stays disabled. The configuration and base CSS come from the pinned `hypr-dots` input, with local overrides applied by `configure.py`.
- Notifications use SwayNC from `modules/home/desktop/swaync.nix`. The Waybar notification helper uses Python with PyGObject for D-Bus, `hyprctl` for monitor placement, and `notify-send` for errors.
- The Nix logo opens `wlogout` through `logout.py` and `hyprctl`. Its actions use `systemctl` for suspend, reboot, and poweroff, and `uwsm stop` for logout.
- Audio selection uses Rofi from `modules/home/desktop/rofi.nix` and `pactl` from PulseAudio to select devices and move streams. The middle-click controls open Pavucontrol. `notify-send` reports errors.
- The input-method indicator uses Python with PyGObject and the fcitx5 D-Bus menu; clicking it opens `fcitx5-config-qt`. Weather uses `wttrbar`. Waybar uses `PlemolJP Console NF`, supplied by the NixOS font configuration in `modules/nixos/fonts/default.nix`.

## Waybar styling

- Keep the appearance of the entire Waybar experience consistent, not just the bar itself. When changing the theme, check hover tooltips, tray right-click menus, SwayNC notifications and panel, the wlogout power menu, the Rofi audio-device chooser, and other windows opened by Waybar controls. Coordinate colors, fonts, borders, corner shapes, and hover and focus states across these surfaces.
- The shared Catppuccin palette lives in `lib/style/catppuccin-colors.nix`, and popup font and corner settings live in `lib/style/popup.nix`. Waybar and wlogout styles live in `modules/home/desktop/waybar/default.nix`, the audio chooser theme in `modules/home/desktop/waybar/audio.rasi`, and SwayNC styles in `modules/home/desktop/swaync.nix`. Check the styling of other dependency windows as well, including Pavucontrol and the fcitx5 configuration tool. Verify affected surfaces on screen when possible, including tooltips and tray context menus.

## Directory conventions

- Host-specific mounts and users belong in `hosts/ydog-1/`; shared NixOS feature settings belong in `modules/nixos/`.
- Home Manager modules are grouped by purpose: `ai`, `development`, `editors`, `terminal`, `tools`, `shell`, `desktop`, `input`, and `secrets`.
- A feature with only Nix configuration uses `<feature>.nix`; a feature with supporting files uses `<feature>/default.nix` alongside those files.
- Category `default.nix` files collect imports. `packages.nix` files define packages rather than importing other feature modules.
- `nix/checks.nix` and `nix/devshell.nix` implement flake tooling; `flake.nix` connects inputs and outputs.

## Development shell

- Run `nix develop` from the repository root to enter the default development shell, or `nix develop --command <command>` to run one command in it. The shell provides the enabled hook tools and `layat`. `.envrc` contains `use flake` for direnv users.
- Entering the shell runs the `git-hooks.nix` shell hook from `nix/devshell.nix`. It generates `.pre-commit-config.yaml` as a symlink to the Nix store and installs the configured Git pre-commit hook. Edit hook definitions in `nix/checks.nix`, not the generated config. Re-enter the shell after changing them. An existing non-symlink `.pre-commit-config.yaml` prevents installation and is not overwritten.
- Hook installation can uninstall existing pre-commit-managed hooks and change the repository's local `core.hooksPath`; worktrees share the common hooks directory. Account for these side effects before entering the shell in a worktree or a repository with custom hooks.

## Checks

- `nix flake check --print-build-logs` runs repository hooks and builds the NixOS closure and Home Manager activation package.
- `nix fmt` runs all hooks over all files (actionlint, alejandra, deadnix, prettier, statix, stylua), not just formatters.
- For focused builds, use `nix build .#nixosConfigurations.ydog-1.config.system.build.toplevel` or `nix build .#homeConfigurations.ydog-1.activationPackage`.
- CI's package builds can be checked locally with `nix build --no-link .#ai-usagebar .#layat`. Changes under `layat/` also require `nix build --no-link .#layat.x86_64-linux.ydog-1`.

## Compatibility and secrets

- Treat `hosts/ydog-1/hardware-configuration.nix` as generated hardware data; put host-specific changes in sibling modules and shared system changes in `modules/nixos`.
- Preserve `networking.hostName = "nixos"` and the existing `system.stateVersion` / `home.stateVersion` values; these are intentional compatibility choices.
- Sunshine uses Boost from `nixpkgs-25-05` because Boost 1.89 stalls on this host's RDRAND implementation; avoid removing this override without checking compatibility.
- SOPS age private key is external at `${XDG_CONFIG_HOME}/sops/age/keys.txt` and is needed for Home Manager activation. `.sops.yaml` only matches `secrets/*.yaml` (not nested paths); encrypted `secrets/default.yaml` is repository data.
