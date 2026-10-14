#!/bin/bash
# Explicit first real resolution after replacing the remote package with our
# maintained local source. Never fabricate/edit Package.resolved pins.
set -euo pipefail
workspace_lock=XianxiaReader.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
cp Package.resolved build/Package.before-local-readium.resolved
xcodebuild -resolvePackageDependencies -project XianxiaReader.xcodeproj -scheme XianxiaReader \
  -clonedSourcePackagesDirPath "$PWD/build/SourcePackages"
cp "$workspace_lock" build/Package.resolved
python3 scripts/verify_readium_lock.py build/Package.resolved
cp build/Package.resolved Package.resolved
