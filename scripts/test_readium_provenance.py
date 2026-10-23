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
