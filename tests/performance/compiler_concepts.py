#!/usr/bin/env python3
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.

"""Measure MiniLang-runtime optimization candidates on one retained database."""

from __future__ import annotations

import argparse
import json
import socket
import statistics
import subprocess
import sys
import threading
import time
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "clients" / "python"))
from minisql import connect  # noqa: E402

from capacity_regression import private_bytes  # noqa: E402

CREATE_NO_WINDOW = 0x08000000 if sys.platform == "win32" else 0


class BenchmarkFailure(RuntimeError):
    """Report an invalid benchmark environment or result."""


def free_port() -> int:
    """Return one currently unused loopback TCP port."""

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as listener:
        listener.bind(("127.0.0.1", 0))
        return int(listener.getsockname()[1])


def wait_ready(process: subprocess.Popen[bytes], port: int) -> None:
    """Wait until the isolated native server accepts MiniSQL connections."""

    deadline = time.monotonic() + 45
    while time.monotonic() < deadline:
        if process.poll() is not None:
            raise BenchmarkFailure(f"server stopped during startup: {process.returncode}")
        try:
            connection = connect(
                port=port, autocommit=True, connect_timeout=0.5, socket_timeout=5
            )
            connection.close()
            return
        except Exception:
            time.sleep(0.05)
    raise BenchmarkFailure("server readiness timed out")


def execute(port: int, sql: str) -> list[tuple[object, ...]]:
    """Execute one autocommit statement and fully consume its rows."""

    connection = connect(
        port=port, autocommit=True, connect_timeout=2, socket_timeout=120
    )
    try:
        cursor = connection.cursor()
        cursor.execute(sql)
        return cursor.fetchall() if cursor.description else []
    finally:
        connection.close()


def insert_chunks(port: int, table: str, rows: int, chunk_size: int = 100) -> None:
    """Populate one benchmark table through bounded multi-row statements."""

    for first in range(1, rows + 1, chunk_size):
        last = min(rows, first + chunk_size - 1)
        values = []
        for identifier in range(first, last + 1):
            group_key = identifier
            sort_key = rows - identifier
            values.append(
                f"({identifier}, {group_key}, {sort_key}, 'payload-{identifier:08d}')"
            )
        execute(
            port,
            f"INSERT INTO {table}(id, group_key, sort_key, payload) VALUES "
            + ",".join(values),
        )


def prepare_database(port: int, rows: int) -> None:
    """Create deterministic high-cardinality sort, group, and join inputs."""

    execute(
        port,
        "CREATE TABLE runtime_fact ("
        "id INTEGER PRIMARY KEY, group_key INTEGER NOT NULL, "
        "sort_key INTEGER NOT NULL, payload VARCHAR(40) NOT NULL)",
    )
    execute(
        port,
        "CREATE TABLE runtime_mirror ("
        "id INTEGER PRIMARY KEY, group_key INTEGER NOT NULL, "
        "sort_key INTEGER NOT NULL, payload VARCHAR(40) NOT NULL)",
    )
    insert_chunks(port, "runtime_fact", rows)
    insert_chunks(port, "runtime_mirror", rows)


def percentile(values: list[float], fraction: float) -> float:
    """Return a deterministic nearest-rank percentile."""

    ordered = sorted(values)
    rank = max(1, int(len(ordered) * fraction + 0.999999))
    return ordered[min(rank, len(ordered)) - 1]


def measure_query(
    port: int, name: str, sql: str, expected_rows: int, trials: int
) -> dict[str, object]:
    """Warm and repeatedly measure one fully materialized query."""

    warm = execute(port, sql)
    if len(warm) != expected_rows:
        raise BenchmarkFailure(
            f"{name} warm-up returned {len(warm)} rows, expected {expected_rows}"
        )
    durations: list[float] = []
    for _ in range(trials):
        started = time.perf_counter()
        result = execute(port, sql)
        elapsed_ms = (time.perf_counter() - started) * 1000.0
        if len(result) != expected_rows:
            raise BenchmarkFailure(
                f"{name} returned {len(result)} rows, expected {expected_rows}"
            )
        durations.append(elapsed_ms)
    return {
        "name": name,
        "rows": expected_rows,
        "trialsMs": [round(value, 3) for value in durations],
        "minimumMs": round(min(durations), 3),
        "medianMs": round(statistics.median(durations), 3),
        "p95Ms": round(percentile(durations, 0.95), 3),
    }


def main() -> int:
    """Run the retained-database benchmark and emit machine-readable results."""

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--server", type=Path, required=True)
    parser.add_argument("--database", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--rows", type=int, default=3000)
    parser.add_argument("--trials", type=int, default=5)
    parser.add_argument("--prepare", action="store_true")
    args = parser.parse_args()
    server = args.server.resolve()
    database = args.database.resolve()
    if not server.is_file() or not database.is_dir():
        raise BenchmarkFailure("server executable or database directory is missing")
    if args.rows < 100 or args.trials < 1:
        raise BenchmarkFailure("rows must be at least 100 and trials must be positive")

    port = free_port()
    process = subprocess.Popen(
        [str(server), "--serve", str(database), str(port), "8"],
        cwd=ROOT,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        creationflags=CREATE_NO_WINDOW,
    )
    stop_sampling = threading.Event()
    peak_private = 0

    def sample_memory() -> None:
        """Track peak server private bytes without perturbing query threads."""

        nonlocal peak_private
        while not stop_sampling.wait(0.01):
            peak_private = max(peak_private, private_bytes(process.pid))

    sampler = threading.Thread(target=sample_memory, daemon=True)
    sampler.start()
    try:
        wait_ready(process, port)
        startup_private = private_bytes(process.pid)
        if args.prepare:
            prepare_database(port, args.rows)
        count = int(execute(port, "SELECT COUNT(*) FROM runtime_fact")[0][0])
        if count != args.rows:
            raise BenchmarkFailure(
                f"retained database contains {count} rows, expected {args.rows}"
            )
        measurements = [
            measure_query(
                port,
                "sort",
                "SELECT id, sort_key FROM runtime_fact ORDER BY sort_key, id",
                args.rows,
                args.trials,
            ),
            measure_query(
                port,
                "group",
                "SELECT group_key, COUNT(*) FROM runtime_fact GROUP BY group_key",
                args.rows,
                args.trials,
            ),
            measure_query(
                port,
                "join",
                "SELECT f.id, m.payload FROM runtime_fact f INNER JOIN runtime_mirror m "
                "ON f.group_key = m.group_key",
                args.rows,
                args.trials,
            ),
        ]
        report = {
            "server": str(server),
            "database": str(database),
            "rows": args.rows,
            "trials": args.trials,
            "startupPrivateBytes": startup_private,
            "peakPrivateBytes": peak_private,
            "finalPrivateBytes": private_bytes(process.pid),
            "measurements": measurements,
        }
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print(json.dumps(report, indent=2))
        return 0
    finally:
        stop_sampling.set()
        sampler.join(timeout=2)
        if process.poll() is None:
            process.terminate()
        try:
            process.wait(timeout=10)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait(timeout=5)


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (BenchmarkFailure, OSError, subprocess.SubprocessError) as exc:
        print(f"MiniSQL compiler-concepts benchmark: FAIL ({exc})", file=sys.stderr)
        raise SystemExit(1)
