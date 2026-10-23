from collections import Counter
from copy import deepcopy
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest
import xml.etree.ElementTree as ET

from check_architecture import ROOT, yaml
from verify_reader_positions import LOGIC_TESTS, STATE_TESTS, TEST_CLASSES, NATIVE_TESTS, ACCEPTANCE_TESTS, CLOSE_TESTS, VIEWPORT_SMOKE_TESTS, verify_logic, verify_native, verify_acceptance, verify_close, verify_viewport_smoke
from verify_reader_positions import verify_viewport_pair_arm, compare_viewport_pair_receipts


class PositionEvidenceTests(unittest.TestCase):
    def setUp(self):
        folder = tempfile.TemporaryDirectory()
        self.addCleanup(folder.cleanup)
        self.root = Path(folder.name)
        self.suite = ET.Element("testsuite", tests=str(len(LOGIC_TESTS)), errors="0", failures="0")
        for name in sorted(LOGIC_TESTS):
            cls = TEST_CLASSES[name]
            ET.SubElement(self.suite, "testcase", classname="ReaderPositionsTests." + cls, name=name)
        (self.root / "dependencies.json").write_text(json.dumps({"name": "ReaderPositions", "dependencies": [{"name": "XianxiaCore", "dependencies": []}]}))

    def logic(self, suite=None):
        tree = ET.Element("testsuites")
        tree.append(self.suite if suite is None else suite)
        ET.ElementTree(tree).write(self.root / "tests.xml")
        return verify_logic(self.root)

    def test_all_contracts_require_exact_identity_without_external_packages(self):
        self.assertEqual(self.logic()["passed"], len(LOGIC_TESTS))
        for dependencies in [{"name": "Other", "dependencies": []},
                             {"name": "ReaderPositions", "dependencies": []},
                             {"name": "ReaderPositions", "dependencies": [{"name": "ReadiumToolkit", "dependencies": []}]},
                             {"name": "ReaderPositions", "dependencies": [{"name": "XianxiaCore", "dependencies": [{"name": "ReadiumToolkit"}]}]}]:
            with self.subTest(dependencies=dependencies):
                (self.root / "dependencies.json").write_text(json.dumps(dependencies))
                with self.assertRaises(ValueError): self.logic()

    def test_missing_duplicate_extra_wrong_failed_and_skipped_logic_is_rejected(self):
        for mode in ["missing", "duplicate", "extra", "wrong-class", "moved-class", "failure", "skipped", "empty"]:
            with self.subTest(mode=mode):
                suite = deepcopy(self.suite)
                if mode == "missing": suite.remove(suite[0])
                elif mode == "duplicate": suite.append(deepcopy(suite[0]))
                elif mode == "extra": ET.SubElement(suite, "testcase", classname="ReaderPositionStateTests", name="testOther")
                elif mode == "wrong-class": suite[0].set("classname", "Other")
                elif mode == "moved-class":
                    other = "ReaderPositionPersistenceTests" if suite[0].get("name") in STATE_TESTS else "ReaderPositionStateTests"
                    suite[0].set("classname", "ReaderPositionsTests." + other)
                elif mode in {"failure", "skipped"}: ET.SubElement(suite[0], mode)
                else: suite.clear()
                with self.assertRaises(ValueError): self.logic(suite)

    def native_fixture(self, tests=NATIVE_TESTS):
        (self.root / "logs").mkdir()
        lines = []
        for case in sorted(tests):
            cls, name = case.split("/")
            prefix = f"Test Case '-[XianxiaReaderTests.{cls} {name}]' "
            lines.extend([prefix + "started.", prefix + "passed (1.000 seconds)."])
        log = "\n".join(lines) + "\n"
        (self.root / "logs/reader-diagnostic.log").write_text(log)
        summary = dict(totalTestCount=len(tests), passedTests=len(tests), failedTests=0, skippedTests=0, testFailures=[], result="Passed")
        (self.root / "test-results-summary.json").write_text(json.dumps(summary))
        return log, summary

    def test_original_native_cases_and_summary_must_agree_without_retries(self):
        log, summary = self.native_fixture()
        self.assertEqual(verify_native(self.root)["passed"], len(NATIVE_TESTS))
        for bad in [log.replace("passed", "failed", 1), log + log, "\n".join(log.splitlines()[2:]), ""]:
            (self.root / "logs/reader-diagnostic.log").write_text(bad)
            with self.assertRaises(ValueError): verify_native(self.root)
        (self.root / "logs/reader-diagnostic.log").write_text(log)
        for key in ["passedTests", "totalTestCount", "failedTests", "skippedTests"]:
            bad = dict(summary); bad[key] += 1
            (self.root / "test-results-summary.json").write_text(json.dumps(bad))
            with self.assertRaises(ValueError): verify_native(self.root)

    def test_native_selection_matches_exact_existing_methods(self):
        script = (ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        block = script.split("  position-isolation)", 1)[1].split("    ;;", 1)[0]
        selected = re.findall(r"-only-testing:XianxiaReaderTests/(\w+/\w+)", block)
        self.assertEqual(Counter(selected), Counter({name: 1 for name in NATIVE_TESTS}))
        for case in selected:
            cls, name = case.split("/")
            source = (ROOT / f"Tests/iOS/{cls}.swift").read_text(encoding="utf-8")
            self.assertIn(f"func {name}(", source)

    def test_acceptance_requires_all_23_events_summary_and_true_exit_without_retry(self):
        log, summary = self.native_fixture(ACCEPTANCE_TESTS)
        self.assertEqual(verify_acceptance(self.root)["passed"], 23)
        with self.assertRaises(ValueError): verify_acceptance(self.root, status=65)
        for bad in [log.replace("passed", "failed", 1), log + log, "\n".join(log.splitlines()[2:]), ""]:
            (self.root / "logs/reader-diagnostic.log").write_text(bad)
            with self.assertRaises(ValueError): verify_acceptance(self.root)
        (self.root / "logs/reader-diagnostic.log").write_text(log)
        for bad in [dict(summary, result="Failed"), dict(summary, skippedTests=1),
                    dict(summary, totalTestCount=22), dict(summary, passedTests=22),
                    dict(summary, testFailures=["earlier crash"])]:
            (self.root / "test-results-summary.json").write_text(json.dumps(bad))
            with self.assertRaises(ValueError): verify_acceptance(self.root)

    def test_acceptance_selector_and_workflow_match_the_audited_23_only(self):
        audit = json.loads((ROOT / "Documentation/ValidationLogs/project-isolation-i6-audit.json").read_text(encoding="utf-8"))
        self.assertEqual(ACCEPTANCE_TESTS, set(audit["nextNativeGate"]["cases"]))
        shell = (ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        block = shell.split("  position-acceptance)", 1)[1].split("    ;;", 1)[0]
        selected = re.findall(r"-only-testing:XianxiaReaderTests/(\w+/\w+)", block)
        self.assertEqual(Counter(selected), Counter(dict.fromkeys(ACCEPTANCE_TESTS, 1)))
        self.assertEqual(len(selected), 23)
        for case in selected:
            cls, name = case.split("/")
            self.assertIn(f"func {name}(", (ROOT / f"Tests/iOS/{cls}.swift").read_text(encoding="utf-8"))
        self.assertIn('"$selection" == \'position-acceptance\' ||', shell)
        workflow = yaml.load((ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        self.assertIn("position-acceptance", workflow["on"]["workflow_dispatch"]["inputs"]["diagnostic_selection"]["options"])
        jobs = workflow["jobs"]
        self.assertIn("== 'position-acceptance'", jobs["reader-positions"]["if"])
        for name in ["core-tests", "reading-diagnostic"]:
            self.assertIn("!= 'position-acceptance'", jobs[name]["if"])
        self.assertNotIn("position-acceptance", jobs["ios"]["if"])
        steps = [s for s in jobs["reader-positions"]["steps"] if "verify_reader_positions.py acceptance" in s.get("run", "")]
        self.assertEqual(len(steps), 1)
        self.assertIn("set -euo pipefail", steps[0]["run"])
        self.assertNotIn("test_reader_positions.sh", steps[0]["run"])

    def test_close_requires_pending_barrier_and_disconnection_in_both_modes(self):
        log, _ = self.native_fixture(CLOSE_TESTS)
        rows = []
        for mode in ["paged", "continuous"]:
            values = {"href": "/OEBPS/cover.xhtml", "started": True, "nativeFontState": "pending",
                      "probe": {"installed": True, "nativeReady": True, "released": False,
                                "settledCalls": 0, "instanceCalls": 0, "prototypeCalls": 1}}
            rows.extend([dict(mode=mode, phase="prepared", values=values),
                         dict(mode=mode, phase="closed", values=dict(retiredCount=2,
                              delegatesDisconnected=True, remainingWebViews=0, remainingChildren=0)),
                         dict(mode=mode, phase="gate-cleanup", values=dict(released=True))])
        def write(records):
            (self.root / "logs/reader-diagnostic.log").write_text(
                log + "\n" + "\n".join("CLOSE_INITIALIZATION_PROBE " + json.dumps(r) for r in records))
        write(rows)
        self.assertEqual(verify_close(self.root)["passed"], 1)
        with self.assertRaises(ValueError): verify_close(self.root, status=65)
        for bad in [rows[:3], rows + rows[:1]]:
            write(bad)
            with self.assertRaises(ValueError): verify_close(self.root)
        for key, value in [("installed", False), ("nativeReady", False), ("released", True),
                           ("settledCalls", 1), ("prototypeCalls", 0), ("installError", "broken hook")]:
            bad = deepcopy(rows); bad[0]["values"]["probe"][key] = value; write(bad)
            with self.assertRaises(ValueError): verify_close(self.root)
        for key, value in [("nativeFontState", "ready"), ("href", "/hidden/one.xhtml")]:
            bad = deepcopy(rows); bad[0]["values"][key] = value; write(bad)
            with self.assertRaises(ValueError): verify_close(self.root)
        for key, value in [("delegatesDisconnected", False), ("remainingWebViews", 1), ("remainingChildren", 1)]:
            bad = deepcopy(rows); bad[1]["values"][key] = value; write(bad)
            with self.assertRaises(ValueError): verify_close(self.root)

    def test_initialization_close_route_never_selects_other_cases_or_jobs(self):
        shell = (ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        block = shell.split("  initialization-close)", 1)[1].split("    ;;", 1)[0]
        self.assertEqual(re.findall(r"-only-testing:XianxiaReaderTests/(\w+/\w+)", block), sorted(CLOSE_TESTS))
        workflow = yaml.load((ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        self.assertIn("initialization-close", workflow["on"]["workflow_dispatch"]["inputs"]["diagnostic_selection"]["options"])
        jobs = workflow["jobs"]
        for name in ["core-tests", "reading-diagnostic"]:
            self.assertIn("!= 'initialization-close'", jobs[name]["if"])
        self.assertNotIn("initialization-close", jobs["ios"]["if"])
        self.assertIn("== 'initialization-close'", jobs["reader-positions"]["if"])
        steps = [s for s in jobs["reader-positions"]["steps"] if "verify_reader_positions.py close" in s.get("run", "")]
        self.assertEqual(len(steps), 1)
        self.assertIn("set -euo pipefail", steps[0]["run"])
        self.assertIn("ci_reader_diagnostic.sh initialization-close", steps[0]["run"])
        self.assertNotIn("test_reader_positions.sh", steps[0]["run"])

    def test_viewport_smoke_requires_real_gates_receipts_and_empty_cleanup(self):
        log, _ = self.native_fixture(VIEWPORT_SMOKE_TESTS)
        events = []
        def add(request, kind, **values):
            events.append(dict(requestID=request, kind=kind, sequence=str(len(events) + 1), nonce="fixture", **values))
        add("S", "sample-before-read"); add("S", "held", gate="sample-before-read")
        add("S", "released", disposition="run"); add("S", "sample-finished", outcome="committed")
        owner = dict(reader="reader", epoch="epoch", slot="slot", webView="web", index="1", anchor="A")
        neighbor = dict(owner, slot="neighbor", webView="neighbor-web", index="0")
        add("arm", "admission-armed", **owner, targetWidth="874")
        for request, kind, values in [("N", "measure", neighbor), ("M", "measure", owner)]:
            add(request, "work-start", **values)
            add(request, kind + "-before-capture", **values)
            add(request, "queued", gate=kind + "-before-capture")
        add("M", "admitted", point="measure-before-capture", disposition="run")
        add("M", "measure-start", **owner)
        add("M", "measure-before-commit", **owner, **{"dom.width":"874"})
        add("M", "held", gate="measure-before-commit")
        add("P", "work-start", **owner)
        add("P", "sample-before-capture", **owner)
        add("P", "queued", gate="sample-before-capture")
        add("M", "released", disposition="run")
        flags = dict.fromkeys(["ownerMatches", "anchorEqual", "anchorCurrentAtStart", "anchorCurrentNow",
                               "revisionMatches", "localMatches", "mayRestore"], "true")
        add("M", "measure-guard", **flags); add("M", "measure-finished", outcome="committed")
        add("M", "work-finished", captured="true")
        for request, kind, values in [("N", "measure", neighbor), ("P", "sample", owner)]:
            add(request, "admitted", point=kind + "-before-capture", disposition="run")
            add(request, kind + "-start", **values)
            add(request, kind + "-finished", outcome="committed")
            add(request, "work-finished", captured="true")
        add("done", "admission-complete", queued="0", running="0", waiters="0")
        add("close", "closing"); add("abort", "abort-issued", count="0")
        row = dict(nonce="fixture", stage=4, failure="none", active=[], tasks=[], waiters=[], queued=[], running=[], events=events)
        marker = "CONTINUOUS_FIXTURE_MECHANICS passed=6 liveSDKReceiptsRequired=true\n"
        def write(value, mechanics=marker):
            (self.root / "logs/reader-diagnostic.log").write_text(log + "\n" + mechanics + "CONTINUOUS_VIEWPORT_FIXTURE " + json.dumps(value) + "\n")
        write(row)
        result = verify_viewport_smoke(self.root)
        self.assertEqual(result["realTerminalReceipts"], 2)
        self.assertEqual(result["admissionRequests"], 3)
        self.assertTrue(result["serialDrainVerified"])
        with self.assertRaises(ValueError): verify_viewport_smoke(self.root, status=65)
        for mechanics in ["", marker + marker]:
            write(row, mechanics)
            with self.assertRaises(ValueError): verify_viewport_smoke(self.root)
        for key, value in [("stage", 3), ("failure", "late-commit"), ("active", ["S"]),
                           ("tasks", ["T"]), ("waiters", ["M"]), ("queued", ["N"]), ("running", ["P"])]:
            bad = deepcopy(row); bad[key] = value; write(bad)
            with self.assertRaises(ValueError): verify_viewport_smoke(self.root)
        ix = lambda request, kind: next(i for i, e in enumerate(events) if e["requestID"] == request and e["kind"] == kind)
        for index, key, value in [(1,"gate","cache-hit"), (2,"disposition","abort"),
                                   (3,"outcome","cached"), (ix("M","measure-guard"),"mayRestore","false"),
                                   (0,"nonce","other"), (ix("M","work-finished"),"captured","false"),
                                   (ix("M","admitted"),"point","measure-before-commit"),
                                   (ix("N","measure-start"),"epoch","other"),
                                   (ix("M","measure-before-commit"),"dom.width","402")]:
            bad = deepcopy(row); bad["events"][index][key] = value; write(bad)
            with self.assertRaises(ValueError): verify_viewport_smoke(self.root)
        for index in range(len(events)):
            bad = deepcopy(row); bad["events"].pop(index); write(bad)
            with self.assertRaises(ValueError): verify_viewport_smoke(self.root)
        # Preserve sequential numbering so these fail on the causal contract,
        # rather than merely noticing a missing/repeated sequence number.
        for moved, before in [(ix("M","measure-start"), ix("M","admitted")),
                               (ix("N","admitted"), ix("M","work-finished")),
                               (ix("P","admitted"), ix("N","admitted"))]:
            bad = deepcopy(row); event = bad["events"].pop(moved); bad["events"].insert(before, event)
            for i, event in enumerate(bad["events"]): event["sequence"] = str(i + 1)
            write(bad)
            with self.assertRaises(ValueError): verify_viewport_smoke(self.root)

    def test_viewport_smoke_route_is_single_case_and_passes_runner_environment(self):
        shell = (ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        block = shell.split("  continuous-resize-smoke)", 1)[1].split("    ;;", 1)[0]
        self.assertEqual(re.findall(r"-only-testing:XianxiaReaderTests/(\w+/\w+)", block), sorted(VIEWPORT_SMOKE_TESTS))
        self.assertIn("export TEST_RUNNER_XIANXIA_VIEWPORT_FIXTURE=smoke", block)
        workflow = yaml.load((ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        self.assertIn("continuous-resize-smoke", workflow["on"]["workflow_dispatch"]["inputs"]["diagnostic_selection"]["options"])
        jobs = workflow["jobs"]
        for name in ["core-tests", "reading-diagnostic"]:
            self.assertIn("!= 'continuous-resize-smoke'", jobs[name]["if"])
        self.assertNotIn("continuous-resize-smoke", jobs["ios"]["if"])
        self.assertIn("== 'continuous-resize-smoke'", jobs["reader-positions"]["if"])
        steps = [s for s in jobs["reader-positions"]["steps"] if "verify_reader_positions.py viewport-smoke" in s.get("run", "")]
        self.assertEqual(len(steps), 1)
        self.assertEqual(steps[0]["env"]["DIAGNOSTIC_SELECTION"], "${{ inputs.diagnostic_selection }}")
        self.assertIn("set -euo pipefail", steps[0]["run"])
        self.assertNotIn("retry", steps[0]["run"])

    def pair_fixture(self, mode, status=0, effect=None):
        effect = effect or ("unchanged" if mode=="paired-safe" else "anchor-replaced")
        values=dict(reader=mode,epoch="epoch",slot="body",webView="web",index="1",revision="1",localTop="100",
                    nativeWidth="402",nativeHeight="778",anchor="A",source="test-auxiliary",clipTop="0",clipBottom="778")
        neighbor=dict(values,slot="neighbor",webView="other-web",index="0")
        origin=dict(href="OEBPS/one.xhtml",selector="p",textNodeIndex="0",charOffset="499",viewportOffset="-3.125",
                    windowWidth="402",windowHeight="874",targetWidth="874",targetHeight="402",sampleSource="test-auxiliary")
        saved=dict(href=origin["href"],locations=dict(domRange=dict(start=dict(cssSelector="p",textNodeIndex=0,charOffset=499)),xianxiaViewportOffset=-3.125))
        events=[]
        def add(rid, kind, **fields):
            if kind in ["work-start", "work-finished"] or kind.startswith(("sample-", "measure-")):
                fields = {**(neighbor if rid == "N" else values), **fields}
            events.append(dict(fields,requestID=rid,kind=kind,sequence=str(len(events)+1),nonce="pair"))
        add("S","work-start",**values);add("S","sample-start",**values)
        add("S","sample-before-read",**values);add("S","held",gate="sample-before-read")
        old=dict(values,source="original-capture",outcome="committed")
        add("A","work-start",**old);add("A","sample-start",**old)
        add("A","sample-dom",**old,**{"dom.width":"402"})
        add("A","sample-finished",**old);add("A","work-finished",captured="true")
        add("arm","admission-armed",**values,targetWidth="874")
        add("S","pair-sealed",**origin,mode=mode)
        def finish_sample():
            add("S","released",point="sample-before-read",disposition="run")
            for attempt in range(3 if effect=="blocked" else 1):
                top=110 if effect=="blocked" else 100
                reason=("document-top-mismatch-retry" if attempt<2 else "document-top-mismatch-exhausted") if effect=="blocked" else ("snapshot-unavailable" if effect=="read-unavailable" else "committed")
                read=dict(values,attempt=str(attempt))
                read.update({"dom.width":"402" if mode=="paired-safe" else "874","dom.visibleTop":"0","dom.scrollY":str(top),"dom.documentTop":str(top)})
                add("S","sample-dom",**read)
                decision=dict.fromkeys(["notCancelled","epochMatches","indexMatches","slotMatches","movingMatches","notPositioning","revisionMatches","localMatches","viewportMatches"],"true")
                decision.update(attempt=str(attempt),reason=reason,snapshotAvailable=str(effect!="read-unavailable").lower(),documentTop=str(top),expectedDocumentTop="100",documentTopDelta=str(top-100),documentTopMatches=str(top==100).lower())
                add("S","sample-decision",**decision)
            end=dict(values,anchor="B" if effect=="anchor-replaced" else "A",outcome="rejected" if effect in ["blocked","read-unavailable"] else "committed",reason=reason)
            add("S","sample-finished",**end);add("S","work-finished",captured="true")
        if mode=="paired-safe":finish_sample()
        add("resize","pair-resize",mode=mode,width="874",height="402",attached="true")
        for rid,kind,data in [("N","measure",neighbor),("M","measure",values)]:
            add(rid,"work-start",**data);add(rid,kind+"-before-capture",**data);add(rid,"queued",gate=kind+"-before-capture")
        add("M","admitted",point="measure-before-capture",disposition="run")
        m=dict(values,nativeWidth="874",nativeHeight="306")
        add("M","measure-start",**m)
        add("M","measure-before-commit",**m,**{"dom.width":"874","result.height":"2000","result.anchorY":"96.875"})
        add("M","held",gate="measure-before-commit")
        add("P","work-start",**values);add("P","sample-before-capture",**values);add("P","queued",gate="sample-before-capture")
        if mode=="paired-conflict":finish_sample()
        add("M","released",point="measure-before-commit",disposition="run")
        guard=dict(m,anchor="B" if effect=="anchor-replaced" else "A",positioning="false")
        guard.update(dict.fromkeys(["ownerMatches","indexMatches","anchorCurrentAtStart","anchorCurrentNow","revisionMatches","localMatches"],"true"))
        guard.update(anchorEqual=str(effect!="anchor-replaced").lower(),mayRestore=str(effect!="anchor-replaced").lower())
        add("M","measure-guard",**guard);add("M","measure-finished",outcome="committed");add("M","work-finished",captured="true")
        add("M","pair-effect",effect=effect)
        for rid,kind,data in [("N","measure",neighbor),("P","sample",values)]:
            add(rid,"admitted",point=kind+"-before-capture",disposition="run");add(rid,kind+"-start",**data)
            add(rid,kind+"-finished",outcome="committed");add(rid,"work-finished",captured="true")
        add("drained","pair-drained",queued="0",running="0",waiters="0")
        predicate=dict(point="DOM",loaded="2",afterSequence=str(len(events)),sameWebView="true",attached="true",widthMatches="true",valid="true",alpha="1",visible=str(status==0).lower(),accepted=str(status==0).lower(),uptime="1.5")
        if status==0:add("accepted","admission-complete",queued="0",running="0",waiters="0")
        add("close","closing");add("abort","abort-issued",count="0")
        row=dict(nonce="pair",events=events,stage=4,failure="none",active=[],tasks=[],waiters=[],queued=[],running=[],pairMode=mode,pairPhase="visible",pairSampleID="S",pairMeasureID="M",pairOrigin=origin,pairEffect=effect,pairPredicate=predicate)
        cls,name=next(iter(VIEWPORT_SMOKE_TESTS)).split("/");prefix=f"Test Case '-[XianxiaReaderTests.{cls} {name}]' "
        base=prefix+"started.\n"+prefix+("passed" if status==0 else "failed")+" (1.000 seconds).\n"
        base+=f"CONTINUOUS_VIEWPORT_PAIR_MECHANICS mode={mode} passed=2 liveSDKReceiptsRequired=true\n"
        summary=dict(totalTestCount=1,passedTests=int(status==0),failedTests=int(status!=0),skippedTests=0,result="Passed" if status==0 else "Failed",testFailures=[] if status==0 else [{"failureText":"Continuous reader did not reach expected state"}])
        phases=["before-resize","passed-874","passed-402"] if status==0 else ["before-resize","failed-874"]
        resize=[dict(phase=p,origin=saved,originalWeb="web",uptime=i+1,polls=[]) for i,p in enumerate(phases)]
        for record,width,height,uptime in zip(resize[1:],[874,402],[306,778],[1.5,2.5]):
            dom=dict(width=width,height=height,y=100,valid=True,visible=status==0,widthMatches=True,accepted=status==0,
                     rect=dict(top=-3.125,bottom=20,left=50,right=60))
            record["polls"]=[dict(expectedWidth=width,sameWebView=True,attached=True,alpha=1,uptime=uptime,dom=dom)]
        return row,base,summary,resize

    def pair_with_return(self, cached=False):
        fixture = self.pair_fixture("paired-safe")
        events = fixture[0]["events"]
        insert_at = next(i for i,e in enumerate(events) if e["kind"] == "closing")
        context = dict(next(e for e in events if e["kind"] == "admission-armed"))
        for key in ["requestID", "kind", "sequence", "nonce", "targetWidth"]:
            context.pop(key)
        context.update(source="native", revision="3", localTop="2151", nativeWidth="402", nativeHeight="778")
        tail = []
        def add(rid, kind, **fields):
            tail.append({**context, **fields})
            tail[-1].update(requestID=rid, kind=kind, nonce="pair")
        for rid in ["return-M1", "return-M2"]:
            add(rid,"work-start");add(rid,"measure-before-capture");add(rid,"measure-start")
            add(rid,"measure-before-commit",**{"dom.width":"402","dom.height":"778","dom.scrollY":"2151",
                                               "result.height":"8318","result.anchorY":"2336.875"})
            guard=dict.fromkeys(["ownerMatches","indexMatches","anchorCurrentAtStart","anchorCurrentNow",
                                 "anchorEqual","revisionMatches","localMatches","mayRestore"],"true")
            if rid == "return-M2":
                guard.update(anchorCurrentAtStart="false",anchorCurrentNow="false",mayRestore="false")
            add(rid,"measure-guard",positioning="false",**guard)
            context.update(revision="4", localTop="2340")
            add(rid,"measure-finished",outcome="committed");add(rid,"work-finished",captured="true")
        rid="return-S"
        add(rid,"work-start");add(rid,"sample-before-capture");add(rid,"sample-start")
        if not cached:
            add(rid,"sample-before-read")
            add(rid,"sample-dom",attempt="0",**{"dom.documentTop":"2340","dom.scrollY":"2340","dom.visibleTop":"0"})
            guard=dict.fromkeys(["notCancelled","epochMatches","indexMatches","slotMatches","movingMatches",
                                 "notPositioning","revisionMatches","localMatches","viewportMatches"],"true")
            add(rid,"sample-decision",attempt="0",reason="committed",snapshotAvailable="true",documentTop="2340",
                expectedDocumentTop="2340",documentTopDelta="0",documentTopMatches="true",**guard)
        add(rid,"sample-finished",outcome="cached" if cached else "committed",reason="cached" if cached else "committed")
        add(rid,"work-finished",captured="true")
        events[insert_at:insert_at]=tail
        self.resequence_pair(fixture)
        return fixture

    @staticmethod
    def resequence_pair(fixture):
        for i,e in enumerate(fixture[0]["events"]):
            e["sequence"]=str(i+1)
        drains=[e for e in fixture[0]["events"] if e["kind"]=="pair-drained"]
        if drains:
            fixture[0]["pairPredicate"]["afterSequence"]=drains[-1]["sequence"]

    def assert_pair_rejected(self, fixture, status=0):
        self.write_pair(self.root/"bad", fixture)
        with self.assertRaises(ValueError):
            verify_viewport_pair_arm(self.root/"bad", fixture[0]["pairMode"], status)

    def test_paired_return_audits_each_request_without_forcing_fifo_or_restore(self):
        for cached in [False, True]:
            fixture=self.pair_with_return(cached)
            self.write_pair(self.root/"return",fixture)
            proof=verify_viewport_pair_arm(self.root/"return","paired-safe")
            self.assertEqual([v["requestID"] for v in proof["postControlRequests"]],["return-M1","return-M2","return-S"])
            self.assertEqual(proof["postControlRequestCount"],3)
            self.assertTrue(proof["allSDKEventsAccounted"] and proof["originalWideNarrowDOMVerified"])
        # Natural SDK work may overlap and belong to a neighboring resource.
        fixture=self.pair_with_return();events=fixture[0]["events"]
        second=[e for e in events if e["requestID"]=="return-M2"]
        for e in second:
            e.update(slot="neighbor",webView="neighbor-web",index="0")
            if e["kind"]=="measure-guard":e["indexMatches"]="false"
        events[:]=[e for e in events if e not in second]
        first=next(i for i,e in enumerate(events) if e["requestID"]=="return-M1")
        events[first:first]=second[:3];events[-2:-2]=second[3:]
        self.resequence_pair(fixture);self.write_pair(self.root/"overlap",fixture)
        self.assertEqual(verify_viewport_pair_arm(self.root/"overlap","paired-safe")["postControlRequestCount"],3)
        self.write_pair(self.root/"none",self.pair_fixture("paired-safe"))
        self.assertEqual(verify_viewport_pair_arm(self.root/"none","paired-safe")["postControlRequestCount"],0)

    def test_paired_return_rejects_each_missing_duplicate_mixed_or_false_receipt(self):
        fixture=self.pair_with_return();events=fixture[0]["events"]
        indices=[i for i,e in enumerate(events) if e["requestID"].startswith("return-")]
        for i in indices:
            for operation in ["delete","duplicate"]:
                with self.subTest(request=events[i]["requestID"],kind=events[i]["kind"],operation=operation):
                    bad=deepcopy(fixture)
                    if operation=="delete":bad[0]["events"].pop(i)
                    else:bad[0]["events"].insert(i,deepcopy(events[i]))
                    self.resequence_pair(bad);self.assert_pair_rejected(bad)
            for key in ["reader","epoch","slot","webView","index"]:
                with self.subTest(kind=events[i]["kind"],key=key):
                    bad=deepcopy(fixture);bad[0]["events"][i][key]="wrong";self.assert_pair_rejected(bad)
        for kind,key,value in [("work-finished","captured","false"),("sample-finished","reason","not-finished"),
                               ("measure-finished","outcome","not-committed"),("measure-guard","mayRestore","false"),
                               ("sample-decision","documentTopDelta","600"),("sample-dom","dom.scrollY","1767")]:
            bad=deepcopy(fixture);e=next(e for e in bad[0]["events"] if e["requestID"].startswith("return-") and e["kind"]==kind)
            e[key]=value;self.assert_pair_rejected(bad)
        for kind in ["sample-start","sample-finished","measure-guard"]:
            bad=deepcopy(fixture);bad[0]["events"].insert(-2,dict(events[-3],requestID="orphan",kind=kind))
            self.resequence_pair(bad);self.assert_pair_rejected(bad)
        bad=deepcopy(fixture);bad[0]["events"][-3]["requestID"]="M";self.assert_pair_rejected(bad)
        bad=deepcopy(fixture);moving=bad[0]["events"].pop(-3);bad[0]["events"].append(moving)
        self.resequence_pair(bad);self.assert_pair_rejected(bad)
        bad=self.pair_with_return(True)
        next(e for e in bad[0]["events"] if e["requestID"]=="return-S" and e["kind"]=="sample-finished")["reason"]="committed"
        self.assert_pair_rejected(bad)

    def test_paired_return_keeps_actual_sample_branches_and_original_attempt_budget(self):
        fixture=self.pair_with_return();events=fixture[0]["events"]
        read=next(e for e in events if e["requestID"]=="return-S" and e["kind"]=="sample-dom")
        verdict=next(e for e in events if e["requestID"]=="return-S" and e["kind"]=="sample-decision")
        for terminal_reason in ["committed","document-top-mismatch-exhausted","snapshot-unavailable"]:
            branch=deepcopy(fixture);rows=branch[0]["events"]
            if terminal_reason=="snapshot-unavailable":
                next(e for e in rows if e["requestID"]=="return-S" and e["kind"]=="sample-decision").update(
                    reason=terminal_reason,snapshotAvailable="false")
            else:
                at=next(i for i,e in enumerate(rows) if e["requestID"]=="return-S" and e["kind"]=="sample-dom")
                attempts=[]
                for i in range(3):
                    last=i==2;success=last and terminal_reason=="committed";top=2340 if success else 2342
                    attempts.extend([dict(read,attempt=str(i),**{"dom.documentTop":str(top),"dom.scrollY":str(top)}),
                        dict(verdict,attempt=str(i),reason="committed" if success else "document-top-mismatch-exhausted" if last else "document-top-mismatch-retry",
                             documentTop=str(top),documentTopDelta=str(top-2340),documentTopMatches=str(success).lower())])
                rows[at:at+2]=attempts
            if terminal_reason!="committed":
                next(e for e in rows if e["requestID"]=="return-S" and e["kind"]=="sample-finished").update(
                    outcome="rejected",reason=terminal_reason)
            self.resequence_pair(branch);self.write_pair(self.root/terminal_reason,branch)
            proof=verify_viewport_pair_arm(self.root/terminal_reason,"paired-safe")
            self.assertEqual(proof["postControlRequests"][-1]["outcome"],"committed" if terminal_reason=="committed" else "rejected")
            if terminal_reason=="committed":
                bad=deepcopy(branch);rows=bad[0]["events"]
                at=next(i for i,e in enumerate(rows) if e["requestID"]=="return-S" and e["kind"]=="sample-finished")
                rows[at:at]=[dict(read,attempt="3"),dict(verdict,attempt="3")]
                self.resequence_pair(bad);self.assert_pair_rejected(bad)
        for kind,key,value in [("sample-before-read","clipTop","2"),("sample-dom","revision","9"),
                               ("sample-decision","localTop","1767"),("sample-finished","anchor","nil")]:
            bad=deepcopy(fixture)
            next(e for e in bad[0]["events"] if e["requestID"]=="return-S" and e["kind"]==kind)[key]=value
            self.assert_pair_rejected(bad)
        bad=self.pair_with_return(True)
        next(e for e in bad[0]["events"] if e["requestID"]=="return-S" and e["kind"]=="sample-finished")["anchor"]="different"
        self.assert_pair_rejected(bad)
        bad=deepcopy(fixture);rows=bad[0]["events"]
        while len(rows)<=128:rows.insert(-2,dict(read,requestID="overflow"))
        self.resequence_pair(bad);self.assert_pair_rejected(bad)

    def test_paired_admission_end_cannot_hide_crossing_work_or_continuations(self):
        fixture=self.pair_with_return();events=fixture[0]["events"]
        complete=next(i for i,e in enumerate(events) if e["kind"]=="admission-complete")
        for action in ["missing","duplicate","early","late","pending","post-permission"]:
            with self.subTest(action=action):
                bad=deepcopy(fixture);rows=bad[0]["events"]
                if action=="missing":rows.pop(complete)
                elif action=="duplicate":rows.insert(complete,dict(rows[complete]))
                elif action=="early":rows.insert(complete-3,rows.pop(complete))
                elif action=="late":rows.insert(complete+2,rows.pop(complete))
                elif action=="pending":rows[complete]["waiters"]="1"
                else:rows.insert(-2,dict(rows[-3],kind="admitted",point="sample-before-capture",disposition="run"))
                self.resequence_pair(bad);self.assert_pair_rejected(bad)
        # A controlled request whose finish is delayed beyond complete remains controlled.
        bad=deepcopy(fixture);rows=bad[0]["events"]
        moving=next(e for e in rows if e["requestID"]=="P" and e["kind"]=="work-finished")
        rows.remove(moving);rows.insert(-2,moving);self.resequence_pair(bad);self.assert_pair_rejected(bad)
        bad=deepcopy(fixture);rows=bad[0]["events"]
        for e in rows:
            if e["requestID"]=="return-M1":e["requestID"]="M"
        self.assert_pair_rejected(bad)

    def test_paired_return_requires_real_wide_and_narrow_dom_and_keeps_failure_65(self):
        fixture=self.pair_with_return()
        for which in [1,2]:
            for action in ["no-poll","origin","origin-metadata","web","not-attached","invisible","wrong-width","wrong-expected","nan","offscreen","stale-poll"]:
                with self.subTest(direction=which,action=action):
                    bad=deepcopy(fixture);record=bad[3][which];poll=record["polls"][-1]
                    if action=="no-poll":record["polls"]=[]
                    elif action=="origin":record["origin"]["locations"]["domRange"]["start"]["charOffset"]=1
                    elif action=="origin-metadata":record["origin"]=dict(record["origin"],text={"highlight":"changed"})
                    elif action=="web":record["originalWeb"]="other-web"
                    elif action=="not-attached":poll["attached"]=False
                    elif action=="invisible":poll["dom"]["visible"]=False
                    elif action=="wrong-width":poll["dom"]["width"]+=50
                    elif action=="wrong-expected":poll["expectedWidth"]+=50
                    elif action=="nan":poll["dom"]["rect"]["left"]=float("nan")
                    elif action=="offscreen":poll["dom"]["rect"].update(top=10000,bottom=10020)
                    else:poll["uptime"]=4
                    self.assert_pair_rejected(bad)
        bad=deepcopy(fixture);bad[3][2]["polls"]=deepcopy(bad[3][1]["polls"]);self.assert_pair_rejected(bad)
        for direction in ["wide","narrow"]:
            if direction=="wide":failed=self.pair_fixture("paired-conflict",65)
            else:
                failed=list(deepcopy(fixture));failed[1]=failed[1].replace("' passed (","' failed (")
                failed[2].update(passedTests=0,failedTests=1,result="Failed",testFailures=[dict(failureText="Continuous reader did not reach expected state")])
                failed[3][-1]["phase"]="failed-402";failed[3][-1]["polls"][-1]["dom"].update(accepted=False,visible=False)
            self.write_pair(self.root/direction,failed)
            proof=verify_viewport_pair_arm(self.root/direction,failed[0]["pairMode"],65)
            self.assertEqual(proof["originalExit"],65);self.assertFalse(proof["originalPassed"])
            self.assertFalse(proof["originalWideNarrowDOMVerified"])
            if direction=="narrow":self.assertEqual(proof["classification"],"other-original-failure")

    def write_pair(self, folder, fixture):
        row,base,summary,resize=fixture
        (folder/"logs").mkdir(parents=True,exist_ok=True)
        (folder/"logs/reader-diagnostic.log").write_text(base+"CONTINUOUS_VIEWPORT_PAIR "+json.dumps(row)+"\n"+"".join("CONTINUOUS_RESIZE_EVIDENCE "+json.dumps(x)+"\n" for x in resize),encoding="utf-8")
        (folder/"test-results-summary.json").write_text(json.dumps(summary),encoding="utf-8")

    def test_preparation_metadata_cannot_qualify_unarmed_safe_failure(self):
        for include_diagnostics in [False, True]:
            failed = list(self.pair_fixture("paired-safe", 65))
            row = failed[0]
            row.update(stage=0, pairPhase="seal", pairSampleID=None, pairMeasureID=None,
                       pairEffect="pending", pairOrigin={}, pairPredicate={},
                       preparation={"completed":False, "firstError":{"stage":"cover-probe.javascript",
                           "errorType":"CancellationError", "taskCancelled":"false"},
                           "firstCleanup":{"stage":"cleanUp"}})
            row["events"] = [dict(requestID="close",kind="closing",sequence="1",nonce="pair"),
                             dict(requestID="abort",kind="abort-issued",count="0",sequence="2",nonce="pair")]
            row["readDiagnostics"] = ([dict(kind="sample-read-inner-buffer-delivery",buffered="1",
                preArmDropped="0",incomplete="false",frameworkVersion="observed",restored="true")]
                if include_diagnostics else [])
            failed[2]["testFailures"] = [dict(failureText="CancellationError()")]
            failed[3] = []
            # Original 65 and no S/M/word proof still fail, including when
            # cleanup is empty and additional diagnostic labels look complete.
            self.assert_pair_rejected(failed, status=65)

    def test_preparation_metadata_cannot_replace_sdk_or_return_receipts(self):
        fixture = self.pair_with_return()
        fixture[0].update(preparation={"completed":True,"firstError":{},"firstCleanup":{"stage":"cleanUp"}},
            readDiagnostics=[dict(kind="sample-read-inner-buffer-delivery",incomplete="false",
                                  buffered="1",preArmDropped="0",outcome="committed")])
        self.write_pair(self.root/"original",fixture)
        proof = verify_viewport_pair_arm(self.root/"original","paired-safe",0)
        self.assertEqual(proof["originalExit"],0)
        for rid, kind in [("S","sample-finished"),("M","measure-guard"),
                          ("return-M1","work-finished"),("return-S","sample-decision")]:
            bad = deepcopy(fixture)
            bad[0]["events"] = [e for e in bad[0]["events"] if (e["requestID"],e["kind"]) != (rid,kind)]
            self.resequence_pair(bad)
            self.assert_pair_rejected(bad)
        bad=deepcopy(fixture);bad[3][-1]["polls"][-1]["dom"]["visible"]=False
        self.assert_pair_rejected(bad)

    def test_paired_arms_separate_original_failure_from_state_change_and_keep_exit(self):
        safe_folder=self.root/"safe";safe_fixture=self.pair_fixture("paired-safe")
        self.write_pair(safe_folder,safe_fixture);safe=verify_viewport_pair_arm(safe_folder,"paired-safe")
        self.assertEqual(safe["classification"],"unchanged")
        for status,effect,classification in [(0,"anchor-replaced","state-interleaving-only"),
                (65,"anchor-replaced","candidate-controlled-word-failure"),(0,"unchanged","unchanged"),
                (0,"blocked","blocked"),(0,"read-unavailable","read-unavailable")]:
            folder=self.root/f"conflict-{effect}-{status}";fixture=self.pair_fixture("paired-conflict",status,effect)
            self.write_pair(folder,fixture);result=verify_viewport_pair_arm(folder,"paired-conflict",status)
            self.assertEqual(result["classification"],classification)
            self.assertEqual(result["originalExit"],status)
            pair=compare_viewport_pair_receipts(safe,result)
            self.assertEqual(pair["originalExits"],[0,status]);self.assertTrue(pair["semanticPairCompatible"])
            self.assertFalse(pair["matchedBuildVerified"]);self.assertFalse(pair["matchedPairAccepted"])
            self.assertFalse(pair["oldFullRootCauseProven"])
        bad=deepcopy(result);bad["origin"]["sampleSource"]="native"
        with self.assertRaises(ValueError):compare_viewport_pair_receipts(safe,bad)
        with self.assertRaises(ValueError):compare_viewport_pair_receipts(dict(safe,originalPassed=False),result)
        failed=self.pair_fixture("paired-conflict",65)
        for key,value in [("sameWebView","false"),("attached","false"),("valid","false"),("widthMatches","false"),("alpha","0.1")]:
            bad=deepcopy(failed);bad[0]["pairPredicate"][key]=value;self.write_pair(self.root/"other",bad)
            self.assertEqual(verify_viewport_pair_arm(self.root/"other","paired-conflict",65)["classification"],"other-original-failure")

    def test_paired_receipts_reject_confounds_early_resume_wrong_gate_and_missing_evidence(self):
        fixture=self.pair_fixture("paired-conflict");row=fixture[0];events=row["events"]
        ix=lambda rid,kind:next(i for i,e in enumerate(events) if e["requestID"]==rid and e["kind"]==kind)
        def rejected(bad,status=0):
            self.write_pair(self.root/"bad",bad)
            with self.assertRaises(ValueError):verify_viewport_pair_arm(self.root/"bad","paired-conflict",status)
        for key,value in [("pairMode","smoke"),("pairPhase","newSample"),("failure","context-invalid"),
                ("active",["S"]),("tasks",["aux"]),("waiters",["M"]),("queued",["P"]),("running",["N"])]:
            bad=deepcopy(fixture);bad[0][key]=value;rejected(bad)
        for rid,kind,key,value in [("S","sample-dom","dom.width","402"),("S","sample-dom","clipTop","2"),
                ("S","sample-decision","documentTopDelta","50"),("S","sample-decision","revisionMatches","false"),
                ("M","measure-guard","indexMatches","false"),("M","measure-guard","localMatches","false"),
                ("M","measure-guard","anchorEqual","true"),("M","measure-before-commit","result.anchorY","nan"),
                ("M","released","point","measure-before-capture"),("P","admitted","point","sample-before-read"),
                ("P","work-finished","captured","false"),("A","sample-dom","dom.width","874")]:
            bad=deepcopy(fixture);bad[0]["events"][ix(rid,kind)][key]=value;rejected(bad)
        for rid,kind,before_rid,before_kind in [("S","released","M","held"),("M","released","S","work-finished"),
                ("N","admitted","M","work-finished"),("P","sample-start","P","admitted")]:
            bad=deepcopy(fixture);moving=bad[0]["events"].pop(ix(rid,kind));bad[0]["events"].insert(ix(before_rid,before_kind),moving)
            for i,e in enumerate(bad[0]["events"]):e["sequence"]=str(i+1)
            rejected(bad)
        for i in range(len(events)):
            bad=deepcopy(fixture);bad[0]["events"].pop(i);rejected(bad)
        bad=list(deepcopy(fixture));bad[1]+=bad[1];rejected(bad)
        bad=deepcopy(fixture);bad[2]["passedTests"]=0;rejected(bad)
        # The existing smoke route and CLI remain unchanged; pairing has no CI wiring here.
        with self.assertRaises(ValueError):verify_viewport_pair_arm(self.root/"bad","smoke")

    @unittest.skipIf(os.name == "nt", "POSIX executable fixture validated on Linux CI")
    def test_shell_preserves_swift_failure_and_rejects_stale_evidence(self):
        self.logic()
        (self.root / "scripts").mkdir()
        (self.root / "fakebin").mkdir()
        for name in ["test_reader_positions.sh", "verify_reader_positions.py"]:
            shutil.copyfile(ROOT / "scripts" / name, self.root / "scripts" / name)
        helpers = {
            "swift": '#!/bin/bash\nset -eu\ncase "$1" in\n--version) echo fixture;;\npackage) cat dependencies.json;;\ntest) while [[ "$1" != --xunit-output ]]; do shift; done; shift; cp tests.xml "$1"; exit "$POSITION_TEST_EXIT";;\n*) exit 97;;\nesac\n',
        }
        for name, content in helpers.items():
            path = self.root / "fakebin" / name
            path.write_text(content); path.chmod(0o755)
        for mode, expected in [("success", 0), ("swift-failure", 65), ("stale", 2)]:
            with self.subTest(mode=mode):
                output = f"build/{mode}"
                if mode == "stale": (self.root / output).mkdir(parents=True)
                env = dict(os.environ, POSITION_TEST_EXIT="65" if mode == "swift-failure" else "0")
                result = subprocess.run(["bash", "-c", f'PATH="$PWD/fakebin:$PATH" bash scripts/test_reader_positions.sh {output}'],
                                        cwd=self.root, env=env, capture_output=True, text=True)
                self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
                self.assertEqual((self.root / output / "receipt.json").exists(), mode == "success")
