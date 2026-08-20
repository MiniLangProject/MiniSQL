#!/usr/bin/env python3
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""MiniSQL M49 deterministic fuzz, crash-matrix, soak and performance gate."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import random
import shutil
import subprocess
import sys
import time
from pathlib import Path
from typing import Sequence


class QualityError(RuntimeError):
    """Signals a failure in a deterministic quality or durability gate."""
    pass


def run(command: Sequence[str], timeout: float) -> subprocess.CompletedProcess[str]:
    """Runs one quality subprocess and raises QualityError on timeout or nonzero exit."""
    completed = subprocess.run(
        list(command), text=True, encoding="utf-8", errors="replace",
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=timeout, check=False,
    )
    if completed.returncode != 0:
        raise QualityError(
            "command failed: " + " ".join(command)
            + f"\nexit={completed.returncode}\nstdout={completed.stdout.strip()}\nstderr={completed.stderr.strip()}"
        )
    return completed


def executable_command(path: Path, *args: object) -> list[str]:
    """Builds a platform-correct command for a native executable and its arguments."""
    return [str(path), *(str(value) for value in args)]


def corpus_digest(corpus: list[str]) -> str:
    """Returns the stable SHA-256 digest of the ordered SQL fuzz corpus."""
    joined = "\n---\n".join(corpus).encode("utf-8")
    return hashlib.sha256(joined).hexdigest()


def self_test(root: Path) -> int:
    """Validates quality fixtures, their digests and the frozen deterministic RNG sequence."""
    corpus_path = root / "tests" / "fuzz" / "m49_sql_corpus.json"
    baseline_path = root / "tests" / "performance" / "m49_baseline.json"
    matrix_path = root / "tests" / "recovery" / "m49_crash_matrix.json"
    corpus_doc = json.loads(corpus_path.read_text(encoding="utf-8"))
    baseline = json.loads(baseline_path.read_text(encoding="utf-8"))
    matrix = json.loads(matrix_path.read_text(encoding="utf-8"))
    corpus = corpus_doc.get("statements")
    if not isinstance(corpus, list) or len(corpus) < 32 or not all(isinstance(item, str) for item in corpus):
        raise QualityError("SQL fuzz corpus must contain at least 32 strings")
    if corpus_doc.get("sha256") != corpus_digest(corpus):
        raise QualityError("SQL fuzz corpus checksum mismatch")
    if baseline.get("maxHardeningRunSeconds", 0) < 60:
        raise QualityError("performance baseline is implausibly strict")
    scenarios = matrix.get("scenarios")
    if not isinstance(scenarios, list) or {item.get("name") for item in scenarios} != {"durable-commit", "uncommitted"}:
        raise QualityError("crash matrix scenarios are incomplete")
    generator = random.Random(490049)
    sample = [generator.randrange(0, 1_000_000) for _ in range(8)]
    if sample != [390256, 953607, 433499, 447413, 545463, 499704, 388945, 829958]:
        raise QualityError("deterministic fuzz seed changed")
    print(f"MiniSQL M49 quality self-test: SUCCESS corpus={len(corpus)}")
    return 0


def crash_matrix(worker: Path, output_root: Path, iterations: int, timeout: float) -> int:
    """Runs committed and uncommitted crash/recovery pairs and publishes their timing report."""
    output_root.mkdir(parents=True, exist_ok=True)
    completed = 0
    cases: list[dict[str, object]] = []
    started_all = time.monotonic()
    for iteration in range(iterations):
        for scenario, writer_mode, reader_mode in (
            ("durable-commit", "write-commit", "recover-commit"),
            ("uncommitted", "write-uncommitted", "recover-uncommitted"),
        ):
            case = output_root / f"{iteration:03d}-{scenario}"
            if case.exists():
                shutil.rmtree(case)
            case.mkdir(parents=True)
            data_path = case / "table.tbl"
            wal_path = case / "wal.log"
            case_started = time.monotonic()
            written = run(executable_command(worker, writer_mode, data_path, wal_path), timeout)
            expected_writer = "committed: READY" if scenario == "durable-commit" else "uncommitted: READY"
            if expected_writer not in written.stdout:
                raise QualityError(f"crash writer banner mismatch for {scenario}: {written.stdout!r}")
            recovered = run(executable_command(worker, reader_mode, data_path, wal_path), timeout)
            if "SUCCESS" not in recovered.stdout:
                raise QualityError(f"crash recovery banner mismatch for {scenario}: {recovered.stdout!r}")
            cases.append({
                "iteration": iteration,
                "scenario": scenario,
                "durationSeconds": round(time.monotonic() - case_started, 3),
                "writerExitCode": written.returncode,
                "readerExitCode": recovered.returncode,
            })
            completed += 1
    report = {
        "version": 1,
        "iterations": iterations,
        "casesCompleted": completed,
        "durationSeconds": round(time.monotonic() - started_all, 3),
        "cases": cases,
        "platform": sys.platform,
        "python": sys.version,
    }
    report_path = output_root / "m49-crash-matrix-report.json"
    temporary = report_path.with_suffix(".json.new")
    temporary.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    os.replace(temporary, report_path)
    print(f"MiniSQL M49 crash matrix: SUCCESS cases={completed}")
    return 0


def soak(hardening_exe: Path, output_root: Path, iterations: int, max_seconds: float) -> int:
    """Repeats the native hardening workload and enforces its per-run performance guardrail."""
    output_root.mkdir(parents=True, exist_ok=True)
    durations: list[float] = []
    for iteration in range(iterations):
        root = output_root / f"run-{iteration:03d}"
        if root.exists():
            shutil.rmtree(root)
        root.mkdir(parents=True)
        started = time.monotonic()
        completed = run(executable_command(hardening_exe, root), max_seconds)
        duration = time.monotonic() - started
        if "MiniSQL M49 hardening tests: SUCCESS" not in completed.stdout:
            raise QualityError(f"hardening success banner missing: {completed.stdout!r}")
        if duration > max_seconds:
            raise QualityError(f"hardening run exceeded {max_seconds}s")
        durations.append(duration)
    report = {
        "iterations": iterations,
        "durationsSeconds": [round(value, 3) for value in durations],
        "maximumSeconds": round(max(durations), 3) if durations else 0,
        "averageSeconds": round(sum(durations) / len(durations), 3) if durations else 0,
        "platform": sys.platform,
        "python": sys.version,
    }
    report_path = output_root / "m49-soak-report.json"
    temp = report_path.with_suffix(".json.new")
    temp.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    os.replace(temp, report_path)
    print(
        "MiniSQL M49 soak/performance: SUCCESS "
        f"iterations={iterations} maxSeconds={report['maximumSeconds']}"
    )
    return 0


def parser() -> argparse.ArgumentParser:
    """Builds the command-line parser and all supported role-specific subcommands."""
    root = argparse.ArgumentParser(description=__doc__)
    sub = root.add_subparsers(dest="mode", required=True)
    self_parser = sub.add_parser("self-test")
    self_parser.add_argument("--root", required=True)
    crash = sub.add_parser("crash-matrix")
    crash.add_argument("--worker", required=True)
    crash.add_argument("--output-root", required=True)
    crash.add_argument("--iterations", type=int, default=8)
    crash.add_argument("--timeout", type=float, default=120.0)
    soak_parser = sub.add_parser("soak")
    soak_parser.add_argument("--hardening-exe", required=True)
    soak_parser.add_argument("--output-root", required=True)
    soak_parser.add_argument("--iterations", type=int, default=2)
    soak_parser.add_argument("--max-seconds", type=float, default=600.0)
    return root


def main(argv: Sequence[str] | None = None) -> int:
    """Dispatches the selected command, translates known failures and returns a process exit status."""
    args = parser().parse_args(argv)
    try:
        if args.mode == "self-test":
            return self_test(Path(args.root).resolve())
        if args.mode == "crash-matrix":
            if args.iterations < 1 or args.iterations > 100:
                raise QualityError("iterations must be 1..100")
            return crash_matrix(Path(args.worker).resolve(), Path(args.output_root).resolve(), args.iterations, args.timeout)
        if args.mode == "soak":
            if args.iterations < 1 or args.iterations > 20:
                raise QualityError("iterations must be 1..20")
            return soak(Path(args.hardening_exe).resolve(), Path(args.output_root).resolve(), args.iterations, args.max_seconds)
        raise QualityError(f"unknown mode: {args.mode}")
    except (QualityError, OSError, subprocess.SubprocessError, json.JSONDecodeError) as exc:
        print(f"MiniSQL M49 quality gate: FAIL {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
