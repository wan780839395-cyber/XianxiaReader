#!/bin/bash
# Preserve a diagnostic baseline, then validate an explicitly supplied child commit
# on the same runner/DerivedData. No Release build, automatic patch or test retry.
set -euo pipefail
cd "$(dirname "$0")/.."
folder="$PWD/build/PagedFontControl"
verify_inputs() {
  python3 - "$1" "$2" "$folder" <<'PY'
from pathlib import Path
import hashlib, json, subprocess, sys
revision, phase, folder = sys.argv[1:]
roots = ['App','Packages','Vendor','Tests','project.yml','Package.resolved','.gitattributes','scripts/ci_reader_diagnostic.sh','scripts/ci_paged_font_control.sh','.github/workflows/ios-build.yml']
rows = subprocess.check_output(['git','ls-tree','-rz',revision,'--',*roots]).split(b'\0')
proof=[]
for row in rows:
    if not row: continue
    info, raw_name = row.split(b'\t',1); name=raw_name.decode()
    data=Path(name).read_bytes()
    blob=hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
    assert blob == info.split()[2].decode(), name
    proof.append(dict(path=name,gitBlob=blob,sha256=hashlib.sha256(data).hexdigest()))
Path(folder,phase+'-inputs.json').write_text(json.dumps(dict(revision=revision,inputs=proof),indent=2)+'\n')
print(phase, 'verified source inputs',len(proof))
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
case "${1:?baseline or patched}" in
  baseline)
    test ! -e "$folder"
    mkdir -p "$folder" build/logs
    git rev-parse HEAD > "$folder/baseline-revision.txt"
    verify_inputs "$(cat "$folder/baseline-revision.txt")" baseline
    run_cases paged-font baseline
    mkdir "$folder/baseline"
    cp -R build/logs "$folder/baseline/logs"
    for entry in DiagnosticTests.xcresult ReaderSnapshots test-results-summary.json build-environment.txt Package.resolved; do
      if [[ -e "build/$entry" ]]; then mv "build/$entry" "$folder/baseline/$entry"; fi
    done
    python3 - "${statuses[0]}" "$folder" <<'PY'
from pathlib import Path
import json,sys
status,folder=sys.argv[1:]
d=json.loads(Path(folder,'baseline/test-results-summary.json').read_text())
assert int(status) in (0,65) and d['totalTestCount']==2 and d['skippedTests']==0,d
assert (int(status)==0)==(d['failedTests']==0),d
allowed={'ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes()','ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord()'}
assert all(f['testIdentifierString'] in allowed for f in d.get('testFailures',[])), d
Path(folder,'baseline-result.json').write_text(json.dumps(dict(originalExit=int(status),baselineWasNegative=int(status)==65,summary=d))+'\n')
print('Original baseline exit retained:',status,'; a green replay is not a fix.')
PY
    ;;
  patched)
    test -f "$folder/baseline-result.json"
    reference="${XR_PAGED_FONT_CANDIDATE_REF:-refs/heads/codex/fix-paged-font-restore-stage2}"
    deadline=$((SECONDS + 900))
    while true; do
      if remote=$(git ls-remote --heads origin "$reference") && [[ -n "$remote" ]]; then break; fi
      if (( SECONDS >= deadline )); then echo 'No reviewed candidate supplied within 15 minutes' >&2; exit 75; fi
      sleep 10
    done
    git fetch --no-tags --depth=2 origin "$reference"
    candidate=$(git rev-parse FETCH_HEAD)
    python3 - "$candidate" "$folder" <<'PY'
from pathlib import Path
import json,subprocess,sys
revision,folder=sys.argv[1:]
baseline=Path(folder,'baseline-revision.txt').read_text().strip()
assert subprocess.check_output(['git','rev-parse',revision+'^']).decode().strip()==baseline, 'Candidate must be the exact baseline child'
allowed={'Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBNavigatorViewController.swift','Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBReflowableSpreadView.swift','Vendor/ReadiumToolkit/Sources/Navigator/Toolkit/PaginationView.swift','Vendor/ReadiumToolkit/UPSTREAM.json'}
changed=set(subprocess.check_output(['git','diff-tree','--no-commit-id','--name-only','-r',baseline,revision,'--','App','Packages','Vendor','Tests','scripts','.github','project.yml','Package.resolved','.gitattributes']).decode().splitlines())
assert changed and changed<=allowed and 'Vendor/ReadiumToolkit/UPSTREAM.json' in changed,changed
for name in changed: Path(name).write_bytes(subprocess.check_output(['git','show',revision+':'+name]))
Path(folder,'candidate-revision.txt').write_text(revision+'\n')
Path(folder,'candidate-delta.json').write_text(json.dumps(sorted(changed))+'\n')
PY
    verify_inputs "$candidate" patched
    run_cases paged-font-acceptance patched
    if (( statuses[0] != 0 )); then exit "${statuses[0]}"; fi
    python3 - "$folder" <<'PY'
from pathlib import Path
import json,sys
d=json.loads(Path('build/test-results-summary.json').read_text())
assert d['result']=='Passed' and d['totalTestCount']==d['passedTests']==8 and d['failedTests']==d['skippedTests']==0 and not d.get('testFailures'),d
baseline=json.loads(Path(sys.argv[1],'baseline-result.json').read_text())
Path(sys.argv[1],'receipt.json').write_text(json.dumps(dict(baselineOriginalExit=baseline['originalExit'],baselineWasNegative=baseline['baselineWasNegative'],patchedOriginalExit=0,passed=8,failed=0,skipped=0,sharedDerivedData=True,full187Executed=False,deviceReleaseExecuted=False,newIPA=False),indent=2)+'\n')
PY
    ;;
  *) exit 2 ;;
esac
