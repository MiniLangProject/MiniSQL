/*
 * Copyright 2026 MiniLangProject contributors
 * Licensed under the Apache License, Version 2.0; see LICENSE for details.
 */
package org.minilang.minisql.jdbc;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Properties;

/** Immutable, validated connection configuration parsed from a JDBC URL. */
final class MiniSqlUrl {
    final String originalUrl;
    final String host;
    final int port;
    final String database;
    final String user;
    final String password;
    final boolean tls;
    final String serverName;
    final String pinSha256;
    final boolean trustServerCertificate;
    final int connectTimeoutMs;
    final int socketTimeoutMs;

    private MiniSqlUrl(String originalUrl, String host, int port, String database, Map<String, String> values)
            throws SQLException {
        this.originalUrl = originalUrl;
        this.host = host;
        this.port = port;
        this.database = database;
        this.user = blankToNull(values.get("user"));
        this.password = values.getOrDefault("password", "");
        this.tls = booleanValue(values, "tls", false);
        this.serverName = values.getOrDefault("serverName", host);
        this.pinSha256 = normalizePin(blankToNull(values.get("pinSha256")));
        this.trustServerCertificate = booleanValue(values, "trustServerCertificate", false);
        this.connectTimeoutMs = integerValue(values, "connectTimeoutMs", 10_000, 0, 3_600_000);
        this.socketTimeoutMs = integerValue(values, "socketTimeoutMs", 30_000, 0, 3_600_000);
        if (trustServerCertificate && pinSha256 == null) {
            throw new SQLException("trustServerCertificate requires pinSha256", "08001");
        }
        if ((pinSha256 != null || trustServerCertificate) && !tls) {
            throw new SQLException("Certificate options require tls=true", "08001");
        }
    }

    /** Parses jdbc:minisql://host[:port]/database?key=value and merges JDBC properties. */
    static MiniSqlUrl parse(String url, Properties properties) throws SQLException {
        if (url == null || !url.startsWith(MiniSqlDriver.URL_PREFIX)) {
            throw new SQLException("Invalid MiniSQL JDBC URL", "08001");
        }
        String remainder = url.substring(MiniSqlDriver.URL_PREFIX.length());
        int queryAt = remainder.indexOf('?');
        String location = queryAt < 0 ? remainder : remainder.substring(0, queryAt);
        String query = queryAt < 0 ? "" : remainder.substring(queryAt + 1);
        int slash = location.indexOf('/');
        String authority = slash < 0 ? location : location.substring(0, slash);
        String database = slash < 0 ? "main" : decode(location.substring(slash + 1));
        if (authority.isEmpty()) authority = "127.0.0.1:7432";

        String host;
        int port = 7432;
        if (authority.startsWith("[")) {
            int end = authority.indexOf(']');
            if (end < 0) throw new SQLException("Invalid bracketed host", "08001");
            host = authority.substring(1, end);
            if (end + 1 < authority.length()) port = parsePort(authority.substring(end + 2));
        } else {
            int colon = authority.lastIndexOf(':');
            host = colon < 0 ? authority : authority.substring(0, colon);
            if (colon >= 0) port = parsePort(authority.substring(colon + 1));
        }
        if (host.isEmpty() || database.isEmpty()) throw new SQLException("Host and database must not be empty", "08001");

        Map<String, String> values = new LinkedHashMap<>();
        if (properties != null) {
            for (String name : properties.stringPropertyNames()) values.put(name, properties.getProperty(name));
        }
        if (!query.isEmpty()) {
            for (String pair : query.split("&")) {
                int equals = pair.indexOf('=');
                values.put(decode(equals < 0 ? pair : pair.substring(0, equals)),
                        decode(equals < 0 ? "" : pair.substring(equals + 1)));
            }
        }
        return new MiniSqlUrl(url, host, port, database, values);
    }

    private static int parsePort(String value) throws SQLException {
        try {
            int port = Integer.parseInt(value);
            if (port < 1 || port > 65535) throw new NumberFormatException();
            return port;
        } catch (NumberFormatException exception) {
            throw new SQLException("Invalid MiniSQL port", "08001", exception);
        }
    }

    private static String decode(String text) throws SQLException {
        try { return URLDecoder.decode(text, StandardCharsets.UTF_8.name()); }
        catch (Exception exception) { throw new SQLException("Invalid URL encoding", "08001", exception); }
    }

    private static boolean booleanValue(Map<String, String> values, String name, boolean fallback) throws SQLException {
        String value = values.get(name);
        if (value == null) return fallback;
        if ("true".equalsIgnoreCase(value)) return true;
        if ("false".equalsIgnoreCase(value)) return false;
        throw new SQLException(name + " must be true or false", "08001");
    }

    private static int integerValue(Map<String, String> values, String name, int fallback, int minimum, int maximum)
            throws SQLException {
        String value = values.get(name);
        if (value == null) return fallback;
        try {
            int parsed = Integer.parseInt(value);
            if (parsed < minimum || parsed > maximum) throw new NumberFormatException();
            return parsed;
        } catch (NumberFormatException exception) {
            throw new SQLException(name + " is outside its supported range", "08001", exception);
        }
    }

    private static String normalizePin(String pin) throws SQLException {
        if (pin == null) return null;
        String normalized = pin.replace(":", "").replace("-", "").trim().toLowerCase();
        if (!normalized.matches("[0-9a-f]{64}")) throw new SQLException("pinSha256 must contain 32 hexadecimal bytes", "08001");
        return normalized;
    }

    private static String blankToNull(String value) { return value == null || value.trim().isEmpty() ? null : value; }
}
