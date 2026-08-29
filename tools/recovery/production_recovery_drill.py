#!/usr/bin/env python3
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.

"""Perform a real base-backup restore and integrity-check recovery drill."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import time
from pathlib import Path


def run_checked(command: list[str]) -> dict[str, object]:
    """Run one recovery stage and return auditable timing and bounded output."""
    started = time.monotonic()
    completed = subprocess.run(command, capture_output=True, text=True, timeout=3600)
    result = {
        "command": command,
        "exitCode": completed.returncode,
        "durationSeconds": time.monotonic() - started,
        "stdout": completed.stdout[-8000:],
        "stderr": completed.stderr[-8000:],
    }
    if completed.returncode != 0:
        raise RuntimeError(json.dumps(result, indent=2))
    return result


def require_empty_target(path: Path, label: str) -> None:
    """Reject existing output paths so a drill never overwrites prior evidence."""
    if path.exists():
        raise ValueError(f"{label} already exists: {path}")


def main() -> int:
    """Create, restore, verify, and report a production recovery exercise."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("database", type=Path)
    parser.add_argument("backup", type=Path)
    parser.add_argument("restore", type=Path)
    parser.add_argument("--bin-dir", type=Path, default=Path("build/bin"))
    parser.add_argument("--report", type=Path, default=Path("build/recovery/recovery-drill.json"))
    args = parser.parse_args()
    require_empty_target(args.backup, "backup target")
    require_empty_target(args.restore, "restore target")
    args.backup.parent.mkdir(parents=True, exist_ok=True)
    args.restore.parent.mkdir(parents=True, exist_ok=True)
    backup_tool = args.bin_dir / ("minisql-backup.exe" if os.name == "nt" else "minisql-backup")
    check_tool = args.bin_dir / ("minisql-check.exe" if os.name == "nt" else "minisql-check")
    stages = [
        run_checked([str(backup_tool), "backup", str(args.database), str(args.backup)]),
        run_checked([str(backup_tool), "restore", str(args.backup), str(args.restore)]),
        run_checked([str(check_tool), str(args.restore)]),
    ]
    report = {"success": True, "database": str(args.database), "backup": str(args.backup), "restore": str(args.restore), "stages": stages}
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("MiniSQL production recovery drill: SUCCESS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
