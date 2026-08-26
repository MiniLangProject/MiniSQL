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

"""Run one side of the reproducible Windows/Linux MiniSQL comparison."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import platform
import re
import subprocess
import sys
import time
from pathlib import Path

# This benchmark imports a local sampler. Disable Python bytecode before that
# import so a documented performance run cannot poison MiniSQL's source-package
# hygiene gate with an ignored tests/performance/__pycache__ directory.
sys.dont_write_bytecode = True

from capacity_regression import private_bytes


ROOT = Path(__file__).resolve().parents[2]
NETWORK_RUNNER = Path(__file__).with_name("network_baseline.py")


class ComparisonFailure(RuntimeError):
    """Report an invalid artifact, failed workload, or malformed result."""


def sha256(path: Path) -> str:
    """Return the SHA-256 digest of one benchmark artifact."""

    digest = hashlib.sha256()
    with path.open("rb") as stream:
        while chunk := stream.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest().upper()


def tree_bytes(path: Path) -> int:
    """Return the physical byte size of all regular files below a directory."""

    return sum(item.stat().st_size for item in path.rglob("*") if item.is_file())


def run_monitored(command: list[str], timeout: float) -> dict[str, object]:
    """Run a command while sampling wall time and process-private memory."""

    started = time.perf_counter()
    process = subprocess.Popen(
        command,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    peak_private = 0
    while process.poll() is None:
        peak_private = max(peak_private, private_bytes(process.pid))
        if time.perf_counter() - started > timeout:
            process.kill()
            stdout, stderr = process.communicate()
            raise subprocess.TimeoutExpired(command, timeout, output=stdout, stderr=stderr)
        time.sleep(0.01)
    stdout, stderr = process.communicate()
    peak_private = max(peak_private, private_bytes(process.pid))
    wall_seconds = time.perf_counter() - started
    if process.returncode != 0 or stderr.strip():
        raise ComparisonFailure(
            f"command failed rc={process.returncode}: {command!r}\n"
            f"stdout={stdout[-2000:]!r}\nstderr={stderr[-2000:]!r}"
        )
    return {
        "wallSeconds": round(wall_seconds, 6),
        "peakPrivateBytes": peak_private,
        "stdout": stdout.strip(),
    }


def output_integer(output: str, name: str) -> int:
    """Read one decimal key from a native worker's stable output."""

    match = re.search(rf"\b{re.escape(name)}=(\d+)\b", output)
    if not match:
        raise ComparisonFailure(f"worker output is missing {name}: {output!r}")
    return int(match.group(1))


def database_path(output: str) -> Path:
    """Read the initialized database path emitted by the native worker."""

    match = re.search(r"^CAPACITY_DATABASE_PATH=(.+)$", output, re.MULTILINE)
    if not match:
        raise ComparisonFailure(f"worker did not report its database path: {output!r}")
    return Path(match.group(1).strip()).resolve()


def cpu_name() -> str:
    """Return a stable best-effort processor description."""

    if sys.platform.startswith("linux"):
        try:
            for line in Path("/proc/cpuinfo").read_text(
                encoding="ascii", errors="replace"
            ).splitlines():
                if line.startswith("model name"):
                    return line.partition(":")[2].strip()
        except OSError:
            pass
    value = platform.processor().strip()
    if value:
        return value
    return "unknown"


def run_network_trial(
    *,
    server: Path,
    client: Path,
    database: Path,
    output: Path,
    concurrency: str,
    statements: int,
    one_shot: int,
    query: str,
) -> dict[str, object]:
    """Execute one complete loopback matrix through the shared network runner."""

    command = [
        sys.executable,
        str(NETWORK_RUNNER),
        "--server",
        str(server),
        "--client",
        str(client),
        "--database",
        str(database),
        "--output",
        str(output),
        "--concurrency",
        concurrency,
        "--one-shot-per-client",
        str(one_shot),
        "--statements-per-session",
        str(statements),
        "--query",
        query,
    ]
    runner = run_monitored(command, 900.0)
    report = json.loads(output.read_text(encoding="utf-8"))
    report["runnerWallSeconds"] = runner["wallSeconds"]
    return report


def main() -> int:
    """Execute storage, restart, and loopback workloads and retain raw JSON."""

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--label", required=True)
    parser.add_argument("--worker", type=Path, required=True)
    parser.add_argument("--server", type=Path, required=True)
    parser.add_argument("--client", type=Path, required=True)
    parser.add_argument("--data-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--trials", type=int, default=3)
    parser.add_argument("--storage-mib", type=int, default=64)
    parser.add_argument("--payload-kib", type=int, default=1024)
    parser.add_argument("--verify-trials", type=int, default=5)
    parser.add_argument("--concurrency", default="1,4,8")
    parser.add_argument("--one-shot-per-client", type=int, default=10)
    parser.add_argument("--count-statements", type=int, default=500)
    parser.add_argument("--sum-statements", type=int, default=200)
    args = parser.parse_args()
    started_utc = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

    worker = args.worker.resolve()
    server = args.server.resolve()
    client = args.client.resolve()
    for artifact in (worker, server, client):
        if not artifact.is_file():
            raise ComparisonFailure(f"benchmark artifact is missing: {artifact}")
    if min(args.trials, args.storage_mib, args.payload_kib, args.verify_trials) < 1:
        raise ComparisonFailure("trial counts and storage sizes must be positive")
    rows = math.ceil((args.storage_mib * 1024) / args.payload_kib)
    payload_bytes = args.payload_kib * 1024
    data_root = args.data_root.resolve()
    if data_root.exists() and any(data_root.iterdir()):
        raise ComparisonFailure(f"data root must be empty or absent: {data_root}")
    data_root.mkdir(parents=True, exist_ok=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)

    storage: list[dict[str, object]] = []
    retained_database: Path | None = None
    for trial in range(1, args.trials + 1):
        trial_root = data_root / f"storage-{trial}"
        trial_root.mkdir()
        initialized = run_monitored(
            [str(worker), "init", str(trial_root), f"platform_{trial}"], 300.0
        )
        database = database_path(str(initialized["stdout"]))
        inserted = run_monitored(
            [
                str(worker),
                "insert",
                str(database),
                "1",
                str(rows),
                str(payload_bytes),
            ],
            900.0,
        )
        verified = run_monitored(
            [str(worker), "verify", str(database), str(rows), str(payload_bytes)],
            900.0,
        )
        storage.append(
            {
                "trial": trial,
                "database": str(database),
                "initializeWallSeconds": initialized["wallSeconds"],
                "insertWallSeconds": inserted["wallSeconds"],
                "insertEngineMs": output_integer(str(inserted["stdout"]), "elapsedMs"),
                "insertPeakPrivateBytes": inserted["peakPrivateBytes"],
                "coldVerifyWallSeconds": verified["wallSeconds"],
                "coldVerifyEngineMs": output_integer(str(verified["stdout"]), "elapsedMs"),
                "coldVerifyPeakPrivateBytes": verified["peakPrivateBytes"],
                "databaseTreeBytes": tree_bytes(database),
            }
        )
        if retained_database is None:
            retained_database = database

    assert retained_database is not None
    restart_verify: list[dict[str, object]] = []
    # The storage phase already created the persistent heap-page directory. The
    # following independent processes therefore measure steady restart behavior.
    for trial in range(1, args.verify_trials + 1):
        verified = run_monitored(
            [
                str(worker),
                "verify",
                str(retained_database),
                str(rows),
                str(payload_bytes),
            ],
            900.0,
        )
        restart_verify.append(
            {
                "trial": trial,
                "wallSeconds": verified["wallSeconds"],
                "engineMs": output_integer(str(verified["stdout"]), "elapsedMs"),
                "peakPrivateBytes": verified["peakPrivateBytes"],
            }
        )

    network: dict[str, list[dict[str, object]]] = {"count": [], "sum": []}
    query_specs = (
        ("count", "SELECT COUNT(*) AS c FROM capacity_data;", args.count_statements),
        ("sum", "SELECT SUM(id) AS total FROM capacity_data;", args.sum_statements),
    )
    for name, query, statements in query_specs:
        for trial in range(1, args.trials + 1):
            raw_path = args.output.parent / f"{args.label}-{name}-{trial}.json"
            network[name].append(
                run_network_trial(
                    server=server,
                    client=client,
                    database=retained_database,
                    output=raw_path,
                    concurrency=args.concurrency,
                    statements=statements,
                    one_shot=args.one_shot_per_client if name == "count" else 0,
                    query=query,
                )
            )

    report = {
        "label": args.label,
        "startedUtc": started_utc,
        "environment": {
            "platform": platform.platform(),
            "system": platform.system(),
            "release": platform.release(),
            "python": platform.python_version(),
            "cpu": cpu_name(),
            "logicalProcessors": os.cpu_count(),
            "dataRoot": str(data_root),
        },
        "artifacts": {
            "worker": {"path": str(worker), "bytes": worker.stat().st_size, "sha256": sha256(worker)},
            "server": {"path": str(server), "bytes": server.stat().st_size, "sha256": sha256(server)},
            "client": {"path": str(client), "bytes": client.stat().st_size, "sha256": sha256(client)},
        },
        "parameters": {
            "trials": args.trials,
            "storageMiB": args.storage_mib,
            "payloadKiB": args.payload_kib,
            "rows": rows,
            "verifyTrials": args.verify_trials,
            "concurrency": args.concurrency,
            "oneShotPerClient": args.one_shot_per_client,
            "countStatements": args.count_statements,
            "sumStatements": args.sum_statements,
        },
        "database": str(retained_database),
        "storage": storage,
        "restartVerify": restart_verify,
        "network": network,
        "finishedUtc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ComparisonFailure, subprocess.TimeoutExpired, json.JSONDecodeError) as exc:
        print(f"MiniSQL platform comparison: FAIL ({exc})", file=sys.stderr)
        raise SystemExit(1)
