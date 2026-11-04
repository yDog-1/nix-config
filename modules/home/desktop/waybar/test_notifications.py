import unittest
from unittest.mock import Mock

from notifications import panel_margin, toggle_panel


class NotificationPositionTests(unittest.TestCase):
    monitor = {"name": "DP-3", "x": 0, "y": 0, "width": 2560, "height": 1440, "scale": 1}

    def test_panel_starts_to_right_of_clicked_icon(self):
        right = panel_margin({"x": 1300}, self.monitor)
        self.assertEqual(2560 - right - 446, 1308)

    def test_clamps_at_screen_edge(self):
        self.assertEqual(panel_margin({"x": 2500}, self.monitor), 8)

    def test_secondary_scaled_and_rotated_coordinates(self):
        monitor = {**self.monitor, "x": 2560, "width": 3840, "height": 2160, "scale": 2}
        self.assertEqual(panel_margin({"x": 3460}, monitor), 566)
        monitor.update(width=2160, height=3840, transform=1)
        self.assertEqual(panel_margin({"x": 3460}, monitor), 566)

    def test_no_disk_write_and_monitor_selected_before_open(self):
        call = Mock(side_effect=[False, None, True, None])
        toggle_panel(call, {"x": 1300}, [self.monitor], "DP-3")
        self.assertEqual(call.call_args_list[1].args, ("ChangeConfigValue", "control-center-margin-right", 806, False, ""))
        self.assertEqual(call.call_args_list[2].args, ("SetCcMonitor", "DP-3"))
        self.assertEqual(call.call_args_list[3].args, ("SetVisibility", True))

    def test_second_click_only_closes(self):
        call = Mock(return_value=True)
        toggle_panel(call, {}, [], "DP-3")
        self.assertEqual([c.args for c in call.call_args_list], [("GetVisibility",), ("SetVisibility", False)])
