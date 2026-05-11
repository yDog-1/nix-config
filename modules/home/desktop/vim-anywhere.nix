{
  lib,
  pkgs,
  ...
}: let
  terminalTargetClasses = [
    "org.wezfurlong.wezterm"
  ];

  terminalTargetClassLines = lib.concatMapStringsSep "\n" (class: "        ${lib.escapeShellArg class}") terminalTargetClasses;

  vimAnywhereWayland = pkgs.writeShellApplication {
    name = "vim-anywhere-wayland";
    runtimeInputs = with pkgs; [
      hyprland
      jq
      pyprland
    ];
    text = ''
      set -euo pipefail

      runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}/vim-anywhere"
      target_file="$runtime_dir/target-address"
      target_window_file="$runtime_dir/target-window.json"

      mkdir -p "$runtime_dir"
      chmod 700 "$runtime_dir"

      active_window_json="$(hyprctl activewindow -j)"

      target_address="$(printf '%s\n' "$active_window_json" | jq -r '.address // empty')"
      if [ -z "$target_address" ]; then
        exit 1
      fi

      printf '%s\n' "$target_address" > "$target_file"
      printf '%s\n' "$active_window_json" > "$target_window_file"

      pypr show vim_anywhere >/dev/null
    '';
  };

  vimAnywhereEditor = pkgs.writeShellApplication {
    name = "vim-anywhere-editor";
    runtimeInputs = with pkgs; [
      coreutils
      hyprland
      jq
      wl-clipboard
      wtype
    ];
    text = ''
            set -euo pipefail

            runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}/vim-anywhere"
            target_file="$runtime_dir/target-address"
            target_window_file="$runtime_dir/target-window.json"
            history_dir="''${TMPDIR:-/tmp}/vim-anywhere"
            tmp_file="$history_dir/doc-$(date +%y%m%d%H%M%S)"

            terminal_target_classes=(
      ${terminalTargetClassLines}
            )

            mkdir -p "$runtime_dir" "$history_dir"
            chmod 700 "$runtime_dir" "$history_dir"
            touch "$tmp_file"
            chmod 600 "$tmp_file"

            is_terminal_target() {
              if [ ! -s "$target_window_file" ]; then
                return 1
              fi

              target_class="$(jq -r '.class // empty' "$target_window_file")"
              target_initial_class="$(jq -r '.initialClass // empty' "$target_window_file")"

              for terminal_class in "''${terminal_target_classes[@]}"; do
                if [ "$target_class" = "$terminal_class" ] || [ "$target_initial_class" = "$terminal_class" ]; then
                  return 0
                fi
              done

              return 1
            }

            editor_cmd="''${EDITOR:-vi}"
            eval "set -- $editor_cmd"
            "$@" "$tmp_file"

            wl-copy < "$tmp_file"

            if [ -s "$target_file" ]; then
              target_address="$(cat "$target_file")"
              hyprctl dispatch focuswindow "address:$target_address" >/dev/null || true
              sleep 0.1
            fi

            if ! is_terminal_target; then
              wtype -M ctrl -k v -m ctrl
            fi
    '';
  };
in {
  home.packages = [
    vimAnywhereWayland
    vimAnywhereEditor
  ];
}
