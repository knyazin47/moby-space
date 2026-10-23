#!/usr/bin/env python3
"""Regression checks for the source publication boundary."""
from pathlib import Path
import subprocess
import tempfile
import unittest

from check_repository import ROOT, validate


RUNTIME_PATHS = (
    'owner.pfx',
    'family.db',
    'family.sqlite',
    'family.sqlite3',
    'family.db-wal',
    'family.db-shm',
    'family.sqlite-wal',
    'family.sqlite-shm',
    'family.sqlite3-journal',
    'nested/family.sqlite3-wal',
    'nested/family.sqlite3-shm',
)


class PublicationBoundaryTest(unittest.TestCase):
    def test_runtime_files_cannot_enter_the_source_snapshot(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name in RUNTIME_PATHS:
                with self.subTest(name=name):
                    path = root / name
                    path.parent.mkdir(parents=True, exist_ok=True)
                    path.write_text('synthetic boundary fixture\n')
                    errors = validate(root, [name])
                    self.assertEqual(errors, [f'{name}: runtime/private path'])

    def test_runtime_paths_are_ignored_even_outside_backend_data(self):
        result = subprocess.run(
            ['git', 'check-ignore', '--no-index', '--stdin'],
            input='\n'.join(RUNTIME_PATHS) + '\n',
            capture_output=True, text=True, cwd=ROOT, check=False,
        )
        self.assertIn(result.returncode, (0, 1), result.stderr)
        self.assertEqual(set(result.stdout.splitlines()), set(RUNTIME_PATHS))

    def test_public_examples_and_schema_remain_allowed(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            paths = ['.env.example', 'schema.sql', 'docs/setup.md']
            for name in paths:
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text('synthetic public fixture\n')
            self.assertEqual(validate(root, paths), [])


if __name__ == '__main__':
    unittest.main()
