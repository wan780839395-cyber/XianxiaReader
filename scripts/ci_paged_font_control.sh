#!/bin/bash
# One native resize-control case on each source; preserve real exits and evidence.
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
    run_cases paged-resize-control baseline
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
assert int(status) in (0,65) and d['totalTestCount']==1 and d['skippedTests']==0,d
assert (int(status)==0)==(d['failedTests']==0),d
allowed={'ReaderRenderingTests/testSameWidthBodyResizeDoesNotOverwritePendingPagedWord()'}
assert all(f['testIdentifierString'] in allowed for f in d.get('testFailures',[])), d
qualified=any(f.get('testIdentifierString')=='ReaderRenderingTests/testSameWidthBodyResizeDoesNotOverwritePendingPagedWord()' and 'SAME_WIDTH_RESIZE_MUST_NOT_WRITE_POSITION' in f.get('failureText','') for f in d.get('testFailures',[]))
import re
lines=Path(folder,'baseline/logs/reader-diagnostic.log').read_text(errors='replace').splitlines()
evidence=[json.loads(line.split('SAME_WIDTH_RESIZE_CONTROL_EVIDENCE ',1)[1]) for line in lines if line.startswith('SAME_WIDTH_RESIZE_CONTROL_EVIDENCE ')]
assert len(evidence)==1, 'Exactly one native control evidence record is required'
e=evidence[0]
target=e.get('owner',{}).get('source','').find('document.scrollingElement.scrollLeft')>=0
frames=e.get('frames',[])
entered=target and len(frames)==1 and frames[0].get('target') is True and e.get('returned') is True and e.get('href','').endswith('/one.xhtml') and e.get('mode')!='readium-scroll-on'
staleRead=any(row.get('injected') is True and row.get('role')=='snap' and row.get('value')==0 for row in e.get('reads',[]))
progressionRead=any(row.get('injected') is False and row.get('role')=='progression' for row in e.get('reads',[]))
zeroWrite=any(row.get('value')==0 for row in e.get('writes',[]))
qualified=qualified and entered and staleRead and zeroWrite and progressionRead
Path(folder,'baseline-result.json').write_text(json.dumps(dict(originalExit=int(status),baselineWasNegative=int(status)==65,sameWidthControlledFailure=qualified,targetFrameEntered=entered,injectedReadObserved=staleRead,zeroWriteObserved=zeroWrite,progressionBypassObserved=progressionRead,controlEvidence=e,summary=d))+'\n')
print('Original baseline exit retained:',status,'; a green replay is not a fix.')
PY
    ;;
  patched)
    test -f "$folder/baseline-result.json"
    reference="${XR_PAGED_FONT_CANDIDATE_REF:-refs/heads/codex/fix-paged-font-owner-control}"
    remote=$(git ls-remote --heads origin "$reference")
    test -n "$remote" # Candidate must be frozen and pushed before dispatch; no empty wait.
    git fetch --no-tags --depth=2 origin "$reference"
    candidate=$(git rev-parse FETCH_HEAD)
    python3 - "$candidate" "$folder" <<'PY'
from pathlib import Path
import json,subprocess,sys
revision,folder=sys.argv[1:]
baseline=Path(folder,'baseline-revision.txt').read_text().strip()
assert subprocess.check_output(['git','rev-parse',revision+'^']).decode().strip()==baseline, 'Candidate must be the exact baseline child'
allowed={'Vendor/ReadiumToolkit/UPSTREAM.json','Vendor/ReadiumToolkit/Sources/Navigator/EPUB/Assets/Static/scripts/readium-reflowable.js'}
changed=set(subprocess.check_output(['git','diff-tree','--no-commit-id','--name-only','-r',baseline,revision,'--','App','Packages','Vendor','Tests','scripts','.github','project.yml','Package.resolved','.gitattributes']).decode().splitlines())
assert changed and changed<=allowed and 'Vendor/ReadiumToolkit/UPSTREAM.json' in changed,changed
for name in changed: Path(name).write_bytes(subprocess.check_output(['git','show',revision+':'+name]))
Path(folder,'candidate-revision.txt').write_text(revision+'\n')
Path(folder,'candidate-delta.json').write_text(json.dumps(sorted(changed))+'\n')
PY
    verify_inputs "$candidate" patched
    run_cases paged-resize-control patched
    if (( statuses[0] != 0 )); then exit "${statuses[0]}"; fi
    python3 - "$folder" <<'PY'
from pathlib import Path
import json,sys
d=json.loads(Path('build/test-results-summary.json').read_text())
assert d['result']=='Passed' and d['totalTestCount']==d['passedTests']==1 and d['failedTests']==d['skippedTests']==0 and not d.get('testFailures'),d
baseline=json.loads(Path(sys.argv[1],'baseline-result.json').read_text())
lines=Path('build/logs/reader-diagnostic.log').read_text(errors='replace').splitlines()
evidence=[json.loads(line.split('SAME_WIDTH_RESIZE_CONTROL_EVIDENCE ',1)[1]) for line in lines if line.startswith('SAME_WIDTH_RESIZE_CONTROL_EVIDENCE ')]
assert len(evidence)==1, 'Exactly one patched native control evidence record is required'
e=evidence[0]
frames=e.get('frames',[])
assert len(frames)==1 and frames[0].get('target') is True and e.get('returned') is True, e
assert not e.get('writes'), 'Candidate same-width frame must not attempt a root position write'
assert e.get('reads') and all(row.get('injected') is False and row.get('role')=='progression' and row.get('value',0)>100 for row in e['reads']), 'Candidate must use only the live progression coordinate, with no injected snap read'
Path(sys.argv[1],'patched-control-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
Path(sys.argv[1],'receipt.json').write_text(json.dumps(dict(baselineOriginalExit=baseline['originalExit'],baselineWasNegative=baseline['baselineWasNegative'],sameWidthControlledFailure=baseline['sameWidthControlledFailure'],patchedOriginalExit=0,passed=1,failed=0,skipped=0,sharedDerivedData=True,full187Executed=False,full188Executed=False,deviceReleaseExecuted=False,newIPA=False),indent=2)+'\n')
assert baseline['sameWidthControlledFailure'], 'Native negative control did not enter the old failing writer; candidate success alone is unqualified'
PY
    ;;
  *) exit 2 ;;
esac
