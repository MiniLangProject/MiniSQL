# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see LICENSE for details.
"""Live trusted/authenticated/TLS DB-API integration tests."""

from __future__ import annotations

import datetime
import sys

import minisql


checks = 0


def check(condition: bool, label: str) -> None:
    """Counts one live assertion and raises with its diagnostic label."""
    global checks
    checks += 1
    if not condition:
        raise AssertionError(label)


def equal(actual: object, expected: object, label: str) -> None:
    """Checks equality while preserving expected and actual values."""
    check(actual == expected, f"{label}: expected={expected!r} actual={actual!r}")


def run(dsn: str, prepare_auth: bool) -> None:
    """Runs the complete DB-API live suite against one server mode."""
    global checks
    connection = minisql.connect(dsn)
    try:
        check(connection.ping(), "PING/PONG validation")
        with connection.cursor() as cursor:
            cursor.execute(
                "CREATE TABLE IF NOT EXISTS python_probe "
                "(id INTEGER PRIMARY KEY, label VARCHAR(100), active BOOLEAN)"
            )
            connection.commit()
            cursor.execute("DELETE FROM python_probe")
            connection.commit()

            rows = [(identifier, f"row {identifier}", identifier % 2 == 0) for identifier in range(1, 601)]
            cursor.executemany("INSERT INTO python_probe(id,label,active) VALUES (?,?,?)", rows)
            equal(cursor.rowcount, 600, "bounded executemany count")
            connection.commit()

            operation = "SELECT id,label,active FROM python_probe WHERE id >= ? ORDER BY id"
            cursor.execute(operation, (1,))
            check(operation in connection._plans, "parameterized query owns a server-side plan")
            equal(len(cursor.description or ()), 3, "cursor description width")
            streamed = cursor.fetchall()
            equal(len(streamed), 600, "result crosses the 512-row frame boundary")
            for index, row in enumerate(streamed, 1):
                equal(row[0], str(index), "ordered streamed id")
                equal(row[1], f"row {index}", "streamed label")

            cursor.execute(
                "INSERT INTO python_probe(id,label,active) VALUES (?,?,?)",
                (700, "O'Reilly VALUES ) (", True),
            )
            cursor.execute("SELECT label FROM python_probe WHERE id = ?", (700,))
            equal(cursor.fetchone(), ("O'Reilly VALUES ) (",), "quote-safe parameter binding")
            equal(cursor.fetchone(), None, "exhausted cursor remains exhausted")

            competing = connection.cursor()
            cursor.execute("SELECT id FROM python_probe ORDER BY id")
            check(cursor.fetchone() is not None, "stream starts")
            try:
                competing.execute("SELECT 1")
                raise AssertionError("parallel cursor must not interleave one v1 stream")
            except minisql.InterfaceError:
                checks += 1
            cursor.close()
            with connection.cursor() as reusable:
                reusable.execute("SELECT 1 AS value")
                equal(reusable.fetchone(), ("1",), "connection reusable after cursor drain")

        connection.commit()
        with connection.cursor() as temporal:
            temporal.execute(
                "CREATE TABLE IF NOT EXISTS python_temporal "
                "(id INTEGER PRIMARY KEY, d DATE, t TIME, ts TIMESTAMP)"
            )
            connection.commit()
            temporal.execute("DELETE FROM python_temporal")
            temporal.execute(
                "INSERT INTO python_temporal(id,d,t,ts) VALUES (?,?,?,?)",
                (1, datetime.date(2026, 8, 28), datetime.time(3, 14, 15, 123456),
                 datetime.datetime(2026, 8, 28, 3, 14, 15, 123456)),
            )
            connection.commit()
            temporal.execute("SELECT COUNT(*) FROM python_temporal")
            equal(temporal.fetchone(), ("1",), "temporal values persisted")

        with connection.cursor() as transaction:
            transaction.execute(
                "INSERT INTO python_probe(id,label,active) VALUES (?,?,?)", (9999, "rollback", True)
            )
            connection.rollback()
            transaction.execute("SELECT COUNT(*) FROM python_probe WHERE id = 9999")
            equal(transaction.fetchone(), ("0",), "rollback removed row")
            connection.commit()

        connection.autocommit = True
        with connection.cursor() as failing:
            try:
                failing.executemany(
                    "INSERT INTO python_probe(id,label,active) VALUES (?,?,?)",
                    [(8000, "first", True), (8000, "duplicate", False)],
                )
                raise AssertionError("duplicate executemany must fail")
            except minisql.IntegrityError:
                checks += 1
            failing.execute("SELECT COUNT(*) FROM python_probe WHERE id = 8000")
            equal(failing.fetchone(), ("1",), "failed batch preserves successful prefix")

        connection.autocommit = False
        with connection.cursor() as transactional_batch:
            try:
                transactional_batch.executemany(
                    "INSERT INTO python_probe(id,label,active) VALUES (?,?,?)",
                    [(9000, "first", True), (9000, "duplicate", False)],
                )
                raise AssertionError("transactional duplicate batch must fail")
            except minisql.IntegrityError:
                checks += 1
            connection.rollback()
            transactional_batch.execute("SELECT COUNT(*) FROM python_probe WHERE id = 9000")
            equal(transactional_batch.fetchone(), ("0",), "rollback clears failed transactional batch")
            connection.commit()

        if prepare_auth:
            with connection.cursor() as security:
                security.execute("ALTER USER \"admin\" WITH PASSWORD 'python-test-password'")
    finally:
        connection.close()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise SystemExit("usage: integration.py DSN [prepare-auth]")
    run(sys.argv[1], len(sys.argv) > 2 and sys.argv[2] == "prepare-auth")
    print(f"MiniSQL Python connector integration tests: PASS ({checks} checks)")
