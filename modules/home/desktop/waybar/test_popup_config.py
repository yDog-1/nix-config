"""Regression assertions against built Home Manager configuration files."""

import json
import os
import pathlib
import unittest


@unittest.skipUnless(os.environ.get("WAYBAR_CONFIG") and os.environ.get("SWAYNC_CONFIG"), "Set paths to built Waybar and SwayNC JSON")
class PopupConfigTests(unittest.TestCase):
    def setUp(self):
        with open(os.environ["WAYBAR_CONFIG"]) as file:
            self.bars = json.load(file)
        with open(os.environ["SWAYNC_CONFIG"]) as file:
            self.notifications = json.load(file)

    def test_layout_and_tray_drawer(self):
        for bar in self.bars:
            self.assertIn("", bar["custom/window"]["format"])
            self.assertEqual([name for name in bar["modules-left"] if not name.startswith("custom/segment-")], ["custom/window", "ext/workspaces", "group/apps"])
            self.assertEqual(bar["ext/workspaces"]["on-click"], "activate")
            self.assertFalse(bar["ext/workspaces"]["all-outputs"])
            self.assertIn("waybar-logout", bar["custom/window"]["on-click"])
            self.assertIn(bar["output"], bar["custom/window"]["on-click"])
            self.assertTrue(pathlib.Path(bar["custom/input-method"]["on-click"]).is_file())
            self.assertEqual(bar["modules-center"], ["group/date-clock", "custom/weather"])
            self.assertEqual(bar["group/date-clock"]["modules"], ["custom/date", "clock"])
            self.assertEqual([name for name in bar["modules-right"] if not name.startswith("custom/segment-")], ["group/tray", "custom/input-method", "group/audio", "custom/notifications", "group/power"])
            self.assertEqual(bar["group/tray"]["modules"], ["custom/tray-toggle", "tray"])
            self.assertEqual(bar["custom/tray-toggle"]["format"], "&lt;")
            self.assertNotIn("format-alt", bar["clock"])
            self.assertIn("%Y/%-m/%-d(%a)", bar["custom/date"]["exec"])
            self.assertIn("--tab=4", bar["pulseaudio#microphone"]["on-click-middle"])
            self.assertTrue(bar["pulseaudio"]["tooltip"])
            self.assertEqual(bar["pulseaudio"]["tooltip-format"], "{desc}")
            self.assertEqual(bar["pulseaudio#microphone"]["tooltip-format"], "{source_desc}")
            self.assertTrue(bar["pulseaudio#microphone"]["tooltip"])
            self.assertEqual(bar["height"], 27)
            self.assertFalse(bar["group/tray"]["drawer"].get("click-to-reveal", False))
            self.assertEqual(bar["group/tray"]["drawer"]["transition-duration"], 200)
            self.assertEqual(bar["group/audio"]["modules"], ["pulseaudio", "pulseaudio#microphone"])
            self.assertIn("set-source-volume", bar["pulseaudio#microphone"]["on-scroll-up"])
            self.assertIn("--lang ja", bar["custom/weather"]["exec"])
            self.assertEqual(bar["custom/weather"]["interval"], 600)
            self.assertFalse(bar["custom/weather"]["exec-on-event"])
            self.assertIn("{icon}", bar["pulseaudio"]["format"])
            self.assertIn("{volume}%", bar["pulseaudio"]["format"])
            for name, group in bar.items():
                if name.startswith("group/") and name != "group/tray":
                    self.assertNotIn("drawer", group)
            for name in ("custom/record", "custom/section", "custom/stop", "network"):
                self.assertNotIn(name, bar)
            self.assertEqual(bar["group/apps"]["modules"], ["custom/cpu", "custom/memory", "custom/disk"])
            for name in ("cpu", "memory", "disk"):
                self.assertEqual(bar[f"custom/{name}"]["return-type"], "json")
                self.assertTrue(bar[f"custom/{name}"]["exec"].endswith(f" {name}"))

    def test_notification_transition_is_instant(self):
        self.assertEqual(self.notifications["transition-time"], 0)

    def test_notification_click_positions_panel(self):
        for bar in self.bars:
            self.assertIn("waybar-notifications", bar["custom/notifications"]["on-click"])
            self.assertIn(bar["output"], bar["custom/notifications"]["on-click"])


if __name__ == "__main__":
    unittest.main()
