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
    modules.pop("custom/updates")
    modules["group/info"]["modules"].remove("custom/updates")
    modules["group/info"]["modules"] = ["group/media" if name == "custom/playerlabel" else name for name in modules["group/info"]["modules"]]
    modules.pop("hyprland/window")

    bars = []
    # Map upstream external/laptop layouts to this host's primary/secondary.
    for filename, output in [("config.jsonc", "DP-3"), ("secondmonitor.jsonc", "HDMI-A-1")]:
        bar = json5.loads((source / filename).read_text())
        bar.pop("include")
        bar.pop("passtrough", None)  # Upstream typo; modules must remain clickable.
        bar["modules-left"] = ["custom/window" if name == "hyprland/window" else name for name in bar["modules-left"]]
        bar.update(copy.deepcopy(modules))
        bar["output"] = output
        for action in ("exec", "on-click", "on-click-middle", "on-click-right"):
            bar["custom/playerlabel"][action] = f'WAYBAR_OUTPUT_NAME={output} {bar["custom/playerlabel"][action]}'
        for name in ("previous", "play", "next"):
            for action in ("exec", "on-click"):
                bar[f"custom/media-{name}"][action] = f'WAYBAR_OUTPUT_NAME={output} {bar[f"custom/media-{name}"][action]}'
        bar["custom/notifications"]["on-click"] += f" {output}"
        bar["custom/record"]["on-click"] = f'WAYBAR_OUTPUT_NAME={output} {bar["custom/record"]["on-click"]}'
        bar["position"] = "top"
        bar["layer"] = "top"
        top, right, bottom, left = bar["margin"].split()
        bar["margin"] = f"{bottom} {right} {top} {left}"
        bars.append(bar)
    return bars


if __name__ == "__main__":
    source, overrides_file, destination = map(pathlib.Path, sys.argv[1:])
    destination.write_text(json.dumps(configure(source, json.loads(overrides_file.read_text())), ensure_ascii=False, indent=2))
