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

"""MiniSQL TLS 1.3/X.509 transport terminator.

The MiniSQL wire protocol remains unchanged.  This small standard-library
sidecar protects it with a standards-compatible TLS 1.3 connection and keeps
its plaintext backend leg restricted to loopback.  It can run in two modes:

* server: TLS listener -> loopback MiniSQL server
* client: loopback listener -> verified remote TLS server

No third-party Python package is required.
"""
from __future__ import annotations

import argparse
import ipaddress
import os
import socket
import ssl
import sys
import threading
import time
from pathlib import Path

BUFFER_SIZE = 64 * 1024


def loopback_only(host: str, label: str) -> None:
    """Rejects a host unless every resolved address is loopback, preventing plaintext exposure."""
    try:
        addresses = {info[4][0] for info in socket.getaddrinfo(host, None)}
    except OSError as exc:
        raise SystemExit(f"{label} cannot be resolved: {host}: {exc}") from exc
    if not addresses:
        raise SystemExit(f"{label} has no resolved addresses: {host}")
    for address in addresses:
        try:
            if not ipaddress.ip_address(address.split("%", 1)[0]).is_loopback:
                raise SystemExit(f"{label} must resolve only to loopback addresses: {host} -> {address}")
        except ValueError as exc:
            raise SystemExit(f"{label} resolved to an invalid address: {address}") from exc


def touch_ready(path: str | None, message: str) -> None:
    """Atomically creates the optional readiness marker after its parent directory exists."""
    if not path:
        return
    target = Path(path)
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = target.with_suffix(target.suffix + ".tmp")
    temporary.write_text(message + "\n", encoding="utf-8")
    os.replace(temporary, target)


def send_fragmented(destination: socket.socket, data: bytes, chunk_size: int, delay_seconds: float) -> None:
    """Forward one plaintext read in deterministic bounded fragments.

    Production defaults preserve the previous sendall behavior. Acceptance can
    request tiny fragments to prove that MiniSQL framing never assumes one TCP
    read per protocol header or payload.
    """
    if chunk_size >= len(data):
        destination.sendall(data)
        return
    for offset in range(0, len(data), chunk_size):
        destination.sendall(data[offset:offset + chunk_size])
        if delay_seconds > 0 and offset + chunk_size < len(data):
            time.sleep(delay_seconds)


def relay(
    left: socket.socket,
    right: socket.socket,
    chunk_size: int,
    delay_seconds: float,
    left_name: str = "left",
    right_name: str = "right",
) -> None:
    """Runs two directional blocking pumps and closes both endpoints when either direction finishes."""
    sockets = (left, right)
    names = {left: left_name, right: right_name}
    forwarded = {left: 0, right: 0}
    stopped = threading.Event()
    reason = ["shutdown"]

    def pump(source: socket.socket, destination: socket.socket) -> None:
        """Forwards one relay direction, records byte counts and wakes the peer on completion."""
        while not stopped.is_set():
            try:
                data = source.recv(BUFFER_SIZE)
            except (ConnectionError, OSError, ssl.SSLError) as exc:
                if not stopped.is_set():
                    reason[0] = f"{names[source]} recv error: {exc}"
                break
            if not data:
                if not stopped.is_set():
                    reason[0] = f"{names[source]} EOF"
                break
            try:
                send_fragmented(destination, data, chunk_size, delay_seconds)
                forwarded[source] += len(data)
            except (ConnectionError, OSError, ssl.SSLError) as exc:
                if not stopped.is_set():
                    reason[0] = f"{names[source]}->{names[destination]} send error: {exc}"
                break
        if not stopped.is_set():
            stopped.set()
            for item in sockets:
                try:
                    item.shutdown(socket.SHUT_RDWR)
                except OSError:
                    pass

    left_to_right = threading.Thread(target=pump, args=(left, right), daemon=True)
    right_to_left = threading.Thread(target=pump, args=(right, left), daemon=True)
    try:
        left_to_right.start()
        right_to_left.start()
        left_to_right.join()
        right_to_left.join()
    finally:
        if os.environ.get("MINISQL_TLS_RELAY_DEBUG") == "1":
            print(
                f"MiniSQL TLS relay ended: {reason[0]}; "
                f"{left_name}->{right_name}={forwarded[left]} "
                f"{right_name}->{left_name}={forwarded[right]}",
                flush=True,
            )
        for item in sockets:
            try:
                item.shutdown(socket.SHUT_RDWR)
            except OSError:
                pass
            try:
                item.close()
            except OSError:
                pass


def server_context(cert: str, key: str) -> ssl.SSLContext:
    """Creates a TLS-1.3-only server context and loads its certificate chain."""
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.minimum_version = ssl.TLSVersion.TLSv1_3
    context.maximum_version = ssl.TLSVersion.TLSv1_3
    context.options |= ssl.OP_NO_COMPRESSION
    context.load_cert_chain(certfile=cert, keyfile=key)
    return context


def client_context(ca: str) -> ssl.SSLContext:
    """Creates a TLS-1.3-only client context with mandatory CA and hostname verification."""
    context = ssl.create_default_context(ssl.Purpose.SERVER_AUTH, cafile=ca)
    context.minimum_version = ssl.TLSVersion.TLSv1_3
    context.maximum_version = ssl.TLSVersion.TLSv1_3
    context.options |= ssl.OP_NO_COMPRESSION
    context.check_hostname = True
    context.verify_mode = ssl.CERT_REQUIRED
    return context


def serve_connection(
    raw: socket.socket,
    context: ssl.SSLContext,
    backend_host: str,
    backend_port: int,
    relay_chunk_size: int,
    relay_delay_seconds: float,
) -> None:
    """Terminates one inbound TLS connection and relays it to the loopback MiniSQL backend."""
    try:
        with context.wrap_socket(raw, server_side=True) as secure:
            if secure.version() != "TLSv1.3":
                raise ssl.SSLError(f"negotiated unexpected TLS version {secure.version()!r}")
            backend = socket.create_connection((backend_host, backend_port), timeout=15.0)
            backend.settimeout(None)
            print(f"MiniSQL TLS server connection: TLSv1.3 cipher={secure.cipher()[0]}", flush=True)
            relay(secure, backend, relay_chunk_size, relay_delay_seconds, "tls-client", "backend")
    except (OSError, ssl.SSLError) as exc:
        print(f"MiniSQL TLS server connection rejected: {exc}", file=sys.stderr, flush=True)
        try:
            raw.close()
        except OSError:
            pass


def run_server(args: argparse.Namespace) -> int:
    """Runs the TLS server terminator with one worker thread per accepted connection."""
    loopback_only(args.backend_host, "backend host")
    context = server_context(args.cert, args.key)
    listener = socket.socket(socket.AF_INET6 if ":" in args.listen_host else socket.AF_INET, socket.SOCK_STREAM)
    listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    listener.bind((args.listen_host, args.listen_port))
    listener.listen(args.backlog)
    actual_port = listener.getsockname()[1]
    message = f"MiniSQL TLS 1.3 server ready {args.listen_host}:{actual_port} -> {args.backend_host}:{args.backend_port}"
    print(message, flush=True)
    touch_ready(args.ready_file, message)
    accepted = 0
    threads: list[threading.Thread] = []
    try:
        while args.max_connections <= 0 or accepted < args.max_connections:
            raw, _ = listener.accept()
            accepted += 1
            thread = threading.Thread(
                target=serve_connection,
                args=(
                    raw,
                    context,
                    args.backend_host,
                    args.backend_port,
                    args.relay_chunk_size,
                    args.relay_delay_ms / 1000.0,
                ),
                daemon=True,
            )
            thread.start()
            threads.append(thread)
    except KeyboardInterrupt:
        pass
    finally:
        listener.close()
        for thread in threads:
            if args.max_connections > 0:
                # A bounded sidecar has promised to serve every accepted
                # connection. Do not let process exit truncate a deliberately
                # fragmented final relay.
                thread.join()
            else:
                thread.join(timeout=2.0)
    return 0


def client_connection(
    raw: socket.socket,
    context: ssl.SSLContext,
    remote_host: str,
    remote_port: int,
    server_name: str,
    relay_chunk_size: int,
    relay_delay_seconds: float,
) -> None:
    """Accepts one local plaintext client and relays it through a verified TLS connection."""
    try:
        outbound = socket.create_connection((remote_host, remote_port), timeout=15.0)
        secure = context.wrap_socket(outbound, server_hostname=server_name)
        if secure.version() != "TLSv1.3":
            raise ssl.SSLError(f"negotiated unexpected TLS version {secure.version()!r}")
        # create_connection's timeout is only for connect/handshake. Leaving it
        # on the SSLSocket can turn a TLS post-handshake selector wakeup into an
        # application-data timeout before the local client request is relayed.
        secure.settimeout(None)
        print(f"MiniSQL TLS client connection: TLSv1.3 cipher={secure.cipher()[0]}", flush=True)
        relay(raw, secure, relay_chunk_size, relay_delay_seconds, "local-client", "tls-server")
    except (OSError, ssl.SSLError) as exc:
        print(f"MiniSQL TLS client connection failed: {exc}", file=sys.stderr, flush=True)
        try:
            raw.close()
        except OSError:
            pass


def run_client(args: argparse.Namespace) -> int:
    """Runs the loopback client sidecar and drains all bounded connection workers before exit."""
    loopback_only(args.listen_host, "client proxy listen host")
    context = client_context(args.ca)
    listener = socket.socket(socket.AF_INET6 if ":" in args.listen_host else socket.AF_INET, socket.SOCK_STREAM)
    listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    listener.bind((args.listen_host, args.listen_port))
    listener.listen(args.backlog)
    actual_port = listener.getsockname()[1]
    message = f"MiniSQL verified TLS 1.3 client proxy ready {args.listen_host}:{actual_port} -> {args.remote_host}:{args.remote_port} name={args.server_name}"
    print(message, flush=True)
    touch_ready(args.ready_file, message)
    accepted = 0
    threads: list[threading.Thread] = []
    try:
        while args.max_connections <= 0 or accepted < args.max_connections:
            raw, _ = listener.accept()
            accepted += 1
            thread = threading.Thread(
                target=client_connection,
                args=(
                    raw,
                    context,
                    args.remote_host,
                    args.remote_port,
                    args.server_name,
                    args.relay_chunk_size,
                    args.relay_delay_ms / 1000.0,
                ),
                daemon=True,
            )
            thread.start()
            threads.append(thread)
    except KeyboardInterrupt:
        pass
    finally:
        listener.close()
        for thread in threads:
            if args.max_connections > 0:
                thread.join()
            else:
                thread.join(timeout=2.0)
    return 0


def run_probe(args: argparse.Namespace) -> int:
    """Performs one verified TLS handshake and reports the negotiated protocol and cipher."""
    context = client_context(args.ca)
    try:
        with socket.create_connection((args.host, args.port), timeout=args.timeout) as raw:
            with context.wrap_socket(raw, server_hostname=args.server_name) as secure:
                if secure.version() != "TLSv1.3":
                    raise ssl.SSLError(f"unexpected protocol {secure.version()!r}")
                print(f"MiniSQL TLS probe: SUCCESS protocol={secure.version()} cipher={secure.cipher()[0]}")
                return 0
    except (OSError, ssl.SSLError) as exc:
        print(f"MiniSQL TLS probe: FAIL {exc}", file=sys.stderr)
        return 2


def parser() -> argparse.ArgumentParser:
    """Builds the command-line parser and all supported role-specific subcommands."""
    root = argparse.ArgumentParser(description=__doc__)
    sub = root.add_subparsers(dest="command", required=True)

    server = sub.add_parser("server", help="terminate TLS and forward to a loopback MiniSQL server")
    server.add_argument("--listen-host", default="127.0.0.1")
    server.add_argument("--listen-port", type=int, required=True)
    server.add_argument("--backend-host", default="127.0.0.1")
    server.add_argument("--backend-port", type=int, required=True)
    server.add_argument("--cert", required=True)
    server.add_argument("--key", required=True)
    server.add_argument("--ready-file")
    server.add_argument("--max-connections", type=int, default=0)
    server.add_argument("--backlog", type=int, default=64)
    server.add_argument("--relay-chunk-size", type=int, default=BUFFER_SIZE)
    server.add_argument("--relay-delay-ms", type=float, default=0.0)
    server.set_defaults(handler=run_server)

    client = sub.add_parser("client", help="expose a loopback plaintext port backed by verified TLS")
    client.add_argument("--listen-host", default="127.0.0.1")
    client.add_argument("--listen-port", type=int, required=True)
    client.add_argument("--remote-host", required=True)
    client.add_argument("--remote-port", type=int, required=True)
    client.add_argument("--server-name", required=True)
    client.add_argument("--ca", required=True)
    client.add_argument("--ready-file")
    client.add_argument("--max-connections", type=int, default=0)
    client.add_argument("--backlog", type=int, default=64)
    client.add_argument("--relay-chunk-size", type=int, default=BUFFER_SIZE)
    client.add_argument("--relay-delay-ms", type=float, default=0.0)
    client.set_defaults(handler=run_client)

    probe = sub.add_parser("probe", help="perform a verified TLS 1.3 handshake")
    probe.add_argument("--host", required=True)
    probe.add_argument("--port", type=int, required=True)
    probe.add_argument("--server-name", required=True)
    probe.add_argument("--ca", required=True)
    probe.add_argument("--timeout", type=float, default=10.0)
    probe.set_defaults(handler=run_probe)
    return root


def main() -> int:
    """Dispatches the selected command, translates known failures and returns a process exit status."""
    args = parser().parse_args()
    if hasattr(args, "listen_port") and not 0 <= args.listen_port <= 65535:
        raise SystemExit("listener port must be in range 0..65535")
    for name in ("backend_port", "remote_port", "port"):
        if hasattr(args, name) and not 1 <= getattr(args, name) <= 65535:
            raise SystemExit(f"{name.replace('_', ' ')} must be in range 1..65535")
    if hasattr(args, "max_connections") and args.max_connections < 0:
        raise SystemExit("max connections must be non-negative")
    if hasattr(args, "backlog") and args.backlog < 1:
        raise SystemExit("backlog must be positive")
    if hasattr(args, "relay_chunk_size") and not 1 <= args.relay_chunk_size <= BUFFER_SIZE:
        raise SystemExit(f"relay chunk size must be 1..{BUFFER_SIZE}")
    if hasattr(args, "relay_delay_ms") and not 0 <= args.relay_delay_ms <= 1000:
        raise SystemExit("relay delay must be 0..1000 milliseconds")
    return int(args.handler(args))


if __name__ == "__main__":
    raise SystemExit(main())
