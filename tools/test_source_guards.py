"""Run the real Phase 9 guard against formatted and broken checkout fixtures."""
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class Phase9SourceGuardTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.scratch = tempfile.TemporaryDirectory(prefix='ledger-source-guard-')
        cls.addClassCleanup(cls.scratch.cleanup)
        cls.fixture = Path(cls.scratch.name)
        for name in ('android', 'ios', 'lib', 'supabase'):
            shutil.copytree(ROOT / name, cls.fixture / name)
        (cls.fixture / 'tools').mkdir()
        shutil.copy2(ROOT / 'tools/phase9_security_checks.py', cls.fixture / 'tools')
        cls.onboarding = cls.fixture / 'lib/features/onboarding/presentation/onboarding_screen.dart'
        cls.original = cls.onboarding.read_text()

    def setUp(self):
        self.onboarding.write_text(self.original)

    def run_guard(self):
        return subprocess.run(
            [sys.executable, str(self.fixture / 'tools/phase9_security_checks.py')],
            cwd=self.fixture, text=True, capture_output=True, check=False,
        )

    def replace_define(self, replacement):
        changed, count = re.subn(
            r"String\.fromEnvironment\(\s*'ACCOUNT_DELETION_URL'\s*,?\s*\)",
            lambda _: replacement, self.original,
        )
        self.assertEqual(count, 1, 'fixture must contain exactly one URL define')
        self.onboarding.write_text(changed)

    def test_current_formatter_output_passes(self):
        result = self.run_guard()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_single_line_define_passes(self):
        self.replace_define("String.fromEnvironment('ACCOUNT_DELETION_URL')")
        result = self.run_guard()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_wrong_environment_name_fails(self):
        self.replace_define("String.fromEnvironment('WRONG_URL')")
        result = self.run_guard()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('missing account-deletion URL environment define', result.stderr)

    def test_literal_url_without_environment_define_fails(self):
        self.replace_define("'https://example.invalid/delete-account'")
        result = self.run_guard()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('missing account-deletion URL environment define', result.stderr)


if __name__ == '__main__':
    unittest.main()
