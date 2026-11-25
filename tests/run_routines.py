# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see the LICENSE file.

"""Internal native stored-procedure gate, exposed through test.ps1 -Routines."""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import sys
import tempfile

sys.dont_write_bytecode = True
from run_storage_v2 import run_case  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
CASES = {
    "stored_procedure_parser": [],
    "stored_procedure_runtime": ["{data}"],
    "stored_procedure_edges": ["{data}"],
    "stored_procedure_parity": ["{data}"],
    "routines_client": [],
    "routine_security": ["{data}"],
    "m12_sql_frontend": [],
    "m15_sql_engine": ["{data}"],
    "m22_prepared_statements": ["{data}"],
    "m33_sql_batch": [],
    "m37_outer_joins": ["{data}"],
    "m45_sequences_generated_triggers": ["{data}"],
}


def main() -> int:
    """Runs isolated native cases, or a cross-target compile gate, with retained evidence."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--compiler", default=os.environ.get("MINILANG_COMPILER"))
    parser.add_argument("--target", choices=["windows-x64", "linux-x64"],
                        default="windows-x64" if os.name == "nt" else "linux-x64")
    parser.add_argument("--compile-only", action="store_true")
    parser.add_argument("--case", action="append", choices=sorted(CASES))
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
    selected = list(dict.fromkeys(args.case or CASES))
    output_parent = ROOT / "build" / "routines" / "gates"
    output_parent.mkdir(parents=True, exist_ok=True)
    run_root = Path(tempfile.mkdtemp(
        prefix=datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ-"), dir=output_parent))
    results = []
    print(f"Stored procedures {args.target}: {len(selected)} cases; logs: {run_root}", flush=True)
    # The shared native runner validates executable format, exit status and the
    # source's success marker, with a fresh data directory for every invocation.
    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        futures = [pool.submit(run_case, name, CASES[name], compiler, args.target,
                               run_root, args.compile_only) for name in selected]
        for future in as_completed(futures):
            result = future.result()
            results.append(result)
            print(f"{result['case']}: {result['status']} ({result['seconds']}s)", flush=True)
            if "error" in result:
                print(result["error"], flush=True)
    passed = all(result["status"] in {"PASS", "COMPILE_PASS"} for result in results)
    evidence = {"target": args.target, "compileOnly": args.compile_only,
                "compiler": str(compiler), "status": "PASS" if passed else "FAIL",
                "cases": sorted(results, key=lambda item: item["case"])}
    (run_root / "results.json").write_text(json.dumps(evidence, indent=2) + "\n", encoding="utf-8")
    mode = "compile gate" if args.compile_only else "tests"
    print(f"MiniSQL stored procedure {mode}: {'SUCCESS' if passed else 'FAIL'}", flush=True)
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
