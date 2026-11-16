import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("rules", Path(__file__).with_name("rules.py"))
rules = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rules)


class CycleTest(unittest.TestCase):
    def test_cycle_walks_on_silent_off_and_back(self):
        self.assertEqual(rules.next_state("enabled"), "muted")
        self.assertEqual(rules.next_state("muted"), "ignored")
        self.assertEqual(rules.next_state("ignored"), "enabled")

    def test_unknown_state_cycles_to_enabled(self):
        self.assertEqual(rules.next_state("bogus"), "enabled")


class EscapeTest(unittest.TestCase):
    def test_escape_leaves_spaces_and_escapes_metacharacters(self):
        self.assertEqual(rules.escape_regex("GNOME Shell"), "GNOME Shell")
        self.assertEqual(rules.escape_regex("a.b+c"), "a\\.b\\+c")
        self.assertEqual(rules.escape_regex("Firefox (Nightly)"), "Firefox \\(Nightly\\)")


class MergeTest(unittest.TestCase):
    def base(self):
        return {
            "widgets": ["notifications"],
            "notification-visibility": {
                "swaync-app-rules-9": {"app-name": "Old", "state": "ignored"},
                "hand-written": {"app-name": "Keep", "state": "muted"},
            },
        }

    def test_enabled_apps_produce_no_rule(self):
        merged = rules.merge_config(self.base(), {"Spotify": "enabled"})
        self.assertEqual(
            merged["notification-visibility"],
            {"hand-written": {"app-name": "Keep", "state": "muted"}},
        )

    def test_stale_generated_rules_are_replaced(self):
        merged = rules.merge_config(self.base(), {"Spotify": "muted"})
        self.assertEqual(
            merged["notification-visibility"],
            {
                "hand-written": {"app-name": "Keep", "state": "muted"},
                "swaync-app-rules-0": {"app-name": "Spotify", "state": "muted"},
            },
        )
        self.assertEqual(merged["widgets"], ["notifications"])

    def test_base_is_not_mutated(self):
        base = self.base()
        rules.merge_config(base, {"Spotify": "muted"})
        self.assertEqual(
            base["notification-visibility"],
            {
                "swaync-app-rules-9": {"app-name": "Old", "state": "ignored"},
                "hand-written": {"app-name": "Keep", "state": "muted"},
            },
        )

    def test_empty_rules_drop_the_key(self):
        merged = rules.merge_config({"widgets": []}, {})
        self.assertNotIn("notification-visibility", merged)


class RowTest(unittest.TestCase):
    def test_rows_round_trip_with_current_state(self):
        text = rules.format_row("Spotify", "muted")
        self.assertEqual(text, "Spotify  [Silent]")
        self.assertEqual(rules.parse_row(text, {"Spotify": "muted"}), ("Spotify", "muted"))

    def test_custom_name_defaults_to_enabled(self):
        self.assertEqual(rules.parse_row("Discord", {}), ("Discord", "enabled"))

    def test_label_text_is_not_part_of_the_name(self):
        self.assertEqual(
            rules.parse_row("Some App  [Off]", {"Some App": "ignored"}),
            ("Some App", "ignored"),
        )


class CatalogueTest(unittest.TestCase):
    def test_recent_apps_prefers_rule_owners_then_newest(self):
        lines = ["New\t3", "Old\t2", "notify-send\t9", "Old\t1"]
        self.assertEqual(
            rules.recent_apps(lines, {"Spotify": "muted"}),
            ["Spotify", "Old", "New"],
        )

    def test_limit_is_respected(self):
        lines = [f"App{index}\t{index}" for index in range(50)]
        self.assertEqual(len(rules.recent_apps(lines, {}, limit=5)), 5)

    def test_record_appends_and_skips_noise(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "apps.log"
            self.assertTrue(rules.record(path, "Spotify", now=1))
            self.assertFalse(rules.record(path, "notify-send"))
            self.assertFalse(rules.record(path, "  "))
            self.assertEqual(path.read_text(), "Spotify\t1\n")

    def test_written_rules_are_reloaded(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "rules.json"
            rules.write_rules(path, {"Spotify": "muted", "Discord": "enabled"})
            self.assertEqual(
                rules.read_rules(path), {"Spotify": "muted", "Discord": "enabled"}
            )

    def test_apply_writes_the_merged_config(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory) / "base.json"
            base.write_text(json.dumps({"timeout": 10}))
            target = Path(directory) / "config.json"
            rules.apply(base, {"Spotify": "ignored"}, target)
            written = json.loads(target.read_text())
            self.assertEqual(written["timeout"], 10)
            self.assertEqual(
                written["notification-visibility"],
                {"swaync-app-rules-0": {"app-name": "Spotify", "state": "ignored"}},
            )


if __name__ == "__main__":
    unittest.main()