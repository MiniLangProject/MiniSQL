/*
 * Copyright 2026 MiniLangProject contributors
 * SPDX-License-Identifier: Apache-2.0
 * Licensed under the Apache License, Version 2.0; see LICENSE for details.
 */
package org.minilang.minisql.jdbc;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ParameterMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.BatchUpdateException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;
import java.util.zip.CRC32C;

/** Wire-level CALL tests with a disposable protocol peer and no database dependency. */
public final class RoutineTest {
    private static int checks;

    public static void main(String[] args) throws Exception {
        check(MiniSqlJdbc.parameterMarkers("SELECT `has?mark`, `escaped``?` FROM t WHERE id = ?").size() == 1, "backtick-aware binding");
        check(MiniSqlJdbc.procedureCallSql("{call tools.calculate(?, ?, ?)}").equals("call tools.calculate(?, ?, ?)"), "JDBC call escape");
        check(MiniSqlJdbc.procedureCallSql("{call \"My Schema\".\"MiXeD\"(?, ?)}").equals("call \"My Schema\".\"MiXeD\"(?, ?)"), "quoted mixed-case routine escape");
        check(MiniSqlJdbc.procedureCallSql("CALL `a``b`.`c.d`()").equals("CALL `a``b`.`c.d`()"), "backtick routine escaping");
        check(MiniSqlJdbc.procedureCallSql("{call no_arguments}").equals("call no_arguments"), "zero-argument call without parentheses");
        boolean rejected = false;
        try { MiniSqlJdbc.procedureCallSql("{? = call f(?)}"); } catch (java.sql.SQLException expected) { rejected = true; }
        check(rejected, "function return escape is not a procedure call");
        AtomicReference<Throwable> failure = new AtomicReference<>();
        List<String> requests = new ArrayList<>();
        try (ServerSocket listener = new ServerSocket(0, 1, InetAddress.getLoopbackAddress())) {
            Thread server = new Thread(() -> {
                try (Socket socket = listener.accept()) {
                    socket.setSoTimeout(3000);
                    InputStream input = socket.getInputStream();
                    OutputStream output = socket.getOutputStream();
                    int step = 0;
                    while (true) {
                        byte[] header = input.readNBytes(32);
                        if (header.length == 0) break;
                        if (header.length != 32) throw new AssertionError("truncated request");
                        ByteBuffer h = ByteBuffer.wrap(header).order(ByteOrder.LITTLE_ENDIAN);
                        int type = Short.toUnsignedInt(h.getShort(6));
                        int request = h.getInt(12);
                        byte[] body = input.readNBytes(h.getInt(16));
                        if (type == MiniSqlProtocol.TYPE_CLOSE) break;
                        if (type == MiniSqlProtocol.TYPE_HELLO) {
                            send(output, request, 0, command("HELLO", 0, "MiniSQL protocol 1; session=42"));
                            continue;
                        }
                        String sql = new String(body, StandardCharsets.UTF_8);
                        requests.add(sql);
                        if (step == 0) {
                            send(output, request, 6, rows("1"));
                            send(output, request, 2, rows("2"));
                            send(output, request, 6, rows("3"));
                            send(output, request, 6, rows());
                            send(output, request, 4, command("CALL", 4, "p"));
                        } else if (step == 1 || step == 4) {
                            send(output, request, 0, command("SET", 0, ""));
                        } else if (step == 2) {
                            send(output, request, 6, rows("7"));
                            send(output, request, 6, rows("9"));
                            send(output, request, 4, command("CALL", 4, "calculate"));
                        } else if (step == 3) {
                            send(output, request, 0, new MiniSqlProtocol.Response(2, "SELECT", Arrays.asList("out", "nullable"),
                                    Collections.singletonList(new String[] {"42", "NULL"}), 1, "", 0));
                        } else {
                            send(output, request, 0, rows("99"));
                        }
                        step++;
                    }
                } catch (Throwable caught) { failure.set(caught); }
            });
            server.start();
            MiniSqlUrl url = MiniSqlUrl.parse("jdbc:minisql://127.0.0.1:" + listener.getLocalPort() + "/main", null);
            try (Connection connection = MiniSqlJdbc.connection(url, MiniSqlProtocol.open(url))) {
                try (Statement statement = connection.createStatement()) {
                    check(statement.execute("CALL p()"), "first result is rows");
                    ResultSet first = statement.getResultSet();
                    check(first.next() && first.getInt(1) == 1, "first row");
                    check(statement.getMoreResults(Statement.KEEP_CURRENT_RESULT), "second result available while first retained");
                    ResultSet second = statement.getResultSet();
                    check(second.next() && second.getInt(1) == 3, "second result row");
                    check(first.next() && first.getInt(1) == 2, "retained continuation row");
                    check(!first.next(), "same-schema next result is separate");
                    check(!first.isClosed(), "exhaustion does not close retained result");
                    check(statement.getMoreResults(Statement.KEEP_CURRENT_RESULT), "retained result advances to empty result");
                    check(second.getInt(1) == 3, "retained current row remains available");
                    check(!statement.getResultSet().next(), "empty result is retained");
                    check(!statement.getMoreResults(Statement.CLOSE_ALL_RESULTS) && statement.getUpdateCount() == 4, "CALL completion count");
                    check(first.isClosed() && second.isClosed(), "CLOSE_ALL_RESULTS closes retained cursors");
                    check(!statement.getMoreResults() && statement.getUpdateCount() == -1, "request exhausted");
                }
                try (CallableStatement call = connection.prepareCall("{call tools.calculate(?, ?, ?)}")) {
                    call.setString(1, "O'Reilly");
                    call.setInt(2, 5);
                    call.registerOutParameter(2, Types.INTEGER);
                    call.registerOutParameter(3, Types.VARCHAR);
                    check(call.execute(), "CallableStatement returns first result");
                    check(call.getInt(2) == 42 && !call.wasNull(), "INOUT retrieved after buffered CALL");
                    check(call.getString(3) == null && call.wasNull(), "NULL OUT retrieved");
                    check(call.getObject(2, Integer.class).equals(42), "typed output getter");
                    check(call.getResultSet().next() && call.getResultSet().getInt(1) == 7, "first buffered result");
                    check(call.getMoreResults(), "second buffered result retained");
                    check(call.getResultSet().next() && call.getResultSet().getInt(1) == 9, "second buffered result");
                }
                try (Statement next = connection.createStatement(); ResultSet rows = next.executeQuery("SELECT 99")) {
                    check(rows.next() && rows.getInt(1) == 99, "connection aligned after early CallableStatement close");
                }
            }
            server.join(4000);
            check(!server.isAlive(), "protocol peer terminated");
        }
        if (failure.get() != null) throw new AssertionError("protocol peer failed", failure.get());
        check(requests.get(1).contains("'O''Reilly'"), "input strings quoted");
        check(requests.get(2).startsWith("call tools.calculate(@"), "CALL uses output-capable session variables");
        check(requests.get(4).endsWith(" = NULL"), "temporary values cleaned up");
        testRoutineMetadataAndBatches();
        testExtendedResults();
        System.out.println("MiniSQL JDBC routine tests: PASS (" + checks + " checks)");
    }

    /** Exercises real metadata queries and captured parameter snapshots against a legacy peer. */
    private static void testRoutineMetadataAndBatches() throws Exception {
        List<String> requests = new ArrayList<>();
        withPeer("MiniSQL protocol 1; session=43", (sql, request, output) -> {
            requests.add(sql);
            if (sql.startsWith("SELECT SPECIFIC_SCHEMA")) {
                List<String[]> fields = new ArrayList<>();
                fields.add(new String[] {"My Schema", "MiXeD", "1", "IN", "p_input", "INTEGER", "NULL", "NULL", "10", "0", "NULL", "int"});
                fields.add(new String[] {"My Schema", "MiXeD", "2", "OUT", "p_output", "VARCHAR", "20", "80", "NULL", "NULL", "NULL", "varchar(20)"});
                send(output, request, 0, new MiniSqlProtocol.Response(2, "SELECT", Arrays.asList("SPECIFIC_SCHEMA", "SPECIFIC_NAME", "ORDINAL_POSITION", "PARAMETER_MODE", "PARAMETER_NAME", "DATA_TYPE", "CHARACTER_MAXIMUM_LENGTH", "CHARACTER_OCTET_LENGTH", "NUMERIC_PRECISION", "NUMERIC_SCALE", "DATETIME_PRECISION", "DTD_IDENTIFIER"), fields, fields.size(), "", 0));
            } else if (sql.startsWith("SELECT ROUTINE_SCHEMA")) {
                send(output, request, 0, new MiniSqlProtocol.Response(2, "SELECT", Arrays.asList("ROUTINE_SCHEMA", "ROUTINE_NAME", "ROUTINE_COMMENT", "SPECIFIC_NAME"),
                        Collections.singletonList(new String[] {"My Schema", "MiXeD", "catalog comment", "MiXeD"}), 1, "", 0));
            } else if (sql.startsWith("SELECT @")) {
                send(output, request, 0, rows("answer"));
            } else if (sql.startsWith("SET ")) {
                send(output, request, 0, command("SET", 0, ""));
            } else if (sql.startsWith("CALL fail_batch")) {
                send(output, request, 0, new MiniSqlProtocol.Response(3, "ERROR", Collections.emptyList(), Collections.emptyList(), 0, "SQLSTATE 45000: batch failure", 30001));
            } else {
                send(output, request, 0, command("CALL", 2, ""));
            }
        }, connection -> {
            try (CallableStatement call = connection.prepareCall("{call \"My Schema\".\"MiXeD\"(?, ?)}")) {
                call.setInt("P_INPUT", 8);
                call.registerOutParameter("p_output", Types.VARCHAR);
                ParameterMetaData metadata = call.getParameterMetaData();
                check(metadata.getParameterCount() == 2, "routine parameter metadata count");
                check(metadata.getParameterType(1) == Types.INTEGER && metadata.getPrecision(1) == 10, "integer parameter metadata");
                check(metadata.getParameterMode(2) == ParameterMetaData.parameterModeOut && metadata.getPrecision(2) == 20, "OUT text metadata");
                check(metadata.getParameterClassName(1).equals(Integer.class.getName()), "parameter Java type");
                expectSql(() -> metadata.getParameterMode(0), "parameter metadata index validated");
                expectSql(() -> call.setInt("absent", 1), "unknown named parameter rejected");
                check(!call.execute(), "named callable command result");
                check(call.getString("p_output").equals("answer"), "named output getter");
                expectSql(call::addBatch, "output parameters rejected for update-count batch");
            }
            DatabaseMetaData metadata = connection.getMetaData();
            check(metadata.supportsNamedParameters() && metadata.supportsMultipleOpenResults(), "JDBC feature metadata");
            try (ResultSet procedures = metadata.getProcedures("main", "My Schema", "MiX%D")) {
                check(procedures.getMetaData().getColumnCount() == 9 && procedures.next(), "JDBC procedure catalog shape");
                check(procedures.getString("PROCEDURE_NAME").equals("MiXeD") && procedures.getString("REMARKS").equals("catalog comment"), "JDBC procedure values");
            }
            try (ResultSet columns = metadata.getProcedureColumns(null, "My Schema", "MiXeD", "p\\_output")) {
                check(columns.getMetaData().getColumnCount() == 20 && columns.next(), "JDBC procedure-column catalog shape");
                check(columns.getInt("COLUMN_TYPE") == DatabaseMetaData.procedureColumnOut && columns.getInt("CHAR_OCTET_LENGTH") == 80, "JDBC output metadata values");
                check(!columns.next(), "metadata pattern escape matches one parameter");
            }
            try (ResultSet missing = metadata.getProcedures("different_database", null, null)) {
                check(!missing.next(), "catalog filtering does not leak another database");
            }
            try (CallableStatement batch = connection.prepareCall("CALL insert_batch(?)")) {
                batch.setInt(1, 10); batch.addBatch(); batch.setInt(1, 20); batch.addBatch();
                check(Arrays.equals(batch.executeBatch(), new int[] {2, 2}), "callable batch returns individual update counts");
                check(batch.executeLargeBatch().length == 0, "completed callable batch is cleared");
            }
            try (CallableStatement batch = connection.prepareCall("CALL fail_batch(?)")) {
                batch.setInt(1, 1); batch.addBatch();
                try { batch.executeBatch(); throw new AssertionError("batch must fail"); }
                catch (BatchUpdateException failure) {
                    check(failure.getUpdateCounts().length == 0 && failure.getErrorCode() == 30001 && failure.getSQLState().equals("45000"), "callable batch preserves error and completed counts");
                }
            }
        });
        check(requests.stream().anyMatch(sql -> sql.contains("SPECIFIC_SCHEMA = 'My Schema'") && sql.contains("SPECIFIC_NAME = 'MiXeD'")), "metadata preserves quoted case");
        check(requests.stream().anyMatch(sql -> sql.startsWith("SET ") && sql.endsWith(" = 10"))
                && requests.stream().anyMatch(sql -> sql.startsWith("SET ") && sql.endsWith(" = 20")), "batch captures separate input values");
    }

    /** Runs a bounded disposable peer; a failed client assertion cannot leave the peer thread alive. */
    private static void withPeer(String hello, PeerResponder responder, ClientAction action) throws Exception {
        AtomicReference<Throwable> failure = new AtomicReference<>();
        try (ServerSocket listener = new ServerSocket(0, 1, InetAddress.getLoopbackAddress())) {
            Thread peer = new Thread(() -> {
                try (Socket socket = listener.accept()) {
                    socket.setSoTimeout(5000);
                    InputStream input = socket.getInputStream(); OutputStream output = socket.getOutputStream();
                    while (true) {
                        byte[] header = input.readNBytes(32); if (header.length == 0) break;
                        if (header.length != 32) throw new AssertionError("truncated request");
                        ByteBuffer frame = ByteBuffer.wrap(header).order(ByteOrder.LITTLE_ENDIAN);
                        int type = Short.toUnsignedInt(frame.getShort(6)), request = frame.getInt(12);
                        byte[] body = input.readNBytes(frame.getInt(16));
                        if (type == MiniSqlProtocol.TYPE_CLOSE) break;
                        if (type == MiniSqlProtocol.TYPE_HELLO) send(output, request, 0, command("HELLO", 0, hello));
                        else responder.respond(new String(body, StandardCharsets.UTF_8), request, output);
                    }
                } catch (Throwable caught) { failure.set(caught); }
            });
            peer.setDaemon(true); peer.start();
            MiniSqlUrl url = MiniSqlUrl.parse("jdbc:minisql://127.0.0.1:" + listener.getLocalPort() + "/main", null);
            try (Connection connection = MiniSqlJdbc.connection(url, MiniSqlProtocol.open(url))) { action.run(connection); }
            finally { peer.join(6000); }
            check(!peer.isAlive(), "metadata protocol peer terminated");
        }
        if (failure.get() != null) throw new AssertionError("metadata protocol peer failed", failure.get());
    }

    private static void expectSql(SqlAction action, String label) throws Exception {
        try { action.run(); throw new AssertionError(label); } catch (SQLException expected) { checks++; }
    }
    @FunctionalInterface private interface SqlAction { void run() throws SQLException; }
    @FunctionalInterface private interface ClientAction { void run(Connection connection) throws Exception; }
    @FunctionalInterface private interface PeerResponder { void respond(String sql, int request, OutputStream output) throws Exception; }

    /** Negotiated metadata distinguishes actual NULL, keeps warnings, and defers terminal errors. */
    private static void testExtendedResults() throws Exception {
        List<String> requests = new ArrayList<>();
        withPeer("MiniSQL protocol 1; session=44; capabilities=results-v2", (sql, request, output) -> {
            requests.add(sql);
            if (sql.startsWith("SET ")) {
                send(output, request, 0, extendedCommand("SET", 0, Collections.emptyList(), Collections.emptyList()));
            } else if (sql.startsWith("CALL typed_outputs")) {
                List<String> columns = Arrays.asList("literal", "nullable", "integer");
                List<Integer> types = Arrays.asList(9, 9, 3);
                send(output, request, 6, extendedRows(columns, Collections.singletonList(new String[] {"NULL", null, "7"}), types));
                send(output, request, 6, extendedRows(columns, Collections.emptyList(), types));
                List<MiniSqlProtocol.Condition> warnings = Arrays.asList(new MiniSqlProtocol.Condition("01000", 1642, "first warning"),
                        new MiniSqlProtocol.Condition("01004", 1265, "second warning"));
                List<MiniSqlProtocol.OutputParameter> outputs = Arrays.asList(new MiniSqlProtocol.OutputParameter(1, "text_result", 9, "NULL"),
                        new MiniSqlProtocol.OutputParameter(2, "null_result", 9, null), new MiniSqlProtocol.OutputParameter(3, "count_result", 3, "42"),
                        new MiniSqlProtocol.OutputParameter(4, "amount_result", 7, "7.25"));
                send(output, request, 4, extendedCommand("CALL", 0, warnings, outputs));
            } else if (sql.startsWith("CALL deferred_problem")) {
                send(output, request, 6, extendedRows(Collections.singletonList("value"), Collections.singletonList(new String[] {"17"}), Collections.singletonList(3)));
                send(output, request, 4, new MiniSqlProtocol.Response(3, "ERROR", Collections.emptyList(), Collections.emptyList(), 0,
                        "later problem without SQLSTATE in message", 31001, false, "45001", Collections.emptyList(), Collections.emptyList(), Collections.emptyList(), true));
            } else if (sql.startsWith("CALL large_spool")) {
                String value = String.join("", Collections.nCopies(4096, "x"));
                for (int index = 0; index < 400; index++) {
                    send(output, request, index == 0 ? 6 : 2, extendedRows(Collections.singletonList("payload"), Collections.singletonList(new String[] {value}), Collections.singletonList(9)));
                }
                send(output, request, 4, extendedCommand("CALL", 0, Collections.emptyList(), Collections.emptyList()));
            } else if (sql.equals("SELECT temporal")) {
                send(output, request, 0, extendedRows(Arrays.asList("past_date", "past_timestamp"), Collections.singletonList(new String[] {"-1", "-1"}), Arrays.asList(14, 16)));
            } else {
                send(output, request, 0, extendedRows(Collections.singletonList("value"), Collections.singletonList(new String[] {"99"}), Collections.singletonList(3)));
            }
        }, connection -> {
            try (CallableStatement call = connection.prepareCall("CALL typed_outputs(?, ?, ?, ?)")) {
                call.registerOutParameter(1, Types.VARCHAR); call.registerOutParameter(2, Types.VARCHAR); call.registerOutParameter(3, Types.INTEGER);
                call.registerOutParameter(4, Types.DECIMAL);
                check(call.execute(), "extended callable first result");
                check(call.getString(1).equals("NULL") && !call.wasNull(), "text NULL output stays text");
                check(call.getString(2) == null && call.wasNull(), "bitmap NULL output stays SQL NULL");
                check(call.getObject(3).equals(42), "structured output defaults to native Java type");
                check(call.getBigDecimal(4).equals(new java.math.BigDecimal("7.25")) && call.getObject(4) instanceof java.math.BigDecimal, "decimal output uses normalized decimal text");
                check(call.getWarnings() != null && call.getWarnings().getErrorCode() == 1642
                        && call.getWarnings().getNextWarning().getSQLState().equals("01004"), "statement warning chain preserves diagnostics");
                check(connection.getWarnings() != null && connection.getWarnings().getNextWarning() != null, "connection exposes call warning chain");
                call.clearWarnings();
                check(call.getWarnings() == null && connection.getWarnings() != null, "clearing statement warnings does not clear connection warnings");
                ResultSet retained = call.getResultSet();
                check(call.getMoreResults(Statement.KEEP_CURRENT_RESULT), "KEEP preserves an entirely unread result");
                check(!call.getResultSet().next(), "extended empty result remains visible");
                check(retained.next() && retained.getString(1).equals("NULL") && !retained.wasNull(), "retained literal NULL is not SQL NULL");
                check(retained.getString(2) == null && retained.wasNull(), "retained actual NULL is recognized");
                check(retained.getObject(3).equals(7) && retained.getMetaData().getColumnType(3) == Types.INTEGER, "typed row and result metadata");
                check(!call.getMoreResults(Statement.CLOSE_ALL_RESULTS) && call.getUpdateCount() == 0 && retained.isClosed(), "extended terminal status and retained-result cleanup");
            }
            check(requests.size() == 2 && requests.get(0).startsWith("SET ") && requests.get(1).startsWith("CALL "), "v2 outputs require no post-CALL SQL query or cleanup");
            try (CallableStatement call = connection.prepareCall("CALL deferred_problem")) {
                check(call.execute(), "callable completed SELECT survives later failure");
                check(call.getResultSet().next() && call.getResultSet().getInt(1) == 17, "earlier row readable before condition");
                try { call.getMoreResults(); throw new AssertionError("deferred error expected"); }
                catch (SQLException failure) { check(failure.getSQLState().equals("45001") && failure.getErrorCode() == 31001, "structured SQLSTATE survives deferred replay"); }
            }
            try (CallableStatement call = connection.prepareCall("CALL large_spool")) {
                check(call.execute(), "large callable result spooled");
                int count = 0; boolean intact = true; ResultSet result = call.getResultSet();
                while (result.next()) { intact &= result.getString(1).length() == 4096; count++; }
                check(count == 400 && intact, "all spilled continuation frames replayed intact");
            }
            try (Statement next = connection.createStatement(); ResultSet result = next.executeQuery("SELECT 99")) {
                check(result.next() && result.getObject(1).equals(99), "connection reusable after deferred error and large replay");
            }
            try (Statement temporal = connection.createStatement(); ResultSet result = temporal.executeQuery("SELECT temporal")) {
                check(result.next() && result.getDate(1).toLocalDate().equals(java.time.LocalDate.of(1969, 12, 31)), "negative epoch date conversion");
                check(result.getTimestamp(2).toLocalDateTime().equals(java.time.LocalDateTime.of(1969, 12, 31, 23, 59, 59, 999999000)), "negative epoch timestamp conversion");
            }
        });
    }

    private static MiniSqlProtocol.Response extendedRows(List<String> columns, List<String[]> values, List<Integer> types) {
        return new MiniSqlProtocol.Response(2, "SELECT", columns, values, values.size(), "", 0, false, "00000",
                Collections.emptyList(), types, Collections.emptyList(), true);
    }

    private static MiniSqlProtocol.Response extendedCommand(String command, int count, List<MiniSqlProtocol.Condition> warnings, List<MiniSqlProtocol.OutputParameter> outputs) {
        return new MiniSqlProtocol.Response(1, command, Collections.emptyList(), Collections.emptyList(), count, "", 0, false, "00000",
                warnings, Collections.emptyList(), outputs, true);
    }

    private static MiniSqlProtocol.Response rows(String... values) {
        List<String[]> data = new ArrayList<>();
        for (String value : values) data.add(new String[] {value});
        return new MiniSqlProtocol.Response(2, "SELECT", Collections.singletonList("value"), data, data.size(), "", 0);
    }
    private static MiniSqlProtocol.Response command(String command, int count, String message) {
        return new MiniSqlProtocol.Response(1, command, Collections.emptyList(), Collections.emptyList(), count, message, 0);
    }
    private static void field(ByteArrayOutputStream output, String text) throws Exception {
        byte[] value = text.getBytes(StandardCharsets.UTF_8);
        output.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(value.length).array());
        output.write(value);
    }
    private static void send(OutputStream output, int requestId, int flags, MiniSqlProtocol.Response response) throws Exception {
        byte[] payload = MiniSqlProtocol.encodeResponse(response);
        if (response.extended) flags |= 8;
        byte[] header = ByteBuffer.allocate(32).order(ByteOrder.LITTLE_ENDIAN).put(new byte[] {'M','S','Q','L'})
                .putShort((short) 1).putShort((short) 100).putInt(flags).putInt(requestId).putInt(payload.length)
                .putInt(crc(payload)).putInt(0).putInt(0).array();
        ByteBuffer.wrap(header).order(ByteOrder.LITTLE_ENDIAN).putInt(24, crc(header));
        output.write(header); output.write(payload); output.flush();
    }
    private static int crc(byte[] bytes) { CRC32C crc = new CRC32C(); crc.update(bytes, 0, bytes.length); return (int) crc.getValue(); }
    private static void check(boolean condition, String label) { if (!condition) throw new AssertionError(label); checks++; }
}
