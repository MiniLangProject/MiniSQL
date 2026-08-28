# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see LICENSE for details.
"""PEP 249 exception hierarchy for the MiniSQL Python connector."""


class Warning(Exception):
    """Reports a non-fatal database warning."""


class Error(Exception):
    """Base class for all connector errors."""


class InterfaceError(Error):
    """Reports invalid connector use or an unavailable client capability."""


class DatabaseError(Error):
    """Base class for errors returned by MiniSQL."""

    def __init__(self, message: str, code: int | None = None) -> None:
        """Stores the human-readable message and stable MiniSQL error code."""
        super().__init__(message)
        self.code = code


class DataError(DatabaseError):
    """Reports invalid or out-of-range data."""


class OperationalError(DatabaseError):
    """Reports transport, connection, and operational failures."""


class IntegrityError(DatabaseError):
    """Reports relational-integrity violations."""


class InternalError(DatabaseError):
    """Reports an invalid internal protocol or connector state."""


class ProgrammingError(DatabaseError):
    """Reports malformed SQL and invalid API arguments."""


class NotSupportedError(DatabaseError):
    """Reports a requested operation that MiniSQL cannot provide."""
