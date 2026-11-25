# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see LICENSE for details.
"""MiniSQL wire-protocol v1, secure authentication, TLS, and row streaming."""

from __future__ import annotations

from dataclasses import asdict, dataclass
import hashlib
import hmac
import json
import re
import socket
import ssl
import struct
import threading
import tempfile
from typing import Final

from .errors import (
    DataError,
    DatabaseError,
    IntegrityError,
    InterfaceError,
    InternalError,
    OperationalError,
    ProgrammingError,
    NotSupportedError,
)


TYPE_HELLO: Final = 1
TYPE_QUERY: Final = 2
TYPE_PING: Final = 3
TYPE_CLOSE: Final = 4
TYPE_AUTH_BEGIN: Final = 5
TYPE_AUTH_CHALLENGE: Final = 6
TYPE_AUTH_PROOF: Final = 7
TYPE_AUTH_OK: Final = 8
TYPE_CANCEL: Final = 9
TYPE_RESPONSE: Final = 100
TYPE_PONG: Final = 101
TYPE_ERROR: Final = 102
STATUS_COMMAND: Final = 1
STATUS_ROWS: Final = 2
STATUS_ERROR: Final = 3
FLAG_SECURE: Final = 1
FLAG_MORE: Final = 2
FLAG_RESULT_START: Final = 4
FLAG_METADATA: Final = 8
HEADER_BYTES: Final = 32
MAX_PAYLOAD: Final = 16 * 1024 * 1024
TLS_CIPHER: Final = "TLS_AES_256_GCM_SHA384"


def _crc32c_table() -> tuple[int, ...]:
    """Builds the reflected Castagnoli table once at module import."""
    values: list[int] = []
    polynomial = 0x82F63B78
    for byte in range(256):
        current = byte
        for _ in range(8):
            current = (current >> 1) ^ (polynomial if current & 1 else 0)
        values.append(current & 0xFFFFFFFF)
    return tuple(values)


_CRC32C_TABLE = _crc32c_table()


def crc32c(data: bytes | bytearray) -> int:
    """Returns the protocol's CRC-32C checksum for *data*."""
    checksum = 0xFFFFFFFF
    for value in data:
        checksum = _CRC32C_TABLE[(checksum ^ value) & 0xFF] ^ (checksum >> 8)
    return checksum ^ 0xFFFFFFFF


@dataclass(frozen=True)
class Message:
    """One validated logical MiniSQL message."""

    message_type: int
    flags: int
    request_id: int
    payload: bytes


@dataclass(frozen=True)
class Condition:
    """Structured SQL warning independent of the human-readable diagnostic text."""

    sqlstate: str
    code: int
    message: str


@dataclass(frozen=True)
class OutputParameter:
    """Successful outer CALL output at its one-based declaration ordinal."""

    ordinal: int
    name: str
    type_kind: int
    value: str | None


@dataclass(frozen=True)
class Response:
    """One decoded command or bounded row response frame."""

    status: int
    command: str
    columns: tuple[str, ...]
    rows: tuple[tuple[str | None, ...], ...]
    affected_rows: int
    message: str
    error_code: int
    result_start: bool = False
    sqlstate: str = ""
    warnings: tuple[Condition, ...] = ()
    column_types: tuple[int, ...] = ()
    outputs: tuple[OutputParameter, ...] = ()
    extended: bool = False


class Query:
    """Owns a response and its continuation frames until drained or closed."""

    def __init__(self, protocol: Protocol, request_id: int, first: Response, more: bool) -> None:
        """Stores the first response and continuation ownership state."""
        self._protocol = protocol
        self.request_id = request_id
        self.first = first
        self.more = more
        self._first_pending = True
        self._closed = False
        self._pending_result: Response | None = None
        self._result_ended = False
        self.warnings = list(first.warnings)

    def next_frame(self) -> Response | None:
        """Returns the next batch of the current result, stopping at its boundary."""
        if self._closed or self._result_ended:
            return None
        if self._first_pending:
            self._first_pending = False
            return self.first
        if not self.more:
            self._result_ended = True
            return None
        response = self._protocol._continuation(self)
        self.warnings.extend(response.warnings)
        if response.result_start:
            self._pending_result = response
            self._result_ended = True
            return None
        if response.status != self.first.status or response.columns != self.first.columns:
            raise InternalError("MiniSQL continuation schema changed without a result boundary")
        return response

    def next_result(self) -> bool:
        """Discards unread rows and advances to the next separate CALL result."""
        if self._closed:
            return False
        while self.next_frame() is not None:
            pass
        if self._pending_result is None:
            self._closed = True
            return False
        self.first = self._pending_result
        self._pending_result = None
        if self.first.status == STATUS_ERROR:
            self._closed = True
            raise Protocol._server_error(self.first)
        self._first_pending = True
        self._result_ended = False
        return True

    def close(self) -> None:
        """Drains every result so the connection remains usable after early close."""
        while True:
            while self.next_frame() is not None:
                pass
            if not self.next_result():
                break
        self._closed = True


class BufferedQuery(Query):
    """Replays a drained CALL while its output parameters are fetched separately."""

    def __init__(self, frames: list[Response]) -> None:
        """Retains all CALL frames; used only by the deliberately buffered callproc API."""
        if not frames:
            raise InternalError("Cannot buffer an empty MiniSQL result stream")
        self._frames = iter(frames[1:])
        self._remaining = len(frames) - 1
        super().__init__(self, 0, frames[0], self._remaining > 0)

    def _continuation(self, query: Query) -> Response:
        """Supplies a local continuation using the same result-boundary rules."""
        response = next(self._frames)
        self._remaining -= 1
        query.more = self._remaining > 0
        return response


class ResultSpool:
    """Stores bounded frames in a private temporary file instead of retaining a CALL in RAM."""

    def __init__(self) -> None:
        """Creates storage that spills after one MiB and is removed when its owner closes."""
        self._file = tempfile.SpooledTemporaryFile(max_size=1024 * 1024, mode="w+b")
        self._count = 0

    def append(self, response: Response) -> None:
        """Serializes one bounded response without executable object deserialization."""
        if self._file is None:
            raise InterfaceError("Result spool is closed")
        payload = json.dumps(asdict(response), ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        self._file.write(struct.pack("<I", len(payload)))
        self._file.write(payload)
        self._count += 1

    def finish(self) -> Query:
        """Transfers storage ownership to a forward-only replay query."""
        if self._file is None or not self._count:
            raise InternalError("Cannot replay an empty result spool")
        self._file.seek(0)
        query = SpoolQuery(self._file, self._count)
        self._file = None
        return query

    def close(self) -> None:
        """Closes incomplete storage, deleting any temporary spill file."""
        if getattr(self, "_file", None) is not None:
            self._file.close()
            self._file = None

    def __del__(self) -> None:
        """Reclaims abandoned storage without executing database operations."""
        self.close()


class SpoolQuery(Query):
    """Replays a completed CALL while keeping at most one bounded frame in memory."""

    def __init__(self, file, count: int) -> None:
        """Takes exclusive ownership of a validated local frame spool."""
        self._file = file
        self._remaining = count
        try:
            first = self._read()
        except BaseException:
            self._file.close()
            raise
        super().__init__(self, 0, first, self._remaining > 0)

    def _read(self) -> Response:
        """Reads one safe JSON frame with an explicit length bound."""
        header = self._file.read(4)
        if len(header) != 4:
            raise InternalError("Truncated result spool")
        length, = struct.unpack("<I", header)
        # JSON escaping can expand a valid maximum-size wire frame sixfold.
        if length > MAX_PAYLOAD * 6 + 65536:
            raise InternalError("Invalid result spool frame length")
        payload = self._file.read(length)
        if len(payload) != length:
            raise InternalError("Truncated result spool frame")
        data = json.loads(payload)
        data["columns"] = tuple(data["columns"])
        data["rows"] = tuple(tuple(row) for row in data["rows"])
        data["warnings"] = tuple(Condition(**value) for value in data["warnings"])
        data["column_types"] = tuple(data["column_types"])
        data["outputs"] = tuple(OutputParameter(**value) for value in data["outputs"])
        self._remaining -= 1
        return Response(**data)

    def _continuation(self, query: Query) -> Response:
        """Supplies local continuation frames using the live stream's boundary rules."""
        response = self._read()
        query.more = self._remaining > 0
        return response

    def next_result(self) -> bool:
        """Releases the temporary file at exhaustion or a deferred terminal error."""
        try:
            available = super().next_result()
            if not available:
                self._file.close()
            return available
        except BaseException:
            self._file.close()
            raise

    def close(self) -> None:
        """Drains local results and always removes temporary storage."""
        try:
            super().close()
        finally:
            self._file.close()

    def __del__(self) -> None:
        """Reclaims an abandoned cursor's local storage without network side effects."""
        self._file.close()


class Protocol:
    """Serial MiniSQL v1 connection with optional TLS and secure framing."""

    def __init__(self, transport: socket.socket) -> None:
        """Initializes framing, sequence, and single-stream ownership state."""
        self._socket = transport
        self._lock = threading.RLock()
        self._next_request_id = 1
        self._send_key: bytes | None = None
        self._receive_key: bytes | None = None
        self._send_sequence = 0
        self._receive_sequence = 0
        self._secure = False
        self._closed = False
        self._active_query: Query | None = None
        self.session_id: int | None = None
        self.extended_results = False
        self.warnings: list[Condition] = []

    @classmethod
    def open(
        cls,
        host: str,
        port: int,
        *,
        user: str | None,
        password: str,
        tls: bool,
        server_name: str,
        pin_sha256: str | None,
        trust_server_certificate: bool,
        ca_file: str | None,
        connect_timeout: float | None,
        socket_timeout: float | None,
    ) -> Protocol:
        """Connects and completes HELLO, TLS, and optional password authentication."""
        try:
            raw = socket.create_connection((host, port), timeout=connect_timeout)
            raw.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
            raw.settimeout(socket_timeout)
            transport: socket.socket = raw
            if tls:
                transport = cls._wrap_tls(
                    raw, server_name, pin_sha256, trust_server_certificate, ca_file
                )
            protocol = cls(transport)
            try:
                protocol._hello()
                if user is not None:
                    protocol._authenticate(user, password)
                return protocol
            except Exception:
                protocol._close_transport()
                raise
        except (OSError, ssl.SSLError) as exc:
            raise OperationalError(f"Could not connect to MiniSQL at {host}:{port}: {exc}") from exc

    @staticmethod
    def _wrap_tls(
        raw: socket.socket,
        server_name: str,
        pin_sha256: str | None,
        trust_server_certificate: bool,
        ca_file: str | None,
    ) -> ssl.SSLSocket:
        """Negotiates TLS 1.3 and validates PKIX/hostname plus an optional leaf pin."""
        if trust_server_certificate:
            context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
            context.check_hostname = False
            context.verify_mode = ssl.CERT_NONE
        else:
            context = ssl.create_default_context(cafile=ca_file)
            context.check_hostname = True
        context.minimum_version = ssl.TLSVersion.TLSv1_3
        context.maximum_version = ssl.TLSVersion.TLSv1_3
        wrapped = context.wrap_socket(raw, server_hostname=server_name)
        negotiated = wrapped.cipher()
        if negotiated is None or negotiated[0] != TLS_CIPHER:
            wrapped.close()
            raise OperationalError(
                f"MiniSQL requires {TLS_CIPHER}, negotiated {negotiated[0] if negotiated else 'none'}"
            )
        if pin_sha256 is not None:
            certificate = wrapped.getpeercert(binary_form=True)
            actual = hashlib.sha256(certificate).hexdigest()
            if not hmac.compare_digest(actual, pin_sha256):
                wrapped.close()
                raise OperationalError("MiniSQL TLS certificate pin mismatch")
        return wrapped

    def _hello(self) -> None:
        """Negotiates MiniSQL protocol version 1 before other messages."""
        request_id = self._next_id()
        self._write(Message(TYPE_HELLO, 0, request_id, b"MiniSQL/1; capabilities=results-v2"))
        message = self._read_expected(request_id)
        response = self._decode_response(message)
        if (
            message.message_type != TYPE_RESPONSE
            or response.status != STATUS_COMMAND
            or response.command != "HELLO"
        ):
            raise OperationalError("MiniSQL HELLO handshake was rejected")
        self.extended_results = "; capabilities=results-v2" in response.message
        for field in response.message.split(";"):
            field = field.strip()
            if not field.startswith("session="):
                continue
            try:
                parsed = int(field.removeprefix("session="))
            except ValueError:
                break
            if 1 <= parsed <= 0xFFFFFFFF:
                self.session_id = parsed
            break

    def _authenticate(self, user: str, password: str) -> None:
        """Completes challenge/response and enables the inner AES-256-GCM layer."""
        try:
            from cryptography.hazmat.primitives.ciphers.aead import AESGCM  # noqa: F401
        except ImportError as exc:
            raise InterfaceError(
                "Password authentication requires the 'cryptography' package"
            ) from exc
        user_bytes = user.encode("utf-8")
        if not 1 <= len(user_bytes) <= 128:
            raise InterfaceError("MiniSQL user names must contain 1..128 UTF-8 bytes")
        begin_id = self._next_id()
        self._write(Message(TYPE_AUTH_BEGIN, 0, begin_id, struct.pack("<H", len(user_bytes)) + user_bytes))
        challenge = self._read_expected(begin_id)
        if challenge.message_type != TYPE_AUTH_CHALLENGE or len(challenge.payload) not in (52, 56):
            raise OperationalError("MiniSQL authentication challenge was rejected")
        iterations, = struct.unpack_from("<I", challenge.payload)
        if not 10_000 <= iterations <= 5_000_000:
            raise OperationalError("MiniSQL authentication work factor is invalid")
        salt = challenge.payload[4:20]
        nonce = challenge.payload[20:52]
        scheme = 1 if len(challenge.payload) == 52 else struct.unpack_from("<H", challenge.payload, 52)[0]
        if scheme not in (1, 2) or (len(challenge.payload) == 56 and challenge.payload[54:56] != b"\0\0"):
            raise OperationalError("MiniSQL authentication scheme is invalid")
        verifier = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, iterations, 32)
        session_secret = verifier
        if scheme == 2:
            transcript = b"MiniSQL-AUTH-2|" + user.encode("utf-8") + b"|" + nonce
            client_key = hmac.new(verifier, b"MiniSQL Client Key", hashlib.sha256).digest()
            stored_key = hashlib.sha256(client_key).digest()
            server_key = hmac.new(verifier, b"MiniSQL Server Key", hashlib.sha256).digest()
            signature = hmac.new(stored_key, transcript, hashlib.sha256).digest()
            proof = bytes(left ^ right for left, right in zip(client_key, signature))
            expected = hmac.new(server_key, transcript, hashlib.sha256).digest()
            session_secret = hmac.new(
                server_key, b"MiniSQL-SESSION-2|" + transcript + stored_key, hashlib.sha256
            ).digest()
        else:
            proof = self._auth_value(verifier, nonce, user, "client")
            expected = self._auth_value(verifier, nonce, user, "server")
        proof_id = self._next_id()
        self._write(Message(TYPE_AUTH_PROOF, 0, proof_id, proof))
        accepted = self._read_expected(proof_id)
        if accepted.message_type != TYPE_AUTH_OK or not hmac.compare_digest(accepted.payload, expected):
            raise OperationalError("MiniSQL authentication failed")
        self._send_key = self._auth_value(session_secret, nonce, user, "client-to-server", "MiniSQL-TRANSPORT-1|")
        self._receive_key = self._auth_value(session_secret, nonce, user, "server-to-client", "MiniSQL-TRANSPORT-1|")
        self._secure = True

    @staticmethod
    def _auth_value(
        verifier: bytes,
        nonce: bytes,
        user: str,
        label: str,
        prefix: str = "MiniSQL-AUTH-1|",
    ) -> bytes:
        """Derives one domain-separated authentication or transport value."""
        context = f"{prefix}{label}|{user}".encode("utf-8") + nonce
        return hashlib.pbkdf2_hmac("sha256", verifier, context, 1, 32)

    def query(self, sql: str) -> Query:
        """Starts exactly one SQL statement and returns its streaming response."""
        with self._lock:
            self._ensure_open()
            if self._active_query is not None:
                raise InterfaceError("Consume or close the active MiniSQL cursor first")
            try:
                request_id = self._next_id()
                self._write(Message(TYPE_QUERY, FLAG_METADATA if self.extended_results else 0, request_id, sql.encode("utf-8")))
                message = self._read_expected(request_id)
                first = self._decode_response(message)
                self.warnings = list(first.warnings)
                if message.message_type == TYPE_ERROR or first.status == STATUS_ERROR:
                    raise self._server_error(first)
                query = Query(self, request_id, first, bool(message.flags & FLAG_MORE))
                self.warnings = query.warnings
                if query.more:
                    self._active_query = query
                return query
            except DatabaseError:
                raise
            except (OSError, ssl.SSLError, UnicodeError) as exc:
                raise OperationalError(f"MiniSQL query transport failed: {exc}") from exc

    def ping(self) -> bool:
        """Returns whether a PING/PONG exchange succeeds."""
        with self._lock:
            self._ensure_open()
            if self._active_query is not None:
                return False
            try:
                request_id = self._next_id()
                self._write(Message(TYPE_PING, 0, request_id, b""))
                return self._read_expected(request_id).message_type == TYPE_PONG
            except (OSError, ssl.SSLError, OperationalError):
                return False

    def cancel_session(self, session_id: int) -> Response:
        """Requests cancellation through this separate administrative connection."""
        if not isinstance(session_id, int) or not 1 <= session_id <= 0xFFFFFFFF:
            raise InterfaceError("session_id must be a positive U32")
        with self._lock:
            self._ensure_open()
            if self._active_query is not None:
                raise InterfaceError("Use a separate MiniSQL connection to cancel a query")
            try:
                request_id = self._next_id()
                self._write(Message(TYPE_CANCEL, 0, request_id, struct.pack("<I", session_id)))
                message = self._read_expected(request_id)
                response = self._decode_response(message)
                if message.message_type == TYPE_ERROR or response.status == STATUS_ERROR:
                    raise self._server_error(response)
                return response
            except DatabaseError:
                raise
            except (OSError, ssl.SSLError) as exc:
                raise OperationalError(f"MiniSQL cancellation transport failed: {exc}") from exc

    def _continuation(self, query: Query) -> Response:
        """Reads and validates the next frame owned by *query*."""
        with self._lock:
            if self._active_query is not query:
                raise InternalError("MiniSQL result stream is no longer active")
            try:
                message = self._read_expected(query.request_id)
                response = self._decode_response(message)
                query.more = bool(message.flags & FLAG_MORE)
                if not query.more:
                    self._active_query = None
                if message.message_type == TYPE_ERROR or response.status == STATUS_ERROR:
                    self._active_query = None
                    # A completed routine SELECT survives a later error. Defer
                    # that separate terminal result until the caller advances.
                    if not response.result_start or query.more:
                        query.warnings.extend(response.warnings)
                        query.more = False
                        raise self._server_error(response)
                return response
            except DatabaseError:
                raise
            except (OSError, ssl.SSLError) as exc:
                self._active_query = None
                raise OperationalError(f"MiniSQL continuation failed: {exc}") from exc

    def _write(self, logical: Message) -> None:
        """Protects, checksums, frames, and atomically writes one message."""
        message = self._protect(logical) if self._secure else logical
        header = bytearray(
            struct.pack(
                "<4sHHIIIIII",
                b"MSQL",
                1,
                message.message_type,
                message.flags,
                message.request_id,
                len(message.payload),
                crc32c(message.payload),
                0,
                0,
            )
        )
        struct.pack_into("<I", header, 24, crc32c(header))
        self._socket.sendall(header + message.payload)

    def _read(self) -> Message:
        """Reads one exact frame and validates header, size, CRC, and AEAD."""
        header = bytearray(self._read_exact(HEADER_BYTES))
        magic, version, message_type, flags, request_id, length, payload_crc, header_crc, reserved = (
            struct.unpack("<4sHHIIIIII", header)
        )
        if magic != b"MSQL" or version != 1 or reserved != 0:
            raise OperationalError("MiniSQL returned an unsupported frame header")
        struct.pack_into("<I", header, 24, 0)
        if crc32c(header) != header_crc:
            raise OperationalError("MiniSQL frame header CRC-32C mismatch")
        if not 0 <= length <= MAX_PAYLOAD:
            raise OperationalError("MiniSQL frame payload exceeds the protocol limit")
        payload = self._read_exact(length)
        if crc32c(payload) != payload_crc:
            raise OperationalError("MiniSQL frame payload CRC-32C mismatch")
        message = Message(message_type, flags, request_id, payload)
        return self._unprotect(message) if self._secure else message

    def _read_expected(self, request_id: int) -> Message:
        """Reads one frame and enforces its request identifier."""
        message = self._read()
        if message.request_id != request_id:
            raise OperationalError("MiniSQL returned an unexpected request identifier")
        return message

    def _protect(self, logical: Message) -> Message:
        """Encrypts one authenticated payload with the next send sequence."""
        from cryptography.hazmat.primitives.ciphers.aead import AESGCM

        assert self._send_key is not None
        flags = logical.flags | FLAG_SECURE
        sequence = self._send_sequence
        nonce = self._nonce(self._send_key, sequence)
        aad = struct.pack("<IIIQI", logical.message_type, flags, logical.request_id, sequence, len(logical.payload))
        encrypted = AESGCM(self._send_key).encrypt(nonce, logical.payload, aad)
        self._send_sequence += 1
        return Message(logical.message_type, flags, logical.request_id, struct.pack("<Q", sequence) + encrypted)

    def _unprotect(self, message: Message) -> Message:
        """Authenticates and decrypts the next receive-sequence payload."""
        from cryptography.hazmat.primitives.ciphers.aead import AESGCM

        assert self._receive_key is not None
        if not message.flags & FLAG_SECURE or len(message.payload) < 24:
            raise OperationalError("MiniSQL returned an unprotected authenticated frame")
        sequence, = struct.unpack_from("<Q", message.payload)
        if sequence != self._receive_sequence:
            raise OperationalError("MiniSQL secure sequence mismatch")
        encrypted = message.payload[8:]
        plaintext_length = len(encrypted) - 16
        aad = struct.pack(
            "<IIIQI", message.message_type, message.flags, message.request_id, sequence, plaintext_length
        )
        try:
            plaintext = AESGCM(self._receive_key).decrypt(
                self._nonce(self._receive_key, sequence), encrypted, aad
            )
        except Exception as exc:
            raise OperationalError("MiniSQL authenticated frame validation failed") from exc
        self._receive_sequence += 1
        return Message(message.message_type, message.flags & ~FLAG_SECURE, message.request_id, plaintext)

    @staticmethod
    def _nonce(key: bytes, sequence: int) -> bytes:
        """Builds the protocol's deterministic 96-bit AES-GCM nonce."""
        return bytes(value ^ 0xA5 for value in key[:4]) + struct.pack("<Q", sequence)

    @staticmethod
    def _decode_response(message: Message) -> Response:
        """Decodes bounded UTF-8 response fields and row arrays."""
        if message.message_type not in (TYPE_RESPONSE, TYPE_ERROR):
            raise OperationalError(f"Unexpected MiniSQL response type {message.message_type}")
        payload = memoryview(message.payload)
        if len(payload) < 24:
            raise OperationalError("MiniSQL returned a truncated response")
        status, reserved, column_count, row_count, affected, error_code, metadata_length = struct.unpack_from(
            "<HHIIIII", payload
        )
        if reserved or status not in (1, 2, 3) or metadata_length > len(payload) - 24 or column_count > 1024 or row_count > 512:
            raise OperationalError("MiniSQL returned invalid response counts")
        offset = 24

        def field() -> str:
            """Consumes one length-prefixed UTF-8 field from the payload."""
            nonlocal offset
            if offset + 4 > len(payload):
                raise OperationalError("MiniSQL returned a truncated response field")
            length, = struct.unpack_from("<I", payload, offset)
            offset += 4
            if offset + length > len(payload):
                raise OperationalError("MiniSQL returned an invalid response field length")
            try:
                value = bytes(payload[offset:offset + length]).decode("utf-8")
            except UnicodeDecodeError as exc:
                raise OperationalError("MiniSQL returned invalid UTF-8") from exc
            offset += length
            return value

        command = field()
        text = field()
        columns = tuple(field() for _ in range(column_count))
        rows = tuple(tuple(field() for _ in range(column_count)) for _ in range(row_count))
        if offset != len(payload) - metadata_length:
            raise OperationalError("MiniSQL returned trailing response bytes")
        state = ""
        warnings: list[Condition] = []
        types: tuple[int, ...] = ()
        outputs: list[OutputParameter] = []

        def number(format: str = "<I", maximum: int = MAX_PAYLOAD) -> int:
            """Reads one bounded numeric metadata field before allocation or iteration."""
            nonlocal offset
            size = struct.calcsize(format)
            if offset + size > len(payload):
                raise OperationalError("MiniSQL returned truncated metadata")
            value, = struct.unpack_from(format, payload, offset)
            offset += size
            if value > maximum:
                raise OperationalError("MiniSQL returned invalid metadata count")
            return value

        def sqlstate() -> str:
            """Validates exactly five uppercase ASCII SQLSTATE characters."""
            value = field()
            if re.fullmatch(r"[0-9A-Z]{5}", value) is None:
                raise OperationalError("MiniSQL returned invalid SQLSTATE")
            return value

        if metadata_length:
            if bytes(payload[offset:offset + 4]) != b"MDV1":
                raise OperationalError("MiniSQL returned unsupported metadata")
            offset += 4
            state = sqlstate()
            for _ in range(number(maximum=65535)):
                warning_state, code = sqlstate(), number(maximum=0xFFFFFFFF)
                warnings.append(Condition(warning_state, code, field()))
            bitmap_length = number()
            if bitmap_length != (column_count * row_count + 7) // 8 or offset + bitmap_length > len(payload):
                raise OperationalError("MiniSQL returned invalid NULL bitmap")
            bitmap = payload[offset:offset + bitmap_length]
            offset += bitmap_length
            rows = tuple(tuple(None if bitmap[(r * column_count + c) // 8] & (1 << ((r * column_count + c) % 8)) else value
                               for c, value in enumerate(row)) for r, row in enumerate(rows))
            type_count = number(maximum=1024)
            if type_count != column_count:
                raise OperationalError("MiniSQL returned invalid column type count")
            types = tuple(number("<H", 16) for _ in range(type_count))
            for _ in range(number(maximum=65535)):
                ordinal, name = number(maximum=65535), field()
                if ordinal == 0:
                    raise OperationalError("MiniSQL returned invalid output ordinal")
                kind, is_null, value = number("<H", 16), number("<H", 1), field()
                outputs.append(OutputParameter(ordinal, name, kind, None if is_null else value))
        if offset != len(payload):
            raise OperationalError("MiniSQL returned trailing metadata bytes")
        return Response(status, command, columns, rows, affected, text, error_code,
                        bool(message.flags & FLAG_RESULT_START), state, tuple(warnings), types, tuple(outputs), bool(metadata_length))

    def _read_exact(self, length: int) -> bytes:
        """Accumulates exactly *length* bytes across arbitrary TCP fragments."""
        output = bytearray(length)
        view = memoryview(output)
        offset = 0
        while offset < length:
            count = self._socket.recv_into(view[offset:])
            if count == 0:
                raise OperationalError("MiniSQL closed the connection during a frame")
            offset += count
        return bytes(output)

    @staticmethod
    def _server_error(response: Response) -> DatabaseError:
        """Maps stable MiniSQL error codes onto the PEP 249 hierarchy."""
        state = response.sqlstate
        if not state:
            match = re.match(r"SQLSTATE ([0-9A-Z]{5}): ", response.message)
            if match:
                state = match.group(1)
        if state and state != "00000":
            category = state[:2]
            kind = DatabaseError
            if category == "23": kind = IntegrityError
            elif category == "22": kind = DataError
            elif category in {"42", "37", "2A"}: kind = ProgrammingError
            elif category in {"08", "40", "53", "54", "57", "58"} or state in {"HYT00", "HYT01", "70100"}: kind = OperationalError
            elif category == "0A": kind = NotSupportedError
            return kind(response.message, response.error_code, state)
        if response.error_code in {9021, 9022}:
            return IntegrityError(response.message, response.error_code)
        if response.error_code == 9017:
            return DataError(response.message, response.error_code)
        if response.error_code in {9013, 9014, 9019, 9020, 9025}:
            return ProgrammingError(response.message, response.error_code)
        if response.error_code in {9011, 9012, 9023, 9027, 9028, 9029, 9030, 9033, 9034, 9038}:
            return OperationalError(response.message, response.error_code)
        return DatabaseError(response.message, response.error_code)

    def _next_id(self) -> int:
        """Allocates a nonzero wrapping 32-bit request identifier."""
        value = self._next_request_id
        self._next_request_id = (self._next_request_id + 1) & 0xFFFFFFFF
        if self._next_request_id == 0:
            self._next_request_id = 1
        return value

    def _ensure_open(self) -> None:
        """Raises when the protocol transport has already closed."""
        if self._closed:
            raise InterfaceError("MiniSQL connection is closed")

    def close(self) -> None:
        """Drains an active result, sends CLOSE, and releases the socket."""
        with self._lock:
            if self._closed:
                return
            if self._active_query is not None:
                try:
                    self._active_query.close()
                except DatabaseError:
                    pass
            try:
                request_id = self._next_id()
                self._write(Message(TYPE_CLOSE, 0, request_id, b""))
            except (OSError, ssl.SSLError, DatabaseError):
                pass
            self._close_transport()

    def _close_transport(self) -> None:
        """Closes the socket and clears retained secure-session material."""
        self._closed = True
        self._active_query = None
        try:
            self._socket.close()
        except OSError:
            pass
        self._send_key = None
        self._receive_key = None
