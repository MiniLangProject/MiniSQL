# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see LICENSE for details.
"""MiniSQL Python DB-API 2.0 connector."""

from .dbapi import (
    BINARY,
    DATETIME,
    NUMBER,
    ROWID,
    STRING,
    Binary,
    Connection,
    Cursor,
    Date,
    DateFromTicks,
    Time,
    TimeFromTicks,
    Timestamp,
    TimestampFromTicks,
    connect,
)
from .errors import (
    DataError,
    DatabaseError,
    Error,
    IntegrityError,
    InterfaceError,
    InternalError,
    NotSupportedError,
    OperationalError,
    ProgrammingError,
    Warning,
)

apilevel = "2.0"
threadsafety = 1
paramstyle = "qmark"
__version__ = "1.1.0"

__all__ = [
    "BINARY", "DATETIME", "NUMBER", "ROWID", "STRING", "Binary", "Connection", "Cursor",
    "DataError", "DatabaseError", "Date", "DateFromTicks", "Error", "IntegrityError",
    "InterfaceError", "InternalError", "NotSupportedError", "OperationalError", "ProgrammingError",
    "Time", "TimeFromTicks", "Timestamp", "TimestampFromTicks", "Warning", "apilevel", "connect",
    "paramstyle", "threadsafety",
]
