{pkgs, ...}: {
  home.packages = with pkgs; [
    hyprsunset
    (pkgs.writeShellApplication {
      name = "night-mode-toggle";
      runtimeInputs = [
        coreutils
        hyprsunset
        procps
      ];
      text = ''
        state_dir="''${XDG_RUNTIME_DIR:-/tmp}/night-mode"
        pid_file="$state_dir/hyprsunset.pid"

        mkdir -p "$state_dir"

        if [ -s "$pid_file" ]; then
          read -r pid < "$pid_file"
          if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
          fi
          rm -f "$pid_file"
        elif pgrep -x hyprsunset >/dev/null; then
          pkill -x hyprsunset
        else
          hyprsunset -t 3000 >/dev/null 2>&1 &
          printf '%s\n' "$!" > "$pid_file"
        fi
      '';
    })
  ];
}
