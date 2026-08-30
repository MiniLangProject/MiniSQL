#!/usr/bin/env python3
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.

"""Exercise live WAL export, standby reads, promotion and post-failover writes."""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import re
import socket
import subprocess
import sys
import time

PROJECT_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PROJECT_ROOT / "clients" / "python"))
import minisql  # noqa: E402

CREATED_PATH = re.compile(r"MiniSQL database created:\s*(.+)")


def run(command: list[str], timeout: float = 300.0) -> subprocess.CompletedProcess[str]:
    """Runs one required tool command and preserves diagnostics on failure."""
    completed = subprocess.run(command, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout)
    if completed.returncode != 0:
        raise RuntimeError(f"command failed ({completed.returncode}): {' '.join(command)}\n{completed.stdout}\n{completed.stderr}")
    return completed


def free_port() -> int:
    """Returns an unused loopback TCP port."""
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", 0))
        return int(listener.getsockname()[1])


def wait_ready(process: subprocess.Popen[str], port: int, timeout: float = 60.0) -> None:
    """Waits until a child server accepts connections or terminates."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if process.poll() is not None:
            raise RuntimeError(f"server stopped before readiness with exit {process.returncode}")
        try:
            connection = minisql.connect(port=port, autocommit=True, connect_timeout=0.5, socket_timeout=2)
            connection.close()
            return
        except Exception:
            time.sleep(0.05)
    raise RuntimeError(f"server did not become ready on port {port}")


def start_server(server_exe: Path, database: Path, port: int, standby: bool = False) -> subprocess.Popen[str]:
    """Starts one trusted loopback primary or read-only standby."""
    mode = "--serve-standby" if standby else "--serve"
    # Unread verbose log pipes fill quickly and would block the server under
    # load, so the drill deliberately detaches child output.
    process = subprocess.Popen([str(server_exe), mode, str(database), str(port), "32"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, text=True, encoding="utf-8", errors="replace")
    wait_ready(process, port)
    return process


def shutdown(port: int, process: subprocess.Popen[str]) -> None:
    """Requests graceful shutdown and escalates only when the bounded drain fails."""
    if process.poll() is not None:
        return
    try:
        connection = minisql.connect(port=port, autocommit=True, connect_timeout=2, socket_timeout=5)
        cursor = connection.cursor()
        cursor.execute("SHUTDOWN")
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
    """Executes one statement on an isolated autocommit connection."""
    connection = minisql.connect(port=port, autocommit=True, connect_timeout=3, socket_timeout=30)
    try:
        cursor = connection.cursor()
        cursor.execute(sql)
        return cursor.fetchall() if cursor.description else []
    finally:
        connection.close()


def writer(port: int, first: int, count: int, payload_bytes: int) -> int:
    """Inserts one deterministic key range through a persistent connection."""
    connection = minisql.connect(port=port, autocommit=True, connect_timeout=3, socket_timeout=30)
    payload = "x" * payload_bytes
    try:
        cursor = connection.cursor()
        for identifier in range(first, first + count):
            cursor.execute(f"INSERT INTO ha_load(id, payload) VALUES ({identifier}, '{payload}')")
        return count
    finally:
        connection.close()


def reader(port: int, operations: int) -> int:
    """Runs repeated aggregate consistency reads against a standby."""
    connection = minisql.connect(port=port, autocommit=True, connect_timeout=3, socket_timeout=30)
    try:
        cursor = connection.cursor()
        for _ in range(operations):
            cursor.execute("SELECT COUNT(*), SUM(id) FROM ha_load")
            row = cursor.fetchone()
            if row is None or int(row[0]) < 1:
                raise RuntimeError("standby returned an invalid aggregate")
        return operations
    finally:
        connection.close()


def main() -> int:
    """Builds an isolated database and emits a machine-readable HA report."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--work-root", type=Path, required=True)
    parser.add_argument("--server-exe", type=Path, default=PROJECT_ROOT / "build" / "bin" / "minisqld.exe")
    parser.add_argument("--client-exe", type=Path, default=PROJECT_ROOT / "build" / "bin" / "minisql.exe")
    parser.add_argument("--backup-exe", type=Path, default=PROJECT_ROOT / "build" / "bin" / "minisql-backup.exe")
    parser.add_argument("--check-exe", type=Path, default=PROJECT_ROOT / "build" / "bin" / "minisql-check.exe")
    parser.add_argument("--writers", type=int, default=4)
    parser.add_argument("--rows-per-writer", type=int, default=1000)
    parser.add_argument("--payload-bytes", type=int, default=1024)
    parser.add_argument("--readers", type=int, default=8)
    parser.add_argument("--reads-per-reader", type=int, default=100)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    if args.work_root.exists() and any(args.work_root.iterdir()):
        parser.error("--work-root must be absent or empty")
    args.work_root.mkdir(parents=True, exist_ok=True)
    data_root = args.work_root / "data"
    data_root.mkdir()
    archive = args.work_root / "archive"
    standby = args.work_root / "standby"
    primary_port, standby_port, promoted_port = free_port(), free_port(), free_port()
    processes: list[tuple[int, subprocess.Popen[str]]] = []
    started = time.monotonic()
    try:
        initialized = run([str(args.server_exe), "--init", str(data_root), "ha_drill", "4096"])
        match = CREATED_PATH.search(initialized.stdout)
        if match is None:
            raise RuntimeError(f"cannot parse database path: {initialized.stdout}")
        database = Path(match.group(1).strip()).resolve()
        primary = start_server(args.server_exe, database, primary_port)
        processes.append((primary_port, primary))
        execute(primary_port, "CREATE TABLE ha_load (id INTEGER PRIMARY KEY, payload TEXT NOT NULL)")
        execute(primary_port, "INSERT INTO ha_load(id, payload) VALUES (0, 'base')")
        shutdown(primary_port, primary)
        run([str(args.backup_exe), "archive-init", str(database), str(archive)])

        primary = start_server(args.server_exe, database, primary_port)
        processes[-1] = (primary_port, primary)
        load_started = time.monotonic()
        with ThreadPoolExecutor(max_workers=args.writers) as pool:
            futures = [pool.submit(writer, primary_port, 1 + index * args.rows_per_writer, args.rows_per_writer, args.payload_bytes) for index in range(args.writers)]
            # Capture multiple durable prefixes while writers are still active.
            # A bounded count avoids turning process startup into the workload.
            live_exports = 0
            while live_exports < 16 and not all(future.done() for future in futures):
                run([str(args.backup_exe), "archive-wal-live", str(database), str(archive)])
                live_exports += 1
                time.sleep(0.05)
            written = sum(future.result() for future in futures)
        write_seconds = time.monotonic() - load_started
        run([str(args.backup_exe), "archive-wal-live", str(database), str(archive)])
        expected_rows = 1 + written

        run([str(args.backup_exe), "standby-materialize", str(archive), str(standby)])
        standby_process = start_server(args.server_exe, standby, standby_port, standby=True)
        processes.append((standby_port, standby_process))
        observed = int(execute(standby_port, "SELECT COUNT(*) FROM ha_load")[0][0])
        if observed != expected_rows:
            raise RuntimeError(f"standby row count {observed} != expected {expected_rows}")
        read_started = time.monotonic()
        with ThreadPoolExecutor(max_workers=args.readers) as pool:
            read_futures = [pool.submit(reader, standby_port, args.reads_per_reader) for _ in range(args.readers)]
            reads = sum(future.result() for future in read_futures)
        read_seconds = time.monotonic() - read_started

        shutdown(primary_port, primary)
        shutdown(standby_port, standby_process)
        failover_started = time.monotonic()
        run([str(args.backup_exe), "standby-promote", str(standby)])
        promoted = start_server(args.server_exe, standby, promoted_port)
        processes.append((promoted_port, promoted))
        recovery_time_seconds = time.monotonic() - failover_started
        execute(promoted_port, f"INSERT INTO ha_load(id, payload) VALUES ({expected_rows + 1000}, 'post-promotion')")
        promoted_rows = int(execute(promoted_port, "SELECT COUNT(*) FROM ha_load")[0][0])
        if promoted_rows != expected_rows + 1:
            raise RuntimeError("promoted primary did not retain and extend the replicated data")
        shutdown(promoted_port, promoted)
        run([str(args.check_exe), str(standby)])

        report = {
            "status": "success", "expectedRows": expected_rows, "promotedRows": promoted_rows,
            "writtenRows": written, "payloadBytes": written * args.payload_bytes,
            "liveExportsDuringWrites": live_exports,
            "writeSeconds": write_seconds, "writesPerSecond": written / write_seconds,
            "standbyReads": reads, "readSeconds": read_seconds, "readsPerSecond": reads / read_seconds,
            "recoveryTimeSeconds": recovery_time_seconds,
            "totalSeconds": time.monotonic() - started,
        }
        output = json.dumps(report, indent=2, sort_keys=True)
        if args.report:
            args.report.parent.mkdir(parents=True, exist_ok=True)
            args.report.write_text(output + "\n", encoding="utf-8")
        print(output)
        print("MiniSQL production failover drill: SUCCESS")
        return 0
    finally:
        for port, process in reversed(processes):
            shutdown(port, process)


if __name__ == "__main__":
    raise SystemExit(main())
