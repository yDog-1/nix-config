"""Open SwayNC below/right of the clicked Waybar notification button."""

import json
import subprocess
import sys


def panel_margin(cursor, monitor, panel_width=446, gap=8):
    # 420px content + 12px padding and 1px border on each side (SwayNC CSS).
    # Hyprland cursor/monitor origins are logical coordinates; dimensions are physical.
    width, height = monitor["width"], monitor["height"]
    if monitor.get("transform", 0) % 2:
        width, height = height, width
    logical_width = width / monitor.get("scale", 1)
    left = max(gap, min(cursor["x"] - monitor["x"] + gap, logical_width - panel_width - gap))
    return max(gap, round(logical_width - left - panel_width))


def toggle_panel(call, cursor, monitors, output):
    if call("GetVisibility"):
        call("SetVisibility", False)
        return
    monitor = next(monitor for monitor in monitors if monitor["name"] == output)
    right = panel_margin(cursor, monitor)
    # One volatile setting; false explicitly prevents writing the HM-managed config.
    call("ChangeConfigValue", "control-center-margin-right", right, False, "")
    if not call("SetCcMonitor", output):
        raise RuntimeError(f"SwayNC could not select monitor {output}")
    call("SetVisibility", True)


def main(output):
    from gi.repository import Gio, GLib

    proxy = Gio.DBusProxy.new_for_bus_sync(
        Gio.BusType.SESSION, Gio.DBusProxyFlags.NONE, None,
        "org.erikreider.swaync.cc", "/org/erikreider/swaync/cc", "org.erikreider.swaync.cc", None,
    )

    def call(method, *args):
        if method == "ChangeConfigValue":
            parameters = GLib.Variant("(svbs)", (args[0], GLib.Variant("i", args[1]), args[2], args[3]))
        elif method == "SetVisibility":
            parameters = GLib.Variant("(b)", args)
        elif method == "SetCcMonitor":
            parameters = GLib.Variant("(s)", args)
        else:
            parameters = None
        reply = proxy.call_sync(method, parameters, Gio.DBusCallFlags.NONE, 2000, None).unpack()
        return reply[0] if reply else None

    cursor = json.loads(subprocess.check_output(["hyprctl", "cursorpos", "-j"], text=True, timeout=2))
    monitors = json.loads(subprocess.check_output(["hyprctl", "monitors", "-j"], text=True, timeout=2))
    toggle_panel(call, cursor, monitors, output)


if __name__ == "__main__":
    try:
        main(sys.argv[1])
    except Exception as error:
        subprocess.run(["notify-send", "Notification panel", str(error)], check=False)
        sys.exit(1)
