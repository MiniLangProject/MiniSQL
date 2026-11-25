/*
 * Copyright 2026 MiniLangProject contributors
 * SPDX-License-Identifier: Apache-2.0
 * Licensed under the Apache License, Version 2.0; see LICENSE for details.
 */
package org.minilang.minisql.jdbc;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ParameterMetaData;
import java.sql.BatchUpdateException;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Types;

/** Exercises routine streaming, metadata, typed outputs, warnings and batching against MiniSQL. */
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
            try (Statement definitions = connection.createStatement()) {
                definitions.execute("CREATE OR REPLACE PROCEDURE \"JdbcMixed\"(IN p_count INT, OUT p_text VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin, INOUT p_total INT, OUT p_amount DECIMAL(8,2)) BEGIN SET p_text = 'NULL'; SET p_total = p_total + p_count; SET p_amount = CAST('7.25' AS DECIMAL(8,2)); SELECT 'NULL' AS literal_text, NULL AS null_text, p_total AS total; SIGNAL SQLSTATE '01000' SET MESSAGE_TEXT = 'JDBC warning'; END");
                definitions.execute("CREATE TABLE IF NOT EXISTS jdbc_batch_log(v INTEGER)");
                definitions.execute("DELETE FROM jdbc_batch_log");
                definitions.execute("CREATE OR REPLACE PROCEDURE jdbc_batch_add(IN p_value INT) BEGIN IF p_value < 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'negative batch value', MYSQL_ERRNO = 30177; END IF; INSERT INTO jdbc_batch_log(v) VALUES(p_value); END");
            }
            try (CallableStatement call = connection.prepareCall("{call \"JdbcMixed\"(?, ?, ?, ?)}")) {
                call.setInt("p_count", 3); call.registerOutParameter("p_text", Types.VARCHAR);
                call.setInt("p_total", 5); call.registerOutParameter("p_total", Types.INTEGER);
                call.registerOutParameter("p_amount", Types.DECIMAL);
                ParameterMetaData metadata = call.getParameterMetaData();
                if (metadata.getParameterMode(3) != ParameterMetaData.parameterModeInOut || metadata.getPrecision(2) != 20
                        || metadata.getScale(4) != 2) throw new AssertionError("native routine parameter metadata");
                checks++;
                if (!call.execute() || !"NULL".equals(call.getString("p_text")) || call.wasNull()
                        || !Integer.valueOf(8).equals(call.getObject("p_total"))
                        || !new java.math.BigDecimal("7.25").equals(call.getBigDecimal("p_amount"))) throw new AssertionError("typed named outputs");
                checks++;
                if (call.getWarnings() == null || !"01000".equals(call.getWarnings().getSQLState())) throw new AssertionError("native structured warning");
                checks++;
                ResultSet retained = call.getResultSet();
                if (call.getMoreResults(Statement.KEEP_CURRENT_RESULT)) throw new AssertionError("expected final CALL status");
                if (!retained.next() || !"NULL".equals(retained.getString("literal_text")) || retained.wasNull()
                        || retained.getString("null_text") != null || !retained.wasNull()
                        || retained.getMetaData().getColumnType(3) != Types.INTEGER) throw new AssertionError("retained typed NULL metadata");
                checks++;
                call.getMoreResults(Statement.CLOSE_ALL_RESULTS);
                if (!retained.isClosed()) throw new AssertionError("kept native result closes");
                checks++;
                try (Statement diagnostics = connection.createStatement(); ResultSet count = diagnostics.executeQuery("SELECT @@warning_count")) {
                    if (!count.next() || count.getInt(1) < 1) throw new AssertionError("CALL diagnostics survive output retrieval");
                }
                checks++;
            }
            try (ResultSet procedures = connection.getMetaData().getProcedures(null, "public", "JdbcMixed")) {
                if (!procedures.next() || !"JdbcMixed".equals(procedures.getString("PROCEDURE_NAME"))) throw new AssertionError("native JDBC procedure discovery");
                checks++;
            }
            try (ResultSet columns = connection.getMetaData().getProcedureColumns(null, "public", "JdbcMixed", "p\\_text")) {
                if (!columns.next() || columns.getInt("DATA_TYPE") != Types.VARCHAR || columns.getInt("CHAR_OCTET_LENGTH") != 80) throw new AssertionError("native JDBC procedure columns");
                checks++;
            }
            try (CallableStatement batch = connection.prepareCall("CALL jdbc_batch_add(?)")) {
                batch.setInt(1, 10); batch.addBatch(); batch.setInt(1, 20); batch.addBatch();
                if (!java.util.Arrays.equals(batch.executeBatch(), new int[] {1, 1})) throw new AssertionError("native callable batch counts");
                checks++;
                batch.setInt(1, 30); batch.addBatch(); batch.setInt(1, -1); batch.addBatch();
                boolean failed = false;
                try { batch.executeBatch(); } catch (BatchUpdateException expected) {
                    failed = expected.getErrorCode() == 30177 && java.util.Arrays.equals(expected.getUpdateCounts(), new int[] {1});
                }
                if (!failed) throw new AssertionError("native callable batch partial-success error");
                checks++;
            }
            try (Statement rows = connection.createStatement(); ResultSet count = rows.executeQuery("SELECT COUNT(*) FROM jdbc_batch_log")) {
                if (!count.next() || count.getInt(1) != 3) throw new AssertionError("native callable batch successful rows preserved");
                checks++;
            }
        }
        System.out.println("MiniSQL JDBC live procedure tests: PASS (" + checks + " checks)");
    }
}
