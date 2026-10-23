#!/usr/bin/env python3
"""Public endpoint configuration and pre-build rejection regressions."""
from __future__ import annotations

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

from lib.build_config import validate_api_url
import prepare_mobile_release


class BuildConfigTests(unittest.TestCase):
    def test_replica_and_supported_network_endpoints(self):
        for value in ['', 'https://api.example.invalid', 'https://api.example.invalid/',
                      'https://api.example.invalid:8443', 'https://[::1]:443/',
                      'http://localhost:19090', 'http://127.0.0.1:19090/',
                      'http://10.0.2.2:19090']:
            with self.subTest(value=value):
                self.assertEqual(validate_api_url(value), value)

    def test_rejects_unsafe_or_malformed_endpoints_without_echoing_input(self):
        for value in ['https://user:fixture-private@api.example.invalid',
                      'https://api.example.invalid?token=fixture-private',
                      'https://api.example.invalid#fixture-private',
                      'https://api.example.invalid?', 'https://api.example.invalid#',
                      'https://api.example.invalid:wrong', 'https://api.example.invalid:65536',
                      'https://api.example.invalid:0', 'https://api.example.invalid:',
                      'https://api.example.invalid/service', 'http://api.example.invalid',
                      'http://[::1]:19090', 'https:///missing-host',
                      'https://bad..example.invalid', 'https://-bad.example.invalid',
                      'https://api.example.invalid\\private',
                      ' https://api.example.invalid', 'https://api.example.invalid\n',
                      'https://[broken', 'https://[::1]trailing-text', 'not-a-url']:
            with self.subTest(value=value):
                with self.assertRaises(ValueError) as error:
                    validate_api_url(value)
                self.assertNotIn(value, str(error.exception))
                self.assertNotIn('fixture-private', str(error.exception))

    def test_helpers_reject_before_signing_platform_or_build_commands(self):
        root = Path(__file__).resolve().parents[1]
        value = 'https://user:fixture-private@api.example.invalid'
        for name in ['build_android_release.sh', 'build_ios_unsigned.sh']:
            with self.subTest(helper=name):
                result = subprocess.run(['bash', str(root / 'tools' / name)],
                                        env={**os.environ, 'MOBY_API_URL': value},
                                        capture_output=True, text=True)
                self.assertEqual(result.returncode, 2)
                self.assertIn('Invalid MOBY_API_URL', result.stderr)
                self.assertNotIn('fixture-private', result.stdout + result.stderr)
                self.assertNotIn('Commit source', result.stderr)
                self.assertNotIn('requires macOS', result.stderr)

    def test_release_staging_validates_config_before_package_access(self):
        with tempfile.TemporaryDirectory() as directory:
            missing_source = Path(directory) / 'missing-source'
            output = Path(directory) / 'output'
            with patch.object(prepare_mobile_release, 'validate_android') as android:
                with self.assertRaisesRegex(ValueError, 'Invalid MOBY_API_URL'):
                    prepare_mobile_release.prepare(missing_source, output, 'a' * 40,
                                                   'v1.5.1',
                                                   'https://api.example.invalid?private=fixture-private')
                android.assert_not_called()
            self.assertFalse(output.exists())

    def test_helpers_pass_optional_api_argument_on_system_bash(self):
        """The macOS runner uses /bin/bash 3.2; no SDK or signing is invoked."""
        root = Path(__file__).resolve().parents[1]
        shell = '/bin/bash' if Path('/bin/bash').exists() else 'bash'
        with tempfile.TemporaryDirectory(prefix='moby-build-argv-') as directory:
            scratch = Path(directory)
            for name, body in {
                'git': '#!/bin/sh\nexit 0\n',
                'uname': '#!/bin/sh\nprintf "Darwin\\n"\n',
                'xcodebuild': '#!/bin/sh\nexit 0\n',
                'flutter': (
                    f'#!{sys.executable}\n'
                    'import json,os,sys\n'
                    'from pathlib import Path\n'
                    'if sys.argv[1:3] == ["pub", "get"]: raise SystemExit(0)\n'
                    'if sys.argv[1:2] == ["build"]:\n'
                    ' Path(os.environ["MOBY_TEST_ARGV_FILE"]).write_text(json.dumps(sys.argv[1:]))\n'
                    ' raise SystemExit(42)\n'
                    'raise SystemExit(80)\n'
                ),
            }.items():
                executable = scratch / name
                executable.write_text(body)
                executable.chmod(0o755)
            for helper, expected in [
                ('build_android_release.sh', ['build', 'apk', '--release']),
                ('build_ios_unsigned.sh', ['build', 'ios', '--release', '--no-codesign']),
            ]:
                for api_url in ['', 'https://api.example.invalid:8443/']:
                    with self.subTest(helper=helper, api_url=api_url):
                        record = scratch / 'build-argv.json'
                        record.unlink(missing_ok=True)
                        environment = {
                            **os.environ,
                            'PATH': str(scratch) + os.pathsep + os.environ.get('PATH', ''),
                            'MOBY_FLUTTER_BIN': str(scratch / 'flutter'),
                            'MOBY_API_URL': api_url,
                            'MOBY_TEST_ARGV_FILE': str(record),
                            'MOBY_ANDROID_SIGNING_MODE': 'permanent',
                            'MOBY_ANDROID_STORE_FILE': str(scratch / 'unused-dummy-keystore'),
                            'MOBY_ANDROID_STORE_PASSWORD': 'test-fixture-only',
                            'MOBY_VERIFIED_TEST_COUNT': '1',
                        }
                        result = subprocess.run([shell, str(root / 'tools' / helper)],
                                                env=environment, capture_output=True, text=True)
                        self.assertEqual(result.returncode, 42, result.stderr)
                        arguments = expected + ([f'--dart-define=MOBY_API_URL={api_url}']
                                                if api_url else [])
                        self.assertEqual(json.loads(record.read_text()), arguments)


if __name__ == '__main__':
    unittest.main()
