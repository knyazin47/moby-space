#!/usr/bin/env python3
"""Check an unsigned physical-device IPA; a simulator bundle is rejected."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import plistlib
import re
import struct
import zipfile


def device_macho(data):
    assert len(data) >= 32, 'Truncated Mach-O'
    magic, cpu, _, filetype, count, command_bytes, _, _ = struct.unpack_from('<8I', data)
    assert magic == 0xFEEDFACF and cpu == 0x0100000C and filetype == 2, 'Expected arm64 Mach-O executable'
    assert command_bytes <= len(data) - 32 and count <= command_bytes // 8
    offset = 32
    platforms = []
    for _ in range(count):
        command, size = struct.unpack_from('<II', data, offset)
        assert size >= 8 and offset + size <= 32 + command_bytes, 'Invalid load command'
        if command == 0x32:  # LC_BUILD_VERSION; arm64 simulators also use arm64 CPU.
            assert size >= 24
            platforms.append(struct.unpack_from('<I', data, offset + 8)[0])
        offset += size
    assert offset == 32 + command_bytes and platforms == [2], 'Expected iOS device platform, not simulator'


def validate(manifest_path):
    data = json.loads(manifest_path.read_text())
    assert data['platform'] == 'ios-device' and data['signed'] is False
    assert data['bundle_id'] == 'dev.knyazin47.moby' and data['display_name'] == 'Moby Space'
    assert re.fullmatch(r'[0-9a-f]{40}', data['source_commit'])
    assert re.fullmatch(r'\d+\.\d+\.\d+\+\d+', data['version'])
    assert Path(data['artifact']).name == data['artifact']
    ipa = manifest_path.parent / data['artifact']
    assert ipa.stat().st_size == data['bytes']
    digest = hashlib.sha256(ipa.read_bytes()).hexdigest()
    assert digest == data['sha256'], 'IPA hash mismatch'
    assert ipa.with_suffix('.sha256').read_text().strip() == f'{digest}  {ipa.name}'
    with zipfile.ZipFile(ipa) as archive:
        names = archive.namelist()
        assert len(names) == len(set(names)), 'Duplicate ZIP entries'
        assert all(not PurePosixPath(name).is_absolute() and '..' not in PurePosixPath(name).parts
                   and name.startswith('Payload/Runner.app/') for name in names), 'Unexpected IPA path'
        root = 'Payload/Runner.app/'
        info = plistlib.loads(archive.read(root + 'Info.plist'))
        assert info['CFBundleIdentifier'] == data['bundle_id']
        assert info['CFBundleDisplayName'] == data['display_name']
        version, build = data['version'].split('+')
        assert info['CFBundleShortVersionString'] == version and info['CFBundleVersion'] == build
        assert info.get('UIUserInterfaceStyle') == 'Light'
        assert info.get('CFBundleSupportedPlatforms') == ['iPhoneOS']
        assert info.get('MinimumOSVersion') == data['minimum_os'] == '15.0', 'Unexpected minimum iOS'
        executable = info['CFBundleExecutable']
        assert PurePosixPath(executable).name == executable
        binary = archive.getinfo(root + executable)
        assert (binary.external_attr >> 16) & 0o111, 'Executable permission missing'
        device_macho(archive.read(binary))
        for name in ['Frameworks/Flutter.framework/Flutter', 'Frameworks/App.framework/App']:
            assert root + name in names, f'Missing {name}'
        assert not any(name.endswith('embedded.mobileprovision') for name in names), 'Unexpected provisioning profile'
        # Prebuilt Flutter frameworks can retain vendor/ad-hoc seals. The
        # device package still requires personal re-signing; no profile ships.
    return {'platform': 'ios-device', 'version': data['version'], 'sha256': digest,
            'source_commit': data['source_commit'], 'signed': False,
            'artifact_contract': 'passed', 'requires_personal_resigning': True,
            'physical_device_verified': False}


def self_test():
    # A real compile is separate. These fixtures prove the arm64 simulator
    # rejection and malformed-command bounds which ZIP/hash checks cannot prove.
    header = struct.pack('<8I', 0xFEEDFACF, 0x0100000C, 0, 2, 1, 24, 0, 0)
    device = header + struct.pack('<6I', 0x32, 24, 2, 0, 0, 0)
    device_macho(device)
    for bad in [header + struct.pack('<6I', 0x32, 24, 7, 0, 0, 0),
                header + struct.pack('<6I', 0x32, 0, 2, 0, 0, 0), device[:35]]:
        try:
            device_macho(bad)
        except (AssertionError, struct.error):
            pass
        else:
            raise AssertionError('Invalid/simulator fixture accepted')
    print('iOS Mach-O parser: device accepted; arm64 simulator/truncation/bounds rejected')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('manifest', nargs='?', type=Path)
    parser.add_argument('--self-test', action='store_true')
    args = parser.parse_args()
    try:
        if args.self_test:
            self_test()
        elif args.manifest:
            print(json.dumps(validate(args.manifest), indent=2))
        else:
            parser.error('Provide manifest or --self-test')
    except (AssertionError, KeyError, ValueError, OSError, struct.error, zipfile.BadZipFile) as error:
        parser.exit(1, f'iOS artifact check failed: {error}\n')
