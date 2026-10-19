#!/bin/bash
# Diagnostic experiment only. Keep both original exits; never package a device IPA.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/logs build/RecordingControl
test -d "${DEVELOPER_DIR:?Select Xcode 16.4}/Platforms/iPhoneOS.platform"
xcrun simctl list devices available --json > build/RecordingControl/devices.json
simulator_id=$(python3 scripts/select_simulator.py build/RecordingControl/devices.json)
xcrun simctl bootstatus "$simulator_id" -b
xcrun simctl ui "$simulator_id" appearance dark

video_pid=''
stop_control_recording() {
  if [[ -z "$video_pid" ]]; then return 0; fi
  local result=0
  if kill -INT "$video_pid"; then
    if wait "$video_pid"; then :; else result=$?; fi
  else
    if wait "$video_pid"; then result=1; else result=$?; fi
  fi
  video_pid=''
  return "$result"
}
trap 'stop_control_recording' EXIT

first_failure=0
for condition in recording-on recording-off; do
  destination="build/RecordingControl/$condition"
  mkdir "$destination"
  if [[ "$condition" == recording-on ]]; then
    xcrun simctl io "$simulator_id" recordVideo --codec=h264 "$PWD/$destination/background.mp4" > "$destination/recording.log" 2>&1 &
    video_pid=$!
  fi
  date -u '+%Y-%m-%dT%H:%M:%SZ' > "$destination/started.txt"
  echo "RECORDING_CONTROL BEGIN $condition selection=reader-session; identical tests and budgets; no retries"
  # Each invocation writes its own xcresult. DerivedData and locked packages
  # stay on this one runner; XCTest still performs its normal fixture cleanup.
  status=0
  if bash scripts/ci_reader_diagnostic.sh reader-session; then :; else status=$?; fi
  recording_status=0
  if stop_control_recording; then :; else recording_status=$?; fi
  if [[ "$condition" == recording-on && ! -s "$destination/background.mp4" ]]; then recording_status=1; fi
  date -u '+%Y-%m-%dT%H:%M:%SZ' > "$destination/finished.txt"
  printf '%s\n' "$status" > "$destination/diagnostic-exit.txt"
  printf '%s\n' "$recording_status" > "$destination/recording-exit.txt"
  # Preserve the first failure even if the second condition passes.
  if (( first_failure == 0 && status != 0 )); then first_failure=$status; fi
  if (( first_failure == 0 && recording_status != 0 )); then first_failure=$recording_status; fi
  for path in build/DiagnosticTests.xcresult build/ReaderSnapshots build/test-results-summary.json build/logs/native-resources.jsonl build/logs/processes-before-tests.log build/logs/processes-after-tests.log build/logs/additional-context.json build/logs/reading-lifecycle.log build/logs/document-services.log; do
    if [[ -e "$path" ]]; then mv "$path" "$destination/"; fi
  done
  echo "RECORDING_CONTROL END $condition diagnostic=$status recording=$recording_status"
done
echo "RECORDING_CONTROL original_first_failure=$first_failure; on/off order is a remaining warmup confound; no release acceptance"
exit "$first_failure"
