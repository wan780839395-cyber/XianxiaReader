#!/bin/bash
# macOS settings logic only. No XcodeGen, simulator, Readium or device packaging.
set -euo pipefail
cd "$(dirname "$0")/.."
test "$(uname -s)" = Darwin
output="${1:-build/ReaderLogic}"
if [[ -e "$output" ]]; then
  echo "Refusing to overwrite prior logic evidence: $output; select a fresh output folder" >&2
  exit 2
fi
mkdir -p "$output"
output="$(cd "$output" && pwd)"
xcodebuild -version | tee "$output/environment.log"
swift --version | tee -a "$output/environment.log"
sw_vers | tee -a "$output/environment.log"
swift package --package-path Packages/ReaderSettings show-dependencies --format json > "$output/dependencies.json"
swift test --package-path Packages/ReaderSettings --parallel \
  --xunit-output "$output/tests.xml" 2>&1 | tee "$output/tests.log"
python3 scripts/verify_reader_logic.py "$output/tests.xml" "$output/dependencies.json" --report "$output/receipt.json"
