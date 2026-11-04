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

    def test_independent_left_click_media_buttons(self):
        for bar in self.bars:
            group = bar.get("group/media", {}).get("modules", [])
            for name, action in [("previous", "previous"), ("play", "play-pause"), ("next", "next")]:
                key = f"custom/media-{name}"
                self.assertIn(key, group)
                self.assertIn(action, bar[key]["on-click"])
                self.assertTrue(bar[key]["format"])
            self.assertIn("group/media", bar["group/info"]["modules"])

    def test_notification_transition_matches_drawers(self):
        for bar in self.bars:
            self.assertEqual(self.notifications["transition-time"], bar["group/utils"]["drawer"]["transition-duration"])
        compositor = (pathlib.Path(__file__).parent.parent / "hyprland" / "hyprland.lua").read_text()
        self.assertIn('ipairs({ "layers", "fadeLayers", "fadePopups" })', compositor)
        self.assertIn('leaf = leaf, enabled = true, speed = 3, bezier = "default"', compositor)

    def test_notification_click_positions_panel(self):
        for bar in self.bars:
            self.assertIn("waybar-notifications", bar["custom/notifications"]["on-click"])
            self.assertIn(bar["output"], bar["custom/notifications"]["on-click"])


if __name__ == "__main__":
    unittest.main()
