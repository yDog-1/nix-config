case "${1:-}" in
  state)
    if systemctl --user is-active --quiet hypridle.service; then
      echo FALSE
    else
      echo TRUE
    fi
    ;;
  toggle)
    case "${SWAYNC_TOGGLE_STATE:-}" in
      true) systemctl --user stop hypridle.service ;;
      *) systemctl --user start hypridle.service ;;
    esac
    ;;
  *)
    echo "usage: $0 {state|toggle}" >&2
    exit 2
    ;;
esac
