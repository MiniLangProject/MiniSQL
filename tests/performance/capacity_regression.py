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

"""Restart-aware MiniSQL capacity profiles for 1, 5, and 10 GiB datasets."""

from __future__ import annotations

import argparse
import ctypes
import json
import math
import re
import subprocess
import sys
import time
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / "build" / "performance" / "capacity"
WORKER_SOURCE = ROOT / "src" / "tests" / "m51_capacity_worker.ml"
WORKER = BUILD / "minisql-capacity-worker.exe"
PROFILE_BYTES = {
    "smoke": 64 * 1024 * 1024,
    "1": 1 * 1024 * 1024 * 1024,
    "5": 5 * 1024 * 1024 * 1024,
    "10": 10 * 1024 * 1024 * 1024,
}


class CapacityFailure(RuntimeError):
    """Raised when a native worker or a postcondition fails."""


class ProcessMemoryCountersEx(ctypes.Structure):
    """Windows PROCESS_MEMORY_COUNTERS_EX layout used without third-party modules."""

    _fields_ = [
        ("cb", ctypes.c_ulong),
        ("page_fault_count", ctypes.c_ulong),
        ("peak_working_set_size", ctypes.c_size_t),
        ("working_set_size", ctypes.c_size_t),
        ("quota_peak_paged_pool_usage", ctypes.c_size_t),
        ("quota_paged_pool_usage", ctypes.c_size_t),
        ("quota_peak_non_paged_pool_usage", ctypes.c_size_t),
        ("quota_non_paged_pool_usage", ctypes.c_size_t),
        ("pagefile_usage", ctypes.c_size_t),
        ("peak_pagefile_usage", ctypes.c_size_t),
        ("private_usage", ctypes.c_size_t),
    ]


def private_bytes(process_id: int) -> int:
    """Return current private bytes for a Windows process, or zero if unavailable."""

    if sys.platform != "win32":
        return 0
    query_information = 0x0400
    virtual_memory_read = 0x0010
    kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
    psapi = ctypes.WinDLL("psapi", use_last_error=True)
    kernel32.OpenProcess.argtypes = [ctypes.c_ulong, ctypes.c_int, ctypes.c_ulong]
    kernel32.OpenProcess.restype = ctypes.c_void_p
    kernel32.CloseHandle.argtypes = [ctypes.c_void_p]
    kernel32.CloseHandle.restype = ctypes.c_int
    psapi.GetProcessMemoryInfo.argtypes = [
        ctypes.c_void_p,
        ctypes.POINTER(ProcessMemoryCountersEx),
        ctypes.c_ulong,
    ]
    psapi.GetProcessMemoryInfo.restype = ctypes.c_int
    handle = kernel32.OpenProcess(
        query_information | virtual_memory_read, False, process_id
    )
    if not handle:
        return 0
    counters = ProcessMemoryCountersEx()
    counters.cb = ctypes.sizeof(counters)
    try:
        if not psapi.GetProcessMemoryInfo(
            handle, ctypes.byref(counters), counters.cb
        ):
            return 0
        return int(counters.private_usage)
    finally:
        kernel32.CloseHandle(handle)


def compiler_path(explicit: str | None) -> Path:
    """Resolve the explicit or conventional MiniLang compiler location."""

    candidates = [
        Path(explicit) if explicit else None,
        ROOT.parent / "MiniLangCompilerPy" / "mlc_win64.py",
        ROOT / "mlc_win64.py",
    ]
    for candidate in candidates:
        if candidate and candidate.is_file():
            return candidate.resolve()
    raise CapacityFailure("MiniLang Python compiler not found; pass --compiler")


def run(command: list[str], timeout: int) -> tuple[str, float, int]:
    """Run one bounded child process and return output, elapsed time, and peak private bytes."""

    started = time.monotonic()
    process = subprocess.Popen(
        command,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    peak_private_bytes = 0
    while process.poll() is None:
        peak_private_bytes = max(peak_private_bytes, private_bytes(process.pid))
        if time.monotonic() - started >= timeout:
            process.kill()
            output, _ = process.communicate()
            raise subprocess.TimeoutExpired(command, timeout, output=output)
        time.sleep(0.05)
    output, _ = process.communicate()
    peak_private_bytes = max(peak_private_bytes, private_bytes(process.pid))
    elapsed = time.monotonic() - started
    if output:
        print(output, end="")
    if process.returncode != 0:
        raise CapacityFailure(
            f"command failed with exit code {process.returncode}: {' '.join(command)}"
        )
    return output, elapsed, peak_private_bytes


def enforce_memory_budget(peak_bytes: int, maximum_bytes: int, phase: str) -> None:
    """Reject a profile phase whose observed private-memory peak exceeds its budget."""

    if peak_bytes > maximum_bytes:
        raise CapacityFailure(
            f"{phase} private-memory peak {peak_bytes} exceeds budget {maximum_bytes}"
        )


def compile_worker(compiler: Path) -> None:
    """Compile the native restart-sized capacity worker with project imports."""

    BUILD.mkdir(parents=True, exist_ok=True)
    run(
        [
            sys.executable,
            str(compiler),
            str(WORKER_SOURCE),
            str(WORKER),
            "-I",
            str(ROOT / "src"),
            "-I",
            str(compiler.parent),
            "--keep-going",
            "--max-errors",
            "100",
        ],
        1800,
    )


def tree_bytes(path: Path) -> int:
    """Return the physical byte size of every regular file below a directory."""

    return sum(item.stat().st_size for item in path.rglob("*") if item.is_file())


def parse_database_path(output: str) -> Path:
    """Extract and normalize the database path reported by worker initialization."""

    match = re.search(r"^CAPACITY_DATABASE_PATH=(.+)$", output, re.MULTILINE)
    if not match:
        raise CapacityFailure("capacity worker did not report the database path")
    return Path(match.group(1).strip()).resolve()


def main() -> int:
    """Execute the selected capacity profile and persist its machine-readable report."""

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--profile", choices=PROFILE_BYTES, default="smoke")
    parser.add_argument("--compiler")
    parser.add_argument("--payload-kib", type=int, default=1024)
    parser.add_argument("--chunk-mib", type=int, default=32)
    parser.add_argument("--max-private-mib", type=int, default=512)
    parser.add_argument("--vacuum", action="store_true")
    parser.add_argument("--skip-build", action="store_true")
    parser.add_argument("--output-root", type=Path)
    args = parser.parse_args()

    if args.payload_kib < 2 or args.chunk_mib < 1 or args.max_private_mib < 64:
        raise CapacityFailure(
            "payload must be >= 2 KiB, chunk size positive, and memory budget >= 64 MiB"
        )
    compiler = compiler_path(args.compiler)
    if not args.skip_build or not WORKER.is_file():
        compile_worker(compiler)

    target_bytes = PROFILE_BYTES[args.profile]
    payload_bytes = args.payload_kib * 1024
    expected_rows = math.ceil(target_bytes / payload_bytes)
    rows_per_chunk = max(1, (args.chunk_mib * 1024 * 1024) // payload_bytes)
    stamp = time.strftime("%Y%m%d-%H%M%S")
    output_root = (args.output_root or (BUILD / f"profile-{args.profile}gib-{stamp}")).resolve()
    output_root.mkdir(parents=True, exist_ok=False)

    report: dict[str, object] = {
        "profile": args.profile,
        "targetBytes": target_bytes,
        "payloadBytes": payload_bytes,
        "expectedRows": expected_rows,
        "rowsPerProcess": rows_per_chunk,
        "chunks": [],
        "startedUtc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }
    memory_budget = args.max_private_mib * 1024 * 1024
    init_output, init_seconds, init_peak = run(
        [str(WORKER), "init", str(output_root), f"capacity_{args.profile}gib"], 600
    )
    enforce_memory_budget(init_peak, memory_budget, "initialize")
    database = parse_database_path(init_output)
    report["database"] = str(database)
    report["initializeSeconds"] = round(init_seconds, 3)
    report["initializePeakPrivateBytes"] = init_peak
    report["maxPrivateBytes"] = memory_budget

    first_id = 1
    while first_id <= expected_rows:
        rows = min(rows_per_chunk, expected_rows - first_id + 1)
        output, seconds, peak_private = run(
            [
                str(WORKER),
                "insert",
                str(database),
                str(first_id),
                str(rows),
                str(payload_bytes),
            ],
            7200,
        )
        enforce_memory_budget(peak_private, memory_budget, f"insert chunk {first_id}")
        report["chunks"].append(
            {
                "firstId": first_id,
                "rows": rows,
                "seconds": round(seconds, 3),
                "peakPrivateBytes": peak_private,
                "output": output.strip(),
            }
        )
        first_id += rows

    point_output, point_seconds, point_peak = run(
        [str(WORKER), "point", str(database), str(expected_rows), str(payload_bytes)],
        7200,
    )
    enforce_memory_budget(point_peak, memory_budget, "point lookup")
    report["pointLookupSeconds"] = round(point_seconds, 3)
    report["pointLookupPeakPrivateBytes"] = point_peak
    report["pointLookupOutput"] = point_output.strip()

    verify_output, verify_seconds, verify_peak = run(
        [str(WORKER), "verify", str(database), str(expected_rows), str(payload_bytes)],
        7200,
    )
    enforce_memory_budget(verify_peak, memory_budget, "verify")
    report["verifySeconds"] = round(verify_seconds, 3)
    report["verifyPeakPrivateBytes"] = verify_peak
    report["verifyOutput"] = verify_output.strip()

    if args.vacuum:
        vacuum_output, vacuum_seconds, vacuum_peak = run(
            [str(WORKER), "vacuum", str(database), str(expected_rows)], 21600
        )
        enforce_memory_budget(vacuum_peak, memory_budget, "vacuum")
        report["vacuumSeconds"] = round(vacuum_seconds, 3)
        report["vacuumPeakPrivateBytes"] = vacuum_peak
        report["vacuumOutput"] = vacuum_output.strip()
        # VACUUM is followed by a second independent open and semantic check.
        post_output, post_seconds, post_peak = run(
            [str(WORKER), "verify", str(database), str(expected_rows), str(payload_bytes)],
            7200,
        )
        enforce_memory_budget(post_peak, memory_budget, "post-vacuum verify")
        report["postVacuumVerifySeconds"] = round(post_seconds, 3)
        report["postVacuumVerifyPeakPrivateBytes"] = post_peak
        report["postVacuumVerifyOutput"] = post_output.strip()

    logical_payload_bytes = expected_rows * payload_bytes
    wal_path = database / "wal" / "wal.log"
    wal_bytes = wal_path.stat().st_size
    if logical_payload_bytes < target_bytes:
        raise CapacityFailure("logical payload did not reach the selected profile")
    if wal_bytes > 65536:
        raise CapacityFailure(f"automatic checkpoint left an oversized WAL: {wal_bytes} bytes")
    report["logicalPayloadBytes"] = logical_payload_bytes
    report["databaseTreeBytes"] = tree_bytes(database)
    report["walBytes"] = wal_bytes
    report["finishedUtc"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    report_path = output_root / "capacity-report.json"
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(
        f"MiniSQL capacity profile {args.profile} GiB: SUCCESS "
        f"rows={expected_rows} logicalBytes={logical_payload_bytes} walBytes={wal_bytes} "
        f"report={report_path}"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (CapacityFailure, subprocess.TimeoutExpired) as exc:
        print(f"MiniSQL capacity profile: FAIL ({exc})", file=sys.stderr)
        raise SystemExit(1)
