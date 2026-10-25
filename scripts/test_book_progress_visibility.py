"""Local source/wiring guards, not execution of Swift settings or native UI."""
import hashlib
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
OLD_SHA = {'Packages/XianxiaCore/Sources/XianxiaCore/Models/ReadingInteraction.swift': '65a14418f4084ea234da026dadbb0f7d414dbc87536548794bc6de076eb1537d', 'App/Reader/ReaderProgressView.swift': '3a9dfbbdf8e59d00491866559933505b8c729be406353c4eca2ccbcce0780150', 'App/Reader/ReaderAppearanceView.swift': '8cdd12352e465689c7c4cb501652c589580890dffe6d89dc02f5e67b7cef6663', 'App/Reader/ReaderMenuView.swift': '071c970e15013c0de0ff7e206682b672abdea4adc6f368a7aa0a14a6e825dfe4', 'App/Reader/ReaderViewModel.swift': 'b5a2b7692aedb4293ab1ed8b32b0aa51de8de6b95dff6ac3b6507adad90b085a'}
MODEL_BLOCK_SHA = '32b22ea428d873e0720b626a3287297695d9d5bc29cc9d1549ff1b4c77058647'
APPEARANCE_BLOCK_SHA = '0ef8983aa7a7fb6c5f35749495a3cd3fa400c0166576cba823ed028c78839072'


def replace_one(text, old, new):
    if text.count(old) != 1:
        raise ValueError('Progress visibility change missing or duplicated')
    return text.replace(old, new, 1)


def replace_block(text, start, end, expected, replacement):
    if text.count(start) != 1 or text.count(end) != 1:
        raise ValueError('Progress visibility block missing or duplicated')
    block = start + text.split(start, 1)[1].split(end, 1)[0] + end
    if hashlib.sha256(block.encode()).hexdigest() != expected:
        raise ValueError('Progress visibility block differs from reviewed code')
    return text.replace(block, replacement, 1)


def project_visibility(path, text):
    """Reverse only this feature, retaining previous diagnostics and old hashes."""
    if path.endswith('ReaderMenuView.swift'):
        return replace_one(text,
            'ReaderProgressView(state: model.progress, palette: palette, showBookProgress: model.interaction.showsBookProgress)',
            'ReaderProgressView(state: model.progress, palette: palette)')
    if path.endswith('ReaderAppearanceView.swift'):
        text = replace_one(text, 'else { interactionControls; progressVisibilityControls }', 'else { interactionControls }')
        return replace_block(text, '    private var progressVisibilityControls: some View {',
            '    private var interactionControls: some View {', APPEARANCE_BLOCK_SHA,
            '    private var interactionControls: some View {')
    if path.endswith('ReaderViewModel.swift'):
        text = replace_one(text, '    private var interactionHasPendingEngineEdits = false\n', '')
        text = replace_one(text,
            '            if completion?.errorMessage == nil { self.interactionHasPendingEngineEdits = false }\n'
            '            else if self.interactionHasPendingEngineEdits { self.pauseAutomaticScroll() }',
            '            if completion?.errorMessage != nil { self.pauseAutomaticScroll() }')
        text = replace_one(text, '                self.interactionHasPendingEngineEdits = false\n', '')
        text = replace_one(text, '        interactionHasPendingEngineEdits = true\n', '')
        return replace_block(text, '    func setBookProgressVisible(', '    func setAdditionalReduceMotion(', MODEL_BLOCK_SHA,
            '    func retryInteractionSave() { setInteraction(interaction) }\n\n    func setAdditionalReduceMotion(')
    if path.endswith('ReaderProgressView.swift'):
        text = replace_one(text, '    var showBookProgress = true\n', '')
        if text.count('if showBookProgress, let progress = state.summary.progression') != 2:
            raise ValueError('Both visible progress and AX bar must follow the switch')
        text = text.replace('if showBookProgress, let progress = state.summary.progression', 'if let progress = state.summary.progression')
        return replace_one(text, '                    .accessibilityIdentifier("reader.progress.bar")\n', '')
    if path.endswith('ReadingInteraction.swift'):
        text = replace_one(text, '    public var showsBookProgress = true\n', '')
        text = replace_one(text, 'autoHideMenu, showsBookProgress, automaticScrollSpeed', 'autoHideMenu, automaticScrollSpeed')
        return replace_one(text, '        showsBookProgress = try values.contains(.showsBookProgress)\n'
                           '            ? values.decode(Bool.self, forKey: .showsBookProgress) : true\n', '')
    return text


NATIVE_METHODS_SHA = '6334b37bbf806028bf6a89419c27e1034c037c19afe501315d23eed4f2d915d5'


class BookProgressVisibilityTests(unittest.TestCase):
    def text(self, name):
        return (ROOT/name).read_text(encoding='utf-8')

    def test_feature_projects_to_exact_existing_working_files(self):
        for path, old in OLD_SHA.items():
            with self.subTest(path=path):
                self.assertEqual(hashlib.sha256(project_visibility(path, self.text(path)).encode()).hexdigest(), old)

    def test_missing_or_malformed_compatibility_default_cannot_be_silently_changed(self):
        path = 'Packages/XianxiaCore/Sources/XianxiaCore/Models/ReadingInteraction.swift'
        text = self.text(path)
        for bad in [text.replace('public var showsBookProgress = true', 'public var showsBookProgress = false'),
                    text.replace('values.decode(Bool.self, forKey: .showsBookProgress) : true', 'values.decodeIfPresent(Bool.self, forKey: .showsBookProgress) ?? true')]:
            with self.assertRaises(ValueError): project_visibility(path, bad)
        self.assertNotIn('decodeIfPresent', text)

    def test_display_only_setter_does_not_call_engine_sample_or_pause(self):
        text = self.text('App/Reader/ReaderViewModel.swift')
        setter = text.split('    func setBookProgressVisible(', 1)[1].split('    func retryInteractionSave()', 1)[0]
        self.assertIn('guard isReady, let owner = openRequestID else { return }', setter)
        self.assertIn('services.readerSettings.saveInteraction(updated, owner: owner)', setter)
        for bad in ['engine', 'await ', 'Task', 'capture', 'pause', 'saveNow', 'interactionHasPendingEngineEdits =']:
            self.assertNotIn(bad, setter)
        retry = text.split('    func retryInteractionSave()', 1)[1].split('    func setAdditionalReduceMotion(', 1)[0]
        self.assertIn('if interactionHasPendingEngineEdits { setInteraction(interaction) }', retry)
        self.assertIn('else { setBookProgressVisible(interaction.showsBookProgress) }', retry)

    def test_existing_engine_write_failure_safety_is_retained(self):
        text = self.text('App/Reader/ReaderViewModel.swift')
        self.assertIn('if completion?.errorMessage == nil { self.interactionHasPendingEngineEdits = false }', text)
        self.assertIn('else if self.interactionHasPendingEngineEdits { self.pauseAutomaticScroll() }', text)
        engine_setter = text.split('    func setInteraction(', 1)[1].split('    func setBookProgressVisible(', 1)[0]
        self.assertLess(engine_setter.index('interactionHasPendingEngineEdits = true'), engine_setter.index('saveInteraction('))
        native = self.text('Tests/iOS/ReaderLifecycleTests.swift')
        mixed = native.split('        let mixedPrior =', 1)[1].split('        next.close()', 1)[0]
        queued = mixed.split('        await services.readerSettings.flush()', 1)[0]
        self.assertIn('model.setAppearance(typography)', queued)
        self.assertIn('model.setInteraction(mixed)', queued)
        self.assertIn('model.setBookProgressVisible(false)', queued)
        self.assertNotIn('await ', queued)
        self.assertIn('XCTAssertEqual(engine.interactionApplications, applications + 2)', mixed)

    def test_rendering_removes_both_progress_elements_and_retains_position_state(self):
        text = self.text('App/Reader/ReaderProgressView.swift')
        self.assertEqual(text.count('if showBookProgress, let progress = state.summary.progression'), 2)
        self.assertIn('Text(state.summary.chapterTitle)', text)
        state = text.split('@MainActor final class ReaderProgressState:', 1)[1].split('@MainActor struct ReaderProgressView:', 1)[0]
        self.assertNotIn('showBookProgress', state)
        self.assertIn('func update(_ position: ReadingPosition?) { positions.update(position) }', state)

    def test_toggle_is_outside_engine_capability_disabled_group(self):
        text = self.text('App/Reader/ReaderAppearanceView.swift')
        self.assertIn('else { interactionControls; progressVisibilityControls }', text)
        controls = text.split('    private var progressVisibilityControls:', 1)[1].split('    private var interactionControls:', 1)[0]
        self.assertIn('Toggle("显示全书进度"', controls)
        self.assertIn('reader.progress.visibility', controls)
        self.assertNotIn('engine', controls)
        self.assertIn('reader.interaction.save-error', text)

    def test_swift_coverage_keeps_existing_model_case_inventory(self):
        core = self.text('Packages/XianxiaCore/Tests/XianxiaCoreTests/BookProgressVisibilityTests.swift')
        for token in ['testLegacyDefaultsAndVisibilitySurviveFileStoreRecreation', 'testMalformedPresentVisibilityRemainsAnErrorWithoutRewritingTheFile',
                      'XCTAssertFalse(restored.showsBookProgress)', 'XCTAssertEqual(try Data(contentsOf: url), bad)']:
            self.assertIn(token, core)
        native = self.text('Tests/iOS/ReaderLifecycleTests.swift')
        methods = re.findall(r'func (test\w+)\(', native)
        self.assertEqual(hashlib.sha256('\n'.join(methods).encode()).hexdigest(), NATIVE_METHODS_SHA)
        for token in ['XCTAssertEqual(engine.interactionApplications, applications)', 'XCTAssertEqual(engine.captureCalls, captures)',
                      'XCTAssertEqual(persistedPosition, kept)', 'XCTAssertFalse(next.interaction.showsBookProgress)']:
            self.assertIn(token, native)



# Narrow native route; inverses keep all published baseline protections intact.
BOOK_PROGRESS_SELECTION = "book-progress-visibility"
NATIVE_CASES = (
    ("XianxiaReaderTests", "ReaderLifecycleTests", "testInteractionWriteFailureRetryAndAdditionalReductionDoesNotPersist"),
    ("XianxiaReaderUITests", "ReaderInterfaceUITests", "testProgressAndHeaderBackdropKeepMenuGesturesAndChapterUpdates"),
    ("XianxiaReaderUITests", "ReaderInterfaceUITests", "testBookProgressVisibilityAfterReadyPersistsAcrossReopenAndRelaunch"),
)
UI_STAGES = ("default", "hidden", "reopened-hidden", "relaunched-hidden", "visible-again")
PROGRESS_BRANCH = "  book-progress-visibility)\n    cases=(" + " ".join("-only-testing:" + "/".join(c) for c in NATIVE_CASES) + ")\n    ;;\n"
PROGRESS_SETTINGS_STEP = """      - name: Validate progress visibility settings persistence
        if: ${{ inputs.diagnostic_selection == 'book-progress-visibility' }}
        shell: bash
        run: bash scripts/test_reader_logic.sh build/ReaderLogic
"""
PROGRESS_RECEIPT = '''          if [[ "$DIAGNOSTIC_SELECTION" == 'book-progress-visibility' ]]; then
            python3 - <<'BOOK_PROGRESS_RECEIPT'
          from pathlib import Path
          import json, os, sys
          sys.path.insert(0, "scripts")
          from test_book_progress_visibility import verify_book_progress_native
          receipt = verify_book_progress_native(Path("build"))
          receipt.update(source=os.environ["GITHUB_SHA"], nativeCompiled=True)
          Path("build/BookProgressVisibility").mkdir(exist_ok=True)
          Path("build/BookProgressVisibility/native-receipt.json").write_text(json.dumps(receipt, indent=2) + "\\n")
          print("BOOK_PROGRESS_RECEIPT " + json.dumps(receipt, sort_keys=True))
          BOOK_PROGRESS_RECEIPT
          fi
'''
PROGRESS_PATHS = "            build/BookProgressVisibility/\n            build/ReaderLogic/\n"

def without_progress_workflow(text):
    for old, new in [(", book-progress-visibility]", "]"), (PROGRESS_SETTINGS_STEP, ""),
                     (PROGRESS_RECEIPT, ""), (PROGRESS_PATHS, "")]:
        text = replace_one(text, old, new)
    return text

def without_progress_driver(text):
    return replace_one(text, PROGRESS_BRANCH, "")

def verify_book_progress_native(folder):
    import json
    from collections import Counter
    log = (folder/"logs/reader-diagnostic.log").read_text(encoding="utf-8")
    pattern = r"^Test Case '-\[([^ .]+)\.([^ ]+) ([^\]]+)\]' (started\.|passed \([^\n]+\)\.|failed \([^\n]+\)\.|skipped[^\n]*)$"
    events = re.findall(pattern, log, re.M)
    expected = Counter(NATIVE_CASES)
    starts = Counter(e[:3] for e in events if e[3] == "started.")
    passes = Counter(e[:3] for e in events if e[3].startswith("passed ("))
    if len(events) != 2 * len(NATIVE_CASES) or starts != expected or passes != expected:
        raise ValueError("Original opening gate, model and functional UI must each start/pass once with zero other cases/failures/skips")
    for case in NATIVE_CASES:
        rows = [e[3] for e in events if e[:3] == case]
        if rows[0] != "started.": raise ValueError("Pass must follow its own start")
    raw = re.findall(r"^DIAGNOSTIC ONLY: book-progress-visibility; test=(\d+) summary=(\d+) export=(\d+); no device Release or IPA$", log, re.M)
    if raw != [("0", "0", "0")]: raise ValueError("Original three exits must be zero exactly once")
    summary = json.loads((folder/"test-results-summary.json").read_text(encoding="utf-8"))
    for key, value in {"totalTestCount": 3, "passedTests": 3, "failedTests": 0, "skippedTests": 0}.items():
        if type(summary.get(key)) is not int or summary[key] != value: raise ValueError("Wrong xcresult count")
    if summary.get("result") != "Passed" or summary.get("testFailures") != []: raise ValueError("xcresult failed")
    stages = re.findall(r"^BOOK_PROGRESS_UI stage=(\S+) percentage=(true|false) bar=(true|false) chapter=(true|false)$", log, re.M)
    wanted = [(s, "true" if s in ("default", "visible-again") else "false", "true" if s in ("default", "visible-again") else "false", "true") for s in UI_STAGES]
    if stages != wanted: raise ValueError("All actual UI stages must complete in order")
    preparation = re.findall(r"^BOOK_PROGRESS_PREP phase=(\S+) result=(\S+)$", log, re.M)
    if preparation != [(s, "ready") for s in ("initial", "reopened", "relaunched")]:
        raise ValueError("All functional preparations must finish; no failed/missing preparation can be a pass")
    marker = "BOOK_PROGRESS_MODEL pureRetryNoEngine=true mixedApplied=true positionKept=true restoredHidden=true"
    if log.splitlines().count(marker) != 1: raise ValueError("Model retry/mixed/reopen checks did not complete")
    return dict(selection=BOOK_PROGRESS_SELECTION, cases=["/".join(c) for c in NATIVE_CASES],
                started=3, passed=3, failed=0, skipped=0, testExit=0, summaryExit=0, exportExit=0,
                uiStages=list(UI_STAGES), preparationPhases=[s for s, _ in preparation], original20SecondGatePassed=True, modelRetryMixedPositionReopen=True)

class BookProgressNativeCITests(unittest.TestCase):
    def test_selection_keeps_prerequisites_and_never_enters_packaging(self):
        from check_architecture import yaml
        workflow = yaml.load((ROOT/".github/workflows/ios-build.yml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        self.assertEqual(workflow['on']['push']['branches'], ['main'])
        self.assertEqual(workflow['on']['workflow_dispatch']['inputs']['diagnostic_selection']['options'].count(BOOK_PROGRESS_SELECTION), 1)
        jobs = workflow['jobs']
        self.assertEqual(jobs['reading-diagnostic']['needs'], ['repository-checks', 'core-tests'])
        inputs = dict(diagnostic_selection=BOOK_PROGRESS_SELECTION, resolve_local_readium=False, session_logic_only=False, stop_after_full_tests=False)
        def enabled(expression):
            expression = expression.strip().removeprefix('${{').removesuffix('}}').strip()
            expression = re.sub(r'inputs\.(\w+)', lambda m: repr(inputs[m[1]]), expression)
            expression = expression.replace('&&', ' and ').replace('||', ' or ')
            expression = re.sub(r'!(?!=)', ' not ', expression)
            return bool(eval(expression, {'__builtins__': {}}, {}))
        for name in ['core-tests', 'reading-diagnostic']:
            self.assertTrue(enabled(jobs[name]['if']), name)
        for name in ['ios', 'reader-logic', 'reader-positions']:
            self.assertFalse(enabled(jobs[name]['if']), name)
        steps = jobs['reading-diagnostic']['steps']
        settings = next(s for s in steps if s.get('name') == 'Validate progress visibility settings persistence')
        self.assertTrue(enabled(settings['if']))
        self.assertEqual(settings['run'], 'bash scripts/test_reader_logic.sh build/ReaderLogic')
        self.assertLess(steps.index(settings), next(i for i,s in enumerate(steps) if s.get('name') == 'Run selected native diagnostics without device packaging'))

    def test_exact_published_route_preserved(self):
        workflow = (ROOT/".github/workflows/ios-build.yml").read_text(encoding="utf-8")
        driver = (ROOT/"scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        self.assertEqual(hashlib.sha256(without_progress_workflow(workflow).encode()).hexdigest(), "a6ea6eb62afac61a53fbaa47f7c351e66134af572057a4095329b4adfe6325b8")
        self.assertEqual(hashlib.sha256(without_progress_driver(driver).encode()).hexdigest(), "79f96b8934a9b2905356bb6831e91e79e49d7a9c549901893a7afe3c5d19a71d")
        self.assertEqual(driver.count(PROGRESS_BRANCH), 1)
        for bad in [workflow.replace(PROGRESS_RECEIPT, ""), workflow + PROGRESS_SETTINGS_STEP,
                    workflow.replace('book-progress-visibility]', 'settings-ui]')]:
            with self.assertRaises(ValueError): without_progress_workflow(bad)
        with self.assertRaises(ValueError): without_progress_driver(driver.replace(PROGRESS_BRANCH, ""))

    def test_ui_keeps_original_method_and_covers_actual_reopen_relaunch(self):
        text = (ROOT/"Tests/UI/ReaderInterfaceUITests.swift").read_text(encoding="utf-8")
        for token in ['let visibilityApp = XCUIApplication()', 'from: true, to: false', 'from: false, to: true',
                      'visibilityApp.terminate(); visibilityApp.launch()',
                      'hittable == true', 'XCTAssertEqual(percentage.exists, visible)',
                      'XCTAssertEqual(bar.exists, visible)', 'XCTAssertTrue(title.label.contains("第二章"))']:
            self.assertIn(token, text)
        for case in NATIVE_CASES[1:]: self.assertEqual(text.count('func '+case[2]+'('), 1)
        for stage in UI_STAGES: self.assertIn('stage: "'+stage+'"', text)

    def test_native_receipt_success_and_rejects_missing_wrong_duplicate_skip_failure(self):
        import json, tempfile
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); (root/"logs").mkdir()
            log = ""
            for module, cls, method in NATIVE_CASES:
                prefix = "Test Case '-["+module+"."+cls+" "+method+"]' "
                log += prefix+"started.\n"+prefix+"passed (1.000 seconds).\n"
            log += "DIAGNOSTIC ONLY: book-progress-visibility; test=0 summary=0 export=0; no device Release or IPA\n"
            for phase in ("initial", "reopened", "relaunched"):
                log += f"BOOK_PROGRESS_PREP phase={phase} result=ready\n"
            for stage in UI_STAGES:
                value = "true" if stage in ("default", "visible-again") else "false"
                log += f"BOOK_PROGRESS_UI stage={stage} percentage={value} bar={value} chapter=true\n"
            log += "BOOK_PROGRESS_MODEL pureRetryNoEngine=true mixedApplied=true positionKept=true restoredHidden=true\n"
            target = root/"logs/reader-diagnostic.log"
            summary = dict(totalTestCount=3, passedTests=3, failedTests=0, skippedTests=0, result="Passed", testFailures=[])
            result = root/"test-results-summary.json"
            result.write_text(json.dumps(summary), encoding="utf-8"); target.write_text(log, encoding="utf-8")
            self.assertEqual(verify_book_progress_native(root)["passed"], 3)
            gate = NATIVE_CASES[1]
            gate_label = "Test Case '-["+gate[0]+"."+gate[1]+" "+gate[2]+"]' "
            gate_pass = gate_label+"passed (1.000 seconds)."
            missing_gate = "\n".join(row for row in log.splitlines() if not row.startswith(gate_label))+"\n"
            for bad in [missing_gate, log.replace(gate_pass, gate_pass.replace("passed (", "failed (")),
                        log+log.splitlines()[0]+"\n", log.replace("XianxiaReaderUITests.", "WrongTests."),
                        log.replace("passed (1.000 seconds).", "skipped.", 1),
                        log.replace("passed (1.000 seconds).", "failed (1.000 seconds).", 1),
                        log.replace("test=0", "test=65"),
                        log.replace("phase=initial result=ready", "phase=initial result=failed"),
                        log.replace("BOOK_PROGRESS_PREP phase=reopened result=ready\n", ""), log.replace("stage=default", "stage=unknown"),
                        log.replace("pureRetryNoEngine=true", "pureRetryNoEngine=false"),
                        "\n".join(s for s in log.splitlines() if "reopened-hidden" not in s)]:
                target.write_text(bad, encoding="utf-8")
                with self.assertRaises(ValueError): verify_book_progress_native(root)
            target.write_text(log, encoding="utf-8")
            for change in [dict(skippedTests=1), dict(totalTestCount=2), dict(result="Failed"), dict(passedTests=True)]:
                result.write_text(json.dumps(summary|change), encoding="utf-8")
                with self.assertRaises(ValueError): verify_book_progress_native(root)



LEGACY_UI_SHA = '4ab8579e8e7db695e3903996d29cb7d758bdb144c73ba7f0f210f602f748ed5a'
FEATURE_UI_BLOCK_SHA = 'aeb0a4887218320012314d69e36f12e619ae436ccaefbad5c01958884cdf80cf'
FEATURE_UI_HELPERS_SHA = '0643a640a675ef5863982fca1188f52dda969b7e15f4eba267f39792fdeed32a'

def project_functional_ui(text):
    text = replace_block(text, '    // Functional preparation is separate from the unchanged 20s opening gate above.\n', '    @MainActor func testReadingPanelsFollowFiveThemesAndKeepNativeHitRegions()', FEATURE_UI_BLOCK_SHA,
                         '    @MainActor func testReadingPanelsFollowFiveThemesAndKeepNativeHitRegions()')
    return replace_block(text, '    // This 60s fixture-preparation budget is NOT an opening-speed acceptance budget.\n', '    @MainActor private func start(', FEATURE_UI_HELPERS_SHA,
                         '    @MainActor private func start(')

class BookProgressBoundaryTests(unittest.TestCase):
    def test_original_gate_all_assertions_and_twenty_second_helpers_are_exact(self):
        text = (ROOT/"Tests/UI/ReaderInterfaceUITests.swift").read_text(encoding="utf-8")
        self.assertEqual(hashlib.sha256(project_functional_ui(text).encode()).hexdigest(), LEGACY_UI_SHA)
        changed = text.replace('timeout: 20', 'timeout: 60')
        with self.assertRaises(ValueError): project_functional_ui(changed)

    def test_preparation_cannot_turn_not_ready_into_skip_or_success(self):
        text = (ROOT/"Tests/UI/ReaderInterfaceUITests.swift").read_text(encoding="utf-8")
        preparation = text.split('    @MainActor private func prepareBookProgressReader(',1)[1].split('    @MainActor private func changeBookProgress(',1)[0]
        self.assertIn('settings.exists && settings.isEnabled && text.allElementsBoundByIndex.contains { $0.isHittable }', preparation)
        self.assertIn('guard result == .completed else {', preparation)
        self.assertEqual(preparation.count('XCTFail('), 2)
        self.assertEqual(preparation.count('return false'), 2)
        self.assertIn('XCTWaiter.wait(for: [ready], timeout: 60)', preparation)
        for token in ['XCTSkip','XCTExpectFailure','sleep(', 'try?', 'continueAfterFailure = true']:
            self.assertNotIn(token, text)
        feature = text.split('func '+NATIVE_CASES[2][2]+'()',1)[1].split('    @MainActor func testReadingPanelsFollowFiveThemesAndKeepNativeHitRegions()',1)[0]
        self.assertNotIn('start()', feature)
        self.assertNotIn('openBook(in:', feature)
        self.assertIn('UUID().uuidString', feature)
        for phase, expected in [('initial','本样书用于'),('reopened','灯下第1段'),('relaunched','灯下第1段')]:
            self.assertIn('phase: "'+phase+'", expectedText: "'+expected+'") else { return }', feature)
        self.assertEqual(feature.count('prepareBookProgressReader('), 3)


if __name__ == '__main__':
    unittest.main()
