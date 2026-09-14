import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]

class PreflightTests(unittest.TestCase):
    def run_script(self, script, env):
        return subprocess.run(["bash", str(ROOT / "scripts" / script)],
                              env={**os.environ, **env}, capture_output=True, text=True)

    def test_ledger_states(self):
        for command, status, code in [("", "skipped", 0), ("printf evidence", "success", 0), ("exit 7", "failed_optional", 7)]:
            with self.subTest(status=status), tempfile.TemporaryDirectory() as directory:
                result = self.run_script("build_node_ledger_evidence.sh", {
                    "NODE_LEDGER_ARTIFACT_DIR": directory, "NODE_LEDGER_COMMAND": command})
                self.assertEqual(result.returncode, 0, result.stderr)
                summary = json.loads((Path(directory) / "summary.json").read_text())
                self.assertEqual((summary["status"], summary["exit_code"]), (status, code))
                self.assertNotIn("command", summary)
                self.assertTrue((Path(directory) / "node-ledger.log").exists())

    def test_gate_blocks_target_and_repair(self):
        for flag in ["", "false", "TRUE"]:
            with self.subTest(flag=flag), tempfile.TemporaryDirectory() as directory:
                target = Path(directory) / "target"
                repair = Path(directory) / "repair"
                result = self.run_script("run_codex_preflight.sh", {
                    "USER_INPUT_FLAG": flag, "TARGET_COMMAND": f"touch '{target}'",
                    "REPAIR_COMMAND": f"touch '{repair}'",
                    "GITHUB_OUTPUT": str(Path(directory) / "output")})
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(target.exists())
                self.assertFalse(repair.exists())

    def test_success_and_failure_retry_counts(self):
        for command, expected_code, targets, repairs in [("true", 0, 1, 0), ("false", 1, 3, 2)]:
            with self.subTest(command=command), tempfile.TemporaryDirectory() as directory:
                target = Path(directory) / "targets"
                repair = Path(directory) / "repairs"
                output = Path(directory) / "output"
                result = self.run_script("run_codex_preflight.sh", {
                    "USER_INPUT_FLAG": "true",
                    "TARGET_COMMAND": f"echo run >> '{target}'; {command}",
                    "REPAIR_COMMAND": f"echo repair >> '{repair}'",
                    "GITHUB_OUTPUT": str(output)})
                self.assertEqual(result.returncode, expected_code)
                self.assertEqual(len(target.read_text().splitlines()), targets)
                self.assertEqual(len(repair.read_text().splitlines()) if repair.exists() else 0, repairs)
                self.assertIn("attempt_result=" + ("success" if expected_code == 0 else "failed"), output.read_text())

if __name__ == "__main__":
    unittest.main()
