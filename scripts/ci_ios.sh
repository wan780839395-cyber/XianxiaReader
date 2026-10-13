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

swift test --package-path Packages/XianxiaCore --parallel
xcodebuild -resolvePackageDependencies -project XianxiaReader.xcodeproj -scheme XianxiaReader \
  -onlyUsePackageVersionsFromResolvedFile \
  -clonedSourcePackagesDirPath "$PWD/build/SourcePackages"

# A simulator is selected by real availability, not a hardcoded device UUID/name.
xcrun simctl list devices available --json > build/devices.json
SIMULATOR_ID=$(python3 scripts/select_simulator.py build/devices.json)
test_status=0
if xcodebuild test -project XianxiaReader.xcodeproj -scheme XianxiaReader \
  -onlyUsePackageVersionsFromResolvedFile \
  -configuration Debug -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  -derivedDataPath "$PWD/build/DerivedData" \
  -clonedSourcePackagesDirPath "$PWD/build/SourcePackages" \
  -resultBundlePath "$PWD/build/SimulatorTests.xcresult" CODE_SIGNING_ALLOWED=NO; then
  test_status=0
else
  test_status=$?
fi

# Keep real WKWebView image snapshots from the rendering regressions for visual review.
export_status=0
if xcrun xcresulttool export attachments --path build/SimulatorTests.xcresult --output-path build/ReaderSnapshots; then
  export_status=0
else
  export_status=$?
fi
# Export failed-test screenshots too, then propagate the ORIGINAL test exit.
# A successful test with a failed export also fails, never producing an IPA.
echo "Simulator test exit: $test_status; attachment export exit: $export_status"
if (( test_status != 0 )); then exit "$test_status"; fi
if (( export_status != 0 )); then exit "$export_status"; fi

xcodebuild build -project XianxiaReader.xcodeproj -scheme XianxiaReader \
  -onlyUsePackageVersionsFromResolvedFile \
  -configuration Release -destination 'generic/platform=iOS' \
  -derivedDataPath "$PWD/build/DerivedData" \
  -clonedSourcePackagesDirPath "$PWD/build/SourcePackages" \
  -resultBundlePath "$PWD/build/DeviceBuild.xcresult" CODE_SIGNING_ALLOWED=NO

python3 scripts/package_ipa.py \
  build/DerivedData/Build/Products/Release-iphoneos/XianxiaReader.app build/XianxiaReader.ipa
shasum -a 256 build/XianxiaReader.ipa
