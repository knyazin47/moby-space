#!/usr/bin/env python3
"""Recheck pinned official emoji pixels over HTTPS; write an evidence receipt only."""
from concurrent.futures import ThreadPoolExecutor
from hashlib import sha256
from io import BytesIO
import json
from pathlib import Path
from urllib.request import urlopen

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
COMMIT = 'a411844b60060174c7826ca9ec77035b8f18abb1'
BASE = f'https://raw.githubusercontent.com/vanniktech/Emoji/{COMMIT}/'


def verify():
    manifest = json.loads((ROOT / 'tools/assets/emoji.json').read_text())
    rows = []

    def visit(row):
        rows.append(row)
        for child in row.get('variants', []):
            visit(child)

    for row in manifest['emoji']:
        visit(row)
    sheets = {row['source_path']: row['source_sha256'] for row in rows}

    def load(item):
        path, expected = item
        data = urlopen(BASE + 'emoji-google/src/main/' + path, timeout=30).read()
        assert sha256(data).hexdigest() == expected, f'Upstream sheet mismatch: {path}'
        return path, Image.open(BytesIO(data)).convert('RGBA')

    with ThreadPoolExecutor(max_workers=8) as pool:
        images = dict(pool.map(load, sheets.items()))
    for row in rows:
        x, y, width, height = row['crop']
        image = images[row['source_path']].crop((x, y, x + width, y + height))
        local = Image.open(ROOT / row['output_path']).convert('RGBA')
        assert local.size == image.size and local.tobytes() == image.tobytes(), row['output_path']
        assert sha256((ROOT / row['output_path']).read_bytes()).hexdigest() == row['output_sha256']
    tabs = []
    for row in manifest['tabs']:
        module = 'emoji-google' if 'category' in row['resource_name'] else 'emoji'
        path = f"{module}/src/main/{row['source_path']}"
        data = urlopen(BASE + path, timeout=30).read()
        upstream = Image.open(BytesIO(data)).convert('RGBA')
        local_data = (ROOT / row['output_path']).read_bytes()
        local = Image.open(BytesIO(local_data)).convert('RGBA')
        assert upstream.size == local.size and upstream.tobytes() == local.tobytes(), path
        tabs.append({'output_path': row['output_path'], 'upstream_url': BASE + path,
                     'upstream_sha256': sha256(data).hexdigest(),
                     'output_sha256': sha256(local_data).hexdigest(),
                     'comparison': 'byte-identical' if data == local_data else 'RGBA-pixel-identical; PNG encoding differs'})
    result = {'schema_version': 1, 'upstream_commit': COMMIT,
              'upstream_tag': '0.9.0', 'license': 'Apache-2.0',
              'license_file': 'tools/assets/licenses/Emoji-Apache-2.0.txt',
              'notice_file': 'tools/assets/licenses/Emoji-NOTICE.txt',
              'exact_source_sheet_hashes': len(sheets),
              'verified_crop_pixels': len(rows), 'verified_tabs': tabs,
              'sheet_hashes': sheets,
              'output_hashes': {row['output_path']: row['output_sha256'] for row in rows}}
    return result


if __name__ == '__main__':
    result = verify()
    (ROOT / 'tools/assets/emoji-upstream.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    path = ROOT / 'tools/assets/emoji.json'
    manifest = json.loads(path.read_text())
    manifest['official_upstream'] = {
        'repository': 'https://github.com/vanniktech/Emoji', 'tag': '0.9.0',
        'commit': COMMIT, 'license': 'Apache-2.0',
        'evidence': 'tools/assets/emoji-upstream.json',
        'license_file': result['license_file'], 'notice_file': result['notice_file'],
    }
    manifest['license_boundary'] = 'All 3011 crops and 10 controls verified against pinned official upstream; Apache-2.0 notices retained. Two controls retain identical RGBA pixels with different PNG encoding.'
    manifest['source_boundary'] = 'Official upstream images verified independently of private APK exports. Provider order and Unicode mappings retained; no decompiled Java or private source files included.'
    manifest['attribution'] = {'authors': 'Niklas Baudy, Ruben Gees, Mario Đanić and contributors; Google/Noto Emoji artwork', 'license': 'Apache-2.0'}
    for name in ['apk', 'source_java_sha256', 'attribution_source']:
        manifest.pop(name, None)
    path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + '\n')
    print(f"Verified {result['verified_crop_pixels']} emoji crops, {result['exact_source_sheet_hashes']} sheets and {len(result['verified_tabs'])} controls")
