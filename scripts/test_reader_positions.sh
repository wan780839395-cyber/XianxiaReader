#!/bin/bash
# Isolated position contracts; no App host, Readium, simulator or packaging.
set -euo pipefail
cd "$(dirname "$0")/.."
output="${1:-build/ReaderPositions}"
if [[ -e "$output" ]]; then
  echo "Refusing to overwrite prior position evidence: $output; select a fresh output folder" >&2
  exit 2
fi
mkdir -p "$output"
output="$(cd "$output" && pwd)"
swift --version | tee "$output/environment.log"
uname -s | tee -a "$output/environment.log"
swift package --package-path Packages/XianxiaCore show-dependencies --format json > "$output/dependencies.json"
swift test --package-path Packages/XianxiaCore --parallel --filter ReaderPositionStateTests \
  --xunit-output "$output/tests.xml" 2>&1 | tee "$output/tests.log"
python3 scripts/verify_reader_positions.py logic "$output" --report "$output/receipt.json"
