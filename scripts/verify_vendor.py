"""Verify the maintained source inventory and declared differences, not compilation."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def verify_vendor(root=None):
    root = root or ROOT / "Vendor/ReadiumToolkit"
    metadata = json.loads((root / "UPSTREAM.json").read_text(encoding="utf-8"))
    if (metadata["version"], metadata["revision"], metadata["license"]) != (
        "3.11.0", "d82f44f4f05d87add9e22a8b75abbd61dce745dd", "BSD-3-Clause"
    ):
        raise ValueError("Readium reviewed upstream provenance changed")
    original = {r["path"]: r["sha256"] for r in metadata["baselineFiles"]}
    modified = {r["path"]: r["sha256"] for r in metadata["localModifiedFiles"]}
    for relative, expected in (original | modified).items():
        path = root / relative
        if Path(relative).is_absolute() or ".." in Path(relative).parts or not path.is_file():
            raise ValueError(f"Missing/invalid Readium inventory path: {relative}")
        if hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            raise ValueError(f"Readium file differs from reviewed inventory: {relative}")
    allowed = set(original) | set(modified) | {"LICENSE", "README.md", "UPSTREAM.json"}
    actual = {p.relative_to(root).as_posix() for p in root.rglob("*") if p.is_file()}
    if actual != allowed:
        raise ValueError(f"Readium undeclared/missing files: {sorted(actual ^ allowed)}")
    if "Redistribution and use" not in (root / "LICENSE").read_text(encoding="utf-8"):
        raise ValueError("Readium license is missing")
    return len(actual)


if __name__ == "__main__":
    print(f"Verified {verify_vendor()} Readium source/resource/provenance files")
