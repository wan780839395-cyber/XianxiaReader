#!/bin/bash
# One old callback control, then only the related candidate lifecycle contracts.
set -euo pipefail
cd "$(dirname "$0")/.."
folder="$PWD/build/SessionIsolation"
test ! -e "$folder"
mkdir -p "$folder" build/logs
candidate=$(git rev-parse HEAD)
baseline=a3aea572e692688fd9704e1b5035d6de260b0e02
source=App/Reader/ReaderViewModel.swift
git fetch --no-tags --depth=1 origin "$baseline"
test "$(git rev-parse FETCH_HEAD)" = "$baseline"
cp "$source" "$folder/candidate-ReaderViewModel.swift"
trap 'cp "$folder/candidate-ReaderViewModel.swift" "$source"' EXIT
verify_inputs() {
  python3 - "$candidate" "$baseline" "$1" "$folder" <<'PY'
from pathlib import Path
import hashlib,json,subprocess,sys
candidate,baseline,phase,folder=sys.argv[1:]
roots=['App','Packages','Vendor','Tests','scripts','.github','project.yml','Package.resolved','.gitattributes']
proof=[]
for row in subprocess.check_output(['git','ls-tree','-rz',candidate,'--',*roots]).split(b'\0'):
    if not row:continue
    info,name=row.split(b'\t',1);name=name.decode();expected=info.split()[2].decode()
    if phase=='baseline' and name=='App/Reader/ReaderViewModel.swift':
        expected=subprocess.check_output(['git','rev-parse',baseline+':'+name]).decode().strip()
    data=Path(name).read_bytes();blob=hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
    assert blob==expected,name
    proof.append(dict(path=name,gitBlob=blob,sha256=hashlib.sha256(data).hexdigest()))
Path(folder,phase+'-inputs.json').write_text(json.dumps(dict(candidate=candidate,baseline=baseline,phase=phase,
    onlyOverlay='App/Reader/ReaderViewModel.swift',inputs=proof),indent=2)+'\n')
PY
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
git show "$baseline:$source" > "$source"
verify_inputs baseline
run_cases session-owner-baseline baseline
mkdir "$folder/baseline"
cp -R build/logs "$folder/baseline/logs"
for entry in DiagnosticTests.xcresult PositionBuild.xcresult ReaderSnapshots test-results-summary.json build-environment.txt Package.resolved; do
  if [[ -e "build/$entry" ]]; then mv "build/$entry" "$folder/baseline/$entry"; fi
done
python3 scripts/verify_reader_sessions.py baseline "$folder/baseline" --status "${statuses[0]}" --report "$folder/baseline-receipt.json"
cp "$folder/candidate-ReaderViewModel.swift" "$source"
verify_inputs candidate
run_cases session-isolation candidate
python3 scripts/verify_reader_sessions.py candidate build --status "${statuses[0]}" --report "$folder/candidate-receipt.json"
echo 'Session isolation: qualified old 1-case failure and focused candidate contracts; no full gate/IPA'
