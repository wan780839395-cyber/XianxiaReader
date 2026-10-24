"""Bounded receipts for the existing Foundation layout sample, never a retry."""
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import subprocess
import time
import uuid

OUTPUT_BYTES = 16 * 1024
MAX_PHASES = 8
UPLOAD_STEP = """      - name: Preserve bounded layout sample evidence
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: XianxiaReader-layout-sample-evidence
          retention-days: 7
          if-no-files-found: warn
          include-hidden-files: true
          path: |
            .cache/layout-sample/baseline.swift
            .cache/layout-sample/harness.swift
            .cache/layout-sample/behavior.json
"""


def without_layout_sample_upload(text):
    count = text.count(UPLOAD_STEP)
    if count > 1:
        raise ValueError("Duplicate layout evidence upload")
    return text.replace(UPLOAD_STEP, "", 1) if count else text


def bounded_output(value):
    raw = value if isinstance(value, bytes) else (value or "").encode("utf-8")
    text = raw.decode("utf-8", errors="replace")
    patterns = [r"(?s)-----BEGIN [^-]*PRIVATE KEY-----.*?-----END [^-]*PRIVATE KEY-----",
                r"(?i)\bauthorization\s*:\s*(?:Bearer|token|Basic)\s+[^\s,;]+",
                r"gh[pousr]_[A-Za-z0-9]{20,}", r"github_pat_[A-Za-z0-9_]{20,}",
                r"AKIA[0-9A-Z]{16}", r"(?i)\b(?:authorization|password|token|secret)\s*[:=]\s*[^\s,;]+"]
    for pattern in patterns:
        text = re.sub(pattern, "[REDACTED]", text)
    encoded = text.encode("utf-8")
    truncated = len(encoded) > OUTPUT_BYTES
    if truncated:
        marker = b"\n[output truncated]\n"
        half = (OUTPUT_BYTES - len(marker)) // 2
        encoded = encoded[:half] + marker + encoded[-half:]
    retained = encoded.decode("utf-8", errors="replace").encode("utf-8")[:OUTPUT_BYTES].decode("utf-8", errors="ignore")
    return dict(text=retained, originalBytes=len(raw), retainedBytes=len(retained.encode("utf-8")),
                truncated=truncated, redacted=text != raw.decode("utf-8", errors="replace"))


class LayoutSampleEvidence:
    def __init__(self, receipt, record):
        self.receipt = Path(receipt)
        self.record = record
        context = {}
        for key in ["GITHUB_SHA", "GITHUB_RUN_ID", "GITHUB_RUN_ATTEMPT"]:
            value = os.environ.get(key, "")
            if re.fullmatch(r"[0-9a-fA-F]{40}" if key == "GITHUB_SHA" else r"\d{1,32}", value):
                context[key] = value
        record.update(evidenceSchema=1, observationID=uuid.uuid4().hex, phases=[],
                      context=context, diagnosticsComplete=True,
                      outputBytesPerStream=OUTPUT_BYTES, maximumPhases=MAX_PHASES)
        self.persist()

    def persist(self):
        temporary = self.receipt.with_suffix(".json.tmp")
        temporary.write_text(json.dumps(self.record, indent=2) + "\n", encoding="utf-8")
        temporary.replace(self.receipt)

    def message(self, result):
        return bounded_output(result.stdout)["text"] + bounded_output(result.stderr)["text"]

    def _finish(self, stage, started, stdout=None, stderr=None, error=None):
        stage.update(elapsedSeconds=max(0, time.monotonic() - started),
                     endedAtUTC=datetime.now(timezone.utc).isoformat())
        # docker inspect contains an entire image environment; retain no raw JSON.
        stage["stdout"] = (dict(text="[image inspection payload omitted]", omittedForPrivacy=True)
                           if stage["phase"] == "docker-inspect" else bounded_output(stdout))
        stage["stderr"] = bounded_output(stderr)
        if stage["phase"] == "docker-combined":
            version = next((line for line in stage["stdout"]["text"].splitlines()
                            if line.startswith("Swift version ")), None)
            self.record["compiler"] = dict(mode="locked-container", version=version)
        if stage["outcome"] != "returned" or stage.get("returncode") != 0:
            if stage["optionalMetadata"]:
                self.record["diagnosticsComplete"] = False
            else:
                self.record["failurePhase"] = stage["phase"]
        try:
            self.persist()
        except OSError as save_error:
            if error is None:
                raise
            # Best effort receipt failure must not replace the original timeout.
            error.add_note("Layout receipt write failed: " + type(save_error).__name__)

    def run(self, phase, command, *, timeout, text=True, optional=False):
        if phase not in {"baseline-compile", "baseline-run", "current-compile", "current-run",
                         "compiler-version", "docker-inspect", "docker-combined"} or len(command) > 32:
            raise ValueError("Unexpected layout evidence command/phase")
        if len(self.record["phases"]) >= MAX_PHASES:
            raise ValueError("Layout evidence phase capacity exceeded")
        started = time.monotonic()
        stage = dict(phase=phase, command=[bounded_output(str(arg))["text"] for arg in command],
                     timeoutSeconds=timeout, textMode=text, optionalMetadata=optional,
                     startedAtUTC=datetime.now(timezone.utc).isoformat(), outcome="started")
        self.record["phases"].append(stage)
        self.persist()
        kwargs = dict(capture_output=True, timeout=timeout)
        if text:
            kwargs.update(text=True, encoding="utf-8")
        try:
            result = subprocess.run(command, **kwargs)
        except subprocess.TimeoutExpired as error:
            stage.update(outcome="timeout", exception="TimeoutExpired")
            self._finish(stage, started, error.stdout, error.stderr, error)
            raise
        except OSError as error:
            stage.update(outcome="launch-error", exception=type(error).__name__)
            self._finish(stage, started, error=error)
            raise
        stage.update(outcome="returned", returncode=result.returncode)
        self._finish(stage, started, result.stdout, result.stderr)
        return result

    def compiler_version(self, compiler):
        # Probe only after the measured legacy compile; never warm it beforehand.
        self.record["compiler"] = dict(mode="PATH", path=bounded_output(compiler)["text"],
                                       version=None, probeAfterLegacyCompile=True)
        try:
            result = self.run("compiler-version", [compiler, "--version"], timeout=5, optional=True)
            if result.returncode == 0:
                self.record["compiler"]["version"] = bounded_output(result.stdout)["text"]
            self.persist()
        except (OSError, subprocess.TimeoutExpired):
            # Only optional metadata is best effort; original compilation exceptions
            # and return-code assertions continue to propagate unchanged.
            self.record["diagnosticsComplete"] = False
