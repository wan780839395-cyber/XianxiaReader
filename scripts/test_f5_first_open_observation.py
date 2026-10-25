"""Bounded F5 first-open observation. Never establishes the full F5 save flow."""
from pathlib import Path
import hashlib
import json
import math
import re
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SELECTION = 'f5-first-open'
KEY = 'XIANXIA_F5_FIRST_OPEN_ONLY'
SELECTOR = 'XianxiaReaderUITests/ReadingExperienceUITests/testFontCollectionGridSearchAndOptInLayoutPresetsPreserveSelection'
MARKER = 'F5_FIRST_OPEN_ONLY targetSaveExecuted=false'
ENV_GUARD = '''# F5 first-open scope may only be supplied by its explicit selection.
if [[ -n "${XIANXIA_F5_FIRST_OPEN_ONLY:-}" || -n "${TEST_RUNNER_XIANXIA_F5_FIRST_OPEN_ONLY:-}" ]]; then
  echo "F5 first-open override must come from the explicit selection" >&2; exit 2
fi
'''
BRANCH = '''  f5-first-open)
    cases=(-only-testing:''' + SELECTOR + ''')
    export TEST_RUNNER_XIANXIA_F5_FIRST_OPEN_ONLY=1
    ;;
'''
RECEIPT = '''          if [[ "$DIAGNOSTIC_SELECTION" == 'f5-first-open' ]]; then
            python3 - <<'F5_FIRST_OPEN_RECEIPT'
          from pathlib import Path
          import json, os, sys
          sys.path.insert(0, "scripts")
          from test_f5_first_open_observation import verify_first_open_success
          receipt = verify_first_open_success(Path("build"))
          receipt.update(source=os.environ["GITHUB_SHA"], nativeCompiled=True)
          Path("build/f5-first-open-receipt.json").write_text(json.dumps(receipt, indent=2) + "\\n")
          print("F5_FIRST_OPEN_RECEIPT " + json.dumps(receipt, sort_keys=True))
          F5_FIRST_OPEN_RECEIPT
          fi
'''
RECEIPT_PATH = '            build/f5-first-open-receipt.json\n'
FULL_GUARD = '# First-open diagnostic overrides are never valid in full validation.\nif [[ -n "${XIANXIA_F5_FIRST_OPEN_ONLY:-}" || -n "${TEST_RUNNER_XIANXIA_F5_FIRST_OPEN_ONLY:-}" ]]; then\n  echo "F5 first-open override is invalid in full validation" >&2; exit 2\nfi\n'
FULL_BASE_SHA = 'ed5c28bf4126981696a6690d09ab94e44ff7449d129e56e2ab91052f7a2f8a12'
ENTRY_OLD = '        let app = start(fonts: true); defer { app.terminate() }; open(in: app)\n'
ENTRY_NEW = '''        let app = start(fonts: true); defer { app.terminate() }
        let firstOpenOnly = ProcessInfo.processInfo.environment["XIANXIA_F5_FIRST_OPEN_ONLY"] == "1"
        if firstOpenOnly { print("F5_FIRST_OPEN_ONLY targetSaveExecuted=false") }
        open(in: app, observeFirstOpen: firstOpenOnly)
        if firstOpenOnly { return } // Diagnostic scope ends before settings/save; never full F5 acceptance.
'''
BODY_OLD = '''        let readable = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in texts.allElementsBoundByIndex.contains { $0.isHittable } }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [readable], timeout: 20), .completed)
'''
BODY_NEW = '''        if observeFirstOpen {
            let observation = F5FirstOpenObservation()
            let readable = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
                let began = ProcessInfo.processInfo.systemUptime
                let ordinal = observation.begin()
                let elements = texts.allElementsBoundByIndex
                let queryReturned = ProcessInfo.processInfo.systemUptime
                var evaluated = 0
                var firstHittable: Int?
                let value = elements.contains { element in
                    let hit = element.isHittable
                    if hit { firstHittable = evaluated }
                    evaluated += 1
                    return hit
                }
                observation.finish(ordinal: ordinal, began: began, queryReturned: queryReturned,
                                   ended: ProcessInfo.processInfo.systemUptime, count: elements.count,
                                   evaluated: evaluated, firstHittable: firstHittable, value: value)
                return value
            }, object: nil)
            let waitBegan = ProcessInfo.processInfo.systemUptime
            let result = XCTWaiter.wait(for: [readable], timeout: 20)
            let waitReturned = ProcessInfo.processInfo.systemUptime
            if result == .timedOut {
                var payload = observation.freeze()
                let screenshotBegan = ProcessInfo.processInfo.systemUptime
                let screenshot = XCUIScreen.main.screenshot()
                let screenshotReturned = ProcessInfo.processInfo.systemUptime
                let image = XCTAttachment(screenshot: screenshot)
                image.name = "f5-first-open-after-timeout"; image.lifetime = .keepAlways; add(image)
                payload["schemaVersion"] = 1
                payload["scope"] = "first-open-only"
                payload["targetSaveExecuted"] = false
                payload["waitResult"] = "timedOut"
                payload["timeoutSeconds"] = 20
                payload["waitBeganUptime"] = waitBegan
                payload["nominalDeadlineUptime"] = waitBegan + 20
                payload["waitReturnedUptime"] = waitReturned
                payload["screenshotBeganUptime"] = screenshotBegan
                payload["screenshotReturnedUptime"] = screenshotReturned
                payload["sameFrameClaim"] = false
                payload["screenshotTiming"] = "API interval after wait return; actual pixel presentation time unavailable"
                do {
                    let data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
                    let metadata = XCTAttachment(string: String(decoding: data, as: UTF8.self))
                    metadata.name = "f5-first-open-timeout-observation"; metadata.lifetime = .keepAlways; add(metadata)
                } catch {
                    let failure = XCTAttachment(string: "metadataEncodingFailed=true; original timedOut assertion retained")
                    failure.name = "f5-first-open-observation-error"; failure.lifetime = .keepAlways; add(failure)
                }
            }
            print("F5_FIRST_OPEN_RESULT raw=\\(result.rawValue) targetSaveExecuted=false")
            XCTAssertEqual(result, .completed)
        } else {
''' + BODY_OLD + '''        }
'''
HELPER = '''
// F5_FIRST_OPEN_OBSERVATION_HELPER_BEGIN
// Only primitive values from the original AX reads; one last sample, no body text/history.
private final class F5FirstOpenObservation {
    private let lock = NSLock()
    private var polls = 0
    private var inFlight = 0
    private var closed = false
    private var last: [String: Any] = [:]

    func begin() -> Int {
        lock.lock(); defer { lock.unlock() }
        polls += 1; inFlight += 1
        return polls
    }

    func finish(ordinal: Int, began: Double, queryReturned: Double, ended: Double,
                count: Int, evaluated: Int, firstHittable: Int?, value: Bool) {
        lock.lock(); defer { lock.unlock() }
        inFlight -= 1
        guard !closed else { return }
        last = ["ordinal": ordinal, "evaluationBeganUptime": began, "queryReturnedUptime": queryReturned,
                "evaluationEndedUptime": ended, "matchedCount": count, "evaluatedHittableCount": evaluated,
                "firstHittableIndex": firstHittable.map { $0 as Any } ?? NSNull(), "predicateResult": value]
    }

    func freeze() -> [String: Any] {
        lock.lock(); defer { lock.unlock() }
        closed = true
        return ["pollCount": polls, "evaluationsInFlightAtFreeze": inFlight, "lastCompletedEvaluation": last]
    }
}
// F5_FIRST_OPEN_OBSERVATION_HELPER_END
'''


def once(text, old, new):
    if text.count(old) != 1:
        raise ValueError('Named first-open block missing or duplicated')
    return text.replace(old, new, 1)


def without_first_open_ui(text):
    if 'F5_FIRST_OPEN_ONLY' not in text:
        return text
    text = once(text, ENTRY_NEW, ENTRY_OLD)
    text = once(text, 'private func open(in app: XCUIApplication, observeFirstOpen: Bool = false)', 'private func open(in app: XCUIApplication)')
    text = once(text, BODY_NEW, BODY_OLD)
    return once(text, HELPER, '')


def without_first_open_driver(text):
    if '  f5-first-open)' not in text:
        return text
    text = once(text, ENV_GUARD, '')
    text = once(text, BRANCH, '')
    text = once(text, '"$selection" == \'f5-first-open\' || ', '')
    text = once(text, '# First-open evidence uses only the original test log and timeout attachments.\nif [[ "$selection" != \'f5-first-open\' ]]; then\n', '')
    return once(text, '# End first-open context exclusion.\nfi\n', '')


def without_first_open_workflow(text):
    if ', f5-first-open]' not in text:
        return text
    text = once(text, ', f5-first-open]', ']')
    text = once(text, RECEIPT, '')
    return once(text, RECEIPT_PATH, '')


def validate_timeout_evidence(value):
    if (value.get('schemaVersion') != 1 or value.get('scope') != 'first-open-only'
            or value.get('targetSaveExecuted') is not False or value.get('sameFrameClaim') is not False
            or value.get('waitResult') != 'timedOut' or value.get('timeoutSeconds') != 20):
        raise ValueError('Wrong diagnostic scope, wait or frame claim')
    names = ['waitBeganUptime', 'nominalDeadlineUptime', 'waitReturnedUptime', 'screenshotBeganUptime', 'screenshotReturnedUptime']
    times = [value.get(name) for name in names]
    if any(type(t) not in (int, float) or not math.isfinite(t) or t < 0 for t in times):
        raise ValueError('Finite monotonic API times required')
    if not (times == sorted(times) and abs(times[1] - times[0] - 20) < 1e-6):
        raise ValueError('Screenshot must follow wait return; original budget remains 20')
    sample = value.get('lastCompletedEvaluation', {})
    if not sample or value.get('evaluationsInFlightAtFreeze') != 0:
        return dict(scope='first-open-only', targetSaveExecuted=False, correlation='insufficient: missing/in-flight AX evaluation', sameFrame=False)
    stamps = [sample.get(n) for n in ['evaluationBeganUptime', 'queryReturnedUptime', 'evaluationEndedUptime']]
    if any(type(t) not in (int, float) or not math.isfinite(t) for t in stamps) or stamps != sorted(stamps):
        raise ValueError('Invalid original AX interval')
    count, checked, first, result = (sample.get(k) for k in ['matchedCount', 'evaluatedHittableCount', 'firstHittableIndex', 'predicateResult'])
    if type(count) is not int or type(checked) is not int or not 0 <= checked <= count or type(result) is not bool:
        raise ValueError('Invalid original AX counts')
    if (result and (type(first) is not int or first != checked - 1 or checked == 0)) or (not result and (first is not None or checked != count)):
        raise ValueError('Original contains short-circuit result inconsistent')
    if not (times[0] <= stamps[0] <= stamps[-1] <= times[2]):
        return dict(scope='first-open-only', targetSaveExecuted=False, correlation='insufficient: AX result outside wait interval', sameFrame=False)
    return dict(scope='first-open-only', targetSaveExecuted=False, sameFrame=False,
                correlation='ordered AX and later screenshot API intervals only',
                matchedCount=count, evaluatedHittableCount=checked, firstHittableIndex=first, predicateResult=result,
                sampleAgeAtWaitReturn=times[2] - stamps[-1], screenshotDelayAfterWaitReturn=times[3] - times[2],
                screenshotCallDuration=times[4] - times[3])


def verify_first_open_success(folder):
    log = (folder / 'logs/reader-diagnostic.log').read_text(encoding='utf-8')
    target, cls, method = SELECTOR.split('/')
    prefix = "Test Case '-[" + target + '.' + cls + ' ' + method + "]' "
    events = re.findall(r"^Test Case '-\[([^\]]+)\]' (started\.|passed \([^\n]+\)\.|failed[^\n]*|skipped[^\n]*)$", log, re.M)
    if (len(events) != 2 or [e[0] for e in events] != [target+'.'+cls+' '+method] * 2
            or events[0][1] != 'started.' or not events[1][1].startswith('passed (')):
        raise ValueError('One original first-open invocation must pass; no skip/other case')
    if log.splitlines().count(MARKER) != 1 or log.splitlines().count('F5_FIRST_OPEN_RESULT raw=1 targetSaveExecuted=false') != 1:
        raise ValueError('The explicit first-open-only runner scope was not honored')
    if re.findall(r'^DIAGNOSTIC ONLY: f5-first-open; test=(\d+) summary=(\d+) export=(\d+); no device Release or IPA$', log, re.M) != [('0', '0', '0')]:
        raise ValueError('Original exits missing/nonzero')
    summary = json.loads((folder / 'test-results-summary.json').read_text(encoding='utf-8'))
    for key, expected in dict(totalTestCount=1, passedTests=1, failedTests=0, skippedTests=0).items():
        if type(summary.get(key)) is not int or summary[key] != expected:
            raise ValueError('Wrong first-open xcresult count')
    if summary.get('result') != 'Passed' or summary.get('testFailures') != []:
        raise ValueError('xcresult failure cannot be hidden')
    return dict(selection=SELECTION, scope='first-open-only', originalMethod=SELECTOR,
                firstOpenGatePassed=True, targetSaveExecuted=False, fullF5Accepted=False,
                timeoutScreenshotExpected=False, started=1, passed=1, failed=0, skipped=0)


class F5FirstOpenObservationTests(unittest.TestCase):
    def test_exact_inverse_preserves_published_ui_and_current_driver_workflow(self):
        files = [('Tests/UI/ReadingExperienceUITests.swift', without_first_open_ui, 'ff913cacba3decc2a880c716d5b09f6ea6bc6c5ecb5a6631011c751fc2b0d4cd'),
                 ('scripts/ci_reader_diagnostic.sh', without_first_open_driver, '7d3a279a77fbee7abb293f55e568d951559bbb1437af188dc89c2a507b62a1db'),
                 ('.github/workflows/ios-build.yml', without_first_open_workflow, None),
                 ('scripts/ci_ios.sh', lambda text: once(text, FULL_GUARD, ''), FULL_BASE_SHA)]
        for path, inverse, expected in files:
            text = (ROOT / path).read_text(encoding='utf-8')
            if expected is None:
                expected = WORKFLOW_BASE_SHA
            self.assertEqual(hashlib.sha256(inverse(text).encode()).hexdigest(), expected, path)

    def test_sampling_has_no_new_ax_reads_waits_or_body_data(self):
        text = (ROOT / 'Tests/UI/ReadingExperienceUITests.swift').read_text(encoding='utf-8')
        self.assertEqual(text.count(BODY_NEW), 1)
        self.assertEqual(text.count(HELPER), 1)
        observed = BODY_NEW.split('        } else {', 1)[0]
        for token in ('texts.allElementsBoundByIndex', 'element.isHittable', 'XCTWaiter.wait(for: [readable], timeout: 20)', 'XCUIScreen.main.screenshot()'):
            self.assertEqual(observed.count(token), 1)
        for token in ('.label', '.frame', '.exists', '.debugDescription', 'sleep(', 'Task ', 'await ', 'try?'):
            self.assertNotIn(token, observed + HELPER)
        self.assertLess(observed.index('if result == .timedOut'), observed.index('XCUIScreen.main.screenshot()'))
        self.assertIn('last = [', HELPER); self.assertNotIn('.append(', HELPER)
        self.assertIn('guard !closed else { return }', HELPER)
        self.assertNotIn('XCTFail(', observed)
        self.assertIn('metadataEncodingFailed=true; original timedOut assertion retained', observed)

    def evidence(self):
        return dict(schemaVersion=1, scope='first-open-only', targetSaveExecuted=False, sameFrameClaim=False,
                    waitResult='timedOut', timeoutSeconds=20, waitBeganUptime=100, nominalDeadlineUptime=120,
                    waitReturnedUptime=120.5, screenshotBeganUptime=120.51, screenshotReturnedUptime=122,
                    evaluationsInFlightAtFreeze=0, lastCompletedEvaluation=dict(evaluationBeganUptime=118,
                    queryReturnedUptime=119, evaluationEndedUptime=120, matchedCount=0,
                    evaluatedHittableCount=0, firstHittableIndex=None, predicateResult=False))

    def test_late_screenshot_and_inflight_or_late_ax_never_claim_same_frame(self):
        v = self.evidence(); result = validate_timeout_evidence(v)
        self.assertFalse(result['sameFrame']); self.assertEqual(result['sampleAgeAtWaitReturn'], .5)
        self.assertAlmostEqual(result['screenshotDelayAfterWaitReturn'], .01)
        for changed in (dict(v, evaluationsInFlightAtFreeze=1), dict(v, lastCompletedEvaluation={}),
                        dict(v, lastCompletedEvaluation=dict(v['lastCompletedEvaluation'], evaluationEndedUptime=121))):
            self.assertIn('insufficient', validate_timeout_evidence(changed)['correlation'])
        for changed in (dict(v, sameFrameClaim=True), dict(v, screenshotBeganUptime=119), dict(v, waitReturnedUptime=float('nan')),
                        dict(v, lastCompletedEvaluation=dict(v['lastCompletedEvaluation'], matchedCount=2))):
            with self.assertRaises(ValueError): validate_timeout_evidence(changed)

    def test_first_open_marker_cannot_be_accepted_as_full_f5(self):
        from test_f5_save_origin_ci import F5SaveOriginCITests, verify_f5_native
        with tempfile.TemporaryDirectory() as d:
            folder = Path(d); log, _ = F5SaveOriginCITests().fixture(folder)
            (folder / 'logs/reader-diagnostic.log').write_text(log + MARKER + '\n', encoding='utf-8')
            with self.assertRaises(ValueError): verify_f5_native(folder)

    def test_success_receipt_is_first_open_only_and_rejects_missing_scope_failure_skip_and_raw_exits(self):
        import os
        import subprocess
        import sys
        target, cls, method = SELECTOR.split('/')
        prefix = "Test Case '-[" + target + '.' + cls + ' ' + method + "]' "
        log = (prefix + 'started.\n' + MARKER + '\nF5_FIRST_OPEN_RESULT raw=1 targetSaveExecuted=false\n'
               + prefix + 'passed (1.000 seconds).\nDIAGNOSTIC ONLY: f5-first-open; test=0 summary=0 export=0; no device Release or IPA\n')
        summary = dict(result='Passed', totalTestCount=1, passedTests=1, failedTests=0, skippedTests=0, testFailures=[])
        with tempfile.TemporaryDirectory() as d:
            folder = Path(d) / 'build'; (folder / 'logs').mkdir(parents=True)
            path = folder / 'logs/reader-diagnostic.log'; path.write_text(log, encoding='utf-8')
            (folder / 'test-results-summary.json').write_text(json.dumps(summary), encoding='utf-8')
            result = verify_first_open_success(folder)
            self.assertFalse(result['fullF5Accepted']); self.assertFalse(result['targetSaveExecuted'])
            for bad in (log.replace(MARKER, ''), log + log, log.replace('passed (', 'failed ('),
                        log.replace('passed (1.000 seconds).', 'skipped (1.000 seconds).'), log.replace('test=0', 'test=65')):
                path.write_text(bad, encoding='utf-8')
                with self.assertRaises(ValueError): verify_first_open_success(folder)
            path.write_text(log, encoding='utf-8')
            body = RECEIPT.split("<<'F5_FIRST_OPEN_RECEIPT'\n", 1)[1].split('          F5_FIRST_OPEN_RECEIPT\n', 1)[0]
            body = '\n'.join(line[10:] for line in body.splitlines())
            run = subprocess.run([sys.executable, '-c', body], cwd=d,
                                 env={**os.environ, 'PYTHONPATH': str(ROOT / 'scripts'), 'GITHUB_SHA': '1' * 40},
                                 capture_output=True, timeout=20)
            self.assertEqual(run.returncode, 0, run.stderr.decode(errors='replace'))
            self.assertFalse(json.loads((folder / 'f5-first-open-receipt.json').read_text(encoding='utf-8'))['fullF5Accepted'])

    def test_selection_is_exact_dark_and_has_no_general_context_queries(self):
        from check_architecture import yaml
        driver = (ROOT / 'scripts/ci_reader_diagnostic.sh').read_text(encoding='utf-8')
        self.assertEqual(driver.count(BRANCH), 1); self.assertEqual(driver.count(ENV_GUARD), 1)
        self.assertIn('"$selection" == \'f5-first-open\' || "$selection" == \'f5-save-origin\'', driver)
        workflow = yaml.load((ROOT / '.github/workflows/ios-build.yml').read_text(encoding='utf-8'), Loader=yaml.BaseLoader)
        self.assertEqual(workflow['on']['workflow_dispatch']['inputs']['diagnostic_selection']['options'].count(SELECTION), 1)
        self.assertEqual(workflow['jobs']['reading-diagnostic']['needs'], ['repository-checks', 'core-tests'])
        for name in ('ios', 'reader-positions', 'reader-logic'):
            self.assertNotIn(SELECTION, workflow['jobs'][name]['if'])

    def test_real_shell_selects_one_original_method_and_rejects_leaked_overrides(self):
        import os
        import shutil
        import subprocess
        bash_path = Path(os.environ.get('ProgramFiles', 'C:/Program Files')) / 'Git/bin/bash.exe'
        bash = str(bash_path) if os.name == 'nt' and bash_path.is_file() else shutil.which('bash')
        self.assertIsNotNone(bash)
        driver = (ROOT / 'scripts/ci_reader_diagnostic.sh').read_text(encoding='utf-8')
        dispatch = driver[driver.index('selection='):driver.index('\nesac\n') + len('\nesac\n')]
        script = 'set -euo pipefail\n' + dispatch + '\nprintf "%s\\n" "${cases[@]}" "runner=${TEST_RUNNER_XIANXIA_F5_FIRST_OPEN_ONLY:-unset}"\n'
        env = {k: v for k, v in os.environ.items() if k not in (KEY, 'TEST_RUNNER_' + KEY)}
        with tempfile.TemporaryDirectory() as directory:
            fixture = Path(directory) / 'selector.sh'
            fixture.write_text(script, encoding='utf-8', newline='\n')
            for selection, wanted in ((SELECTION, '1'), ('f5-save-origin', 'unset')):
                result = subprocess.run([bash, fixture.as_posix(), selection], cwd=ROOT, env=env, capture_output=True, text=True, timeout=10)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout.splitlines(), ['-only-testing:' + SELECTOR, 'runner=' + wanted])
            for key in (KEY, 'TEST_RUNNER_' + KEY):
                result = subprocess.run([bash, fixture.as_posix(), SELECTION], cwd=ROOT, env={**env, key: '1'}, capture_output=True, text=True, timeout=10)
                self.assertEqual(result.returncode, 2, result.stderr)
                self.assertNotIn('-only-testing:', result.stdout)
            full = (ROOT / 'scripts/ci_ios.sh').read_text(encoding='utf-8')
            self.assertEqual(full.count(FULL_GUARD), 1)
            self.assertLess(full.index(FULL_GUARD), full.index('test -d'))
            fixture.write_text('set -euo pipefail\n' + FULL_GUARD + '\necho FULL_NOT_STARTED\n', encoding='utf-8', newline='\n')
            for key in (KEY, 'TEST_RUNNER_' + KEY):
                result = subprocess.run([bash, fixture.as_posix()], cwd=ROOT, env={**env, key: '1'}, capture_output=True, text=True, timeout=10)
                self.assertEqual(result.returncode, 2, result.stderr)
                self.assertNotIn('FULL_NOT_STARTED', result.stdout)


WORKFLOW_BASE_SHA = 'e1935b162493c150d0189e2017109f4e733cffcaf417a53eda844eb52a99c41a'

if __name__ == '__main__':
    unittest.main()
