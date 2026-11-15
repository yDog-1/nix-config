"""Translate upstream JSONC without reimplementing its layout or modules."""

import copy
import json
import pathlib
import sys

import json5


def configure(source, overrides):
    modules = json5.loads((source / "modules.jsonc").read_text())
    for name, values in overrides.items():
        modules.setdefault(name, {}).update(values)
    for name in ("cpu", "memory", "disk"):
        modules.pop(name, None)
    modules["group/apps"]["modules"] = ["custom/cpu", "custom/memory", "custom/disk"]
    modules.pop("custom/updates")
    modules.pop("hyprland/window")
    modules.pop("hyprland/workspaces")
    modules["ext/workspaces"] = {"format": "{name}", "on-click": "activate", "all-outputs": False}
    for name, module in modules.items():
        if name.startswith("group/"):
            module.pop("drawer", None)
            module["modules"] = [item for item in module["modules"] if item not in ("custom/arrow-left", "custom/arrow-right")]
    for name in ("group/info", "group/video", "group/control-center", "group/connection", "group/network", "group/utils", "custom/record", "custom/section", "custom/stop", "network"):
        modules.pop(name, None)
    for name in ("left", "left-apps", "left-end", "tray", "input", "audio", "notifications"):
        modules[f"custom/segment-{name}"] = {"format": "" if name.startswith("left") else "", "tooltip": False}
    modules["group/audio"]["modules"].append("pulseaudio#microphone")
    modules["group/date-clock"] = {"orientation": "horizontal", "modules": ["custom/date", "clock"]}
    modules["clock"].pop("format-alt", None)
    modules["custom/tray-toggle"] = {"format": "&lt;", "tooltip": False}
    modules["group/tray"] = {
        "orientation": "horizontal",
        "drawer": {"transition-duration": 200, "transition-left-to-right": True},
        "modules": ["custom/tray-toggle", "tray"],
    }

    bars = []
    # Map upstream external/laptop layouts to this host's primary/secondary.
    for filename, output in [("config.jsonc", "DP-3"), ("secondmonitor.jsonc", "HDMI-A-1")]:
        bar = json5.loads((source / filename).read_text())
        bar.pop("include")
        bar.pop("passtrough", None)  # Upstream typo; modules must remain clickable.
        bar["modules-left"] = ["custom/window", "custom/segment-left", "ext/workspaces", "custom/segment-left-apps", "group/apps", "custom/segment-left-end"]
        bar["modules-center"] = ["group/date-clock", "custom/weather"]
        bar["modules-right"] = ["custom/segment-tray", "group/tray", "custom/segment-input", "custom/input-method", "custom/segment-audio", "group/audio", "custom/segment-notifications", "custom/notifications", "group/power"]
        bar.update(copy.deepcopy(modules))
        bar["output"] = output
        bar["custom/notifications"]["on-click"] += f" {output}"
        bar["position"] = "top"
        bar["height"] = 27
        bar["layer"] = "top"
        top, right, bottom, left = bar["margin"].split()
        bar["margin"] = f"{bottom} {right} {top} {left}"
        bar["custom/window"]["on-click"] += f" {output} {left} {int(bottom) + bar['height'] + 4}"
        bars.append(bar)
    return bars


if __name__ == "__main__":
    source, overrides_file, destination = map(pathlib.Path, sys.argv[1:])
    destination.write_text(json.dumps(configure(source, json.loads(overrides_file.read_text())), ensure_ascii=False, indent=2))
