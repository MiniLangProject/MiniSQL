#!/usr/bin/env python3
"""MiniSQL M48 continuous WAL shipping and read-only hot-standby sidecar.

The primary role repeatedly exports only the WAL prefix covered by MiniSQL's
FlushFileBuffers-backed durable marker. The standby role uses two independently
materialized standby slots and a loopback TCP switch. Existing client
connections finish on their old generation; new connections use the newest
fully recovered generation.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import socket
import subprocess
import sys
import threading
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Sequence

REPORT_RE = re.compile(r"generation=(\d+)\s+lsn=(\d+)")


class ReplicaError(RuntimeError):
    pass


def now_utc() -> str:
    import datetime

    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def atomic_json(path: Path | None, payload: dict[str, Any]) -> None:
    if path is None:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_name(path.name + ".new")
    temp.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    os.replace(temp, path)


def touch_ready(path: Path | None) -> None:
    if path is None:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_name(path.name + ".new")
    temp.write_bytes(b"ready\n")
    os.replace(temp, path)


def command_for(executable: Path, *arguments: object) -> list[str]:
    return [str(executable), *(str(value) for value in arguments)]


def run_checked(command: Sequence[str], timeout: float = 600.0) -> subprocess.CompletedProcess[str]:
    completed = subprocess.run(
        list(command),
        text=True,
        encoding="utf-8",
        errors="replace",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=timeout,
        check=False,
    )
    if completed.returncode != 0:
        raise ReplicaError(
            "command failed: "
            + " ".join(command)
            + f"\nexit={completed.returncode}\nstdout={completed.stdout.strip()}\nstderr={completed.stderr.strip()}"
        )
    return completed


def parse_report(output: str) -> tuple[int, int]:
    match = REPORT_RE.search(output)
    if match is None:
        raise ReplicaError(f"MiniSQL report does not contain generation/lsn: {output!r}")
    return int(match.group(1)), int(match.group(2))


def verify_archive(backup_exe: Path, archive: Path) -> tuple[int, int]:
    completed = run_checked(command_for(backup_exe, "archive-verify", archive))
    return parse_report(completed.stdout)


def wait_listening(process: subprocess.Popen[str], host: str, port: int, timeout: float) -> None:
    deadline = time.monotonic() + timeout
    last_error: OSError | None = None
    while time.monotonic() < deadline:
        if process.poll() is not None:
            stdout, stderr = process.communicate(timeout=5)
            raise ReplicaError(
                f"standby server exited before listening: exit={process.returncode} "
                f"stdout={stdout.strip()!r} stderr={stderr.strip()!r}"
            )
        try:
            with socket.create_connection((host, port), timeout=0.25):
                return
        except OSError as exc:
            last_error = exc
            time.sleep(0.05)
    raise ReplicaError(f"standby server did not listen on {host}:{port}: {last_error}")


def free_port() -> int:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as listener:
        listener.bind(("127.0.0.1", 0))
        return int(listener.getsockname()[1])


def terminate(process: subprocess.Popen[str] | None) -> None:
    if process is None or process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=5)


@dataclass
class Backend:
    slot: Path
    port: int
    generation: int
    lsn: int
    process: subprocess.Popen[str] | None
    active_connections: int = 0
    retired: bool = False
    lock: threading.Lock = field(default_factory=threading.Lock)

    def acquire(self) -> None:
        with self.lock:
            self.active_connections += 1

    def release(self) -> None:
        with self.lock:
            self.active_connections -= 1

    def idle(self) -> bool:
        with self.lock:
            return self.active_connections == 0


class SwitchingProxy:
    def __init__(self, host: str, port: int, max_connections: int) -> None:
        if host not in {"127.0.0.1", "localhost", "::1"}:
            raise ReplicaError("the M48 cleartext standby switch may bind only to loopback")
        self.host = host
        self.port = port
        self.max_connections = max_connections
        self._backend: Backend | None = None
        self._lock = threading.Lock()
        self._stop = threading.Event()
        self._accept_done = threading.Event()
        self._served = 0
        self._listener: socket.socket | None = None
        self._thread: threading.Thread | None = None
        self._handlers: list[threading.Thread] = []

    @property
    def served(self) -> int:
        with self._lock:
            return self._served

    def set_backend(self, backend: Backend) -> Backend | None:
        with self._lock:
            previous = self._backend
            self._backend = backend
            if previous is not None:
                previous.retired = True
            return previous

    def start(self) -> None:
        listener = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        listener.bind((self.host, self.port))
        listener.listen(32)
        listener.settimeout(0.2)
        self._listener = listener
        self._thread = threading.Thread(target=self._accept_loop, name="minisql-hot-standby-proxy", daemon=True)
        self._thread.start()

    def _accept_loop(self) -> None:
        assert self._listener is not None
        while not self._stop.is_set():
            if self.max_connections > 0 and self.served >= self.max_connections:
                break
            try:
                client, _ = self._listener.accept()
            except socket.timeout:
                continue
            except OSError:
                break
            with self._lock:
                backend = self._backend
                self._served += 1
            if backend is None:
                client.close()
                continue
            backend.acquire()
            thread = threading.Thread(target=self._bridge, args=(client, backend), daemon=True)
            self._handlers.append(thread)
            thread.start()
        self._accept_done.set()

    def _pump(self, source: socket.socket, destination: socket.socket) -> None:
        """Copy one half of a full-duplex connection without losing partial sends."""
        while not self._stop.is_set():
            try:
                data = source.recv(65536)
            except socket.timeout:
                continue
            except OSError:
                return
            if not data:
                try:
                    destination.shutdown(socket.SHUT_WR)
                except OSError:
                    pass
                return

            pending = memoryview(data)
            while pending and not self._stop.is_set():
                try:
                    sent = destination.send(pending)
                except socket.timeout:
                    continue
                except OSError:
                    return
                if sent <= 0:
                    return
                pending = pending[sent:]

    def _bridge(self, client: socket.socket, backend: Backend) -> None:
        upstream: socket.socket | None = None
        pumps: list[threading.Thread] = []
        try:
            upstream = socket.create_connection(("127.0.0.1", backend.port), timeout=5)
            # Short timeouts make shutdown deterministic while retaining normal
            # blocking send/recv semantics. Two one-way pumps avoid the subtle
            # partial-send behavior of sendall() on non-blocking sockets.
            client.settimeout(0.5)
            upstream.settimeout(0.5)
            pumps = [
                threading.Thread(target=self._pump, args=(client, upstream), daemon=True),
                threading.Thread(target=self._pump, args=(upstream, client), daemon=True),
            ]
            for pump in pumps:
                pump.start()
            while any(pump.is_alive() for pump in pumps) and not self._stop.is_set():
                for pump in pumps:
                    pump.join(timeout=0.1)
            if self._stop.is_set():
                for stream in (client, upstream):
                    try:
                        stream.shutdown(socket.SHUT_RDWR)
                    except OSError:
                        pass
            for pump in pumps:
                pump.join(timeout=1)
        finally:
            try:
                client.close()
            except OSError:
                pass
            if upstream is not None:
                try:
                    upstream.close()
                except OSError:
                    pass
            backend.release()

    def wait_for_connections(self, timeout: float) -> None:
        if self.max_connections <= 0:
            return
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline and self.served < self.max_connections:
            time.sleep(0.05)
        if self.served < self.max_connections:
            raise ReplicaError(
                f"standby proxy served {self.served}/{self.max_connections} expected connections before timeout"
            )
        # Reaching the accept budget must stop only new accepts. Existing SQL
        # connections are allowed to finish before their recovered generation
        # is retired.
        for handler in list(self._handlers):
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                raise ReplicaError("standby client connection did not finish before timeout")
            handler.join(timeout=remaining)
            if handler.is_alive():
                raise ReplicaError("standby client connection did not finish before timeout")

    def close(self) -> None:
        self._stop.set()
        if self._listener is not None:
            try:
                self._listener.close()
            except OSError:
                pass
        if self._thread is not None:
            self._thread.join(timeout=2)
        for handler in self._handlers:
            handler.join(timeout=2)


def primary_role(args: argparse.Namespace) -> int:
    database = Path(args.database).resolve()
    archive = Path(args.archive).resolve()
    backup_exe = Path(args.backup_exe).resolve()
    status = Path(args.status_file).resolve() if args.status_file else None
    ready = Path(args.ready_file).resolve() if args.ready_file else None
    cycles = int(args.cycles)
    interval = int(args.interval_ms) / 1000.0
    completed_cycles = 0

    if not archive.exists():
        completed = run_checked(command_for(backup_exe, "archive-init", database, archive), timeout=args.command_timeout)
        generation, lsn = parse_report(completed.stdout)
        atomic_json(status, {
            "role": "primary", "status": "ready", "cycle": 0,
            "generation": generation, "lsn": lsn, "database": str(database),
            "archive": str(archive), "updatedUtc": now_utc(),
        })
    touch_ready(ready)

    while cycles == 0 or completed_cycles < cycles:
        completed = run_checked(
            command_for(backup_exe, "archive-wal-live", database, archive),
            timeout=args.command_timeout,
        )
        generation, lsn = parse_report(completed.stdout)
        completed_cycles += 1
        atomic_json(status, {
            "role": "primary", "status": "streaming", "cycle": completed_cycles,
            "generation": generation, "lsn": lsn, "database": str(database),
            "archive": str(archive), "updatedUtc": now_utc(),
        })
        print(f"MiniSQL hot primary: cycle={completed_cycles} generation={generation} lsn={lsn}", flush=True)
        if cycles == 0 or completed_cycles < cycles:
            time.sleep(interval)
    print(f"MiniSQL hot primary: SUCCESS cycles={completed_cycles}")
    return 0


def materialize_backend(
    backup_exe: Path,
    server_exe: Path,
    archive: Path,
    slot: Path,
    port: int,
    maximum_clients: int,
    timeout: float,
) -> Backend:
    if slot.exists():
        shutil.rmtree(slot)
    completed = run_checked(
        command_for(backup_exe, "standby-materialize", archive, slot), timeout=timeout
    )
    generation, lsn = parse_report(completed.stdout)
    command = command_for(server_exe, "--serve-standby", slot, port, maximum_clients)
    process = subprocess.Popen(
        command,
        text=True,
        encoding="utf-8",
        errors="replace",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    wait_listening(process, "127.0.0.1", port, timeout=min(timeout, 180.0))
    return Backend(slot, port, generation, lsn, process)


def wait_backend_idle(backend: Backend, timeout: float) -> None:
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if backend.idle():
            return
        time.sleep(0.05)
    raise ReplicaError(f"retired standby generation {backend.generation} still has active clients")


def standby_role(args: argparse.Namespace) -> int:
    archive = Path(args.archive).resolve()
    slot_root = Path(args.slot_root).resolve()
    backup_exe = Path(args.backup_exe).resolve()
    server_exe = Path(args.server_exe).resolve()
    status = Path(args.status_file).resolve() if args.status_file else None
    ready = Path(args.ready_file).resolve() if args.ready_file else None
    slot_root.mkdir(parents=True, exist_ok=True)
    port_a = int(args.backend_port_a) or free_port()
    port_b = int(args.backend_port_b) or free_port()
    if port_a == port_b or args.listen_port in {port_a, port_b}:
        raise ReplicaError("public and backend ports must be distinct")

    proxy = SwitchingProxy(args.listen_host, int(args.listen_port), int(args.max_connections))
    backends: dict[str, Backend] = {}
    active_name = "a"
    cycles = int(args.cycles)
    completed_cycles = 0
    current_generation = 0
    proxy.start()

    try:
        while cycles == 0 or completed_cycles < cycles:
            generation, _ = verify_archive(backup_exe, archive)
            if generation <= current_generation:
                time.sleep(int(args.interval_ms) / 1000.0)
                continue

            target_name = "a" if completed_cycles == 0 else ("b" if active_name == "a" else "a")
            previous_target = backends.get(target_name)
            if previous_target is not None:
                wait_backend_idle(previous_target, args.command_timeout)
                terminate(previous_target.process)
                backends.pop(target_name, None)

            slot = slot_root / f"slot-{target_name}"
            backend_port = port_a if target_name == "a" else port_b
            backend = materialize_backend(
                backup_exe, server_exe, archive, slot, backend_port,
                int(args.maximum_clients), args.command_timeout,
            )
            previous_active = proxy.set_backend(backend)
            backends[target_name] = backend
            active_name = target_name
            current_generation = backend.generation
            completed_cycles += 1
            atomic_json(status, {
                "role": "standby", "status": "serving", "cycle": completed_cycles,
                "generation": backend.generation, "lsn": backend.lsn,
                "slot": str(slot), "listenHost": args.listen_host,
                "listenPort": int(args.listen_port), "updatedUtc": now_utc(),
            })
            if completed_cycles == 1:
                touch_ready(ready)
            print(
                f"MiniSQL hot standby: cycle={completed_cycles} generation={backend.generation} "
                f"lsn={backend.lsn} slot={target_name}",
                flush=True,
            )
            if previous_active is not None and previous_active.idle():
                terminate(previous_active.process)
            if cycles == 0 or completed_cycles < cycles:
                time.sleep(int(args.interval_ms) / 1000.0)

        proxy.wait_for_connections(args.client_timeout)
        print(
            f"MiniSQL hot standby: SUCCESS cycles={completed_cycles} connections={proxy.served}"
        )
        return 0
    finally:
        proxy.close()
        for backend in backends.values():
            terminate(backend.process)


def self_test() -> int:
    generation, lsn = parse_report("MiniSQL WAL archive verify: SUCCESS generation=12 lsn=3456")
    if generation != 12 or lsn != 3456:
        raise ReplicaError("report parser self-test failed")
    try:
        SwitchingProxy("0.0.0.0", 1, 1)
        raise ReplicaError("non-loopback proxy self-test failed")
    except ReplicaError as exc:
        if "loopback" not in str(exc):
            raise

    # Exercise the actual full-duplex switch with a local echo backend. This
    # catches accept-budget regressions and partial forwarding before Windows
    # application integration begins.
    backend_listener = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    backend_listener.bind(("127.0.0.1", 0))
    backend_listener.listen(1)
    backend_listener.settimeout(5)
    backend_port = int(backend_listener.getsockname()[1])
    backend_failure: list[BaseException] = []

    def echo_once() -> None:
        try:
            connection, _ = backend_listener.accept()
            with connection:
                connection.settimeout(5)
                while True:
                    data = connection.recv(65536)
                    if not data:
                        break
                    connection.sendall(data)
                try:
                    connection.shutdown(socket.SHUT_WR)
                except OSError:
                    pass
        except BaseException as exc:  # captured and re-raised in the main thread
            backend_failure.append(exc)
        finally:
            backend_listener.close()

    echo_thread = threading.Thread(target=echo_once, daemon=True)
    echo_thread.start()
    proxy_port = free_port()
    proxy = SwitchingProxy("127.0.0.1", proxy_port, 1)
    proxy.set_backend(Backend(Path("self-test"), backend_port, 1, 0, None))
    proxy.start()
    payload = bytes((index * 37 + 11) & 0xFF for index in range(65536))
    received = bytearray()
    try:
        with socket.create_connection(("127.0.0.1", proxy_port), timeout=5) as client:
            client.settimeout(5)
            client.sendall(payload)
            client.shutdown(socket.SHUT_WR)
            while True:
                chunk = client.recv(65536)
                if not chunk:
                    break
                received.extend(chunk)
        proxy.wait_for_connections(5)
    finally:
        proxy.close()
        echo_thread.join(timeout=5)
    if echo_thread.is_alive():
        raise ReplicaError("proxy echo self-test did not finish")
    if backend_failure:
        raise ReplicaError(f"proxy echo backend failed: {backend_failure[0]}")
    if bytes(received) != payload:
        raise ReplicaError("proxy echo self-test changed the byte stream")

    print("MiniSQL M48 replication sidecar self-test: SUCCESS")
    return 0


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(description=__doc__)
    sub = root.add_subparsers(dest="mode", required=True)

    primary = sub.add_parser("primary", help="continuously export the durable WAL prefix")
    primary.add_argument("--database", required=True)
    primary.add_argument("--archive", required=True)
    primary.add_argument("--backup-exe", required=True)
    primary.add_argument("--cycles", type=int, default=0, help="zero means forever")
    primary.add_argument("--interval-ms", type=int, default=250)
    primary.add_argument("--command-timeout", type=float, default=600.0)
    primary.add_argument("--status-file")
    primary.add_argument("--ready-file")

    standby = sub.add_parser("standby", help="double-buffer read-only standby generations")
    standby.add_argument("--archive", required=True)
    standby.add_argument("--slot-root", required=True)
    standby.add_argument("--backup-exe", required=True)
    standby.add_argument("--server-exe", required=True)
    standby.add_argument("--listen-host", default="127.0.0.1")
    standby.add_argument("--listen-port", required=True, type=int)
    standby.add_argument("--backend-port-a", type=int, default=0)
    standby.add_argument("--backend-port-b", type=int, default=0)
    standby.add_argument("--maximum-clients", type=int, default=16)
    standby.add_argument("--max-connections", type=int, default=0, help="zero means unlimited")
    standby.add_argument("--cycles", type=int, default=0, help="zero means forever")
    standby.add_argument("--interval-ms", type=int, default=250)
    standby.add_argument("--command-timeout", type=float, default=600.0)
    standby.add_argument("--client-timeout", type=float, default=600.0)
    standby.add_argument("--status-file")
    standby.add_argument("--ready-file")

    sub.add_parser("self-test")
    return root


def main(argv: Sequence[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        if args.mode == "self-test":
            return self_test()
        if args.mode == "primary":
            if args.cycles < 0 or args.interval_ms < 10:
                raise ReplicaError("cycles must be non-negative and interval must be at least 10 ms")
            return primary_role(args)
        if args.mode == "standby":
            if args.cycles < 0 or args.max_connections < 0 or args.interval_ms < 10:
                raise ReplicaError("cycles/max-connections must be non-negative and interval at least 10 ms")
            return standby_role(args)
        raise ReplicaError(f"unsupported mode: {args.mode}")
    except (ReplicaError, OSError, subprocess.SubprocessError) as exc:
        print(f"MiniSQL hot replication: FAIL {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
