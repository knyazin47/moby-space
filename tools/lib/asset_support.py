"""Standard-library checks for native stock-icon packaging and asset gates."""
import hashlib
import json
from pathlib import Path
import struct
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
ANDROID_RES = Path('frontend/android/app/src/main/res')
IOS_CATALOG = Path('frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset')
DENSITIES = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
APPLICATION = {'label': 'Moby Space', 'icon': '@mipmap/ic_launcher_logo',
               'roundIcon': '@mipmap/ic_launcher_logo_round'}
ANDROID = '{http://schemas.android.com/apk/res/android}'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def dimensions(data):
    if data[:8] != b'\x89PNG\r\n\x1a\n' or data[12:16] != b'IHDR':
        raise ValueError('Expected a PNG image')
    return struct.unpack('>II', data[16:24])


def ios_slots(root=ROOT):
    slots = json.loads((root / IOS_CATALOG / 'Contents.json').read_text())['images']
    result = {}
    for row in slots:
        filename = row['filename']
        if Path(filename).name != filename or not filename.endswith('.png'):
            raise ValueError('Invalid iOS app icon filename')
        size = round(float(row['size'].split('x')[0]) * float(row['scale'][:-1]))
        if filename in result and result[filename] != size:
            raise ValueError('Conflicting iOS app icon sizes')
        result[filename] = size
    return result


def validate_native_icons(root=ROOT):
    source = json.loads((root / 'tools/assets/material/source.json').read_text())
    for name, expected_hash in [(source['source_path'], source['source_sha256']),
                                (source['license_file'], source['license_sha256'])]:
        if digest((root / name).read_bytes()) != expected_hash:
            raise ValueError(f'Stock icon source/license hash mismatch: {name}')
    (root / source['notice_file']).read_bytes()
    launcher = json.loads((root / 'tools/assets/launcher.json').read_text())
    if launcher['source_path'] != source['source_path'] or launcher['source_sha256'] != source['source_sha256']:
        raise ValueError('Native launcher is not bound to the pinned stock SVG')
    app = ET.parse(root / 'frontend/android/app/src/main/AndroidManifest.xml').getroot().find('application')
    if app is None or {name: app.get(ANDROID + name) for name in APPLICATION} != APPLICATION:
        raise ValueError('Android launcher application bindings changed')
    expected = {}
    for density, size in DENSITIES.items():
        for name in ['ic_launcher_logo', 'ic_launcher_logo_round', 'ic_launcher_logo_foreground']:
            expected[str(ANDROID_RES / f'mipmap-{density}/{name}.png')] = size * 9 // 4 if name.endswith('foreground') else size
    expected.update({str(ANDROID_RES / f'mipmap-anydpi/{name}.xml'): None for name in ['ic_launcher_logo', 'ic_launcher_logo_round']})
    expected[str(ANDROID_RES / 'values/launcher_colors.xml')] = None
    if set(expected) != {row['output_path'] for row in launcher['assets']}:
        raise ValueError('Android stock icon manifest does not cover the exact launcher allowlist')
    for row in launcher['assets']:
        name = row['output_path']
        data = (root / name).read_bytes()
        if digest(data) != row['output_sha256']:
            raise ValueError(f'Android stock icon hash mismatch: {name}')
        if expected[name] is not None:
            if dimensions(data) != (expected[name],) * 2:
                raise ValueError(f'Android stock icon size mismatch: {name}')
        elif '/mipmap-anydpi/' in name:
            tree = ET.fromstring(data)
            if tree.tag != 'adaptive-icon' or [(child.tag, child.attrib) for child in tree] != [
                    ('background', {ANDROID + 'drawable': '@color/ic_launcher_logo_background'}),
                    ('foreground', {ANDROID + 'drawable': '@mipmap/ic_launcher_logo_foreground'})]:
                raise ValueError('Android adaptive icon bindings changed')
        else:
            color = ET.fromstring(data).find("color[@name='ic_launcher_logo_background']")
            if color is None or color.text != '#ffffff':
                raise ValueError('Android adaptive icon white background changed')
    ios = json.loads((root / 'tools/assets/ios-icons.json').read_text())
    if ios['source_path'] != source['source_path'] or ios['source_sha256'] != source['source_sha256']:
        raise ValueError('iOS icons are not bound to the pinned stock SVG')
    slots = ios_slots(root)
    if set(slots) != {row['filename'] for row in ios['outputs']}:
        raise ValueError('iOS icon manifest does not cover catalog slots')
    for row in ios['outputs']:
        data = (root / IOS_CATALOG / row['filename']).read_bytes()
        if digest(data) != row['sha256'] or dimensions(data) != (slots[row['filename']],) * 2 or data[25] != 2:
            raise ValueError(f"iOS stock icon hash/size/opaque RGB mismatch: {row['filename']}")
    return {'android_resources': len(expected), 'ios_images': len(slots)}
