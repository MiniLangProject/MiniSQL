#!/usr/bin/env python3
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.

"""Qualify native write fencing, split-brain rejection, failover, and rejoin."""

from __future__ import annotations

import argparse
import json
import re
import shutil
import socket
import subprocess
import sys
import time
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PROJECT_ROOT / "clients" / "python"))
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "replication"))
import minisql  # noqa: E402
from minisql_ha_controller import FileWitness, write_database_epoch  # noqa: E402
from minisql_hot_replica import Backend, ReplicaError, SwitchingProxy  # noqa: E402

CREATED_PATH = re.compile(r"MiniSQL database created:\s*(.+)")


def run(command: list[str], timeout: float = 180.0) -> subprocess.CompletedProcess[str]:
    """Runs one required native command and raises with complete diagnostics."""
    completed = subprocess.run(command, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout)
    if completed.returncode != 0:
        raise RuntimeError(f"command failed: {' '.join(command)}\n{completed.stdout}\n{completed.stderr}")
    return completed


def free_port() -> int:
    """Returns a currently unused loopback TCP port."""
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", 0))
        return int(listener.getsockname()[1])


def wait_ready(process: subprocess.Popen[bytes], port: int) -> None:
    """Waits for a server to answer a real MiniSQL connection."""
    deadline = time.monotonic() + 45
    while time.monotonic() < deadline:
        if process.poll() is not None:
            raise RuntimeError(f"server exited before readiness: {process.returncode}")
        try:
            connection = minisql.connect(port=port, autocommit=True, connect_timeout=0.5, socket_timeout=2)
            connection.close()
            return
        except Exception:
            time.sleep(0.05)
    raise RuntimeError(f"server did not become ready on {port}")


def start_fenced(server: Path, database: Path, port: int, witness: FileWitness, epoch: int, node: int) -> subprocess.Popen[bytes]:
    """Starts one fenced primary with detached logs."""
    process = subprocess.Popen([str(server), "--serve-fenced", str(database), str(port), "16", str(witness.lease_path), str(epoch), str(node), str(witness.clock_skew_ms)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    wait_ready(process, port)
    return process


def start_standby(server: Path, database: Path, port: int) -> subprocess.Popen[bytes]:
    """Starts one read-only rejoined standby."""
    process = subprocess.Popen([str(server), "--serve-standby", str(database), str(port), "16"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    wait_ready(process, port)
    return process


def start_primary(server: Path, database: Path, port: int) -> subprocess.Popen[bytes]:
    """Starts an unfenced primary used only to establish the archive base schema."""
    process = subprocess.Popen([str(server), "--serve", str(database), str(port), "16"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    wait_ready(process, port)
    return process


def terminate(process: subprocess.Popen[bytes] | None) -> None:
    """Terminates a child process with bounded escalation."""
    if process is None or process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=5)


def execute(port: int, sql: str) -> list[tuple[object, ...]]:
    """Executes one autocommit statement and returns all rows."""
    connection = minisql.connect(port=port, autocommit=True, connect_timeout=2, socket_timeout=20)
    try:
        cursor = connection.cursor()
        cursor.execute(sql)
        return cursor.fetchall() if cursor.description else []
    finally:
        connection.close()


def expect_fenced(port: int, sql: str) -> None:
    """Requires the stable 9038 write-fenced error from a direct connection."""
    try:
        execute(port, sql)
    except minisql.OperationalError as exc:
        if exc.code == 9038:
            return
        raise RuntimeError(f"unexpected operational error {exc.code}: {exc}") from exc
    raise RuntimeError("retired primary accepted a write")


def main() -> int:
    """Builds an isolated cluster and emits a machine-readable qualification report."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--work-root", type=Path, required=True)
    parser.add_argument("--server-exe", type=Path, default=PROJECT_ROOT / "build" / "bin" / "minisqld.exe")
    parser.add_argument("--backup-exe", type=Path, default=PROJECT_ROOT / "build" / "bin" / "minisql-backup.exe")
    parser.add_argument("--check-exe", type=Path, default=PROJECT_ROOT / "build" / "bin" / "minisql-check.exe")
    args = parser.parse_args()
    if args.work_root.exists() and any(args.work_root.iterdir()):
        parser.error("--work-root must be absent or empty")
    args.work_root.mkdir(parents=True, exist_ok=True)
    data_root = args.work_root / "data"
    data_root.mkdir()
    archive = args.work_root / "archive"
    standby = args.work_root / "standby"
    rejoined = args.work_root / "rejoined"
    witness = FileWitness(args.work_root / "witness", lease_ms=2500, clock_skew_ms=100)
    port_a, port_b, proxy_port, rejoin_port = free_port(), free_port(), free_port(), free_port()
    processes: list[subprocess.Popen[bytes]] = []
    proxy: SwitchingProxy | None = None
    started = time.monotonic()
    try:
        initialized = run([str(args.server_exe), "--init", str(data_root), "fenced", "4096"])
        match = CREATED_PATH.search(initialized.stdout)
        if match is None:
            raise RuntimeError("database path was not reported")
        primary = Path(match.group(1).strip()).resolve()
        schema_server = start_primary(args.server_exe, primary, port_a)
        processes.append(schema_server)
        execute(port_a, "CREATE TABLE fenced_rows (id INTEGER PRIMARY KEY, note TEXT NOT NULL)")
        execute(port_a, "SHUTDOWN")
        schema_server.wait(timeout=15)
        run([str(args.backup_exe), "archive-init", str(primary), str(archive)])

        epoch_a, _ = witness.acquire(101)
        write_database_epoch(primary, epoch_a, 101)
        server_a = start_fenced(args.server_exe, primary, port_a, witness, epoch_a, 101)
        processes.append(server_a)
        proxy = SwitchingProxy("127.0.0.1", proxy_port, 0)
        proxy.set_backend(Backend(primary, port_a, epoch_a, 0, server_a))
        proxy.start()
        execute(proxy_port, "INSERT INTO fenced_rows(id, note) VALUES (1, 'leader-a')")
        try:
            witness.acquire(202)
            raise RuntimeError("double promotion acquired a live lease")
        except ReplicaError as exc:
            if "still active" not in str(exc):
                raise

        run([str(args.backup_exe), "archive-wal-live", str(primary), str(archive)])
        run([str(args.backup_exe), "standby-materialize", str(archive), str(standby)])
        expiry = witness.expiry()
        remaining = expiry + witness.clock_skew_ms + 5 - time.time_ns() // 1_000_000
        if remaining > 0:
            time.sleep(remaining / 1000.0)
        epoch_b, _ = witness.acquire(202)
        write_database_epoch(standby, epoch_b, 202)

        # The old server is deliberately left alive and reachable to model a
        # partitioned primary. Reads remain useful, but both direct and proxied
        # writes fail closed before the standby is promoted.
        expect_fenced(port_a, "INSERT INTO fenced_rows(id, note) VALUES (2, 'split-brain')")
        if int(execute(port_a, "SELECT COUNT(*) FROM fenced_rows")[0][0]) != 1:
            raise RuntimeError("fenced primary could not serve a read")

        run([str(args.backup_exe), "standby-promote", str(standby)])
        witness.renew(epoch_b, 202)
        server_b = start_fenced(args.server_exe, standby, port_b, witness, epoch_b, 202)
        processes.append(server_b)
        proxy.set_backend(Backend(standby, port_b, epoch_b, 0, server_b))
        execute(proxy_port, "INSERT INTO fenced_rows(id, note) VALUES (2, 'leader-b')")
        if int(execute(proxy_port, "SELECT COUNT(*) FROM fenced_rows")[0][0]) != 2:
            raise RuntimeError("stable endpoint did not switch to promoted primary")
        expect_fenced(port_a, "DELETE FROM fenced_rows WHERE id = 1")

        terminate(server_a)
        run([str(args.backup_exe), "archive-wal-live", str(standby), str(archive)])
        run([str(args.backup_exe), "standby-materialize", str(archive), str(rejoined)])
        rejoin = start_standby(args.server_exe, rejoined, rejoin_port)
        processes.append(rejoin)
        if int(execute(rejoin_port, "SELECT COUNT(*) FROM fenced_rows")[0][0]) != 2:
            raise RuntimeError("rejoined standby did not recover the new leader")
        try:
            execute(rejoin_port, "INSERT INTO fenced_rows(id, note) VALUES (3, 'standby-write')")
            raise RuntimeError("rejoined standby accepted a write")
        except minisql.OperationalError as exc:
            if exc.code != 9033:
                raise
        terminate(rejoin)
        terminate(server_b)
        run([str(args.check_exe), str(standby)])
        run([str(args.check_exe), str(rejoined)])

        report = {
            "status": "success", "initialEpoch": epoch_a, "promotedEpoch": epoch_b,
            "oldPrimaryDirectWriteError": 9038, "rejoinedStandbyWriteError": 9033,
            "stableEndpointPort": proxy_port, "rowsAfterFailover": 2,
            "totalSeconds": time.monotonic() - started,
        }
        print(json.dumps(report, indent=2, sort_keys=True))
        print("MiniSQL automatic fencing drill: SUCCESS")
        return 0
    finally:
        if proxy is not None:
            proxy.close()
        for process in reversed(processes):
            terminate(process)


if __name__ == "__main__":
    raise SystemExit(main())
