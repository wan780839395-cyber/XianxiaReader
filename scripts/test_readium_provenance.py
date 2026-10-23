"""Reject accidental source and dependency drift in the maintained extension."""
import copy
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

from verify_readium_lock import ROOT, verify_lock
from verify_vendor import verify_vendor


def writer_body(text):
    """Execute the exact shipped DEBUG template, not a Python reimplementation."""
    return re.search(r'writerObservationBody = #"""\n(.*?)\n    """#', text, re.S).group(1)


def without_writer_body(text):
    return re.sub(r'    private static let writerObservationBody = #""".*?"""#\n', '', text, flags=re.S)


def swift_diagnostic_declaration(text, marker):
    """Extract these small helpers verbatim; none contains JS or brace literals."""
    start = text.index(marker)
    opening = text.index("{", start)
    depth = 1
    end = opening + 1
    while depth:
        depth += (text[end] == "{") - (text[end] == "}")
        end += 1
    return text[start:end]


def preparation_harness(test_source, sdk_source):
    # Real source bodies, with only the UIKit owner/protocol replaced by a sink.
    # This verifies synchronous helpers, not the iOS wiring or WK behavior.
    extracted = [swift_diagnostic_declaration(test_source, "@MainActor private final class ViewportPreparationTrace"),
                 swift_diagnostic_declaration(sdk_source, "@MainActor private final class EPUBInnerDiagnosticBuffer"),
                 swift_diagnostic_declaration(sdk_source, "public struct EPUBViewportFixtureEvent")]
    delivery = swift_diagnostic_declaration(sdk_source, "private func fixtureDeliverInnerDiagnostics(")
    return "import Foundation\n" + "\n".join(extracted) + r'''
@MainActor private protocol EPUBViewportFixtureControl: AnyObject {
    func observe(_ event: EPUBViewportFixtureEvent)
}
@MainActor private final class Sink: EPUBViewportFixtureControl {
    var events: [EPUBViewportFixtureEvent] = []
    func observe(_ event: EPUBViewportFixtureEvent) { events.append(event) }
}
@MainActor private final class Owner {
    var epoch = UUID()
''' + delivery + r'''
    func deliver(_ buffer: EPUBInnerDiagnosticBuffer, to sink: Sink) {
        fixtureDeliverInnerDiagnostics(buffer, to: sink, reason: "fixture-replaced")
    }
}
@main private struct Harness {
    @MainActor static func fail(_ trace: ViewportPreparationTrace, _ original: NSError) throws {
        defer { trace.cleanup("cleanUp") }
        do { trace.enter("cover-probe.javascript"); throw original }
        catch { trace.capture(error); throw error }
    }
    @MainActor static func main() async {
        let trace = ViewportPreparationTrace()
        let original = NSError(domain: "original-WK-error", code: 7)
        do { try fail(trace, original); preconditionFailure("error swallowed") }
        catch { precondition((error as NSError) === original) }
        let first = trace.firstError
        precondition(first?["errorDomain"] == "original-WK-error")
        precondition(first?["stage"] == "cover-probe.javascript")
        precondition(trace.firstCleanup?["stage"] == "cleanUp")
        precondition(Double(first!["caughtUptime"]!)! <= Double(trace.firstCleanup!["uptime"]!)!)
        trace.capture(CancellationError()); trace.enter("later"); trace.cleanup("again")
        precondition(trace.firstError == first && trace.firstCleanup?["stage"] == "cleanUp")
        let completed = ViewportPreparationTrace()
        completed.enter("ready"); completed.finish(); completed.capture(original)
        precondition(completed.firstError == nil)
        let cancelled = ViewportPreparationTrace()
        // Same actor: cancel before this parent yields, no sleep or timing window.
        let task = Task { @MainActor in
            defer { cancelled.cleanup("cancel-cleanup") }
            do { cancelled.enter("original-poll-sleep"); try Task.checkCancellation() }
            catch { cancelled.capture(error) }
        }
        task.cancel(); await task.value
        precondition(cancelled.firstError?["taskCancelled"] == "true")
        precondition(cancelled.firstCleanup?["taskCancelled"] == "true")
        let owner = Owner(), old = Sink(), new = Sink(), buffer = EPUBInnerDiagnosticBuffer()
        let epoch = owner.epoch.uuidString
        var input: [EPUBViewportFixtureEvent] = []
        for n in 0..<256 {
            let event = EPUBViewportFixtureEvent(requestID: UUID(), kind: "sample-read-inner", values: ["epoch":epoch,"n":String(n)])
            input.append(event); precondition(buffer.store(event))
        }
        owner.deliver(buffer, to: old)
        precondition(old.events.count == 256 && new.events.isEmpty && buffer.events.isEmpty)
        precondition(old.events[0].values["preArmDropped"] == "1")
        precondition(old.events[0].values["incomplete"] == "true")
        precondition(old.events[0].values["epoch"] == epoch)
        precondition(Array(old.events.dropFirst()).map(\.requestID) == Array(input.dropFirst()).map(\.requestID))
        owner.epoch = UUID(); owner.deliver(buffer, to: new); owner.deliver(buffer, to: old)
        precondition(old.events.count == 256 && new.events.isEmpty)
        precondition(!buffer.store(input[0]))
        let empty = EPUBInnerDiagnosticBuffer()
        precondition(empty.take()?.events.isEmpty == true && empty.take() == nil)
        print("PREPARATION_SWIFT_HELPERS_PASS original-error/cancel/first-only/complete/255/old-sink/one-drain")
    }
}
'''


def layout_sample_harness(source, legacy=False):
    """Actual Release S/cache and M expressions; UIKit/WK are explicit test doubles."""
    release = release_source(source)
    helper = swift_diagnostic_declaration(release, 'private struct EPUBSamplingLayout')
    sample = swift_diagnostic_declaration(release, 'func firstVisibleElementLocator()')
    if legacy:
        sample = sample.replace('        let layoutGeneration = samplingLayout.generation\n', '')
        sample = sample.replace('        let layoutSize = samplingViewportSize\n', '')
        sample = sample.replace('            guard samplingLayout.matches(layoutGeneration, size: layoutSize, currentSize: samplingViewportSize) else {\n                return nil\n            }\n', '')
        # Exact frozen 050c2b2 Release S, not a replacement implementation.
        assert hashlib.sha256(sample.encode()).hexdigest() == '25a2496ca7fdb22fb6e50cff1dddba503439ca26e78d5ef9c54981a5f654d85e'
    cache = swift_diagnostic_declaration(release, 'private func savedAnchorMatchesViewport(')
    measure = release.split('private func measure(', 1)[1].split('override func layoutSubviews()', 1)[0]
    start = measure.index('            let mayRestoreAnchor =')
    expressions = measure[start:measure.index('            recordReflow(', start)]
    owner = re.search(r'guard epoch == request, slots\[index\] === slot else', measure).group(0)
    size = swift_diagnostic_declaration(release, 'private var samplingViewportSize:')
    return 'import Foundation\n' + helper + r'''
private struct Number: Equatable { let double: Double? }
private struct Locations: Equatable { var otherLocations: [String: Number] = ["xianxiaViewportOffset":Number(double:-3.125)] }
private struct Locator: Equatable { let word: Int; var locations = Locations() }
private struct Snapshot { let locator: Locator; let documentY: CGFloat; let documentTop: CGFloat }
@MainActor private final class View {
    var frame = CGRect(x:0,y:0,width:402,height:778)
    var pending: CheckedContinuation<Snapshot?, Never>?
    var entered: CheckedContinuation<Void, Never>?
    func continuousVisibleAnchorSnapshot(visibleTop: CGFloat, visibleBottom: CGFloat) async -> Snapshot? {
        await withCheckedContinuation { continuation in
            pending = continuation; entered?.resume(); entered = nil
        }
    }
    func waitForRead() async {
        if pending != nil { return }
        await withCheckedContinuation { entered = $0 }
    }
    func finish(_ snapshot: Snapshot) { let c = pending; pending = nil; c!.resume(returning:snapshot) }
}
@MainActor private final class Slot {
    let view = View(); let wrapper = View()
    var ready = true, positioning = false
    var height: CGFloat = 9000
    var anchorRevision: UInt64?, anchorViewportTop: CGFloat?, anchorDocumentY: CGFloat?
    var savedAnchor: Locator?; var anchorDiagnostic = ""
    init() { view.frame.origin.y = 2367 }
}
@MainActor private final class Label { var text: String? }
@MainActor private final class Reader {
    var epoch = UUID(), currentIndex = 1
    var slots: [Int: Slot] = [1:Slot()]
    var bounds = CGRect(x:0,y:0,width:402,height:778)
    var viewportHeight: CGFloat = 778, viewportTop: CGFloat = 2367
    var viewportRevision: UInt64 = 2
    var automaticScrolling = false
    var samplingLayout = EPUBSamplingLayout()
    let boundaryLabel = Label()
    init() { samplingLayout.update(samplingViewportSize) }
''' + size + '\n' + sample + '\n' + cache + r'''
    func resize(_ width: CGFloat, _ height: CGFloat, observeLayout: Bool = true) {
        bounds.size = CGSize(width:width,height:height); viewportHeight = height
        if observeLayout { samplingLayout.update(samplingViewportSize) }
    }
    func restore(_ slot: Slot, request: UUID, measuredAnchor: Locator?, measuredRevision: UInt64,
                 measuredLocalTop: CGFloat, newAnchorY: CGFloat?) -> CGFloat? {
        let index = 1, measuredAnchorIsCurrent = true
''' + owner + ' { return nil }\n' + expressions + r'''
        return desiredLocal
    }
}
@main private struct Harness {
    @MainActor static func main() async {
        let baseline = CommandLine.arguments.contains("--baseline")
        let original = Locator(word:499), newer = Locator(word:818)
        for scenario in ["same", "same-layout-pass", "resize", "ABA", "pending-layout", "scroll", "physical-scroll", "navigation", "new-layout"] {
            let reader = Reader()
            if scenario == "new-layout" { reader.resize(874,306) }
            let slot = reader.slots[1]!, request = reader.epoch
            let task = Task { @MainActor in await reader.firstVisibleElementLocator() }
            await slot.view.waitForRead()
            // Equivalent to the separate original capture while old S is held.
            slot.savedAnchor = original; slot.anchorRevision = 2; slot.anchorViewportTop = 2367
            switch scenario {
            case "resize": reader.resize(874,306)
            case "ABA": reader.resize(874,306); reader.resize(402,778)
            case "pending-layout": reader.resize(874,306,observeLayout:false)
            case "same-layout-pass": reader.resize(402,778)
            case "scroll": reader.viewportRevision = 3; reader.viewportTop += 600
            case "physical-scroll": reader.viewportTop += 600
            case "navigation": reader.epoch = UUID()
            default: break
            }
            slot.view.finish(Snapshot(locator:newer,documentY:3000,documentTop:2367))
            let returned = await task.value
            let dimensionsChanged = ["resize","ABA","pending-layout"].contains(scenario)
            let normal = ["same","same-layout-pass","new-layout"].contains(scenario) || (baseline && dimensionsChanged)
            precondition(returned == (normal ? newer : nil), "S terminal: " + scenario)
            precondition(slot.savedAnchor == (normal ? newer : original), "cache: " + scenario)
            let desired = reader.restore(slot,request:request,measuredAnchor:original,measuredRevision:2,
                                         measuredLocalTop:2367,newAnchorY:2147.875)
            let mustRestore = !baseline && dimensionsChanged
            precondition((desired != nil) == mustRestore, "M guard: " + scenario)
            if scenario == "resize", !baseline {
                precondition(desired == 2151 && 2147.875 - desired! == -3.125)
                precondition(slot.savedAnchor?.word == 499)
            }
            print("LAYOUT_SAMPLE_CASE " + (baseline ? "baseline " : "fixed ") + scenario
                  + " returnedNew=" + String(returned == newer) + " preserved=" + String(slot.savedAnchor == original)
                  + " restore=" + String(desired != nil))
        }
        print(baseline ? "LAYOUT_SAMPLE_BASELINE_CONFIRMED" : "LAYOUT_SAMPLE_SWIFT_PASS actual-S/cache/M-expressions; UIKit-WK-unverified")
    }
}
'''


def release_source(text):
    """Select DEBUG=false; these three EPUB files have only DEBUG conditionals."""
    live = [True]
    rows = []
    for row in text.splitlines():
        value = row.strip()
        if value == "#if DEBUG":
            live.append(False)
        elif value == "#else":
            live[-1] = not live[-1]
        elif value == "#endif":
            live.pop()
        elif value.startswith(("#if ", "#elseif ")):
            raise ValueError("Review new conditional before updating this source contract")
        elif all(live) and value:
            # Two unused nil slots follow the pre-existing viewportFixtureStorage
            # pattern. Release has no typed installer, accesses or mutations.
            if value not in ["private var innerScrollDiagnosticStorage: AnyObject?",
                             "private var fixtureInnerDiagnosticStorage: AnyObject?",
                             "// Nil opaque storage in Release; all access/installers are DEBUG-only."]:
                rows.append(row.rstrip())
    if live != [True]:
        raise ValueError("Unbalanced diagnostic conditionals")
    return "\n".join(rows)


class ReadiumProvenanceTests(unittest.TestCase):
    def setUp(self):
        self.pins = json.loads((ROOT / "Vendor/ReadiumToolkit/UPSTREAM.json").read_text())["remoteDependencyPins"]

    def test_layout_generation_actual_sample_and_restore_behavior(self):
        import uuid
        source = self.inner_sources()['EPUBInfiniteScrollView.swift']
        generated = layout_sample_harness(source)
        baseline_generated = layout_sample_harness(source, legacy=True)
        folder = ROOT / '.cache/layout-sample'
        folder.mkdir(parents=True, exist_ok=True)
        harness = folder / 'harness.swift'
        harness.write_text(generated, encoding='utf-8', newline='\n')
        baseline = folder / 'baseline.swift'
        baseline.write_text(baseline_generated, encoding='utf-8', newline='\n')
        record = dict(kind='actual-Release-S-and-M-expressions-with-Foundation-doubles',
                      harnessSHA256=hashlib.sha256(generated.encode()).hexdigest(),
                      baselineHarnessSHA256=hashlib.sha256(baseline_generated.encode()).hexdigest(),
                      executed=False, passed=False, nativeCompiled=False)
        receipt = folder / 'behavior.json'
        receipt.write_text(json.dumps(record, indent=2) + '\n', encoding='utf-8')
        compiler = shutil.which('swiftc')
        if compiler:
            baseline_executable = folder / 'baseline.exe'
            old_compile = subprocess.run([compiler, '-swift-version', '6', '-parse-as-library', str(baseline), '-o', str(baseline_executable)], capture_output=True, text=True, encoding='utf-8', timeout=60)
            record.update(baselineCompileExit=old_compile.returncode, baselineCompileLog=old_compile.stdout + old_compile.stderr)
            receipt.write_text(json.dumps(record, indent=2) + '\n', encoding='utf-8')
            self.assertEqual(old_compile.returncode, 0, record['baselineCompileLog'])
            old_run = subprocess.run([str(baseline_executable), '--baseline'], capture_output=True, text=True, encoding='utf-8', timeout=30)
            record.update(baselineExit=old_run.returncode, baselineLog=old_run.stdout + old_run.stderr)
            self.assertEqual(old_run.returncode, 0, record['baselineLog'])
            self.assertIn('LAYOUT_SAMPLE_BASELINE_CONFIRMED', old_run.stdout)
            executable = folder / 'harness.exe'
            args = [compiler, '-swift-version', '6', '-parse-as-library', str(harness), '-o', str(executable)]
            compiled = subprocess.run(args, capture_output=True, text=True, encoding='utf-8', timeout=60)
            record.update(compileExit=compiled.returncode, compileLog=compiled.stdout + compiled.stderr)
            receipt.write_text(json.dumps(record, indent=2) + '\n', encoding='utf-8')
            self.assertEqual(compiled.returncode, 0, record['compileLog'])
            args = [str(executable)]
        else:
            image = 'swift@sha256:1122c18e938491180820e9b4902c489dadd5a89f7e6bd99ff9b64e7f1b18f41f'
            docker = shutil.which('docker')
            if not docker:
                self.skipTest('No existing Swift compiler/Docker; actual layout behavior unexecuted')
            inspected = subprocess.run([docker, 'image', 'inspect', image], capture_output=True, timeout=20)
            if inspected.returncode:
                record['environmentError'] = inspected.stderr.decode(errors='replace')
                receipt.write_text(json.dumps(record, indent=2) + '\n', encoding='utf-8')
                self.skipTest('Locked cached image/engine unavailable; no pull or installation')
            cached_image = json.loads(inspected.stdout)[0]
            record['imageID'] = cached_image['Id']
            record['imageRepoDigests'] = cached_image.get('RepoDigests', [])
            cid = folder / ('container-' + uuid.uuid4().hex + '.txt')
            args = [docker, 'run', '--pull=never', '--network=none', '--platform', 'linux/amd64',
                    '--cidfile', str(cid), '--mount', f'type=bind,source={folder},target=/fixture,readonly',
                    image, 'bash', '-lc', 'set -euo pipefail\nswiftc --version\n'
                    'swiftc -swift-version 6 -parse-as-library /fixture/baseline.swift -o /tmp/layout-baseline\n/tmp/layout-baseline --baseline\n'
                    'swiftc -swift-version 6 -parse-as-library /fixture/harness.swift -o /tmp/layout-harness\n/tmp/layout-harness\n']
        result = subprocess.run(args, capture_output=True, text=True, encoding='utf-8', timeout=90)
        record.update(command=args, executed=True, realExit=result.returncode,
                      passed=result.returncode == 0, stdout=result.stdout, stderr=result.stderr)
        receipt.write_text(json.dumps(record, indent=2) + '\n', encoding='utf-8')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('LAYOUT_SAMPLE_SWIFT_PASS', result.stdout)
        if not compiler:
            self.assertIn('LAYOUT_SAMPLE_BASELINE_CONFIRMED', result.stdout)

    def test_layout_generation_preserves_measure_and_original_sampling_contracts(self):
        source = self.inner_sources()['EPUBInfiniteScrollView.swift']
        measure = source.split('    private func measure(', 1)[1].split('    override func layoutSubviews()', 1)[0]
        self.assertEqual(hashlib.sha256(measure.encode()).hexdigest(), 'ca3050402bf2b21effbd565bde72f94c8d65cc59fc73beeac1b0bd3274bee798')
        layout = source.split('override func layoutSubviews()', 1)[1].split('private func layoutSlots', 1)[0]
        self.assertLess(layout.index('samplingLayout.update(samplingViewportSize)'), layout.index('guard !layingOut'))
        self.assertNotIn('viewportRevision &+=', layout)
        sample = swift_diagnostic_declaration(release_source(source), 'func firstVisibleElementLocator()')
        self.assertLess(sample.index('let layoutGeneration ='), sample.index('await slot.view.continuousVisibleAnchorSnapshot'))
        guard = 'guard samplingLayout.matches(layoutGeneration, size: layoutSize, currentSize: samplingViewportSize)'
        self.assertLess(sample.index('await slot.view.continuousVisibleAnchorSnapshot'), sample.index(guard))
        self.assertLess(sample.index(guard), sample.index('slot.anchorRevision = revision'))
        self.assertIn('viewportRevision == revision && abs(viewportTop - slot.wrapper.frame.minY - localTop) < 0.5', sample)
        self.assertIn('epoch == request, currentIndex == index, slots[index] === slot', sample)
        self.assertIn('for attempt in 0..<3', sample)
        self.assertEqual(sample.count('Task.sleep(nanoseconds: 32_000_000)'), 1)
        # Reverse only the new guard/captures and require the exact old Release S.
        self.assertIn('LAYOUT_SAMPLE_BASELINE_CONFIRMED', layout_sample_harness(source, legacy=True))

    def lock(self, pins, allow_upstream=False):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Package.resolved"
            path.write_text(json.dumps({"pins": pins}))
            return verify_lock(path, allow_upstream=allow_upstream)

    def test_fixed_spread_evaluator_signature_and_observer_forwarding(self):
        # A narrow source contract, not Swift type checking. Defaults must not
        # hide the two-argument override regression from CI39908431098.
        folder = ROOT / "Vendor/ReadiumToolkit/Sources/Navigator/EPUB"
        parent = (folder / "EPUBSpreadView.swift").read_text(encoding="utf-8")
        child = (folder / "EPUBFixedSpreadView.swift").read_text(encoding="utf-8")
        pattern = r"\bfunc evaluateScript\((.*?)\)\s+async\s*->"

        def matches(base, override):
            signatures = [re.search(pattern, text, re.S) for text in [base, override]]
            if not all(signatures):
                return False
            params = [re.sub(r"\s+", "", m.group(1)) for m in signatures]
            forwarded = re.findall(r"return\s+await\s+super\.evaluateScript\(\s*script\s*,\s*"
                                   r"fixtureReadObserver:\s*fixtureReadObserver\s*\)", override)
            return params[0] == params[1] and len(forwarded) == 1

        self.assertTrue(matches(parent, child), "FixedSpread override/observer must match the superclass")
        signature = re.search(pattern, child, re.S).group(1)
        old_signature = re.sub(r",\s*fixtureReadObserver:.*", "", signature, flags=re.S)
        mutations = [child.replace(signature, old_signature, 1),
                     child.replace("[String: Double]", "[String: String]", 1),
                     child.replace("fixtureReadObserver:", "readObserver:", 1),
                     child.replace("fixtureReadObserver: fixtureReadObserver", "fixtureReadObserver: nil", 1)]
        for changed in mutations:
            with self.subTest(variant=changed):
                self.assertFalse(matches(parent, changed))

    def inner_sources(self):
        folder = ROOT / "Vendor/ReadiumToolkit/Sources/Navigator/EPUB"
        return {name: (folder / name).read_text(encoding="utf-8") for name in [
            "EPUBSpreadView.swift", "EPUBReflowableSpreadView.swift", "EPUBInfiniteScrollView.swift"]}

    def test_inner_diagnostics_preserve_release_and_embedded_js(self):
        # Baseline 3bb3ef43. Intentional production/JS changes require a new
        # reviewed contract; passing this check is not native compilation.
        expected = {'EPUBSpreadView.swift': {'release': 'd79a01c99e5db34ba8b9e5e87729aad8da23619f53f79285fea594db546fb043', 'js': '24360e6a630a6ba33fb73d5be413a0fc7ab7a5645b689e4eb12552c81eab97f3', 'awaits': '838acea36ee3ecadcffb7cc7fa3c958a1a50a2b8bdce77c503ce87b318670be8'}, 'EPUBReflowableSpreadView.swift': {'release': '2daeba600700a62ba06fb2aac79920e8aacf68891936ed17cc434a3d9dff46ed', 'js': 'bbe1d6418414ec65dcaedd227261be1e8444a1cdeae27c00941c8c64f482b541', 'awaits': 'f9b28569ff9c4eb31320e3d74143b688d97826d9c1b1ced202e0f597fd5d3261'}, 'EPUBInfiniteScrollView.swift': {'release': '0aebd46a3813dc75c5f7db1f2bca0a7559b861245411fecb5a0f58fe23ad2bd8', 'js': '2abb959598e79a25c3c7176b7b3369e2a1235dd1456ebbc7e8019b722d0df00d', 'awaits': '184f24176cf7e255fcd0425a0fb5b8592a12b8540133562bea0db4bed3d4713d'}}
        self.assertEqual(len(expected), 3)
        for name, text in self.inner_sources().items():
            with self.subTest(file=name):
                protected = release_source(text).encode()
                # The only Release text difference is two explicit value aliases.
                # This avoids Swift shadow/capture ambiguity in the DEBUG closure.
                if name == "EPUBSpreadView.swift":
                    release = protected.decode()
                    self.assertIn("let submittedScript = script", release)
                    self.assertIn("let businessResult = res", release)
                    release = release.replace("                let submittedScript = script\n", "")
                    release = release.replace("                    let businessResult = res\n", "")
                    release = release.replace("evaluateJavaScript(submittedScript)", "evaluateJavaScript(script)")
                    release = release.replace(".success(businessResult ?? ())", ".success(res ?? ())")
                    protected = release.encode()
                self.assertEqual(hashlib.sha256(protected).hexdigest(), expected[name]["release"])
                literals = re.findall(r'"""(.*?)"""', without_writer_body(text), re.S)
                self.assertEqual(hashlib.sha256(json.dumps(literals).encode()).hexdigest(), expected[name]["js"])
                awaits = re.findall(r"\bawait\s+([A-Za-z_][A-Za-z0-9_?.]*)", without_writer_body(text))
                self.assertEqual(hashlib.sha256(json.dumps(awaits).encode()).hexdigest(), expected[name]["awaits"])
                altered = release_source(text).replace("guard ", "guard false, ", 1)
                self.assertNotEqual(hashlib.sha256(altered.encode()).hexdigest(), expected[name]["release"])

    def test_inner_evaluator_and_cancellation_receipt_order(self):
        base = self.inner_sources()["EPUBSpreadView.swift"]
        evaluator = base.split("    func evaluateScript(", 1)[1].split("    /// Called from the JS code", 1)[0]
        markers = ["enterEvaluation(script)", "await spreadLoaded()", "guard !wasCleared, !Task.isCancelled",
                   'fixtureReadObserver?("js-submit"', "submitEvaluation(evaluationID)",
                   "webView.evaluateJavaScript(submittedScript)", 'fixtureReadObserver("js-callback"',
                   "finishEvaluation(evaluationID, error: error)", "continuation.resume(returning: .failure(error))",
                   "continuation.resume(returning: .success(businessResult ?? ()))"]

        def ordered(text):
            positions = [text.find(value) for value in markers]
            return min(positions) >= 0 and positions == sorted(positions) and text.count("continuation.resume(") == 2

        self.assertTrue(ordered(evaluator))
        self.assertFalse(ordered(evaluator.replace("submitEvaluation(evaluationID)", "finishEvaluation(evaluationID)", 1)))
        self.assertIn("defer {\n                if !diagnosticSubmitted", evaluator)
        self.assertIn("cancelEvaluation(evaluationID)", evaluator)
        helper = base.split("@MainActor final class EPUBInnerScrollDiagnostics", 1)[1].split("extension EPUBSpreadView", 1)[0]
        swift_helper = without_writer_body(helper)
        self.assertNotRegex(swift_helper, r"\b(?:await\s+\w|Task\s*\{|evaluateJavaScript|setContentOffset|layoutIfNeeded)\b")
        self.assertNotRegex(helper, r"contentOffset\s*(?:\.[xy])?\s*=")
        close = helper.split("func close(", 1)[1].split("func record(", 1)[0]
        self.assertLess(close.index("active = false"), close.index('emit("coverage-end"'))
        self.assertIn("evaluations.removeAll(); writers.removeAll()", close)
        self.assertIn("view = nil", close)
        self.assertIn("recordLateEvaluation(id", helper)
        self.assertIn("Thread.callStackSymbols.prefix(16)", helper)
        self.assertIn("previousY - y > 0.5, !capturedRollback", helper)

    def run_writer_js(self, case):
        node = shutil.which("node")
        self.assertIsNotNone(node, "Node is required; source checks do not replace JS semantic execution")
        body = writer_body(self.inner_sources()["EPUBSpreadView.swift"])
        common = r"""
const assert = require('node:assert/strict');
const vm = require('node:vm');
const payload = JSON.parse(require('node:fs').readFileSync(0, 'utf8'));
const setup = `
  let tick = 0;
  globalThis.performance = {now: () => ++tick};
  globalThis.window = {scrollY: 0};
  globalThis.document = {scrollingElement: null};
  function fixture(method, own = false, flags = {}) {
    const proto = {scrollTo: method}, root = Object.create(proto);
    root.scrollTop = 0;
    if (own) Object.defineProperty(root, 'scrollTo',
      {value: method, configurable: true, enumerable: true, writable: true, ...flags});
    document.scrollingElement = root;
    return root;
  }
  const options = () => ({left: 0, top: 1767, behavior: 'instant'});
  const observe = ${payload.body};
`;
vm.runInNewContext(setup + payload.case, {assert}, {timeout: 3000});
process.stdout.write('ok');
"""
        result = subprocess.run([node, "-e", common], input=json.dumps({"body": body, "case": case}),
                                capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "ok")

    def test_writer_forwarding_identity_values_and_descriptor_restoration(self):
        self.run_writer_js(r"""
for (const own of [false, true]) for (const writable of [false, true])
for (const value of [true, false, undefined, null, 8.5, 'original']) {
  const args = options(); let count = 0;
  const method = function(...received) {
    ++count; assert.equal(this, root); assert.equal(received.length, 1);
    assert.equal(received[0], args); this.scrollTop = args.top; window.scrollY = args.top;
    return 'method-value';
  };
  const root = fixture(method, own, {writable});
  const before = Object.getOwnPropertyDescriptor(root, 'scrollTo');
  const report = observe('eval', 'coverage', () => {
    assert.equal(root.scrollTo(args), 'method-value'); return value;
  });
  assert.equal(count, 1); assert.deepEqual(Object.getOwnPropertyDescriptor(root, 'scrollTo'), before);
  assert.equal(report.incomplete, false); assert.equal(report.restored, true);
  assert.equal(report.evaluationID, 'eval'); assert.equal(report.coverageID, 'coverage');
  assert.equal(report.resultKind, value === null ? 'null' : typeof value);
  assert.equal(report.value, value); assert.equal(report.calls.length, 1);
  assert.deepEqual({...report.calls[0].parameters}, args);
  assert.equal(report.calls[0].before.scrollTop, 0); assert.equal(report.calls[0].after.scrollTop, 1767);
  assert.ok(report.calls[0].before.time < report.calls[0].after.time);
  assert.equal(report.calls[0].terminal, 'returned');
}
// A writable non-configurable own data property can also be restored exactly.
const root = fixture(function(){}, true, {configurable: false});
const before = Object.getOwnPropertyDescriptor(root, 'scrollTo');
assert.equal(observe('e', 'c', () => root.scrollTo(options())).restored, true);
assert.deepEqual(Object.getOwnPropertyDescriptor(root, 'scrollTo'), before);
""")

    def test_writer_errors_escape_identically_and_finally_restores(self):
        self.run_writer_js(r"""
for (const own of [false, true]) for (const source of ['method', 'expression']) {
  const sentinel = {originalError: true}; let count = 0;
  const root = fixture(function(){ ++count; if (source === 'method') throw sentinel; }, own);
  const before = Object.getOwnPropertyDescriptor(root, 'scrollTo');
  assert.throws(() => observe('e', 'c', () => { root.scrollTo(options()); throw sentinel; }),
    error => error === sentinel);
  assert.equal(count, 1); assert.deepEqual(Object.getOwnPropertyDescriptor(root, 'scrollTo'), before);
}
""")

    def test_writer_unknown_arguments_do_not_read_getters_or_coerce(self):
        self.run_writer_js(r"""
let reads = 0, conversions = 0, calls = 0;
const args = {left: 0, get top(){ ++reads; return {valueOf(){ ++conversions; return 1767; }}; }, behavior: 'instant'};
const root = fixture(function(arg){ ++calls; this.scrollTop = Number(arg.top); });
const report = observe('e', 'c', () => root.scrollTo(args));
assert.equal(calls, 1); assert.equal(reads, 1); assert.equal(conversions, 1);
assert.equal(report.incomplete, true); assert.equal(report.calls[0].parameters, null);
let received;
root.scrollTo = function(...args){ received = args; };
const overload = observe('e', 'c', () => root.scrollTo(1, 2));
assert.deepEqual([...received], [1, 2]); assert.equal(overload.reason, 'unsupported-overload');
// Unknown result objects/thenables go straight back, without touching .then.
let thenReads = 0; const unknown = {get then(){ ++thenReads; throw new Error('must not read'); }};
assert.equal(observe('e', 'c', () => unknown), unknown); assert.equal(thenReads, 0);
let receiver;
root.scrollTo = function(){ receiver = this; };
const alternate = {};
const changed = observe('e', 'c', () => root.scrollTo.call(alternate, options()));
assert.equal(receiver, alternate); assert.equal(changed.reason, 'receiver-changed');
let geometryCalls = 0; root.scrollTo = function(){ ++geometryCalls; };
Object.defineProperty(root, 'scrollTop', {get(){ throw new Error('geometry'); }});
const unavailable = observe('e', 'c', () => root.scrollTo(options()));
assert.equal(geometryCalls, 1); assert.equal(unavailable.reason, 'geometry-error');
assert.equal(unavailable.restored, true);
""")

    def test_writer_unavailable_method_no_call_and_root_change_are_incomplete(self):
        self.run_writer_js(r"""
for (const kind of ['frozen-own', 'nonextensible', 'accessor']) {
  let calls = 0, methodReads = 0;
  const method = function(){ ++calls; return false; };
  const root = fixture(method, kind === 'frozen-own', {configurable: false, writable: false});
  if (kind === 'nonextensible') Object.preventExtensions(root);
  if (kind === 'accessor') Object.defineProperty(root, 'scrollTo', {get(){ ++methodReads; return method; }, configurable: true});
  const before = Object.getOwnPropertyDescriptor(root, 'scrollTo');
  const report = observe('e', 'c', () => root.scrollTo(options()));
  assert.equal(report.value, false); assert.equal(report.incomplete, true);
  assert.equal(calls, 1); assert.equal(methodReads, kind === 'accessor' ? 1 : 0);
  assert.deepEqual(Object.getOwnPropertyDescriptor(root, 'scrollTo'), before);
}
const root = fixture(function(){});
const noCall = observe('e', 'c', () => false);
assert.equal(noCall.value, false); assert.equal(noCall.reason, 'no-call');
document.scrollingElement = null;
assert.equal(observe('e', 'c', () => false).reason, 'no-root');
document.scrollingElement = root;
const changed = observe('e', 'c', () => { root.scrollTo(options()); document.scrollingElement = {}; });
assert.equal(changed.reason, 'root-changed'); assert.equal(changed.restored, true);
assert.equal(Object.hasOwn(root, 'scrollTo'), false);
""")

    def test_writer_nested_capacity_and_restore_failure_do_not_hide_original_calls(self):
        self.run_writer_js(r"""
let calls = 0; const root = fixture(function(){ ++calls; });
const original = root.scrollTo;
let inner;
const outer = observe('outer', 'c', () => {
  const outerMethod = root.scrollTo;
  inner = observe('inner', 'c', () => root.scrollTo(options()));
  assert.equal(root.scrollTo, outerMethod); return true;
});
assert.equal(calls, 1); assert.equal(root.scrollTo, original);
assert.equal(outer.restored, true); assert.equal(inner.restored, true);
assert.equal(outer.calls.length, 1); assert.equal(inner.calls.length, 1);
assert.equal(outer.evaluationID, 'outer'); assert.equal(inner.evaluationID, 'inner');
calls = 0;
const capped = observe('e', 'c', () => { for (let i=0; i<17; ++i) root.scrollTo(options()); });
assert.equal(calls, 17); assert.equal(capped.calls.length, 16);
assert.equal(capped.reason, 'call-capacity'); assert.equal(capped.incomplete, true);
const failed = observe('e', 'c', () => {
  root.scrollTo(options()); Object.defineProperty(root, 'scrollTo', {value: original, configurable: false}); return true;
});
assert.equal(failed.value, true); assert.equal(failed.incomplete, true);
assert.equal(failed.restored, false); assert.equal(failed.reason, 'restore-error');
""")

    def test_writer_selection_rejects_embedded_text_and_extra_statements(self):
        source = self.inner_sources()["EPUBSpreadView.swift"]
        pattern = re.search(r'writerPattern = #"(.*?)"#', source).group(1).replace(r"\z", r"\Z")
        for value in ["readium.scrollToId('long-paragraph', false);",
                      "readium.scrollToId('escaped\\\'id', true);",
                      "readium.scrollToPosition('0.4', 'ltr', false)"]:
            self.assertRegex(value, pattern)
        for value in ["readium.scrollToId('x', false); window.scrollTo(0,0)",
                      "(() => readium.scrollToId('x', false))()", "readium.scrollToId('x\n', false);",
                      "readium.scrollToId('x', false);\n", "document.createRange()",
                      '({text:"readium.scrollToId(\\\'x\\\', false);"})',
                      "window.__xrCanonicalGoTarget = readium.scrollToId('x', false);"]:
            self.assertIsNone(re.search(pattern, value), value)
        selector = source.split("private static func supportedWriter", 1)[1].split("func observeWriter", 1)[0]
        self.assertIn("script.hasPrefix(prefix)", selector)
        self.assertIn("script.hasSuffix($0)", selector)
        self.assertIn("JSONSerialization.jsonObject(with: data) is [String: Any]", selector)
        self.assertNotIn(".contains(", selector)

    def test_writer_ownership_runtime_version_and_symbol_only_labels(self):
        source = self.inner_sources()["EPUBSpreadView.swift"]
        observer = source.split("func observeWriter", 1)[1].split("func writerResult", 1)[0]
        self.assertIn("guard active, let view, view.innerScrollDiagnostics === self", observer)
        self.assertIn('evaluations[id]?["phase"] == "submitted"', observer)
        result = source.split("func writerResult", 1)[1].split("private static let writerObservationBody", 1)[0]
        for marker in ['body["evaluationID"] as? String == id.uuidString',
                       'body["coverageID"] as? String == coverageID.uuidString',
                       'evaluations[id]?["phase"] == "submitted"', 'view.innerScrollDiagnostics === self',
                       '"wk-error-no-envelope"', '"identity-or-envelope"',
                       'if kind == "undefined" { return nil }', 'if kind == "null" { return NSNull() }']:
            self.assertIn(marker, result)
        self.assertIn('let framework = Bundle(for: WKWebView.self)', source)
        self.assertIn('forInfoDictionaryKey: "CFBundleVersion"', source)
        self.assertIn('"exactSourceMatch": "unknown"', source)
        self.assertEqual(source.count("Thread.callStackSymbols"), 1)
        self.assertIn('labels.isEmpty ? "unknown"', source)
        self.assertIn('"same-16-native-symbols"', source)
        # Observation receipts never manufacture SDK terminals or alter fixture gates.
        body = writer_body(source)
        self.assertNotRegex(body, r"\b(?:eval|setTimeout|requestAnimationFrame|Promise|await)\s*\(")
        self.assertNotIn(".then", re.sub(r"//[^\n]*", "", body))
        evaluator = source.split("    func evaluateScript(", 1)[1].split("    /// Called from the JS code", 1)[0]
        self.assertEqual(evaluator.count("webView.evaluateJavaScript("), 1)
        # The other existing call is the separate native-readiness observation.
        self.assertEqual(source.count("webView.evaluateJavaScript("), 2)

    def test_inner_binding_and_bounded_prearm_delivery(self):
        source = self.inner_sources()["EPUBInfiniteScrollView.swift"]
        bind = source.split("private func fixtureBindInnerDiagnostics", 1)[1].split("private func fixtureRecordInnerDiagnostic", 1)[0]
        self.assertIn("guard let fixture = readDiagnosticsFixture", bind)
        self.assertIn("[weak self, weak slot, weak fixture]", bind)
        self.assertIn("self?.epoch == bindingEpoch", bind)
        self.assertIn("self?.slots[index] === slot", bind)
        self.assertIn("guard current || terminal else { return }", bind)
        self.assertIn("if sameController, !late, let self", bind)
        self.assertIn("events.count == 255", swift_diagnostic_declaration(source, "@MainActor private final class EPUBInnerDiagnosticBuffer"))
        self.assertIn('"preArmDropped": String(batch.dropped)', source)
        self.assertIn('["test-auxiliary", "original-capture"].contains', source)
        self.assertIn("let batch = events; events.removeAll()", source)
        clear = source.split("private func clear()", 1)[1].split("func shutdown()", 1)[0]
        self.assertLess(clear.index('reason: "viewport-clear"'), clear.index("epoch = UUID()"))
        self.assertIn("fixtureInnerDiagnosticStorage = nil", clear)
        eviction = source.split("private func evict(", 1)[1].split("func reload(", 1)[0]
        self.assertLess(eviction.index('reason: "slot-evicted"'), eviction.index("slot.loadTask?.cancel()"))
        self.assertIn('epubViewportReadDiagnosticsEnabled ? viewportFixtureControl : nil', source)


    def test_preparation_preserves_suspensions_scripts_and_control(self):
        source = (ROOT / "Tests/iOS/ReaderRenderingTests.swift").read_text(encoding="utf-8")
        expected = {'awaits': '55b33d92731c8172d7e296cca51adc78ddf2e7840d946838eb2f9338cfb967d5', 'js': 'c8dc3354db5e7ce1edf96773a89d84dc839d65c6294925418bd9cbe5cbcf90de', 'control': 'f8f3a3de5203a08cd248074bc0b3a09fe48f7462c937db416a11a936a0928ef7', 'pause': '152886fad492634268e0243851a66ae115c7c433461a50eeaaa7c3715d976fa5', 'cleanup': '84f4259a0f115236cff96e256bc8fd0301a1df3e76c082c73d3fdf37ba3dcb76'}
        protected = {
            "awaits": json.dumps(re.findall(r"\bawait\s+([A-Za-z_][A-Za-z0-9_?.]*)", source)),
            "js": json.dumps(re.findall(r'"""(.*?)"""', source, re.S)),
            "control": source.split('        if event.kind == "work-start"', 1)[1].split('    private func append(', 1)[0],
            "pause": source.split('    func pause(', 1)[1].split('    private func abort(', 1)[0],
            "cleanup": source.split('    func cleanUp()', 1)[1].split('    func tearDown()', 1)[0].replace('        preparation?.cleanup("cleanUp")\n', '')}
        for name, value in protected.items():
            with self.subTest(contract=name):
                self.assertEqual(hashlib.sha256(value.encode()).hexdigest(), expected[name])
        case = source.split('func testContinuousViewportResizeKeepsOriginalWordAndLiveWebView()', 1)[1].split('    @MainActor func testSameWidthBodyResize', 1)[0]
        self.assertLess(case.index('defer { fixture?.cleanUp() }'), case.index('        do {'))
        self.assertLess(case.index('fixture?.completePreparation()'), case.index('fixture?.armSample('))
        self.assertTrue(case.rstrip().endswith('throw error\n        }\n    }'))
        self.assertEqual(case.count('fixture?.recordPreparationError(error)'), 1)
        trace = swift_diagnostic_declaration(source, '@MainActor private final class ViewportPreparationTrace')
        self.assertEqual(trace.count('guard !completed, firstError == nil'), 2)
        self.assertNotRegex(trace, r'\b(?:await|throw|Task\s*\{|withTaskCancellationHandler)\b')
        self.assertNotIn('localizedDescription', trace)
        self.assertNotIn('userInfo', trace)
        for helper in ['open(_ engine', 'probe(_ navigator', 'waitUntil(caller:', 'jump(_ engine']:
            signature = source.split('func ' + helper, 1)[1].split(' async throws', 1)[0]
            self.assertIn('preparationObserver: (@MainActor (String) -> Void)? = nil', signature)
        metadata = source.split('    func observe(_ event: Event)', 1)[1].split('        if event.kind == "work-start"', 1)[0]
        self.assertIn('guard pair != nil else', metadata)
        self.assertNotIn('armed', metadata)
        self.assertIn('readDiagnostics.count == 256', metadata)
        self.assertIn('preparation = pairMode.map', source)

    def test_retiring_buffer_delivered_before_old_owner_invalidation(self):
        source = self.inner_sources()['EPUBInfiniteScrollView.swift']
        clear = source.split('private func clear()', 1)[1].split('func shutdown()', 1)[0]
        ordered = ['reason: "viewport-clear"', 'fixtureDrainRetiringInnerDiagnostics(reason: "viewport-clear")',
                   'epoch = UUID()', 'fixtureInnerDiagnosticStorage = nil']
        self.assertEqual([clear.index(x) for x in ordered], sorted(clear.index(x) for x in ordered))
        setter = source.split('var viewportFixtureControl:', 1)[1].split('private func fixtureAnchor', 1)[0]
        ordered = ['reason: "fixture-replaced"', 'fixtureDrainRetiringInnerDiagnostics(reason: "fixture-replaced")',
                   'fixtureInnerDiagnosticStorage = nil', 'viewportFixtureStorage = newValue']
        self.assertEqual([setter.index(x) for x in ordered], sorted(setter.index(x) for x in ordered))
        drain = swift_diagnostic_declaration(source, 'private func fixtureDrainRetiringInnerDiagnostics(')
        self.assertIn('let fixture = readDiagnosticsFixture', drain)
        self.assertIn('fixtureInnerDiagnosticStorage as? EPUBInnerDiagnosticBuffer', drain)
        self.assertNotIn('fixtureInnerState', drain)  # no new empty lifetime
        self.assertNotRegex(drain, r'\b(?:await|Task)\b')
        timeout = source.split('slot.timeoutTask = Task', 1)[1].split('slot.loadTask = Task', 1)[0]
        self.assertLess(timeout.index('guard '), timeout.index('self.fixtureRecordClearOrigin("timeout-fired"'))
        self.assertLess(timeout.index('self.fixtureRecordClearOrigin("timeout-fired"'), timeout.index('slot.view.clear()'))
        for origin in ['shutdown', 'reload']:
            self.assertIn('fixtureRecordClearOrigin("' + origin + '")', source)
        for forbidden in ['withTaskCancellationHandler', 'Task.detached']:
            self.assertNotIn(forbidden, drain)

    def test_preparation_helpers_actual_swift_behavior(self):
        source = (ROOT / 'Tests/iOS/ReaderRenderingTests.swift').read_text(encoding='utf-8')
        sdk = self.inner_sources()['EPUBInfiniteScrollView.swift']
        generated = preparation_harness(source, sdk)
        folder = ROOT / '.cache/preparation-diagnostics'
        folder.mkdir(parents=True, exist_ok=True)
        harness = folder / 'harness.swift'
        harness.write_text(generated, encoding='utf-8', newline='\n')
        record = dict(kind='exact-source-host-Swift-helpers', nativeCompiled=False,
                      harnessSHA256=hashlib.sha256(generated.encode()).hexdigest(),
                      executed=False, passed=False, compiler=shutil.which('swiftc'))
        receipt = folder / 'behavior.json'
        receipt.write_text(json.dumps(record, indent=2) + '\n', encoding='utf-8')
        if not record['compiler']:
            record['reason'] = 'Swift compiler unavailable; behavior unexecuted; CI gate blocked'
            receipt.write_text(json.dumps(record, indent=2) + '\n', encoding='utf-8')
            self.skipTest(record['reason'])
        with tempfile.TemporaryDirectory() as directory:
            executable = Path(directory) / 'harness.exe'
            compile_result = subprocess.run([record['compiler'], '-swift-version', '6', '-parse-as-library',
                str(harness), '-o', str(executable)], capture_output=True, text=True, timeout=60)
            record.update(compileExit=compile_result.returncode, compileLog=compile_result.stdout + compile_result.stderr)
            receipt.write_text(json.dumps(record, indent=2) + '\n', encoding='utf-8')
            self.assertEqual(compile_result.returncode, 0, record['compileLog'])
            result = subprocess.run([str(executable)], capture_output=True, text=True, timeout=30)
            record.update(executed=True, passed=result.returncode == 0, runExit=result.returncode,
                          runLog=result.stdout + result.stderr)
            receipt.write_text(json.dumps(record, indent=2) + '\n', encoding='utf-8')
            self.assertEqual(result.returncode, 0, record['runLog'])
            self.assertIn('PREPARATION_SWIFT_HELPERS_PASS', result.stdout)

    def test_missing_changed_or_duplicate_remote_pin_fails(self):
        changed = copy.deepcopy(self.pins)
        changed[0]["state"]["revision"] = "unreviewed"
        for pins in [self.pins[:-1], changed, self.pins + [self.pins[0]]]:
            with self.subTest(pins=pins), self.assertRaises(ValueError):
                self.lock(pins)

    def test_old_genuine_lock_only_allowed_before_first_real_resolution(self):
        metadata = json.loads((ROOT / "Vendor/ReadiumToolkit/UPSTREAM.json").read_text())
        # Reconstruct the explicitly reviewed remote pin for this regression,
        # without modifying any real lockfile.
        upstream = {"identity": "swift-toolkit", "kind": "remoteSourceControl",
                    "location": "https://github.com/readium/swift-toolkit.git",
                    "state": {"version": "3.11.0", "revision": "d82f44f4f05d87add9e22a8b75abbd61dce745dd"}}
        old = self.pins + metadata["removedUnusedRemoteDependencyPins"] + [upstream]
        self.assertEqual(self.lock(old, allow_upstream=True), len(self.pins))
        with self.assertRaises(ValueError):
            self.lock(old)
        upstream["state"]["revision"] = "different"
        with self.assertRaises(ValueError):
            self.lock(old, allow_upstream=True)

    def test_reviewed_transitive_pins_are_accepted(self):
        self.assertEqual(self.lock(self.pins), len(self.pins))

    def test_vendor_tampering_and_undeclared_sources_fail(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            original = b"// reviewed baseline\n"
            source = root / "Source.swift"
            source.write_bytes(original)
            (root / "LICENSE").write_text("Redistribution and use")
            (root / "README.md").write_text("fixture")
            metadata = {"version": "3.11.0", "revision": "d82f44f4f05d87add9e22a8b75abbd61dce745dd",
                        "license": "BSD-3-Clause", "baselineFiles": [{"path": "Source.swift", "sha256": hashlib.sha256(original).hexdigest()}],
                        "localModifiedFiles": []}
            (root / "UPSTREAM.json").write_text(json.dumps(metadata))
            self.assertEqual(verify_vendor(root), 4)
            source.write_bytes(b"altered")
            with self.assertRaises(ValueError):
                verify_vendor(root)
            source.write_bytes(original)
            (root / "Undeclared.swift").write_text("import UIKit")
            with self.assertRaises(ValueError):
                verify_vendor(root)
