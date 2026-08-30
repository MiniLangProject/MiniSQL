#!/usr/bin/env python3
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.

"""Validate cancellation, deadlines, result quotas, metrics and slow-query state."""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import socket
import subprocess
import sys
import time
from urllib.request import urlopen

PROJECT_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PROJECT_ROOT / "clients" / "python"))
import minisql  # noqa: E402


def free_port() -> int:
    """Reserves and returns one currently unused loopback TCP port."""
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", 0))
        return int(listener.getsockname()[1])


def wait_ready(process: subprocess.Popen[bytes], port: int) -> None:
    """Waits for one server without hiding an early child failure."""
    deadline = time.monotonic() + 60
    while time.monotonic() < deadline:
        if process.poll() is not None:
            raise RuntimeError(f"server exited before readiness: {process.returncode}")
        try:
            connection = minisql.connect(port=port, autocommit=True, connect_timeout=0.25, socket_timeout=2)
            connection.close()
            return
        except Exception:
            time.sleep(0.05)
    raise RuntimeError("server readiness timeout")


def execute_failure(port: int, sql: str) -> int | None:
    """Executes one statement and returns its stable server error code."""
    connection = minisql.connect(port=port, autocommit=True, socket_timeout=20)
    try:
        cursor = connection.cursor()
        cursor.execute(sql)
        if cursor.description:
            cursor.fetchall()
        return None
    except minisql.DatabaseError as error:
        return error.code
    finally:
        connection.close()


def execute_connection_failure(connection: object, sql: str) -> int | None:
    """Executes on a retained connection so another thread can cancel it."""
    try:
        cursor = connection.cursor()
        cursor.execute(sql)
        if cursor.description:
            cursor.fetchall()
        return None
    except minisql.DatabaseError as error:
        return error.code


def status(connection: object) -> dict[str, int]:
    """Returns numeric SHOW STATUS rows as a dictionary."""
    cursor = connection.cursor()
    cursor.execute("SHOW STATUS")
    return {str(name): int(value) for name, value in cursor.fetchall()}


def main() -> int:
    """Runs all production controls against an existing HA-load database."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", type=Path, required=True)
    parser.add_argument("--work-root", type=Path, required=True)
    parser.add_argument("--server-exe", type=Path, default=PROJECT_ROOT / "build" / "bin" / "minisqld.exe")
    args = parser.parse_args()
    args.work_root.mkdir(parents=True, exist_ok=True)
    server_port, exporter_port = free_port(), free_port()
    config = json.loads((PROJECT_ROOT / "config" / "minisql.example.json").read_text(encoding="utf-8"))
    config["paths"] = {
        "dataRoot": str(args.work_root / "data"),
        "temporaryRoot": str(args.work_root / "tmp"),
        "logDirectory": str(args.work_root / "logs"),
    }
    config["server"]["port"] = server_port
    config["server"]["maxResultBytes"] = 1_048_576
    config["runtime"]["queryTimeoutMs"] = 5_000
    config["runtime"]["slowQueryMs"] = 1
    config["logging"]["stdoutEnabled"] = False
    config_path = args.work_root / "production-controls.json"
    config_path.write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")
    server = subprocess.Popen(
        [str(args.server_exe), "--serve-config", str(args.database.resolve()), str(config_path.resolve())],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    exporter: subprocess.Popen[bytes] | None = None
    admin = None
    try:
        wait_ready(server, server_port)
        admin = minisql.connect(port=server_port, autocommit=True, socket_timeout=10)
        if not admin.ping():
            raise RuntimeError("Python connector PING/PONG failed before control tests")
        expensive = "SELECT SUM(a.id + b.id + c.id) FROM ha_load a, ha_load b, ha_load c"
        with minisql.connect(port=server_port, autocommit=True, socket_timeout=20) as query_connection:
            with ThreadPoolExecutor(max_workers=1) as pool:
                future = pool.submit(execute_connection_failure, query_connection, expensive)
                target = None
                deadline = time.monotonic() + 5
                while time.monotonic() < deadline and target is None:
                    cursor = admin.cursor()
                    cursor.execute("SHOW PROCESSLIST")
                    for row in cursor.fetchall():
                        if str(row[4]) in {"EXECUTING", "CANCELLING"} and "HA_LOAD" in str(row[6]).upper():
                            target = int(row[0])
                            break
                    if target is None:
                        time.sleep(0.01)
                if target is None:
                    raise RuntimeError("expensive statement was not visible in SHOW PROCESSLIST")
                query_connection.cancel()
                if future.result(timeout=10) != 9035:
                    raise RuntimeError("cancelled statement did not report error 9035")

        result_heavy = "SELECT payload, payload, payload FROM ha_load"
        if execute_failure(server_port, result_heavy) != 9037:
            raise RuntimeError("aggregate result-byte ceiling did not report error 9037")

        values = status(admin)
        required = {"cancelled_statements": 1, "resource_rejected_statements": 1, "slow_query_count": 1}
        for name, minimum in required.items():
            if values.get(name, 0) < minimum:
                raise RuntimeError(f"SHOW STATUS {name} did not reach {minimum}: {values.get(name)}")
        log_text = (args.work_root / "logs" / "minisql.log").read_text(encoding="utf-8")
        if "[WARNING]" not in log_text or "minisql.server.session.slowQuery" not in log_text:
            raise RuntimeError("slow-query warning was not persisted")
        if expensive in log_text:
            raise RuntimeError("ordinary slow-query log leaked complete SQL text")

        # A second short-lived server gives the expensive cross product a
        # deterministic deadline while retaining enough budget for SHOW STATUS.
        admin.cursor().execute("SHUTDOWN")
        admin.close()
        admin = None
        server.wait(timeout=15)
        config["runtime"]["queryTimeoutMs"] = 50
        config_path.write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")
        server = subprocess.Popen(
            [str(args.server_exe), "--serve-config", str(args.database.resolve()), str(config_path.resolve())],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        wait_ready(server, server_port)
        if execute_failure(server_port, expensive) != 9036:
            raise RuntimeError("short statement deadline did not report error 9036")
        admin = minisql.connect(port=server_port, autocommit=True, socket_timeout=10)
        timeout_values = status(admin)
        if timeout_values.get("timed_out_statements", 0) < 1:
            raise RuntimeError("SHOW STATUS did not count the timed-out statement")
        required["timed_out_statements"] = 1

        exporter = subprocess.Popen(
            [sys.executable, str(PROJECT_ROOT / "tools" / "monitoring" / "minisql_exporter.py"), "--database-port", str(server_port), "--listen-port", str(exporter_port)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        metrics = ""
        deadline = time.monotonic() + 10
        while time.monotonic() < deadline:
            try:
                metrics = urlopen(f"http://127.0.0.1:{exporter_port}/metrics", timeout=2).read().decode("utf-8")
                break
            except Exception:
                time.sleep(0.05)
        for name in ("minisql_up 1", "minisql_cancelled_statements", "minisql_timed_out_statements", "minisql_result_bytes_returned"):
            if name not in metrics:
                raise RuntimeError(f"exporter metric is missing: {name}")
        print(json.dumps({"status": "success", "serverPort": server_port, "exporterPort": exporter_port, **required}, sort_keys=True))
        print("MiniSQL live production controls: SUCCESS")
        return 0
    finally:
        if exporter is not None and exporter.poll() is None:
            exporter.terminate()
            exporter.wait(timeout=5)
        if admin is not None:
            try:
                admin.cursor().execute("SHUTDOWN")
                admin.close()
            except Exception:
                pass
        if server.poll() is None:
            try:
                server.wait(timeout=15)
            except subprocess.TimeoutExpired:
                server.terminate()
                server.wait(timeout=5)


if __name__ == "__main__":
    raise SystemExit(main())
