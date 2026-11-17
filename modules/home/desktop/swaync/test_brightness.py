import importlib.util
import io
from contextlib import redirect_stdout
from pathlib import Path
import subprocess
import sys
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("brightness", Path(__file__).with_name("brightness.py"))
brightness = importlib.util.module_from_spec(spec)
spec.loader.exec_module(brightness)


class BrightnessTest(unittest.TestCase):
    def run_action(self, args, response="VCP 10 C 40 80\n"):
        output = io.StringIO()
        with patch.object(sys, "argv", ["brightness", *args]), patch.object(
            brightness.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, response, "")
        ) as run, redirect_stdout(output):
            brightness.main()
        return output.getvalue(), run.call_args_list

    def test_get_scales_monitor_range(self):
        output, calls = self.run_action(["lg", "get"])
        self.assertEqual(output, "50\n")
        self.assertEqual(calls[0].args[0], ["ddcutil", "--model", "MP59G", "--terse", "--skip-ddc-checks", "getvcp", "10"])

    def test_set_selects_model_and_scales(self):
        _, calls = self.run_action(["pixio", "set", "75"])
        self.assertEqual(calls[1].args[0], ["ddcutil", "--model", "PX277h/PX276h", "--terse", "--skip-ddc-checks", "setvcp", "10", "60"])

    def test_ignores_flock_diagnostics_before_the_reading(self):
        noisy = (
            "(flock_lock_by_fd              )           Max wait time 0 milliseconds exceeded after 2 flock() calls\n"
            "(flock_lock_by_fd              )           flock() for /dev/i2c-9 failed on 2 calls\n"
            "VCP 10 C 40 80\n"
        )
        output, _ = self.run_action(["lg", "get"], noisy)
        self.assertEqual(output, "50\n")

    def test_rejects_bad_reading_and_value(self):
        with self.assertRaises(ValueError):
            self.run_action(["lg", "get"], "bad output")
        with self.assertRaises(ValueError):
            self.run_action(["lg", "set", "101"])


if __name__ == "__main__":
    unittest.main()
