"""Export one immutable, already-completed result; never build or run tests."""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import stat
import subprocess
import sys
import time
import urllib.request
import zipfile

REPOSITORY = "wan780839395-cyber/XianxiaReader"
RUN_ID = 40189698011
ARTIFACT_ID = 12598179361
SOURCE_SHA = "4c2e16ef37ebd39f45d4f37e009c058fd430d940"
ARTIFACT_NAME = "XianxiaReader-reader-diagnostic-f5-first-open"
DIGEST = "sha256:25c9f2e1f7f830e74465ecad9b716e9904be9b2876a5164d4b8897fe9e75357d"
EVENTS = ("XRPresentation", "XRSave", "reader.appeared", "reader.open.returned", "reader.disappeared")


def write_json(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def validate_source(meta):
    run = meta["workflow_run"]
    expected = (ARTIFACT_ID, ARTIFACT_NAME, DIGEST, RUN_ID, SOURCE_SHA)
    actual = (meta["id"], meta["name"], meta["digest"], run["id"], run["head_sha"])
    if actual != expected or meta["expired"]:
        raise ValueError("Source artifact identity/digest/expiry mismatch")


def api_open(suffix, token):
    request = urllib.request.Request("https://api.github.com/repos/" + REPOSITORY + suffix)
    request.add_header("Accept", "application/vnd.github+json")
    request.add_header("X-GitHub-Api-Version", "2022-11-28")
    # The signed archive redirect must not receive the GitHub token.
    request.add_unredirected_header("Authorization", "Bearer " + token)
    return urllib.request.urlopen(request, timeout=60)


def extract_result(archive, destination):
    total = 0
    count = 0
    with zipfile.ZipFile(archive) as bundle:
        for member in bundle.infolist():
            name = PurePosixPath(member.filename)
            if name.is_absolute() or ".." in name.parts or "\\" in member.filename:
                raise ValueError("Unsafe archive member")
            if not name.parts or name.parts[0] != "DiagnosticTests.xcresult":
                continue
            if stat.S_ISLNK(member.external_attr >> 16):
                raise ValueError("Symlink in result archive")
            total += member.file_size
            count += 1
            if total > 512 * 1024 * 1024 or count > 5000:
                raise ValueError("Result exceeds bounded extraction")
            bundle.extract(member, destination)
    result = destination / "DiagnosticTests.xcresult"
    if not (result / "Info.plist").is_file() or not (result / "database.sqlite3").is_file():
        raise ValueError("Original result bundle missing")
    return result


def command(argv, name, output, timeout):
    started = time.monotonic()
    env = {k: v for k, v in os.environ.items() if k not in ("GH_TOKEN", "GITHUB_TOKEN")}
    try:
        run = subprocess.run(argv, capture_output=True, timeout=timeout, env=env)
        stdout, stderr, code, timed_out = run.stdout, run.stderr, run.returncode, False
    except subprocess.TimeoutExpired as error:
        stdout, stderr, code, timed_out = error.stdout or b"", error.stderr or b"", None, True
    (output / (name + ".stdout.txt")).write_bytes(stdout)
    (output / (name + ".stderr.txt")).write_bytes(stderr)
    write_json(output / (name + ".json"), {
        "argv": argv, "exitCode": code, "timeout": timed_out,
        "elapsedSeconds": time.monotonic() - started,
    })
    if timed_out or code != 0:
        raise RuntimeError(name + " failed; original exit/partial output preserved")
    return stdout.decode("utf-8", errors="replace")


def select_existing_text(raw, output):
    files, hits, unscanned, inventory = [], [], [], []
    copied = 0
    for source in sorted(raw.rglob("*")):
        if not source.is_file() or source.is_symlink():
            continue
        relative = source.relative_to(raw)
        size = source.stat().st_size
        inventory.append({"path": str(relative), "bytes": size})
        if size > 64 * 1024 * 1024:
            unscanned.append({"path": str(relative), "bytes": size, "reason": "file-size-bound"})
            continue
        data = source.read_bytes()
        if b"\0" in data[:4096]:
            unscanned.append({"path": str(relative), "bytes": size, "reason": "non-plain-text"})
            continue
        text = data.decode("utf-8", errors="replace")
        matches = [(n, line[:1500]) for n, line in enumerate(text.splitlines(), 1)
                   if any(event in line for event in EVENTS)]
        stdout_name = any(word in source.name.lower() for word in
                          ("standardoutputandstandarderror", "stdout", "stderr"))
        if not stdout_name and not matches:
            continue
        if copied + size > 128 * 1024 * 1024:
            unscanned.append({"path": str(relative), "bytes": size, "reason": "copy-size-bound"})
            continue
        target = output / "existing-text" / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        copied += size
        files.append({"path": str(relative), "bytes": size,
                      "sha256": hashlib.sha256(data).hexdigest(), "stdoutName": stdout_name,
                      "counts": {event: text.count(event) for event in EVENTS}})
        hits.extend({"path": str(relative), "line": n, "text": line} for n, line in matches[:100])
    return {"exportDirectoryExists": raw.is_dir(), "inventory": inventory,
            "files": files, "eventLines": hits, "unscanned": unscanned,
            "limitation": "No event in exported text does not prove task/open never ran."}


def main():
    work = Path("build/ExistingResultDiagnostics")
    output = work / "result"
    output.mkdir(parents=True, exist_ok=False)
    receipt = {"sourceRun": RUN_ID, "sourceSHA": SOURCE_SHA, "artifactID": ARTIFACT_ID,
               "expectedDigest": DIGEST, "workflowSHA": os.environ.get("GITHUB_SHA"),
               "testsExecuted": False, "newDeviceCollection": False, "phase": "metadata"}
    try:
        token = os.environ["GITHUB_TOKEN"]
        with api_open(f"/actions/artifacts/{ARTIFACT_ID}", token) as response:
            meta = json.load(response)
        validate_source(meta)
        write_json(output / "source-artifact.json", {key: meta[key] for key in
                   ("id", "name", "size_in_bytes", "digest", "expired", "workflow_run")})
        receipt["phase"] = "download"
        archive = work / "source.zip"
        digest = hashlib.sha256()
        with api_open(f"/actions/artifacts/{ARTIFACT_ID}/zip", token) as response, archive.open("xb") as target:
            while chunk := response.read(1024 * 1024):
                target.write(chunk)
                digest.update(chunk)
        receipt["actualDigest"] = "sha256:" + digest.hexdigest()
        if receipt["actualDigest"] != DIGEST or archive.stat().st_size != meta["size_in_bytes"]:
            raise ValueError("Downloaded artifact hash/size mismatch")
        receipt["phase"] = "extract-original"
        result = extract_result(archive, work / "input")
        archive.unlink()
        receipt["phase"] = "native-help"
        version = command(["xcodebuild", "-version"], "xcode-version", output, 30)
        if "Xcode 16.4\n" not in version:
            raise ValueError("Expected original Xcode 16.4")
        help_text = command(["xcrun", "xcresulttool", "export", "diagnostics", "--help"],
                            "export-help", output, 30)
        if "--path" not in help_text or "--output-path" not in help_text:
            raise ValueError("Native export help does not support expected arguments")
        receipt["phase"] = "export-existing-diagnostics"
        raw = work / "raw-diagnostics"
        command(["xcrun", "xcresulttool", "export", "diagnostics", "--path", str(result),
                 "--output-path", str(raw)], "export", output, 180)
        receipt["phase"] = "inspect-existing-text"
        receipt["inspection"] = select_existing_text(raw, output)
        receipt["phase"] = "completed"
        write_json(output / "receipt.json", receipt)
        print("Existing result export complete; selected text files:", len(receipt["inspection"]["files"]))
        return 0
    except Exception as error:
        receipt["errorType"] = type(error).__name__
        receipt["error"] = str(error)[:500]
        write_json(output / "receipt.json", receipt)
        print("Existing result export failed at", receipt["phase"], type(error).__name__)
        return 1


if __name__ == "__main__":
    sys.exit(main())
