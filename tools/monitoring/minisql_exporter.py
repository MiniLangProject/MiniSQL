#!/usr/bin/env python3
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.

"""Expose MiniSQL SHOW STATUS counters as Prometheus text over loopback HTTP."""

from __future__ import annotations

import argparse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import os
from pathlib import Path
import re
import sys
import time
from typing import Iterable

PROJECT_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PROJECT_ROOT / "clients" / "python"))

import minisql  # noqa: E402

METRIC_NAME = re.compile(r"[^a-zA-Z0-9_:]")


def prometheus_name(status_name: str) -> str:
    """Converts one stable SHOW STATUS name into a MiniSQL metric name."""
    return "minisql_" + METRIC_NAME.sub("_", status_name).lower()


def render_metrics(rows: Iterable[tuple[object, object]], scrape_seconds: float) -> bytes:
    """Renders numeric SHOW STATUS rows and exporter health in text format."""
    lines = ["# HELP minisql_up Whether the latest MiniSQL scrape succeeded.", "# TYPE minisql_up gauge", "minisql_up 1"]
    for raw_name, raw_value in rows:
        name = prometheus_name(str(raw_name))
        value = str(raw_value)
        try:
            numeric = float(value)
        except ValueError:
            continue
        rendered = str(int(numeric)) if numeric.is_integer() else repr(numeric)
        lines.extend((f"# TYPE {name} gauge", f"{name} {rendered}"))
    lines.extend(("# TYPE minisql_exporter_scrape_duration_seconds gauge", f"minisql_exporter_scrape_duration_seconds {scrape_seconds:.9f}"))
    return ("\n".join(lines) + "\n").encode("utf-8")


class MiniSqlCollector:
    """Owns immutable connection settings and performs one bounded scrape."""

    def __init__(self, args: argparse.Namespace) -> None:
        """Stores validated database and exporter connection settings."""
        self.args = args

    def scrape(self) -> bytes:
        """Opens an isolated connection, obtains SHOW STATUS, and closes it."""
        started = time.monotonic()
        connection = minisql.connect(
            host=self.args.database_host,
            port=self.args.database_port,
            database=self.args.database,
            user=self.args.user,
            password=os.environ.get(self.args.password_env, ""),
            tls=self.args.tls,
            server_name=self.args.server_name,
            pin_sha256=self.args.pin_sha256,
            ca_file=self.args.ca_file,
            connect_timeout=self.args.timeout,
            socket_timeout=self.args.timeout,
            autocommit=True,
        )
        try:
            cursor = connection.cursor()
            cursor.execute("SHOW STATUS")
            rows = cursor.fetchall()
        finally:
            connection.close()
        return render_metrics(rows, time.monotonic() - started)


def handler_type(collector: MiniSqlCollector) -> type[BaseHTTPRequestHandler]:
    """Builds a request handler bound to one collector without global state."""

    class Handler(BaseHTTPRequestHandler):
        """Serves health and metric snapshots for one shared collector."""

        def do_GET(self) -> None:  # noqa: N802 - stdlib callback name
            """Handles one bounded loopback HTTP GET request."""
            if self.path not in {"/metrics", "/healthz"}:
                self.send_error(404)
                return
            try:
                body = collector.scrape()
                status = 200
            except Exception as exc:  # health endpoint must remain observable
                body = ("minisql_up 0\n# scrape_error " + str(exc).replace("\n", " ") + "\n").encode("utf-8", "replace")
                status = 503
            self.send_response(status)
            self.send_header("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def log_message(self, fmt: str, *args: object) -> None:
            """Writes standard HTTP access diagnostics without global logging."""
            sys.stderr.write("minisql-exporter " + (fmt % args) + "\n")

    return Handler


def parse_args() -> argparse.Namespace:
    """Parses fail-closed network and credential settings."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--listen-address", default="127.0.0.1")
    parser.add_argument("--listen-port", type=int, default=9107)
    parser.add_argument("--database-host", default="127.0.0.1")
    parser.add_argument("--database-port", type=int, default=7432)
    parser.add_argument("--database", default="main")
    parser.add_argument("--user")
    parser.add_argument("--password-env", default="MINISQL_EXPORTER_PASSWORD")
    parser.add_argument("--tls", action="store_true")
    parser.add_argument("--server-name", default="localhost")
    parser.add_argument("--pin-sha256")
    parser.add_argument("--ca-file")
    parser.add_argument("--timeout", type=float, default=5.0)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.listen_address not in {"127.0.0.1", "::1", "localhost"}:
        parser.error("the exporter binds only to loopback; use a protected reverse proxy for remote monitoring")
    return args


def main() -> int:
    """Runs a deterministic renderer self-test or serves until interrupted."""
    args = parse_args()
    if args.self_test:
        output = render_metrics([("total_statements", "12"), ("heap_used_bytes", "4096")], 0.25).decode()
        if "minisql_total_statements 12" not in output or "minisql_up 1" not in output:
            return 1
        print("MiniSQL monitoring exporter self-test: SUCCESS")
        return 0
    collector = MiniSqlCollector(args)
    server = ThreadingHTTPServer((args.listen_address, args.listen_port), handler_type(collector))
    print(f"MiniSQL monitoring exporter listening on http://{args.listen_address}:{args.listen_port}/metrics")
    try:
        server.serve_forever(poll_interval=0.5)
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
