unit=waybar-record.service
case "${1:-}" in
  stop)
    systemctl --user stop "$unit"
    notify-send "Recording stopped" "Saved in $(xdg-user-dir VIDEOS)/record"
    ;;
  fullscreen|section)
    if systemctl --user is-active --quiet "$unit"; then
      notify-send "Recording already active"
      exit 0
    fi
    args=()
    if [[ "$1" == section ]]; then
      geometry=$(slurp) || exit 0
      [[ -n "$geometry" ]] || exit 0
      args+=(-g "$geometry")
    else
      output=${WAYBAR_OUTPUT_NAME:-$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')}
      args+=(-o "$output")
    fi
    directory="$(xdg-user-dir VIDEOS)/record"
    mkdir -p "$directory"
    file="$directory/Video-$(date +%Y%m%d-%H%M%S-%N).mp4"
    # The original VAAPI encoder is AMD-specific. Software H.264 also works on NVIDIA.
    systemd-run --user --collect --unit="$unit" --property=KillSignal=SIGINT \
      --setenv="WAYLAND_DISPLAY=$WAYLAND_DISPLAY" \
      "$(command -v wf-recorder)" -a -c libx264 "${args[@]}" -f "$file"
    notify-send "Recording started" "$file"
    ;;
  *)
    echo "Usage: waybar-record {fullscreen|section|stop}" >&2
    exit 1
    ;;
esac
