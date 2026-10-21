#!/bin/bash
# Foundation-only contracts; no App, Readium, simulator or packaging.
set -euo pipefail
cd "$(dirname "$0")/.."
output="${1:-build/ReaderSessions}"
if [[ -e "$output" ]]; then
  echo "Refusing to overwrite prior session evidence: $output" >&2
  exit 2
fi
mkdir -p "$output"
output="$(cd "$output" && pwd)"
swift --version | tee "$output/environment.log"
uname -s | tee -a "$output/environment.log"
swift package --package-path Packages/ReaderSessions show-dependencies --format json > "$output/dependencies.json"
swift test --package-path Packages/ReaderSessions --parallel \
  --xunit-output "$output/tests.xml" 2>&1 | tee "$output/tests.log"
python3 scripts/verify_reader_sessions.py logic "$output" --report "$output/receipt.json"
