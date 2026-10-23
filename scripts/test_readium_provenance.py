"""Reject accidental source and dependency drift in the maintained extension."""
import copy
import hashlib
import json
from pathlib import Path
import re
import tempfile
import unittest

from verify_readium_lock import ROOT, verify_lock
from verify_vendor import verify_vendor


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
        expected = {'EPUBSpreadView.swift': {'release': 'd79a01c99e5db34ba8b9e5e87729aad8da23619f53f79285fea594db546fb043', 'js': '24360e6a630a6ba33fb73d5be413a0fc7ab7a5645b689e4eb12552c81eab97f3', 'awaits': '838acea36ee3ecadcffb7cc7fa3c958a1a50a2b8bdce77c503ce87b318670be8'}, 'EPUBReflowableSpreadView.swift': {'release': '2daeba600700a62ba06fb2aac79920e8aacf68891936ed17cc434a3d9dff46ed', 'js': 'bbe1d6418414ec65dcaedd227261be1e8444a1cdeae27c00941c8c64f482b541', 'awaits': 'f9b28569ff9c4eb31320e3d74143b688d97826d9c1b1ced202e0f597fd5d3261'}, 'EPUBInfiniteScrollView.swift': {'release': '8d05487ee656b8e7506d24717a49125bc11eb9e7bc82cebc7ec80d65769083ed', 'js': '2abb959598e79a25c3c7176b7b3369e2a1235dd1456ebbc7e8019b722d0df00d', 'awaits': '184f24176cf7e255fcd0425a0fb5b8592a12b8540133562bea0db4bed3d4713d'}}
        self.assertEqual(len(expected), 3)
        for name, text in self.inner_sources().items():
            with self.subTest(file=name):
                protected = release_source(text).encode()
                self.assertEqual(hashlib.sha256(protected).hexdigest(), expected[name]["release"])
                literals = re.findall(r'"""(.*?)"""', text, re.S)
                self.assertEqual(hashlib.sha256(json.dumps(literals).encode()).hexdigest(), expected[name]["js"])
                awaits = re.findall(r"\bawait\s+([A-Za-z_][A-Za-z0-9_?.]*)", text)
                self.assertEqual(hashlib.sha256(json.dumps(awaits).encode()).hexdigest(), expected[name]["awaits"])
                altered = release_source(text).replace("guard ", "guard false, ", 1)
                self.assertNotEqual(hashlib.sha256(altered.encode()).hexdigest(), expected[name]["release"])

    def test_inner_evaluator_and_cancellation_receipt_order(self):
        base = self.inner_sources()["EPUBSpreadView.swift"]
        evaluator = base.split("    func evaluateScript(", 1)[1].split("    /// Called from the JS code", 1)[0]
        markers = ["enterEvaluation(script)", "await spreadLoaded()", "guard !wasCleared, !Task.isCancelled",
                   'fixtureReadObserver?("js-submit"', "submitEvaluation(evaluationID)",
                   "webView.evaluateJavaScript(script)", 'fixtureReadObserver("js-callback"',
                   "finishEvaluation(evaluationID, error: error)", "continuation.resume(returning: .failure(error))",
                   "continuation.resume(returning: .success(res ?? ()))"]

        def ordered(text):
            positions = [text.find(value) for value in markers]
            return min(positions) >= 0 and positions == sorted(positions) and text.count("continuation.resume(") == 2

        self.assertTrue(ordered(evaluator))
        self.assertFalse(ordered(evaluator.replace("submitEvaluation(evaluationID)", "finishEvaluation(evaluationID)", 1)))
        self.assertIn("defer {\n                if !diagnosticSubmitted", evaluator)
        self.assertIn("cancelEvaluation(evaluationID)", evaluator)
        helper = base.split("@MainActor final class EPUBInnerScrollDiagnostics", 1)[1].split("extension EPUBSpreadView", 1)[0]
        self.assertNotRegex(helper, r"\b(?:await|Task\s*\{|evaluateJavaScript|setContentOffset|layoutIfNeeded)\b")
        self.assertNotRegex(helper, r"contentOffset\s*(?:\.[xy])?\s*=")
        close = helper.split("func close(", 1)[1].split("func record(", 1)[0]
        self.assertLess(close.index("active = false"), close.index('emit("coverage-end"'))
        self.assertIn("evaluations.removeAll(); writers.removeAll()", close)
        self.assertIn("view = nil", close)
        self.assertIn("recordLateEvaluation(id", helper)
        self.assertIn("Thread.callStackSymbols.prefix(16)", helper)
        self.assertIn("previousY - y > 0.5, !capturedRollback", helper)

    def test_inner_binding_and_bounded_prearm_delivery(self):
        source = self.inner_sources()["EPUBInfiniteScrollView.swift"]
        bind = source.split("private func fixtureBindInnerDiagnostics", 1)[1].split("private func fixtureRecordInnerDiagnostic", 1)[0]
        self.assertIn("guard let fixture = readDiagnosticsFixture", bind)
        self.assertIn("[weak self, weak slot, weak fixture]", bind)
        self.assertIn("self?.epoch == bindingEpoch", bind)
        self.assertIn("self?.slots[index] === slot", bind)
        self.assertIn("guard current || terminal else { return }", bind)
        self.assertIn("if sameController, !late, let self", bind)
        self.assertIn("state.events.count == 255", source)
        self.assertIn('"preArmDropped": String(state.dropped)', source)
        self.assertIn('["test-auxiliary", "original-capture"].contains', source)
        self.assertIn("let events = state.events; state.events.removeAll()", source)
        clear = source.split("private func clear()", 1)[1].split("func shutdown()", 1)[0]
        self.assertLess(clear.index('reason: "viewport-clear"'), clear.index("epoch = UUID()"))
        self.assertIn("fixtureInnerDiagnosticStorage = nil", clear)
        eviction = source.split("private func evict(", 1)[1].split("func reload(", 1)[0]
        self.assertLess(eviction.index('reason: "slot-evicted"'), eviction.index("slot.loadTask?.cancel()"))
        self.assertIn('epubViewportReadDiagnosticsEnabled ? viewportFixtureControl : nil', source)

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
