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
import java.sql.ResultSet;
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
                    check(first.next() && first.getInt(1) == 2, "continuation row");
                    check(!first.next(), "same-schema next result is separate");
                    check(statement.getMoreResults(), "second result available");
                    ResultSet second = statement.getResultSet();
                    check(second.next() && second.getInt(1) == 3, "second result row");
                    check(statement.getMoreResults(), "early close advances to empty result");
                    check(!statement.getResultSet().next(), "empty result is retained");
                    check(!statement.getMoreResults() && statement.getUpdateCount() == 4, "CALL completion count");
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
        System.out.println("MiniSQL JDBC routine tests: PASS (" + checks + " checks)");
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
        ByteArrayOutputStream body = new ByteArrayOutputStream();
        body.write(ByteBuffer.allocate(24).order(ByteOrder.LITTLE_ENDIAN).putShort((short) response.status).putShort((short) 0)
                .putInt(response.columns.size()).putInt(response.rows.size()).putInt(response.affectedRows)
                .putInt(response.errorCode).putInt(0).array());
        field(body, response.command); field(body, response.message);
        for (String column : response.columns) field(body, column);
        for (String[] row : response.rows) for (String value : row) field(body, value);
        byte[] payload = body.toByteArray();
        byte[] header = ByteBuffer.allocate(32).order(ByteOrder.LITTLE_ENDIAN).put(new byte[] {'M','S','Q','L'})
                .putShort((short) 1).putShort((short) 100).putInt(flags).putInt(requestId).putInt(payload.length)
                .putInt(crc(payload)).putInt(0).putInt(0).array();
        ByteBuffer.wrap(header).order(ByteOrder.LITTLE_ENDIAN).putInt(24, crc(header));
        output.write(header); output.write(payload); output.flush();
    }
    private static int crc(byte[] bytes) { CRC32C crc = new CRC32C(); crc.update(bytes, 0, bytes.length); return (int) crc.getValue(); }
    private static void check(boolean condition, String label) { if (!condition) throw new AssertionError(label); checks++; }
}
