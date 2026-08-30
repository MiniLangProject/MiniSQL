# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see LICENSE for details.
"""PEP 249 Connection and Cursor implementation for MiniSQL."""

from __future__ import annotations

from collections import OrderedDict
from dataclasses import dataclass
import datetime as _datetime
from decimal import Decimal
import math
import re
import secrets
from typing import Any, Iterable, Iterator, Sequence
from urllib.parse import parse_qsl, unquote, urlparse

from .errors import (
    DataError,
    DatabaseError,
    Error,
    InterfaceError,
    InternalError,
    IntegrityError,
    NotSupportedError,
    OperationalError,
    ProgrammingError,
    Warning,
)
from .protocol import Protocol, Query, Response, STATUS_ROWS


MAX_PREPARED_PLANS = 128
MAX_BATCH_ROWS = 256
MAX_BATCH_BYTES = 768 * 1024
_EPOCH = _datetime.date(1970, 1, 1)


class DBAPITypeObject:
    """PEP 249 type object used by cursor descriptions."""

    def __init__(self, *values: type[Any]) -> None:
        """Stores the Python types represented by this DB-API category."""
        self.values = values

    def __eq__(self, other: object) -> bool:
        """Returns whether *other* is one of the represented Python types."""
        return other in self.values


STRING = DBAPITypeObject(str)
BINARY = DBAPITypeObject(bytes, bytearray, memoryview)
NUMBER = DBAPITypeObject(int, float, Decimal)
DATETIME = DBAPITypeObject(_datetime.date, _datetime.time, _datetime.datetime)
ROWID = DBAPITypeObject(int)


def Date(year: int, month: int, day: int) -> _datetime.date:
    """Constructs the PEP 249 date value."""
    return _datetime.date(year, month, day)


def Time(hour: int, minute: int, second: int) -> _datetime.time:
    """Constructs the PEP 249 time value."""
    return _datetime.time(hour, minute, second)


def Timestamp(
    year: int, month: int, day: int, hour: int, minute: int, second: int
) -> _datetime.datetime:
    """Constructs the PEP 249 timestamp value."""
    return _datetime.datetime(year, month, day, hour, minute, second)


def DateFromTicks(ticks: float) -> _datetime.date:
    """Constructs a local date from POSIX seconds."""
    return _datetime.datetime.fromtimestamp(ticks).date()


def TimeFromTicks(ticks: float) -> _datetime.time:
    """Constructs a local time from POSIX seconds."""
    return _datetime.datetime.fromtimestamp(ticks).time()


def TimestampFromTicks(ticks: float) -> _datetime.datetime:
    """Constructs a local timestamp from POSIX seconds."""
    return _datetime.datetime.fromtimestamp(ticks)


def Binary(value: bytes | bytearray | memoryview) -> bytes:
    """Copies a bytes-like value for the PEP 249 binary constructor."""
    return bytes(value)


@dataclass(frozen=True)
class _ConnectConfig:
    """Validated immutable connection and security configuration."""
    host: str
    port: int
    database: str
    user: str | None
    password: str
    tls: bool
    server_name: str
    pin_sha256: str | None
    trust_server_certificate: bool
    ca_file: str | None
    connect_timeout: float | None
    socket_timeout: float | None
    autocommit: bool
    isolation_level: str


def connect(
    dsn: str | None = None,
    *,
    host: str | None = None,
    port: int | None = None,
    database: str | None = None,
    user: str | None = None,
    password: str | None = None,
    tls: bool | None = None,
    server_name: str | None = None,
    pin_sha256: str | None = None,
    trust_server_certificate: bool | None = None,
    ca_file: str | None = None,
    connect_timeout: float | None = None,
    socket_timeout: float | None = None,
    autocommit: bool | None = None,
    isolation_level: str | None = None,
) -> Connection:
    """Opens a MiniSQL connection using keyword options or a ``minisql://`` DSN."""
    values: dict[str, Any] = {}
    if dsn is not None:
        values.update(_parse_dsn(dsn))
    overrides = {
        "host": host,
        "port": port,
        "database": database,
        "user": user,
        "password": password,
        "tls": tls,
        "server_name": server_name,
        "pin_sha256": pin_sha256,
        "trust_server_certificate": trust_server_certificate,
        "ca_file": ca_file,
        "connect_timeout": connect_timeout,
        "socket_timeout": socket_timeout,
        "autocommit": autocommit,
        "isolation_level": isolation_level,
    }
    values.update({key: value for key, value in overrides.items() if value is not None})
    config = _validate_config(values)
    protocol = Protocol.open(
        config.host,
        config.port,
        user=config.user,
        password=config.password,
        tls=config.tls,
        server_name=config.server_name,
        pin_sha256=config.pin_sha256,
        trust_server_certificate=config.trust_server_certificate,
        ca_file=config.ca_file,
        connect_timeout=config.connect_timeout,
        socket_timeout=config.socket_timeout,
    )
    return Connection(protocol, config)


def _parse_dsn(dsn: str) -> dict[str, Any]:
    """Parses a strict ``minisql://`` DSN into unvalidated option values."""
    parsed = urlparse(dsn)
    if parsed.scheme != "minisql" or not parsed.hostname:
        raise InterfaceError("MiniSQL DSNs use minisql://host[:port]/database")
    accepted = {
        "tls", "server_name", "pin_sha256", "trust_server_certificate", "ca_file",
        "connect_timeout", "socket_timeout", "autocommit", "isolation_level",
    }
    try:
        parsed_port = 7432 if parsed.port is None else parsed.port
    except ValueError as exc:
        raise InterfaceError("MiniSQL DSN port is invalid") from exc
    if not 1 <= parsed_port <= 65535:
        raise InterfaceError("MiniSQL DSN port must be in 1..65535")
    values: dict[str, Any] = {
        "host": parsed.hostname,
        "port": parsed_port,
        "database": unquote(parsed.path[1:]) if parsed.path and parsed.path != "/" else "main",
    }
    if parsed.username is not None:
        values["user"] = unquote(parsed.username)
        values["password"] = unquote(parsed.password or "")
    for key, value in parse_qsl(parsed.query, keep_blank_values=True):
        if key not in accepted:
            raise InterfaceError(f"Unknown MiniSQL DSN option: {key}")
        values[key] = value
    return values


def _validate_config(values: dict[str, Any]) -> _ConnectConfig:
    """Normalizes and validates all connection options."""
    host = str(values.get("host", "127.0.0.1"))
    database = str(values.get("database", "main"))
    if not host or not database:
        raise InterfaceError("MiniSQL host and database must not be empty")
    try:
        port = int(values.get("port", 7432))
    except (TypeError, ValueError) as exc:
        raise InterfaceError("MiniSQL port must be an integer") from exc
    if not 1 <= port <= 65535:
        raise InterfaceError("MiniSQL port must be in 1..65535")
    tls = _bool_option(values.get("tls", False), "tls")
    trust = _bool_option(values.get("trust_server_certificate", False), "trust_server_certificate")
    autocommit = _bool_option(values.get("autocommit", False), "autocommit")
    pin = values.get("pin_sha256")
    if pin:
        pin = re.sub(r"[:-]", "", str(pin)).strip().lower()
        if re.fullmatch(r"[0-9a-f]{64}", pin) is None:
            raise InterfaceError("pin_sha256 must contain 32 hexadecimal bytes")
    else:
        pin = None
    if trust and pin is None:
        raise InterfaceError("trust_server_certificate requires pin_sha256")
    if (trust or pin is not None or values.get("ca_file")) and not tls:
        raise InterfaceError("Certificate options require tls=true")
    isolation = str(values.get("isolation_level", "SERIALIZABLE")).upper().replace("_", " ")
    if isolation not in {"READ COMMITTED", "SERIALIZABLE"}:
        raise InterfaceError("isolation_level must be READ COMMITTED or SERIALIZABLE")
    return _ConnectConfig(
        host=host,
        port=port,
        database=database,
        user=str(values["user"]) if values.get("user") not in (None, "") else None,
        password=str(values.get("password", "")),
        tls=tls,
        server_name=str(values.get("server_name", host)),
        pin_sha256=pin,
        trust_server_certificate=trust,
        ca_file=str(values["ca_file"]) if values.get("ca_file") else None,
        connect_timeout=_timeout(values.get("connect_timeout", 10.0), "connect_timeout"),
        socket_timeout=_timeout(values.get("socket_timeout", 30.0), "socket_timeout"),
        autocommit=autocommit,
        isolation_level=isolation,
    )


def _bool_option(value: Any, name: str) -> bool:
    """Parses one strict Boolean keyword or DSN option."""
    if isinstance(value, bool):
        return value
    if isinstance(value, str) and value.lower() in {"true", "false"}:
        return value.lower() == "true"
    raise InterfaceError(f"{name} must be true or false")


def _timeout(value: Any, name: str) -> float | None:
    """Converts a bounded seconds value; zero selects blocking I/O."""
    try:
        parsed = float(value)
    except (TypeError, ValueError) as exc:
        raise InterfaceError(f"{name} must be a number") from exc
    if not 0 <= parsed <= 3600:
        raise InterfaceError(f"{name} must be in 0..3600 seconds")
    return None if parsed == 0 else parsed


class Connection:
    """PEP 249 connection with lazy transactions and bounded prepared-plan caching."""

    Warning = Warning
    Error = Error
    InterfaceError = InterfaceError
    DatabaseError = DatabaseError
    DataError = DataError
    OperationalError = OperationalError
    IntegrityError = IntegrityError
    InternalError = InternalError
    ProgrammingError = ProgrammingError
    NotSupportedError = NotSupportedError

    def __init__(self, protocol: Protocol, config: _ConnectConfig) -> None:
        """Initializes DB-API and session-local prepared-plan state."""
        self._protocol = protocol
        self._config = config
        self._closed = False
        self._transaction_active = False
        self._autocommit = config.autocommit
        self._isolation_level = config.isolation_level
        self._plans: OrderedDict[str, str] = OrderedDict()
        self._plan_namespace = secrets.token_hex(6)
        self._next_plan = 0
        self._next_savepoint = 0

    @property
    def autocommit(self) -> bool:
        """Returns whether statements use implicit transactions."""
        return self._autocommit

    @autocommit.setter
    def autocommit(self, enabled: bool) -> None:
        """Changes autocommit, committing an active transaction when enabled."""
        self._ensure_open()
        if not isinstance(enabled, bool):
            raise InterfaceError("autocommit must be bool")
        if enabled and not self._autocommit and self._transaction_active:
            self.commit()
        self._autocommit = enabled

    @property
    def isolation_level(self) -> str:
        """Returns the isolation used by the next lazy transaction."""
        return self._isolation_level

    @isolation_level.setter
    def isolation_level(self, value: str) -> None:
        """Changes isolation between transactions."""
        self._ensure_open()
        normalized = value.upper().replace("_", " ")
        if normalized not in {"READ COMMITTED", "SERIALIZABLE"}:
            raise InterfaceError("isolation_level must be READ COMMITTED or SERIALIZABLE")
        if self._transaction_active:
            raise InterfaceError("Change isolation_level between transactions")
        self._isolation_level = normalized

    def cursor(self) -> Cursor:
        """Creates a forward-only cursor owned by this connection."""
        self._ensure_open()
        return Cursor(self)

    def commit(self) -> None:
        """Commits the active transaction, or does nothing when idle."""
        self._ensure_open()
        if self._transaction_active:
            self._raw_command("COMMIT")
            self._transaction_active = False

    def rollback(self) -> None:
        """Rolls back the active transaction, or does nothing when idle."""
        self._ensure_open()
        if self._transaction_active:
            self._raw_command("ROLLBACK")
            self._transaction_active = False

    def ping(self) -> bool:
        """Checks liveness through the protocol PING/PONG exchange."""
        self._ensure_open()
        return self._protocol.ping()

    def cancel_session(self, session_id: int) -> None:
        """Requests cooperative cancellation using this administrative connection."""
        self._ensure_open()
        self._protocol.cancel_session(session_id)

    def cancel(self) -> None:
        """Cancels this connection's running statement through a control socket."""
        self._ensure_open()
        session_id = self._protocol.session_id
        if session_id is None:
            raise NotSupportedError(
                "The MiniSQL server did not advertise a cancellable session identifier"
            )
        config = self._config
        control = Protocol.open(
            config.host,
            config.port,
            user=config.user,
            password=config.password,
            tls=config.tls,
            server_name=config.server_name,
            pin_sha256=config.pin_sha256,
            trust_server_certificate=config.trust_server_certificate,
            ca_file=config.ca_file,
            connect_timeout=config.connect_timeout,
            socket_timeout=config.socket_timeout,
        )
        try:
            control.cancel_session(session_id)
        finally:
            control.close()

    def close(self) -> None:
        """Rolls back uncommitted work and closes the protocol transport."""
        if self._closed:
            return
        if self._transaction_active:
            try:
                self._raw_command("ROLLBACK")
            except DatabaseError:
                pass
        self._transaction_active = False
        self._protocol.close()
        self._closed = True

    def _begin_if_needed(self) -> None:
        """Lazily opens a DB-API transaction for the next non-DDL statement."""
        self._ensure_open()
        if not self._autocommit and not self._transaction_active:
            self._raw_command(f"BEGIN ISOLATION LEVEL {self._isolation_level} READ WRITE")
            self._transaction_active = True

    def _raw_command(self, sql: str) -> Response:
        """Executes SQL that must produce exactly one command response."""
        query = self._protocol.query(sql)
        try:
            response = query.first
            if response.status == STATUS_ROWS:
                raise InternalError("Expected a MiniSQL command response")
            return response
        finally:
            query.close()

    def _statement_sql(self, operation: str, parameters: Sequence[Any] | None) -> str:
        """Returns direct SQL or a cached server-side EXECUTE command."""
        if parameters is None:
            return operation
        literals = _parameter_literals(operation, parameters)
        if literals and _first_keyword(operation) in {"SELECT", "INSERT", "UPDATE", "DELETE"}:
            name = self._plans.get(operation)
            if name is None:
                self._next_plan += 1
                name = f"py_ps_{self._plan_namespace}_{self._next_plan}"
                self._raw_command(f"PREPARE {name} AS {operation}")
                self._plans[operation] = name
                self._evict_plan_if_needed()
            else:
                self._plans.move_to_end(operation)
            return f"EXECUTE {name} USING {','.join(literals)}"
        return _bound_sql(operation, parameters)

    def _evict_plan_if_needed(self) -> None:
        """Deallocates the least-recently-used plan above the fixed cache bound."""
        if len(self._plans) <= MAX_PREPARED_PLANS:
            return
        _, name = self._plans.popitem(last=False)
        self._raw_command(f"DEALLOCATE PREPARE {name}")

    def _savepoint_name(self) -> str:
        """Allocates a collision-resistant internal batch savepoint name."""
        self._next_savepoint += 1
        return f"py_batch_{self._plan_namespace}_{self._next_savepoint}"

    def _ensure_open(self) -> None:
        """Raises when the connection no longer owns a transport."""
        if self._closed:
            raise InterfaceError("MiniSQL connection is closed")

    def __enter__(self) -> Connection:
        """Returns this open connection for context-manager use."""
        self._ensure_open()
        return self

    def __exit__(self, exc_type: Any, exc: Any, traceback: Any) -> None:
        """Commits normal context exit and rolls back exceptional exit."""
        if exc_type is None:
            self.commit()
        else:
            self.rollback()


class Cursor(Iterator[tuple[Any, ...]]):
    """Forward-only streaming cursor for MiniSQL protocol continuation frames."""

    def __init__(self, connection: Connection) -> None:
        """Initializes one cursor without acquiring a server resource."""
        self.connection = connection
        self.arraysize = 1
        self.description: tuple[tuple[Any, ...], ...] | None = None
        self.rowcount = -1
        self.lastrowid: Any = None
        self._query: Query | None = None
        self._frame: Response | None = None
        self._frame_row = 0
        self._closed = False

    def execute(self, operation: str, parameters: Sequence[Any] | None = None) -> Cursor:
        """Executes one operation and retains a lazy row stream when present."""
        self._ensure_open()
        if not isinstance(operation, str) or not operation.strip():
            raise ProgrammingError("SQL operation must be non-empty text")
        self._close_result()
        # MiniSQL authenticated DDL is autocommit-only, and the trusted engine
        # also forbids mixing DDL and DML in one explicit transaction. End the
        # current DB-API transaction before DDL and execute it implicitly.
        ddl_autocommit = _first_keyword(operation) in {
            "CREATE", "ALTER", "DROP", "TRUNCATE", "VACUUM", "REINDEX", "ANALYZE"
        }
        if ddl_autocommit and not self.connection.autocommit:
            self.connection.commit()
        else:
            self.connection._begin_if_needed()
        sql = self.connection._statement_sql(operation, parameters)
        query = self.connection._protocol.query(sql)
        first = query.first
        self.rowcount = -1
        self.lastrowid = None
        if first.status == STATUS_ROWS:
            self._query = query
            self.description = tuple((name, STRING, None, None, None, None, None) for name in first.columns)
        else:
            query.close()
            self.description = None
            self.rowcount = first.affected_rows
        return self

    def executemany(self, operation: str, seq_of_parameters: Iterable[Sequence[Any]]) -> Cursor:
        """Executes a bounded stream of parameter sets and coalesces safe INSERT batches."""
        self._ensure_open()
        self._close_result()
        self.connection._begin_if_needed()
        self.description = None
        self.rowcount = 0
        iterator = iter(seq_of_parameters)
        pending: tuple[Sequence[Any], str, tuple[str, str] | None] | None = None
        while True:
            if pending is None:
                try:
                    parameters = next(iterator)
                except StopIteration:
                    break
                sql = _bound_sql(operation, parameters)
                parts = _split_single_insert(sql)
            else:
                parameters, sql, parts = pending
                pending = None
            if parts is None:
                self.rowcount += self._execute_batch_command(sql)
                continue
            prefix, first_tuple = parts
            statements = [sql]
            tuples = [first_tuple]
            encoded_size = len((prefix + first_tuple).encode("utf-8"))
            while len(statements) < MAX_BATCH_ROWS:
                try:
                    next_parameters = next(iterator)
                except StopIteration:
                    break
                next_sql = _bound_sql(operation, next_parameters)
                next_parts = _split_single_insert(next_sql)
                if next_parts is None or next_parts[0] != prefix:
                    pending = (next_parameters, next_sql, next_parts)
                    break
                tuple_size = 1 + len(next_parts[1].encode("utf-8"))
                if encoded_size + tuple_size > MAX_BATCH_BYTES:
                    pending = (next_parameters, next_sql, next_parts)
                    break
                statements.append(next_sql)
                tuples.append(next_parts[1])
                encoded_size += tuple_size
            self.rowcount += self._execute_insert_chunk(prefix, tuples, statements)
        return self

    def _execute_batch_command(self, sql: str) -> int:
        """Executes one batch command and returns its affected-row count."""
        response = self.connection._raw_command(sql)
        return response.affected_rows

    def _execute_insert_chunk(self, prefix: str, tuples: list[str], statements: list[str]) -> int:
        """Runs one optimized insert chunk with failure-safe sequential fallback."""
        if len(statements) == 1:
            return self._execute_batch_command(statements[0])
        savepoint: str | None = None
        if not self.connection.autocommit:
            savepoint = self.connection._savepoint_name()
            self.connection._raw_command(f"SAVEPOINT {savepoint}")
        try:
            affected = self._execute_batch_command(prefix + ",".join(tuples) + ";")
            if savepoint is not None:
                self.connection._raw_command(f"RELEASE SAVEPOINT {savepoint}")
            return affected
        except DatabaseError as combined_error:
            if savepoint is not None:
                try:
                    self.connection._raw_command(f"ROLLBACK TO SAVEPOINT {savepoint}")
                    self.connection._raw_command(f"RELEASE SAVEPOINT {savepoint}")
                except DatabaseError as recovery_error:
                    raise combined_error from recovery_error
            affected = 0
            for sql in statements:
                affected += self._execute_batch_command(sql)
            return affected

    def fetchone(self) -> tuple[Any, ...] | None:
        """Returns one row from the current or next continuation frame."""
        self._ensure_fetchable()
        if self._query is None:
            return None
        while self._frame is None or self._frame_row >= len(self._frame.rows):
            frame = self._query.next_frame()
            if frame is None:
                self._query = None
                self._frame = None
                return None
            expected = tuple(item[0] for item in self.description or ())
            if frame.columns != expected:
                self._close_result()
                raise InternalError("MiniSQL continuation-frame columns changed")
            self._frame = frame
            self._frame_row = 0
        raw = self._frame.rows[self._frame_row]
        self._frame_row += 1
        return tuple(None if value == "NULL" else value for value in raw)

    def fetchmany(self, size: int | None = None) -> list[tuple[Any, ...]]:
        """Returns at most *size* rows, defaulting to ``arraysize``."""
        requested = self.arraysize if size is None else size
        if not isinstance(requested, int) or requested < 0:
            raise ProgrammingError("fetchmany size must be a non-negative integer")
        rows: list[tuple[Any, ...]] = []
        while len(rows) < requested:
            row = self.fetchone()
            if row is None:
                break
            rows.append(row)
        return rows

    def fetchall(self) -> list[tuple[Any, ...]]:
        """Consumes all remaining rows into a list."""
        rows: list[tuple[Any, ...]] = []
        while True:
            row = self.fetchone()
            if row is None:
                return rows
            rows.append(row)

    def setinputsizes(self, sizes: Any) -> None:
        """Accepts the optional PEP 249 sizing hint as a no-op."""
        return None

    def setoutputsize(self, size: int, column: int | None = None) -> None:
        """Accepts the optional PEP 249 output hint as a no-op."""
        return None

    def callproc(self, procname: str, parameters: Sequence[Any] | None = None) -> None:
        """Reports that protocol-v1 stored procedure calls are unavailable."""
        raise NotSupportedError("MiniSQL stored procedures are not supported")

    def nextset(self) -> None:
        """Returns ``None`` because MiniSQL queries have one result set."""
        return None

    def close(self) -> None:
        """Drains an unread result and permanently closes this cursor."""
        if self._closed:
            return
        self._close_result()
        self._closed = True

    def _close_result(self) -> None:
        """Drains and releases the current protocol query, if any."""
        if self._query is not None:
            self._query.close()
        self._query = None
        self._frame = None
        self._frame_row = 0

    def _ensure_open(self) -> None:
        """Validates both cursor and owning connection state."""
        self.connection._ensure_open()
        if self._closed:
            raise InterfaceError("MiniSQL cursor is closed")

    def _ensure_fetchable(self) -> None:
        """Validates that the previous operation produced a row description."""
        self._ensure_open()
        if self.description is None:
            raise ProgrammingError("The previous operation did not produce rows")

    def __iter__(self) -> Cursor:
        """Returns this cursor as its own row iterator."""
        return self

    def __next__(self) -> tuple[Any, ...]:
        """Returns the next row or raises ``StopIteration`` at EOF."""
        row = self.fetchone()
        if row is None:
            raise StopIteration
        return row

    def __enter__(self) -> Cursor:
        """Returns this open cursor for context-manager use."""
        self._ensure_open()
        return self

    def __exit__(self, exc_type: Any, exc: Any, traceback: Any) -> None:
        """Closes and drains the cursor at context exit."""
        self.close()


def _parameter_markers(sql: str) -> list[int]:
    """Finds qmark offsets while skipping SQL literals, identifiers, and comments."""
    markers: list[int] = []
    single = quoted = line = block = False
    index = 0
    while index < len(sql):
        current = sql[index]
        following = sql[index + 1] if index + 1 < len(sql) else ""
        if line:
            if current in "\r\n":
                line = False
        elif block:
            if current == "*" and following == "/":
                block = False
                index += 1
        elif single:
            if current == "'" and following == "'":
                index += 1
            elif current == "'":
                single = False
        elif quoted:
            if current == '"' and following == '"':
                index += 1
            elif current == '"':
                quoted = False
        elif current == "-" and following == "-":
            line = True
            index += 1
        elif current == "/" and following == "*":
            block = True
            index += 1
        elif current == "'":
            single = True
        elif current == '"':
            quoted = True
        elif current == "?":
            markers.append(index)
        index += 1
    return markers


def _parameter_literals(sql: str, parameters: Sequence[Any]) -> list[str]:
    """Validates parameter arity and converts values into safe SQL literals."""
    if isinstance(parameters, (str, bytes, bytearray, memoryview)):
        raise ProgrammingError("SQL parameters must be a non-string sequence")
    try:
        values = list(parameters)
    except TypeError as exc:
        raise ProgrammingError("SQL parameters must be a sequence") from exc
    markers = _parameter_markers(sql)
    if len(markers) != len(values):
        raise ProgrammingError(f"Expected {len(markers)} parameters, received {len(values)}")
    return [_literal(value) for value in values]


def _bound_sql(sql: str, parameters: Sequence[Any]) -> str:
    """Substitutes executable qmarks with validated literals."""
    markers = _parameter_markers(sql)
    literals = _parameter_literals(sql, parameters)
    output: list[str] = []
    source = 0
    for marker, literal in zip(markers, literals):
        output.append(sql[source:marker])
        output.append(literal)
        source = marker + 1
    output.append(sql[source:])
    return "".join(output)


def _literal(value: Any) -> str:
    """Renders one supported Python value as a MiniSQL SQL literal."""
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, (float, Decimal)):
        if not math.isfinite(value):
            raise DataError("MiniSQL numeric parameters must be finite")
        return str(value)
    if isinstance(value, str):
        return "'" + value.replace("'", "''") + "'"
    if isinstance(value, _datetime.datetime):
        if value.tzinfo is not None:
            raise DataError("MiniSQL TIMESTAMP parameters must be timezone-naive")
        days = (value.date() - _EPOCH).days
        micros = (
            ((value.hour * 60 + value.minute) * 60 + value.second) * 1_000_000
            + value.microsecond
        )
        return f"CAST({days * 86_400_000_000 + micros} AS TIMESTAMP)"
    if isinstance(value, _datetime.date):
        return f"CAST({(value - _EPOCH).days} AS DATE)"
    if isinstance(value, _datetime.time):
        if value.tzinfo is not None:
            raise DataError("MiniSQL TIME parameters must be timezone-naive")
        micros = ((value.hour * 60 + value.minute) * 60 + value.second) * 1_000_000 + value.microsecond
        return f"CAST({micros} AS TIME)"
    if isinstance(value, (bytes, bytearray, memoryview)):
        raise NotSupportedError("Protocol v1 has no SQL binary literal; binary binding is unavailable")
    raise NotSupportedError(f"Cannot bind Python value of type {type(value).__name__}")


def _first_keyword(sql: str) -> str:
    """Returns the first executable SQL keyword after leading comments."""
    cleaned = re.sub(r"\A(?:\s|--[^\r\n]*(?:\r?\n|$)|/\*.*?\*/)*", "", sql, flags=re.S)
    match = re.match(r"[A-Za-z_]+", cleaned)
    return match.group(0).upper() if match else ""


def _split_single_insert(sql: str) -> tuple[str, str] | None:
    """Splits a safe single-row INSERT into stable prefix and VALUES tuple."""
    if _first_keyword(sql) != "INSERT":
        return None
    values = _top_level_keyword(sql, "VALUES")
    if values < 0:
        return None
    start = values + len("VALUES")
    while start < len(sql) and sql[start].isspace():
        start += 1
    if start >= len(sql) or sql[start] != "(":
        return None
    end = _matching_parenthesis(sql, start)
    if end < 0:
        return None
    suffix = sql[end + 1:].strip()
    if suffix not in {"", ";"}:
        return None
    return sql[:start], sql[start:end + 1]


def _top_level_keyword(sql: str, keyword: str) -> int:
    """Finds an unquoted keyword outside parenthesized expressions."""
    depth = 0
    single = quoted = line = block = False
    index = 0
    upper = sql.upper()
    while index <= len(sql) - len(keyword):
        current = sql[index]
        following = sql[index + 1] if index + 1 < len(sql) else ""
        if line:
            if current in "\r\n":
                line = False
        elif block:
            if current == "*" and following == "/":
                block = False
                index += 1
        elif single:
            if current == "'" and following == "'":
                index += 1
            elif current == "'":
                single = False
        elif quoted:
            if current == '"' and following == '"':
                index += 1
            elif current == '"':
                quoted = False
        elif current == "-" and following == "-":
            line = True
            index += 1
        elif current == "/" and following == "*":
            block = True
            index += 1
        elif current == "'":
            single = True
        elif current == '"':
            quoted = True
        elif current == "(":
            depth += 1
        elif current == ")":
            depth = max(0, depth - 1)
        elif depth == 0 and upper.startswith(keyword, index):
            before = sql[index - 1] if index else " "
            after_index = index + len(keyword)
            after = sql[after_index] if after_index < len(sql) else " "
            if not (before.isalnum() or before == "_") and not (after.isalnum() or after == "_"):
                return index
        index += 1
    return -1


def _matching_parenthesis(sql: str, start: int) -> int:
    """Finds the matching tuple parenthesis with quote/comment awareness."""
    depth = 0
    single = quoted = line = block = False
    index = start
    while index < len(sql):
        current = sql[index]
        following = sql[index + 1] if index + 1 < len(sql) else ""
        if line:
            if current in "\r\n":
                line = False
        elif block:
            if current == "*" and following == "/":
                block = False
                index += 1
        elif single:
            if current == "'" and following == "'":
                index += 1
            elif current == "'":
                single = False
        elif quoted:
            if current == '"' and following == '"':
                index += 1
            elif current == '"':
                quoted = False
        elif current == "-" and following == "-":
            line = True
            index += 1
        elif current == "/" and following == "*":
            block = True
            index += 1
        elif current == "'":
            single = True
        elif current == '"':
            quoted = True
        elif current == "(":
            depth += 1
        elif current == ")":
            depth -= 1
            if depth == 0:
                return index
        index += 1
    return -1
