"""Apply upstream title abbreviations; only an absent window gets the Nix logo."""

import html
import json
import re
import subprocess
import sys


def label(window, rules):
    if not window.get("address") or window["address"] == "0x0":
        return ""
    title = window.get("title") or window.get("class") or "Untitled"
    for pattern, replacement in rules.items():
        if re.fullmatch(pattern, title):
            return re.sub(pattern, replacement, title)
    return title


if __name__ == "__main__":
    try:
        window = json.loads(subprocess.check_output(["hyprctl", "activewindow", "-j"], text=True, timeout=2))
        with open(sys.argv[1]) as file:
            text = label(window, json.load(file))
    except (subprocess.SubprocessError, ValueError):
        text = ""  # A failed IPC query does not mean that no window is active.
    print(json.dumps({"text": html.escape(text)}))
