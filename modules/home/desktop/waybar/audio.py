"""Choose a PulseAudio/PipeWire sink and move existing playback to it."""

import json
import subprocess
import sys


def pactl(*args):
    return subprocess.run(["pactl", *args], capture_output=True, text=True, check=True, timeout=5).stdout.strip()


def choose_output(theme):
    sinks = json.loads(pactl("-f", "json", "list", "sinks"))
    if not sinks:
        subprocess.run(["notify-send", "Audio output", "No output devices available"], check=False)
        return
    default = pactl("get-default-sink")
    labels = [f'{"●" if sink["name"] == default else "○"} {sink.get("description", sink["name"])}' for sink in sinks]
    selection = subprocess.run(
        ["rofi", "-no-config", "-dmenu", "-i", "-no-custom", "-format", "i", "-m", "-3", "-p", "Audio output", "-theme", theme],
        input="\n".join(label.replace("\n", " ") for label in labels), capture_output=True, text=True,
    )
    if selection.returncode != 0:
        return
    index = int(selection.stdout.strip())
    if not 0 <= index < len(sinks):
        return
    sink = sinks[index]["name"]
    pactl("set-default-sink", sink)
    # A stream may disappear while the menu is open; do not abort other moves.
    failed = []
    for stream in json.loads(pactl("-f", "json", "list", "sink-inputs")):
        try:
            pactl("move-sink-input", str(stream["index"]), sink)
        except subprocess.CalledProcessError:
            failed.append(stream["index"])
    if failed:
        remaining = {s["index"]: s for s in json.loads(pactl("-f", "json", "list", "sink-inputs"))}
        if any(i in remaining and remaining[i]["sink"] != sinks[index]["index"] for i in failed):
            subprocess.run(["notify-send", "Audio output", "Some applications could not be moved; check Pavucontrol."], check=False)


if __name__ == "__main__":
    try:
        choose_output(sys.argv[1])
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, ValueError) as error:
        subprocess.run(["notify-send", "Audio output", str(error)], check=False)
        sys.exit(1)
