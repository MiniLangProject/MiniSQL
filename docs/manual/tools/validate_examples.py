#!/usr/bin/env python3
"""Execute the manual's examples against fresh native MiniSQL databases.

No existing database is opened or changed. Run from any directory with
--bin-dir pointing at matching minisqld/minisql executables. All subprocesses
share one invocation, which also works in isolated CI network namespaces.
"""
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
from __future__ import annotations

import argparse
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


def free_port() -> int:
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return int(sock.getsockname()[1])


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bin-dir", required=True, type=Path)
    parser.add_argument("--output", type=Path, default=MANUAL / "validation.json")
    args = parser.parse_args()
    suffix = ".exe" if os.name == "nt" else ""
    server_exe = args.bin_dir.resolve() / ("minisqld" + suffix)
    client_exe = args.bin_dir.resolve() / ("minisql" + suffix)
    for path in (server_exe, client_exe):
        if not path.is_file():
            parser.error(f"missing executable: {path}")
    evidence: dict = {
        "source_baseline": "9bedab0c9de307d0435d3abfb3eab98a2f6d42a5",
        "platform": sys.platform,
        "storage_format": 2,
        "wire_protocol": 1,
        "scope": "Native CLI scripts and focused documentation assertions; not a full release gate",
        "scripts": [],
        "checks": [],
    }
    failures = 0
    REPO.joinpath("build").mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="manual-", dir=REPO / "build") as temporary:
        work = Path(temporary)
        initialized = subprocess.run(
            [str(server_exe), "--init", str(work / "data"), "manual", "4096"],
            capture_output=True, text=True, check=True, timeout=60,
        )
        match = re.search(r"MiniSQL database created: (.+)", initialized.stdout)
        if not match:
            raise RuntimeError(initialized.stdout + initialized.stderr)
        database = match.group(1).strip()
        port = free_port()
        with (work / "server.log").open("w", encoding="utf-8") as log:
            process = subprocess.Popen(
                [str(server_exe), "--serve", database, str(port), "16"],
                cwd=work, stdout=log, stderr=subprocess.STDOUT,
            )
            connection = None
            try:
                for _ in range(200):
                    try:
                        connection = minisql.connect(
                            f"minisql://127.0.0.1:{port}/main", autocommit=True,
                            connect_timeout=1,
                        )
                        break
                    except minisql.OperationalError:
                        if process.poll() is not None:
                            raise RuntimeError((work / "server.log").read_text())
                        time.sleep(0.05)
                if connection is None:
                    raise RuntimeError("server did not become ready")

                for script in sorted(MANUAL.joinpath("examples").glob("0[1-4]-*.sql")):
                    result = subprocess.run(
                        [str(client_exe), "--script", str(port), str(script)],
                        cwd=work, capture_output=True, text=True, timeout=90,
                    )
                    passed = result.returncode == 0 and "MiniSQL script completed" in result.stdout
                    evidence["scripts"].append({
                        "file": f"examples/{script.name}", "passed": passed,
                        "exit_code": result.returncode, "stdout": result.stdout,
                        "stderr": result.stderr,
                    })
                    print(f"{script.name}: {'PASS' if passed else 'FAIL'}", flush=True)
                    if not passed:
                        print(result.stdout + result.stderr, flush=True)
                        failures += 1
                        break

                def check(name: str, sql: str, expected=None, error_contains=None) -> None:
                    nonlocal failures
                    record = {"name": name, "sql": sql}
                    try:
                        with connection.cursor() as cursor:
                            cursor.execute(sql)
                            rows = [list(row) for row in cursor.fetchall()] if cursor.description else []
                        record["rows"] = rows
                        record["passed"] = error_contains is None and (expected is None or rows == expected)
                        if expected is not None:
                            record["expected"] = expected
                    except Exception as error:
                        record["error"] = str(error)
                        record["passed"] = error_contains is not None and error_contains in str(error)
                        if error_contains:
                            record["expected_error_contains"] = error_contains
                    if not record["passed"]:
                        failures += 1
                    evidence["checks"].append(record)
                    print(f"{name}: {'PASS' if record['passed'] else 'FAIL'}", flush=True)

                if failures == 0:
                    check("table row counts", "SELECT (SELECT COUNT(*) FROM customers),(SELECT COUNT(*) FROM products),(SELECT COUNT(*) FROM orders),(SELECT COUNT(*) FROM order_items)", [["4", "5", "4", "6"]])
                    check("low stock order", "SELECT product_id,stock FROM products WHERE stock<15 ORDER BY stock,product_id", [["104", "8"], ["101", "12"]])
                    check("null city", "SELECT customer_id FROM customers WHERE city IS NULL", [["4"]])
                    check("COUNT ignores null", "SELECT COUNT(city),COUNT(*) FROM customers", [["3", "4"]])
                    check("outer join zero orders", "SELECT c.name,COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id GROUP BY c.name ORDER BY c.name", [["Ada", "2"], ["Grace", "1"], ["Linus", "1"], ["Margaret", "0"]])
                    check("grouped units", "SELECT c.name,SUM(i.quantity) FROM customers c JOIN orders o ON o.customer_id=c.customer_id JOIN order_items i ON i.order_id=o.order_id GROUP BY c.name HAVING SUM(i.quantity)>=3 ORDER BY c.name", [["Ada", "6"], ["Grace", "3"]])
                    check("total units", "SELECT SUM(quantity) FROM order_items", [["10"]])
                    check("top two stock", "SELECT product_id,stock FROM products ORDER BY stock DESC,product_id LIMIT 2", [["103", "100"], ["105", "50"]])
                    check("transaction script restored state", "SELECT stock FROM products WHERE product_id=101", [["12"]])
                    check("practice row rolled back", "SELECT COUNT(*) FROM customers WHERE customer_id=99", [["0"]])
                    check("anti join", "SELECT c.customer_id FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id WHERE o.order_id IS NULL", [["4"]])
                    check("window numbering", "SELECT order_id,ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_id) FROM orders ORDER BY customer_id,order_id", [["1001", "1"], ["1003", "2"], ["1002", "1"], ["1004", "1"]])
                    check("recursive query", "WITH RECURSIVE numbers(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM numbers WHERE n<5) SELECT n FROM numbers ORDER BY n", [["1"], ["2"], ["3"], ["4"], ["5"]])
                    check("reject duplicate key", "INSERT INTO customers(customer_id,name) VALUES(1,'Duplicate')", error_contains="duplicate")
                    check("reject missing parent", "INSERT INTO orders(order_id,customer_id,order_status) VALUES(9999,9999,'new')", error_contains="foreign")
                    check("reject negative stock", "UPDATE products SET stock=-1 WHERE product_id=101", error_contains="CHECK")
                    check("decimal wire coefficient", "SELECT price FROM products WHERE product_id=101", [["7990"]])
                    check("decimal arithmetic limitation", "SELECT CAST('3.30' AS DECIMAL(10,2))+CAST('1.20' AS DECIMAL(10,2))", [["45000"]])
                    check("decimal mixed comparison limitation", "SELECT CAST('3.30' AS DECIMAL(10,2))=330", [["TRUE"]])
                    check("NULLIF limitation", "SELECT NULLIF(5,NULL)", [[None]])
                    check("temporal comparison limitation", "SELECT CAST(0 AS DATE)=CAST(0 AS DATE)", error_contains="not comparable")
                    check("current timestamp limitation", "SELECT CURRENT_TIMESTAMP", [["0"]])
                    check("division returns DOUBLE", "SELECT 5/2", [["2.5"]])
                    check("text NULL ambiguity", "SELECT 'NULL',NULL", [[None, None]])
                    check("create referential probe parent", "CREATE TABLE manual_probe_parent(id INTEGER PRIMARY KEY)")
                    check("create referential probe child", "CREATE TABLE manual_probe_child(id INTEGER PRIMARY KEY,pid INTEGER REFERENCES manual_probe_parent(id) ON DELETE CASCADE ON UPDATE CASCADE)")
                    check("insert referential probe parent", "INSERT INTO manual_probe_parent VALUES(1)")
                    check("insert referential probe child", "INSERT INTO manual_probe_child VALUES(10,1)")
                    check("delete cascade limitation", "DELETE FROM manual_probe_parent WHERE id=1", error_contains="CASCADE execution")
                    check("parent update limitation", "UPDATE manual_probe_parent SET id=2 WHERE id=1")
                    check("orphan demonstrates update limitation", "SELECT p.id,c.pid FROM manual_probe_parent p CROSS JOIN manual_probe_child c", [["2", "1"]])
                    check("drop referential probe child", "DROP TABLE manual_probe_child")
                    check("drop referential probe parent", "DROP TABLE manual_probe_parent")
                    check("correlated EXISTS", "SELECT c.customer_id FROM customers c WHERE EXISTS(SELECT 1 FROM orders o WHERE o.customer_id=c.customer_id) ORDER BY c.customer_id", [["1"], ["2"], ["3"]])
                    check("correlated scalar aggregate", "SELECT c.customer_id,(SELECT COUNT(*) FROM orders o WHERE o.customer_id=c.customer_id) FROM customers c ORDER BY c.customer_id", [["1", "2"], ["2", "1"], ["3", "1"], ["4", "0"]])
                    check("IN subquery", "SELECT customer_id FROM customers WHERE customer_id IN(SELECT customer_id FROM orders) ORDER BY customer_id", [["1"], ["2"], ["3"]])
                    check("correlated NOT EXISTS limitation", "SELECT c.customer_id FROM customers c WHERE NOT EXISTS(SELECT 1 FROM orders o WHERE o.customer_id=c.customer_id)", error_contains="Struct has no member")
                    check("create sequence probe", "CREATE SEQUENCE manual_seq START WITH 1 INCREMENT BY 1")
                    check("sequence materialization limitation", "SELECT NEXTVAL('manual_seq') FROM products ORDER BY product_id", [["2"], ["2"], ["2"], ["2"], ["2"]])
                    check("sequence double-consumption limitation", "SELECT NEXTVAL('manual_seq')", [["4"]])
                    check("read-only sequence begin", "BEGIN READ ONLY")
                    check("read-only sequence limitation", "SELECT NEXTVAL('manual_seq')", [["6"]])
                    check("read-only sequence rollback", "ROLLBACK")
                    check("sequence survives rollback", "SELECT CURRVAL('manual_seq')", [["6"]])
                    check("drop sequence probe", "DROP SEQUENCE manual_seq")
                    check("create identity probe", "CREATE TABLE manual_identity(id INTEGER AUTO_INCREMENT PRIMARY KEY,label VARCHAR(20))")
                    check("identity first insert", "INSERT INTO manual_identity(label) VALUES('first') RETURNING id", [["1"]])
                    check("identity second insert", "INSERT INTO manual_identity(label) VALUES('second') RETURNING id", [["2"]])
                    check("delete highest identity", "DELETE FROM manual_identity WHERE id=2")
                    check("identity reuse limitation", "INSERT INTO manual_identity(label) VALUES('replacement') RETURNING id", [["2"]])
                    check("drop identity probe", "DROP TABLE manual_identity")
                    check("operational status", "SHOW STATUS")
                    check("operational process list", "SHOW PROCESSLIST")
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
    evidence["passed"] = failures == 0
    evidence["check_count"] = len(evidence["checks"])
    evidence["script_count"] = len(evidence["scripts"])
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(evidence, indent=2) + "\n", encoding="utf-8")
    print(f"Manual validation: {'PASS' if failures == 0 else 'FAIL'} ({len(evidence['checks'])} checks, {len(evidence['scripts'])} scripts)")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
