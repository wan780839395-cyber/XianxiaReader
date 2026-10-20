"""Verify the real SwiftPM 6.1 xUnit report and its resolved local dependency tree."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import xml.etree.ElementTree as ET

EXPECTED_TESTS = {
    "testAppearanceWritesAcrossReadersStayOrderedAndObsoleteResultsAreNotPublished",
    "testLatestAppearanceFailureIsVisibleUntilExplicitRetrySucceeds",
    "testInteractionWritesKeepLatestValueAndFailureIndependentOfAppearance",
    "testFlushIncludesAppearanceQueuedWhileWaitingForInteraction",
    "testNewReaderRestoreWaitsForPendingAppearanceWrite",
    "testStorageReadErrorPropagatesWithoutReplacingSettingsWithDefaults",
    "testRealFileStoreKeepsExistingPreferencePathsAndValues",
}


def verify(xml_path, dependencies_path):
    tree = ET.parse(xml_path).getroot()
    suites = list(tree.iter("testsuite"))
    if len(suites) != 1 or any(int(suites[0].get(key, "0")) != 0 for key in ["errors", "failures", "skipped"]):
        raise ValueError("Logic report contains failures/errors/skips or an unexpected suite")
    cases = list(tree.iter("testcase"))
    names = Counter()
    for case in cases:
        if case.get("classname") not in {"ReaderSettingsPersistenceTests", "ReaderSettingsTests.ReaderSettingsPersistenceTests"}:
            raise ValueError("Unexpected logic test class")
        if any(child.tag in {"failure", "error", "skipped"} for child in case.iter()):
            raise ValueError("Logic testcase failed or skipped")
        names[case.get("name", "").removesuffix("()")] += 1
    if names != Counter({name: 1 for name in EXPECTED_TESTS}) or int(suites[0].get("tests", "-1")) != len(EXPECTED_TESTS):
        raise ValueError("Logic report must execute each of the seven original contracts exactly once")
    packages = []

    def visit(package):
        packages.append(package["name"])
        for child in package["dependencies"]:
            visit(child)

    visit(json.loads(Path(dependencies_path).read_text(encoding="utf-8")))
    if Counter(packages) != Counter(["ReaderSettings", "XianxiaCore"]):
        raise ValueError("Fast logic dependencies must be ReaderSettings + XianxiaCore only")
    return {"recordedAtUTC": datetime.now(timezone.utc).isoformat(), "validationKind": "macos_swiftpm_logic",
            "passed": len(names), "failed": 0, "skipped": 0, "packages": packages,
            "cases": sorted(names), "appHostUsed": False, "readiumResolved": False,
            "iOSIntegrationAccepted": False, "releaseAccepted": False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("xml", type=Path)
    parser.add_argument("dependencies", type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    report = verify(args.xml, args.dependencies)
    args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("PASS ReaderSettings logic: 7/7 original contracts; Core-only dependency graph; not release acceptance")


if __name__ == "__main__":
    main()
