"""Record maintained-file hashes for recovery when no Git commit exists yet."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "Documentation/FILE_INVENTORY.json"


def main() -> None:
    paths = subprocess.check_output(
        ["git", "-c", "core.quotepath=false", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
        cwd=ROOT,
    ).decode("utf-8").split("\0")
    records = []
    for relative in sorted(set(filter(None, paths))):
        path = ROOT / relative
        if path == OUTPUT or not path.is_file():
            continue
        data = path.read_bytes()
        records.append({"path": relative.replace("\\", "/"), "bytes": len(data),
                        "sha256": hashlib.sha256(data).hexdigest()})
    OUTPUT.write_text(json.dumps({
        "recordedAtUTC": datetime.now(timezone.utc).isoformat(),
        "purpose": "Maintained file checkpoint; excludes ignored caches, builds, and this inventory itself.",
        "fileCount": len(records), "files": records
    }, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(f"Recorded {len(records)} maintained file hashes in {OUTPUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
