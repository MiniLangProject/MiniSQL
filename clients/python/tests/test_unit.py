# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see LICENSE for details.
"""Dependency-light unit tests for the MiniSQL Python connector."""

import datetime
from decimal import Decimal
import unittest

import minisql
from minisql import dbapi
from minisql.protocol import crc32c


class ConnectorUnitTest(unittest.TestCase):
    """Validates pure connector algorithms without opening a socket."""

    def test_pep249_metadata(self) -> None:
        """Checks the required module-level DB-API declarations."""
        self.assertEqual(minisql.apilevel, "2.0")
        self.assertEqual(minisql.threadsafety, 1)
        self.assertEqual(minisql.paramstyle, "qmark")

    def test_crc32c_vector(self) -> None:
        """Checks the standard Castagnoli checksum vector."""
        self.assertEqual(crc32c(b"123456789"), 0xE3069283)

    def test_parameter_scanner_ignores_literals_and_comments(self) -> None:
        """Checks quote-aware qmark discovery and substitution."""
        sql = "SELECT '?', \"?\" FROM t WHERE a = ? AND b = ? -- ?\n/* ? */"
        self.assertEqual(len(dbapi._parameter_markers(sql)), 2)
        self.assertEqual(
            dbapi._bound_sql(sql, (7, "O'Reilly")),
            "SELECT '?', \"?\" FROM t WHERE a = 7 AND b = 'O''Reilly' -- ?\n/* ? */",
        )

    def test_temporal_and_numeric_literals(self) -> None:
        """Checks exact temporal units and finite numeric validation."""
        self.assertEqual(dbapi._literal(datetime.date(1970, 1, 2)), "CAST(1 AS DATE)")
        self.assertEqual(dbapi._literal(datetime.time(0, 0, 1, 25)), "CAST(1000025 AS TIME)")
        self.assertEqual(dbapi._literal(Decimal("12.50")), "12.50")
        with self.assertRaises(minisql.DataError):
            dbapi._literal(float("nan"))

    def test_insert_split_is_quote_aware(self) -> None:
        """Checks safe tuple extraction and suffix rejection."""
        sql = "INSERT INTO t(id,label) VALUES (1,'VALUES ) (' );"
        parts = dbapi._split_single_insert(sql)
        self.assertIsNotNone(parts)
        assert parts is not None
        self.assertEqual(parts[1], "(1,'VALUES ) (' )")
        self.assertIsNone(dbapi._split_single_insert(sql[:-1] + " RETURNING id"))

    def test_dsn_and_security_validation(self) -> None:
        """Checks strict DSN parsing and fail-closed pin configuration."""
        values = dbapi._parse_dsn(
            "minisql://alice:secret@localhost:7440/shop?tls=true&server_name=db.example"
        )
        config = dbapi._validate_config(values)
        self.assertEqual((config.host, config.port, config.database), ("localhost", 7440, "shop"))
        self.assertEqual((config.user, config.password), ("alice", "secret"))
        self.assertTrue(config.tls)
        with self.assertRaises(minisql.InterfaceError):
            dbapi._validate_config({"trust_server_certificate": True})
        with self.assertRaises(minisql.InterfaceError):
            dbapi._parse_dsn("minisql://localhost:0/main")

    def test_binary_binding_is_explicitly_unavailable(self) -> None:
        """Checks the protocol-v1 binary-parameter limitation."""
        with self.assertRaises(minisql.NotSupportedError):
            dbapi._literal(b"binary")


if __name__ == "__main__":
    unittest.main()
