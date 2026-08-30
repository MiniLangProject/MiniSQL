#!/usr/bin/env python3
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.

"""Run isolated process, network, storage and WAL fault-injection scenarios."""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import re
import shutil
import socket
import subprocess
import sys
import threading
import time

PROJECT_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PROJECT_ROOT / "clients" / "python"))
import minisql  # noqa: E402

CREATED_PATH = re.compile(r"MiniSQL database created:\s*(.+)")
WAL_HEADER_BYTES = 80


def run(command: list[str], timeout: float = 600.0, expect_success: bool = True) -> subprocess.CompletedProcess[str]:
    """Run one bounded child command and retain diagnostics for the drill report."""
    completed = subprocess.run(
        command,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=timeout,
        check=False,
    )
    if expect_success and completed.returncode != 0:
        raise RuntimeError(
            f"command failed ({completed.returncode}): {' '.join(command)}\n"
            f"stdout={completed.stdout[-4000:]}\nstderr={completed.stderr[-4000:]}"
        )
    return completed


def free_port() -> int:
    """Reserve and return a currently unused loopback TCP port."""
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", 0))
        return int(listener.getsockname()[1])


def wait_ready(process: subprocess.Popen[bytes], port: int, timeout: float = 60.0) -> None:
    """Wait until a child server accepts a real MiniSQL connection."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if process.poll() is not None:
            raise RuntimeError(f"server exited before readiness: {process.returncode}")
        try:
            connection = minisql.connect(port=port, autocommit=True, connect_timeout=0.25, socket_timeout=2)
            connection.close()
            return
        except Exception:
            time.sleep(0.05)
    raise RuntimeError(f"server readiness timeout on port {port}")


def start_server(server_exe: Path, database: Path, port: int) -> subprocess.Popen[bytes]:
    """Start one isolated trusted-loopback server with detached diagnostics."""
    process = subprocess.Popen(
        [str(server_exe), "--serve", str(database), str(port), "32"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    wait_ready(process, port)
    return process


def shutdown(port: int, process: subprocess.Popen[bytes]) -> None:
    """Request bounded graceful shutdown, escalating only for cleanup."""
    if process.poll() is not None:
        return
    try:
        connection = minisql.connect(port=port, autocommit=True, connect_timeout=1, socket_timeout=5)
        connection.cursor().execute("SHUTDOWN")
        connection.close()
        process.wait(timeout=15)
    except Exception:
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait(timeout=5)


def execute(port: int, sql: str) -> list[tuple[object, ...]]:
    """Execute one autocommit statement on an isolated connection."""
    connection = minisql.connect(port=port, autocommit=True, connect_timeout=3, socket_timeout=30)
    try:
        cursor = connection.cursor()
        cursor.execute(sql)
        return cursor.fetchall() if cursor.description else []
    finally:
        connection.close()


def inject_network_aborts(port: int, attempts: int) -> dict[str, object]:
    """Drop clients at different partial-frame boundaries and verify liveness."""
    started = time.monotonic()
    for index in range(attempts):
        # The server sends HELLO first. The peer deliberately neither consumes
        # it nor completes its request, covering close/reset during framing.
        fragment_length = 1 + index % 31
        fragment = (b"MSQL" + bytes((index + offset) & 0xFF for offset in range(32)))[:fragment_length]
        with socket.create_connection(("127.0.0.1", port), timeout=3) as client:
            client.sendall(fragment)
        if (index + 1) % 16 == 0:
            connection = minisql.connect(port=port, autocommit=True, connect_timeout=2, socket_timeout=5)
            try:
                if not connection.ping():
                    raise RuntimeError("PING failed after partial-frame disconnects")
            finally:
                connection.close()
    # Verify the final state even when attempts is not a multiple of 16.
    connection = minisql.connect(port=port, autocommit=True, connect_timeout=2, socket_timeout=5)
    try:
        if not connection.ping():
            raise RuntimeError("server stopped responding after network abort injection")
    finally:
        connection.close()
    return {"attempts": attempts, "durationSeconds": time.monotonic() - started}


def crash_during_writes(
    server_exe: Path,
    database: Path,
    port: int,
    server: subprocess.Popen[bytes],
    writers: int,
    confirmed_target: int,
    payload_bytes: int,
) -> tuple[subprocess.Popen[bytes], dict[str, object]]:
    """Kill the server after acknowledged commits and validate crash recovery."""
    stop = threading.Event()
    lock = threading.Lock()
    next_identifier = 1
    confirmed: list[int] = []
    issued: list[int] = []
    payload = "x" * payload_bytes

    # Owns one persistent client connection and records only acknowledged commits.
    def writer() -> None:
        """Write unique rows until the coordinator injects the process crash."""
        nonlocal next_identifier
        connection = minisql.connect(port=port, autocommit=True, connect_timeout=3, socket_timeout=10)
        try:
            cursor = connection.cursor()
            while not stop.is_set():
                with lock:
                    identifier = next_identifier
                    next_identifier += 1
                    issued.append(identifier)
                try:
                    cursor.execute(
                        f"INSERT INTO fault_load(id, payload) VALUES ({identifier}, '{payload}')"
                    )
                    with lock:
                        confirmed.append(identifier)
                except Exception:
                    return
        finally:
            try:
                connection.close()
            except Exception:
                pass

    started = time.monotonic()
    with ThreadPoolExecutor(max_workers=writers) as pool:
        futures = [pool.submit(writer) for _ in range(writers)]
        deadline = time.monotonic() + 60
        while time.monotonic() < deadline:
            with lock:
                acknowledged_before_kill = len(confirmed)
            if acknowledged_before_kill >= confirmed_target:
                break
            if server.poll() is not None:
                raise RuntimeError(f"server exited before crash injection: {server.returncode}")
            time.sleep(0.01)
        else:
            raise RuntimeError(f"writers did not reach {confirmed_target} acknowledged commits")
        server.kill()
        server.wait(timeout=10)
        stop.set()
        for future in futures:
            future.result(timeout=15)

    restarted = start_server(server_exe, database, port)
    recovered_rows = int(execute(port, "SELECT COUNT(*) FROM fault_load")[0][0])
    if recovered_rows < acknowledged_before_kill:
        raise RuntimeError(
            f"recovery lost acknowledged commits: recovered={recovered_rows} acknowledged={acknowledged_before_kill}"
        )
    sentinel = 2_000_000_000
    execute(port, f"INSERT INTO fault_load(id, payload) VALUES ({sentinel}, 'post-crash')")
    post_recovery_rows = int(execute(port, "SELECT COUNT(*) FROM fault_load")[0][0])
    if post_recovery_rows != recovered_rows + 1:
        raise RuntimeError("post-recovery write did not advance the durable row count")
    return restarted, {
        "writers": writers,
        "acknowledgedBeforeKill": acknowledged_before_kill,
        "issuedBeforeStop": len(issued),
        "recoveredRows": recovered_rows,
        "postRecoveryRows": post_recovery_rows,
        "durationSeconds": time.monotonic() - started,
    }


def corrupt_middle_wal(database: Path, clone: Path, check_exe: Path) -> dict[str, object]:
    """Corrupt a non-tail WAL header in a clone and require fail-closed checking."""
    shutil.copytree(database, clone)
    wal_path = clone / "wal" / "wal.log"
    data = bytearray(wal_path.read_bytes())
    offsets: list[int] = []
    offset = 0
    while offset + WAL_HEADER_BYTES <= len(data):
        total_length = int.from_bytes(data[offset + 16 : offset + 20], "little")
        if total_length < WAL_HEADER_BYTES or offset + total_length > len(data):
            break
        offsets.append(offset)
        offset += total_length
    if len(offsets) < 3:
        raise RuntimeError(f"WAL fixture has too few complete records: {len(offsets)}")
    target = offsets[len(offsets) // 2]
    data[target + 12] ^= 0x01
    wal_path.write_bytes(data)
    checked = run([str(check_exe), str(clone)], timeout=120, expect_success=False)
    if checked.returncode == 0:
        raise RuntimeError("offline checker accepted a checksummed middle-WAL corruption")
    diagnostic = (checked.stdout + "\n" + checked.stderr)[-4000:]
    if "9004" not in diagnostic and "corrupt" not in diagnostic.lower() and "checksum" not in diagnostic.lower():
        raise RuntimeError(f"checker rejected WAL without a corruption diagnostic: {diagnostic}")
    return {
        "records": len(offsets),
        "corruptedOffset": target + 12,
        "checkerExitCode": checked.returncode,
        "diagnostic": diagnostic,
    }


def main() -> int:
    """Execute every isolated fault scenario and publish machine-readable evidence."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--work-root", type=Path, required=True)
    parser.add_argument("--server-exe", type=Path, default=PROJECT_ROOT / "build" / "bin" / "minisqld.exe")
    parser.add_argument("--check-exe", type=Path, default=PROJECT_ROOT / "build" / "bin" / "minisql-check.exe")
    parser.add_argument("--crash-worker", type=Path, default=PROJECT_ROOT / "build" / "bin" / "minisql-m7-crash-worker.exe")
    parser.add_argument("--storage-fault-exe", type=Path, default=PROJECT_ROOT / "build" / "bin" / "minisql-m78-fault-injection.exe")
    parser.add_argument("--writers", type=int, default=4)
    parser.add_argument("--confirmed-before-kill", type=int, default=200)
    parser.add_argument("--payload-bytes", type=int, default=1024)
    parser.add_argument("--network-aborts", type=int, default=128)
    parser.add_argument("--crash-matrix-iterations", type=int, default=4)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    if args.work_root.exists() and any(args.work_root.iterdir()):
        parser.error("--work-root must be absent or empty")
    if min(args.writers, args.confirmed_before_kill, args.payload_bytes, args.network_aborts, args.crash_matrix_iterations) < 1:
        parser.error("all numeric workload arguments must be positive")
    args.work_root.mkdir(parents=True, exist_ok=True)
    report_path = args.report or args.work_root / "production-fault-drill.json"
    report: dict[str, object] = {"status": "running", "startedUnixSeconds": time.time(), "scenarios": {}}
    server: subprocess.Popen[bytes] | None = None
    port = free_port()
    started = time.monotonic()
    try:
        storage_root = args.work_root / "storage-fault"
        storage_root.mkdir()
        storage_result = run([str(args.storage_fault_exe), str(storage_root)], timeout=300)
        report["scenarios"]["storageExhaustion"] = {
            "exitCode": storage_result.returncode,
            "successBanner": "MiniSQL M78 fault injection: SUCCESS" in storage_result.stdout,
        }

        crash_matrix_root = args.work_root / "crash-matrix"
        crash_matrix = run(
            [
                sys.executable,
                str(PROJECT_ROOT / "tools" / "quality" / "minisql_quality.py"),
                "crash-matrix",
                "--worker",
                str(args.crash_worker),
                "--output-root",
                str(crash_matrix_root),
                "--iterations",
                str(args.crash_matrix_iterations),
            ],
            timeout=1800,
        )
        report["scenarios"]["nativeCrashMatrix"] = {
            "iterations": args.crash_matrix_iterations,
            "cases": args.crash_matrix_iterations * 2,
            "successBanner": "MiniSQL M49 crash matrix: SUCCESS" in crash_matrix.stdout,
        }

        data_root = args.work_root / "data"
        data_root.mkdir()
        initialized = run([str(args.server_exe), "--init", str(data_root), "fault_drill", "4096"])
        match = CREATED_PATH.search(initialized.stdout)
        if match is None:
            raise RuntimeError(f"cannot parse initialized database path: {initialized.stdout}")
        database = Path(match.group(1).strip()).resolve()
        server = start_server(args.server_exe, database, port)
        execute(port, "CREATE TABLE fault_load (id INTEGER PRIMARY KEY, payload TEXT NOT NULL)")

        report["scenarios"]["networkAbort"] = inject_network_aborts(port, args.network_aborts)
        server, crash_report = crash_during_writes(
            args.server_exe,
            database,
            port,
            server,
            args.writers,
            args.confirmed_before_kill,
            args.payload_bytes,
        )
        report["scenarios"]["processCrash"] = crash_report
        shutdown(port, server)
        server = None

        healthy_check = run([str(args.check_exe), str(database)], timeout=300)
        report["scenarios"]["postCrashIntegrity"] = {
            "exitCode": healthy_check.returncode,
            "success": "SUCCESS" in healthy_check.stdout,
        }
        report["scenarios"]["walCorruption"] = corrupt_middle_wal(
            database, args.work_root / "corrupt-wal-clone", args.check_exe
        )
        report["status"] = "success"
        report["durationSeconds"] = time.monotonic() - started
        print(json.dumps(report, indent=2, sort_keys=True))
        print("MiniSQL production fault drill: SUCCESS")
        return 0
    except Exception as exc:
        report["status"] = "failure"
        report["durationSeconds"] = time.monotonic() - started
        report["error"] = str(exc)
        print(f"MiniSQL production fault drill: FAIL {exc}", file=sys.stderr)
        return 1
    finally:
        if server is not None:
            shutdown(port, server)
        report_path.parent.mkdir(parents=True, exist_ok=True)
        temporary = report_path.with_suffix(report_path.suffix + ".new")
        temporary.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        temporary.replace(report_path)


if __name__ == "__main__":
    raise SystemExit(main())
