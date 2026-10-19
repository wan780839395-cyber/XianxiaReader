"""Bounded, best-effort CI context; commands contain no app arguments or book data."""
from __future__ import annotations

import json
import os
import signal
import subprocess
import threading
import time


def main() -> None:
    stopped = threading.Event()
    signal.signal(signal.SIGTERM, lambda *_: stopped.set())
    deadline = time.monotonic() + 1800
    while not stopped.is_set() and time.monotonic() < deadline:
        sample = {"time": time.time(), "loadAverage": os.getloadavg()}
        for name, command in [("processes", ["ps", "-axo", "pid,ppid,state,rss,comm"]),
                              ("memory", ["vm_stat"])]:
            try:
                result = subprocess.run(command, capture_output=True, text=True, timeout=3)
                value = result.stdout
                if name == "processes":
                    rows = value.splitlines()[1:]
                    rows.sort(key=lambda row: int(row.split(None, 4)[3]), reverse=True)
                    selected = rows[:20]
                    selected += [row for row in rows[20:] if "WebKit" in row or "XianxiaReader" in row]
                    value = "\n".join(selected)
                sample[name] = {"exit": result.returncode, "stdout": value, "stderr": result.stderr}
            except (OSError, ValueError, subprocess.TimeoutExpired) as error:
                sample[name] = {"error": str(error)}
        print(json.dumps(sample), flush=True)
        stopped.wait(5)


if __name__ == "__main__":
    main()
