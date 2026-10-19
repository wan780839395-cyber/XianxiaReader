#!/bin/bash
# macOS only. The caller tees ALL stdout/stderr; pipefail preserves real failures.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/logs .cache
test -d "${DEVELOPER_DIR:?Select Xcode 16.4}/Platforms/iPhoneOS.platform"
xcodebuild -version | tee build/build-environment.txt
swift --version | tee -a build/build-environment.txt
sw_vers | tee -a build/build-environment.txt

# Pin generator source to a release instead of whatever Homebrew happens to install.
if [[ ! -d .cache/XcodeGen ]]; then
  git clone --depth 1 --branch 2.46.0 https://github.com/yonaskolb/XcodeGen.git .cache/XcodeGen
fi
test "$(git -C .cache/XcodeGen describe --tags --exact-match)" = "2.46.0"
swift run --package-path .cache/XcodeGen --configuration release xcodegen generate --spec "$PWD/project.yml"

# Seed the generated workspace with the lockfile from the first real CI resolution.
mkdir -p XianxiaReader.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
cp Package.resolved XianxiaReader.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

# A deliberate bootstrap run publishes the resolver-produced lock as an
# artifact. Adopt that exact file and rerun the whole workflow with this off.
if [[ "${READIUM_RESOLVE_BOOTSTRAP:-0}" == 1 ]]; then
  bash scripts/resolve_local_readium.sh
fi
python3 scripts/verify_readium_lock.py Package.resolved
cp Package.resolved build/Package.resolved

swift test --package-path Packages/XianxiaCore --parallel
swift build --package-path Packages/XianxiaCore --configuration release --product TXTPerformanceProbe
PROBE_BIN=$(swift build --package-path Packages/XianxiaCore --configuration release --show-bin-path)
python3 scripts/run_txt_performance.py --binary "$PROBE_BIN/TXTPerformanceProbe" --output build/TXTPerformance
xcodebuild -resolvePackageDependencies -project XianxiaReader.xcodeproj -scheme XianxiaReader \
  -onlyUsePackageVersionsFromResolvedFile \
  -clonedSourcePackagesDirPath "$PWD/build/SourcePackages"

# A simulator is selected by real availability, not a hardcoded device UUID/name.
xcrun simctl list devices available --json > build/devices.json
SIMULATOR_ID=$(python3 scripts/select_simulator.py build/devices.json)

# Keep the base simulator recording as a diagnostic. XCTest can execute on a
# clone; its per-test recordings are retained by project.yml and exported below.
# A recording/export failure must not silently produce a supposedly validated IPA.
mkdir -p build/InteractionVideo
xcrun simctl bootstatus "$SIMULATOR_ID" -b
case "${IOS_TEST_SCOPE:-full}" in
  full) set -- ;;
  unit-release)
    python3 scripts/verify_ui_baseline.py --simulator-id "$SIMULATOR_ID"
    set -- -only-testing:XianxiaReaderTests
    ;;
  *) echo "Invalid iOS test scope" >&2; exit 2 ;;
esac
# Exercise the real system-follow shelf/search path on a dark OS. Reader page
# themes are independent and the existing five-theme tests still run in full.
xcrun simctl ui "$SIMULATOR_ID" appearance dark
xcrun simctl io "$SIMULATOR_ID" recordVideo --codec=h264 "$PWD/build/InteractionVideo/library-interactions.mp4" > build/InteractionVideo/recording.log 2>&1 &
video_pid=$!
stop_simulator_recording() {
  if kill -INT "$1"; then
    wait "$1"
  else
    # Collect the real exit of an already-failed recorder before reporting failure.
    if wait "$1"; then return 1; else return "$?"; fi
  fi
}
if ps -axo pid,ppid,state,rss,comm > build/logs/processes-before-tests.log 2>&1; then :
else echo "Additional pre-test process context unavailable; original tests still run"; fi
test_status=0
if xcodebuild test -project XianxiaReader.xcodeproj -scheme XianxiaReader \
  -onlyUsePackageVersionsFromResolvedFile \
  -configuration Debug -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  -derivedDataPath "$PWD/build/DerivedData" \
  -clonedSourcePackagesDirPath "$PWD/build/SourcePackages" \
  -resultBundlePath "$PWD/build/SimulatorTests.xcresult" "$@" CODE_SIGNING_ALLOWED=NO; then
  test_status=0
else
  test_status=$?
fi

# SIGINT flushes the simulator recording and preserves its real exit status.
video_status=0
if stop_simulator_recording "$video_pid"; then video_status=0; else video_status=$?; fi
if [[ ! -s build/InteractionVideo/library-interactions.mp4 ]]; then video_status=1; fi

# Structured xcresult totals include crashed tests from previous launches,
# unlike the final restarted suite's visible log tail.
summary_status=0
if xcrun xcresulttool get test-results summary --path build/SimulatorTests.xcresult > build/test-results-summary.json; then
  summary_status=0
else
  summary_status=$?
fi

# Keep real WKWebView image snapshots from the rendering regressions for visual review.
export_status=0
if xcrun xcresulttool export attachments --path build/SimulatorTests.xcresult --output-path build/ReaderSnapshots; then
  export_status=0
else
  export_status=$?
fi
# Best-effort, bounded service context; no command arguments or book text.
# Missing/slow diagnostic tools are recorded, preserving the actual test exit.
if python3 - "$SIMULATOR_ID" <<'XR_CONTEXT'
from pathlib import Path
import json, subprocess, sys
folder=Path("build/logs");folder.mkdir(parents=True,exist_ok=True);records=[]
commands=[("processes-after-tests",["ps","-axo","pid,ppid,state,rss,comm"],10),
          ("document-services",["xcrun","simctl","spawn",sys.argv[1],"log","show","--last","10m","--style","compact","--predicate",'subsystem CONTAINS "DocumentManager" OR subsystem CONTAINS "FileProvider"'],20)]
for name,command,seconds in commands:
    try:
        result=subprocess.run(command,capture_output=True,timeout=seconds)
        (folder/(name+".log")).write_bytes(result.stdout+result.stderr)
        records.append(dict(name=name,exit=result.returncode,timeout=False))
    except subprocess.TimeoutExpired as error:
        (folder/(name+".log")).write_bytes((error.stdout or b"")+(error.stderr or b""))
        records.append(dict(name=name,timeout=True,error=str(error)))
    except OSError as error:
        (folder/(name+".log")).write_text(str(error))
        records.append(dict(name=name,timeout=False,error=str(error)))
(folder/"additional-context.json").write_text(json.dumps(dict(bestEffort=True,records=records),indent=2))
print("Additional simulated service context recorded; original test/build exits preserved")
XR_CONTEXT
then echo "Additional context command exit: 0"
else context_status=$?; echo "Additional context command exit: $context_status; original test/build exits preserved"; fi
# Export failed-test screenshots too, then propagate the ORIGINAL test exit.
# A successful test with a failed export also fails, never producing an IPA.
echo "Simulator test exit: $test_status; attachment export exit: $export_status; summary exit: $summary_status"
echo "Simulator recording exit: $video_status"
if (( test_status != 0 )); then exit "$test_status"; fi
if (( export_status != 0 )); then exit "$export_status"; fi
if (( summary_status != 0 )); then exit "$summary_status"; fi
if (( video_status != 0 )); then exit "$video_status"; fi
if [[ "${IOS_TEST_SCOPE:-full}" == 'unit-release' ]]; then
  python3 scripts/verify_ui_baseline.py --unit-summary build/test-results-summary.json
fi

xcodebuild build -project XianxiaReader.xcodeproj -scheme XianxiaReader \
  -onlyUsePackageVersionsFromResolvedFile \
  -configuration Release -destination 'generic/platform=iOS' \
  -derivedDataPath "$PWD/build/DerivedData" \
  -clonedSourcePackagesDirPath "$PWD/build/SourcePackages" \
  -resultBundlePath "$PWD/build/DeviceBuild.xcresult" CODE_SIGNING_ALLOWED=NO

python3 scripts/package_ipa.py \
  build/DerivedData/Build/Products/Release-iphoneos/XianxiaReader.app build/XianxiaReader.ipa
shasum -a 256 build/XianxiaReader.ipa
