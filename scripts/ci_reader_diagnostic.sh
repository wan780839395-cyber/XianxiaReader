#!/bin/bash
# Selected macOS diagnostics only. This script never builds or packages a device IPA.
# The default full ios-build.yml/ci_ios.sh pipeline remains the delivery gate.
set -euo pipefail
cd "$(dirname "$0")/.."
selection="${1:?Choose native-input, fonts, panels, recovery, settings or settings-ui}"
case "$selection" in
  settings-ui)
    cases=(
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testTouchExtentComparisonKeeps44PointMinimumAndRejectsRealShortfalls
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testProgressAndHeaderBackdropKeepMenuGesturesAndChapterUpdates
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testUnsafeEdgesRemainCoveredDuringSlowScrollThemeAndRotation
    )
    ;;
  settings)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderSettingsPersistenceTests
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests
    )
    ;;
  native-input)
    cases=(-only-testing:XianxiaReaderTests/ReaderSearchFieldTests)
    ;;
  fonts)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord
    )
    ;;
  recovery)
    cases=(
      -only-testing:XianxiaReaderTests/TXTReadingTests/testTXTChineseAppearanceAndNonzeroUTF16AnchorSurviveTypographyAndReopen
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord
      -only-testing:XianxiaReaderUITests/LibraryInteractionUITests/testCoverEditorNativeFilesCancelDefaultSaveAndReopen
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testNativeMenuLayoutGroupsPublisherRulesAndRelaunch
      -only-testing:XianxiaReaderTests/ReaderSurfaceTests
      -only-testing:XianxiaReaderTests/ReadingExperienceTests/testReaderPresentationThemeNeverChangesShelfOrWindowAndRestoresLocalOverride
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testContinuousBoundaryShowsTwoResourcesAndScrollsBack
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testProgressAndHeaderBackdropKeepMenuGesturesAndChapterUpdates
      -only-testing:XianxiaReaderUITests/ReadingExperienceUITests/testFontCollectionGridSearchAndOptInLayoutPresetsPreserveSelection
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testUnsafeEdgesRemainCoveredDuringSlowScrollThemeAndRotation
    )
    ;;
  panels)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testNativeMenuLayoutGroupsPublisherRulesAndRelaunch
      -only-testing:XianxiaReaderTests/ReadingExperienceTests
      -only-testing:XianxiaReaderTests/ReaderSearchFieldTests
      -only-testing:XianxiaReaderTests/ReadingFontTests/testExternalFontBrowsingDoesNotRebuildUntilExplicitSelectionAndKeepsFullAnchor
      -only-testing:XianxiaReaderUITests/ReadingExperienceUITests
      -only-testing:XianxiaReaderUITests/ReadingFontUITests
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testReadingPanelsFollowFiveThemesAndKeepNativeHitRegions
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testThemedBookmarkSwipePersistsAndSearchClearDoesNotReuseResults
    )
    ;;
  *) echo "Invalid diagnostic selection" >&2; exit 2 ;;
esac
mkdir -p build/logs .cache
test -d "${DEVELOPER_DIR:?Select Xcode 16.4}/Platforms/iPhoneOS.platform"
xcodebuild -version | tee build/build-environment.txt
swift --version | tee -a build/build-environment.txt
sw_vers | tee -a build/build-environment.txt
if [[ ! -d .cache/XcodeGen ]]; then
  git clone --depth 1 --branch 2.46.0 https://github.com/yonaskolb/XcodeGen.git .cache/XcodeGen
fi
test "$(git -C .cache/XcodeGen describe --tags --exact-match)" = "2.46.0"
swift run --package-path .cache/XcodeGen --configuration release xcodegen generate --spec "$PWD/project.yml"
mkdir -p XianxiaReader.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
cp Package.resolved XianxiaReader.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
python3 scripts/verify_readium_lock.py Package.resolved
cp Package.resolved build/Package.resolved
xcodebuild -resolvePackageDependencies -project XianxiaReader.xcodeproj -scheme XianxiaReader \
  -onlyUsePackageVersionsFromResolvedFile \
  -clonedSourcePackagesDirPath "$PWD/build/SourcePackages"
xcrun simctl list devices available --json > build/devices.json
SIMULATOR_ID=$(python3 scripts/select_simulator.py build/devices.json)
xcrun simctl bootstatus "$SIMULATOR_ID" -b
if [[ "$selection" == 'panels' || "$selection" == 'recovery' || "$selection" == 'settings-ui' ]]; then xcrun simctl ui "$SIMULATOR_ID" appearance dark; fi
if ps -axo pid,ppid,state,rss,comm > build/logs/processes-before-tests.log 2>&1; then :
else echo "Additional pre-test process context unavailable; original tests still run"; fi
test_status=0
if xcodebuild test -project XianxiaReader.xcodeproj -scheme XianxiaReader \
  -onlyUsePackageVersionsFromResolvedFile \
  -configuration Debug -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  -derivedDataPath "$PWD/build/DerivedData" \
  -clonedSourcePackagesDirPath "$PWD/build/SourcePackages" \
  -resultBundlePath "$PWD/build/DiagnosticTests.xcresult" \
  "${cases[@]}" CODE_SIGNING_ALLOWED=NO; then test_status=0; else test_status=$?; fi
summary_status=0
if xcrun xcresulttool get test-results summary --path build/DiagnosticTests.xcresult > build/test-results-summary.json; then
  summary_status=0
else summary_status=$?; fi
export_status=0
if xcrun xcresulttool export attachments --path build/DiagnosticTests.xcresult --output-path build/ReaderSnapshots; then
  export_status=0
else export_status=$?; fi
# Best-effort, bounded service context; no command arguments or book text.
# Missing/slow diagnostic tools are recorded, preserving the actual test exit.
if python3 - "$SIMULATOR_ID" <<'XR_CONTEXT'
from pathlib import Path
import json, subprocess, sys
folder=Path("build/logs");folder.mkdir(parents=True,exist_ok=True);records=[]
commands=[("processes-after-tests",["ps","-axo","pid,ppid,state,rss,comm"],10),
          ("reading-lifecycle",["xcrun","simctl","spawn",sys.argv[1],"log","show","--last","20m","--info","--style","compact","--predicate",'eventMessage BEGINSWITH "XRReadingLifecycle" OR eventMessage BEGINSWITH "XRPresentation"'],20),
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
echo "DIAGNOSTIC ONLY: $selection; test=$test_status summary=$summary_status export=$export_status; no device Release or IPA"
if (( test_status != 0 )); then exit "$test_status"; fi
if (( summary_status != 0 )); then exit "$summary_status"; fi
if (( export_status != 0 )); then exit "$export_status"; fi
