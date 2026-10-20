#!/bin/bash
# Explicit negative control followed by the patched gate; never packages an IPA.
set -euo pipefail
cd "$(dirname "$0")/.."
patched=$(git rev-parse HEAD)
if ! baseline=$(git rev-parse --verify HEAD^ 2>/dev/null); then
  git fetch --no-tags --depth=2 origin "$patched"
  baseline=$(git rev-parse HEAD^)
fi
output="$PWD/build/PositionControl"
test ! -e "$output"
mkdir -p "$output"
printf '%s\n' "$baseline" > "$output/baseline-revision.txt"
printf '%s\n' "$patched" > "$output/patched-revision.txt"

restore_and_verify() {
  python3 - "$1" "$2" "$output" <<'PY'
from pathlib import Path
import hashlib, json, subprocess, sys
revision, phase, folder = sys.argv[1:]
for name in ['Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBReflowableSpreadView.swift', 'Vendor/ReadiumToolkit/UPSTREAM.json']:
    Path(name).write_bytes(subprocess.check_output(['git', 'show', revision + ':' + name]))
roots = ['App', 'Packages', 'Vendor', 'Tests', 'project.yml', 'Package.resolved', '.gitattributes', 'scripts/ci_reader_diagnostic.sh']
entries = subprocess.check_output(['git', 'ls-tree', '-rz', revision, '--', *roots]).split(b'\0')
proof = []
for row in entries:
    if not row: continue
    attrs, raw_name = row.split(b'\t', 1)
    mode, kind, expected = attrs.split()
    assert kind == b'blob'
    name = raw_name.decode('utf-8')
    data = Path(name).read_bytes()
    blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
    assert blob == expected.decode(), name
    proof.append({'path': name, 'gitBlob': blob, 'sha256': hashlib.sha256(data).hexdigest()})
Path(folder, phase + '-inputs.json').write_text(json.dumps({'revision': revision, 'inputs': proof}, indent=2) + '\n')
print(phase, 'runtime input blobs verified:', len(proof))
PY
  python3 scripts/verify_vendor.py
}

restore_and_verify "$baseline" baseline
if bash scripts/ci_reader_diagnostic.sh position-control-baseline 2>&1 | tee "$output/baseline-driver.log"; then
  baseline_exits=("${PIPESTATUS[@]}")
else
  baseline_exits=("${PIPESTATUS[@]}")
fi
printf '%s\n' "test=${baseline_exits[0]} tee=${baseline_exits[1]}" > "$output/baseline-exits.txt"
mkdir "$output/baseline"
# Move only this run's result bundles; retain its full logs before reuse.
cp -R build/logs "$output/baseline/logs"
for entry in DiagnosticTests.xcresult ReaderSnapshots test-results-summary.json build-environment.txt Package.resolved; do
  if [[ -e "build/$entry" ]]; then mv "build/$entry" "$output/baseline/$entry"; fi
done
python3 - "${baseline_exits[0]}" "${baseline_exits[1]}" "$output" <<'PY'
from pathlib import Path
import json, sys
status, tee_status, folder = sys.argv[1:]
assert int(tee_status) == 0
result = json.loads(Path(folder, 'baseline/test-results-summary.json').read_text())
failures = result.get('testFailures', [])
assert int(status) == 65, 'Old source must fail; a green replay is not a causal control'
assert result['totalTestCount'] == result['failedTests'] == 1
assert result['passedTests'] == result['skippedTests'] == 0
assert len(failures) == 1 and 'LATE_CANONICAL_VIEWPORT_OFFSET' in failures[0]['failureText'], failures
assert failures[0]['testIdentifierString'].startswith('ReaderRenderingTests/testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes'), failures
Path(folder, 'negative-control.json').write_text(json.dumps({'expectedFailureObserved': True, 'originalTestExit': int(status), 'marker': 'LATE_CANONICAL_VIEWPORT_OFFSET'}) + '\n')
print('Specified old-source offset failure reproduced; original exit65 retained')
PY

restore_and_verify "$patched" patched
if bash scripts/ci_reader_diagnostic.sh position-fix 2>&1 | tee "$output/patched-driver.log"; then
  patched_exits=("${PIPESTATUS[@]}")
else
  patched_exits=("${PIPESTATUS[@]}")
fi
printf '%s\n' "test=${patched_exits[0]} tee=${patched_exits[1]}" > "$output/patched-exits.txt"
if (( patched_exits[0] != 0 )); then exit "${patched_exits[0]}"; fi
if (( patched_exits[1] != 0 )); then exit "${patched_exits[1]}"; fi
python3 - "$output" <<'PY'
from pathlib import Path
import json, sys
folder = Path(sys.argv[1])
result = json.loads(Path('build/test-results-summary.json').read_text())
assert result['result'] == 'Passed'
assert result['totalTestCount'] == result['passedTests'] == 6
assert result['failedTests'] == result['skippedTests'] == 0 and not result.get('testFailures')
negative = json.loads((folder/'negative-control.json').read_text())
assert negative['expectedFailureObserved']
(folder/'receipt.json').write_text(json.dumps({'baseline': negative, 'patchedPassed': 6, 'patchedFailed': 0, 'patchedSkipped': 0, 'sharedBuildDirectory': True, 'importedFontCaseScope': 'continuous only in this diagnostic commit; default repository gate retains both modes', 'full187Executed': False, 'deviceReleaseExecuted': False, 'newIPA': False}, indent=2) + '\n')
print('POSITION CONTROL: old source failed specified assertion; patched six scoped cases passed; no Release or IPA')
PY
