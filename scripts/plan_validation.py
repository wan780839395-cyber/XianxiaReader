"""Produce a conservative validation plan; never run, skip or certify tests."""
import argparse
import json
from pathlib import Path, PurePosixPath, PureWindowsPath

from check_architecture import ROOT, check_architecture

COMMANDS = {
    "repository": "python scripts/check_repository.py --swift-syntax",
    "tooling": "python -m unittest discover -s scripts -p 'test_*.py' -v",
    "reader-logic": "bash scripts/test_reader_logic.sh <fresh-output-folder>",
    "core": "swift test --package-path Packages/XianxiaCore --parallel",
    "ios-integration": "bash scripts/ci_reader_diagnostic.sh settings (settings changes); full integration for other App/engine changes",
    "native-ui": "existing native UI regressions for the affected feature; full UI at delivery",
}


def plan(changed, root=ROOT):
    architecture = check_architecture(root)
    sources = {source["file"]: source for source in architecture["sources"]}
    seeds, reasons = set(), []
    tiers = {"repository"}
    fallback = False
    for value in changed:
        file = str(PurePosixPath(value.replace("\\", "/")))
        if PurePosixPath(file).is_absolute() or PureWindowsPath(file).is_absolute() or ".." in PurePosixPath(file).parts:
            raise ValueError("Changed paths must be repository-relative")
        if file in sources:
            seeds.update(sources[file]["compiledTargets"])
            reasons.append({"file": file, "owners": sources[file]["compiledTargets"]})
        elif (file.startswith("Documentation/") and file.endswith(".md")) or ("/" not in file and file.endswith(".md")):
            reasons.append({"file": file, "scope": "documentation"})
        elif file.startswith("scripts/") and file.endswith(".py"):
            tiers.add("tooling")
            reasons.append({"file": file, "scope": "Python tooling"})
        else:
            fallback = True
            reasons.append({"file": file, "scope": "shared input or unknown/deleted source; conservative full validation"})
    affected = set(seeds)
    while True:
        expanded = affected | {name for name, dependencies in architecture["targets"].items() if set(dependencies) & affected}
        if expanded == affected:
            break
        affected = expanded
    if affected & {"ReaderSettings", "ReaderSettingsTests"}:
        tiers.add("reader-logic")
    if affected & {"XianxiaCore", "XianxiaCoreTests", "TXTPerformanceProbe"}:
        tiers.add("core")
    if affected & {"XianxiaReader", "XianxiaReaderTests", "ReadiumAdapter", "ReadingInterfaces"}:
        tiers.add("ios-integration")
    if "XianxiaReaderUITests" in affected:
        tiers.add("native-ui")
    if fallback:
        tiers.update(COMMANDS)
    order = [name for name in COMMANDS if name in tiers]
    return {"planOnly": True, "acceptanceGranted": False, "changed": changed, "reasons": reasons,
            "affectedTargets": sorted(affected), "conservativeFallback": fallback,
            "checksInOrder": [{"name": name, "command": COMMANDS[name]} for name in order],
            "releaseGate": {"unchanged": True, "command": "bash scripts/ci_ios.sh", "mustUseFrozenInputs": True},
            "limits": "The current App still shares a target; this map is conservative and does not infer semantic independence or authorize UI-result reuse."}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--changed", required=True, nargs="+")
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    result = plan(args.changed)
    output = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(output, encoding="utf-8")
    print(output, end="")


if __name__ == "__main__":
    main()
