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
"""Measure indexed point-read throughput across concurrent MiniSQL sessions."""

from __future__ import annotations

import argparse
import json
import statistics
import threading
import time
from dataclasses import asdict, dataclass

import minisql


@dataclass(frozen=True)
class LevelResult:
    """Median and individual throughput trials for one client count."""

    clients: int
    operations_per_client: int
    median_requests_per_second: float
    trial_requests_per_second: list[float]


def run_trial(dsn: str, clients: int, operations: int) -> float:
    """Run one aligned trial using one persistent connection per worker."""

    start = threading.Barrier(clients + 1)
    finish = threading.Barrier(clients + 1)
    failures: list[BaseException] = []
    failure_guard = threading.Lock()

    def worker(worker_index: int) -> None:
        """Warm one session, execute its aligned reads, and report failures."""

        try:
            connection = minisql.connect(dsn, autocommit=True)
            cursor = connection.cursor()
            for warmup in range(16):
                key = 1 + ((worker_index * 257 + warmup) % 10_000)
                cursor.execute("SELECT metric FROM connector_seed WHERE id = ?", (key,))
                if int(cursor.fetchone()[0]) != key % 97:
                    raise RuntimeError("indexed-read warmup mismatch")
            start.wait()
            for operation in range(operations):
                key = 1 + ((worker_index * operations + operation) % 10_000)
                cursor.execute("SELECT metric FROM connector_seed WHERE id = ?", (key,))
                if int(cursor.fetchone()[0]) != key % 97:
                    raise RuntimeError("indexed-read result mismatch")
            finish.wait()
            cursor.close()
            connection.close()
        except BaseException as exception:  # Preserve worker diagnostics.
            with failure_guard:
                failures.append(exception)
            try:
                start.abort()
            except threading.BrokenBarrierError:
                pass
            try:
                finish.abort()
            except threading.BrokenBarrierError:
                pass

    workers = [
        threading.Thread(target=worker, args=(index,), daemon=True)
        for index in range(clients)
    ]
    for current in workers:
        current.start()
    try:
        start.wait(timeout=30)
        started = time.perf_counter()
        finish.wait(timeout=120)
        elapsed = time.perf_counter() - started
    except threading.BrokenBarrierError as exception:
        for current in workers:
            current.join(timeout=1)
        if failures:
            raise RuntimeError("concurrent indexed-read worker failed") from failures[0]
        raise RuntimeError("concurrent indexed-read barrier failed") from exception
    for current in workers:
        current.join(timeout=10)
        if current.is_alive():
            raise RuntimeError("concurrent indexed-read worker did not stop")
    if failures:
        raise RuntimeError("concurrent indexed-read worker failed") from failures[0]
    return clients * operations / elapsed


def main() -> int:
    """Parse arguments, run all concurrency levels, and emit stable JSON."""

    parser = argparse.ArgumentParser()
    parser.add_argument("dsn")
    parser.add_argument("--clients", default="1,2,4,8,16,32")
    parser.add_argument("--operations", type=int, default=250)
    parser.add_argument("--trials", type=int, default=3)
    parser.add_argument("--output")
    arguments = parser.parse_args()
    levels = [int(value) for value in arguments.clients.split(",")]
    if any(value < 1 or value > 64 for value in levels):
        raise ValueError("client counts must be between 1 and 64")
    if arguments.operations < 1 or arguments.trials < 1:
        raise ValueError("operations and trials must be positive")

    results: list[LevelResult] = []
    for clients in levels:
        trials = [
            run_trial(arguments.dsn, clients, arguments.operations)
            for _ in range(arguments.trials)
        ]
        result = LevelResult(
            clients,
            arguments.operations,
            statistics.median(trials),
            trials,
        )
        results.append(result)
        print(
            f"clients={clients} medianRequestsPerSecond="
            f"{result.median_requests_per_second:.3f} trials={trials}",
            flush=True,
        )

    document = {
        "workload": "prepared indexed point read",
        "levels": [asdict(result) for result in results],
    }
    encoded = json.dumps(document, indent=2) + "\n"
    if arguments.output:
        with open(arguments.output, "w", encoding="utf-8", newline="\n") as stream:
            stream.write(encoded)
    else:
        print(encoded, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
