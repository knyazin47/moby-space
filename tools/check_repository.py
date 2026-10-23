#!/usr/bin/env python3
"""Check source layout, local documentation links and optional public assets."""
from __future__ import annotations

import argparse
from html.parser import HTMLParser
from pathlib import Path
import re
import subprocess
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
REMOVED = (
    "docs/pitch/", "docs/reverse/", "docs/legal/", "docs/privacy/",
    "presentation/", "design/", "tools/pitch/", "tools/android-collector/",
    "tools/windows/", "tools/ci/", "deploy/tls/", "deploy/systemd/", "deploy/nginx/",
)
SENSITIVE = {".pem", ".key", ".p12", ".pfx", ".jks", ".keystore", ".db", ".sqlite", ".sqlite3", ".log"}
LINK = re.compile(r"!?\[[^\]]*\]\(([^)\n]+)\)")


class DocumentationTargets(HTMLParser):
    """Collect GitHub-supported image/picture and anchor targets without fetching them."""
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.targets = []

    def handle_starttag(self, tag, attributes):
        if tag not in {'img', 'source', 'a'}:
            return
        for name, value in attributes:
            if not value:
                continue
            if name in {'src', 'href'}:
                self.targets.append(value)
            elif name == 'srcset':
                # A URL may itself contain commas (e.g. Skill Icons parameters).
                rest = value
                while rest.strip(' ,\t\r\n'):
                    rest = rest.lstrip(' ,\t\r\n')
                    parts = rest.split(None, 1)
                    url = parts[0]
                    rest = parts[1] if len(parts) == 2 else ''
                    if url.endswith(','):
                        url = url.rstrip(',')
                    elif rest:
                        _, separator, rest = rest.partition(',')
                        if not separator:
                            rest = ''
                    self.targets.append(url)


def validate(root: Path, paths: list[str], defer_readme: bool = False) -> list[str]:
    errors = []
    for name in sorted(set(paths)):
        path = root / name
        if not path.exists() and not path.is_symlink():
            continue  # A tracked deletion is not part of the resulting source tree.
        if path.is_symlink():
            errors.append(f"{name}: source symlink requires review")
            continue
        if name.startswith(REMOVED):
            errors.append(f"{name}: excluded historical material")
        if (path.suffix.lower() in SENSITIVE or
            path.name.lower().endswith(('-wal', '-shm', '-journal')) or
            (path.name.startswith('.env') and not path.name.endswith('.example'))):
            errors.append(f"{name}: runtime/private path")
            continue
        if path.suffix != '.md' or (name == 'README.md' and defer_readme):
            continue
        text = path.read_text(encoding='utf-8')
        html = DocumentationTargets()
        html.feed(text)
        targets = [match.group(1) for match in LINK.finditer(text)] + html.targets
        for raw_target in targets:
            target = raw_target.strip()
            if target.startswith('<'):
                target = target.split('>', 1)[0][1:]
            else:
                target = target.split(' "', 1)[0]
            parsed = urlsplit(target)
            if parsed.scheme or parsed.netloc or not parsed.path:
                continue
            destination = (path.parent / unquote(parsed.path)).resolve()
            if not destination.is_relative_to(root):
                errors.append(f"{name}: local link escapes repository")
            elif not destination.exists():
                errors.append(f"{name}: missing local link {target}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--defer-root-readme', action='store_true', help='Check modules while the root README is edited separately')
    parser.add_argument('--public', action='store_true', help='Require complete docs and public redistribution eligibility')
    args = parser.parse_args()
    if args.public and args.defer_root_readme:
        parser.error('--public requires the root README check')
    raw = subprocess.check_output(['git', '-C', str(ROOT), 'ls-files', '-co', '--exclude-standard', '-z'])
    paths = [item.decode() for item in raw.split(b'\0') if item]
    errors = validate(ROOT, paths, args.defer_root_readme)
    for error in errors:
        print(error)
    if errors:
        return 1
    print('Source layout and local documentation links passed' + ('; root README explicitly deferred' if args.defer_root_readme else ''))
    command = ['python3', str(ROOT / 'tools/check_assets.py')]
    if args.public:
        command.append('--public')
    return subprocess.run(command, cwd=ROOT, check=False).returncode


if __name__ == '__main__':
    raise SystemExit(main())
