#!/usr/bin/env python3
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0

"""Measure trusted-loopback MiniSQL throughput across concurrent connections."""

from __future__ import annotations

import argparse
import concurrent.futures
import json
import socket
import statistics
import subprocess
import sys
import threading
import time
from pathlib import Path

# This runner is launched as a subprocess by platform_compare.py. Disable local
# bytecode independently so direct and delegated benchmark runs both preserve
# the repository's source-package hygiene contract.
sys.dont_write_bytecode = True

from capacity_regression import private_bytes


ROOT = Path(__file__).resolve().parents[2]
CREATE_NO_WINDOW = 0x08000000 if sys.platform == "win32" else 0


class BenchmarkFailure(RuntimeError):
    """Report an invalid benchmark environment or failed client operation."""


def free_port() -> int:
    """Reserve and release one loopback port for the immediately following server."""

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as listener:
        listener.bind(("127.0.0.1", 0))
        return int(listener.getsockname()[1])


def percentile(values: list[float], percentage: float) -> float:
    """Return a deterministic nearest-rank percentile from milliseconds."""

    ordered = sorted(values)
    rank = max(1, int(len(ordered) * percentage + 0.999999))
    return ordered[min(rank, len(ordered)) - 1]


def run_checked(command: list[str], timeout: float) -> tuple[float, str]:
    """Run one client command and return elapsed milliseconds plus stdout."""

    started = time.perf_counter()
    result = subprocess.run(
        command,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=timeout,
        creationflags=CREATE_NO_WINDOW,
    )
    elapsed_ms = (time.perf_counter() - started) * 1000.0
    if result.returncode != 0 or result.stderr.strip():
        raise BenchmarkFailure(
            f"client failed rc={result.returncode} stdout={result.stdout!r} "
            f"stderr={result.stderr!r}"
        )
    return elapsed_ms, result.stdout


def one_shot_worker(client: Path, port: int, query: str, count: int) -> list[float]:
    """Execute count independent process/connect/query/close operations."""

    durations: list[float] = []
    for _ in range(count):
        elapsed, output = run_checked(
            [str(client), "--query", str(port), query], timeout=60.0
        )
        if "(1 rows)" not in output:
            raise BenchmarkFailure(f"unexpected one-shot result: {output!r}")
        durations.append(elapsed)
    return durations


def measure_one_shot(
    client: Path, port: int, query: str, concurrency: int, requests_per_client: int
) -> dict[str, object]:
    """Measure end-to-end one-shot requests with a fixed client-worker count."""

    started = time.perf_counter()
    durations: list[float] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as pool:
        futures = [
            pool.submit(one_shot_worker, client, port, query, requests_per_client)
            for _ in range(concurrency)
        ]
        for future in futures:
            durations.extend(future.result())
    wall_seconds = time.perf_counter() - started
    return {
        "concurrency": concurrency,
        "requests": len(durations),
        "wallSeconds": round(wall_seconds, 6),
        "requestsPerSecond": round(len(durations) / wall_seconds, 3),
        "latencyMedianMs": round(statistics.median(durations), 3),
        "latencyP95Ms": round(percentile(durations, 0.95), 3),
        "latencyMaxMs": round(max(durations), 3),
    }


def measure_persistent_scripts(
    client: Path, port: int, script: Path, concurrency: int, statements: int
) -> dict[str, object]:
    """Measure simultaneous persistent sessions executing a fixed SQL script."""

    command = [str(client), "--script", str(port), str(script)]
    started = time.perf_counter()
    durations: list[float] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as pool:
        futures = [pool.submit(run_checked, command, 120.0) for _ in range(concurrency)]
        for future in futures:
            elapsed, output = future.result()
            if f"statements={statements}" not in output:
                raise BenchmarkFailure(f"unexpected script result: {output[-500:]!r}")
            durations.append(elapsed)
    wall_seconds = time.perf_counter() - started
    total_statements = concurrency * statements
    return {
        "concurrency": concurrency,
        "statements": total_statements,
        "wallSeconds": round(wall_seconds, 6),
        "statementsPerSecond": round(total_statements / wall_seconds, 3),
        "sessionMedianMs": round(statistics.median(durations), 3),
        "sessionP95Ms": round(percentile(durations, 0.95), 3),
        "sessionMaxMs": round(max(durations), 3),
    }


def main() -> int:
    """Start an isolated server, execute both matrices, and write raw JSON."""

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--server", type=Path, required=True)
    parser.add_argument("--client", type=Path, required=True)
    parser.add_argument("--database", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--concurrency", default="1,2,4,8")
    parser.add_argument("--one-shot-per-client", type=int, default=20)
    parser.add_argument("--statements-per-session", type=int, default=100)
    parser.add_argument(
        "--query", default="SELECT COUNT(*) AS c FROM capacity_data;"
    )
    parser.add_argument("--buffer-pool-bytes", type=int)
    args = parser.parse_args()

    server = args.server.resolve()
    client = args.client.resolve()
    database = args.database.resolve()
    if not server.is_file() or not client.is_file() or not database.is_dir():
        raise BenchmarkFailure("server, client, or database path is missing")
    try:
        levels = [int(item) for item in args.concurrency.split(",")]
    except ValueError as exc:
        raise BenchmarkFailure("concurrency must be a comma-separated integer list") from exc
    if not levels or min(levels) < 1 or max(levels) > 64:
        raise BenchmarkFailure("concurrency must contain values from 1 through 64")
    if args.one_shot_per_client < 0 or args.statements_per_session < 1:
        raise BenchmarkFailure("request count must be non-negative and statement count positive")
    if args.buffer_pool_bytes is not None and args.buffer_pool_bytes < 4096:
        raise BenchmarkFailure("buffer-pool-bytes must be at least 4096")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    script = args.output.with_suffix(".sql")
    query = args.query.strip()
    if not query:
        raise BenchmarkFailure("query must not be empty")
    script.write_text(
        (query + "\n") * args.statements_per_session, encoding="utf-8"
    )
    port = free_port()
    server_command = [
        str(server), "--serve", str(database), str(port), str(max(levels) + 2)
    ]
    if args.buffer_pool_bytes is not None:
        template = ROOT / "config" / "minisql.example.json"
        config = json.loads(template.read_text(encoding="utf-8"))
        config["server"]["port"] = port
        config["server"]["maxConnections"] = max(levels) + 2
        config["runtime"]["bufferPoolBytes"] = args.buffer_pool_bytes
        # Configuration validation requires one ordinary destination. The
        # benchmark process redirects stdout to DEVNULL below.
        config["logging"]["stdoutEnabled"] = True
        config["logging"]["fileEnabled"] = False
        config["binlog"]["enabled"] = False
        derived_config = args.output.with_suffix(".server.json")
        derived_config.write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")
        server_command = [
            str(server), "--serve-config", str(database), str(derived_config)
        ]
    server_process = subprocess.Popen(
        server_command,
        cwd=ROOT,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        creationflags=CREATE_NO_WINDOW,
    )
    stop_sampling = threading.Event()
    server_peak_private = 0

    def sample_server() -> None:
        """Track server private bytes while clients are active."""

        nonlocal server_peak_private
        while not stop_sampling.wait(0.01):
            server_peak_private = max(server_peak_private, private_bytes(server_process.pid))

    sampler = threading.Thread(target=sample_server, daemon=True)
    sampler.start()
    try:
        ready = False
        for _ in range(100):
            if server_process.poll() is not None:
                raise BenchmarkFailure("server exited during startup")
            try:
                _, output = run_checked([str(client), "--ping", str(port)], timeout=5.0)
                if "PONG" in output:
                    ready = True
                    break
            except (BenchmarkFailure, subprocess.TimeoutExpired):
                time.sleep(0.05)
        if not ready:
            raise BenchmarkFailure("server did not become ready")

        # Warm compiler/runtime, database metadata, and filesystem caches before
        # recording steady-state loopback results.
        for _ in range(3):
            run_checked([str(client), "--query", str(port), query], timeout=30.0)

        one_shot = []
        if args.one_shot_per_client > 0:
            one_shot = [
                measure_one_shot(
                    client, port, query, level, args.one_shot_per_client
                )
                for level in levels
            ]
        persistent = [
            measure_persistent_scripts(
                client, port, script, level, args.statements_per_session
            )
            for level in levels
        ]
        report = {
            "port": port,
            "database": str(database),
            "query": query,
            "oneShotPerClient": args.one_shot_per_client,
            "statementsPerSession": args.statements_per_session,
            "bufferPoolBytes": args.buffer_pool_bytes,
            "oneShot": one_shot,
            "persistent": persistent,
            "serverPeakPrivateBytes": server_peak_private,
        }
        args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print(json.dumps(report, indent=2))
        return 0
    finally:
        stop_sampling.set()
        sampler.join(timeout=2.0)
        if server_process.poll() is None:
            server_process.terminate()
        try:
            server_process.wait(timeout=10.0)
        except subprocess.TimeoutExpired:
            server_process.kill()
            server_process.wait(timeout=5.0)


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (BenchmarkFailure, subprocess.TimeoutExpired) as exc:
        print(f"MiniSQL network baseline: FAIL ({exc})", file=sys.stderr)
        raise SystemExit(1)
