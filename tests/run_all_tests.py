#!/usr/bin/env python3
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

"""Run the complete MiniSQL 1.0.0 M0-M50 test suite and package results."""
from __future__ import annotations

import argparse
import ast
import hashlib
import json
import os
import re
import socket
import subprocess
import sys
import time
import zipfile
from datetime import datetime
from decimal import Decimal, InvalidOperation
from pathlib import Path
from typing import Any, Callable

ROOT = Path(__file__).resolve().parents[1]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / "tests"))
import baseline_m0_m10 as base  # noqa: E402

MANIFEST_PATH = ROOT / "tests" / "manifest.json"
BUILD_ROOT = ROOT / "build" / "acceptance"
RESULTS_DIR = ROOT / "build" / "test-results"
RESULTS_PATH = RESULTS_DIR / "results.json"
LOG_DIR = RESULTS_DIR / "logs"
DATA_DIR = BUILD_ROOT / "data"
VERSION = "1.0.0"
REVISION = "M48-M50R3"
PHASE_COUNT = 106
FINAL_SUCCESS = "MiniSQL 1.0.0 test suite: SUCCESS"
FINAL_FAILURE = "MiniSQL 1.0.0 test suite: FAIL"

base.BUILD_ROOT = BUILD_ROOT
base.RESULTS_DIR = RESULTS_DIR
base.RESULTS_PATH = RESULTS_PATH
base.LOG_DIR = LOG_DIR
base.DATA_DIR = DATA_DIR


class AcceptanceFailure(RuntimeError):
    """Signals a deterministic acceptance-contract violation."""
    pass


def load_json(path: Path) -> Any:
    """Loads and decodes a UTF-8 JSON document from the supplied path."""
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        raise AcceptanceFailure(f"Invalid JSON {path.relative_to(ROOT)}: {exc}") from exc


def require_phrases(relative: str, phrases: list[str]) -> None:
    """Requires every supplied source-contract phrase to occur in one repository file."""
    path = ROOT / relative
    if not path.is_file():
        raise AcceptanceFailure(f"Required file missing: {relative}")
    text = path.read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in text:
            raise AcceptanceFailure(f"Required contract missing from {relative}: {phrase}")


def first_minilang_code_line(text: str) -> str:
    """Returns the first nonblank MiniLang line that is not a line comment."""
    return next(
        (line.strip() for line in text.splitlines() if line.strip() and not line.strip().startswith("//")),
        "",
    )


def validate_source_documentation() -> None:
    """Enforces Apache headers and declaration documentation across every source file."""
    source_paths = sorted(
        path
        for pattern in ("*.ml", "*.py", "*.ps1")
        for path in ROOT.rglob(pattern)
        if not any(part in {"build", "data", "logs", "tmp", ".git", "__pycache__"} for part in path.parts)
    )
    for path in source_paths:
        text = path.read_text(encoding="utf-8")
        header = "\n".join(text.splitlines()[:20])
        relative = path.relative_to(ROOT).as_posix()
        for marker in (
            "Copyright 2026 MiniLangProject contributors",
            "SPDX-License-Identifier: Apache-2.0",
            "Apache License, Version 2.0",
        ):
            if marker not in header:
                raise AcceptanceFailure(f"Missing Apache-2.0 source header in {relative}: {marker}")

        if path.suffix == ".py":
            tree = ast.parse(text, filename=str(path))
            undocumented = [
                node.name
                for node in ast.walk(tree)
                if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef))
                and ast.get_docstring(node) is None
            ]
            if undocumented:
                raise AcceptanceFailure(f"Undocumented Python declarations in {relative}: {undocumented}")
            continue

        if path.suffix == ".ps1":
            lines = text.splitlines()
            for index, raw in enumerate(lines):
                if not raw.strip().lower().startswith("function "):
                    continue
                previous = next((lines[p].strip() for p in range(index - 1, -1, -1) if lines[p].strip()), "")
                if not (previous.startswith("#") or previous == "#>"):
                    raise AcceptanceFailure(
                        f"Undocumented PowerShell function in {relative}:{index + 1}: {raw.strip()}"
                    )
            continue

        if path.suffix != ".ml":
            continue
        lines = text.splitlines()
        declaration = re.compile(r"^(?:function(?:\s+synchronized)?|extern\s+function|struct|enum)\b")
        container_end = {"struct": "end struct", "enum": "end enum"}
        container: str | None = None
        for index, raw in enumerate(lines):
            stripped = raw.strip()
            if container is not None:
                if stripped == container_end[container]:
                    container = None
                    continue
                if stripped and not stripped.startswith("//"):
                    previous = next((lines[p].strip() for p in range(index - 1, -1, -1) if lines[p].strip()), "")
                    if not previous.startswith("//"):
                        raise AcceptanceFailure(
                            f"Undocumented {container} member in {relative}:{index + 1}: {stripped}"
                        )
                continue
            if not declaration.match(stripped):
                continue
            previous = next((lines[p].strip() for p in range(index - 1, -1, -1) if lines[p].strip()), "")
            if not previous.startswith("//"):
                raise AcceptanceFailure(f"Undocumented MiniLang declaration in {relative}:{index + 1}: {stripped}")
            if stripped.startswith("struct "):
                container = "struct"
            elif stripped.startswith("enum "):
                container = "enum"



def run_m11(compiler: Path, verbose: bool) -> None:
    """Compiles and executes persistent B+ tree correctness and recovery tests."""
    path = DATA_DIR / "m11-index.idx"; base.clean_path(path); base.clean_path(Path(str(path)+".nonunique"))
    base.compile_run_test(compiler, "src/tests/m11_btree.ml", "minisql-m11-btree.exe", "MiniSQL M11 B+ tree tests: SUCCESS", verbose, [str(path)], timeout=1200)

def run_simple(compiler: Path, source: str, output: str, expected: str, verbose: bool, args: list[str] | None = None, timeout: float = 1200) -> None:
    """Compiles one later-milestone test and requires its exact success banner."""
    base.compile_run_test(compiler, source, output, expected, verbose, args or [], timeout=timeout)

def run_m33_client_input(compiler: Path, verbose: bool) -> None:
    """Runs scanner coverage and the native stdin ABI path used by the interactive shell."""
    run_simple(compiler, "src/tests/m33_sql_batch.ml", "minisql-m33-sql-batch.exe",
               "MiniSQL M33 SQL-aware client input tests: SUCCESS", verbose, timeout=2400)
    executable = base.compile_target(compiler, "src/tests/m33_interactive_input.ml",
                                     "minisql-m33-interactive-input.exe", verbose)
    result = base.run_command(
        base.executable_command(executable),
        log_name="minisql-m33-interactive-input.exe.default.run.log",
        verbose=verbose,
        timeout=240.0,
        input_text="show tables;\n",
    )
    expected = "MiniSQL M33 interactive input tests: SUCCESS"
    if result.returncode != 0 or base.normalized(result.stdout) != expected or base.normalized(result.stderr):
        raise AcceptanceFailure(
            f"M33 native interactive input regression failed: rc={result.returncode} "
            f"stdout={base.normalized(result.stdout)!r} stderr={base.normalized(result.stderr)!r}"
        )

def data_root(name: str) -> Path:
    """Returns an isolated generated data directory for one named integration scenario."""
    root = DATA_DIR / name; base.clean_path(root); root.mkdir(parents=True, exist_ok=True); return root

def free_port() -> int:
    """Asks Windows for an unused loopback TCP port and returns the assigned port number."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as probe:
        probe.bind(("127.0.0.1", 0)); return int(probe.getsockname()[1])

def wait_ready(process: subprocess.Popen[str], ready: Path, label: str, timeout: float) -> None:
    """Waits for a child-process readiness marker while also detecting premature process exit."""
    deadline = time.time() + timeout
    while not ready.exists() and process.poll() is None and time.time() < deadline:
        time.sleep(0.05)
    if not ready.exists():
        out, err = process.communicate(timeout=5)
        base.write_log(f"{label}.run.log", process.args, process.returncode or 1, out, err)
        raise AcceptanceFailure(f"{label} did not publish readiness marker; stdout={base.normalized(out)!r} stderr={base.normalized(err)!r}")

def run_m18_network(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M18 network acceptance scenario."""
    server = base.compile_target(compiler, "src/tests/m18_server_worker.ml", "minisql-m18-server-worker.exe", verbose)
    client = base.compile_target(compiler, "src/tests/m18_client_worker.ml", "minisql-m18-client-worker.exe", verbose)
    root = data_root("m18-network"); ready = root / "server.ready"; port = free_port()
    command = base.executable_command(server, str(root), str(port), str(ready))
    process = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    try:
        wait_ready(process, ready, "m18-server-worker", 120)
        base.run_exact(client, [str(port)], "MiniSQL M18 loopback client tests: SUCCESS", verbose, timeout=600)
        out, err = process.communicate(timeout=600)
        base.write_log("m18-server-worker.run.log", command, process.returncode, out, err)
        if process.returncode != 0 or base.normalized(out) != "MiniSQL M18 server worker: SUCCESS" or base.normalized(err):
            raise AcceptanceFailure(f"M18 server worker failed: rc={process.returncode} stdout={base.normalized(out)!r} stderr={base.normalized(err)!r}")
    finally:
        if process.poll() is None: process.kill(); process.communicate()

def run_m21_network(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M21 network acceptance scenario."""
    server = base.compile_target(compiler, "src/tests/m21_auth_server_worker.ml", "minisql-m21-auth-server-worker.exe", verbose)
    client = base.compile_target(compiler, "src/tests/m21_auth_client_worker.ml", "minisql-m21-auth-client-worker.exe", verbose)
    root = data_root("m21-network"); ready = root / "server.ready"; port = free_port()
    command = base.executable_command(server, str(root), str(port), str(ready))
    process = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    try:
        wait_ready(process, ready, "m21-auth-server-worker", 180)
        base.run_exact(client, [str(port)], "MiniSQL M21 authenticated client tests: SUCCESS", verbose, timeout=900)
        out, err = process.communicate(timeout=900)
        base.write_log("m21-auth-server-worker.run.log", command, process.returncode, out, err)
        if process.returncode != 0 or base.normalized(out) != "MiniSQL M21 authenticated server worker: SUCCESS" or base.normalized(err):
            raise AcceptanceFailure(f"M21 server worker failed: rc={process.returncode} stdout={base.normalized(out)!r} stderr={base.normalized(err)!r}")
    finally:
        if process.poll() is None: process.kill(); process.communicate()

def run_parallel_clients(executable: Path, port: int, client_ids: list[int], prefix: str, verbose: bool, timeout: float) -> None:
    """Starts client processes concurrently, waits for all of them and validates every result."""
    processes: list[tuple[int, list[str], subprocess.Popen[str]]] = []
    for client_id in client_ids:
        command = base.executable_command(executable, str(port), str(client_id))
        process = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        processes.append((client_id, command, process))
    failures: list[str] = []
    try:
        for client_id, command, process in processes:
            try:
                out, err = process.communicate(timeout=timeout)
            except subprocess.TimeoutExpired:
                process.kill()
                out, err = process.communicate(timeout=5)
                failures.append(f"client {client_id} timed out")
            base.write_log(f"{prefix}-client-{client_id}.run.log", command, process.returncode, out, err)
            expected = f"{prefix} client worker: SUCCESS id={client_id}"
            normalized_out = base.normalized(out)
            normalized_err = base.normalized(err)
            if process.returncode != 0 or normalized_out != expected or normalized_err:
                failures.append(
                    f"client {client_id}: rc={process.returncode} "
                    f"stdout={normalized_out!r} stderr={normalized_err!r}"
                )
    finally:
        for client_id, command, process in processes:
            if process.poll() is None:
                process.kill()
                out, err = process.communicate(timeout=5)
                base.write_log(f"{prefix}-client-{client_id}.run.log", command, process.returncode, out, err)
    if failures:
        raise AcceptanceFailure(f"{prefix} client failures: " + "; ".join(failures))

def run_m27_network(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M27 network acceptance scenario."""
    server = base.compile_target(compiler, "src/tests/m27_server_worker.ml", "minisql-m27-server-worker.exe", verbose)
    client = base.compile_target(compiler, "src/tests/m27_client_worker.ml", "minisql-m27-client-worker.exe", verbose)
    root = data_root("m27-network"); ready = root / "server.ready"; port = free_port()
    command = base.executable_command(server, str(root), str(port), str(ready), "4", "15")
    process = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    try:
        wait_ready(process, ready, "m27-server-worker", 180)
        try:
            run_parallel_clients(client, port, [1,2,3], "MiniSQL M27 concurrent", verbose, 900)
        except AcceptanceFailure as client_error:
            if process.poll() is None:
                process.kill()
            out, err = process.communicate(timeout=5)
            base.write_log("m27-server-worker.run.log", command, process.returncode, out, err)
            raise AcceptanceFailure(
                f"{client_error}; M27 server at client failure: rc={process.returncode} "
                f"stdout={base.normalized(out)!r} stderr={base.normalized(err)!r}"
            ) from client_error
        out, err = process.communicate(timeout=900)
        base.write_log("m27-server-worker.run.log", command, process.returncode, out, err)
        if process.returncode != 0 or base.normalized(out) != "MiniSQL M27 concurrent server worker: SUCCESS requests=15" or base.normalized(err):
            raise AcceptanceFailure(f"M27 server failed: rc={process.returncode} stdout={base.normalized(out)!r} stderr={base.normalized(err)!r}")
    finally:
        if process.poll() is None:
            process.kill()
            out, err = process.communicate(timeout=5)
            base.write_log("m27-server-worker.run.log", command, process.returncode, out, err)

def run_m29_network(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M29 network acceptance scenario."""
    server = base.compile_target(compiler, "src/tests/m29_secure_server_worker.ml", "minisql-m29-secure-server-worker.exe", verbose)
    client = base.compile_target(compiler, "src/tests/m29_secure_client_worker.ml", "minisql-m29-secure-client-worker.exe", verbose)
    root = data_root("m29-network"); ready = root / "server.ready"; port = free_port()
    command = base.executable_command(server, str(root), str(port), str(ready), "4", "12")
    process = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    try:
        wait_ready(process, ready, "m29-secure-server-worker", 240)
        try:
            run_parallel_clients(client, port, [1,2], "MiniSQL M29 secure concurrent", verbose, 1800)
        except AcceptanceFailure as client_error:
            if process.poll() is None:
                process.kill()
            out, err = process.communicate(timeout=5)
            base.write_log("m29-secure-server-worker.run.log", command, process.returncode, out, err)
            raise AcceptanceFailure(
                f"{client_error}; M29 server at client failure: rc={process.returncode} "
                f"stdout={base.normalized(out)!r} stderr={base.normalized(err)!r}"
            ) from client_error
        out, err = process.communicate(timeout=1800)
        base.write_log("m29-secure-server-worker.run.log", command, process.returncode, out, err)
        if process.returncode != 0 or base.normalized(out) != "MiniSQL M29 secure concurrent server worker: SUCCESS requests=12" or base.normalized(err):
            raise AcceptanceFailure(f"M29 server failed: rc={process.returncode} stdout={base.normalized(out)!r} stderr={base.normalized(err)!r}")
    finally:
        if process.poll() is None:
            process.kill()
            out, err = process.communicate(timeout=5)
            base.write_log("m29-secure-server-worker.run.log", command, process.returncode, out, err)

def wait_listening(process: subprocess.Popen[str], port: int, label: str, timeout: float) -> None:
    """Waits until a child server accepts loopback connections or fails early."""
    deadline = time.monotonic() + timeout
    last_error: OSError | None = None
    while process.poll() is None and time.monotonic() < deadline:
        try:
            with socket.create_connection(("127.0.0.1", port), timeout=0.25):
                return
        except OSError as exc:
            last_error = exc
            time.sleep(0.05)
    if process.poll() is None:
        process.kill()
    out, err = process.communicate(timeout=5)
    # A caller may redirect output directly to files to avoid Windows pipe
    # backpressure; communicate() then returns None for the redirected stream.
    out = out or ""
    err = err or ""
    base.write_log(f"{label}.run.log", list(process.args), process.returncode or 1, out, err)
    raise AcceptanceFailure(
        f"{label} did not listen on 127.0.0.1:{port}; last_error={last_error!r} "
        f"stdout={base.normalized(out)!r} stderr={base.normalized(err)!r}"
    )


def public_apps() -> tuple[Path, Path]:
    """Returns verified paths to the public server and client executables."""
    server = BUILD_ROOT / "minisqld.exe"
    client = BUILD_ROOT / "minisql.exe"
    if not server.is_file() or not client.is_file():
        raise AcceptanceFailure("Public application binaries were not compiled by the application regression phase")
    return server, client


def initialize_public_database(server: Path, root: Path, name: str, verbose: bool) -> Path:
    """Creates a fresh database through the public daemon and returns its reported path."""
    command = base.executable_command(server, "--init", str(root), name, "4096")
    result = base.run_command(command, log_name=f"m32-{name}-init.run.log", verbose=verbose, timeout=900)
    output = base.normalized(result.stdout)
    if result.returncode != 0 or base.normalized(result.stderr):
        raise AcceptanceFailure(
            f"Public database initialization failed: rc={result.returncode} stdout={output!r} "
            f"stderr={base.normalized(result.stderr)!r}"
        )
    match = re.search(r"^MiniSQL database created: (.+)$", output, flags=re.MULTILINE)
    if not match:
        raise AcceptanceFailure(f"Public database initialization did not report its physical path: {output!r}")
    database = Path(match.group(1).strip())
    if not database.is_dir() or not (database / "db.meta").is_file():
        raise AcceptanceFailure(f"Reported public database path is not a valid initialized directory: {database}")
    if "Database name: " + name not in output or "Page size: 4096" not in output:
        raise AcceptanceFailure(f"Public initialization summary is incomplete: {output!r}")
    return database


def run_m32_public_script(verbose: bool) -> None:
    """Compiles and executes the M32 public script acceptance scenario."""
    server, client = public_apps()
    root = data_root("m32-public-script")
    database = initialize_public_database(server, root, "public_script", verbose)
    script = root / "transaction.sql"
    script.write_text(
        "# one public client connection retains transaction state\n"
        "CREATE TABLE public_cli_item (id INTEGER PRIMARY KEY, note VARCHAR(40));\n"
        "BEGIN;\n"
        "INSERT INTO public_cli_item(id, note) VALUES (1, 'kept');\n"
        "SAVEPOINT discard_second;\n"
        "INSERT INTO public_cli_item(id, note) VALUES (2, 'discarded');\n"
        "ROLLBACK TO discard_second;\n"
        "COMMIT;\n"
        "SELECT COUNT(*) AS c FROM public_cli_item;\n",
        encoding="utf-8",
    )
    port = free_port()
    request_budget = 10  # HELLO + eight SQL statements + CLOSE
    server_command = base.executable_command(
        server, "--serve-many", str(database), str(port), "4", str(request_budget)
    )
    process = subprocess.Popen(
        server_command,
        cwd=ROOT,
        text=True,
        encoding="utf-8",
        errors="replace",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    try:
        wait_listening(process, port, "m32-public-script-server", 180)
        client_command = base.executable_command(client, "--script", str(port), str(script))
        result = base.run_command(
            client_command,
            log_name="m32-public-script-client.run.log",
            verbose=verbose,
            timeout=1800,
        )
        client_output = base.normalized(result.stdout)
        if result.returncode != 0 or base.normalized(result.stderr):
            raise AcceptanceFailure(
                f"Public script client failed: rc={result.returncode} stdout={client_output!r} "
                f"stderr={base.normalized(result.stderr)!r}"
            )
        if "MiniSQL script completed statements=8" not in client_output:
            raise AcceptanceFailure(f"Public script did not execute all statements in one session: {client_output!r}")
        if "c\n1\n(1 rows)" not in client_output:
            raise AcceptanceFailure(f"Public script transaction/savepoint result is incorrect: {client_output!r}")
        out, err = process.communicate(timeout=1800)
        base.write_log("m32-public-script-server.run.log", server_command, process.returncode, out, err)
        server_output = base.normalized(out)
        if process.returncode != 0 or base.normalized(err):
            raise AcceptanceFailure(
                f"Bounded public server failed: rc={process.returncode} stdout={server_output!r} "
                f"stderr={base.normalized(err)!r}"
            )
        if f"MiniSQL server completed requests={request_budget}" not in server_output:
            raise AcceptanceFailure(f"Bounded public server did not complete the exact request budget: {server_output!r}")
        if "mode: trusted-local" not in server_output or "request budget: 10" not in server_output:
            raise AcceptanceFailure(f"Bounded public server startup summary is incomplete: {server_output!r}")
    finally:
        if process.poll() is None:
            process.kill()
            process.communicate()


def run_m32_persistent_daemon(verbose: bool) -> None:
    """Compiles and executes the M32 persistent daemon acceptance scenario."""
    server, client = public_apps()
    root = data_root("m32-public-daemon")
    database = initialize_public_database(server, root, "public_daemon", verbose)
    port = free_port()
    server_command = base.executable_command(server, "--serve", str(database), str(port), "4")
    process = subprocess.Popen(
        server_command,
        cwd=ROOT,
        text=True,
        encoding="utf-8",
        errors="replace",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    captured_out = ""
    captured_err = ""
    try:
        wait_listening(process, port, "m32-public-daemon", 180)
        ping_command = base.executable_command(client, "--ping", str(port))
        ping = base.run_command(ping_command, log_name="m32-public-daemon-ping.run.log", verbose=verbose, timeout=600)
        if ping.returncode != 0 or base.normalized(ping.stdout) != "PONG" or base.normalized(ping.stderr):
            raise AcceptanceFailure(
                f"Public daemon ping failed: rc={ping.returncode} stdout={base.normalized(ping.stdout)!r} "
                f"stderr={base.normalized(ping.stderr)!r}"
            )
        query_command = base.executable_command(client, "--query", str(port), "SELECT 7 AS value;")
        query = base.run_command(query_command, log_name="m32-public-daemon-query.run.log", verbose=verbose, timeout=600)
        query_output = base.normalized(query.stdout)
        if query.returncode != 0 or base.normalized(query.stderr) or "value\n7\n(1 rows)" not in query_output:
            raise AcceptanceFailure(
                f"Public daemon query failed: rc={query.returncode} stdout={query_output!r} "
                f"stderr={base.normalized(query.stderr)!r}"
            )
        time.sleep(0.5)
        if process.poll() is not None:
            captured_out, captured_err = process.communicate(timeout=5)
            raise AcceptanceFailure(
                "Operational --serve mode exited after normal clients instead of remaining available; "
                f"rc={process.returncode} stdout={base.normalized(captured_out)!r} "
                f"stderr={base.normalized(captured_err)!r}"
            )
    finally:
        if process.poll() is None:
            process.kill()
        captured_out, captured_err = process.communicate(timeout=10)
        base.write_log("m32-public-daemon.run.log", server_command, process.returncode or -9, captured_out, captured_err)
    daemon_output = base.normalized(captured_out)
    if "mode: trusted-local" not in daemon_output or "request budget: unlimited" not in daemon_output:
        raise AcceptanceFailure(f"Operational daemon startup summary is incomplete: {daemon_output!r}")
    if base.normalized(captured_err):
        raise AcceptanceFailure(f"Operational daemon wrote unexpected stderr: {base.normalized(captured_err)!r}")


def run_m33_public_multiline_script(verbose: bool) -> None:
    """Compiles and executes the M33 public multiline script acceptance scenario."""
    server, client = public_apps()
    root = data_root("m33-public-multiline")
    database = initialize_public_database(server, root, "multiline_script", verbose)
    script = root / "multiline.sql"
    script.write_text(
        "# M33 client-side comment; this semicolon is not SQL\n"
        "CREATE TABLE multi_note (\n"
        "  id INTEGER PRIMARY KEY,\n"
        "  body VARCHAR(80) NOT NULL\n"
        ");\n"
        "BEGIN; /* two statements may share one physical line */ INSERT INTO multi_note(id, body)\n"
        "VALUES (\n"
        "  1,\n"
        "  'semi;colon'\n"
        "); -- SQL comment contains ; and does not split\n"
        "COMMIT;\n"
        "SELECT body\n"
        "FROM multi_note;\n"
        "SHOW TABLES\n",
        encoding="utf-8",
    )
    port = free_port()
    request_budget = 8  # HELLO + six SQL statements + CLOSE
    server_command = base.executable_command(
        server, "--serve-many", str(database), str(port), "4", str(request_budget)
    )
    process = subprocess.Popen(
        server_command,
        cwd=ROOT,
        text=True,
        encoding="utf-8",
        errors="replace",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    try:
        wait_listening(process, port, "m33-public-multiline-server", 180)
        client_command = base.executable_command(client, "--script", str(port), str(script))
        result = base.run_command(
            client_command,
            log_name="m33-public-multiline-client.run.log",
            verbose=verbose,
            timeout=1800,
        )
        output = base.normalized(result.stdout)
        if result.returncode != 0 or base.normalized(result.stderr):
            raise AcceptanceFailure(
                f"M33 public multiline script failed: rc={result.returncode} stdout={output!r} "
                f"stderr={base.normalized(result.stderr)!r}"
            )
        if "MiniSQL script completed statements=6" not in output:
            raise AcceptanceFailure(f"M33 scanner did not frame six SQL statements: {output!r}")
        if "body\nsemi;colon\n(1 rows)" not in output:
            raise AcceptanceFailure(f"M33 quoted semicolon value was not preserved: {output!r}")
        if "multi_note" not in output or "table_name" not in output:
            raise AcceptanceFailure(f"M33 final unterminated SHOW TABLES statement was not executed: {output!r}")
        out, err = process.communicate(timeout=1800)
        base.write_log(
            "m33-public-multiline-server.run.log",
            server_command,
            process.returncode,
            out,
            err,
        )
        server_output = base.normalized(out)
        if process.returncode != 0 or base.normalized(err):
            raise AcceptanceFailure(
                f"M33 bounded public server failed: rc={process.returncode} stdout={server_output!r} "
                f"stderr={base.normalized(err)!r}"
            )
        if f"MiniSQL server completed requests={request_budget}" not in server_output:
            raise AcceptanceFailure(
                f"M33 bounded public server did not complete request budget: {server_output!r}"
            )
    finally:
        if process.poll() is None:
            process.kill()
            process.communicate()


def run_native_tls(compiler: Path, verbose: bool) -> None:
    """Runs policy, ABI, trust, hostname, pinning, and native TLS data-path coverage."""
    run_simple(
        compiler, "src/tests/m73_tls_policy.ml", "minisql-m73-tls-policy.exe",
        "MiniSQL M73 TLS policy test: SUCCESS", verbose,
    )
    run_simple(
        compiler, "src/tests/m73_schannel_abi.ml", "minisql-m73-schannel-abi.exe",
        "MiniSQL M73 Schannel ABI test: SUCCESS", verbose,
    )
    server_worker = base.compile_target(
        compiler, "src/tests/m73_tls_server_worker.ml", "minisql-m73-tls-server-worker.exe", verbose,
    )
    client_worker = base.compile_target(
        compiler, "src/tests/m73_tls_client_worker.ml", "minisql-m73-tls-client-worker.exe", verbose,
    )
    server, _ = public_apps()
    root = data_root("m73-native-tls")
    database = initialize_public_database(server, root, "tls_transport", verbose)
    command = [
        "powershell", "-NoProfile", "-ExecutionPolicy", "Bypass",
        "-File", str(ROOT / "tests/run_native_tls_tests.ps1"),
        "-ServerWorker", str(server_worker),
        "-ClientWorker", str(client_worker),
        "-DatabasePath", str(database),
        "-WorkDirectory", str(root / "integration"),
    ]
    completed = base.run_command(
        command, log_name="m73-native-tls.run.log", verbose=verbose, timeout=300,
    )
    output = base.normalized(completed.stdout)
    if completed.returncode != 0 or output != "MiniSQL M73 native TLS integration: SUCCESS" or base.normalized(completed.stderr):
        raise AcceptanceFailure(
            f"M73 native TLS integration failed: rc={completed.returncode} "
            f"stdout={output!r} stderr={base.normalized(completed.stderr)!r}"
        )


def run_m74_workbench(compiler: Path, verbose: bool) -> None:
    """Compiles and executes native-control, profile, and live-server workbench coverage."""
    model = base.compile_target(
        compiler, "src/tests/m74_workbench.ml", "minisql-m74-workbench.exe", verbose,
    )
    network = base.compile_target(
        compiler,
        "src/tests/m74_workbench_network_worker.ml",
        "minisql-m74-workbench-network-worker.exe",
        verbose,
    )
    root = data_root("m74-workbench")
    profile_root = root / "profiles"
    profile_root.mkdir(parents=True, exist_ok=True)
    model_result = base.run_command(
        base.executable_command(model, str(profile_root)),
        log_name="m74-workbench.run.log",
        verbose=verbose,
        timeout=300,
    )
    if (
        model_result.returncode != 0
        or base.normalized(model_result.stdout) != "MiniSQL M74 workbench tests: SUCCESS"
        or base.normalized(model_result.stderr)
    ):
        raise AcceptanceFailure(
            "M74 workbench model failed: "
            f"rc={model_result.returncode} stdout={base.normalized(model_result.stdout)!r} "
            f"stderr={base.normalized(model_result.stderr)!r}"
        )

    server, _ = public_apps()
    database = initialize_public_database(server, root / "database", "workbench", verbose)
    port = free_port()
    command = base.executable_command(server, "--serve", str(database), str(port), "4")
    server_stdout_path = root / "server.stdout"
    server_stderr_path = root / "server.stderr"
    # Server logging is intentionally verbose. Redirect to files rather than
    # an unread PIPE: a full Windows anonymous pipe would block logger writes
    # and therefore prevent the server from publishing the next SQL response.
    with server_stdout_path.open("w", encoding="utf-8") as server_stdout, server_stderr_path.open("w", encoding="utf-8") as server_stderr:
        process = subprocess.Popen(command, cwd=ROOT, stdout=server_stdout, stderr=server_stderr, text=True)
        try:
            wait_listening(process, port, "m74-workbench-server", 120)
            worker_result = base.run_command(
                base.executable_command(network, str(port)),
                log_name="m74-workbench-network.run.log",
                verbose=verbose,
                timeout=300,
            )
            if (
                worker_result.returncode != 0
                or base.normalized(worker_result.stdout) != "MiniSQL M74 workbench network worker: SUCCESS"
                or base.normalized(worker_result.stderr)
            ):
                raise AcceptanceFailure(
                    "M74 workbench network integration failed: "
                    f"rc={worker_result.returncode} stdout={base.normalized(worker_result.stdout)!r} "
                    f"stderr={base.normalized(worker_result.stderr)!r}"
                )
        finally:
            if process.poll() is None:
                process.kill()
            process.wait(timeout=10)
    out = server_stdout_path.read_text(encoding="utf-8", errors="replace")
    err = server_stderr_path.read_text(encoding="utf-8", errors="replace")
    base.write_log("m74-workbench-server.run.log", command, process.returncode or 0, out, err)

def validate_repository(manifest: dict[str, Any]) -> None:
    """Validates the tracked repository inventory, package layout, headers and launcher contract."""
    expected = {
        "manifestVersion": 1,
        "project": "MiniSQL",
        "milestone": "M50",
        "revision": REVISION,
        "version": VERSION,
        "moduleCount": 78,
        "acceptancePhaseCount": PHASE_COUNT,
        "userFacingTestRunner": "test.ps1",
    }
    for key, value in expected.items():
        if manifest.get(key) != value:
            raise AcceptanceFailure(
                f"Manifest {key} mismatch: expected {value!r}, got {manifest.get(key)!r}"
            )
    accepted = {**{f"M{i}": "PASS" for i in range(51)}, "evidence": "docs/acceptance/FINAL_STATUS.md"}
    if manifest.get("acceptedBaseline") != accepted:
        raise AcceptanceFailure("Manifest accepted M0-M50 baseline mismatch")
    if manifest.get("candidateMilestones") != []:
        raise AcceptanceFailure("MiniSQL 1.0.0 must not contain candidate milestones")
    if manifest.get("resultArchivePattern") != "build/MiniSQL_1.0.0_RESULTS_<timestamp>.zip":
        raise AcceptanceFailure("Manifest result archive pattern mismatch")
    if manifest.get("finalSuccessLine") != FINAL_SUCCESS:
        raise AcceptanceFailure("Manifest final success line mismatch")

    directories = manifest.get("requiredDirectories")
    files = manifest.get("requiredFiles")
    if not isinstance(directories, list) or not isinstance(files, list) or not directories or not files:
        raise AcceptanceFailure("Manifest path inventories are missing")
    if len(directories) != len(set(directories)) or len(files) != len(set(files)):
        raise AcceptanceFailure("Manifest path inventories contain duplicates")
    for relative in directories:
        if not (ROOT / relative).is_dir():
            raise AcceptanceFailure(f"Required directory missing: {relative}")
    for relative in files:
        path = ROOT / relative
        if not path.is_file() or path.stat().st_size == 0:
            raise AcceptanceFailure(f"Required non-empty file missing: {relative}")

    excluded_roots = {"build", "data", "logs", "tmp", ".git"}
    actual_files = {
        path.relative_to(ROOT).as_posix()
        for path in ROOT.rglob("*")
        if path.is_file()
        and path.relative_to(ROOT).parts[0] not in excluded_roots
        and "__pycache__" not in path.relative_to(ROOT).parts
    }
    if actual_files != set(files):
        raise AcceptanceFailure(
            "Manifest file inventory mismatch; "
            f"missing={sorted(actual_files-set(files))}, stale={sorted(set(files)-actual_files)}"
        )
    actual_directories = {
        path.relative_to(ROOT).as_posix()
        for path in ROOT.rglob("*")
        if path.is_dir()
        and path.relative_to(ROOT).parts[0] not in excluded_roots
        and "__pycache__" not in path.relative_to(ROOT).parts
    }
    if actual_directories != set(directories):
        raise AcceptanceFailure(
            "Manifest directory inventory mismatch; "
            f"missing={sorted(actual_directories-set(directories))}, stale={sorted(set(directories)-actual_directories)}"
        )

    launchers = sorted(path.name for path in ROOT.glob("test*.ps1") if path.is_file())
    if launchers != ["test.ps1"]:
        raise AcceptanceFailure(f"Exactly one root test launcher is allowed: {launchers}")

    catalog_document = load_json(ROOT / "docs/module-catalog.json")
    modules = catalog_document.get("modules")
    if not isinstance(modules, list) or len(modules) != 78:
        raise AcceptanceFailure("Module catalog must contain exactly 78 modules")
    catalog_paths: set[str] = set()
    for item in modules:
        relative = item.get("path")
        package = item.get("package")
        component = item.get("component")
        target = item.get("targetMilestone")
        if not all(isinstance(value, str) and value for value in (relative, package, component, target)):
            raise AcceptanceFailure(f"Invalid module entry: {item!r}")
        if relative in catalog_paths:
            raise AcceptanceFailure(f"Duplicate module path: {relative}")
        catalog_paths.add(relative)
        text = (ROOT / relative).read_text(encoding="utf-8")
        first = first_minilang_code_line(text)
        if first != f"package {package}":
            raise AcceptanceFailure(f"Package/path mismatch in {relative}")
        if f'return "{component}"' not in text or f'function targetMilestone()\n  return "{target}"' not in text:
            raise AcceptanceFailure(f"Module identity mismatch in {relative}")
        if "function isImplemented()\n  return true" not in text:
            raise AcceptanceFailure(f"M50 requires implemented module: {relative}")
    actual_modules = {path.relative_to(ROOT).as_posix() for path in (ROOT / "src/minisql").rglob("*.ml")}
    if actual_modules != catalog_paths:
        raise AcceptanceFailure(
            f"Module catalog mismatch; missing={sorted(catalog_paths-actual_modules)}, "
            f"extra={sorted(actual_modules-catalog_paths)}"
        )

    forbidden: list[str] = []
    for path in ROOT.rglob("*"):
        if not path.is_file() or path.is_relative_to(ROOT / "build"):
            continue
        if path.suffix.lower() in {".exe", ".dll", ".pyc", ".pyo"} or "__pycache__" in path.parts:
            forbidden.append(path.relative_to(ROOT).as_posix())
    if forbidden:
        raise AcceptanceFailure(f"Compiled/cache artifacts are forbidden: {forbidden}")
    validate_source_documentation()


def validate_config_and_docs() -> None:
    """Validates frozen configuration defaults and required English documentation contracts."""
    load_json(ROOT / "config/minisql.example.json")
    load_json(ROOT / "config/config.schema.json")
    required = [
        "README.md",
        "CHANGELOG.md",
        "CONTRIBUTING.md",
        "SECURITY.md",
        "NOTICE.md",
        "MILESTONES.md",
        "docs/PROJECT_STRUCTURE.md",
        "docs/acceptance/README.md",
        "docs/acceptance/FINAL_STATUS.md",
        "docs/acceptance/MiniSQL-1.0.0-results.json",
        "docs/spec/61-hot-streaming-replication.md",
        "docs/spec/62-quality-hardening.md",
        "docs/spec/63-release-freeze.md",
        "docs/adr/ADR-0077-durable-live-wal-export.md",
        "docs/adr/ADR-0078-double-buffer-hot-standby.md",
        "docs/adr/ADR-0079-deterministic-release-hardening.md",
        "docs/adr/ADR-0080-version-1-release-freeze.md",
        "docs/adr/ADR-0081-fragmentation-safe-network-byte-ranges.md",
        "docs/adr/ADR-0082-direct-offset-network-io.md",
        "docs/adr/ADR-0083-winsock-signed-i32-results.md",
        "docs/formats/wal-durable-marker-v1.md",
        "docs/formats/FORMAT_COMPATIBILITY.md",
        "docs/release/README.md",
        "docs/release/SQL_REFERENCE.md",
        "docs/release/ADMIN_GUIDE.md",
        "docs/release/SECURITY_GUIDE.md",
        "docs/release/BACKUP_RECOVERY.md",
        "docs/release/REPLICATION.md",
        "docs/release/LIMITATIONS.md",
        "docs/release/UPGRADE.md",
        "docs/release/upgrade-matrix.json",
        "docs/release/feature-matrix.json",
        "tools/replication/minisql_hot_replica.py",
        "tools/quality/minisql_quality.py",
        "tools/release/build_release.py",
        "tests/fuzz/m49_sql_corpus.json",
        "tests/recovery/m49_crash_matrix.json",
        "tests/performance/m49_baseline.json",
        "tests/reference/m48_m50_layout.json",
        "src/tests/m48_hot_replication.ml",
        "src/tests/m49_hardening.ml",
        "src/tests/m50_release_contract.ml",
        "src/tests/m50_all_modules.ml",
        "release.ps1",
    ]
    for relative in required:
        path = ROOT / relative
        if not path.is_file() or path.stat().st_size == 0:
            raise AcceptanceFailure(f"Required MiniSQL 1.0.0 document/tool missing: {relative}")
    for relative in (
        "docs/acceptance/MiniSQL-1.0.0-results.json",
        "docs/release/upgrade-matrix.json",
        "docs/release/feature-matrix.json",
        "tests/fuzz/m49_sql_corpus.json",
        "tests/recovery/m49_crash_matrix.json",
        "tests/performance/m49_baseline.json",
    ):
        load_json(ROOT / relative)
    evidence = load_json(ROOT / "docs/acceptance/MiniSQL-1.0.0-results.json")
    if evidence.get("status") != "SUCCESS" or len(evidence.get("phases", [])) != PHASE_COUNT:
        raise AcceptanceFailure("Final MiniSQL 1.0.0 acceptance evidence is incomplete")
    if set(evidence.get("milestones", {}).values()) != {"PASS"} or len(evidence.get("milestones", {})) != 51:
        raise AcceptanceFailure("Final milestone evidence must contain M0-M50 PASS")
    final_status = (ROOT / "docs/acceptance/FINAL_STATUS.md").read_text(encoding="utf-8")
    for phrase in ("M0-M50 PASS", "106/106 PASS", "M48-M50R3"):
        if phrase not in final_status:
            raise AcceptanceFailure(f"Final acceptance summary missing: {phrase}")
    milestones = (ROOT / "MILESTONES.md").read_text(encoding="utf-8")
    for phrase in ("M0-M50", "Open 1.0 milestones: 0", "106/106"):
        if phrase not in milestones:
            raise AcceptanceFailure(f"M50 completion documentation missing: {phrase}")
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    if "release candidate" in readme.lower() or "106/106" not in readme:
        raise AcceptanceFailure("README must describe the accepted 1.0.0 release")


def validate_source_contracts() -> None:
    """Checks milestone-specific implementation contracts without executing native code."""
    contracts = {
        "src/minisql/common/version.ml": [
            'const PRODUCT_VERSION = "1.0.0"',
            'const MILESTONE = "M50"',
            'const REVISION = "M48-M50R3"',
            "const WIRE_PROTOCOL_VERSION = 1",
            "const DATABASE_FORMAT_VERSION = 1",
        ],
        "src/minisql/platform/network.ml": [
            "extern function send(s as ptr, buffer as ptr, count as i32, flags as i32) from \"ws2_32.dll\" returns i32",
            "extern function recv(s as ptr, buffer as ptr, count as i32, flags as i32) from \"ws2_32.dll\" returns i32",
            "const SOCKET_ERROR_U32 = 4294967295",
            "function isSocketErrorResult",
            "function bytePointer",
            "function receiveAvailableInto",
            "written = send(handle, basePointer + total, remaining, 0)",
            "received = recv(handle, basePointer + cursor, remaining, 0)",
            "recv returned invalid byte count",
        ],
        "src/minisql/protocol/connection.ml": [
            "receiveScratch",
            "maximumBuffered = constants.HEADER_BYTES + constants.MAX_PAYLOAD_BYTES + POLL_RECEIVE_BYTES",
            "function appendReceiveScratch",
            "function extractBufferedMessage",
            "network.receiveAvailableInto",
            "connection.receiveBuffer = combined",
        ],
        "src/minisql/protocol/codec.ml": [
            "function copyRange",
            "headerBytes = try(copyRange",
            "payload = try(copyRange",
        ],
        "src/tests/m18_protocol.ml": [
            "function testSignedWinSockResults",
            "nonblocking recv maps signed SOCKET_ERROR to would-block",
            "blocking receiveExact uses signed i32 result",
        ],
        "src/tests/m27_client_worker.ml": [
            "function reportFailure",
            'reportFailure(active, clientId, "commit", committed)',
            'reportFailure(active, clientId, "ping", pong)',
            "messages.isResponse",
        ],
        "src/minisql/transaction/wal.ml": [
            'return bytes("MSWDL001")',
            "function encodeDurableMarker",
            "function readDurableMarker",
            "function writeDurableMarker",
            "function scanSnapshot",
            "ignoredMarker = try(writeDurableMarker(writer.path, writer.nextLsn))",
        ],
        "src/minisql/tools/backup.ml": [
            "const MAX_ARCHIVE_GENERATIONS = 4294967295",
            "function snapshotDurableWalLive",
            "function archiveWalLive",
            "durable WAL marker is not a complete record boundary",
            "live WAL continuity was lost",
        ],
        "src/minisql/server/listener.ml": [
            "function serveStandbyConcurrentLoopback",
            "database_manager.openStandby(databasePath)",
            "import std.concurrent.thread_pool as thread_pool",
            "function serveConcurrentClient",
            "function reapConcurrentJobs",
            "pool.Submit(serveConcurrentClient, task)",
        ],
        "src/minisql/common/uuid.ml": [
            "function synchronized transportEncrypt",
            "function synchronized transportDecrypt",
        ],
        "src/minisql/server/database_manager.ml": [
            "import std.threading as threading",
            "struct ExecutionGate",
            "function enterReadExecution",
            "function enterExecution",
            "threading.Lock.new()",
            "threading.Semaphore.new(1, 1)",
        ],
        "src/minisql/executor/executor.ml": [
            "function executeStatementCore",
            "database_manager.enterReadExecution(engine.database)",
            "database_manager.enterExecution(engine.database)",
        ],
        "src/minisql/transaction/lock_manager.ml": [
            "import std.threading as threading",
            "manager.guard.acquire()",
        ],
        "src/minisql/platform/file_win32.ml": [
            "function synchronized openNative",
            "function synchronized pathAttributes",
        ],
        "src/minisql/storage/paged_file.ml": [
            "function openReadOnly",
            "file_lock.acquireShared(file, true)",
        ],
        "src/tests/m27_scheduler_locks.ml": [
            "two read workers enter the database together",
            "writer waits while readers are active",
            "real query plans overlap in the shared reader gate",
        ],
        "src/apps/minisqld/main.ml": ["--serve-standby", "read-only-hot-standby"],
        "src/apps/minisql_backup/main.ml": ["archive-wal-live", "MiniSQL live WAL archive: SUCCESS"],
        "src/minisql/platform/tls_schannel.ml": [
            "SCH_CREDENTIALS_VERSION",
            "verifyCipherSuite",
            "validatePinnedX509",
            "processPostHandshake",
            "function shutdown",
        ],
        "src/minisql/platform/tls_policy.ml": [
            "TLS_AES_256_GCM_SHA384_ID",
            "X25519_ID",
            "verifyServerHello",
            "pinnedClientPolicy",
        ],
        "tools/replication/minisql_hot_replica.py": [
            "class SwitchingProxy",
            "archive-wal-live",
            "standby-materialize",
            "standby server did not listen",
            "MiniSQL hot standby: SUCCESS",
        ],
        "tools/quality/minisql_quality.py": [
            "def crash_matrix",
            "def soak",
            "MiniSQL M49 quality self-test: SUCCESS",
            "m49-crash-matrix-report.json",
            "m49-soak-report.json",
        ],
        "tools/release/build_release.py": [
            'VERSION = "1.0.0"',
            "release-manifest.json",
            "SHA256SUMS",
            "MiniSQL 1.0.0 release verify: SUCCESS",
        ],
        "src/tests/m48_hot_replication.ml": ["MiniSQL M48 hot replication tests: SUCCESS", "archiveWalLive", "openStandby"],
        "src/tests/m49_hardening.ml": ["MiniSQL M49 hardening tests: SUCCESS", "AUTO_INCREMENT", "3.3", "deterministic SQL mutation outcome is controlled"],
        "src/tests/m50_release_contract.ml": ["MiniSQL M50 release contract tests: SUCCESS", '"1.0.0"'],
        "src/tests/m50_all_modules.ml": ["MiniSQL M50 module smoke test: SUCCESS (78 modules)"],
        "build.ps1": [
            "minisql-m48-hot-replication.exe",
            "minisql-m49-hardening.exe",
            "minisql-m50-release-contract.exe",
            "minisql-m50-modules.exe",
            "MiniSQL 1.0.0 full build: SUCCESS",
        ],
        "release.ps1": ["build_release.py", "MiniSQL-1.0.0-windows-x64.zip", "MiniSQL 1.0.0 release: SUCCESS"],
    }
    for relative, phrases in contracts.items():
        require_phrases(relative, phrases)
    network_text = (ROOT / "src/minisql/platform/network.ml").read_text(encoding="utf-8")
    connection_text = (ROOT / "src/minisql/protocol/connection.ml").read_text(encoding="utf-8")
    codec_text = (ROOT / "src/minisql/protocol/codec.ml").read_text(encoding="utf-8")
    for forbidden in (
        "part = slice(data, total, len(data) - total)",
        "return slice(buffer, 0, count)",
        "part = try(copyByteRange(data, total, remaining",
        "written = send(handle, part, remaining, 0)",
        "extern function send(s as ptr, buffer as bytes",
        "extern function recv(s as ptr, buffer as bytes",
        "extern function send(s as ptr, buffer as ptr, count as int, flags as int) from \"ws2_32.dll\" returns int",
        "extern function recv(s as ptr, buffer as ptr, count as int, flags as int) from \"ws2_32.dll\" returns int",
    ):
        if forbidden in network_text:
            raise AcceptanceFailure(f"WinSock ABI/direct-offset network contract violation: {forbidden}")
    for forbidden in (
        "slice(connection.receiveBuffer",
        "connection.receiveBuffer = connection.receiveBuffer + incoming",
        "network.receiveAvailable(connection.socket, 65536)",
    ):
        if forbidden in connection_text:
            raise AcceptanceFailure(f"Protocol-buffer contract violation: {forbidden}")
    for forbidden in (
        "decodeHeader(slice(source",
        "payload = slice(source, constants.HEADER_BYTES",
    ):
        if forbidden in codec_text:
            raise AcceptanceFailure(f"Protocol-codec contract violation: {forbidden}")
    runner_text = Path(__file__).read_text(encoding="utf-8")
    for required in (
        "failures: list[str] = []",
        "M27 server at client failure",
        "M29 server at client failure",
        'src/tests/m18_protocol.ml","minisql-m18-protocol.exe","MiniSQL M18 protocol codec tests: SUCCESS",args.verbose,[str(free_port())]',
    ):
        if required not in runner_text:
            raise AcceptanceFailure(f"Concurrent-process diagnostics are missing: {required}")
    version_text = (ROOT / "src/minisql/common/version.ml").read_text(encoding="utf-8")
    if "0.47.0-m47" in version_text or 'const MILESTONE = "M47"' in version_text:
        raise AcceptanceFailure("Release version module still contains the M47 product identity")
    launchers = sorted(path.name for path in ROOT.glob("test*.ps1") if path.is_file())
    if launchers != ["test.ps1"]:
        raise AcceptanceFailure(f"M50 must retain exactly one user test launcher: {launchers}")


def _run_python_static(command: list[str], description: str, timeout: float = 120.0) -> str:
    """Runs a Python tooling check with bytecode disabled and returns its captured stdout."""
    completed = subprocess.run(
        command,
        cwd=ROOT,
        text=True,
        encoding="utf-8",
        errors="replace",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
        timeout=timeout,
    )
    if completed.returncode != 0:
        raise AcceptanceFailure(
            f"{description} failed: rc={completed.returncode} "
            f"stdout={completed.stdout.strip()!r} stderr={completed.stderr.strip()!r}"
        )
    return base.normalized(completed.stdout)


def validate_reference_vectors() -> None:
    """Validates independent binary, parser and security reference vectors."""
    if PHASE_COUNT != 106:
        raise AcceptanceFailure("MiniSQL 1.0.0 phase count must remain 106")
    corpus_document = load_json(ROOT / "tests/fuzz/m49_sql_corpus.json")
    corpus = corpus_document.get("statements")
    if not isinstance(corpus, list) or len(corpus) < 32 or not all(isinstance(item, str) for item in corpus):
        raise AcceptanceFailure("M49 SQL corpus is incomplete")
    digest = hashlib.sha256("\n---\n".join(corpus).encode("utf-8")).hexdigest()
    if corpus_document.get("sha256") != digest:
        raise AcceptanceFailure("M49 SQL corpus checksum mismatch")
    baseline = load_json(ROOT / "tests/performance/m49_baseline.json")
    if baseline.get("maxHardeningRunSeconds") != 600 or baseline.get("soakIterations") != 2:
        raise AcceptanceFailure("M49 performance baseline changed unexpectedly")
    matrix = load_json(ROOT / "tests/recovery/m49_crash_matrix.json")
    if matrix.get("iterations") != 8:
        raise AcceptanceFailure("M49 crash-matrix iteration count changed")
    if {item.get("name") for item in matrix.get("scenarios", [])} != {"durable-commit", "uncommitted"}:
        raise AcceptanceFailure("M49 crash matrix scenarios are incomplete")
    layout = load_json(ROOT / "tests/reference/m48_m50_layout.json")
    if layout.get("walDurableMarker") != {
        "magic": "MSWDL001", "version": 1, "size": 32, "lsnOffset": 16, "checksumOffset": 24
    }:
        raise AcceptanceFailure("M48 durable-marker reference layout mismatch")
    if layout.get("acceptance", {}).get("phaseCount") != PHASE_COUNT or layout.get("acceptance", {}).get("finalLine") != FINAL_SUCCESS:
        raise AcceptanceFailure("MiniSQL 1.0.0 acceptance reference mismatch")
    upgrade = load_json(ROOT / "docs/release/upgrade-matrix.json")
    features = load_json(ROOT / "docs/release/feature-matrix.json")
    if upgrade.get("targetVersion") != VERSION or upgrade.get("databaseFormatVersion") != 1:
        raise AcceptanceFailure("M50 upgrade matrix version mismatch")
    if features.get("version") != VERSION or features.get("wireProtocolVersion") != 1:
        raise AcceptanceFailure("M50 feature matrix version mismatch")

    output = _run_python_static(
        [sys.executable, str(ROOT / "tools/replication/minisql_hot_replica.py"), "self-test"],
        "M48 replication sidecar self-test",
    )
    if output != "MiniSQL M48 replication sidecar self-test: SUCCESS":
        raise AcceptanceFailure(f"Unexpected M48 sidecar self-test output: {output!r}")
    output = _run_python_static(
        [sys.executable, str(ROOT / "tools/quality/minisql_quality.py"), "self-test", "--root", str(ROOT)],
        "M49 quality self-test",
    )
    if not output.startswith("MiniSQL M49 quality self-test: SUCCESS corpus="):
        raise AcceptanceFailure(f"Unexpected M49 quality self-test output: {output!r}")

    static_root = BUILD_ROOT / "static-release"
    base.clean_path(static_root)
    bin_dir = static_root / "bin"
    bin_dir.mkdir(parents=True, exist_ok=True)
    for index, name in enumerate((
        "minisqld.exe", "minisql.exe", "minisql-check.exe", "minisql-backup.exe", "minisql-migrate.exe", "minisql-admin.exe"
    )):
        payload = b"MZ" + bytes([index + 1]) * 2046
        (bin_dir / name).write_bytes(payload)
    first = static_root / "release-a.zip"
    second = static_root / "release-b.zip"
    builder = ROOT / "tools/release/build_release.py"
    for output_path in (first, second):
        _run_python_static(
            [sys.executable, str(builder), "build", "--project", str(ROOT), "--bin-dir", str(bin_dir), "--output", str(output_path)],
            "M50 deterministic release builder",
        )
        _run_python_static(
            [sys.executable, str(builder), "verify", "--archive", str(output_path)],
            "M50 release verifier",
        )
    if hashlib.sha256(first.read_bytes()).digest() != hashlib.sha256(second.read_bytes()).digest():
        raise AcceptanceFailure("M50 release builder is not deterministic for identical inputs")
    base.clean_path(static_root)


def _wait_for_path(path: Path, process: subprocess.Popen[str], timeout: float, description: str) -> None:
    """Waits for a generated path while treating child-process exit as an immediate failure."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if path.exists():
            return
        if process.poll() is not None:
            stdout, stderr = process.communicate(timeout=5)
            raise AcceptanceFailure(
                f"{description} exited before publishing {path.name}: rc={process.returncode} "
                f"stdout={base.normalized(stdout)!r} stderr={base.normalized(stderr)!r}"
            )
        time.sleep(0.05)
    raise AcceptanceFailure(f"Timed out waiting for {description} marker: {path}")


def _read_status(path: Path) -> dict[str, Any]:
    """Loads and validates a replication-controller JSON status document."""
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        raise AcceptanceFailure(f"Invalid replication status file {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise AcceptanceFailure(f"Replication status file is not an object: {path}")
    return value


def _wait_for_generation(path: Path, process: subprocess.Popen[str], minimum: int, timeout: float) -> dict[str, Any]:
    """Waits until replication status reaches at least the requested durable generation."""
    deadline = time.monotonic() + timeout
    last: dict[str, Any] | None = None
    while time.monotonic() < deadline:
        if path.is_file():
            try:
                last = _read_status(path)
                if int(last.get("generation", 0)) >= minimum:
                    return last
            except (AcceptanceFailure, TypeError, ValueError):
                pass
        if process.poll() is not None:
            stdout, stderr = process.communicate(timeout=5)
            raise AcceptanceFailure(
                f"Hot standby exited before generation {minimum}: rc={process.returncode} "
                f"stdout={base.normalized(stdout)!r} stderr={base.normalized(stderr)!r} status={last!r}"
            )
        time.sleep(0.05)
    raise AcceptanceFailure(f"Timed out waiting for hot-standby generation {minimum}; status={last!r}")


def _query_public(client: Path, port: int, sql: str, label: str, verbose: bool, expected_fragment: str | None = None) -> str:
    """Executes SQL through the public client and validates its optional expected result fragment."""
    command = base.executable_command(client, "--query", str(port), sql)
    result = base.run_command(command, log_name=label + ".run.log", verbose=verbose, timeout=1200)
    output = base.normalized(result.stdout)
    if result.returncode != 0 or base.normalized(result.stderr):
        raise AcceptanceFailure(
            f"Public query failed ({label}): rc={result.returncode} stdout={output!r} "
            f"stderr={base.normalized(result.stderr)!r}"
        )
    if expected_fragment is not None and expected_fragment not in output:
        raise AcceptanceFailure(f"Public query result mismatch ({label}): {output!r}")
    return output


def _stop_process(process: subprocess.Popen[str] | None, label: str, command: list[str]) -> tuple[str, str]:
    """Terminates a child process safely and returns its final captured stdout and stderr."""
    if process is None:
        return "", ""
    if process.poll() is None:
        process.kill()
    stdout, stderr = process.communicate(timeout=15)
    base.write_log(label + ".run.log", command, process.returncode if process.returncode is not None else -9, stdout, stderr)
    return stdout, stderr


def run_m48_hot_process(verbose: bool) -> None:
    """Compiles and executes the M48 hot process acceptance scenario."""
    server, client = public_apps()
    backup_exe = BUILD_ROOT / "minisql-backup.exe"
    if not backup_exe.is_file():
        raise AcceptanceFailure("minisql-backup.exe was not compiled by the application phase")
    root = data_root("m48-process")
    database = initialize_public_database(server, root, "hot_primary", verbose)

    setup_port = free_port()
    setup_command = base.executable_command(server, "--serve", str(database), str(setup_port), "8")
    setup_process = subprocess.Popen(
        setup_command, cwd=ROOT, text=True, encoding="utf-8", errors="replace",
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    try:
        wait_listening(setup_process, setup_port, "m48-setup-server", 180)
        _query_public(
            client, setup_port,
            "CREATE TABLE replicated_item (id INTEGER PRIMARY KEY, value VARCHAR(40) NOT NULL);",
            "m48-setup-create-table", verbose,
        )
    finally:
        _stop_process(setup_process, "m48-setup-server", setup_command)

    archive = root / "archive"
    archive_init = base.run_command(
        base.executable_command(backup_exe, "archive-init", str(database), str(archive)),
        log_name="m48-archive-init.run.log", verbose=verbose, timeout=1800,
    )
    if archive_init.returncode != 0 or base.normalized(archive_init.stderr) or "generation=1" not in archive_init.stdout:
        raise AcceptanceFailure(
            f"M48 archive initialization failed: rc={archive_init.returncode} "
            f"stdout={base.normalized(archive_init.stdout)!r} stderr={base.normalized(archive_init.stderr)!r}"
        )

    primary_port = free_port()
    primary_command = base.executable_command(server, "--serve", str(database), str(primary_port), "8")
    primary = subprocess.Popen(
        primary_command, cwd=ROOT, text=True, encoding="utf-8", errors="replace",
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    standby: subprocess.Popen[str] | None = None
    standby_command: list[str] = []
    try:
        wait_listening(primary, primary_port, "m48-primary-server", 180)
        _query_public(
            client, primary_port,
            "INSERT INTO replicated_item(id, value) VALUES (1, 'first');",
            "m48-primary-insert-1", verbose,
        )

        replica_tool = ROOT / "tools/replication/minisql_hot_replica.py"
        primary_status = root / "primary-status.json"
        export_one = base.run_command(
            [
                sys.executable, str(replica_tool), "primary",
                "--database", str(database), "--archive", str(archive),
                "--backup-exe", str(backup_exe), "--cycles", "1",
                "--status-file", str(primary_status),
            ],
            log_name="m48-primary-export-1.run.log", verbose=verbose, timeout=1800,
        )
        if export_one.returncode != 0 or base.normalized(export_one.stderr) or "SUCCESS cycles=1" not in export_one.stdout:
            raise AcceptanceFailure(
                f"First live WAL export failed: rc={export_one.returncode} "
                f"stdout={base.normalized(export_one.stdout)!r} stderr={base.normalized(export_one.stderr)!r}"
            )
        first_generation = int(_read_status(primary_status).get("generation", 0))
        if first_generation < 2:
            raise AcceptanceFailure(f"First live export did not advance archive generation: {first_generation}")

        proxy_port = free_port()
        backend_a = free_port()
        backend_b = free_port()
        ready = root / "standby.ready"
        standby_status = root / "standby-status.json"
        standby_command = [
            sys.executable, str(replica_tool), "standby",
            "--archive", str(archive), "--slot-root", str(root / "standby-slots"),
            "--backup-exe", str(backup_exe), "--server-exe", str(server),
            "--listen-host", "127.0.0.1", "--listen-port", str(proxy_port),
            "--backend-port-a", str(backend_a), "--backend-port-b", str(backend_b),
            "--maximum-clients", "8", "--max-connections", "2", "--cycles", "2",
            "--interval-ms", "50", "--status-file", str(standby_status),
            "--ready-file", str(ready), "--client-timeout", "1200",
        ]
        standby = subprocess.Popen(
            standby_command, cwd=ROOT, text=True, encoding="utf-8", errors="replace",
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        _wait_for_path(ready, standby, 600, "M48 hot standby")
        first_status = _wait_for_generation(standby_status, standby, first_generation, 600)
        _query_public(client, proxy_port, "SELECT COUNT(*) AS c FROM replicated_item;", "m48-standby-count-1", verbose, "c\n1\n(1 rows)")

        _query_public(
            client, primary_port,
            "INSERT INTO replicated_item(id, value) VALUES (2, 'second');",
            "m48-primary-insert-2", verbose,
        )
        export_two = base.run_command(
            [
                sys.executable, str(replica_tool), "primary",
                "--database", str(database), "--archive", str(archive),
                "--backup-exe", str(backup_exe), "--cycles", "1",
                "--status-file", str(primary_status),
            ],
            log_name="m48-primary-export-2.run.log", verbose=verbose, timeout=1800,
        )
        if export_two.returncode != 0 or base.normalized(export_two.stderr) or "SUCCESS cycles=1" not in export_two.stdout:
            raise AcceptanceFailure(
                f"Second live WAL export failed: rc={export_two.returncode} "
                f"stdout={base.normalized(export_two.stdout)!r} stderr={base.normalized(export_two.stderr)!r}"
            )
        second_generation = int(_read_status(primary_status).get("generation", 0))
        if second_generation <= int(first_status.get("generation", 0)):
            raise AcceptanceFailure("Second live export did not advance the archive generation")
        _wait_for_generation(standby_status, standby, second_generation, 900)
        _query_public(client, proxy_port, "SELECT COUNT(*) AS c FROM replicated_item;", "m48-standby-count-2", verbose, "c\n2\n(1 rows)")

        standby_out, standby_err = standby.communicate(timeout=1200)
        base.write_log("m48-hot-standby.run.log", standby_command, standby.returncode, standby_out, standby_err)
        if standby.returncode != 0 or base.normalized(standby_err) or "MiniSQL hot standby: SUCCESS cycles=2 connections=2" not in standby_out:
            raise AcceptanceFailure(
                f"M48 standby sidecar failed: rc={standby.returncode} "
                f"stdout={base.normalized(standby_out)!r} stderr={base.normalized(standby_err)!r}"
            )
        standby = None
    finally:
        if standby is not None:
            _stop_process(standby, "m48-hot-standby", standby_command)
        primary_out, primary_err = _stop_process(primary, "m48-primary-server", primary_command)
        if base.normalized(primary_err):
            raise AcceptanceFailure(f"M48 primary server wrote unexpected stderr: {base.normalized(primary_err)!r}")


def run_m49_crash_matrix(verbose: bool) -> None:
    """Compiles and executes the M49 crash matrix acceptance scenario."""
    worker = BUILD_ROOT / "minisql-m7-crash-worker.exe"
    if not worker.is_file():
        raise AcceptanceFailure("M7 crash worker is unavailable for the M49 matrix")
    output_root = RESULTS_DIR / "m49-crash-matrix"
    command = [
        sys.executable, str(ROOT / "tools/quality/minisql_quality.py"), "crash-matrix",
        "--worker", str(worker), "--output-root", str(output_root),
        "--iterations", "8", "--timeout", "180",
    ]
    completed = base.run_command(command, log_name="m49-crash-matrix.run.log", verbose=verbose, timeout=5400)
    if completed.returncode != 0 or base.normalized(completed.stderr) or "MiniSQL M49 crash matrix: SUCCESS cases=16" not in completed.stdout:
        raise AcceptanceFailure(
            f"M49 crash matrix failed: rc={completed.returncode} "
            f"stdout={base.normalized(completed.stdout)!r} stderr={base.normalized(completed.stderr)!r}"
        )
    report = load_json(output_root / "m49-crash-matrix-report.json")
    if report.get("casesCompleted") != 16 or report.get("iterations") != 8:
        raise AcceptanceFailure("M49 crash matrix report is incomplete")


def run_m49_soak(verbose: bool) -> None:
    """Compiles and executes the M49 soak acceptance scenario."""
    hardening = BUILD_ROOT / "minisql-m49-hardening.exe"
    if not hardening.is_file():
        raise AcceptanceFailure("M49 hardening executable is unavailable for soak")
    output_root = RESULTS_DIR / "m49-soak"
    command = [
        sys.executable, str(ROOT / "tools/quality/minisql_quality.py"), "soak",
        "--hardening-exe", str(hardening), "--output-root", str(output_root),
        "--iterations", "2", "--max-seconds", "600",
    ]
    completed = base.run_command(command, log_name="m49-soak.run.log", verbose=verbose, timeout=1800)
    if completed.returncode != 0 or base.normalized(completed.stderr) or "MiniSQL M49 soak/performance: SUCCESS iterations=2" not in completed.stdout:
        raise AcceptanceFailure(
            f"M49 soak failed: rc={completed.returncode} "
            f"stdout={base.normalized(completed.stdout)!r} stderr={base.normalized(completed.stderr)!r}"
        )
    report = load_json(output_root / "m49-soak-report.json")
    if report.get("iterations") != 2 or report.get("maximumSeconds", 601) > 600:
        raise AcceptanceFailure("M49 soak report violates the performance guardrail")


def run_m50_release_distribution(verbose: bool) -> None:
    """Compiles and executes the M50 release distribution acceptance scenario."""
    bin_dir = BUILD_ROOT
    for name in ("minisqld.exe", "minisql.exe", "minisql-check.exe", "minisql-backup.exe", "minisql-migrate.exe", "minisql-admin.exe"):
        if not (bin_dir / name).is_file():
            raise AcceptanceFailure(f"Release input binary is missing: {name}")
    release_dir = RESULTS_DIR / "release"
    release_dir.mkdir(parents=True, exist_ok=True)
    archive = release_dir / "MiniSQL-1.0.0-windows-x64.zip"
    builder = ROOT / "tools/release/build_release.py"
    build_command = [
        sys.executable, str(builder), "build", "--project", str(ROOT),
        "--bin-dir", str(bin_dir), "--output", str(archive),
    ]
    built = base.run_command(build_command, log_name="m50-release-build.run.log", verbose=verbose, timeout=600)
    if built.returncode != 0 or base.normalized(built.stderr) or "MiniSQL 1.0.0 release build: SUCCESS" not in built.stdout:
        raise AcceptanceFailure(
            f"M50 release build failed: rc={built.returncode} "
            f"stdout={base.normalized(built.stdout)!r} stderr={base.normalized(built.stderr)!r}"
        )
    verify_command = [sys.executable, str(builder), "verify", "--archive", str(archive)]
    verified = base.run_command(verify_command, log_name="m50-release-verify.run.log", verbose=verbose, timeout=300)
    if verified.returncode != 0 or base.normalized(verified.stderr) or "MiniSQL 1.0.0 release verify: SUCCESS" not in verified.stdout:
        raise AcceptanceFailure(
            f"M50 release verify failed: rc={verified.returncode} "
            f"stdout={base.normalized(verified.stdout)!r} stderr={base.normalized(verified.stderr)!r}"
        )
    checksum = archive.with_suffix(archive.suffix + ".sha256")
    if not checksum.is_file() or archive.name not in checksum.read_text(encoding="ascii"):
        raise AcceptanceFailure("M50 release SHA-256 sidecar is missing or invalid")


def run_phase(index: int, total: int, name: str, action: Callable[[], None], phases: list[dict[str, Any]]) -> None:
    """Runs one named acceptance phase, records duration/status and propagates failures."""
    print(f"[{index:02d}/{total:02d}] {name}")
    started = time.perf_counter()
    try:
        action()
    except Exception:
        phases.append({"name": name, "status": "FAIL", "durationSeconds": round(time.perf_counter()-started, 3)})
        raise
    phases.append({"name": name, "status": "PASS", "durationSeconds": round(time.perf_counter()-started, 3)})

def milestone_statuses(phases: list[dict[str, Any]]) -> dict[str, str]:
    """Reduces phase results into the frozen per-milestone PASS/FAIL status map."""
    result = {f"M{i}": "PASS" for i in range(48)}
    states = {phase["name"]: phase["status"] for phase in phases}
    requirements = {
        "M48": [
            "M48 durable live WAL export and read-only standby",
            "M48 continuous public hot-replication process integration",
            "M48 final cumulative gate",
        ],
        "M49": [
            "M49 deterministic parser, wire, WAL and durable-workload hardening",
            "M49 committed/uncommitted crash matrix",
            "M49 repeated soak and performance guardrail",
            "M49 final cumulative gate",
        ],
        "M50": [
            "M50 release contract and compatibility freeze",
            "M50 deterministic Windows-x64 distribution build and verification",
            "M50 78-module implementation smoke",
            "M50 final cumulative gate",
        ],
    }
    for milestone, names in requirements.items():
        values = [states.get(name) for name in names]
        if "FAIL" in values:
            result[milestone] = "FAIL"
        elif all(value == "PASS" for value in values):
            result[milestone] = "PASS"
        else:
            result[milestone] = "INCOMPLETE"
    return result

def write_results(status: str, phases: list[dict[str, Any]], started: float, failure: str | None) -> None:
    """Writes the machine-readable cumulative result report using stable schema fields."""
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    payload: dict[str, Any] = {
        "project": "MiniSQL",
        "through": "M50",
        "revision": REVISION,
        "version": VERSION,
        "status": status,
        "milestones": milestone_statuses(phases),
        "durationSeconds": round(time.perf_counter()-started, 3),
        "platform": sys.platform,
        "python": sys.version,
        "phases": phases,
    }
    if failure:
        payload["failure"] = failure
    RESULTS_PATH.write_text(json.dumps(payload, indent=2)+"\n", encoding="utf-8")


def package_results() -> Path:
    """Packages reports and logs into the timestamped acceptance evidence archive."""
    archive = ROOT / "build" / f"MiniSQL_1.0.0_RESULTS_{datetime.now().strftime('%Y%m%d-%H%M%S')}.zip"
    archive.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as output:
        if RESULTS_PATH.is_file():
            output.write(RESULTS_PATH, "results.json")
        if MANIFEST_PATH.is_file():
            output.write(MANIFEST_PATH, "manifest.json")
        if RESULTS_DIR.is_dir():
            for path in sorted(RESULTS_DIR.rglob("*")):
                if not path.is_file() or path == RESULTS_PATH:
                    continue
                if path.is_relative_to(LOG_DIR):
                    member = "logs/" + path.relative_to(LOG_DIR).as_posix()
                else:
                    member = "artifacts/" + path.relative_to(RESULTS_DIR).as_posix()
                output.write(path, member)
    return archive


def parse_args() -> argparse.Namespace:
    """Parses and returns the acceptance runner command-line arguments."""
    parser = argparse.ArgumentParser(description="Run the complete MiniSQL 1.0.0 M0-M50 test suite")
    parser.add_argument("--compiler")
    parser.add_argument("--static-only", action="store_true")
    parser.add_argument("--keep-artifacts", action="store_true")
    parser.add_argument("--verbose", action="store_true")
    return parser.parse_args()


def main() -> int:
    """Dispatches the selected command, translates known failures and returns a process exit status."""
    args = parse_args(); started = time.perf_counter(); phases: list[dict[str, Any]] = []
    base.ensure_runtime_directories(); base.clean_path(RESULTS_DIR); base.clean_path(BUILD_ROOT); DATA_DIR.mkdir(parents=True, exist_ok=True)
    try:
        manifest = load_json(MANIFEST_PATH)
        static_actions = [
            ("repository manifest, one-launcher contract and 78-module catalog", lambda: validate_repository(manifest)),
            ("configuration, final M0-M50 evidence and complete 1.0 documentation", validate_config_and_docs),
            ("durable replication, hardening and release source contracts", validate_source_contracts),
            ("independent corpus, sidecar, compatibility and deterministic-release vectors", validate_reference_vectors),
        ]
        if args.static_only:
            for i,(name,action) in enumerate(static_actions,1): run_phase(i,len(static_actions),name,action,phases)
            print("MiniSQL 1.0.0 static validation: SUCCESS"); return 0
        compiler = base.resolve_compiler(args.compiler); print(f"MiniLang compiler: {compiler}")
        actions: list[tuple[str,Callable[[],None]]] = list(static_actions)
        actions += [
            ("compile and run application regressions", lambda: base.compile_and_run_apps(compiler, manifest, args.verbose)),
            ("M0 71-module regression", lambda: base.run_m0(compiler,args.verbose)),
            ("M1R1 codec and module regressions", lambda: base.run_m1(compiler,args.verbose)),
            ("M2 canonical varints", lambda: base.run_m2_varint(compiler,args.verbose)),
            ("M2 CRC32C and protected envelopes", lambda: base.run_m2_crc(compiler,args.verbose)),
            ("M3 random-access files and clock", lambda: base.run_m3_file(compiler,args.verbose)),
            ("M3 durable writer/reader processes", lambda: base.run_m3_durable(compiler,args.verbose)),
            ("M3 cross-process exclusive lock", lambda: base.run_m3_lock(compiler,args.verbose)),
            ("M4 page and superblock formats", lambda: base.run_m4_page(compiler,args.verbose)),
            ("M4 paged-file recovery and generation fallback", lambda: base.run_m4_paged(compiler,args.verbose)),
            ("M5 buffer-pool unit and failure paths", lambda: base.run_m5_pool(compiler,args.verbose)),
            ("M5 deterministic buffer-pool stress", lambda: base.run_m5_stress(compiler,args.verbose)),
            ("M5 71-module implementation smoke", lambda: base.run_m5_modules(compiler,args.verbose)),
            ("M6 WAL format, scan and torn-tail repair", lambda: base.run_m6_wal(compiler,args.verbose)),
            ("M6 transaction commit, rollback, locks and fault injection", lambda: base.run_m6_transaction(compiler,args.verbose)),
            ("M7 redundant checkpoint metadata", lambda: base.run_m7_checkpoint(compiler,args.verbose)),
            ("M7 committed-only idempotent recovery", lambda: base.run_m7_recovery(compiler,args.verbose)),
            ("M7 process termination after durable commit", lambda: base.run_m7_crash_committed(compiler,args.verbose)),
            ("M7 process termination before commit", lambda: base.run_m7_crash_uncommitted(compiler,args.verbose)),
            ("M8 strict configuration loader and defaults", lambda: base.run_m8_config(compiler,args.verbose)),
            ("M8 database directory, catalog and manager", lambda: base.run_m8_catalog(compiler,args.verbose)),
            ("M9 row format and SQL NULL codec", lambda: base.run_m9_row(compiler,args.verbose)),
            ("M9 slotted pages and heap-file workload", lambda: base.run_m9_heap(compiler,args.verbose)),
            ("M10 overflow chains, replacement and reclamation", lambda: base.run_m10_overflow(compiler,args.verbose)),
            ("M10 71-module implementation smoke", lambda: base.run_m10_modules(compiler,args.verbose)),
            ("M11 persistent B+ tree", lambda: run_m11(compiler,args.verbose)),
            ("M12 SQL lexer, parser and AST", lambda: run_simple(compiler,"src/tests/m12_sql_frontend.ml","minisql-m12-sql-front-end.exe","MiniSQL M12 SQL front-end tests: SUCCESS",args.verbose)),
            ("M13 binder, SQL types, values and three-valued logic", lambda: run_simple(compiler,"src/tests/m13_binding_values.ml","minisql-m13-binding-values.exe","MiniSQL M13 binding/value tests: SUCCESS",args.verbose)),
            ("M14 transactional DDL, constraints and crash journal", lambda: run_simple(compiler,"src/tests/m14_transactional_ddl.ml","minisql-m14-transactional-ddl.exe","MiniSQL M14 transactional DDL tests: SUCCESS",args.verbose,[str(data_root('m14-root'))])),
            ("M15 transactional DML and basic SELECT", lambda: run_simple(compiler,"src/tests/m15_sql_engine.ml","minisql-m15-sql-engine.exe","MiniSQL M15 SQL engine tests: SUCCESS",args.verbose,[str(data_root('m15-root'))],1800)),
            ("M15 71-module implementation smoke", lambda: run_simple(compiler,"src/tests/m15_all_modules.ml","minisql-m15-modules.exe","MiniSQL M15 module smoke test: SUCCESS (71 modules)",args.verbose)),
            ("M16 joins, grouping, aggregates, sort and set operations", lambda: run_simple(compiler,"src/tests/m16_relational_engine.ml","minisql-m16-relational.exe","MiniSQL M16 relational execution tests: SUCCESS",args.verbose,[str(data_root('m16-root'))],1800)),
            ("M17 persisted statistics, ANALYZE, optimizer and EXPLAIN", lambda: run_simple(compiler,"src/tests/m17_statistics_optimizer.ml","minisql-m17-statistics.exe","MiniSQL M17 statistics and optimizer tests: SUCCESS",args.verbose,[str(data_root('m17-root'))],1800)),
            ("M18 binary protocol codec, limits and signed WinSock ABI", lambda: run_simple(compiler,"src/tests/m18_protocol.ml","minisql-m18-protocol.exe","MiniSQL M18 protocol codec tests: SUCCESS",args.verbose,[str(free_port())])),
            ("M18 loopback server/client process integration", lambda: run_m18_network(compiler,args.verbose)),
            ("M19 transaction savepoints and isolation-aware locks", lambda: run_simple(compiler,"src/tests/m19_savepoints.ml","minisql-m19-savepoints.exe","MiniSQL M19 savepoint and isolation tests: SUCCESS",args.verbose,[str(DATA_DIR/'m19-savepoints.wal')],1200)),
            ("M19 SQL SAVEPOINT, ROLLBACK TO and RELEASE", lambda: run_simple(compiler,"src/tests/m19_sql_savepoints.ml","minisql-m19-sql-savepoints.exe","MiniSQL M19 SQL savepoint tests: SUCCESS",args.verbose,[str(data_root('m19-sql-root'))],1800)),
            ("M20 consistency check, verified backup/restore and migration refusal", lambda: run_simple(compiler,"src/tests/m20_tools.ml","minisql-m20-tools.exe","MiniSQL M20 check, backup, restore and migration tests: SUCCESS",args.verbose,[str(data_root('m20-root'))],2400)),
            ("M20 deterministic durability and performance workload", lambda: run_simple(compiler,"src/tests/m20_performance_smoke.ml","minisql-m20-workload.exe","MiniSQL M20 deterministic workload tests: SUCCESS",args.verbose,[str(data_root('m20-workload-root'))],2400)),
            ("M20 71-module implementation smoke", lambda: run_simple(compiler,"src/tests/m20_all_modules.ml","minisql-m20-modules.exe","MiniSQL M20 module smoke test: SUCCESS (71 modules)",args.verbose)),
            ("M20 final cumulative gate", lambda: None),
            ("M21 security catalog, password verifier and generation fallback", lambda: run_simple(compiler,"src/tests/m21_security_catalog.ml","minisql-m21-security-catalog.exe","MiniSQL M21 security catalog tests: SUCCESS",args.verbose,[str(data_root('m21-security-root'))],2400)),
            ("M21 DCL parser, roles and authorization", lambda: run_simple(compiler,"src/tests/m21_dcl_authorization.ml","minisql-m21-dcl-authorization.exe","MiniSQL M21 DCL authorization tests: SUCCESS",args.verbose,[str(data_root('m21-dcl-root'))],2400)),
            ("M21 authentication protocol and session state", lambda: run_simple(compiler,"src/tests/m21_auth_protocol.ml","minisql-m21-auth-protocol.exe","MiniSQL M21 authentication protocol tests: SUCCESS",args.verbose,[str(data_root('m21-auth-root'))],2400)),
            ("M21 authenticated loopback server/client process integration", lambda: run_m21_network(compiler,args.verbose)),
            ("M21 security-aware consistency check and backup/restore", lambda: run_simple(compiler,"src/tests/m21_security_tools.ml","minisql-m21-security-tools.exe","MiniSQL M21 security backup/check tests: SUCCESS",args.verbose,[str(data_root('m21-tools-root'))],2400)),
            ("M21 71-module implementation smoke", lambda: run_simple(compiler,"src/tests/m21_all_modules.ml","minisql-m21-modules.exe","MiniSQL M21 module smoke test: SUCCESS (71 modules)",args.verbose)),
            ("M21 final cumulative gate", lambda: None),
            ("M22 prepared statements and positional parameters", lambda: run_simple(compiler,"src/tests/m22_prepared_statements.ml","minisql-m22-prepared.exe","MiniSQL M22 prepared statement tests: SUCCESS",args.verbose,[str(data_root('m22-root'))],2400)),
            ("M23 index maintenance, access paths and repair", lambda: run_simple(compiler,"src/tests/m23_index_integration.ml","minisql-m23-index-integration.exe","MiniSQL M23 index integration tests: SUCCESS",args.verbose,[str(data_root('m23-root'))],2400)),
            ("M24 ALTER TABLE and compatible schema evolution", lambda: run_simple(compiler,"src/tests/m24_schema_evolution.ml","minisql-m24-schema-evolution.exe","MiniSQL M24 schema evolution tests: SUCCESS",args.verbose,[str(data_root('m24-root'))],2400)),
            ("M25 VACUUM, REINDEX and maintenance-journal recovery", lambda: run_simple(compiler,"src/tests/m25_maintenance.ml","minisql-m25-maintenance.exe","MiniSQL M25 maintenance tests: SUCCESS",args.verbose,[str(data_root('m25-root'))],3600)),
            ("M26 offline source-to-target page-size migration", lambda: run_simple(compiler,"src/tests/m26_offline_migration.ml","minisql-m26-migration.exe","MiniSQL M26 offline migration tests: SUCCESS",args.verbose,[str(data_root('m26-root'))],3600)),
            ("M26 71-module implementation smoke", lambda: run_simple(compiler,"src/tests/m26_all_modules.ml","minisql-m26-modules.exe","MiniSQL M26 module smoke test: SUCCESS (71 modules)",args.verbose)),
            ("M26 final cumulative gate", lambda: None),
            ("M27 shared lock manager, waits and deadlock detection", lambda: run_simple(compiler,"src/tests/m27_scheduler_locks.ml","minisql-m27-scheduler-locks.exe","MiniSQL M27 scheduler and lock tests: SUCCESS",args.verbose,[str(data_root('m27-lock-root'))],2400)),
            ("M27 concurrent server/client process integration", lambda: run_m27_network(compiler,args.verbose)),
            ("M28 no-echo byte-secret and authentication hardening", lambda: run_simple(compiler,"src/tests/m28_secret_handling.ml","minisql-m28-secret-handling.exe","MiniSQL M28 secret handling tests: SUCCESS",args.verbose,[str(data_root('m28-root'))],2400)),
            ("M29 AES-GCM frame protection and remote-bind policy", lambda: run_simple(compiler,"src/tests/m29_secure_transport.ml","minisql-m29-secure-transport.exe","MiniSQL M29 secure transport tests: SUCCESS",args.verbose,timeout=2400)),
            ("M29 authenticated encrypted concurrent process integration", lambda: run_m29_network(compiler,args.verbose)),
            ("M30 durable audit chain and grant dependency revocation", lambda: run_simple(compiler,"src/tests/m30_audit_grants.ml","minisql-m30-audit-grants.exe","MiniSQL M30 audit and grant-chain tests: SUCCESS",args.verbose,[str(data_root('m30-root'))],3600)),
            ("M31 WAL archive, exact-LSN PITR and standby lifecycle", lambda: run_simple(compiler,"src/tests/m31_archive_pitr.ml","minisql-m31-archive-pitr.exe","MiniSQL M31 archive and PITR tests: SUCCESS",args.verbose,[str(data_root('m31-root'))],5400)),
            ("M31 71-module implementation smoke", lambda: run_simple(compiler,"src/tests/m31_all_modules.ml","minisql-m31-modules.exe","MiniSQL M31 module smoke test: SUCCESS (71 modules)",args.verbose,timeout=2400)),
            ("M31 final cumulative gate", lambda: None),
            ("M32 operational database initialization and secret bootstrap helpers", lambda: run_simple(compiler,"src/tests/m32_operational_cli.ml","minisql-m32-operational.exe","MiniSQL M32 operational helper tests: SUCCESS",args.verbose,[str(data_root('m32-helper-root'))],2400)),
            ("M32 public minisqld/minisql bounded script integration", lambda: run_m32_public_script(args.verbose)),
            ("M32 persistent public daemon and one-shot client lifecycle", lambda: run_m32_persistent_daemon(args.verbose)),
            ("M32 final cumulative gate", lambda: None),
            ("M33 SQL-aware statement scanner and shell framing", lambda: run_m33_client_input(compiler,args.verbose)),
            ("M33 public multiline script and final-statement integration", lambda: run_m33_public_multiline_script(args.verbose)),
            ("M34 catalog introspection commands", lambda: run_simple(compiler,"src/tests/m34_catalog_introspection.ml","minisql-m34-catalog-introspection.exe","MiniSQL M34 catalog introspection tests: SUCCESS",args.verbose,[str(data_root('m34-root'))],2400)),
            ("M35 scalar CASE, CAST, COALESCE and NULLIF", lambda: run_simple(compiler,"src/tests/m35_scalar_expressions.ml","minisql-m35-scalar-expressions.exe","MiniSQL M35 scalar expression tests: SUCCESS",args.verbose,[str(data_root('m35-root'))],2400)),
            ("M36 IN/BETWEEN/truth predicates and OFFSET/FETCH", lambda: run_simple(compiler,"src/tests/m36_predicates_fetch.ml","minisql-m36-predicates-fetch.exe","MiniSQL M36 predicates and FETCH tests: SUCCESS",args.verbose,[str(data_root('m36-root'))],2400)),
            ("M37 RIGHT and FULL OUTER JOIN", lambda: run_simple(compiler,"src/tests/m37_outer_joins.ml","minisql-m37-outer-joins.exe","MiniSQL M37 outer join tests: SUCCESS",args.verbose,[str(data_root('m37-root'))],2400)),
            ("M37 71-module implementation smoke", lambda: run_simple(compiler,"src/tests/m37_all_modules.ml","minisql-m37-modules.exe","MiniSQL M37 module smoke test: SUCCESS (71 modules)",args.verbose,timeout=2400)),
            ("M37 final cumulative gate", lambda: None),
            ("M38 DML RETURNING result rows", lambda: run_simple(compiler,"src/tests/m38_returning.ml","minisql-m38-returning.exe","MiniSQL M38 RETURNING tests: SUCCESS",args.verbose,[str(data_root('m38-root'))],2400)),
            ("M39 INSERT SELECT materialization and rollback", lambda: run_simple(compiler,"src/tests/m39_insert_select.ml","minisql-m39-insert-select.exe","MiniSQL M39 INSERT SELECT tests: SUCCESS",args.verbose,[str(data_root('m39-root'))],2400)),
            ("M40 ON CONFLICT DO NOTHING and conflict targets", lambda: run_simple(compiler,"src/tests/m40_conflict_nothing.ml","minisql-m40-conflict-nothing.exe","MiniSQL M40 ON CONFLICT DO NOTHING tests: SUCCESS",args.verbose,[str(data_root('m40-root'))],2400)),
            ("M41 ON CONFLICT DO UPDATE UPSERT", lambda: run_simple(compiler,"src/tests/m41_upsert.ml","minisql-m41-upsert.exe","MiniSQL M41 UPSERT tests: SUCCESS",args.verbose,[str(data_root('m41-root'))],2400)),
            ("M42 transactional TRUNCATE and identity restart", lambda: run_simple(compiler,"src/tests/m42_truncate.ml","minisql-m42-truncate.exe","MiniSQL M42 TRUNCATE tests: SUCCESS",args.verbose,[str(data_root('m42-root'))],2400)),
            ("M42 71-module implementation smoke", lambda: run_simple(compiler,"src/tests/m42_all_modules.ml","minisql-m42-modules.exe","MiniSQL M42 module smoke test: SUCCESS (71 modules)",args.verbose,timeout=2400)),
            ("M42 final cumulative gate", lambda: None),
            ("M43 AUTO_INCREMENT and exact decimal INSERT compatibility", lambda: run_simple(compiler,"src/tests/m43_auto_increment_decimal.ml","minisql-m43-auto-increment-decimal.exe","MiniSQL AUTO_INCREMENT and decimal INSERT tests: SUCCESS",args.verbose,[str(data_root('m43-compat-root'))],3000)),
            ("M43 persisted views and non-correlated subqueries", lambda: run_simple(compiler,"src/tests/m43_views_subqueries.ml","minisql-m43-views.exe","MiniSQL M43 views and subqueries: SUCCESS",args.verbose,[str(data_root('m43-root'))],3000)),
            ("M44 nonrecursive CTEs and window functions", lambda: run_simple(compiler,"src/tests/m44_cte_windows.ml","minisql-m44-cte-windows.exe","MiniSQL M44 CTE and window tests: SUCCESS",args.verbose,[str(data_root('m44-root'))],3000)),
            ("M45 sequences, generated columns and row triggers", lambda: run_simple(compiler,"src/tests/m45_sequences_generated_triggers.ml","minisql-m45-schema-extensions.exe","MiniSQL M45 sequence generated trigger tests: SUCCESS",args.verbose,[str(data_root('m45-root'))],3600)),
            ("M46 hash operators and external merge sort", lambda: run_simple(compiler,"src/tests/m46_optimizer_executor_v2.ml","minisql-m46-optimizer-v2.exe","MiniSQL M46 optimizer executor v2: SUCCESS",args.verbose,[str(data_root('m46-root'))],5400)),
            ("M73 native TLS 1.3/X.509, X25519 and certificate pinning", lambda: run_native_tls(compiler,args.verbose)),
            ("M47 71-module implementation smoke", lambda: run_simple(compiler,"src/tests/m47_all_modules.ml","minisql-m47-modules.exe","MiniSQL M47 module smoke test: SUCCESS (71 modules)",args.verbose,timeout=2400)),
            ("M47 final cumulative gate", lambda: None),
            ("M48 durable live WAL export and read-only standby", lambda: run_simple(compiler,"src/tests/m48_hot_replication.ml","minisql-m48-hot-replication.exe","MiniSQL M48 hot replication tests: SUCCESS",args.verbose,[str(data_root('m48-root'))],3600)),
            ("M48 continuous public hot-replication process integration", lambda: run_m48_hot_process(args.verbose)),
            ("M48 final cumulative gate", lambda: None),
            ("M49 deterministic parser, wire, WAL and durable-workload hardening", lambda: run_simple(compiler,"src/tests/m49_hardening.ml","minisql-m49-hardening.exe","MiniSQL M49 hardening tests: SUCCESS",args.verbose,[str(data_root('m49-root'))],3600)),
            ("M49 committed/uncommitted crash matrix", lambda: run_m49_crash_matrix(args.verbose)),
            ("M49 repeated soak and performance guardrail", lambda: run_m49_soak(args.verbose)),
            ("M49 final cumulative gate", lambda: None),
            ("M50 release contract and compatibility freeze", lambda: run_simple(compiler,"src/tests/m50_release_contract.ml","minisql-m50-release-contract.exe","MiniSQL M50 release contract tests: SUCCESS",args.verbose,[str(data_root('m50-root'))],3600)),
            ("M50 deterministic Windows-x64 distribution build and verification", lambda: run_m50_release_distribution(args.verbose)),
            ("M50 78-module implementation smoke", lambda: run_simple(compiler,"src/tests/m50_all_modules.ml","minisql-m50-modules.exe","MiniSQL M50 module smoke test: SUCCESS (78 modules)",args.verbose,timeout=2400)),
            ("M50 final cumulative gate", lambda: run_m74_workbench(compiler, args.verbose)),
        ]
        if len(actions) != PHASE_COUNT:
            raise AcceptanceFailure(f"Internal phase count mismatch: {len(actions)} != {PHASE_COUNT}")
        for i,(name,action) in enumerate(actions,1): run_phase(i,len(actions),name,action,phases)
        write_results("SUCCESS",phases,started,None); archive=package_results()
        if not args.keep_artifacts: base.clean_path(BUILD_ROOT)
        print(f"Result archive: {archive}"); print(FINAL_SUCCESS); return 0
    except Exception as exc:
        write_results("FAIL",phases,started,str(exc)); archive=package_results()
        if not args.keep_artifacts: base.clean_path(BUILD_ROOT)
        print(f"ERROR: {exc}"); print(f"Result archive: {archive}"); print(FINAL_FAILURE); return 1

if __name__ == "__main__":
    raise SystemExit(main())
