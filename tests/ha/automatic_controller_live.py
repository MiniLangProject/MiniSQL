#!/usr/bin/env python3
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.

"""Kill a managed leader and verify automatic promotion through one endpoint."""

from __future__ import annotations

import argparse
import json
import os
import re
import signal
import socket
import subprocess
import sys
import time
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PROJECT_ROOT / "clients" / "python"))
import minisql  # noqa: E402

CREATED_PATH = re.compile(r"MiniSQL database created:\s*(.+)")


def run(command: list[str], timeout: float = 120.0) -> subprocess.CompletedProcess[str]:
    """Runs a required command and raises with preserved diagnostics."""
    result = subprocess.run(command, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout)
    if result.returncode != 0:
        raise RuntimeError(f"command failed: {' '.join(command)}\n{result.stdout}\n{result.stderr}")
    return result


def free_port() -> int:
    """Returns one currently unused loopback port."""
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", 0))
        return int(listener.getsockname()[1])


def wait_server(process: subprocess.Popen[bytes], port: int, timeout: float = 45.0) -> None:
    """Waits until an ordinary setup server answers MiniSQL requests."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if process.poll() is not None:
            raise RuntimeError(f"setup server stopped with {process.returncode}")
        try:
            connection = minisql.connect(port=port, autocommit=True, connect_timeout=0.5, socket_timeout=2)
            connection.close()
            return
        except Exception:
            time.sleep(0.05)
    raise RuntimeError("setup server readiness timed out")


def execute(port: int, sql: str) -> list[tuple[object, ...]]:
    """Executes one autocommit statement through the requested endpoint."""
    connection = minisql.connect(port=port, autocommit=True, connect_timeout=1, socket_timeout=15)
    try:
        cursor = connection.cursor()
        cursor.execute(sql)
        return cursor.fetchall() if cursor.description else []
    finally:
        connection.close()


def read_status(path: Path) -> dict[str, object] | None:
    """Returns a complete atomically published controller status document."""
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


def wait_status(path: Path, process: subprocess.Popen[bytes], predicate: object, timeout: float = 60.0, log_path: Path | None = None) -> dict[str, object]:
    """Waits for a status predicate while detecting early controller exit."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if process.poll() is not None:
            diagnostic = ""
            if log_path is not None and log_path.exists():
                diagnostic = "\n" + log_path.read_text(encoding="utf-8", errors="replace")
            raise RuntimeError(f"HA controller stopped with {process.returncode}{diagnostic}")
        status = read_status(path)
        if status is not None and predicate(status):  # type: ignore[operator]
            return status
        time.sleep(0.05)
    raise RuntimeError("controller status transition timed out")


def kill_pid(pid: int) -> None:
    """Forcibly terminates the managed leader without stopping its controller."""
    if os.name == "nt":
        run(["taskkill", "/PID", str(pid), "/F"], timeout=15)
    else:
        os.kill(pid, signal.SIGKILL)


def terminate(process: subprocess.Popen[bytes] | None) -> None:
    """Stops a child process with bounded escalation."""
    if process is None or process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=10)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=5)


def main() -> int:
    """Runs one deterministic controller-owned leader crash and failover."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--work-root", type=Path, required=True)
    parser.add_argument("--server-exe", type=Path, default=PROJECT_ROOT / "build" / "bin" / "minisqld.exe")
    parser.add_argument("--backup-exe", type=Path, default=PROJECT_ROOT / "build" / "bin" / "minisql-backup.exe")
    args = parser.parse_args()
    if args.work_root.exists() and any(args.work_root.iterdir()):
        parser.error("--work-root must be absent or empty")
    args.work_root.mkdir(parents=True, exist_ok=True)
    data = args.work_root / "data"
    data.mkdir()
    status_path = args.work_root / "ha-status.json"
    setup_port, proxy_port, backend_a, backend_b = free_port(), free_port(), free_port(), free_port()
    setup: subprocess.Popen[bytes] | None = None
    controller: subprocess.Popen[bytes] | None = None
    controller_log = None
    controller_log_path = args.work_root / "controller.log"
    started = time.monotonic()
    try:
        initialized = run([str(args.server_exe), "--init", str(data), "automatic", "4096"])
        match = CREATED_PATH.search(initialized.stdout)
        if match is None:
            raise RuntimeError("database path was not reported")
        database = Path(match.group(1).strip()).resolve()
        setup = subprocess.Popen([str(args.server_exe), "--serve", str(database), str(setup_port), "8"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        wait_server(setup, setup_port)
        execute(setup_port, "CREATE TABLE controller_rows (id INTEGER PRIMARY KEY, note TEXT NOT NULL)")
        execute(setup_port, "INSERT INTO controller_rows(id, note) VALUES (1, 'before-failover')")
        execute(setup_port, "SHUTDOWN")
        setup.wait(timeout=15)

        controller_log = controller_log_path.open("wb")
        controller = subprocess.Popen([
            sys.executable, "-B", str(PROJECT_ROOT / "tools" / "replication" / "minisql_ha_controller.py"), "run",
            "--primary-db", str(database), "--archive", str(args.work_root / "archive"),
            "--slot-root", str(args.work_root / "slots"), "--witness-dir", str(args.work_root / "witness"),
            "--server-exe", str(args.server_exe), "--backup-exe", str(args.backup_exe),
            "--proxy-port", str(proxy_port), "--backend-port-a", str(backend_a), "--backend-port-b", str(backend_b),
            "--lease-ms", "1500", "--clock-skew-ms", "100", "--replication-ms", "300",
            "--status-file", str(status_path),
        ], stdout=controller_log, stderr=subprocess.STDOUT)
        initial = wait_status(status_path, controller, lambda value: value.get("status") == "serving" and value.get("standbyDatabase") and value.get("leaderPid"), log_path=controller_log_path)
        if int(execute(proxy_port, "SELECT COUNT(*) FROM controller_rows")[0][0]) != 1:
            raise RuntimeError("stable endpoint did not expose initial leader")
        old_pid = int(initial["leaderPid"])
        kill_started = time.monotonic()
        kill_pid(old_pid)
        promoted = wait_status(status_path, controller, lambda value: int(value.get("failovers", 0)) >= 1 and value.get("status") == "serving" and value.get("leaderPid") != old_pid, log_path=controller_log_path)
        recovery_seconds = time.monotonic() - kill_started
        execute(proxy_port, "INSERT INTO controller_rows(id, note) VALUES (2, 'after-failover')")
        rows = int(execute(proxy_port, "SELECT COUNT(*) FROM controller_rows")[0][0])
        if rows != 2:
            raise RuntimeError("promoted leader did not retain and extend data")
        report = {
            "status": "success", "oldLeaderPid": old_pid, "newLeaderPid": int(promoted["leaderPid"]),
            "oldEpoch": int(initial["epoch"]), "newEpoch": int(promoted["epoch"]),
            "rowsAfterFailover": rows, "recoveryTimeSeconds": recovery_seconds,
            "totalSeconds": time.monotonic() - started,
        }
        print(json.dumps(report, indent=2, sort_keys=True))
        print("MiniSQL automatic HA controller live test: SUCCESS")
        return 0
    finally:
        final_status = read_status(status_path)
        final_leader_pid = int(final_status["leaderPid"]) if final_status and final_status.get("leaderPid") else None
        terminate(controller)
        if final_leader_pid is not None:
            try:
                kill_pid(final_leader_pid)
            except (OSError, RuntimeError):
                pass
        if controller_log is not None:
            controller_log.close()
        terminate(setup)


if __name__ == "__main__":
    raise SystemExit(main())
