#!/usr/bin/env bash
set -euo pipefail
task_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
python3 "$task_root/tools/lib/build_config.py"
# A manifest's exact source SHA is valid only for a committed source tree.
if [[ -n "$(git -C "$task_root" status --porcelain --untracked-files=normal -- frontend tools .github/workflows)" ]]; then
  echo 'Commit source changes before building a release.' >&2
  exit 2
fi
cd "$task_root/frontend"
task_flutter="${MOBY_FLUTTER_BIN:-flutter}"
task_signing_mode="${MOBY_ANDROID_SIGNING_MODE:-ephemeral}"
task_signing_dir=""
cleanup_signing() {
  if [[ -n "$task_signing_dir" ]]; then
    rm -f -- "$task_signing_dir/release.p12"
    rmdir -- "$task_signing_dir"
  fi
}
trap cleanup_signing EXIT
case "$task_signing_mode" in
  permanent)
    : "${MOBY_ANDROID_STORE_FILE:?Permanent signing requires a reviewed keystore}"
    : "${MOBY_ANDROID_STORE_PASSWORD:?Permanent signing requires its password}"
    ;;
  ephemeral)
    if [[ -n "${MOBY_ANDROID_STORE_FILE:-}" ]]; then
      echo 'Select permanent signing explicitly when supplying a keystore.' >&2
      exit 2
    fi
    task_signing_dir="$(mktemp -d)"
    export MOBY_ANDROID_STORE_FILE="$task_signing_dir/release.p12"
    export MOBY_ANDROID_STORE_PASSWORD="$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')"
    if [[ "${GITHUB_ACTIONS:-}" == true ]]; then
      printf '::add-mask::%s\n' "$MOBY_ANDROID_STORE_PASSWORD"
    fi
    keytool -genkeypair -noprompt -storetype PKCS12 \
      -keystore "$MOBY_ANDROID_STORE_FILE" -storepass:env MOBY_ANDROID_STORE_PASSWORD \
      -keypass:env MOBY_ANDROID_STORE_PASSWORD -alias moby-internal -keyalg RSA \
      -keysize 3072 -validity 365 -dname 'CN=Moby disposable development build' >/dev/null 2>&1
    ;;
  *) echo 'MOBY_ANDROID_SIGNING_MODE must be ephemeral or permanent.' >&2; exit 2 ;;
esac
export MOBY_ANDROID_SIGNING_MODE="$task_signing_mode"
: "${MOBY_VERIFIED_TEST_COUNT:?Set the number of tests from the successful validation run}"
"$task_flutter" pub get --enforce-lockfile
set --
if [[ -n "${MOBY_API_URL:-}" ]]; then
  set -- "--dart-define=MOBY_API_URL=${MOBY_API_URL}"
fi
"$task_flutter" build apk --release "$@"
python3 - "$task_root" <<'PY'
from pathlib import Path
import hashlib,json,os,re,shutil,subprocess,sys,zipfile
root=Path(sys.argv[1]);frontend=root/'frontend'
version=re.search(r'^version: (.+)$',(frontend/'pubspec.yaml').read_text(),re.M)[1]
source=frontend/'build/app/outputs/flutter-apk/app-release.apk'
sdk=Path(os.environ.get('ANDROID_HOME') or os.environ.get('ANDROID_SDK_ROOT') or root/'.tools/android-sdk')
tools=sorted((p for p in (sdk/'build-tools').glob('*/apksigner') if re.fullmatch(r'\d+\.\d+\.\d+',p.parent.name)),key=lambda p:[int(x) for x in p.parent.name.split('.')])
assert tools,'Android apksigner unavailable'
verification=subprocess.check_output([str(tools[-1]),'verify','--print-certs',str(source)],text=True)
certificate_sha=re.search(r'certificate SHA-256 digest: ([0-9a-fA-F]+)',verification)[1].lower()
signing_mode=os.environ['MOBY_ANDROID_SIGNING_MODE']
if signing_mode == 'permanent':
 expected=json.loads((root/'tools/release/android-signing.json').read_text())['certificate_sha256']
 assert certificate_sha==expected,'Unexpected permanent Android signing identity'
output=frontend/'build/mobile-release';output.mkdir(exist_ok=True)
artifact=output/f'moby-space-{version.split("+")[0]}.apk';shutil.copyfile(source,artifact)
sha=hashlib.sha256(artifact.read_bytes()).hexdigest()
artifact.with_suffix('.sha256').write_text(f'{sha}  {artifact.name}\n')
with zipfile.ZipFile(artifact) as z:
 abis=sorted({p.split('/')[1] for p in z.namelist() if p.startswith('lib/') and p.endswith('/libapp.so')})
manifest={'schema_version':2,'version':version,'source_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),
 'application_id':'dev.knyazin47.moby','sha256':sha,'bytes':artifact.stat().st_size,'abis':abis,
 'physical_device_verified':False,'unit_widget_asset_tests':int(os.environ['MOBY_VERIFIED_TEST_COUNT']),
 'flutter_analyze':'passed','signature_verify':'passed','signing_mode':signing_mode,
 'signing_compatibility':('reviewed permanent identity; not store distribution' if signing_mode=='permanent' else 'disposable identity; no update compatibility with other builds'),
 'signing_certificate_sha256':certificate_sha,
 'build_mode':'network' if os.environ.get('MOBY_API_URL') else 'replica',
 'api_url':os.environ.get('MOBY_API_URL',''),'boundary':'Synthetic own-app demo; no bank connectivity or real account data.'}
path=artifact.with_suffix('.manifest.json');path.write_text(json.dumps(manifest,indent=2)+'\n')
subprocess.run([sys.executable,str(root/'tools/check_release_artifacts.py'),str(path)],check=True)
PY
