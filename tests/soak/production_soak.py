#!/usr/bin/env python3
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.

"""Run repeated client waves against one MiniSQL server and detect resource drift."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import time
from pathlib import Path


def read_process_sample(pid: int) -> dict[str, int]:
    """Return portable best-effort RSS, handle/fd, and thread counters for a process."""
    if os.name == "nt":
        command = [
            "powershell",
            "-NoProfile",
            "-Command",
            f"$p=Get-Process -Id {pid}; @{{rss=[int64]$p.WorkingSet64;handles=$p.HandleCount;threads=$p.Threads.Count}}|ConvertTo-Json -Compress",
        ]
        completed = subprocess.run(command, check=True, capture_output=True, text=True, timeout=15)
        return {key: int(value) for key, value in json.loads(completed.stdout).items()}
    status = Path(f"/proc/{pid}/status").read_text(encoding="utf-8")
    fields = dict(line.split(":", 1) for line in status.splitlines() if ":" in line)
    rss_kib = int(fields.get("VmRSS", "0 kB").split()[0])
    return {
        "rss": rss_kib * 1024,
        "handles": len(list(Path(f"/proc/{pid}/fd").iterdir())),
        "threads": int(fields.get("Threads", "0").strip()),
    }


def median(values: list[int]) -> int:
    """Return the deterministic integer median of a non-empty sample."""
    ordered = sorted(values)
    return ordered[len(ordered) // 2]


def resource_drift(samples: list[dict[str, int]], key: str) -> int:
    """Compare early and late sample medians so warm-up spikes do not look like leaks."""
    window = max(1, len(samples) // 4)
    return median([sample[key] for sample in samples[-window:]]) - median(
        [sample[key] for sample in samples[:window]]
    )


def percentile(values: list[float], fraction: float) -> float:
    """Return a nearest-rank percentile without an external statistics package."""
    ordered = sorted(values)
    index = min(len(ordered) - 1, max(0, int((len(ordered) - 1) * fraction)))
    return ordered[index]


def run_wave(command: list[str], timeout: int) -> dict[str, object]:
    """Run one client wave and preserve its duration and output for the report."""
    started = time.monotonic()
    try:
        completed = subprocess.run(command, capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired as error:
        return {
            "exitCode": -1,
            "durationSeconds": time.monotonic() - started,
            "stdout": (error.stdout or "")[-4000:],
            "stderr": ((error.stderr or "") + f"\nwave timed out after {timeout}s")[-4000:],
        }
    return {
        "exitCode": completed.returncode,
        "durationSeconds": time.monotonic() - started,
        "stdout": completed.stdout[-4000:],
        "stderr": completed.stderr[-4000:],
    }


def main() -> int:
    """Execute the configured soak duration and fail on workload errors or resource drift."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pid", type=int, required=True, help="PID of the already running minisqld process")
    parser.add_argument("--duration-minutes", type=float, default=1440.0)
    parser.add_argument("--warmup-waves", type=int, default=4)
    parser.add_argument("--wave-timeout-seconds", type=int, default=300)
    parser.add_argument("--max-rss-growth-mib", type=int, default=256)
    parser.add_argument("--max-handle-growth", type=int, default=32)
    parser.add_argument("--max-thread-growth", type=int, default=4)
    parser.add_argument("--minimum-waves", type=int, default=1)
    parser.add_argument("--max-wave-p95-seconds", type=float, default=0.0, help="zero disables the latency guard")
    parser.add_argument("--wave-interval-seconds", type=float, default=0.0)
    parser.add_argument("--output", type=Path, default=Path("build/soak/production-soak.json"))
    parser.add_argument("command", nargs=argparse.REMAINDER, help="client workload after --")
    args = parser.parse_args()
    command = args.command[1:] if args.command and args.command[0] == "--" else args.command
    if not command:
        parser.error("a client workload command is required after --")
    if args.duration_minutes <= 0 or args.minimum_waves < 1 or args.wave_interval_seconds < 0:
        parser.error("duration/minimum waves must be positive and wave interval non-negative")

    for _ in range(args.warmup_waves):
        warmup = run_wave(command, args.wave_timeout_seconds)
        if warmup["exitCode"] != 0:
            raise RuntimeError(f"warm-up wave failed: {warmup}")

    started = time.monotonic()
    deadline = started + args.duration_minutes * 60.0
    samples: list[dict[str, int]] = []
    waves: list[dict[str, object]] = []
    sampling_error = ""
    while time.monotonic() < deadline or not waves:
        waves.append(run_wave(command, args.wave_timeout_seconds))
        try:
            sample = read_process_sample(args.pid)
            sample["elapsedMilliseconds"] = int((time.monotonic() - started) * 1000)
            samples.append(sample)
        except (OSError, subprocess.SubprocessError, ValueError, json.JSONDecodeError) as error:
            sampling_error = f"server process sample failed: {error}"
            break
        if waves[-1]["exitCode"] != 0:
            break
        if args.wave_interval_seconds > 0:
            time.sleep(args.wave_interval_seconds)

    drift = {key: resource_drift(samples, key) for key in ("rss", "handles", "threads")} if samples else {}
    limits = {
        "rss": args.max_rss_growth_mib * 1024 * 1024,
        "handles": args.max_handle_growth,
        "threads": args.max_thread_growth,
    }
    durations = [float(wave["durationSeconds"]) for wave in waves]
    p95 = percentile(durations, 0.95)
    latency_ok = args.max_wave_p95_seconds <= 0 or p95 <= args.max_wave_p95_seconds
    success = (
        not sampling_error
        and len(waves) >= args.minimum_waves
        and all(wave["exitCode"] == 0 for wave in waves)
        and all(drift[key] <= limits[key] for key in limits)
        and latency_ok
    )
    report = {
        "success": success,
        "pid": args.pid,
        "waves": waves,
        "samples": samples,
        "drift": drift,
        "limits": limits,
        "samplingError": sampling_error,
        "durationSeconds": time.monotonic() - started,
        "waveLatencySeconds": {"minimum": min(durations), "p50": percentile(durations, 0.50), "p95": p95, "maximum": max(durations)},
        "peakResources": {key: max(sample[key] for sample in samples) for key in ("rss", "handles", "threads")} if samples else {},
        "minimumWaves": args.minimum_waves,
        "maximumWaveP95Seconds": args.max_wave_p95_seconds,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"MiniSQL production soak: {'SUCCESS' if success else 'FAIL'} waves={len(waves)} drift={drift}")
    return 0 if success else 1


if __name__ == "__main__":
    raise SystemExit(main())
