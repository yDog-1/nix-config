"""Position wlogout below the Waybar on the selected output."""

import ctypes
import json
import os
import subprocess
import sys


class Rectangle(ctypes.Structure):
    _fields_ = [(name, ctypes.c_int) for name in ("x", "y", "width", "height")]


def main(output, left, top, wlogout, layout, style):
    monitors = json.loads(subprocess.check_output(["hyprctl", "monitors", "-j"], text=True))
    target = next(monitor for monitor in monitors if monitor["name"] == output)
    gdk = ctypes.CDLL(os.environ["GDK_LIBRARY"])
    gdk.gdk_display_open.argtypes = [ctypes.c_char_p]
    gdk.gdk_display_open.restype = ctypes.c_void_p
    gdk.gdk_display_get_n_monitors.argtypes = [ctypes.c_void_p]
    gdk.gdk_display_get_monitor.argtypes = [ctypes.c_void_p, ctypes.c_int]
    gdk.gdk_display_get_monitor.restype = ctypes.c_void_p
    gdk.gdk_monitor_get_geometry.argtypes = [ctypes.c_void_p, ctypes.POINTER(Rectangle)]
    display = gdk.gdk_display_open(None)
    if not display:
        raise RuntimeError("Could not open Wayland display")
    for index in range(gdk.gdk_display_get_n_monitors(display)):
        geometry = Rectangle()
        gdk.gdk_monitor_get_geometry(gdk.gdk_display_get_monitor(display, index), ctypes.byref(geometry))
        if (geometry.x, geometry.y) == (target["x"], target["y"]):
            break
    else:
        raise RuntimeError(f"Monitor {output} not found")

    left, top = int(left), int(top)
    width, height = 112, 112
    args = [
        wlogout, "-n", "-P", str(index), "-b", "2", "-l", layout, "-C", style,
        "-L", str(left), "-T", str(top),
        "-R", str(max(0, geometry.width - left - width)),
        "-B", str(max(0, geometry.height - top - height)),
    ]
    os.execv(wlogout, args)


if __name__ == "__main__":
    main(*sys.argv[1:])
