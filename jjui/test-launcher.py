#!/usr/bin/env python3
"""Test startup wiring without running or modifying a real JJ workspace."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time
import unittest

LAUNCHER = Path(__file__).with_name("launch.sh")


class LauncherTests(unittest.TestCase):
    def invoke(self, args=(), overrides=None, warm=True, marker=False):
        with tempfile.TemporaryDirectory(prefix="hx-launch test-") as directory:
            root = Path(directory)
            nested = root / "nested"
            nested.mkdir()
            if marker:
                (root / ".jj/working_copy").mkdir(parents=True)
            binaries = root / "bin"
            binaries.mkdir()
            scripts = {
                "jj": 'import os,sys,pathlib\nassert sys.argv[1:] == ["root", "--ignore-working-copy", "--color", "never"]\npathlib.Path(os.environ["TEST_ROOT"],"root-probed").touch()\nprint(os.environ["TEST_ROOT"])\n',
                "jjui": 'import json,os,sys,pathlib\np=pathlib.Path(os.environ["TEST_ROOT"])\n(p/"ui.json").write_text(json.dumps(dict(args=sys.argv[1:],worker=os.getenv("HELIX_DIFF_WORKER"),shared=os.getenv("HELIX_DIFF_WORKER_SHARED_VIEWPORT"))))\n',
                "hx": 'import json,os,sys,pathlib,time\np=pathlib.Path(os.environ["TEST_ROOT"])\ndeadline=time.monotonic()+3\nwhile not (p/"ui.json").exists() and time.monotonic()<deadline: time.sleep(.005)\n(p/"warm.json").write_text(json.dumps(dict(args=sys.argv[1:],cwd=os.getcwd(),ui_started=(p/"ui.json").exists())))\n',
            }
            for name, body in scripts.items():
                path = binaries / name
                path.write_text("#!/usr/bin/env python3\n" + body)
                path.chmod(0o700)
            env = dict(os.environ, PATH=str(binaries) + os.pathsep + os.environ["PATH"],
                       TEST_ROOT=str(root), NEOHELIX_JJUI_BIN=str(binaries / "jjui"), NEOHELIX_HX_BIN=str(binaries / "hx"))
            env.pop("HELIX_DIFF_WORKER", None)
            env.pop("HELIX_DIFF_WORKER_SHARED_VIEWPORT", None)
            env.update(overrides or {})
            actual = [str(nested) if arg == "LOCATION" else str(root) if arg == "ROOT" else arg for arg in args]
            result = subprocess.run(["bash", str(LAUNCHER), *actual], env=env, cwd=nested, capture_output=True, timeout=5)
            self.assertEqual(result.returncode, 0, result.stderr)
            ui = json.loads((root / "ui.json").read_text())
            self.assertEqual(ui["args"], actual)
            if warm:
                deadline = time.monotonic() + 3
                while not (root / "warm.json").exists() and time.monotonic() < deadline:
                    time.sleep(.01)
                record = json.loads((root / "warm.json").read_text())
                self.assertTrue(record["ui_started"], "warmup blocked the actual UI launch")
                self.assertEqual(record["cwd"], str(root.resolve()))
                self.assertEqual(record["args"], ["--diff-worker-warm", "--width", "100"])
            else:
                time.sleep(.05)
                self.assertFalse((root / "warm.json").exists())
            ui["root_probed"] = (root / "root-probed").exists()
            return ui

    def test_warmup_runs_concurrently_and_rooted_without_rewriting_arguments(self):
        ui = self.invoke(["-r", "description('hello world')", "--limit=8", "LOCATION"])
        self.assertEqual((ui["worker"], ui["shared"]), ("1", "1"))

    def test_current_directory_and_explicit_separator(self):
        self.invoke()
        self.invoke(["--", "LOCATION"])

    def test_workspace_marker_avoids_duplicate_root_process(self):
        self.assertFalse(self.invoke(["ROOT"], marker=True)["root_probed"])

    def test_non_ui_flags_and_unknown_options_do_not_start_workers(self):
        for arg in ["--version", "--help", "--config", "--install-lua-types", "--future-option"]:
            self.invoke([arg], warm=False)

    def test_explicit_opt_outs_are_respected(self):
        self.assertEqual(self.invoke(overrides={"HELIX_DIFF_WORKER": "0"}, warm=False)["worker"], "0")
        self.assertEqual(self.invoke(overrides={"HELIX_DIFF_WORKER_SHARED_VIEWPORT": "0"}, warm=False)["shared"], "0")


if __name__ == "__main__":
    unittest.main()
