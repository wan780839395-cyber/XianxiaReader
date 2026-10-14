"""Check a real resolver output against the reviewed remote dependency baseline."""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def verify_lock(path: Path, *, allow_upstream=False):
    metadata = json.loads((ROOT / "Vendor/ReadiumToolkit/UPSTREAM.json").read_text(encoding="utf-8"))
    actual = json.loads(path.read_text(encoding="utf-8"))["pins"]
    expected = metadata["remoteDependencyPins"]
    if allow_upstream:
        # During the first real local-package resolution only, retain the old
        # genuine lockfile. It is never described as a resolved local graph.
        actual = [pin for pin in actual if pin["identity"] != "swift-toolkit" or
                  pin["state"] != {"version": metadata["version"], "revision": metadata["revision"]}]
    by_id = lambda pins: {p["identity"]: p for p in pins}
    if len(actual) != len(expected) or by_id(actual) != by_id(expected):
        raise ValueError("Resolved remote pins differ from the reviewed Readium 3.11 baseline; review the actual output")
    return len(actual)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("path", type=Path)
    args = parser.parse_args()
    print(f"Verified {verify_lock(args.path)} genuine remote pins; local Readium provenance is separate")
