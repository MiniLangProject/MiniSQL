/*
 * Copyright 2026 MiniLangProject contributors
 * SPDX-License-Identifier: Apache-2.0
 * Licensed under the Apache License, Version 2.0; see LICENSE for details.
 */
package org.minilang.minisql.jdbc;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Types;

/** Exercises procedure streaming and positional outputs against a live MiniSQL server. */
public final class RoutineLiveTest {
    public static void main(String[] args) throws Exception {
        Class.forName("org.minilang.minisql.jdbc.MiniSqlDriver");
        int checks = 0;
        try (Connection connection = java.sql.DriverManager.getConnection(args[0])) {
            try (Statement statement = connection.createStatement()) {
                statement.execute("SET @jtotal = 0, @jacc = 10");
                if (!statement.execute("CALL wire(5, @jtotal, @jacc)")) throw new AssertionError("CALL row result");
                int rows = 0;
                try (ResultSet first = statement.getResultSet()) { while (first.next()) rows++; }
                if (rows != 600) throw new AssertionError("600-row procedure result: " + rows);
                checks++;
                if (!statement.getMoreResults()) throw new AssertionError("second result missing");
                try (ResultSet second = statement.getResultSet()) {
                    if (!second.next() || second.getInt(1) != 5 || second.next()) throw new AssertionError("second result value");
                }
                checks++;
                if (!statement.getMoreResults()) throw new AssertionError("empty result missing");
                if (statement.getResultSet().next()) throw new AssertionError("empty result has rows");
                checks++;
                if (statement.getMoreResults()) throw new AssertionError("CALL completion must be command");
                if (statement.getMoreResults() || statement.getUpdateCount() != -1) throw new AssertionError("CALL not exhausted");
                checks++;
                try (ResultSet values = statement.executeQuery("SELECT @jtotal, @jacc")) {
                    if (!values.next() || values.getInt(1) != 600 || values.getInt(2) != 15) throw new AssertionError("session outputs");
                }
                checks++;
            }
            try (CallableStatement call = connection.prepareCall("{call wire(?, ?, ?)}")) {
                call.setInt(1, 5); call.registerOutParameter(2, Types.INTEGER);
                call.setInt(3, 10); call.registerOutParameter(3, Types.INTEGER);
                if (!call.execute() || call.getInt(2) != 600 || call.getInt(3) != 15) throw new AssertionError("CallableStatement outputs");
                checks++;
                int rows = 0;
                while (call.getResultSet().next()) rows++;
                if (rows != 600 || !call.getMoreResults()) throw new AssertionError("buffered result boundaries");
                checks++;
                if (!call.getResultSet().next() || call.getResultSet().getInt(1) != 5) throw new AssertionError("buffered second result");
                checks++;
            }
            try (CallableStatement call = connection.prepareCall("{call handled(?)}")) {
                call.registerOutParameter(1, Types.INTEGER);
                if (!call.execute() || call.getInt(1) != 42) throw new AssertionError("handled error output");
                checks++;
            }
            try (Statement statement = connection.createStatement()) {
                boolean failed = false;
                try { statement.execute("CALL broken()"); } catch (java.sql.SQLException expected) {
                    failed = expected.getMessage().contains("deliberate live error")
                            && "45000".equals(expected.getSQLState());
                }
                if (!failed) throw new AssertionError("unhandled SIGNAL must fail");
                checks++;
                try (ResultSet rows = statement.executeQuery("SELECT 99")) {
                    if (!rows.next() || rows.getInt(1) != 99) throw new AssertionError("alignment after SIGNAL");
                }
                checks++;
                if (!statement.execute("CALL partial_error()")) throw new AssertionError("completed SELECT missing");
                try (ResultSet rows = statement.getResultSet()) {
                    if (!rows.next() || rows.getInt(1) != 7 || rows.next()) throw new AssertionError("completed SELECT before SIGNAL");
                }
                checks++;
                failed = false;
                try { statement.getMoreResults(); } catch (java.sql.SQLException expected) {
                    failed = expected.getMessage().contains("error after completed result")
                            && "45000".equals(expected.getSQLState());
                }
                if (!failed) throw new AssertionError("getMoreResults must expose later SIGNAL");
                checks++;
                try (ResultSet rows = statement.executeQuery("SELECT 100")) {
                    if (!rows.next() || rows.getInt(1) != 100) throw new AssertionError("alignment after partial-result error");
                }
                checks++;
            }
        }
        System.out.println("MiniSQL JDBC live procedure tests: PASS (" + checks + " checks)");
    }
}
