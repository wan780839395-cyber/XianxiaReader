"""Windows-capable repository validation. This is deliberately NOT a Swift compiler."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import plistlib
import sqlite3
import struct
import sys
import xml.etree.ElementTree as ET
from zipfile import ZipFile, ZIP_STORED

ROOT = Path(__file__).resolve().parents[1]
LOCAL_DEPS = ROOT / ".cache" / "check-deps"
if LOCAL_DEPS.is_dir():
    sys.path.insert(0, str(LOCAL_DEPS))
import yaml


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def check_documents() -> None:
    for name in ["README.md", "ARCHITECTURE.md", "ROADMAP.md", "AGENTS.md", "PROJECT_STATUS.md", "HANDOFF.md",
                 "Future/XBook/SPEC.md", "Future/Knowledge/README.md", "Documentation/FEATURE_MATRIX.md"]:
        require((ROOT / name).is_file(), f"Missing document: {name}")


def check_project() -> None:
    # BaseLoader preserves the YAML 1.2 Actions key 'on', which YAML 1.1 treats as a boolean.
    project = yaml.load((ROOT / "project.yml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
    require(project["name"] == "XianxiaReader", "Unexpected project name")
    require(project["options"]["deploymentTarget"]["iOS"] == "16.0", "iOS baseline drift")
    for spec in project["packages"].values():
        require((ROOT / spec["path"] / "Package.swift").is_file(), "Missing local Swift package")
    for target in project["targets"].values():
        for source in target["sources"]:
            require((ROOT / source["path"]).exists(), f"Missing target source: {source['path']}")
    with (ROOT / "App/Resources/Info.plist").open("rb") as file:
        info = plistlib.load(file)
    require(info["CFBundlePackageType"] == "APPL", "Info.plist is not an application")
    require(project["targets"]["XianxiaReader"]["settings"]["base"]["INFOPLIST_FILE"] == "App/Resources/Info.plist",
            "App target must use the committed Info.plist")
    require("info" not in project["targets"]["XianxiaReader"], "XcodeGen must not overwrite the committed plist")
    for asset in (ROOT / "App/Resources/Assets.xcassets").rglob("Contents.json"):
        json.loads(asset.read_text(encoding="utf-8"))
    require(project["targets"]["XianxiaReader"]["settings"]["base"]["ASSETCATALOG_COMPILER_APPICON_NAME"] == "AppIcon",
            "App icon setting missing")
    iconset = ROOT / "App/Resources/Assets.xcassets/AppIcon.appiconset"
    icon = json.loads((iconset / "Contents.json").read_text(encoding="utf-8"))["images"][0]
    png = (iconset / icon["filename"]).read_bytes()
    require(png[:8] == b"\x89PNG\r\n\x1a\n" and png[12:16] == b"IHDR"
            and struct.unpack(">II", png[16:24]) == (1024, 1024) and png[25] == 2,
            "AppIcon must contain an opaque RGB 1024x1024 PNG")
    manifest = (ROOT / "Packages/XianxiaReading/Package.swift").read_text(encoding="utf-8")
    require('.package(path: "../../Vendor/ReadiumToolkit")' in manifest, "Maintained Readium package missing")
    from verify_readium_lock import verify_lock
    verify_lock(ROOT / "Package.resolved", allow_upstream=True)
    require('ReadiumAdapterGCDWebServer' not in manifest, "Do not add an EPUB HTTP server dependency")
    for source in (ROOT / "Packages/XianxiaCore/Sources/XianxiaCore").rglob("*.swift"):
        for line in source.read_text(encoding="utf-8").splitlines():
            require(not line.startswith(("import SwiftUI", "import UIKit", "import Readium")),
                    f"Core architecture boundary violated: {source}")


def check_workflow() -> None:
    workflow = yaml.load((ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
    require("workflow_dispatch" in workflow["on"], "Manual CI trigger missing")
    job = workflow["jobs"]["ios"]
    core = workflow["jobs"]["core-tests"]
    require(core["container"]["image"] == "swift:6.1.2-jammy@sha256:1122c18e938491180820e9b4902c489dadd5a89f7e6bd99ff9b64e7f1b18f41f",
            "Core Swift compiler and image digest pin missing")
    require("core-tests" in job["needs"], "iOS build must wait for actual Core tests")
    require(job["runs-on"] == "macos-15-intel", "Pinned 14GB Intel macOS runner drift")
    require(workflow["jobs"]["reading-diagnostic"]["runs-on"] == "macos-15-intel",
            "Native diagnostics must use the same pinned runner")
    require(job["env"]["DEVELOPER_DIR"].endswith("Xcode_16.4.app/Contents/Developer"), "Xcode drift")
    diagnostic = next(step for step in job["steps"] if step.get("name", "").startswith("Upload build logs"))
    require(diagnostic.get("if") == "always()", "Failed builds must upload diagnostics")
    script = (ROOT / "scripts/ci_ios.sh").read_text(encoding="utf-8")
    require("set -euo pipefail" in script, "CI failure propagation missing")
    require("CODE_SIGNING_ALLOWED=NO" in script and "xcodebuild test" in script, "Build/test flags missing")
    require(script.count("-onlyUsePackageVersionsFromResolvedFile") == 3,
            "Resolve, simulator test and device build must use locked dependency versions")
    require("|| true" not in script and "continue-on-error" not in (ROOT / ".github/workflows/ios-build.yml").read_text(),
            "CI must not hide failures")


def check_schema() -> None:
    migration = ROOT / "Packages/XianxiaCore/Sources/XianxiaCore/Database/Migrations/001_initial.sql"
    with sqlite3.connect(":memory:") as database:
        database.execute("PRAGMA foreign_keys=ON")
        database.executescript(migration.read_text(encoding="utf-8"))
        require(database.execute("PRAGMA user_version").fetchone()[0] == 1, "Missing schema version")
        database.executescript((migration.parent / "002_removed_books.sql").read_text(encoding="utf-8"))
        require(database.execute("PRAGMA user_version").fetchone()[0] == 2, "Missing recoverable removal migration")
        database.executescript((migration.parent / "003_import_identities.sql").read_text(encoding="utf-8"))
        require(database.execute("PRAGMA user_version").fetchone()[0] == 3, "Missing import identity migration")
        tables = {row[0] for row in database.execute("SELECT name FROM sqlite_master WHERE type='table'")}
        require(tables == {"books", "chapters", "reading_positions", "bookmarks", "removed_books", "book_import_identities"}, "Unexpected MVP schema")
        require(database.execute("PRAGMA integrity_check").fetchone()[0] == "ok", "Schema integrity failed")
        database.execute("INSERT INTO books VALUES ('book', ?, 0)", (b"{}",))
        database.execute("INSERT INTO chapters VALUES ('c1', 'book', 0, ?)", (b"{}",))
        for sql in ["INSERT INTO chapters VALUES ('bad', 'book', -1, X'00')",
                    "INSERT INTO chapters VALUES ('c2', 'book', 0, X'00')",
                    "INSERT INTO reading_positions VALUES ('unknown', 0.5, 0, X'00')",
                    "INSERT INTO removed_books VALUES ('unknown', 0)",
                    "INSERT INTO reading_positions VALUES ('book', 2, 0, X'00')"]:
            try:
                database.execute(sql)
            except sqlite3.IntegrityError:
                pass
            else:
                raise ValueError(f"Missing database constraint: {sql}")
        database.execute("DELETE FROM books WHERE id='book'")
        require(database.execute("SELECT count(*) FROM chapters").fetchone()[0] == 0, "Cascade delete missing")


def check_fixtures() -> None:
    ns = {"opf": "http://www.idpf.org/2007/opf", "dc": "http://purl.org/dc/elements/1.1/"}
    for version in [2, 3]:
        with ZipFile(ROOT / f"Tests/Fixtures/chinese-epub{version}.epub") as archive:
            entries = archive.infolist()
            require(entries[0].filename == "mimetype" and entries[0].compress_type == ZIP_STORED, "EPUB mimetype must be first and stored")
            require(archive.read("mimetype") == b"application/epub+zip", "Incorrect EPUB mimetype")
            for name in archive.namelist():
                require(not name.startswith("/") and ".." not in Path(name).parts, "Unsafe fixture ZIP path")
                if name.endswith((".xml", ".opf", ".xhtml", ".ncx", ".svg")):
                    ET.fromstring(archive.read(name))
            opf = ET.fromstring(archive.read("OEBPS/package.opf"))
            require(opf.attrib["version"] == f"{version}.0", "Wrong EPUB version")
            require(opf.findtext("opf:metadata/dc:title", namespaces=ns) == "云海问道·测试样书", "Wrong fixture metadata")
            for item in opf.findall("opf:manifest/opf:item", ns):
                require("OEBPS/" + item.attrib["href"] in archive.namelist(), "Broken EPUB manifest link")
            require(len(opf.findall("opf:spine/opf:itemref", ns)) == 2, "Fixture spine missing")
    with ZipFile(ROOT / "Tests/Fixtures/reader-layout.epub") as archive:
        require(archive.testzip() is None, "Reader layout fixture ZIP corrupt")
        require(archive.infolist()[0].filename == "mimetype" and archive.infolist()[0].compress_type == ZIP_STORED,
                "Reader fixture mimetype must be first and stored")
        require(archive.read("mimetype") == b"application/epub+zip", "Reader fixture format invalid")
        for name in archive.namelist():
            require(not name.startswith("/") and ".." not in Path(name).parts, "Reader fixture path invalid")
            if name.endswith((".xml", ".opf", ".xhtml", ".svg")):
                ET.fromstring(archive.read(name))
        opf = ET.fromstring(archive.read("OEBPS/package.opf"))
        require(len(opf.findall("opf:spine/opf:itemref", ns)) == 3, "Reader fixture needs cover, long and short chapters")
        for item in opf.findall("opf:manifest/opf:item", ns):
            require("OEBPS/" + item.attrib["href"] in archive.namelist(), "Reader fixture resource missing")
    with ZipFile(ROOT / "Tests/Fixtures/window-long.epub") as archive:
        require(archive.testzip() is None, "Window fixture ZIP CRC failure")
        opf = ET.fromstring(archive.read("OEBPS/book.opf"))
        require(len(opf.findall("opf:spine/opf:itemref", ns)) == 1000, "Window fixture must have 1000 resources")
        for item in opf.findall("opf:manifest/opf:item", ns):
            path = "OEBPS/" + item.attrib["href"]
            require(path in archive.namelist(), "Window fixture resource missing")
            ET.fromstring(archive.read(path))


def check_swift_syntax() -> int:
    from tree_sitter import Language, Parser
    import tree_sitter_swift
    parser = Parser(Language(tree_sitter_swift.language()))
    files = [path for prefix in ["App", "Packages", "Tests/iOS", "Tests/UI", "Vendor"] for path in (ROOT / prefix).rglob("*.swift")
             if ".build" not in path.parts and ".swiftpm" not in path.parts]
    errors = []
    baseline = json.loads((ROOT / "Vendor/ReadiumToolkit/UPSTREAM.json").read_text(encoding="utf-8"))["upstreamGrammarDiagnostics"]
    retained = 0
    for source in files:
        tree = parser.parse(source.read_bytes())
        if not tree.root_node.has_error:
            continue
        stack = [tree.root_node]
        known = Counter(baseline.get(source.relative_to(ROOT / "Vendor/ReadiumToolkit").as_posix(), [])
                        if source.is_relative_to(ROOT / "Vendor/ReadiumToolkit") else [])
        while stack:
            node = stack.pop()
            if node.is_error or node.is_missing:
                # Compare exact parser limitations against the pristine 3.11
                # source, which was already compiled in Build3. New diagnostics
                # still fail. This is a grammar delta check, never a compiler.
                import hashlib
                signature = node.type + ":" + hashlib.sha256(node.parent.text if node.parent is not None else node.text).hexdigest()
                if known[signature]:
                    known[signature] -= 1
                    retained += 1
                    stack.extend(reversed(node.children))
                    continue
                row, column = node.start_point
                errors.append(f"{source.relative_to(ROOT)}:{row + 1}:{column + 1}: {node.type}")
            stack.extend(reversed(node.children))
    require(not errors, "Swift grammar errors (not compiler diagnostics):\n" + "\n".join(errors))
    print(f"Readium pristine grammar limitations retained: {retained}; added diagnostics: 0")
    return len(files)


def check_vendor() -> None:
    from verify_vendor import verify_vendor
    verify_vendor()


def main() -> None:
    argument_parser = argparse.ArgumentParser()
    argument_parser.add_argument("--swift-syntax", action="store_true")
    argument_parser.add_argument("--report", type=Path)
    args = argument_parser.parse_args()
    checks = [check_documents, check_project, check_workflow, check_schema, check_fixtures, check_vendor]
    completed = []
    for check in checks:
        check()
        completed.append(check.__name__)
        print(f"PASS {check.__name__}")
    swift_count = check_swift_syntax() if args.swift_syntax else 0
    if args.swift_syntax:
        print(f"PASS Swift grammar: {swift_count} files (NOT Swift compilation)")
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps({
            "validationKind": "static_only", "recordedAtUTC": datetime.now(timezone.utc).isoformat(), "checks": completed,
            "swiftGrammarFiles": swift_count, "swiftCompiled": False, "xcodeBuildPassed": False,
            "simulatorAccepted": False, "deviceAccepted": False, "trollStoreAccepted": False,
            "ipaProduced": False
        }, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")


if __name__ == "__main__":
    main()
