"""Select browser MPRIS media, and control exactly the last displayed player."""

import html
import json
import os
import pathlib
import re
import subprocess
import sys

BROWSERS = ("firefox", "chromium", "chrome", "google-chrome", "brave", "zen", "librewolf", "floorp", "vivaldi", "opera", "microsoft-edge")


def playerctl(*args):
    try:
        result = subprocess.run(["playerctl", *args], capture_output=True, text=True, timeout=2)
        return result.stdout.strip() if result.returncode == 0 else ""
    except subprocess.TimeoutExpired:
        return ""


def select_player(players, previous):
    candidates = []
    for player in players:
        if not player.lower().startswith(BROWSERS):
            continue
        status = playerctl("-p", player, "status")
        if status not in ("Playing", "Paused"):
            continue
        title = playerctl("-p", player, "metadata", "xesam:title")
        if not title:
            continue
        artist = playerctl("-p", player, "metadata", "xesam:artist")
        candidates.append((status != "Playing", player != previous, player, status, title, artist))
    return min(candidates) if candidates else None


def main(action=None):
    output = re.sub(r"[^a-zA-Z0-9_-]", "_", os.environ.get("WAYBAR_OUTPUT_NAME", "default"))
    state = pathlib.Path(os.environ["XDG_RUNTIME_DIR"]) / f"waybar-media-{output}.json"
    try:
        previous = json.loads(state.read_text())["player"]
    except (OSError, ValueError, KeyError):
        previous = ""
    players = playerctl("-l").splitlines()
    if action:
        if action not in ("previous", "play-pause", "next"):
            raise ValueError("Unknown media action")
        if previous and previous in players:
            playerctl("-p", previous, action)
        return
    selected = select_player(players, previous)
    if selected:
        _, _, player, status, title, artist = selected
        text = f"{artist} : {title}" if artist else title
    else:
        player, status, text = "", "Stopped", ""
    temporary = state.with_suffix(f".{os.getpid()}.tmp")
    temporary.write_text(json.dumps({"player": player}))
    temporary.replace(state)
    print(json.dumps({"text": html.escape(text), "class": status, "alt": status}))


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else None)
