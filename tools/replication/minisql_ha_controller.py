#!/usr/bin/env python3
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.

"""Single-host MiniSQL HA controller with lease fencing and a stable endpoint.

The controller owns a file-backed witness, renews a CRC-32C protected binary
leader lease, ships durable WAL, maintains an offline standby slot, and moves a
loopback TCP proxy after a failed leader is fenced and the standby is promoted.
The witness directory must reside on storage that provides atomic replacement
and has exactly one writer; multi-host consensus is deliberately out of scope.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import signal
import socket
import struct
import subprocess
import sys
import threading
import time
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Iterator

from minisql_hot_replica import Backend, ReplicaError, SwitchingProxy, atomic_json, command_for, free_port, parse_report, run_checked, terminate, verify_archive, wait_listening

EPOCH_MAGIC = b"MSHAE001"
LEASE_MAGIC = b"MSHAL001"
EPOCH_SIZE = 32
LEASE_SIZE = 64
FORMAT_VERSION = 1


def _crc32c_table() -> tuple[int, ...]:
    """Builds the reflected Castagnoli table used by MiniSQL's CRC-32C."""
    entries: list[int] = []
    for value in range(256):
        current = value
        for _ in range(8):
            current = (current >> 1) ^ (0x82F63B78 if current & 1 else 0)
        entries.append(current & 0xFFFFFFFF)
    return tuple(entries)


CRC32C_TABLE = _crc32c_table()


def crc32c(payload: bytes) -> int:
    """Returns the standard finalized CRC-32C of *payload*."""
    checksum = 0xFFFFFFFF
    for value in payload:
        checksum = CRC32C_TABLE[(checksum ^ value) & 0xFF] ^ (checksum >> 8)
    return checksum ^ 0xFFFFFFFF


def encode_epoch(epoch: int, node_id: int) -> bytes:
    """Encodes one persistent database leadership term."""
    if epoch < 1 or node_id < 1:
        raise ReplicaError("epoch and node-id must be positive")
    record = bytearray(EPOCH_SIZE)
    struct.pack_into("<8sHHQQ", record, 0, EPOCH_MAGIC, FORMAT_VERSION, EPOCH_SIZE, epoch, node_id)
    struct.pack_into("<I", record, EPOCH_SIZE - 4, crc32c(record))
    return bytes(record)


def encode_lease(epoch: int, node_id: int, expires_at_ms: int) -> bytes:
    """Encodes one online write lease consumed by the native server."""
    if epoch < 1 or node_id < 1 or expires_at_ms < 1:
        raise ReplicaError("lease values must be positive")
    record = bytearray(LEASE_SIZE)
    struct.pack_into("<8sHHQQQ", record, 0, LEASE_MAGIC, FORMAT_VERSION, LEASE_SIZE, epoch, node_id, expires_at_ms)
    struct.pack_into("<I", record, LEASE_SIZE - 4, crc32c(record))
    return bytes(record)


def decode_record(payload: bytes, magic: bytes, expected_size: int) -> tuple[int, ...]:
    """Validates and decodes an epoch or lease record for controller tests."""
    if len(payload) != expected_size:
        raise ReplicaError("fencing record size mismatch")
    stored = struct.unpack_from("<I", payload, expected_size - 4)[0]
    checked = bytearray(payload)
    struct.pack_into("<I", checked, expected_size - 4, 0)
    actual_magic, version, size = struct.unpack_from("<8sHH", payload, 0)
    if actual_magic != magic or version != FORMAT_VERSION or size != expected_size or crc32c(checked) != stored:
        raise ReplicaError("fencing record validation failed")
    if expected_size == EPOCH_SIZE:
        return struct.unpack_from("<QQ", payload, 12)
    return struct.unpack_from("<QQQ", payload, 12)


def atomic_bytes(path: Path, payload: bytes) -> None:
    """Flushes and atomically replaces one small controller record."""
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + f".{os.getpid()}.new")
    with temporary.open("wb") as stream:
        stream.write(payload)
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(temporary, path)


@contextmanager
def exclusive_file(path: Path) -> Iterator[None]:
    """Serializes witness updates with a cross-platform advisory file lock."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a+b") as stream:
        stream.seek(0, os.SEEK_END)
        if stream.tell() == 0:
            stream.write(b"\0")
            stream.flush()
        stream.seek(0)
        if os.name == "nt":
            import msvcrt

            msvcrt.locking(stream.fileno(), msvcrt.LK_LOCK, 1)
            try:
                yield
            finally:
                stream.seek(0)
                msvcrt.locking(stream.fileno(), msvcrt.LK_UNLCK, 1)
        else:
            import fcntl

            fcntl.flock(stream.fileno(), fcntl.LOCK_EX)
            try:
                yield
            finally:
                fcntl.flock(stream.fileno(), fcntl.LOCK_UN)


class FileWitness:
    """Owns the serialized term state and native-server lease record."""

    def __init__(self, directory: Path, lease_ms: int, clock_skew_ms: int) -> None:
        """Initializes validated witness paths and timing policy."""
        if lease_ms < 1000 or lease_ms > 300_000:
            raise ReplicaError("lease-ms must be between 1000 and 300000")
        if clock_skew_ms < 0 or clock_skew_ms >= lease_ms // 2:
            raise ReplicaError("clock-skew-ms must be non-negative and below half the lease")
        self.directory = directory.resolve()
        self.directory.mkdir(parents=True, exist_ok=True)
        self.state_path = self.directory / "witness.json"
        self.lease_path = self.directory / "leader.lease"
        self.lock_path = self.directory / "witness.lock"
        self.lease_ms = lease_ms
        self.clock_skew_ms = clock_skew_ms

    def _read_state(self) -> dict[str, Any]:
        """Returns validated witness state or an empty initial state."""
        if not self.state_path.exists():
            return {"epoch": 0, "nodeId": 0, "expiresAtMs": 0}
        try:
            value = json.loads(self.state_path.read_text(encoding="utf-8"))
            return {key: int(value[key]) for key in ("epoch", "nodeId", "expiresAtMs")}
        except (OSError, ValueError, KeyError, TypeError) as exc:
            raise ReplicaError(f"witness state is invalid: {exc}") from exc

    def acquire(self, node_id: int) -> tuple[int, int]:
        """Acquires a new term after the prior lease is safely expired."""
        now = time.time_ns() // 1_000_000
        with exclusive_file(self.lock_path):
            state = self._read_state()
            if state["expiresAtMs"] + self.clock_skew_ms >= now:
                raise ReplicaError(f"leader lease is still active for node {state['nodeId']}")
            epoch = state["epoch"] + 1
            expires_at = now + self.lease_ms
            next_state = {"epoch": epoch, "nodeId": node_id, "expiresAtMs": expires_at}
            atomic_json(self.state_path, next_state)
            atomic_bytes(self.lease_path, encode_lease(epoch, node_id, expires_at))
            return epoch, expires_at

    def renew(self, epoch: int, node_id: int) -> int:
        """Extends only the exact unexpired term currently held by this node."""
        now = time.time_ns() // 1_000_000
        with exclusive_file(self.lock_path):
            state = self._read_state()
            if state["epoch"] != epoch or state["nodeId"] != node_id or state["expiresAtMs"] + self.clock_skew_ms < now:
                raise ReplicaError("leadership changed or expired before renewal")
            expires_at = now + self.lease_ms
            next_state = {"epoch": epoch, "nodeId": node_id, "expiresAtMs": expires_at}
            atomic_json(self.state_path, next_state)
            atomic_bytes(self.lease_path, encode_lease(epoch, node_id, expires_at))
            return expires_at

    def expiry(self) -> int:
        """Returns the synchronized lease expiry in Unix milliseconds."""
        with exclusive_file(self.lock_path):
            return self._read_state()["expiresAtMs"]


def write_database_epoch(database: Path, epoch: int, node_id: int) -> None:
    """Publishes the offline restart fence inside one database directory."""
    if not database.is_dir():
        raise ReplicaError(f"database directory does not exist: {database}")
    atomic_bytes(database / "leader.epoch", encode_epoch(epoch, node_id))


def start_fenced_server(server_exe: Path, database: Path, port: int, maximum_clients: int, witness: FileWitness, epoch: int, node_id: int, timeout: float) -> subprocess.Popen[str]:
    """Starts and readiness-checks one native fenced primary process."""
    process = subprocess.Popen(
        command_for(server_exe, "--serve-fenced", database, port, maximum_clients, witness.lease_path, epoch, node_id, witness.clock_skew_ms),
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    wait_listening(process, "127.0.0.1", port, timeout)
    return process


def remove_owned_slot(slot_root: Path, slot: Path) -> None:
    """Removes only a resolved child of the controller-owned slot root."""
    root = slot_root.resolve()
    target = slot.resolve()
    if target.parent != root:
        raise ReplicaError(f"refusing to remove non-slot path: {target}")
    if target.exists():
        shutil.rmtree(target)


class HAController:
    """Coordinates lease renewal, WAL shipping, promotion, and proxy routing."""

    def __init__(self, args: argparse.Namespace) -> None:
        """Captures validated command-line state without starting resources."""
        self.args = args
        self.primary = args.primary_db.resolve()
        self.archive = args.archive.resolve()
        self.slot_root = args.slot_root.resolve()
        self.slot_root.mkdir(parents=True, exist_ok=True)
        self.witness = FileWitness(args.witness_dir, args.lease_ms, args.clock_skew_ms)
        self.status_path = args.status_file.resolve() if args.status_file else None
        self.proxy = SwitchingProxy("127.0.0.1", args.proxy_port, 0)
        self.process: subprocess.Popen[str] | None = None
        self.backend: Backend | None = None
        self.standby: tuple[Path, int, int] | None = None
        self.epoch = 0
        self.node_id = args.node_id
        self.expires_at = 0
        self.failovers = 0
        self.slot_index = 0
        self.stop = False
        self.renew_stop = threading.Event()
        self.renew_thread: threading.Thread | None = None
        self.renew_failure: BaseException | None = None

    def _status(self, state: str, healthy: bool, detail: str = "") -> None:
        """Publishes machine-readable controller and leader state."""
        atomic_json(self.status_path, {
            "role": "ha-controller", "status": state, "healthy": healthy,
            "detail": detail, "epoch": self.epoch, "nodeId": self.node_id,
            "leaseExpiresAtMs": self.expires_at,
            "leaderPid": self.process.pid if self.process and self.process.poll() is None else None,
            "leaderDatabase": str(self.backend.slot) if self.backend else None,
            "leaderPort": self.backend.port if self.backend else None,
            "proxyPort": self.args.proxy_port, "failovers": self.failovers,
            "standbyDatabase": str(self.standby[0]) if self.standby else None,
            "updatedAtMs": time.time_ns() // 1_000_000,
        })

    def _prepare_archive(self) -> None:
        """Creates or verifies the continuous WAL archive before leader startup."""
        if self.archive.exists():
            verify_archive(self.args.backup_exe, self.archive)
        else:
            run_checked(command_for(self.args.backup_exe, "archive-init", self.primary, self.archive), self.args.command_timeout)

    def _start_renewer(self) -> None:
        """Starts lease renewal independently of potentially long archive I/O."""
        self.renew_stop.clear()
        self.renew_failure = None

        def renew_loop() -> None:
            """Renews the current immutable term until failover or shutdown."""
            interval = self.args.lease_ms / 3000.0
            while not self.renew_stop.wait(interval):
                try:
                    self.expires_at = self.witness.renew(self.epoch, self.node_id)
                except BaseException as exc:
                    self.renew_failure = exc
                    return

        self.renew_thread = threading.Thread(target=renew_loop, name="minisql-ha-lease-renewer", daemon=True)
        self.renew_thread.start()

    def _stop_renewer(self) -> None:
        """Stops and joins the current term's lease-renewal thread."""
        self.renew_stop.set()
        if self.renew_thread is not None:
            self.renew_thread.join(timeout=5)
        self.renew_thread = None

    def _acquire_and_start(self, database: Path, port: int, node_id: int) -> None:
        """Acquires a new term, persists it, and starts its fenced server."""
        epoch, expires_at = self.witness.acquire(node_id)
        write_database_epoch(database, epoch, node_id)
        process = start_fenced_server(self.args.server_exe, database, port, self.args.maximum_clients, self.witness, epoch, node_id, self.args.command_timeout)
        self.epoch, self.expires_at, self.node_id, self.process = epoch, expires_at, node_id, process
        self.backend = Backend(database, port, epoch, 0, process)
        self.proxy.set_backend(self.backend)

    def _replicate(self) -> None:
        """Exports the durable prefix and refreshes the alternate offline standby."""
        assert self.backend is not None
        run_checked(command_for(self.args.backup_exe, "archive-wal-live", self.backend.slot, self.archive), self.args.command_timeout)
        generation, lsn = verify_archive(self.args.backup_exe, self.archive)
        target = self.slot_root / f"slot-{self.slot_index % 2}"
        self.slot_index += 1
        if self.backend.slot.resolve() == target.resolve():
            target = self.slot_root / f"slot-{self.slot_index % 2}"
            self.slot_index += 1
        remove_owned_slot(self.slot_root, target)
        completed = run_checked(command_for(self.args.backup_exe, "standby-materialize", self.archive, target), self.args.command_timeout)
        materialized_generation, materialized_lsn = parse_report(completed.stdout)
        if materialized_generation != generation or materialized_lsn != lsn:
            raise ReplicaError("materialized standby does not match verified archive")
        previous = self.standby
        self.standby = (target, generation, lsn)
        if previous and previous[0] != self.backend.slot and previous[0] != target:
            remove_owned_slot(self.slot_root, previous[0])

    def _failover(self) -> None:
        """Waits out the old lease, promotes the standby, and switches new clients."""
        if self.standby is None:
            raise ReplicaError("leader failed before a standby was materialized")
        self._stop_renewer()
        old_process = self.process
        terminate(old_process)
        safe_after = self.witness.expiry() + self.witness.clock_skew_ms + 5
        remaining = safe_after - (time.time_ns() // 1_000_000)
        if remaining > 0:
            time.sleep(remaining / 1000.0)
        promoted = self.standby[0]
        run_checked(command_for(self.args.backup_exe, "standby-promote", promoted), self.args.command_timeout)
        self.node_id += 1
        backend_port = self.args.backend_port_b if self.failovers % 2 == 0 else self.args.backend_port_a
        self._acquire_and_start(promoted, backend_port, self.node_id)
        self._start_renewer()
        self.standby = None
        self.failovers += 1

    def run(self) -> int:
        """Runs the controller until interrupted, timed out, or fatally degraded."""
        self._prepare_archive()
        self.proxy.start()
        started = time.monotonic()
        self._acquire_and_start(self.primary, self.args.backend_port_a, self.node_id)
        self._start_renewer()
        next_replication = 0.0
        self._status("starting", True)
        try:
            while not self.stop:
                now = time.monotonic()
                if self.args.run_seconds and now - started >= self.args.run_seconds:
                    break
                if self.process is None or self.process.poll() is not None:
                    self._status("failing-over", False, "leader process stopped")
                    self._failover()
                    next_replication = 0.0
                    self._status("serving", True, "standby promoted")
                    if self.args.max_failovers and self.failovers >= self.args.max_failovers:
                        break
                if self.renew_failure is not None:
                    raise ReplicaError(f"leader lease renewal failed: {self.renew_failure}")
                if now >= next_replication:
                    self._replicate()
                    next_replication = time.monotonic() + self.args.replication_ms / 1000.0
                self._status("serving", True)
                time.sleep(0.05)
            self._status("stopped", True)
            return 0
        finally:
            self._stop_renewer()
            self.proxy.close()
            terminate(self.process)


def self_test() -> int:
    """Checks record integrity and rejects corruption without native binaries."""
    epoch = encode_epoch(7, 11)
    lease = encode_lease(7, 11, 1_900_000_000_000)
    if decode_record(epoch, EPOCH_MAGIC, EPOCH_SIZE) != (7, 11):
        raise ReplicaError("epoch round trip failed")
    if decode_record(lease, LEASE_MAGIC, LEASE_SIZE) != (7, 11, 1_900_000_000_000):
        raise ReplicaError("lease round trip failed")
    damaged = bytearray(lease)
    damaged[20] ^= 1
    try:
        decode_record(bytes(damaged), LEASE_MAGIC, LEASE_SIZE)
        raise ReplicaError("corrupt lease was accepted")
    except ReplicaError as exc:
        if "validation" not in str(exc):
            raise
    print("MiniSQL automatic HA controller self-test: SUCCESS")
    return 0


def build_parser() -> argparse.ArgumentParser:
    """Builds the controller command-line interface."""
    root = argparse.ArgumentParser(description=__doc__)
    sub = root.add_subparsers(dest="mode", required=True)
    sub.add_parser("self-test", help="verify the fencing record codec")
    write = sub.add_parser("write-epoch", help="write a database leader epoch offline")
    write.add_argument("--database", type=Path, required=True)
    write.add_argument("--epoch", type=int, required=True)
    write.add_argument("--node-id", type=int, required=True)
    run = sub.add_parser("run", help="run local automatic failover and stable endpoint")
    run.add_argument("--primary-db", type=Path, required=True)
    run.add_argument("--archive", type=Path, required=True)
    run.add_argument("--slot-root", type=Path, required=True)
    run.add_argument("--witness-dir", type=Path, required=True)
    run.add_argument("--server-exe", type=Path, required=True)
    run.add_argument("--backup-exe", type=Path, required=True)
    run.add_argument("--proxy-port", type=int, required=True)
    run.add_argument("--backend-port-a", type=int, default=0)
    run.add_argument("--backend-port-b", type=int, default=0)
    run.add_argument("--maximum-clients", type=int, default=32)
    run.add_argument("--node-id", type=int, default=1)
    run.add_argument("--lease-ms", type=int, default=5000)
    run.add_argument("--clock-skew-ms", type=int, default=250)
    run.add_argument("--replication-ms", type=int, default=2000)
    run.add_argument("--command-timeout", type=float, default=300.0)
    run.add_argument("--status-file", type=Path)
    run.add_argument("--run-seconds", type=float, default=0)
    run.add_argument("--max-failovers", type=int, default=0)
    return root


def main() -> int:
    """Dispatches controller modes and converts operational failures to exit 1."""
    args = build_parser().parse_args()
    try:
        if args.mode == "self-test":
            return self_test()
        if args.mode == "write-epoch":
            write_database_epoch(args.database.resolve(), args.epoch, args.node_id)
            print(f"MiniSQL leader epoch written: epoch={args.epoch} node={args.node_id}")
            return 0
        if args.backend_port_a == 0:
            args.backend_port_a = free_port()
        if args.backend_port_b == 0:
            args.backend_port_b = free_port()
        if len({args.proxy_port, args.backend_port_a, args.backend_port_b}) != 3:
            raise ReplicaError("proxy and backend ports must be distinct")
        controller = HAController(args)

        def request_stop(_signum: int, _frame: object) -> None:
            """Turns SIGINT or SIGTERM into a bounded controller shutdown."""
            controller.stop = True

        signal.signal(signal.SIGINT, request_stop)
        signal.signal(signal.SIGTERM, request_stop)
        return controller.run()
    except (OSError, ReplicaError, subprocess.TimeoutExpired) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
