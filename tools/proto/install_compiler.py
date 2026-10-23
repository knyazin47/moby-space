#!/usr/bin/env python3
"""Install only the pinned Linux x86_64 protoc in the ignored project .tools."""
import hashlib
import io
import json
from pathlib import Path
import platform
import urllib.request
import zipfile

root = Path(__file__).resolve().parents[2]
config = json.loads((root / 'tools/proto/versions.json').read_text())['protoc']
if platform.system() != 'Linux' or platform.machine() not in ('x86_64', 'AMD64'):
    raise SystemExit('This installer is pinned for Linux x86_64; use an independently verified compiler on other hosts.')
target = root / '.tools' / ('protoc-' + config['version'])
request = urllib.request.Request(config['linux_x86_64_url'], headers={'User-Agent': 'moby-protoc-installer'})
with urllib.request.urlopen(request, timeout=60) as response:
    archive = response.read(16 * 1024 * 1024 + 1)
if len(archive) > 16 * 1024 * 1024 or hashlib.sha256(archive).hexdigest() != config['sha256']:
    raise SystemExit('Compiler archive size/hash mismatch; no files installed.')
with zipfile.ZipFile(io.BytesIO(archive)) as files:
    if files.testzip() is not None:
        raise SystemExit('Compiler archive CRC mismatch.')
    for item in files.infolist():
        candidate = (target / item.filename).resolve()
        if not candidate.is_relative_to(target.resolve()):
            raise SystemExit('Unsafe archive path; no files installed.')
    files.extractall(target)
(target / 'bin/protoc').chmod(0o755)
print('Installed verified protoc ' + config['version'] + ' in project .tools.')
