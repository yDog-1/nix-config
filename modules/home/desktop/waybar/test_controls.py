import contextlib
import io
import json
import os
import pathlib
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import audio
import media
import window


class WindowTests(unittest.TestCase):
    def test_logo_only_without_active_window(self):
        rules = {"^.*( — Zen Browser|Zen Browser)$": "Zen"}
        self.assertEqual(window.label({}, rules), "")
        self.assertEqual(window.label({"address": "0x123", "title": "", "class": "kitty"}, rules), "kitty")
        self.assertEqual(window.label({"address": "0x123", "title": "Video — Zen Browser"}, rules), "Zen")


class MediaTests(unittest.TestCase):
    def test_playing_browser_wins_and_click_targets_displayed_instance(self):
        calls = []
        statuses = {"firefox.one": "Paused", "chromium.two": "Playing", "spotify": "Playing"}

        def playerctl(*args):
            calls.append(args)
            if args == ("-l",):
                return "\n".join(statuses)
            player = args[1]
            if args[2] == "status":
                return statuses[player]
            if args[2:] == ("metadata", "xesam:title"):
                return "Video <title> & music"
            if args[2:] == ("metadata", "xesam:artist"):
                return "Creator"
            return ""

        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {"XDG_RUNTIME_DIR": directory, "WAYBAR_OUTPUT_NAME": "DP-3"}), patch.object(media, "playerctl", side_effect=playerctl):
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                media.main()
            self.assertIn("&lt;title&gt; &amp;", json.loads(output.getvalue())["text"])
            for icon, expected in [("previous", ""), ("play", ""), ("next", "")]:
                icon_output = io.StringIO()
                with contextlib.redirect_stdout(icon_output):
                    media.main(icon=icon)
                self.assertEqual(json.loads(icon_output.getvalue())["text"], expected)
            self.assertEqual(json.loads((pathlib.Path(directory) / "waybar-media-DP-3.json").read_text())["player"], "chromium.two")
            statuses["firefox.one"] = "Playing"
            media.main("play-pause")
            self.assertEqual(calls[-1], ("-p", "chromium.two", "play-pause"))
            del statuses["chromium.two"]
            calls.clear()
            media.main("next")
            self.assertEqual(calls, [("-l",)])

    def test_play_icon_for_paused_media_and_hide_without_media(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {"XDG_RUNTIME_DIR": directory, "WAYBAR_OUTPUT_NAME": "DP-3"}):
            state = pathlib.Path(directory) / "waybar-media-DP-3.json"
            for data, expected in [({"player": "firefox", "status": "Paused"}, ""), ({"player": "", "status": "Stopped"}, "")]:
                state.write_text(json.dumps(data))
                output = io.StringIO()
                with contextlib.redirect_stdout(output):
                    media.main(icon="play")
                self.assertEqual(json.loads(output.getvalue())["text"], expected)

    def test_no_browser_hides_label_and_stable_selection(self):
        with patch.object(media, "playerctl", return_value="Playing"):
            self.assertIsNone(media.select_player(["spotify", "vlc"], ""))
            selected = media.select_player(["firefox.one", "firefox.two"], "firefox.two")
            self.assertEqual(selected[2], "firefox.two")


class AudioTests(unittest.TestCase):
    sinks = [
        {"index": 1, "name": "speakers", "description": "Output"},
        {"index": 2, "name": "headphones", "description": "Output"},
    ]

    def test_duplicate_labels_select_by_index_and_move_streams(self):
        calls = []

        def pactl(*args):
            calls.append(args)
            if args == ("-f", "json", "list", "sinks"):
                return json.dumps(self.sinks)
            if args == ("get-default-sink",):
                return "speakers"
            if args == ("-f", "json", "list", "sink-inputs"):
                return json.dumps([{"index": 20}, {"index": 21}])
            return ""

        with patch.object(audio, "pactl", side_effect=pactl), patch.object(audio.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, "1\n")):
            audio.choose_output("theme.rasi")
        self.assertIn(("set-default-sink", "headphones"), calls)
        self.assertIn(("move-sink-input", "20", "headphones"), calls)
        self.assertIn(("move-sink-input", "21", "headphones"), calls)

    def test_cancel_does_not_change_audio(self):
        with patch.object(audio, "pactl", side_effect=[json.dumps(self.sinks), "speakers"]) as pactl, patch.object(audio.subprocess, "run", return_value=subprocess.CompletedProcess([], 1, "")):
            audio.choose_output("theme.rasi")
        self.assertEqual(pactl.call_count, 2)


if __name__ == "__main__":
    unittest.main()
