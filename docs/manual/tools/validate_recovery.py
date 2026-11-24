#!/usr/bin/env python3
"""Verify the manual's offline backup/restore recipe in disposable directories."""
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
from __future__ import annotations

import argparse
from contextlib import contextmanager
import json
import os
from pathlib import Path
import re
import socket
import subprocess
import sys
import tempfile
import time

MANUAL = Path(__file__).resolve().parents[1]
REPO = MANUAL.parents[1]
sys.path.insert(0, str(REPO / "clients" / "python"))
import minisql  # noqa: E402


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bin-dir", type=Path, required=True)
    parser.add_argument("--output", type=Path, default=MANUAL / "recovery-validation.json")
    args = parser.parse_args()
    suffix = ".exe" if os.name == "nt" else ""
    bins = {name: args.bin_dir.resolve() / (name + suffix)
            for name in ("minisqld", "minisql", "minisql-check", "minisql-backup")}
    for binary in bins.values():
        if not binary.is_file():
            parser.error(f"missing executable: {binary}")
    evidence = {"source_baseline": "9bedab0c9de307d0435d3abfb3eab98a2f6d42a5",
                "platform": sys.platform, "scope": "Offline plain backup and restore with native check and restarted SQL verification",
                "steps": [], "passed": False}

    def run(label, arguments, work):
        result = subprocess.run(arguments, cwd=work, capture_output=True,
                                text=True, timeout=90)
        evidence["steps"].append({"name": label, "exit_code": result.returncode,
                                  "stdout": result.stdout, "stderr": result.stderr})
        if result.returncode:
            raise RuntimeError(f"{label}: {result.stdout}{result.stderr}")
        print(f"{label}: PASS", flush=True)
        return result.stdout

    @contextmanager
    def serving(database, work, tag):
        with socket.socket() as socket_probe:
            socket_probe.bind(("127.0.0.1", 0))
            port = socket_probe.getsockname()[1]
        connection = None
        with (work / f"{tag}.log").open("w") as log:
            process = subprocess.Popen([str(bins["minisqld"]), "--serve", str(database), str(port), "8"],
                                       cwd=work, stdout=log, stderr=subprocess.STDOUT)
            try:
                for _ in range(200):
                    try:
                        connection = minisql.connect(f"minisql://127.0.0.1:{port}/main", autocommit=True, connect_timeout=1)
                        break
                    except minisql.OperationalError:
                        if process.poll() is not None:
                            raise RuntimeError((work / f"{tag}.log").read_text())
                        time.sleep(.05)
                if connection is None:
                    raise RuntimeError("server did not become ready")
                yield connection, port
                with connection.cursor() as cursor:
                    cursor.execute("SHUTDOWN")
                connection.close()
                connection = None
                process.wait(timeout=15)
            finally:
                if connection is not None:
                    try:
                        connection.close()
                    except Exception:
                        pass
                if process.poll() is None:
                    process.terminate()
                    try:
                        process.wait(timeout=5)
                    except subprocess.TimeoutExpired:
                        process.kill()
                        process.wait()

    REPO.joinpath("build").mkdir(exist_ok=True)
    try:
        with tempfile.TemporaryDirectory(prefix="manual-recovery-", dir=REPO / "build") as temporary:
            work = Path(temporary)
            initialized = run("initialize fresh source", [str(bins["minisqld"]), "--init", str(work / "data"), "recovery", "4096"], work)
            source = Path(re.search(r"MiniSQL database created: (.+)", initialized).group(1).strip())
            with serving(source, work, "source") as (connection, port):
                run("load teaching schema and rows", [str(bins["minisql"]), "--script", str(port), str(MANUAL / "examples/01-create-shop.sql")], work)
            run("check stopped source", [str(bins["minisql-check"]), str(source)], work)
            run("create offline backup", [str(bins["minisql-backup"]), "backup", str(source), str(work / "backup")], work)
            run("restore into new directory", [str(bins["minisql-backup"]), "restore", str(work / "backup"), str(work / "restored")], work)
            run("check restored database", [str(bins["minisql-check"]), str(work / "restored")], work)
            with serving(work / "restored", work, "restored") as (connection, _):
                expected = [["4", "5", "4", "6"]]
                with connection.cursor() as cursor:
                    cursor.execute("SELECT (SELECT COUNT(*) FROM customers),(SELECT COUNT(*) FROM products),(SELECT COUNT(*) FROM orders),(SELECT COUNT(*) FROM order_items)")
                    actual = [list(row) for row in cursor.fetchall()]
                    if actual != expected:
                        raise AssertionError((expected, actual))
                    evidence["steps"].append({"name": "restored SQL row counts", "expected": expected, "actual": actual, "passed": True})
                    cursor.execute("SELECT c.name,SUM(i.quantity) FROM customers c JOIN orders o ON o.customer_id=c.customer_id JOIN order_items i ON i.order_id=o.order_id GROUP BY c.name HAVING SUM(i.quantity)>=3 ORDER BY c.name")
                    actual = [list(row) for row in cursor.fetchall()]
                    expected = [["Ada", "6"], ["Grace", "3"]]
                    if actual != expected:
                        raise AssertionError((expected, actual))
                    evidence["steps"].append({"name": "restored joined aggregate", "expected": expected, "actual": actual, "passed": True})
                    cursor.execute("BEGIN")
                    cursor.execute("UPDATE products SET stock=stock+1 WHERE product_id=101")
                    cursor.execute("SELECT stock FROM products WHERE product_id=101")
                    actual = [list(row) for row in cursor.fetchall()]
                    if actual != [["13"]]:
                        raise AssertionError(actual)
                    cursor.execute("ROLLBACK")
                    cursor.execute("SELECT stock FROM products WHERE product_id=101")
                    actual = [list(row) for row in cursor.fetchall()]
                    if actual != [["12"]]:
                        raise AssertionError(actual)
                    evidence["steps"].append({"name": "restored writable transaction and rollback", "passed": True})
                print("restored SQL and transaction checks: PASS", flush=True)
            evidence["passed"] = True
    finally:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(evidence, indent=2) + "\n", encoding="utf-8")
    print("Manual recovery recipe: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
