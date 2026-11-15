import json
import sys

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib


bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)


def call(destination, path, interface, method, parameters=None):
    return bus.call_sync(destination, path, interface, method, parameters, None, Gio.DBusCallFlags.NONE, 1500, None).unpack()


def property_value(destination, path, interface, name):
    return call(destination, path, "org.freedesktop.DBus.Properties", "Get", GLib.Variant("(ss)", (interface, name)))[0]


def skk_mode():
    watcher = "org.kde.StatusNotifierWatcher"
    items = property_value(watcher, "/StatusNotifierWatcher", watcher, "RegisteredStatusNotifierItems")
    for item in items:
        destination, _, path = item.partition("/")
        path = "/" + path
        interface = "org.kde.StatusNotifierItem"
        try:
            if property_value(destination, path, interface, "Id") != "Fcitx":
                continue
            menu = property_value(destination, path, interface, "Menu")
            _, root = call(destination, menu, "com.canonical.dbusmenu", "GetLayout", GLib.Variant("(iias)", (0, -1, [])))
            for child in root[2]:
                _, properties, children = child
                for entry in children:
                    _, option, _ = entry
                    if option.get("toggle-type") == "radio" and option.get("toggle-state") == 1:
                        return option.get("label", "").split(" - ", 1)[0]
        except GLib.Error:
            continue
    return ""


def main():
    controller = "org.fcitx.Fcitx.Controller1"
    state = call("org.fcitx.Fcitx5", "/controller", controller, "State")[0]
    info = call("org.fcitx.Fcitx5", "/controller", controller, "CurrentInputMethodInfo")
    name, label = info[0], info[1]
    if name == "skk":
        mode = skk_mode()
        return {"text": mode or "SKK", "tooltip": f"SKK: {mode}" if mode else "SKK"}
    if state != 2:
        return {"text": "", "tooltip": "キーボード"}
    return {"text": info[5].split("_", 1)[0] or "", "tooltip": label}


try:
    print(json.dumps(main(), ensure_ascii=False))
except (GLib.Error, IndexError):
    print(json.dumps({"text": "", "tooltip": "入力メソッドを取得できません"}, ensure_ascii=False))
    sys.exit(0)
