#!/usr/bin/env python3
"""Export the pinned official stock SVG to native launcher sizes, or --check."""
import argparse
from io import BytesIO
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from lib.asset_support import (ANDROID_RES, APPLICATION, DENSITIES, IOS_CATALOG,
                               ROOT, digest, ios_slots, validate_native_icons)


def generate():
    # Optional local packaging dependencies; normal checks use stdlib only.
    import cairosvg
    from PIL import Image, __version__ as pillow_version

    source = json.loads((ROOT / 'tools/assets/material/source.json').read_text())
    svg = (ROOT / source['source_path']).read_bytes()
    if digest(svg) != source['source_sha256']:
        raise ValueError('Pinned official stock SVG changed')

    def raster(size, *, foreground=False):
        if foreground:
            icon_size = size * 4 // 9
            png = cairosvg.svg2png(bytestring=svg, output_width=icon_size, output_height=icon_size)
            image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
            image.alpha_composite(Image.open(BytesIO(png)).convert('RGBA'), ((size - icon_size) // 2,) * 2)
        else:
            png = cairosvg.svg2png(bytestring=svg, output_width=size, output_height=size, background_color='white')
            image = Image.open(BytesIO(png)).convert('RGB')
        output = BytesIO()
        image.save(output, format='PNG', compress_level=9)
        return output.getvalue()

    rows = []

    def write(relative, data):
        path = ROOT / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
        rows.append({'output_path': str(relative), 'output_sha256': digest(data),
                     'license': 'Apache-2.0', 'public_distribution': 'eligible'})

    for density, size in DENSITIES.items():
        for name in ['ic_launcher_logo', 'ic_launcher_logo_round', 'ic_launcher_logo_foreground']:
            foreground = name.endswith('foreground')
            export_size = size * 9 // 4 if foreground else size
            write(ANDROID_RES / f'mipmap-{density}/{name}.png', raster(export_size, foreground=foreground))
    adaptive = b'''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_logo_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_logo_foreground"/>
</adaptive-icon>
'''
    for name in ['ic_launcher_logo', 'ic_launcher_logo_round']:
        write(ANDROID_RES / f'mipmap-anydpi/{name}.xml', adaptive)
    write(ANDROID_RES / 'values/launcher_colors.xml', b'''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_logo_background">#ffffff</color>
</resources>
''')
    shared = {'schema_version': 2, 'source_path': source['source_path'],
              'source_sha256': source['source_sha256'], 'license': 'Apache-2.0',
              'license_file': source['license_file'], 'notice_file': source['notice_file'],
              'public_distribution': 'eligible', 'renderer': f'CairoSVG {cairosvg.__version__}; Pillow {pillow_version}',
              'transformation': 'Unchanged official stock SVG rasterized at each native size. White complete icon canvas; centered transparent Android adaptive foreground padding.'}
    (ROOT / 'tools/assets/launcher.json').write_text(json.dumps({**shared, 'application': APPLICATION, 'assets': rows}, indent=2) + '\n')
    ios = []
    for filename, size in sorted(ios_slots().items()):
        data = raster(size)
        (ROOT / IOS_CATALOG / filename).write_bytes(data)
        ios.append({'filename': filename, 'size_px': size, 'sha256': digest(data), 'upscaled': False})
    (ROOT / 'tools/assets/ios-icons.json').write_text(json.dumps({**shared, 'outputs': ios}, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    if not args.check:
        generate()
    print(json.dumps(validate_native_icons(), indent=2))


if __name__ == '__main__':
    main()
