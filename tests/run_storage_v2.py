# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see the LICENSE file.

"""Internal native storage-v2 gate, exposed through test.ps1 -StorageV2."""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
CORE = {
    "storage_v2_metadata": [],
    "storage_v2_rows": [],
    "storage_v2_table": ["{data}/table.tbl"],
    "storage_v2_overflow": [],
    "storage_v2_indexes": ["{data}"],
}
REGRESSIONS = {
    "m8_config": ["{repo}/config/minisql.example.json", "{data}/invalid.json"],
    "m8_catalog": ["{repo}/config/minisql.example.json", "{data}"],
    "m9_row_codec": [],
    "m9_heap_file": ["{data}/heap.tbl"],
    "m10_overflow": ["{data}/overflow.tbl"],
    "m11_btree": ["{data}/index.idx"],
    "m6_wal": ["{data}/wal.log"],
    "m6_transaction": ["{data}/wal.log"],
    "m7_checkpoint": ["{data}/checkpoint.meta"],
    "m7_recovery": ["{data}/data.tbl", "{data}/wal.log"],
    "m15_sql_engine": ["{data}"],
    "m23_index_integration": ["{data}"],
    "m24_schema_evolution": ["{data}"],
    "m25_maintenance": ["{data}"],
    "m26_offline_migration": ["{data}"],
    "m50_release_contract": ["{data}"],
    "m79_security_at_rest": ["{data}"],
}


def execute(command: list[str], log: Path, timeout: int) -> subprocess.CompletedProcess[str]:
    """Runs a bounded process and preserves its complete diagnostic output."""
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True,
                            encoding="utf-8", errors="replace", timeout=timeout)
    log.write_text(json.dumps(command) + "\n" + result.stdout + "\n" + result.stderr,
                   encoding="utf-8")
    return result


def run_case(name: str, arguments: list[str], compiler: Path, target: str,
             run_root: Path, compile_only: bool) -> dict[str, object]:
    """Compiles a test and, for native gates, checks its exit status and success banner."""
    started = time.monotonic()
    case_root = run_root / name
    data = case_root / "data"
    data.mkdir(parents=True)
    source = ROOT / "src" / "tests" / (name + ".ml")
    executable = case_root / (name + (".exe" if target == "windows-x64" else ""))
    result: dict[str, object] = {"case": name, "status": "FAIL"}
    try:
        command = [sys.executable, str(compiler), str(source), str(executable),
                   "-I", str(ROOT / "src"), "-I", str(compiler.parent), "--target", target]
        compiled = execute(command, case_root / "compile.log", 1200)
        if compiled.returncode != 0 or not executable.is_file():
            raise RuntimeError("compilation failed; see compile.log")
        expected_magic = b"MZ" if target == "windows-x64" else b"\x7fELF"
        with executable.open("rb") as stream:
            if stream.read(len(expected_magic)) != expected_magic:
                raise RuntimeError("compiler produced an unexpected executable format")
        if compile_only:
            result["status"] = "COMPILE_PASS"
        else:
            executable.chmod(executable.stat().st_mode | 0o111)
            command = [str(executable)] + [item.format(data=data, repo=ROOT) for item in arguments]
            native = execute(command, case_root / "run.log", 600)
            banners = re.findall(r'"(MiniSQL[^"\n]*: SUCCESS)"', source.read_text(encoding="utf-8"))
            if native.returncode != 0 or not banners or banners[-1] not in native.stdout:
                raise RuntimeError("native test failed or success banner missing; see run.log")
            result["status"] = "PASS"
    except (OSError, subprocess.TimeoutExpired, RuntimeError) as error:
        result["error"] = str(error)
    result["seconds"] = round(time.monotonic() - started, 3)
    return result


def main() -> int:
    """Runs the focused or selected regression cases and writes machine-readable evidence."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--compiler", default=os.environ.get("MINILANG_COMPILER"))
    parser.add_argument("--target", choices=["windows-x64", "linux-x64"],
                        default="windows-x64" if os.name == "nt" else "linux-x64")
    parser.add_argument("--compile-only", action="store_true")
    parser.add_argument("--integration", action="store_true")
    parser.add_argument("--case", action="append", choices=sorted(CORE | REGRESSIONS))
    parser.add_argument("--jobs", type=int, default=2)
    args = parser.parse_args()
    if args.jobs < 1 or args.jobs > 4:
        parser.error("--jobs must be between 1 and 4")
    native_target = "windows-x64" if os.name == "nt" else "linux-x64"
    if args.target != native_target and not args.compile_only:
        parser.error("cross-target execution is unsupported; use --compile-only")
    compiler = Path(args.compiler) if args.compiler else ROOT.parent / "MiniLangCompilerPy" / "mlc_win64.py"
    compiler = compiler.resolve()
    if not compiler.is_file():
        parser.error("MiniLang compiler not found; pass --compiler")
    inventory = CORE | REGRESSIONS
    selected = args.case or list(inventory if args.integration else CORE)
    selected = list(dict.fromkeys(selected))
    output_parent = ROOT / "build" / "storage-v2" / "gates"
    output_parent.mkdir(parents=True, exist_ok=True)
    run_root = Path(tempfile.mkdtemp(prefix=datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ-"), dir=output_parent))
    results = []
    print(f"Storage v2 {args.target}: {len(selected)} cases; logs: {run_root}", flush=True)
    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        futures = [pool.submit(run_case, name, inventory[name], compiler, args.target,
                               run_root, args.compile_only) for name in selected]
        for future in as_completed(futures):
            result = future.result()
            results.append(result)
            print(f"{result['case']}: {result['status']} ({result['seconds']}s)", flush=True)
            if "error" in result:
                print(result["error"], flush=True)
    passed = all(result["status"] in {"PASS", "COMPILE_PASS"} for result in results)
    evidence = {"databaseFormatVersion": 2, "target": args.target,
                "compileOnly": args.compile_only, "compiler": str(compiler),
                "status": "PASS" if passed else "FAIL", "cases": sorted(results, key=lambda item: item["case"])}
    (run_root / "results.json").write_text(json.dumps(evidence, indent=2) + "\n", encoding="utf-8")
    mode = "compile gate" if args.compile_only else "tests"
    print(f"MiniSQL storage v2 {mode}: {'SUCCESS' if passed else 'FAIL'}", flush=True)
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
