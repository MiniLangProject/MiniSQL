/*
 * Copyright 2026 MiniLangProject contributors
 * Licensed under the Apache License, Version 2.0; see LICENSE for details.
 */
package org.minilang.minisql.jdbc;

import java.sql.BatchUpdateException;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.concurrent.atomic.AtomicReference;

/** Live trusted-local integration test, including a continuation-frame result set. */
public final class IntegrationTest {
    private static int checks;

    public static void main(String[] arguments) throws Exception {
        if (arguments.length < 1) throw new IllegalArgumentException("Expected JDBC URL");
        Class.forName("org.minilang.minisql.jdbc.MiniSqlDriver");
        try (Connection connection = DriverManager.getConnection(arguments[0]);
             Statement statement = connection.createStatement()) {
            check(connection.isValid(2), "PING/PONG validation");
            statement.executeUpdate("CREATE TABLE IF NOT EXISTS jdbc_probe (id INTEGER PRIMARY KEY, label VARCHAR(80), active BOOLEAN)");
            statement.executeUpdate("DELETE FROM jdbc_probe");

            StringBuilder insert = new StringBuilder("INSERT INTO jdbc_probe(id, label, active) VALUES ");
            for (int id = 1; id <= 520; id++) {
                if (id > 1) insert.append(',');
                insert.append('(').append(id).append(",'row ").append(id).append("',")
                        .append((id & 1) == 0 ? "TRUE" : "FALSE").append(')');
            }
            equal(statement.executeUpdate(insert.toString()), 520, "bulk insert count");

            try (PreparedStatement prepared = connection.prepareStatement(
                    "SELECT id, label, active FROM jdbc_probe WHERE id >= ? ORDER BY id")) {
                prepared.setInt(1, 1);
                int rows = 0;
                try (ResultSet result = prepared.executeQuery()) {
                    ResultSetMetaData metadata = result.getMetaData();
                    equal(metadata.getColumnCount(), 3, "result column count");
                    while (result.next()) {
                        rows++;
                        equal(result.getInt("id"), rows, "ordered id");
                        equal(result.getString(2), "row " + rows, "label value");
                    }
                }
                equal(rows, 520, "result spans the 512-row protocol frame boundary");
                boolean planNameIsReserved = false;
                try {
                    statement.executeUpdate("PREPARE jdbc_ps_1 AS SELECT 1");
                } catch (java.sql.SQLException expected) {
                    planNameIsReserved = true;
                }
                check(planNameIsReserved, "JDBC PreparedStatement owns a server-side plan");
            }
            statement.executeUpdate("PREPARE jdbc_ps_1 AS SELECT 1");
            statement.executeUpdate("DEALLOCATE PREPARE jdbc_ps_1");

            try (PreparedStatement insertOne = connection.prepareStatement(
                    "INSERT INTO jdbc_probe(id, label, active) VALUES (?, ?, ?)")) {
                insertOne.setInt(1, 521);
                insertOne.setString(2, "O'Reilly");
                insertOne.setBoolean(3, true);
                equal(insertOne.executeUpdate(), 1, "prepared insert");
            }
            try (ResultSet quoted = statement.executeQuery("SELECT label FROM jdbc_probe WHERE id = 521")) {
                check(quoted.next(), "prepared string row");
                equal(quoted.getString(1), "O'Reilly", "prepared string escaping");
            }

            try (PreparedStatement batched = connection.prepareStatement(
                    "INSERT INTO jdbc_probe(id, label, active) VALUES (?, ?, ?)")) {
                for (int id = 1000; id < 1600; id++) {
                    batched.setInt(1, id);
                    batched.setString(2, "batch VALUES ('" + id + ")");
                    batched.setBoolean(3, (id & 1) == 0);
                    batched.addBatch();
                }
                int[] counts = batched.executeBatch();
                equal(counts.length, 600, "coalesced batch count length");
                for (int count : counts) equal(count, 1, "coalesced batch row count");
            }
            try (ResultSet batchedRows = statement.executeQuery(
                    "SELECT COUNT(*) AS count FROM jdbc_probe WHERE id >= 1000 AND id < 1600")) {
                check(batchedRows.next(), "coalesced batch count row");
                equal(batchedRows.getInt(1), 600, "coalesced batch persisted every row");
            }

            // Statement.cancel must use a second protocol connection: the
            // target connection is blocked waiting for this deliberately
            // expensive cross product to produce its first response frame.
            try (Statement cancellable = connection.createStatement()) {
                AtomicReference<Throwable> cancellationResult = new AtomicReference<>();
                Thread worker = new Thread(() -> {
                    try (ResultSet ignored = cancellable.executeQuery(
                            "SELECT SUM(a.id + b.id + c.id) FROM jdbc_probe a, jdbc_probe b, jdbc_probe c")) {
                        cancellationResult.set(new AssertionError("expensive JDBC query completed before cancellation"));
                    } catch (java.sql.SQLException expected) {
                        if (expected.getErrorCode() != 9035) cancellationResult.set(expected);
                    }
                }, "minisql-jdbc-cancellation-test");
                worker.start();
                Thread.sleep(250);
                cancellable.cancel();
                worker.join(10_000);
                check(!worker.isAlive(), "JDBC cancellation terminates the query promptly");
                if (cancellationResult.get() != null) throw new AssertionError(
                        "JDBC cancellation returned an unexpected result", cancellationResult.get());
                check(connection.isValid(2), "connection remains valid after JDBC cancellation");
            }

            try (PreparedStatement failingBatch = connection.prepareStatement(
                    "INSERT INTO jdbc_probe(id, label, active) VALUES (?, ?, ?)")) {
                for (int duplicate = 0; duplicate < 2; duplicate++) {
                    failingBatch.setInt(1, 2000);
                    failingBatch.setString(2, "duplicate batch row");
                    failingBatch.setBoolean(3, true);
                    failingBatch.addBatch();
                }
                try {
                    failingBatch.executeBatch();
                    throw new AssertionError("duplicate batch must fail");
                } catch (BatchUpdateException expected) {
                    equal(expected.getUpdateCounts().length, 1, "failed batch exposes successful prefix");
                    equal(expected.getUpdateCounts()[0], 1, "failed batch prefix count");
                }
            }
            try (ResultSet partialBatch = statement.executeQuery(
                    "SELECT COUNT(*) AS count FROM jdbc_probe WHERE id = 2000")) {
                check(partialBatch.next(), "partial batch count row");
                equal(partialBatch.getInt(1), 1, "failed auto-commit batch preserves successful prefix");
            }

            try (Statement competing = connection.createStatement();
                 ResultSet streaming = statement.executeQuery("SELECT id FROM jdbc_probe ORDER BY id")) {
                check(streaming.next(), "streaming result starts");
                try {
                    competing.executeQuery("SELECT 1");
                    throw new AssertionError("parallel statement must not interleave one protocol stream");
                } catch (java.sql.SQLException expected) {
                    checks++;
                }
                streaming.close();
                try (ResultSet reused = competing.executeQuery("SELECT 1 AS value")) {
                    check(reused.next(), "connection is reusable after draining result frames");
                    equal(reused.getInt(1), 1, "reused connection value");
                }
            }

            statement.executeUpdate("CREATE TABLE IF NOT EXISTS jdbc_temporal (id INTEGER PRIMARY KEY, d DATE, t TIME, ts TIMESTAMP)");
            statement.executeUpdate("DELETE FROM jdbc_temporal");
            Date date = Date.valueOf("2026-08-28");
            Time time = Time.valueOf("03:14:15");
            Timestamp timestamp = Timestamp.valueOf("2026-08-28 03:14:15.123456");
            try (PreparedStatement temporal = connection.prepareStatement(
                    "INSERT INTO jdbc_temporal(id, d, t, ts) VALUES (?, ?, ?, ?)")) {
                temporal.setInt(1, 1); temporal.setDate(2, date); temporal.setTime(3, time); temporal.setTimestamp(4, timestamp);
                equal(temporal.executeUpdate(), 1, "temporal prepared insert");
            }
            try (ResultSet temporal = statement.executeQuery("SELECT d, t, ts FROM jdbc_temporal WHERE id = 1")) {
                check(temporal.next(), "temporal result row");
                equal(temporal.getDate(1), date, "DATE conversion");
                equal(temporal.getTime(2), time, "TIME conversion");
                equal(temporal.getTimestamp(3), timestamp, "TIMESTAMP conversion");
            }

            connection.setAutoCommit(false);
            statement.executeUpdate("INSERT INTO jdbc_probe(id, label, active) VALUES (9999, 'rollback', TRUE)");
            connection.rollback();
            connection.setAutoCommit(true);
            try (ResultSet result = statement.executeQuery("SELECT COUNT(*) AS count FROM jdbc_probe WHERE id = 9999")) {
                check(result.next(), "rollback count row");
                equal(result.getInt("count"), 0, "rollback removed row");
            }

            DatabaseMetaData database = connection.getMetaData();
            equal(database.getDatabaseProductName(), "MiniSQL", "database product");
            boolean foundTable = false;
            try (ResultSet tables = database.getTables(null, null, "%", new String[] { "TABLE" })) {
                while (tables.next()) if ("jdbc_probe".equalsIgnoreCase(tables.getString("TABLE_NAME"))) foundTable = true;
            }
            check(foundTable, "JDBC getTables exposes live catalog");
            int columns = 0;
            try (ResultSet catalogColumns = database.getColumns(null, null, "jdbc_probe", "%")) {
                while (catalogColumns.next()) columns++;
            }
            equal(columns, 3, "JDBC getColumns maps DESCRIBE");
            if (arguments.length > 1 && "prepare-auth".equals(arguments[1])) {
                statement.executeUpdate("ALTER USER \"admin\" WITH PASSWORD 'jdbc-test-password'");
            }
        }
        System.out.println("MiniSQL JDBC integration tests: PASS (" + checks + " checks)");
    }

    private static void check(boolean condition, String label) { checks++; if (!condition) throw new AssertionError(label); }
    private static void equal(Object actual, Object expected, String label) {
        check(expected.equals(actual), label + ": expected=" + expected + " actual=" + actual);
    }
}
