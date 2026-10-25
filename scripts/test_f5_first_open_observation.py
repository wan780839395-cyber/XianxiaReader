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
    text = without_wait_control_ui(text)
    if 'F5_FIRST_OPEN_ONLY' not in text:
        return text
    text = once(text, ENTRY_NEW, ENTRY_OLD)
    text = once(text, 'private func open(in app: XCUIApplication, observeFirstOpen: Bool = false)', 'private func open(in app: XCUIApplication)')
    text = once(text, BODY_NEW, BODY_OLD)
    return once(text, HELPER, '')


def without_first_open_driver(text):
    text = without_wait_control_driver(text)
    if '  f5-first-open)' not in text:
        return text
    text = once(text, ENV_GUARD, '')
    text = once(text, BRANCH, '')
    text = once(text, '"$selection" == \'f5-first-open\' || ', '')
    text = once(text, '# First-open evidence uses only the original test log and timeout attachments.\nif [[ "$selection" != \'f5-first-open\' ]]; then\n', '')
    return once(text, '# End first-open context exclusion.\nfi\n', '')


def without_first_open_workflow(text):
    text = without_existing_export_workflow(without_wait_control_workflow(text))
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
    if 'F5_WAIT_CONTROL ' in log:
        raise ValueError('Wait API controls cannot establish original first-open/body acceptance')
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



WAIT_CONTROL_HASHES = {'ui_config': '7894b543d5e66794b480ef2a023b4244a86fae1e69a21339874d0855be8e9904', 'ui_gate': 'bbf45882e8cab70a5f14b69ea8c38a1510676debf6b4fdd01849da1e4a9c5fd6', 'driver_guard': '3cbd57f1508311258b3aa0e551f0344de3f4878d28926c6c04c5ee5d7a7be4d9', 'driver_branch': '9683cbad5943d64b966085263a9aface7e58ddfcd6a0bdfb8f4b2b2768de9c6f', 'driver_pair': 'e5f87a264182d83f1fd738e4dc9a87e416aaef3a23ab7526a56ef4d1148b65a2'}
WAIT_GATE_OLD = '        let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: settings)\n        let readyResult = XCTWaiter.wait(for: [ready], timeout: 20)\n        let progress = app.descendants(matching: .any).matching(identifier: "reader.open.status").firstMatch\n        XCTAssertEqual(readyResult, .completed, progress.exists ? progress.label : "No opening status")\n'
EXISTING_EXPORT_TAIL_SHA = 'c04f266100bb82f066931b84123c810335005ae8b03784aed4267b9fddc7e441'

def without_control_block(text, name, kind, replacement=''):
    pattern = r'(?m)^[ \t]*(?://|#) F5_WAIT_CONTROL_' + name + r'_BEGIN\n[\s\S]*?^[ \t]*(?://|#) F5_WAIT_CONTROL_' + name + r'_END\n'
    matches = list(re.finditer(pattern, text))
    if not matches:
        return text
    if len(matches) != 1 or hashlib.sha256(matches[0].group().encode()).hexdigest() != WAIT_CONTROL_HASHES[kind]:
        raise ValueError('Control block missing/changed/duplicated: ' + name)
    return text[:matches[0].start()] + replacement + text[matches[0].end():]


def without_wait_control_ui(text):
    text = without_control_block(text, 'CONFIG', 'ui_config')
    return without_control_block(text, 'GATE', 'ui_gate', WAIT_GATE_OLD)


def without_wait_control_driver(text):
    for name in ('GUARD', 'BRANCH', 'PAIR'):
        text = without_control_block(text, name, 'driver_' + name.lower())
    return text


def without_wait_control_workflow(text):
    if ', f5-wait-api-control]' in text:
        text = once(text, ', f5-wait-api-control]', ']')
        text = once(text, '            build/F5WaitControl/\n', '')
    return text


def without_existing_export_workflow(text):
    # Preserve the original baseline hash. Remove only the exact published export addition.
    marker = '\n  existing-result-export:\n'
    if marker not in text:
        return text
    tail = text[text.index(marker):]
    if hashlib.sha256(tail.encode()).hexdigest() != EXISTING_EXPORT_TAIL_SHA:
        raise ValueError('Published export job changed')
    text = text[:text.index(marker)]
    text = once(text, ', xcresult-export]', ']')
    text = once(text, "    if: ${{ inputs.diagnostic_selection != 'xcresult-export' }}\n", '')
    prefix = "inputs.diagnostic_selection != 'xcresult-export' && "
    if text.count(prefix) != 2:
        raise ValueError('Published export exclusions changed')
    return text.replace(prefix, '')


def verify_wait_control_pair(folder):
    if json.loads((folder / 'build-status.json').read_text()) != {'build': 0}:
        raise ValueError('Both arms require the shared successful build')
    target, cls, method = SELECTOR.split('/')
    identity = target + '.' + cls + ' ' + method
    result = {}
    for api in ('predicate', 'property'):
        arm = folder / api
        exits = json.loads((arm / 'exits.json').read_text())
        if any(type(exits.get(key)) is not int or exits[key] < 0 for key in ('test', 'summary', 'export')):
            raise ValueError('Original numeric exits are required')
        if exits.get('api') != api or exits.get('summary') != 0 or exits.get('export') != 0:
            raise ValueError('Arm scope or evidence delivery failed')
        log = (arm / 'native.log').read_text(encoding='utf-8')
        events = re.findall(r"^Test Case '-\[([^\]]+)\]' (started\.|passed \([^\n]+\)\.|failed[^\n]*|skipped[^\n]*)$", log, re.M)
        passed = exits.get('test') == 0
        if (len(events) != 2 or [e[0] for e in events] != [identity, identity]
                or events[0][1] != 'started.'
                or not events[1][1].startswith('passed (' if passed else 'failed (')):
            raise ValueError('Each arm must execute the one original method, with no skip/retry')
        marker = 'F5_WAIT_CONTROL api=' + api + ' scope=settings-enabled-only targetSaveExecuted=false'
        if log.splitlines().count(marker) != 1 or log.splitlines().count(MARKER) != 1:
            raise ValueError('Wrong/missing runtime API or first-open-only marker')
        if 'F5_FIRST_OPEN_RESULT' in log:
            raise ValueError('Control arms must stop before the body wait')
        summary = json.loads((arm / 'summary.json').read_text())
        expected = dict(totalTestCount=1, passedTests=int(passed), failedTests=int(not passed), skippedTests=0)
        if any(type(summary.get(k)) is not int or summary[k] != v for k, v in expected.items()):
            raise ValueError('Arm xcresult counts do not match its original exit')
        if summary.get('result') != ('Passed' if passed else 'Failed'):
            raise ValueError('Arm summary result mismatch')
        failures = summary.get('testFailures')
        if not isinstance(failures, list) or bool(failures) == passed:
            raise ValueError('Failure evidence cannot be hidden')
        result[api] = dict(passed=passed, rawExit=exits['test'], started=1, skipped=0)
    return dict(scope='settings-enabled-wait-api-control', originalMethod=SELECTOR, arms=result,
                sharedBuildActions=1, independentTestActions=2, nativeProcessIDsVerified=False,
                bodyAccepted=False, targetSaveExecuted=False, fullF5Accepted=False,
                originalAcceptanceReplaced=False, systemCachesShared=True)


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


ORIGINAL_F5_METHOD_SHA = '1070e0cf46fb4c9f6fae3140782b3b291402e61e98041bd5c5517a00ad7f4250'

class F5WaitAPIControlTests(unittest.TestCase):
    @staticmethod
    def bash():
        import os, shutil
        value = Path(os.environ.get('ProgramFiles', 'C:/Program Files')) / 'Git/bin/bash.exe'
        return str(value) if value.is_file() else shutil.which('bash')

    def test_original_method_predicate_budget_and_no_extra_sampling(self):
        text = (ROOT / 'Tests/UI/ReadingExperienceUITests.swift').read_text(encoding='utf-8')
        start = text.index('    @MainActor func testFontCollectionGridSearchAndOptInLayoutPresetsPreserveSelection()')
        end = text.index('\n    }', start) + 6
        self.assertEqual(hashlib.sha256(text[start:end].encode()).hexdigest(), ORIGINAL_F5_METHOD_SHA)
        restored = without_wait_control_ui(text)
        self.assertIn(WAIT_GATE_OLD, restored)
        self.assertIn('settings.wait(for: \\.isEnabled, toEqual: true, timeout: 20)', text)
        self.assertIn('#if compiler(>=6.1)', text)
        config = text[text.index('// F5_WAIT_CONTROL_CONFIG_BEGIN'):text.index('// F5_WAIT_CONTROL_CONFIG_END')]
        gate = text[text.index('// F5_WAIT_CONTROL_GATE_BEGIN'):text.index('// F5_WAIT_CONTROL_GATE_END')]
        self.assertIn('guard observeFirstOpen', config)
        self.assertIn('if waitControl != nil { return }', gate)
        self.assertLess(text.index('if waitControl != nil { return }'), text.index('let texts = app.webViews'))
        for forbidden in ('debugDescription', 'screenshot()', 'sleep(', 'isHittable', 'try?', 'XCTSkip'):
            self.assertNotIn(forbidden, config + gate)
        start_code = text[text.index('private func start('):text.index('@MainActor private func book(')]
        self.assertIn('UUID().uuidString', start_code)
        self.assertIn('if fonts {', start_code)
        self.assertNotIn('XIANXIA_F5_WAIT_CONTROL', start_code)  # Runner only, identical App fixture inputs.
        lifecycle = (ROOT / 'Tests/UI/ReaderUITestCase.swift').read_text(encoding='utf-8')
        self.assertIn('if app.state != .notRunning { app.terminate() }', lifecycle)

    def test_pair_selection_and_workflow_are_narrow(self):
        from check_architecture import yaml
        workflow = yaml.load((ROOT / '.github/workflows/ios-build.yml').read_text(), Loader=yaml.BaseLoader)
        self.assertEqual(workflow['on']['workflow_dispatch']['inputs']['diagnostic_selection']['options'].count('f5-wait-api-control'), 1)
        self.assertEqual(workflow['jobs']['reading-diagnostic']['needs'], ['repository-checks', 'core-tests'])
        for name in ('ios', 'reader-positions', 'reader-logic', 'existing-result-export'):
            self.assertNotIn('f5-wait-api-control', workflow['jobs'][name]['if'])
        driver = (ROOT / 'scripts/ci_reader_diagnostic.sh').read_text()
        self.assertIn('-parallel-testing-enabled NO', driver)
        self.assertIn('for arm in predicate property; do', driver)
        self.assertIn('test-without-building "${shared_args[@]}"', driver)
        self.assertNotIn('retry-tests', driver)
        # Existing export scope is preserved exactly, rather than resetting old provenance hashes.
        self.assertIn('existing-result-export:', without_wait_control_workflow((ROOT / '.github/workflows/ios-build.yml').read_text()))

    def test_leaked_api_parameters_are_rejected_before_any_tools(self):
        import os, subprocess
        self.assertIsNotNone(self.bash())
        driver = (ROOT / 'scripts/ci_reader_diagnostic.sh').read_text()
        dispatch = driver[driver.index('selection='):driver.index('\nesac\n') + len('\nesac\n')]
        env = {k: v for k, v in os.environ.items() if k not in (KEY, 'TEST_RUNNER_' + KEY, 'XIANXIA_F5_WAIT_CONTROL', 'TEST_RUNNER_XIANXIA_F5_WAIT_CONTROL')}
        with tempfile.TemporaryDirectory() as directory:
            fixture = Path(directory) / 'selector.sh'
            fixture.write_text('set -euo pipefail\n' + dispatch + '\nprintf "%s\\n" "${cases[@]}"\n', newline='\n')
            for key in ('XIANXIA_F5_WAIT_CONTROL', 'TEST_RUNNER_XIANXIA_F5_WAIT_CONTROL'):
                run = subprocess.run([self.bash(), fixture.as_posix(), 'f5-wait-api-control'], env={**env, key: 'property'}, capture_output=True, timeout=15)
                self.assertEqual(run.returncode, 2, run.stderr.decode(errors='replace'))
            run = subprocess.run([self.bash(), fixture.as_posix(), 'f5-wait-api-control'], env=env, capture_output=True, timeout=15)
            self.assertEqual(run.returncode, 0, run.stderr.decode(errors='replace'))
            self.assertEqual(run.stdout.decode().splitlines(), ['-only-testing:' + SELECTOR])

    STUB = r"""
import json, os, sys
from pathlib import Path
kind, args = sys.argv[1], sys.argv[2:]
with open(os.environ['F5_STUB_TRACE'], 'a') as f:
    f.write(json.dumps(dict(kind=kind, args=args, api=os.environ.get('TEST_RUNNER_XIANXIA_F5_WAIT_CONTROL'))) + '\n')
if kind == 'xcodebuild':
    if args[0] == 'build-for-testing': sys.exit(77 if os.environ.get('F5_STUB_BUILD_FAIL') == '1' else 0)
    assert args[0] == 'test-without-building'
    api = os.environ['TEST_RUNNER_XIANXIA_F5_WAIT_CONTROL']
    assert api in ('predicate', 'property')
    failed = os.environ.get('F5_STUB_FAIL_ARM') == api
    identity = 'XianxiaReaderUITests.ReadingExperienceUITests testFontCollectionGridSearchAndOptInLayoutPresetsPreserveSelection'
    print("Test Case '-[" + identity + "]' started.")
    print('F5_FIRST_OPEN_ONLY targetSaveExecuted=false')
    print('F5_WAIT_CONTROL api=' + api + ' scope=settings-enabled-only targetSaveExecuted=false')
    print("Test Case '-[" + identity + "]' " + ('failed' if failed else 'passed') + ' (1.000 seconds).')
    sys.exit(65 if failed else 0)
assert kind == 'xcrun'
if args[0] == 'simctl': sys.exit(0)
assert args[:3] in (['xcresulttool','get','test-results'], ['xcresulttool','export','attachments'])
if args[1] == 'get':
    arm = Path(args[args.index('--path') + 1]).parent.name
    failed = os.environ.get('F5_STUB_FAIL_ARM') == arm
    print(json.dumps(dict(totalTestCount=1, passedTests=int(not failed), failedTests=int(failed), skippedTests=0, result='Failed' if failed else 'Passed', testFailures=[{'message':'controlled'}] if failed else [])))
else:
    Path(args[args.index('--output-path') + 1]).mkdir(parents=True)
"""

    def run_fake_pair(self, *, failed_arm='', build_failed=False, stale=False):
        import os, shutil, subprocess, sys
        driver = (ROOT / 'scripts/ci_reader_diagnostic.sh').read_text()
        block = re.search(r'(?ms)^# F5_WAIT_CONTROL_PAIR_BEGIN\n.*?^# F5_WAIT_CONTROL_PAIR_END\n', driver).group()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'scripts').mkdir()
            shutil.copyfile(__file__, root / 'scripts/test_f5_first_open_observation.py')
            stub = root / 'stub.py'; stub.write_text(self.STUB)
            fixture = root / 'pair.sh'
            prefix = ('set -euo pipefail\n'
                      'python3() { "$F5_PYTHON" "$@"; }\n'
                      'xcodebuild() { "$F5_PYTHON" "$F5_STUB" xcodebuild "$@"; }\n'
                      'xcrun() { "$F5_PYTHON" "$F5_STUB" xcrun "$@"; }\n'
                      'selection=f5-wait-api-control\nSIMULATOR_ID=controlled\n'
                      'export TEST_RUNNER_XIANXIA_F5_FIRST_OPEN_ONLY=1\n'
                      'cases=(-only-testing:' + SELECTOR + ')\n')
            fixture.write_text(prefix + block, newline='\n')
            if stale: (root / 'build/F5WaitControl').mkdir(parents=True)
            trace = root / 'trace.jsonl'
            env = {**os.environ, 'F5_PYTHON': sys.executable.replace('\\', '/'), 'F5_STUB': stub.as_posix(), 'F5_STUB_TRACE': str(trace), 'F5_STUB_FAIL_ARM': failed_arm, 'F5_STUB_BUILD_FAIL': str(int(build_failed))}
            run = subprocess.run([self.bash(), fixture.as_posix()], cwd=root, env=env, capture_output=True, timeout=25)
            calls = [json.loads(line) for line in trace.read_text().splitlines()] if trace.exists() else []
            receipt = root / 'build/F5WaitControl/pair-receipt.json'
            value = json.loads(receipt.read_text()) if receipt.exists() else None
            return run, calls, value

    def test_controlled_driver_builds_once_and_runs_two_independent_actions(self):
        run, calls, value = self.run_fake_pair()
        self.assertEqual(run.returncode, 0, run.stderr.decode(errors='replace'))
        native = [c for c in calls if c['kind'] == 'xcodebuild']
        self.assertEqual([c['args'][0] for c in native], ['build-for-testing', 'test-without-building', 'test-without-building'])
        self.assertEqual([c['api'] for c in native[1:]], ['predicate', 'property'])
        derived = [c['args'][c['args'].index('-derivedDataPath') + 1] for c in native]
        self.assertEqual(len(set(derived)), 1)
        self.assertTrue(all(c['args'].count('-only-testing:' + SELECTOR) == 1 for c in native))
        self.assertFalse(value['fullF5Accepted']); self.assertFalse(value['nativeProcessIDsVerified'])
        self.assertFalse(value['bodyAccepted']); self.assertTrue(value['systemCachesShared'])

    def test_controlled_first_arm_failure_is_preserved_without_retry(self):
        run, calls, value = self.run_fake_pair(failed_arm='predicate')
        self.assertEqual(run.returncode, 65, run.stderr.decode(errors='replace'))
        self.assertEqual([c['api'] for c in calls if c['kind'] == 'xcodebuild' and c['args'][0] == 'test-without-building'], ['predicate', 'property'])
        self.assertFalse(value['arms']['predicate']['passed']); self.assertTrue(value['arms']['property']['passed'])
        self.assertFalse(value['originalAcceptanceReplaced'])

    def test_controlled_build_failure_runs_neither_arm(self):
        run, calls, value = self.run_fake_pair(build_failed=True)
        self.assertEqual(run.returncode, 77, run.stderr.decode(errors='replace'))
        self.assertEqual(len([c for c in calls if c['kind'] == 'xcodebuild']), 1)
        self.assertIsNone(value)

    def test_controlled_existing_output_is_not_reused_or_rerun(self):
        run, calls, value = self.run_fake_pair(stale=True)
        self.assertEqual(run.returncode, 2)
        self.assertEqual(calls, []); self.assertIsNone(value)

    def test_control_receipt_refuses_skip_and_wrong_scope(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory); (folder / 'build-status.json').write_text('{"build":0}')
            identity = 'XianxiaReaderUITests.ReadingExperienceUITests testFontCollectionGridSearchAndOptInLayoutPresetsPreserveSelection'
            for api in ('predicate', 'property'):
                arm = folder / api; arm.mkdir()
                (arm / 'exits.json').write_text(json.dumps(dict(api=api, test=0, summary=0, export=0)))
                (arm / 'summary.json').write_text(json.dumps(dict(totalTestCount=1, passedTests=1, failedTests=0, skippedTests=0, result='Passed', testFailures=[])))
                (arm / 'native.log').write_text("Test Case '-[" + identity + "]' started.\n" + MARKER + '\nF5_WAIT_CONTROL api=' + api + " scope=settings-enabled-only targetSaveExecuted=false\nTest Case '-[" + identity + "]' passed (1.000 seconds).\n")
            self.assertFalse(verify_wait_control_pair(folder)['fullF5Accepted'])
            arm = folder / 'property'; original = (arm / 'summary.json').read_text()
            (arm / 'summary.json').write_text(original.replace('"skippedTests": 0', '"skippedTests": 1'))
            with self.assertRaises(ValueError): verify_wait_control_pair(folder)
            (arm / 'summary.json').write_text(original)
            original_exits = (arm / 'exits.json').read_text()
            for bad_exit in (None, False, -1):
                bad = json.loads(original_exits); bad['test'] = bad_exit
                (arm / 'exits.json').write_text(json.dumps(bad))
                with self.assertRaises(ValueError): verify_wait_control_pair(folder)
            (arm / 'exits.json').write_text(original_exits)
            log = (arm / 'native.log').read_text(); (arm / 'native.log').write_text(log.replace('api=property', 'api=predicate'))
            with self.assertRaises(ValueError): verify_wait_control_pair(folder)
            (arm / 'native.log').write_text(log + 'F5_FIRST_OPEN_RESULT raw=1 targetSaveExecuted=false\n')
            with self.assertRaises(ValueError): verify_wait_control_pair(folder)


if __name__ == '__main__':
    unittest.main()
