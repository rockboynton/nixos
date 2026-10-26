import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location(
    "update_flake", Path(__file__).with_name("update-flake.py"),
)
updater = importlib.util.module_from_spec(spec)
spec.loader.exec_module(updater)
HASH = "sha256-" + "B" * 43 + "="


class UpdateTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "flake.lock").write_text("original lock with local edits")
        for source, name in updater.TARGETS.items():
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(
                "# unrelated local edit\ncargoDeps = pkgs.rustPlatform.fetchCargoVendor {\n"
                f'  src = inputs.{source};\n  hash = "{updater.FAKE_HASH}";\n'
                "};\n"
            )
        self.originals = {p: p.read_bytes() for p in self.root.rglob("*") if p.is_file()}

    def bump(self, *args, **kwargs):
        (self.root / "flake.lock").write_text("updated lock")

    def test_bump_updates_both_hashes_and_preserves_other_edits(self):
        with patch.object(updater.subprocess, "run", side_effect=self.bump), \
                patch.object(updater, "vendor_hash", return_value=HASH):
            updater.update(self.root, "nix")
        self.assertEqual((self.root / "flake.lock").read_text(), "updated lock")
        for name in updater.TARGETS.values():
            content = (self.root / name).read_text()
            self.assertIn(HASH, content)
            self.assertIn("# unrelated local edit", content)

    def test_second_hash_failure_restores_lock_and_both_files(self):
        with patch.object(updater.subprocess, "run", side_effect=self.bump), \
                patch.object(updater, "vendor_hash", side_effect=[HASH, RuntimeError("network")]):
            with self.assertRaises(RuntimeError):
                updater.update(self.root, "nix")
        for path, content in self.originals.items():
            self.assertEqual(path.read_bytes(), content)

    def test_hashes_only_does_not_bump_inputs(self):
        with patch.object(updater.subprocess, "run") as run, \
                patch.object(updater, "vendor_hash", return_value=HASH):
            updater.update(self.root, "nix", hashes_only=True)
        run.assert_not_called()
        self.assertEqual((self.root / "flake.lock").read_bytes(),
                         self.originals[self.root / "flake.lock"])

    def test_fetch_failure_is_not_accepted_as_a_hash(self):
        failure = subprocess.CompletedProcess([], 1, "network unavailable")
        with patch.object(updater.subprocess, "run", return_value=failure):
            with self.assertRaisesRegex(RuntimeError, "Cannot determine"):
                updater.vendor_hash("nix", self.root, "niri-src")

    def test_hash_is_verified_before_being_accepted(self):
        mismatch = subprocess.CompletedProcess([], 1, f"  got: {HASH}\n")
        failure = subprocess.CompletedProcess([], 1, "vendor build failed")
        with patch.object(updater.subprocess, "run", side_effect=[mismatch, failure]):
            with self.assertRaisesRegex(RuntimeError, "Cannot verify"):
                updater.vendor_hash("nix", self.root, "niri-src")


if __name__ == "__main__":
    unittest.main()
