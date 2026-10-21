#!/bin/bash
# One controlled old case, then six directly affected candidate cases. No retry/IPA.
set -euo pipefail
cd "$(dirname "$0")/.."
folder="$PWD/build/EpubReadyControl"
test ! -e "$folder"
mkdir -p "$folder" build/logs
baseline=$(git rev-parse HEAD)
reference="${XR_EPUB_READY_CANDIDATE_REF:-refs/heads/codex/fix-epub-native-readiness}"
git fetch --no-tags --depth=2 origin "$reference"
candidate=$(git rev-parse FETCH_HEAD)
python3 - "$baseline" "$candidate" "$folder" <<'PY'
from pathlib import Path
import json,subprocess,sys
baseline,candidate,folder=sys.argv[1:]
assert subprocess.check_output(['git','rev-parse',candidate+'^']).decode().strip()==baseline
allowed={'Vendor/ReadiumToolkit/UPSTREAM.json','Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBSpreadView.swift'}
changed=set(subprocess.check_output(['git','diff-tree','--no-commit-id','--name-only','-r',baseline,candidate]).decode().splitlines())
assert changed==allowed,changed
Path(folder,'source-pair.json').write_text(json.dumps(dict(baseline=baseline,candidate=candidate,changed=sorted(changed)),indent=2)+'\n')
PY
verify_inputs() {
  python3 - "$1" "$2" "$folder" <<'PY'
from pathlib import Path
import hashlib,json,subprocess,sys
revision,phase,folder=sys.argv[1:]
roots=['App','Packages','Vendor','Tests','scripts','.github','project.yml','Package.resolved','.gitattributes']
proof=[]
for row in subprocess.check_output(['git','ls-tree','-rz',revision,'--',*roots]).split(b'\0'):
    if not row:continue
    info,name=row.split(b'\t',1);name=name.decode();data=Path(name).read_bytes()
    blob=hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
    assert blob==info.split()[2].decode(),name
    proof.append(dict(path=name,gitBlob=blob,sha256=hashlib.sha256(data).hexdigest()))
Path(folder,phase+'-inputs.json').write_text(json.dumps(dict(revision=revision,inputs=proof),indent=2)+'\n')
PY
  python3 scripts/verify_vendor.py
}
run_cases() {
  if bash scripts/ci_reader_diagnostic.sh "$1" 2>&1 | tee build/logs/reader-diagnostic.log; then
    statuses=("${PIPESTATUS[@]}")
  else
    statuses=("${PIPESTATUS[@]}")
  fi
  printf 'test=%s tee=%s\n' "${statuses[0]}" "${statuses[1]}" > "$folder/$2-exits.txt"
  if (( statuses[1] != 0 )); then exit "${statuses[1]}"; fi
}
verify_inputs "$baseline" baseline
run_cases epub-ready-baseline baseline
mkdir "$folder/baseline"
cp -R build/logs "$folder/baseline/logs"
for entry in DiagnosticTests.xcresult PositionBuild.xcresult ReaderSnapshots test-results-summary.json build-environment.txt Package.resolved; do
  if [[ -e "build/$entry" ]]; then mv "build/$entry" "$folder/baseline/$entry"; fi
done
python3 scripts/verify_epub_ready_control.py baseline "$folder/baseline" "${statuses[0]}" "$folder/baseline-verification.json"
# Preserve the old 65 and xcresult. Change only the reviewed exact child delta.
python3 - "$candidate" <<'PY'
from pathlib import Path
import subprocess,sys
for name in ['Vendor/ReadiumToolkit/UPSTREAM.json','Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBSpreadView.swift']:
    Path(name).write_bytes(subprocess.check_output(['git','show',sys.argv[1]+':'+name]))
PY
verify_inputs "$candidate" patched
run_cases epub-ready-patched patched
if (( statuses[0] != 0 )); then exit "${statuses[0]}"; fi
python3 scripts/verify_epub_ready_control.py patched build "${statuses[0]}" "$folder/patched-verification.json"
echo 'EPUB readiness: qualified old 1-case failure and candidate 6-case pass; shared runner/DerivedData, no full gate or IPA'
