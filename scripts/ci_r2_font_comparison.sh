#!/bin/bash
# One matched pre-R2 / R2 experiment. No source/test/budget edits or test retries.
set -euo pipefail
cd "${XR_CONTROL_ROOT:?Run the saved harness from the ephemeral CI checkout}"
export XR_CONTROL_ROOT="$PWD"
baseline=222f10e072c2580127bf4a510d23ab5c464a2e55
r2=f29c4babbc0e92d83b286703540e1334ff771532
common="${RUNNER_TEMP:?}/r2-font-common.sh"
mkdir -p build/R2FontControl
python3 - "$common" <<'PY'
from pathlib import Path
import hashlib,json,sys
source=Path('scripts/ci_reader_diagnostic.sh').read_text()
assert source.count('cd "$(dirname "$0")/.."')==1 and source.count('\nesac\n')==1
source=source.replace('cd "$(dirname "$0")/.."','cd "${XR_CONTROL_ROOT:?}"',1)
source=source.replace('\nesac\n','\nesac\ncases=(-only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes)\n',1)
Path(sys.argv[1]).write_text(source)
Path('build/R2FontControl/harness.json').write_text(json.dumps({'commonSHA256':hashlib.sha256(source.encode()).hexdigest(),'test':'ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes','testBodiesChanged':False,'testBudgetChanged':False,'retries':0},indent=2)+'\n')
PY
overall_status=0
for label in baseline r2; do
  revision="$baseline"
  if [[ "$label" == r2 ]]; then revision="$r2"; fi
  git fetch --no-tags --depth=1 origin "$revision"
  git checkout --detach "$revision"
  test "$(git rev-parse HEAD)" = "$revision"
  evidence="$PWD/build/R2FontControl/$label"
  mkdir -p "$evidence"
  git status --porcelain --untracked-files=no > "$evidence/tracked-before.txt"
  test ! -s "$evidence/tracked-before.txt"
  git ls-tree -r HEAD > "$evidence/source-tree.txt"
  status=0
  if bash "$common" fonts 2>&1 | tee "$evidence/test.log"; then status=0; else status=$?; fi
  git diff --exit-code "$revision" -- App Packages Vendor Tests project.yml Package.resolved
  for name in DiagnosticTests.xcresult ReaderSnapshots test-results-summary.json build-environment.txt Package.resolved devices.json; do
    if [[ -e "build/$name" ]]; then mv "build/$name" "$evidence/$name"; fi
  done
  mkdir -p "$evidence/context"
  for name in native-resources.jsonl processes-before-tests.log processes-after-tests.log reading-lifecycle.log document-services.log additional-context.json; do
    if [[ -f "build/logs/$name" ]]; then cp "build/logs/$name" "$evidence/context/$name"; fi
  done
  python3 - "$label" "$revision" "$status" "$evidence" <<'PY'
from pathlib import Path
import json,sys
label,revision,status,folder=sys.argv[1:]
p=Path(folder)
record={'label':label,'sourceRevision':revision,'testExit':int(status),'sourceTree':str(p/'source-tree.txt'),'testLog':str(p/'test.log'),'sameRunner':True,'sameCommonHarness':True,'productionInputsUnchangedAfterTest':True}
summary=p/'test-results-summary.json'
if summary.exists():record['summary']=json.loads(summary.read_text())
(p/'receipt.json').write_text(json.dumps(record,indent=2)+'\n')
print('R2_FONT_COMPARISON_RESULT '+json.dumps(record))
PY
  if [[ "$status" -ne 0 ]]; then overall_status="$status"; fi
done
echo "COMPARISON ONLY: baseline and R2 each executed once; exit=$overall_status; no device Release or IPA"
exit "$overall_status"
