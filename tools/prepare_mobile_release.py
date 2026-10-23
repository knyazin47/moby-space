#!/usr/bin/env python3
"""Validate both platform packages and flatten downloaded Actions artifacts."""
import argparse
import json
from pathlib import Path
import shutil

from check_ios_artifacts import validate as validate_ios
from check_release_artifacts import validate as validate_android
from lib.build_config import validate_api_url


def prepare(source: Path, output: Path, commit: str, tag: str, api_url: str):
    validate_api_url(api_url)
    manifests = sorted(source.rglob('*.manifest.json'))
    assert len(manifests) == 2, 'Exactly one Android and one iOS manifest required'
    assert not output.exists(), 'Use a new staging directory'
    packages = [json.loads(path.read_text()) for path in manifests]
    assert {data.get('platform', 'android') for data in packages} == {'android', 'ios-device'}
    assert len({data['version'] for data in packages}) == 1, 'Platform build versions differ'
    files = []
    for manifest, data in zip(manifests, packages):
        assert data['source_commit'] == commit, 'Package source differs from release source'
        assert 'v' + data['version'].split('+')[0] == tag, 'Release version mismatch'
        assert data['api_url'] == api_url, 'Release API mismatch'
        assert data['build_mode'] == ('network' if api_url else 'replica'), 'Release mode mismatch'
        if data.get('platform') == 'ios-device':
            validate_ios(manifest)
            artifact = manifest.parent / data['artifact']
        else:
            validate_android(manifest)
            mode = data['signing_mode']
            assert mode in {'permanent', 'ephemeral'}, 'Unknown Android signing mode'
            if mode == 'permanent':
                pin = json.loads((Path(__file__).resolve().parents[1] / 'tools/release/android-signing.json').read_text())['certificate_sha256']
                assert data['signing_certificate_sha256'] == pin, 'Permanent Android signing pin mismatch'
            else:
                assert data['signing_compatibility'] == 'disposable identity; no update compatibility with other builds', 'Ephemeral signing must state its update limitation'
            artifact = manifest.with_name(manifest.name.removesuffix('.manifest.json') + '.apk')
        files.extend([manifest, artifact, artifact.with_suffix('.sha256')])
    assert len({path.name for path in files}) == 6, 'Duplicate release filename'
    assert {path.resolve() for path in source.rglob('*') if path.is_file()} == {path.resolve() for path in files}, 'Unexpected files in release artifacts'
    assert not any(path.is_symlink() for path in source.rglob('*')), 'Symlinks are not release assets'
    output.mkdir(parents=True)
    for path in files:
        shutil.copyfile(path, output / path.name)
    print(f'Validated and staged {len(files)} release files for {tag} at {commit}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--commit', required=True)
    parser.add_argument('--tag', required=True)
    parser.add_argument('--api-url', required=True)
    args = parser.parse_args()
    prepare(args.source, args.output, args.commit, args.tag, args.api_url)
