#!/usr/bin/env python3
"""Validate application and README assets; --public rejects unresolved rights."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import sys

from lib.asset_support import validate_native_icons
from assets.generate_emoji_catalog import render as render_emoji_catalog

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'tools/assets'
MEDIA_SUFFIXES = {'.png', '.webp', '.jpg', '.jpeg', '.gif', '.svg', '.ttf', '.otf'}
README_IMAGE_SUFFIXES = (MEDIA_SUFFIXES - {'.ttf', '.otf'}) | {
    '.avif', '.apng', '.bmp', '.ico', '.tif', '.tiff', '.heic', '.heif',
}


def validate_readme_assets(root=ROOT):
    """Check local README media; publication decisions come from the owner manifest."""
    manifest_path = root / 'tools/assets/readme.json'
    manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else {
        'schema_version': 1, 'files': [],
    }
    if (not isinstance(manifest, dict) or manifest.get('schema_version') != 1
            or not isinstance(manifest.get('files'), list)):
        raise ValueError('Unsupported README asset manifest schema')
    media_root = root / 'docs/assets'
    if media_root.is_symlink() or not media_root.resolve().is_relative_to(root.resolve()):
        raise ValueError('README media directory escapes repository or uses a symlink')
    checked, counts, pending = set(), Counter(), Counter()
    for row in manifest['files']:
        if not isinstance(row, dict):
            raise ValueError('README asset entries must be objects')
        name = row.get('path', '')
        if (not isinstance(name, str) or not name.startswith('docs/assets/')
                or '\\' in name or Path(name).as_posix() != name or '..' in Path(name).parts
                or Path(name).suffix.lower() not in README_IMAGE_SUFFIXES):
            raise ValueError('README asset must name a local image under docs/assets')
        path = root / name
        if path.is_symlink() or not path.resolve().is_relative_to(media_root.resolve()):
            raise ValueError('README asset path escapes docs/assets or uses a symlink')
        if path.resolve() in checked:
            raise ValueError(f'Duplicate README asset: {name}')
        if row.get('group') not in {'team_photo', 'project_screenshot'}:
            raise ValueError(f'Invalid README asset group: {name}')
        if row.get('public_distribution') not in {'eligible', 'manual_review_required'}:
            raise ValueError(f'Missing README publication decision: {name}')
        if not isinstance(row.get('rights_basis'), str) or not row['rights_basis'].strip():
            raise ValueError(f'Missing README rights basis: {name}')
        expected = row.get('sha256', '')
        if not isinstance(expected, str) or not re.fullmatch(r'[0-9a-f]{64}', expected):
            raise ValueError(f'Missing or invalid README asset SHA-256: {name}')
        if hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            raise ValueError(f'README asset hash mismatch: {name}')
        checked.add(path.resolve())
        counts[row['group']] += 1
        if row['public_distribution'] != 'eligible':
            pending[row['group']] += 1
    inventory = {
        path.resolve() for path in media_root.rglob('*')
        if path.is_file() and path.suffix.lower() in README_IMAGE_SUFFIXES
    }
    unlisted = sorted(str(path.relative_to(root)) for path in inventory - checked)
    if unlisted:
        raise ValueError('Unlisted README image assets: ' + ', '.join(unlisted))
    return {'checked_files': checked, 'inventory': inventory, 'counts': counts, 'pending': pending}


def read(name):
    return json.loads((ASSETS / name).read_text())


def checked_path(name):
    path = (ROOT / name).resolve()
    if not path.is_relative_to(ROOT):
        raise ValueError(f'Asset path escapes repository: {name}')
    return path


def check_hash(name, expected):
    if hashlib.sha256(checked_path(name).read_bytes()).hexdigest() != expected:
        raise ValueError(f'Asset hash mismatch: {name}')


def emoji_rows(manifest):
    def visit(row):
        yield row
        for child in row.get('variants', []):
            yield from visit(child)
    for row in manifest['emoji']:
        yield from visit(row)
    yield from manifest['tabs']


def validate(public=False):
    reference, promo, emoji = (read(name + '.json') for name in ['reference', 'promo', 'emoji'])
    launcher, ios, runtime = (read(name + '.json') for name in ['launcher', 'ios-icons', 'runtime'])
    pending = Counter()
    count = Counter()
    checked_files = set()

    def record_hash(name, expected):
        check_hash(name, expected)
        checked_files.add(checked_path(name))

    for row in reference['assets']:
        record_hash(row['output_path'], row['output_sha256'])
        count['reference'] += 1
        if row.get('public_distribution') == 'eligible' and row.get('license') == 'OFL-1.1':
            checked_path(row['license_file']).read_bytes()
        else:
            pending['unapproved_reference_assets'] += 1
    for row in promo['assets']:
        record_hash(row['output'], row['sha256'])
        count['promo'] += 1
        pending['unapproved_promo_assets'] += 1
    for row in emoji_rows(emoji):
        record_hash(row['output_path'], row['output_sha256'])
        count['emoji'] += 1
    if (ROOT / 'frontend/lib/core/config/source_emoji_catalog.dart').read_bytes() != render_emoji_catalog(emoji):
        raise ValueError('Typed emoji catalog differs from public JSON metadata; regenerate it')
    evidence = read('emoji-upstream.json')
    if (evidence['verified_crop_pixels'] != len(list(emoji_rows(emoji))) - 10
            or evidence['exact_source_sheet_hashes'] != 56
            or len(evidence['verified_tabs']) != 10
            or evidence['upstream_commit'] != emoji['official_upstream']['commit']):
        raise ValueError('Emoji upstream receipt does not cover runtime catalog')
    for name in ['license_file', 'notice_file']:
        checked_path(evidence[name]).read_bytes()
    sheet_hashes = {row['source_path']: row['source_sha256'] for row in emoji_rows(emoji) if 'sheet' in row}
    if sheet_hashes != evidence['sheet_hashes']:
        raise ValueError('Emoji source sheets differ from verified upstream')
    output_hashes = {row['output_path']: row['output_sha256'] for row in emoji_rows(emoji) if 'sheet' in row}
    if output_hashes != evidence['output_hashes']:
        raise ValueError('Emoji output hashes differ from verified upstream')
    by_path = {row['output_path']: row for row in emoji['tabs']}
    for row in evidence['verified_tabs']:
        if row['output_sha256'] != by_path[row['output_path']]['output_sha256']:
            raise ValueError('Emoji control differs from upstream receipt')
    for row in launcher['assets']:
        record_hash(row['output_path'], row['output_sha256'])
        count['android_launcher'] += 1
        if row.get('public_distribution') != 'eligible' or row.get('license') != 'Apache-2.0':
            pending['unapproved_android_launcher'] += 1
    validate_native_icons(ROOT)
    record_hash(ios['source_path'], ios['source_sha256'])
    count['native_stock_source'] += 1
    icon_root = ROOT / 'frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset'
    for row in ios['outputs']:
        record_hash('frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/' + row['filename'], row['sha256'])
        count['ios_launcher'] += 1
        if ios.get('public_distribution') != 'eligible' or ios.get('license') != 'Apache-2.0':
            pending['unapproved_ios_launcher'] += 1
    for row in runtime['files']:
        record_hash(row['path'], row['sha256'])
        count['runtime_art_fonts'] += 1
        if row['public_distribution'] != 'eligible':
            pending[row['group']] += 1
        if 'license_file' in row:
            checked_path(row['license_file']).read_bytes()
    readme = validate_readme_assets(ROOT)
    checked_files.update(readme['checked_files'])
    count.update(readme['counts'])
    pending.update(readme['pending'])
    # Reverse inventory covers all platform media, including unbound resources:
    # adding a new filename must not bypass provenance or publication eligibility.
    inventory = {
        checked_path(path.relative_to(ROOT))
        for path in (ROOT / 'frontend/assets').rglob('*')
        if path.is_file() and path.suffix.lower() in MEDIA_SUFFIXES
    }
    android_res = ROOT / 'frontend/android/app/src/main/res'
    inventory.update(
        checked_path(path.relative_to(ROOT))
        for path in android_res.rglob('*')
        if path.is_file() and (path.suffix.lower() in MEDIA_SUFFIXES
                              or (path.parent.name.startswith('mipmap-') and path.suffix.lower() == '.xml'))
    )
    inventory.update(
        checked_path(path.relative_to(ROOT))
        for path in (ROOT / 'frontend/ios/Runner/Assets.xcassets').rglob('*')
        if path.is_file() and path.suffix.lower() in MEDIA_SUFFIXES
    )
    inventory.update(readme['inventory'])
    unlisted = sorted(str(path.relative_to(ROOT)) for path in inventory - checked_files)
    if unlisted:
        raise ValueError('Unlisted image/font assets: ' + ', '.join(unlisted))
    result = {'hashes_valid': len(checked_files), 'groups': dict(count),
              'inventory_media_files': len(inventory),
              'public_eligible': not pending, 'public_unresolved': dict(pending),
              'boundary': 'Asset provenance/license gate only. Project attribution, contest rights and trademark context remain separate publication decisions.'}
    if public and pending:
        result['status'] = 'PUBLICATION_BLOCKED'
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--public', action='store_true')
    args = parser.parse_args()
    try:
        result = validate(args.public)
    except (ValueError, OSError, KeyError, AssertionError) as error:
        print(f'Asset validation failed: {error}', file=sys.stderr)
        return 1
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 2 if args.public and result['public_unresolved'] else 0


if __name__ == '__main__':
    sys.exit(main())
