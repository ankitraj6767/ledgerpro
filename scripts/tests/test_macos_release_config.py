"""Exercise release policy without Apple credentials, Flutter builds or network."""

import itertools
import os
from pathlib import Path
import re
import subprocess
import tempfile
import textwrap
import unittest


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts/check_macos_release_config.sh"
CERTIFICATE = ("MACOS_CERTIFICATE_P12_BASE64", "MACOS_CERTIFICATE_PASSWORD")
APPLE_ID = ("APPLE_ID", "APPLE_APP_SPECIFIC_PASSWORD", "APPLE_TEAM_ID")
API_KEY = ("APPLE_API_KEY_ID", "APPLE_API_ISSUER_ID", "APPLE_API_KEY_P8_BASE64")
WORKFLOWS = ("macos-desktop-release.yml", "macos-desktop-build.yml")


def workflow_step(workflow, name):
    text = (ROOT / ".github/workflows" / workflow).read_text()
    match = re.search(
        r"^      - name: " + re.escape(name) + r"\n(.*?)(?=^      - name: |\Z)",
        text, re.MULTILINE | re.DOTALL,
    )
    if match is None:
        raise AssertionError(f"Missing {name} in {workflow}")
    return match.group(1)


class MacOSReleaseConfigurationTest(unittest.TestCase):
    def check_config(self, keys=(), event="workflow_dispatch", allow=False):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "output"
            summary = Path(directory) / "summary"
            # Do not inherit real signing credentials from a developer or runner.
            env = {
                "PATH": os.environ["PATH"],
                "MACOS_RELEASE_EVENT": event,
                "ALLOW_UNSIGNED_MACOS_ARTIFACT": str(allow).lower(),
                "GITHUB_OUTPUT": str(output),
                "GITHUB_STEP_SUMMARY": str(summary),
                **{key: "test-value-do-not-log" for key in keys},
            }
            process = subprocess.run(
                ["bash", str(SCRIPT)], env=env, text=True, capture_output=True
            )
            self.assertEqual(process.stderr, "")
            result = output.read_text().strip().removeprefix("mode=")
            report = summary.read_text()
            self.assertNotIn("test-value-do-not-log", process.stdout + report)
            return process.returncode, result, process.stdout, report

    def test_unconfigured_push_skips_without_publication(self):
        status, mode, log, report = self.check_config(event="push")
        self.assertEqual((status, mode), (0, "skip"))
        self.assertIn("::warning::", log)
        self.assertIn("Existing downloads remain unchanged", report)
        for key in CERTIFICATE + APPLE_ID + API_KEY:
            self.assertIn(key, report)

    def test_unconfigured_manual_release_fails_before_build(self):
        status, mode, log, _ = self.check_config()
        self.assertEqual((status, mode), (1, "skip"))
        self.assertIn("::error::", log)
        self.assertIn("allow_unsigned_artifact=true", log)

    def test_explicit_internal_build_is_available_without_apple_secrets(self):
        status, mode, _, report = self.check_config(allow=True)
        self.assertEqual((status, mode), (0, "internal"))
        self.assertIn("No public macOS release", report)

    def test_push_cannot_opt_into_unsigned_artifacts(self):
        status, mode, _, _ = self.check_config(event="push", allow=True)
        self.assertEqual((status, mode), (0, "skip"))

    def test_signed_but_unnotarized_is_internal_only(self):
        status, mode, _, _ = self.check_config(CERTIFICATE, allow=True)
        self.assertEqual((status, mode), (0, "internal"))

    def test_either_complete_notarization_method_enables_releases(self):
        for credentials in (APPLE_ID, API_KEY, APPLE_ID + API_KEY):
            for event in ("push", "workflow_dispatch"):
                with self.subTest(credentials=credentials, event=event):
                    status, mode, _, report = self.check_config(
                        CERTIFICATE + credentials, event=event
                    )
                    self.assertEqual((status, mode), (0, "release"))
                    self.assertIn("must still succeed before publication", report)

    def test_all_partial_credential_combinations(self):
        # Exhaust all 256 subsets, including mismatched halves of the two
        # notarization methods, on automatic, strict manual and internal runs.
        names = CERTIFICATE + APPLE_ID + API_KEY
        for presence in itertools.product((False, True), repeat=len(names)):
            keys = {key for key, present in zip(names, presence) if present}
            complete = set(CERTIFICATE) <= keys and (
                set(APPLE_ID) <= keys or set(API_KEY) <= keys
            )
            for event, allow in (("push", False), ("workflow_dispatch", False),
                                 ("workflow_dispatch", True)):
                with self.subTest(keys=sorted(keys), event=event, allow=allow):
                    status, mode, _, _ = self.check_config(keys, event, allow)
                    expected = ((0, "release") if complete else
                                (0, "internal") if allow else
                                (0, "skip") if event == "push" else (1, "skip"))
                    self.assertEqual((status, mode), expected)


class MacOSNotarizationPublicationTest(unittest.TestCase):
    def run_notarization_step(self, workflow, keys=(), signed=True, allow=False,
                              notary_exit=0):
        # Execute the real workflow shell with a stub in place of the Apple
        # submission script. Never contact Apple or use actual certificates.
        step = workflow_step(workflow, "Notarize macOS app")
        script = textwrap.dedent(step.split("        run: |\n", 1)[1])
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            scripts = root / "scripts"
            scripts.mkdir()
            stub = scripts / "notarize_macos_app.sh"
            stub.write_text(f"#!/usr/bin/env bash\nexit {notary_exit}\n")
            stub.chmod(0o755)
            output = root / "output"
            env = {
                "PATH": os.environ["PATH"],
                "GITHUB_OUTPUT": str(output),
                "MACOS_SIGNING_CONFIGURED": str(signed).lower(),
                "ALLOW_UNSIGNED_MACOS_ARTIFACT": str(allow).lower(),
                **{key: "dummy-test-credential" for key in keys},
            }
            result = subprocess.run(
                ["bash", "-euo", "pipefail", "-c", script], cwd=root,
                env=env, text=True, capture_output=True,
            )
            return result.returncode, output.read_text() if output.exists() else ""

    def test_skipped_notarization_never_reports_success(self):
        for workflow in WORKFLOWS:
            for signed in (False, True):
                with self.subTest(workflow=workflow, signed=signed):
                    self.assertEqual(
                        self.run_notarization_step(workflow, signed=signed, allow=True),
                        (0, ""),
                    )

    def test_strict_notarization_rejects_missing_credentials(self):
        for workflow in WORKFLOWS:
            with self.subTest(workflow=workflow):
                self.assertEqual(self.run_notarization_step(workflow), (1, ""))

    def test_successful_notarization_is_required_for_success_output(self):
        for workflow in WORKFLOWS:
            for credentials in (APPLE_ID, API_KEY):
                with self.subTest(workflow=workflow, credentials=credentials):
                    self.assertEqual(
                        self.run_notarization_step(workflow, credentials),
                        (0, "notarized=true\n"),
                    )
                    # Even explicit test opt-in cannot hide a real Apple failure.
                    self.assertEqual(
                        self.run_notarization_step(
                            workflow, credentials, allow=True, notary_exit=42
                        ), (42, ""),
                    )

    def test_both_publication_steps_require_release_mode_and_notarization(self):
        for name in ("Publish GitHub Release (macOS asset)",
                     "Publish to Supabase + update manifest"):
            with self.subTest(name=name):
                step = workflow_step(WORKFLOWS[0], name)
                condition = next(line.strip() for line in step.splitlines()
                                 if line.strip().startswith("if:"))
                self.assertEqual(
                    condition,
                    "if: ${{ needs.configuration.outputs.mode == 'release' "
                    "&& steps.notarize.outputs.notarized == 'true' }}",
                )


if __name__ == "__main__":
    unittest.main()
