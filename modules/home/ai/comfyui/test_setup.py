"""Lifecycle tests with fake installers; no GPU, network, or user data required."""

import fcntl
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SCRIPTS = Path(__file__).parent


class SetupTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="comfyui-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.data = self.root / "data with spaces"
        self.runtime = self.root / "runtime"
        self.bin = self.root / "bin"
        self.bin.mkdir()
        (self.runtime / "app").mkdir(parents=True)
        (self.runtime / "app" / "main.py").touch()
        (self.runtime / "check-gpu.py").touch()
        (self.runtime / "constraints.txt").write_text("torch==2.10.0+cu126\n")
        (self.runtime / "requirements.lock").write_text("locked\n")
        self.log = self.root / "events"
        self.environment = os.environ | {
            "PATH": f"{self.bin}:{os.environ['PATH']}",
            "data_dir": str(self.data),
            "current": str(self.data / "current"),
            "managed_runtime": str(self.runtime),
            "environment_id": "test-id",
            "CUDA_CACHE_PATH": str(self.data / ".cache/cuda"),
            "HF_HOME": str(self.data / ".cache/huggingface"),
            "TORCH_HOME": str(self.data / ".cache/torch"),
            "EVENT_LOG": str(self.log),
        }
        self.executable("nix-store", '''
while [[ $# -gt 0 ]]; do
  if [[ "$1" == --add-root ]]; then
    ln -s "$managed_runtime" "$2"
    exit 0
  fi
  shift
done
exit 1
''')
        self.executable("uv", '''
printf '%s\\n' "$*" >>"$EVENT_LOG"
if [[ "$*" == *"pip compile"* ]]; then
  if [[ "${FAIL_COMPILE:-0}" == 1 ]]; then exit 1; fi
  while [[ "$1" != --output-file ]]; do shift; done
  printf 'new-lock\\n' >"$2"
elif [[ "$*" == *"pip sync"* ]]; then
  if [[ "${FAIL_SYNC:-0}" == 1 ]]; then exit 1; fi
elif [[ "$*" == *venv* ]]; then
  destination="${!#}"
  mkdir -p "$destination/bin"
  cat >"$destination/bin/python" <<'PYTHON'
#!/usr/bin/env bash
printf '%s\\n' "$@" >>"$EVENT_LOG"
if [[ "$1" == *check-gpu.py && "${FAIL_GPU:-0}" == 1 ]]; then exit 1; fi
if [[ "$*" == *--quick-test-for-ci* && "${FAIL_STARTUP:-0}" == 1 ]]; then exit 1; fi
PYTHON
  chmod +x "$destination/bin/python"
else
  exit 99
fi
''')

    def executable(self, name, contents):
        path = self.bin / name
        shebang = f"#!{shutil.which('bash')}"
        path.write_text(
            shebang + "\nset -euo pipefail\n"
            + contents.replace("#!/usr/bin/env bash", shebang)
        )
        path.chmod(0o755)

    def run_script(self, script="setup.sh", *args, **environment):
        return subprocess.run(
            ["bash", "-euo", "pipefail", str(SCRIPTS / script), *args],
            env=self.environment | environment,
            text=True,
            capture_output=True,
        )

    def setup_ok(self, *args, **environment):
        result = self.run_script("setup.sh", *args, **environment)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return (self.data / "current").resolve()

    def test_setup_reuses_locked_environment_and_preserves_legacy(self):
        (self.data / "app").mkdir(parents=True)
        legacy = self.data / "app" / "local-node.py"
        legacy.write_text("user code")
        active = self.setup_ok()
        self.assertEqual((active / "ready").read_text(), "test-id\n")
        self.assertEqual(self.setup_ok(), active)
        self.assertEqual(legacy.read_text(), "user code")
        log = self.log.read_text()
        self.assertEqual(log.count("pip sync"), 1)
        self.assertNotIn("pip compile", log)
        self.assertNotIn("--clear", log)
        self.assertIn("--require-hashes --strict", log)
        self.assertIn("--quick-test-for-ci", log)

    def test_rebuild_keeps_previous_and_shared_data(self):
        first = self.setup_ok()
        model = self.data / "models" / "keep.safetensors"
        model.write_text("model")
        second = self.setup_ok("--rebuild")
        self.assertNotEqual(first, second)
        self.assertEqual((self.data / "previous").resolve(), first)
        self.assertTrue((first / ".venv/bin/python").exists())
        self.assertEqual(model.read_text(), "model")

    def test_new_runtime_id_creates_candidate_without_overwriting_old_one(self):
        first = self.setup_ok()
        second = self.setup_ok(environment_id="updated-id")
        self.assertNotEqual(first, second)
        self.assertEqual((second / "ready").read_text(), "updated-id\n")
        self.assertEqual((self.data / "previous").resolve(), first)

    def test_failed_install_gpu_or_startup_never_switches_current(self):
        first = self.setup_ok()
        for failure in ("FAIL_SYNC", "FAIL_GPU", "FAIL_STARTUP"):
            with self.subTest(failure=failure):
                result = self.run_script("setup.sh", "--rebuild", **{failure: "1"})
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual((self.data / "current").resolve(), first)
                self.assertFalse((self.data / "previous").exists())

    def test_refuses_user_owned_current_directory(self):
        (self.data / "current").mkdir(parents=True)
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("non-symlink", result.stderr)
        self.assertFalse(self.log.exists())

    def test_rejects_concurrent_setup(self):
        self.data.mkdir()
        with (self.data / ".setup.lock").open("w") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Another ComfyUI setup", result.stderr)

    def test_invalid_arguments_do_not_create_an_environment(self):
        for args in (("--unknown",), ("--rebuild", "extra")):
            result = self.run_script("setup.sh", *args)
            self.assertEqual(result.returncode, 2)
        self.assertFalse(self.data.exists())

    def test_launch_uses_active_snapshot_and_optional_flags_only(self):
        active = self.setup_ok()
        self.log.write_text("")
        result = self.run_script("launch.sh", "--lowvram")
        self.assertEqual(result.returncode, 0, result.stderr)
        args = self.log.read_text().splitlines()
        self.assertEqual(args[0], str(active / "app/main.py"))
        self.assertEqual(args.count("--lowvram"), 1)
        self.assertNotIn("--disable-dynamic-vram", args)
        self.assertEqual(args[args.index("--listen") + 1], "0.0.0.0")
        self.assertIn(str(self.data / "output"), args)

    def test_launch_preserves_legacy_until_setup_succeeds(self):
        legacy = self.data / "app"
        legacy.mkdir(parents=True)
        (legacy / "main.py").touch()
        (self.data / ".venv/bin").mkdir(parents=True)
        python = self.data / ".venv/bin/python"
        python.write_text(f"#!{shutil.which('bash')}\nprintf '%s\\n' \"$@\" >\"$EVENT_LOG\"\n")
        python.chmod(0o755)
        result = self.run_script("launch.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.log.read_text().splitlines()[0], str(legacy / "main.py"))

    def test_failed_initial_setup_does_not_activate_candidate(self):
        result = self.run_script("setup.sh", FAIL_GPU="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.data / "current").is_symlink())
        self.assertTrue(list((self.data / "environments").iterdir()))

    def test_update_lock_is_explicit_and_failure_preserves_old_lock(self):
        output = self.root / "requirements.lock"
        output.write_text("old-lock\n")
        result = self.run_script("update-lock.sh", str(output), FAIL_COMPILE="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(output.read_text(), "old-lock\n")
        result = self.run_script("update-lock.sh", str(output))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(output.read_text(), "new-lock\n")
        self.assertEqual(self.run_script("update-lock.sh").returncode, 2)


if __name__ == "__main__":
    unittest.main()
