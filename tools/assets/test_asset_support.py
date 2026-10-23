#!/usr/bin/env python3
"""Focused stock-icon integrity checks with synthetic metadata fixtures."""
import json
from pathlib import Path
import struct
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from lib.asset_support import ROOT, digest, dimensions, ios_slots, validate_native_icons
from generate_emoji_catalog import render
from check_assets import validate_readme_assets
from check_repository import validate as validate_repository


class AssetSupportTest(unittest.TestCase):
    def test_readme_inventory_rejects_unlisted_image(self):
        with tempfile.TemporaryDirectory(prefix='moby-readme-media-') as temporary:
            root = Path(temporary)
            photo = root / 'docs/assets/team/fixture.jpg'
            photo.parent.mkdir(parents=True)
            photo.write_bytes(b'synthetic-photo-fixture')
            with self.assertRaisesRegex(ValueError, 'Unlisted README image'):
                validate_readme_assets(root)

    def test_readme_requires_hash_and_tracks_publication_decisions(self):
        with tempfile.TemporaryDirectory(prefix='moby-readme-media-') as temporary:
            root = Path(temporary)
            photo = root / 'docs/assets/team/fixture.jpg'
            photo.parent.mkdir(parents=True)
            photo.write_bytes(b'synthetic-photo-fixture')
            manifest = root / 'tools/assets/readme.json'
            manifest.parent.mkdir(parents=True)
            row = {'path': 'docs/assets/team/fixture.jpg', 'group': 'team_photo',
                   'public_distribution': 'manual_review_required',
                   'rights_basis': 'Synthetic test fixture; owner decision pending'}
            def save():
                manifest.write_text(json.dumps({'schema_version': 1, 'files': [row]}))
            save()
            with self.assertRaisesRegex(ValueError, 'Missing or invalid README asset SHA-256'):
                validate_readme_assets(root)
            row['sha256'] = '0' * 64
            save()
            with self.assertRaisesRegex(ValueError, 'README asset hash mismatch'):
                validate_readme_assets(root)
            row['sha256'] = digest(photo.read_bytes())
            save()
            result = validate_readme_assets(root)
            self.assertEqual(result['pending'], {'team_photo': 1})
            self.assertEqual(result['counts'], {'team_photo': 1})
            row['public_distribution'] = 'eligible'
            save()
            self.assertFalse(validate_readme_assets(root)['pending'])

    def test_repository_checks_picture_and_html_image_paths(self):
        with tempfile.TemporaryDirectory(prefix='moby-readme-links-') as temporary:
            root = Path(temporary)
            (root / 'README.md').write_text(
                '<picture><source srcset="docs/assets/dark.png 1x, docs/assets/dark2.png 2x">'
                '<img src="docs/assets/light.png" alt="Fixture"></picture>'
                '<img src="https://example.invalid/logo.svg">'
                '<source srcset="https://skillicons.dev/icons?i=flutter,dart&amp;theme=dark">')
            errors = validate_repository(root, ['README.md'])
            self.assertEqual(len(errors), 3)
            self.assertTrue(all('missing local link docs/assets/' in error for error in errors))

    def test_public_catalog_no_drift(self):
        manifest = json.loads((ROOT / 'tools/assets/emoji.json').read_text())
        output = ROOT / 'frontend/lib/core/config/source_emoji_catalog.dart'
        self.assertEqual(render(manifest), output.read_bytes())

    def test_catalog_rejects_injected_category(self):
        manifest = {'categories': [{'id': "x'); injected()", 'imported_base_count': 0}], 'emoji': []}
        with self.assertRaisesRegex(ValueError, 'Invalid Dart'):
            render(manifest)

    def test_catalog_rejects_missing_order_index(self):
        manifest = {'categories': [{'id': 'sample', 'imported_base_count': 1}],
                    'emoji': [{'category': 'sample', 'category_index': 1}]}
        with self.assertRaisesRegex(ValueError, 'count/order is incomplete'):
            render(manifest)

    def test_committed_native_outputs(self):
        self.assertEqual(validate_native_icons(), {'android_resources': 18, 'ios_images': 15})

    def test_png_header_and_dimensions(self):
        header = b'\x89PNG\r\n\x1a\n' + struct.pack('>I', 13) + b'IHDR' + struct.pack('>II', 48, 48)
        self.assertEqual(dimensions(header), (48, 48))
        with self.assertRaisesRegex(ValueError, 'Expected a PNG'):
            dimensions(b'<svg/>')

    def test_ios_slot_paths_and_conflicts(self):
        with tempfile.TemporaryDirectory(prefix='moby-synthetic-icon-') as temporary:
            root = Path(temporary)
            catalog = root / 'frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset'
            catalog.mkdir(parents=True)
            path = catalog / 'Contents.json'
            path.write_text(json.dumps({'images': [{'filename': '../escape.png', 'size': '20x20', 'scale': '1x'}]}))
            with self.assertRaisesRegex(ValueError, 'Invalid iOS'):
                ios_slots(root)
            path.write_text(json.dumps({'images': [
                {'filename': 'same.png', 'size': '20x20', 'scale': '1x'},
                {'filename': 'same.png', 'size': '20x20', 'scale': '2x'},
            ]}))
            with self.assertRaisesRegex(ValueError, 'Conflicting iOS'):
                ios_slots(root)

    def test_launcher_binding_rejects_other_artwork(self):
        with tempfile.TemporaryDirectory(prefix='moby-synthetic-icon-') as temporary:
            root = Path(temporary)
            assets = root / 'tools/assets'
            (assets / 'material').mkdir(parents=True)
            source = {'source_path': 'tools/assets/material/icon.svg', 'source_sha256': digest(b'<svg/>'),
                      'license_file': 'tools/assets/license.txt', 'license_sha256': digest(b'license'),
                      'notice_file': 'tools/assets/notice.txt'}
            (assets / 'material/icon.svg').write_bytes(b'<svg/>')
            (assets / 'license.txt').write_bytes(b'license')
            (assets / 'notice.txt').write_bytes(b'notice')
            (assets / 'material/source.json').write_text(json.dumps(source))
            (assets / 'launcher.json').write_text(json.dumps(source))
            manifest = root / 'frontend/android/app/src/main/AndroidManifest.xml'
            manifest.parent.mkdir(parents=True)
            manifest.write_text('<manifest xmlns:android="http://schemas.android.com/apk/res/android"><application android:label="Moby Space" android:icon="@mipmap/other" android:roundIcon="@mipmap/ic_launcher_logo_round"/></manifest>')
            with self.assertRaisesRegex(ValueError, 'application bindings changed'):
                validate_native_icons(root)


if __name__ == '__main__':
    unittest.main()
