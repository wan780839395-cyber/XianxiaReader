"""Deterministic original TXT fixtures and isolated real Release Core measurements.

Large book bodies live only in a temporary directory, never Git/artifacts.
Timing/RSS are evidence, not a shared-runner speed gate or iPhone acceptance.
"""
import argparse
import hashlib
import json
from pathlib import Path
import platform
import subprocess
import tempfile


SENTENCE = "山门的灯火照着石阶，少年收好行囊，向云海问道。🙂e\u0301"


def generate(directory: Path, name: str, target_bytes: int, chapters: int, *, giant=False, encoding="utf-8"):
    source = directory / (name + ".txt")
    raw_hash, normalized_hash = hashlib.sha256(), hashlib.sha256()
    raw_bytes = normalized_bytes = 0
    boundaries = []
    # Fixed small blocks keep generation independent of total book size.
    block = SENTENCE * 16 + ("" if giant else "\r\n")
    block_bytes = len(block.encode(encoding))
    repetitions = max(1, (target_bytes // chapters) // block_bytes)
    with source.open("xb") as handle:
        if encoding == "utf-16-le":
            handle.write(b"\xff\xfe"); raw_hash.update(b"\xff\xfe"); raw_bytes += 2

        def write(text):
            nonlocal raw_bytes, normalized_bytes
            raw = text.encode(encoding)
            normalized = text.encode("utf-8")
            handle.write(raw); raw_hash.update(raw); normalized_hash.update(normalized)
            raw_bytes += len(raw); normalized_bytes += len(normalized)

        for ordinal in range(chapters):
            start = normalized_bytes
            title = "正文" if giant else f"第{ordinal+1}章 云海问道"
            if not giant:
                write(title + "\r\n")
            for _ in range(repetitions):
                write(block)
            boundaries.append(dict(title=title, startByte=start, endByte=normalized_bytes))
    expected = dict(name=name, sourceBytes=raw_bytes, sourceSHA256=raw_hash.hexdigest(),
                    normalizedBytes=normalized_bytes, normalizedSHA256=normalized_hash.hexdigest(), chapters=boundaries)
    metadata = directory / (name + ".json")
    metadata.write_text(json.dumps(expected, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return source, metadata, expected


def run(binary: Path, output: Path):
    output.mkdir(parents=True, exist_ok=True)
    cases = [("utf8-5MiB-1000chapters", 5*1024*1024, 1000, {}),
             ("utf8-50MiB-3000chapters", 50*1024*1024, 3000, {}),
             ("utf8-50MiB-no-newline", 50*1024*1024, 1, dict(giant=True)),
             ("utf16-5MiB-1000chapters", 5*1024*1024, 1000, dict(encoding="utf-16-le"))]
    reports = []
    for name, size, chapters, options in cases:
        with tempfile.TemporaryDirectory(prefix="XianxiaTXTProbe-") as temporary:
            source, metadata, expected = generate(Path(temporary), name, size, chapters, **options)
            report = output / (name + ".json")
            # Stream child output directly into a retained full log; timeout/failure propagates.
            with (output / (name + ".log")).open("w", encoding="utf-8") as log:
                subprocess.run([str(binary.resolve()), str(source), str(metadata), str(report.resolve())],
                               stdout=log, stderr=subprocess.STDOUT, check=True, timeout=240)
            result = json.loads(report.read_text(encoding="utf-8"))
            if result["sample"] != expected or not result["allChecksPassed"] or result["configuration"] != "Release":
                raise ValueError(f"Probe did not validate {name}")
            if result["visitedBytes"] != expected["normalizedBytes"] or not 0 < result["maximumWindowBytes"] <= 65536:
                raise ValueError(f"Incomplete/unbounded traversal: {name}")
            reports.append(result)
            print(f'{name}: {expected["sourceBytes"]} bytes, cold {result["coldImportMilliseconds"]:.1f}ms, '
                  f'peak RSS {result["finalPeakRSSBytes"]/1048576:.1f}MiB', flush=True)
    (output / "summary.json").write_text(json.dumps(dict(platform=platform.platform(), cases=reports,
        scope="Release desktop Core; 3 warm OS-cache reopens per fresh sample process; not iOS memory/UI acceptance"),
        ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    arguments = parser.parse_args()
    run(arguments.binary, arguments.output)
