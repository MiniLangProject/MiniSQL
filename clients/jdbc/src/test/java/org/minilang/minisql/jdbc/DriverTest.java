/*
 * Copyright 2026 MiniLangProject contributors
 * Licensed under the Apache License, Version 2.0; see LICENSE for details.
 */
package org.minilang.minisql.jdbc;

import java.sql.DriverPropertyInfo;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;

/** Dependency-free unit tests for URL parsing, PBKDF2, and prepared SQL scanning. */
public final class DriverTest {
    private static int checks;

    public static void main(String[] arguments) throws Exception {
        MiniSqlDriver driver = new MiniSqlDriver();
        check(driver.acceptsURL("jdbc:minisql://localhost:7432/main"), "driver accepts MiniSQL URL");
        check(!driver.acceptsURL("jdbc:postgresql://localhost/main"), "driver rejects foreign URL");

        Properties properties = new Properties();
        properties.setProperty("user", "alice");
        MiniSqlUrl url = MiniSqlUrl.parse(
                "jdbc:minisql://[::1]:7440/shop?tls=true&serverName=db.example&pinSha256="
                        + repeat("00", 32), properties);
        equal(url.host, "::1", "IPv6 host");
        equal(url.port, 7440, "port");
        equal(url.database, "shop", "database");
        equal(url.user, "alice", "property merge");
        check(url.tls, "TLS property");
        equal(url.serverName, "db.example", "server name");

        expectSql(() -> MiniSqlUrl.parse("jdbc:minisql://localhost:0/main", null), "invalid port");
        Properties insecure = new Properties();
        insecure.setProperty("tls", "true");
        insecure.setProperty("trustServerCertificate", "true");
        expectSql(() -> MiniSqlUrl.parse("jdbc:minisql://localhost/main", insecure), "pin required for self-signed trust");

        List<Integer> markers = MiniSqlJdbc.parameterMarkers(
                "SELECT '?', \"?\" FROM t WHERE a = ? AND b = ? -- ?\n/* ? */");
        equal(markers.size(), 2, "only executable question marks are parameters");

        byte[] derived = MiniSqlProtocol.pbkdf2(bytes("password"), bytes("salt"), 2, 32);
        equal(hex(derived), "ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43",
                "PBKDF2-HMAC-SHA256 vector");

        equal(MiniSqlProtocol.parseSessionId("MiniSQL protocol 1; session=42"), 42,
                "HELLO session identifier");
        equal(MiniSqlProtocol.parseSessionId("MiniSQL protocol 1"), 0,
                "legacy HELLO has no cancellable session");
        equal(MiniSqlProtocol.parseSessionId("MiniSQL protocol 1; session=invalid"), 0,
                "invalid HELLO session is rejected");

        DriverPropertyInfo[] info = driver.getPropertyInfo("jdbc:minisql://localhost/main", new Properties());
        check(info.length >= 8, "connection properties are discoverable");
        System.out.println("MiniSQL JDBC unit tests: PASS (" + checks + " checks)");
    }

    private static byte[] bytes(String value) { return value.getBytes(java.nio.charset.StandardCharsets.UTF_8); }
    private static String repeat(String value, int count) { StringBuilder result = new StringBuilder(); while (count-- > 0) result.append(value); return result.toString(); }
    private static String hex(byte[] bytes) { StringBuilder result = new StringBuilder(); for (byte value : bytes) result.append(String.format("%02x", value & 0xff)); return result.toString(); }
    private static void check(boolean condition, String label) { checks++; if (!condition) throw new AssertionError(label); }
    private static void equal(Object actual, Object expected, String label) { check(expected.equals(actual), label + ": expected=" + expected + " actual=" + actual); }
    private static void expectSql(CheckedRunnable action, String label) throws Exception {
        try { action.run(); throw new AssertionError(label + ": expected SQLException"); }
        catch (SQLException expected) { checks++; }
    }
    @FunctionalInterface private interface CheckedRunnable { void run() throws Exception; }
}
