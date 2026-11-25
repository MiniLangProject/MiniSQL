# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see LICENSE for details.
"""Stored procedure result-boundary and DB-API regressions without a server process."""

import socket
import struct
import threading
import unittest

from minisql import dbapi
from minisql.protocol import (
    BufferedQuery, Condition, OutputParameter, ResultSpool, FLAG_METADATA, FLAG_MORE, FLAG_RESULT_START, Message, Protocol, Response,
    STATUS_COMMAND, STATUS_ROWS, STATUS_ERROR, TYPE_QUERY, TYPE_RESPONSE, TYPE_ERROR,
)


def rows(value, *, start=False, columns=("value",)):
    """Constructs one bounded row frame, including explicit empty results."""
    data = () if value is None else ((str(value),),)
    return Response(STATUS_ROWS, "SELECT", columns, data, len(data), "", 0, start)


def command():
    """Constructs the final CALL completion response."""
    return Response(STATUS_COMMAND, "CALL", (), (), 4, "p", 0, True)


def payload(response):
    """Encodes the documented v1 response payload for a socket-level regression."""
    def field(value):
        """Encodes one UTF-8 field with its protocol length prefix."""
        data = value.encode("utf-8")
        return struct.pack("<I", len(data)) + data
    header = struct.pack("<HHIIIII", response.status, 0, len(response.columns), len(response.rows),
                         response.affected_rows, response.error_code, 0)
    base = bytearray(header + field(response.command) + field(response.message) + b"".join(
        field("NULL" if value is None else value) for value in (*response.columns, *(value for row in response.rows for value in row))))
    if response.extended:
        extra = bytearray(b"MDV1" + field(response.sqlstate) + struct.pack("<I", len(response.warnings)))
        for warning in response.warnings:
            extra += field(warning.sqlstate) + struct.pack("<I", warning.code) + field(warning.message)
        bitmap = bytearray((len(response.rows) * len(response.columns) + 7) // 8)
        for index, value in enumerate(value for row in response.rows for value in row):
            if value is None:
                bitmap[index // 8] |= 1 << (index % 8)
        extra += struct.pack("<I", len(bitmap)) + bitmap + struct.pack("<I", len(response.column_types))
        for kind in response.column_types:
            extra += struct.pack("<H", kind)
        extra += struct.pack("<I", len(response.outputs))
        for output in response.outputs:
            extra += struct.pack("<I", output.ordinal) + field(output.name)
            extra += struct.pack("<HH", output.type_kind, output.value is None) + field(output.value or "")
        struct.pack_into("<I", base, 20, len(extra))
        base += extra
    return bytes(base)


class FakeConnection:
    """Supplies scripted response streams to test DB-API state transitions."""
    def __init__(self, responses):
        """Initializes scripted streams and records commands in execution order."""
        self.responses = iter(responses)
        self.autocommit = True
        self._protocol = self
        self.commands = []

    def _ensure_open(self):
        """Accepts the lightweight mock connection as open."""
        pass

    def _begin_if_needed(self):
        """Keeps the mock transaction-free for connector state tests."""
        pass

    def _statement_sql(self, sql, parameters):
        """Uses the production parameter binder for test operations."""
        return sql if parameters is None else dbapi._bound_sql(sql, parameters)

    def query(self, sql):
        """Records SQL and returns the next scripted bounded response stream."""
        self.commands.append(sql)
        return BufferedQuery(next(self.responses))

    def _raw_command(self, sql):
        """Records a command and supplies its completed mock response."""
        self.commands.append(sql)
        return command()


class RoutineConnectorTest(unittest.TestCase):
    """Keeps distinct results separate even when column names are identical."""

    def test_parameter_scanner_respects_mysql_quoted_identifiers(self):
        """Ensures question marks inside backtick identifiers are never substituted."""
        self.assertEqual(dbapi._bound_sql("SELECT `has?mark`, `escaped``?` FROM t WHERE id = ?", (7,)),
                         "SELECT `has?mark`, `escaped``?` FROM t WHERE id = 7")

    def test_streaming_nextset_keeps_identical_schemas_separate(self):
        """Checks row batches, identical schemas, empty results, and final CALL status."""
        conn = FakeConnection([[rows(1, start=True), rows(2), rows(3, start=True), rows(None, start=True), command()]])
        cursor = dbapi.Cursor(conn).execute("CALL p()")
        self.assertEqual(cursor.fetchall(), [("1",), ("2",)])
        self.assertEqual(cursor.fetchone(), None)
        self.assertTrue(cursor.nextset())
        self.assertEqual(cursor.fetchall(), [("3",)])
        self.assertTrue(cursor.nextset())
        self.assertEqual(cursor.fetchall(), [])
        self.assertTrue(cursor.nextset())
        self.assertIsNone(cursor.description)
        self.assertEqual(cursor.rowcount, 4)
        self.assertIsNone(cursor.nextset())

    def test_nextset_discards_only_current_result(self):
        """Checks that skipping unread rows preserves the subsequent result."""
        conn = FakeConnection([[rows(1, start=True), rows(2), rows(3, start=True), command()]])
        cursor = dbapi.Cursor(conn).execute("CALL p()")
        self.assertTrue(cursor.nextset())
        self.assertEqual(cursor.fetchall(), [("3",)])
        cursor.close()

    def test_callproc_returns_outputs_and_retains_call_results(self):
        """Checks IN preservation, output lookup, result retention, and secret cleanup."""
        output = Response(STATUS_ROWS, "SELECT", ("a", "b"), (("42", "NULL"),), 1, "", 0)
        modes = Response(STATUS_ROWS, "SELECT", ("parameter_mode",), (("IN",), ("OUT",)), 2, "", 0)
        conn = FakeConnection([[modes], [rows(7, start=True), rows(9, start=True), command()], [output]])
        cursor = dbapi.Cursor(conn)
        self.assertEqual(cursor.callproc("tools.calculate", ("O'Reilly", None)), ("O'Reilly", None))
        self.assertEqual(cursor.fetchall(), [("7",)])
        self.assertTrue(cursor.nextset())
        self.assertEqual(cursor.fetchall(), [("9",)])
        self.assertIn("'O''Reilly'", conn.commands[1])
        self.assertTrue(conn.commands[2].startswith('CALL "tools"."calculate"(@py_call_'))
        self.assertTrue(conn.commands[-1].startswith("SET @py_call_"))
        self.assertTrue(conn.commands[-1].endswith(" = NULL"))
        cursor.close()

    def test_callproc_rejects_sql_in_procedure_name(self):
        """Rejects SQL injection in the procedure identifier before sending commands."""
        cursor = dbapi.Cursor(FakeConnection([]))
        with self.assertRaises(dbapi.ProgrammingError):
            cursor.callproc("p(); DROP TABLE t", ())

    def test_structured_metadata_distinguishes_null_and_preserves_conditions(self):
        """Checks exact NULLs, type kinds, output ordinals, and warning fields on the wire."""
        response = Response(STATUS_ROWS, "SELECT", ("text", "null", "int"), (("NULL", None, "42"),), 1, "", 0,
                            True, "00000", (Condition("01000", 1642, "careful"),), (10, 10, 3),
                            (OutputParameter(2, "amount", 7, "7.25"), OutputParameter(3, "missing", 10, None)), True)
        decoded = Protocol._decode_response(Message(TYPE_RESPONSE, FLAG_METADATA | FLAG_RESULT_START, 1, payload(response)))
        self.assertEqual(decoded, response)
        corrupted = bytearray(payload(response))
        struct.pack_into("<I", corrupted, 20, len(corrupted))
        with self.assertRaises(dbapi.OperationalError):
            Protocol._decode_response(Message(TYPE_RESPONSE, FLAG_METADATA, 1, bytes(corrupted)))

    def test_sqlstate_prevents_application_errno_category_collisions(self):
        """Uses SQLSTATE as the primary error class when application numbers overlap native ones."""
        response = Response(STATUS_ERROR, "ERROR", (), (), 0, "application failure", 9022,
                            False, "45000", (), (), (), True)
        error = Protocol._server_error(response)
        self.assertIs(type(error), dbapi.DatabaseError)
        self.assertEqual((error.code, error.sqlstate), (9022, "45000"))
        integrity = Response(STATUS_ERROR, "ERROR", (), (), 0, "constraint failure", 60001,
                             False, "23000", (), (), (), True)
        self.assertIsInstance(Protocol._server_error(integrity), dbapi.IntegrityError)

    def test_spool_spills_and_replays_metadata_without_retaining_all_rows(self):
        """Crosses the one-MiB spill threshold and verifies cleanup plus complete data replay."""
        spool = ResultSpool()
        for index in range(400):
            frame = Response(STATUS_ROWS, "SELECT", ("value",), (("x" * 4096,),), 1, "", 0,
                             index == 0, "00000", (), (10,), (), True)
            spool.append(frame)
        spool.append(command())
        self.assertTrue(spool._file._rolled)
        query = spool.finish()
        count = 0
        while (frame := query.next_frame()) is not None:
            self.assertEqual(frame.rows[0][0], "x" * 4096)
            count += len(frame.rows)
        self.assertEqual(count, 400)
        self.assertTrue(query.next_result())
        query.close()
        self.assertTrue(query._file.closed)
        spool.close()

    def test_callproc_v2_uses_typed_terminal_outputs_and_preserves_warnings(self):
        """Avoids metadata/output/cleanup SQL after a negotiated CALL and retains quoted case."""
        finish = Response(STATUS_COMMAND, "CALL", (), (), 0, "QuotedName", 0, True, "00000",
                          (Condition("01000", 1642, "careful"),), (),
                          (OutputParameter(2, "answer", 3, "42"), OutputParameter(3, "text", 10, "NULL")), True)
        conn = FakeConnection([[rows(7, start=True), finish]])
        conn.extended_results = True
        cursor = dbapi.Cursor(conn)
        self.assertEqual(cursor.callproc('"QuotedName"', (5, None, None)), (5, 42, "NULL"))
        self.assertEqual(cursor.messages[0][1].sqlstate, "01000")
        self.assertEqual(cursor.fetchall(), [("7",)])
        self.assertEqual(len(conn.commands), 2)
        self.assertIn('CALL "QuotedName"(', conn.commands[1])
        cursor.close()

    def test_protocol_boundary_flag_and_drain_preserve_alignment(self):
        """Verifies real socket framing and reuse after a partially consumed CALL."""
        left, right = socket.socketpair()
        left.settimeout(2)
        right.settimeout(2)
        protocol = Protocol(left)
        peer = Protocol(right)
        failures = []

        def serve():
            """Emits valid response frames for a CALL followed by an ordinary query."""
            try:
                request = peer._read_expected(1)
                self.assertEqual(request.message_type, TYPE_QUERY)
                stream = [rows(1, start=True), rows(2), rows(3, start=True), command()]
                for index, response in enumerate(stream):
                    flags = FLAG_RESULT_START if response.result_start else 0
                    if index + 1 < len(stream):
                        flags |= FLAG_MORE
                    peer._write(Message(TYPE_RESPONSE, flags, request.request_id, payload(response)))
                request = peer._read_expected(2)
                peer._write(Message(TYPE_RESPONSE, 0, request.request_id, payload(rows(99))))
            except Exception as exc:
                failures.append(exc)

        worker = threading.Thread(target=serve)
        worker.start()
        try:
            query = protocol.query("CALL p()")
            self.assertEqual(query.next_frame().rows, (("1",),))
            self.assertEqual(query.next_frame().rows, (("2",),))
            self.assertIsNone(query.next_frame())
            self.assertTrue(query.next_result())
            self.assertEqual(query.next_frame().rows, (("3",),))
            query.close()  # Drains the final command as well as remaining rows.
            following = protocol.query("SELECT 99")
            self.assertEqual(following.next_frame().rows, (("99",),))
            following.close()
        finally:
            worker.join(timeout=3)
            left.close()
            right.close()
        self.assertFalse(worker.is_alive())
        if failures:
            raise failures[0]

    def test_protocol_defers_terminal_error_until_next_result(self):
        """Keeps completed rows readable and releases transport ownership after SIGNAL."""
        failure = Response(STATUS_ERROR, "", (), (), 0, "error after completed result", 6001, True)
        cursor = dbapi.Cursor(FakeConnection([[rows(7, start=True), failure]])).execute("CALL partial_error()")
        with self.assertRaisesRegex(dbapi.DatabaseError, "error after completed result"):
            cursor.nextset()
        self.assertIsNone(cursor.description)
        self.assertIsNone(cursor.nextset())
        cursor.close()
        left, right = socket.socketpair()
        left.settimeout(2)
        right.settimeout(2)
        protocol, peer = Protocol(left), Protocol(right)
        failures = []

        def serve():
            """Returns a completed result, terminal condition, then a reusable connection."""
            try:
                request = peer._read_expected(1)
                peer._write(Message(TYPE_RESPONSE, FLAG_RESULT_START | FLAG_MORE,
                                    request.request_id, payload(rows(7, start=True))))
                failure = Response(STATUS_ERROR, "", (), (), 0, "error after completed result", 6001, True)
                peer._write(Message(TYPE_ERROR, FLAG_RESULT_START, request.request_id, payload(failure)))
                request = peer._read_expected(2)
                peer._write(Message(TYPE_RESPONSE, 0, request.request_id, payload(rows(99))))
            except Exception as exc:
                failures.append(exc)

        worker = threading.Thread(target=serve)
        worker.start()
        try:
            query = protocol.query("CALL partial_error()")
            self.assertEqual(query.next_frame().rows, (("7",),))
            self.assertIsNone(query.next_frame())
            with self.assertRaisesRegex(dbapi.DatabaseError, "error after completed result"):
                query.next_result()
            query.close()
            following = protocol.query("SELECT 99")
            self.assertEqual(following.next_frame().rows, (("99",),))
            following.close()
        finally:
            worker.join(timeout=3)
            left.close()
            right.close()
        self.assertFalse(worker.is_alive())
        if failures:
            raise failures[0]


if __name__ == "__main__":
    unittest.main()
