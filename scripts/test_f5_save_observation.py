"""F5 observation guards: project out only named metadata; retain the exact old flow.

Frozen hashes refer to the pre-observation source, not newly blessed output.
Swift behavior is additionally checked by the ReaderPositions package tests.
"""
from pathlib import Path
import hashlib
import unittest
from test_book_progress_visibility import project_visibility

ROOT = Path(__file__).resolve().parents[1]


def section(text, start, end):
    return start + text.split(start, 1)[1].split(end, 1)[0]


def sha(text):
    return hashlib.sha256(text.encode()).hexdigest()


class SaveObservationTests(unittest.TestCase):
    def read(self, name):
        return (ROOT / name).read_text(encoding="utf-8")

    def test_save_flow_projects_to_exact_original(self):
        text = section(self.read("App/Reader/ReaderViewModel.swift"),
                       "    func saveNow(source:", "    func setAppearance(")
        text = text.replace("func saveNow(source: ReaderSaveSource = .unspecified)", "func saveNow()")
        start = text.index("        let diagnosticID =")
        end = text.index("        await engine?.automaticScrollProvider?")
        text = text[:start] + text[end:]
        text = text.replace('        phase = "settings-flush"\n', '')
        start = text.index('        phase = "position"')
        end = text.index('        phase = "returned"') + len('        phase = "returned"\n')
        original = "        await positionPersistence.captureAndSave(from: ReaderEnginePositionSource(engine), request: requestID) { self.openRequestID }\n"
        text = text[:start] + original + text[end:]
        self.assertEqual(sha(text), MODEL_SHA)

    def test_capture_flow_projects_to_exact_original(self):
        text = section(self.read("Packages/ReaderPositions/Sources/ReaderPositions/ReaderPositionPersistence.swift"),
                       "    public func captureAndSave(", "    /// Every already-accepted")
        text = text.replace("                               diagnostic: ((CaptureDiagnostic) -> Void)? = nil,\n", "")
        start = text.index("        var reason =")
        end = text.index("        // The new module entry")
        text = text[:start] + text[end:]
        metadata = [line for line in text.splitlines(keepends=True)
                    if line.strip().startswith(("reason =", "attempts +=", "unavailableCaptures +=", "failurePublished ="))]
        self.assertEqual(len(metadata), 14)
        for line in metadata:
            text = text.replace(line, "", 1)
        self.assertEqual(sha(text), PERSIST_SHA)

    def test_adapter_and_view_calls_preserve_original_flow(self):
        text = self.read("App/Reader/ReaderPositionAdapters.swift")
        text = text.replace("    enum UnavailableReason: String { case returnedNil, engineUnavailable }\n", "")
        start = text.index("    private let observeUnavailable:")
        end = text.index("    var supportsTextCapture:")
        text = text[:start] + "    init(_ engine: any ReaderEngine) { self.engine = engine }\n" + text[end:]
        start = text.index("        do {\n")
        end = text.index("        // Translate")
        text = text[:start] + "        do { return try await engine.captureCurrentPosition() }\n" + text[end:]
        text = text.replace("catch ReaderPositionCaptureError.unavailable { observeUnavailable?(.engineUnavailable); return nil }",
                            "catch ReaderPositionCaptureError.unavailable { return nil }")
        self.assertEqual(sha(text), ADAPTER_SHA)
        for name, origins, expected in VIEW_HASHES:
            text = project_visibility(name, self.read(name))
            for origin in origins:
                self.assertEqual(text.count("saveNow(source: ." + origin + ")"), 1)
                text = text.replace("saveNow(source: ." + origin + ")", "saveNow()")
            text = text.replace('presentationTrace.joined(separator: " | ") + model.saveDiagnosticSummary',
                                'presentationTrace.joined(separator: " | ")')
            self.assertEqual(sha(text), expected)

    def test_diagnostics_are_gated_bounded_and_contain_no_error_payload(self):
        model = self.read("App/Reader/ReaderViewModel.swift")
        helper = section(model, "    // F5 save observation:", "    init(book:")
        self.assertIn('#if DEBUG\nprivate let readerSaveDiagnosticsAvailable = true\n#else\nprivate let readerSaveDiagnosticsAvailable = false', model)
        self.assertIn('environment["XR_READER_UI_SETTINGS"] == "1"', model)
        self.assertIn('guard saveDiagnosticsEnabled', helper)
        self.assertIn('saveDiagnosticRequests < 32', helper)
        self.assertIn('saveDiagnosticRows.count > 8', helper)
        self.assertIn('saveCoverage=first-32-requests,last-8-rows', helper)
        self.assertNotIn('@Published', helper)
        for forbidden in ['await ', 'Task {', 'captureCurrentPosition', 'localizedDescription', 'locatorData', 'book.', 'path', 'URLSession']:
            self.assertNotIn(forbidden, helper)
        calls = []
        for file in (ROOT / "App/Reader").glob("*.swift"):
            calls.extend(line for line in file.read_text(encoding="utf-8").splitlines()
                         if 'await model.saveNow(' in line)
        self.assertEqual(len(calls), 4)
        self.assertTrue(all('source: .' in line for line in calls))


MODEL_SHA = '144c14b19b2396e11547034547b3da6f2eb990bddc66c55b164e935ea26c3591'
PERSIST_SHA = 'acce9c67202e3f0c41dbb1a52a4fb0caff5ad09920bed8d8f463b2f8ae3752de'
ADAPTER_SHA = 'f3f0423a98d1e6c9fcc40bdb19d47ed13b50e4261e2fd02ab6cb6e034244c4f3'
VIEW_HASHES = [('App/Reader/ReaderView.swift', ['returnToLibrary', 'settingsDismissed', 'sceneInactive'], '05a12711d7a31b4cf26c8fe790ca4f4a56e3c557384976c18c60fe0fb7da19fd'), ('App/Reader/ReaderAppearanceView.swift', ['positionRetry'], '62adc867e738de4f24fca0535ba351b2b6173dfb91f9bdcfa44794af8d3e0c65')]

if __name__ == "__main__":
    unittest.main()
