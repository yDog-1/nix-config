"""Choose a PulseAudio/PipeWire sink and move existing playback to it."""

import json
import subprocess
import sys


def pactl(*args):
    return subprocess.run(["pactl", *args], capture_output=True, text=True, check=True, timeout=5).stdout.strip()


def choose_output(theme, kind="sink"):
    title = "Audio output" if kind == "sink" else "Audio input"
    devices = json.loads(pactl("-f", "json", "list", f"{kind}s"))
    if kind == "source":
        devices = [device for device in devices if not device["name"].endswith(".monitor")]
    if not devices:
        subprocess.run(["notify-send", title, "No devices available"], check=False)
        return
    default = pactl(f"get-default-{kind}")
    labels = [
        f'{"●" if device["name"] == default else "○"} {device.get("description") if device.get("description") not in (None, "", "(null)") else device["name"]}'
        for device in devices
    ]
    selection = subprocess.run(
        ["rofi", "-no-config", "-dmenu", "-i", "-no-custom", "-format", "i", "-m", "-3", "-p", title, "-theme", theme, "-click-to-exit", "-me-select-entry", "", "-me-accept-entry", "MousePrimary"],
        input="\n".join(label.replace("\n", " ") for label in labels), capture_output=True, text=True,
    )
    if selection.returncode != 0:
        return
    index = int(selection.stdout.strip())
    if not 0 <= index < len(devices):
        return
    device = devices[index]["name"]
    pactl(f"set-default-{kind}", device)
    stream_kind = "sink-input" if kind == "sink" else "source-output"
    failed = []
    for stream in json.loads(pactl("-f", "json", "list", f"{stream_kind}s")):
        try:
            pactl(f"move-{stream_kind}", str(stream["index"]), device)
        except subprocess.CalledProcessError:
            failed.append(stream["index"])
    if failed:
        remaining = {s["index"]: s for s in json.loads(pactl("-f", "json", "list", f"{stream_kind}s"))}
        if any(i in remaining and remaining[i][kind] != devices[index]["index"] for i in failed):
            subprocess.run(["notify-send", title, "Some applications could not be moved; check Pavucontrol."], check=False)


if __name__ == "__main__":
    try:
        choose_output(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else "sink")
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, ValueError) as error:
        subprocess.run(["notify-send", "Audio output", str(error)], check=False)
        sys.exit(1)
