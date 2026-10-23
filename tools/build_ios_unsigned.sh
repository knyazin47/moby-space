#!/usr/bin/env bash
set -euo pipefail
task_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
python3 "$task_root/tools/lib/build_config.py"
if [[ "$(uname -s)" != Darwin ]]; then
  echo 'This build requires macOS and Xcode.' >&2
  exit 2
fi
# A manifest's exact source SHA is valid only for a committed source tree.
if [[ -n "$(git -C "$task_root" status --porcelain --untracked-files=normal -- frontend tools .github/workflows)" ]]; then
  echo 'Commit source changes before building a release.' >&2
  exit 2
fi
cd "$task_root/frontend"
task_flutter="${MOBY_FLUTTER_BIN:-flutter}"
xcodebuild -version
"$task_flutter" pub get --enforce-lockfile
set --
if [[ -n "${MOBY_API_URL:-}" ]]; then
  set -- "--dart-define=MOBY_API_URL=${MOBY_API_URL}"
fi
"$task_flutter" build ios --release --no-codesign "$@"
python3 - "$task_root" <<'PY'
from pathlib import Path
import hashlib,json,os,plistlib,shutil,subprocess,sys,tempfile
root=Path(sys.argv[1]);app=root/'frontend/build/ios/iphoneos/Runner.app'
info=plistlib.loads((app/'Info.plist').read_bytes())
assert info['CFBundleIdentifier']=='dev.knyazin47.moby'
assert info['CFBundleDisplayName']=='Moby Space'
assert info['CFBundleSupportedPlatforms']==['iPhoneOS']
version=info['CFBundleShortVersionString'];build=info['CFBundleVersion']
output=root/'frontend/build/ios/moby-unsigned';output.mkdir(parents=True,exist_ok=True)
artifact=output/f'moby-space-{version}-unsigned.ipa'
# Archive only app files, retaining executable modes and framework symlinks.
with tempfile.TemporaryDirectory(prefix='moby-ipa-') as scratch:
 payload=Path(scratch)/'Payload';payload.mkdir()
 subprocess.run(['ditto','--norsrc','--noextattr',str(app),str(payload/'Runner.app')],check=True)
 # Never reuse an existing zip: zip's update mode would retain stale entries.
 temporary=Path(scratch)/artifact.name
 subprocess.run(['zip','-qry',str(temporary),'Payload/Runner.app'],cwd=scratch,check=True)
 shutil.copyfile(temporary,artifact)
sha=hashlib.sha256(artifact.read_bytes()).hexdigest()
artifact.with_suffix('.sha256').write_text(f'{sha}  {artifact.name}\n')
commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
manifest={'schema_version':2,'platform':'ios-device','version':version+'+'+build,
 'source_commit':commit,'bundle_id':info['CFBundleIdentifier'],'display_name':info['CFBundleDisplayName'],
 'artifact':artifact.name,'sha256':sha,'bytes':artifact.stat().st_size,'signed':False,'build_mode':'network' if os.environ.get('MOBY_API_URL') else 'replica','api_url':os.environ.get('MOBY_API_URL',''),
 'minimum_os':info['MinimumOSVersion'],'physical_device_verified':False,
 'boundary':'Unsigned own-app device build. Re-sign with a personal Apple account before installation. No bank connectivity or real account data.'}
path=artifact.with_suffix('.manifest.json');path.write_text(json.dumps(manifest,indent=2)+'\n')
subprocess.run([sys.executable,str(root/'tools/check_ios_artifacts.py'),str(path)],check=True)
print('Unsigned artifact:',artifact)
PY
