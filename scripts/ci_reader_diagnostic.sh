#!/bin/bash
# Selected macOS diagnostics only. This script never builds or packages a device IPA.
# The default full ios-build.yml/ci_ios.sh pipeline remains the delivery gate.
set -euo pipefail
cd "$(dirname "$0")/.."
selection="${1:?Choose native-input, fonts or panels}"
case "$selection" in
  native-input)
    cases=(-only-testing:XianxiaReaderTests/ReaderSearchFieldTests)
    ;;
  fonts)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord
    )
    ;;
  panels)
    cases=(
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
if [[ "$selection" == 'panels' ]]; then xcrun simctl ui "$SIMULATOR_ID" appearance dark; fi
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
echo "DIAGNOSTIC ONLY: $selection; test=$test_status summary=$summary_status export=$export_status; no device Release or IPA"
if (( test_status != 0 )); then exit "$test_status"; fi
if (( summary_status != 0 )); then exit "$summary_status"; fi
if (( export_status != 0 )); then exit "$export_status"; fi
