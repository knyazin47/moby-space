#!/usr/bin/env python3
"""Check one locally built release package without GitHub credentials or bank data."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import zipfile


def validate(manifest_path: Path, github_path: Path | None = None) -> dict:
    data = json.loads(manifest_path.read_text())
    assert re.fullmatch(r'\d+\.\d+\.\d+(?:-rc\.\d+)?\+\d+', data['version']), 'Invalid version'
    assert re.fullmatch(r'[0-9a-f]{40}', data['source_commit']), 'Missing exact source commit'
    assert data['application_id'] == 'dev.knyazin47.moby', 'Unexpected application ID'
    assert data['physical_device_verified'] is False, 'Physical verification requires a separate evidence contract'
    assert data['unit_widget_asset_tests'] > 0 and data['flutter_analyze'] == 'passed'
    assert data['signature_verify'] == 'passed'
    base = manifest_path.name.removesuffix('.manifest.json')
    apk = manifest_path.with_name(base + '.apk')
    checksum = manifest_path.with_name(base + '.sha256')
    actual = hashlib.sha256(apk.read_bytes()).hexdigest()
    assert actual == data['sha256'], 'Manifest checksum mismatch'
    assert apk.stat().st_size == data['bytes'], 'Manifest byte count mismatch'
    assert checksum.read_text().strip() == f'{actual}  {apk.name}', 'Checksum file mismatch'
    with zipfile.ZipFile(apk) as bundle:
        names = set(bundle.namelist())
        assert {'AndroidManifest.xml', 'classes.dex'} <= names, 'APK components missing'
        for abi in data['abis']:
            assert f'lib/{abi}/libapp.so' in names, f'Missing Flutter app ABI {abi}'
            assert f'lib/{abi}/libflutter.so' in names, f'Missing Flutter runtime ABI {abi}'
    if github_path is not None:
        release = json.loads(github_path.read_text())
        version = data['version'].split('+')[0]
        assert release['tag_name'] == f'v{version}', 'GitHub tag mismatch'
        assert release['target_commitish'] == data['source_commit'], 'GitHub source commit mismatch'
        if data.get('release_status') == 'stable_demo':
            assert release['prerelease'] is False and release['draft'] is False, 'Stable release flag mismatch'
        assets = {asset['name']: asset for asset in release['assets']}
        for path in (apk, checksum, manifest_path):
            remote = assets[path.name]
            assert remote['state'] == 'uploaded', f'Incomplete GitHub upload: {path.name}'
            assert remote['size'] == path.stat().st_size, f'GitHub byte mismatch: {path.name}'
            digest = 'sha256:' + hashlib.sha256(path.read_bytes()).hexdigest()
            assert remote['digest'] == digest, f'GitHub digest mismatch: {path.name}'
    return {'version': data['version'], 'source_commit': data['source_commit'], 'sha256': actual,
            'bytes': data['bytes'], 'artifact_contract': 'passed',
            'physical_device_verified': data['physical_device_verified'],
            'github_artifacts': 'passed' if github_path is not None else 'not_checked'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('manifest', type=Path)
    parser.add_argument('--github-release-json', type=Path, help='Saved gh api release response; no credentials required by this script')
    args = parser.parse_args()
    try:
        print(json.dumps(validate(args.manifest, args.github_release_json), ensure_ascii=False, indent=2))
    except (AssertionError, KeyError, ValueError, OSError, zipfile.BadZipFile) as error:
        parser.exit(1, f'Artifact check failed: {error}\n')
