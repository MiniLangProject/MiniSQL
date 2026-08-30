/*
 * Copyright 2026 MiniLangProject contributors
 * Licensed under the Apache License, Version 2.0; see LICENSE for details.
 */
package org.minilang.minisql.jdbc;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.BatchUpdateException;
import java.sql.DatabaseMetaData;
import java.sql.Date;
import java.sql.ParameterMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.SQLFeatureNotSupportedException;
import java.sql.SQLNonTransientException;
import java.sql.SQLWarning;
import java.sql.Statement;
import java.sql.Time;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.Executor;

/** Dynamic JDBC interface adapters around the compact MiniSQL protocol client. */
final class MiniSqlJdbc {
    private MiniSqlJdbc() { }

    static Connection connection(MiniSqlUrl url, MiniSqlProtocol protocol) {
        ConnectionHandler handler = new ConnectionHandler(url, protocol);
        Connection proxy = proxy(Connection.class, handler);
        handler.proxy = proxy;
        return proxy;
    }

    @SuppressWarnings("unchecked")
    private static <T> T proxy(Class<T> type, InvocationHandler handler) {
        return (T) Proxy.newProxyInstance(MiniSqlDriver.class.getClassLoader(), new Class<?>[] { type }, handler);
    }

    private abstract static class BaseHandler implements InvocationHandler {
        private final String label;
        BaseHandler(String label) { this.label = label; }

        @Override
        public final Object invoke(Object proxy, Method method, Object[] arguments) throws Throwable {
            String name = method.getName();
            if (name.equals("toString") && method.getParameterCount() == 0) return label;
            if (name.equals("hashCode") && method.getParameterCount() == 0) return System.identityHashCode(proxy);
            if (name.equals("equals") && method.getParameterCount() == 1) return proxy == arguments[0];
            if (name.equals("isWrapperFor")) return ((Class<?>) arguments[0]).isInstance(proxy);
            if (name.equals("unwrap")) {
                Class<?> requested = (Class<?>) arguments[0];
                if (requested.isInstance(proxy)) return proxy;
                throw new SQLException("Not a wrapper for " + requested.getName(), "S1009");
            }
            return call(proxy, method, arguments == null ? new Object[0] : arguments);
        }

        abstract Object call(Object proxy, Method method, Object[] arguments) throws Throwable;

        Object unsupported(Method method) throws SQLFeatureNotSupportedException {
            throw new SQLFeatureNotSupportedException(method.getDeclaringClass().getSimpleName() + '.' + method.getName()
                    + " is not supported by MiniSQL JDBC", "0A000");
        }
    }

    /** Owns transaction state and serializes access to the single protocol stream. */
    private static final class ConnectionHandler extends BaseHandler {
        final MiniSqlUrl url;
        final MiniSqlProtocol protocol;
        Connection proxy;
        boolean closed;
        boolean autoCommit = true;
        boolean transactionActive;
        boolean readOnly;
        int isolation = Connection.TRANSACTION_SERIALIZABLE;
        int networkTimeout;
        long nextPreparedStatementId;
        long nextBatchSavepointId;
        final Properties clientInfo = new Properties();

        ConnectionHandler(MiniSqlUrl url, MiniSqlProtocol protocol) {
            super("MiniSQLConnection[" + url.host + ':' + url.port + '/' + url.database + ']');
            this.url = url; this.protocol = protocol; this.networkTimeout = url.socketTimeoutMs;
        }

        @Override Object call(Object ignored, Method method, Object[] args) throws Throwable {
            String name = method.getName();
            if (name.equals("close")) { close(); return null; }
            if (name.equals("isClosed")) return closed;
            if (name.equals("isValid")) return !closed && protocol.ping();
            ensureOpen();
            switch (name) {
                case "createStatement": return statement(this, null);
                case "prepareStatement": return statement(this, (String) args[0]);
                case "nativeSQL": return args[0];
                case "getAutoCommit": return autoCommit;
                case "setAutoCommit": setAutoCommit((Boolean) args[0]); return null;
                case "commit": finishTransaction(true); return null;
                case "rollback":
                    if (args.length == 0) { finishTransaction(false); return null; }
                    return unsupported(method);
                case "getMetaData": return databaseMetaData(this);
                case "setReadOnly": readOnly = (Boolean) args[0]; return null;
                case "isReadOnly": return readOnly;
                case "setCatalog":
                    if (args[0] != null && !url.database.equals(args[0])) throw new SQLException("MiniSQL server exposes one database", "3D000");
                    return null;
                case "getCatalog": return url.database;
                case "setSchema":
                    if (args[0] != null && !"public".equalsIgnoreCase((String) args[0])) return unsupported(method);
                    return null;
                case "getSchema": return "public";
                case "getTransactionIsolation": return isolation;
                case "setTransactionIsolation": setIsolation((Integer) args[0]); return null;
                case "getWarnings": return null;
                case "clearWarnings": return null;
                case "getTypeMap": return Collections.emptyMap();
                case "setTypeMap": if (!((Map<?, ?>) args[0]).isEmpty()) return unsupported(method); return null;
                case "setHoldability":
                    if ((Integer) args[0] != ResultSet.CLOSE_CURSORS_AT_COMMIT) return unsupported(method);
                    return null;
                case "getHoldability": return ResultSet.CLOSE_CURSORS_AT_COMMIT;
                case "setClientInfo": setClientInfo(args); return null;
                case "getClientInfo": return args.length == 0 ? copy(clientInfo) : clientInfo.getProperty((String) args[0]);
                case "abort": close(); return null;
                case "setNetworkTimeout":
                    int requestedNetworkTimeout = (Integer) args[1];
                    if (requestedNetworkTimeout < 0) throw new SQLException("Network timeout must be non-negative", "S1009");
                    protocol.setSocketTimeout(requestedNetworkTimeout);
                    networkTimeout = requestedNetworkTimeout;
                    return null;
                case "getNetworkTimeout": return networkTimeout;
                case "beginRequest": return null;
                case "endRequest": return null;
                default: return unsupported(method);
            }
        }

        private void setAutoCommit(boolean enabled) throws SQLException {
            if (autoCommit == enabled) return;
            if (!enabled) {
                beginTransaction();
            } else {
                if (transactionActive) executeCommand("COMMIT");
                transactionActive = false;
            }
            autoCommit = enabled;
        }

        private void beginTransaction() throws SQLException {
            String level = isolation == Connection.TRANSACTION_READ_COMMITTED ? "READ COMMITTED" : "SERIALIZABLE";
            executeCommand("BEGIN ISOLATION LEVEL " + level + (readOnly ? " READ ONLY" : " READ WRITE"));
            transactionActive = true;
        }

        private void finishTransaction(boolean commit) throws SQLException {
            if (autoCommit) throw new SQLException("Connection is in auto-commit mode", "25000");
            if (transactionActive) executeCommand(commit ? "COMMIT" : "ROLLBACK");
            transactionActive = false;
            beginTransaction();
        }

        private void setIsolation(int value) throws SQLException {
            if (value != Connection.TRANSACTION_READ_COMMITTED && value != Connection.TRANSACTION_SERIALIZABLE) {
                throw new SQLFeatureNotSupportedException("MiniSQL supports READ_COMMITTED and SERIALIZABLE", "0A000");
            }
            if (!autoCommit) throw new SQLException("Change isolation before starting a transaction", "25001");
            isolation = value;
        }

        MiniSqlProtocol.Response executeCommand(String sql) throws SQLException {
            MiniSqlProtocol.Query query = protocol.query(sql);
            try {
                MiniSqlProtocol.Response result = query.nextFrame();
                if (result.status == MiniSqlProtocol.STATUS_ROWS) throw new SQLException("Expected a command response", "HY000");
                return result;
            } finally { query.close(); }
        }

        String allocatePreparedStatementName() {
            return "jdbc_ps_" + (++nextPreparedStatementId);
        }

        String allocateBatchSavepointName() {
            return "jdbc_batch_" + (++nextBatchSavepointId);
        }

        private void setClientInfo(Object[] args) {
            if (args.length == 2) clientInfo.setProperty((String) args[0], (String) args[1]);
            else { clientInfo.clear(); clientInfo.putAll((Properties) args[0]); }
        }

        private void close() {
            if (!closed) {
                if (transactionActive) { try { executeCommand("ROLLBACK"); } catch (SQLException ignored) { } }
                protocol.close(); closed = true;
            }
        }

        void ensureOpen() throws SQLException { if (closed) throw new SQLException("MiniSQL connection is closed", "08003"); }
        private static Properties copy(Properties source) { Properties target = new Properties(); target.putAll(source); return target; }
    }

    private static Statement statement(ConnectionHandler connection, String template) {
        StatementHandler handler = new StatementHandler(connection, template);
        Class<?> type = template == null ? Statement.class : PreparedStatement.class;
        Object proxy = proxy(type, handler);
        handler.proxy = (Statement) proxy;
        return (Statement) proxy;
    }

    /** Implements statements, server-backed prepared statements, and bounded insert batching. */
    private static final class StatementHandler extends BaseHandler {
        private static final int MAX_COALESCED_INSERT_ROWS = 256;
        private static final int MAX_COALESCED_INSERT_BYTES = 768 * 1024;
        final ConnectionHandler connection;
        final String template;
        final List<Integer> markers;
        final Map<Integer, String> parameters = new LinkedHashMap<>();
        final List<String> batch = new ArrayList<>();
        Statement proxy;
        ResultSet currentResult;
        int updateCount = -1;
        boolean closed;
        int maxRows;
        int queryTimeout;
        int fetchSize = 512;
        boolean poolable;
        volatile boolean executing;
        boolean prepareAttempted;
        boolean serverPrepared;
        String preparedName;

        StatementHandler(ConnectionHandler connection, String template) {
            super(template == null ? "MiniSQLStatement" : "MiniSQLPreparedStatement");
            this.connection = connection; this.template = template;
            this.markers = template == null ? Collections.emptyList() : parameterMarkers(template);
        }

        @Override Object call(Object ignored, Method method, Object[] args) throws Throwable {
            String name = method.getName();
            if (name.equals("close")) { closeStatement(); return null; }
            if (name.equals("isClosed")) return closed;
            ensureOpen();
            switch (name) {
                case "executeQuery":
                    execute(sqlArgument(args));
                    if (currentResult == null) throw new SQLException("Statement did not produce a ResultSet", "24000");
                    return currentResult;
                case "executeUpdate": case "executeLargeUpdate":
                    execute(sqlArgument(args));
                    if (currentResult != null) throw new SQLException("Statement produced a ResultSet", "24000");
                    if (name.startsWith("executeLarge")) return Long.valueOf(updateCount);
                    return Integer.valueOf(updateCount);
                case "execute": return execute(sqlArgument(args));
                case "getResultSet": return currentResult;
                case "getUpdateCount": return updateCount;
                case "getLargeUpdateCount": return (long) updateCount;
                case "getMoreResults": closeCurrent(); updateCount = -1; return false;
                case "getConnection": return connection.proxy;
                case "cancel": if (executing || currentResult != null) connection.protocol.cancelCurrentSession(); return null;
                case "getWarnings": return null;
                case "clearWarnings": return null;
                case "setMaxRows": maxRows = nonNegative((Integer) args[0], "maxRows"); return null;
                case "getMaxRows": return maxRows;
                case "setLargeMaxRows": maxRows = nonNegative(Math.toIntExact((Long) args[0]), "largeMaxRows"); return null;
                case "getLargeMaxRows": return (long) maxRows;
                case "setQueryTimeout":
                    int requestedTimeout = nonNegative((Integer) args[0], "queryTimeout");
                    if (requestedTimeout != 0) throw new SQLFeatureNotSupportedException(
                            "Per-statement timeouts are not available; use Connection.setNetworkTimeout", "0A000");
                    queryTimeout = 0;
                    return null;
                case "getQueryTimeout": return queryTimeout;
                case "setFetchSize": fetchSize = nonNegative((Integer) args[0], "fetchSize"); return null;
                case "getFetchSize": return fetchSize;
                case "setFetchDirection":
                    if ((Integer) args[0] != ResultSet.FETCH_FORWARD) return unsupported(method); return null;
                case "getFetchDirection": return ResultSet.FETCH_FORWARD;
                case "getResultSetType": return ResultSet.TYPE_FORWARD_ONLY;
                case "getResultSetConcurrency": return ResultSet.CONCUR_READ_ONLY;
                case "getResultSetHoldability": return ResultSet.CLOSE_CURSORS_AT_COMMIT;
                case "setEscapeProcessing": if (!(Boolean) args[0]) return unsupported(method); return null;
                case "setPoolable": poolable = (Boolean) args[0]; return null;
                case "isPoolable": return poolable;
                case "closeOnCompletion": return null;
                case "isCloseOnCompletion": return false;
                case "setCursorName": return unsupported(method);
                case "getGeneratedKeys": return resultSet(this, local(Collections.singletonList("GENERATED_KEY"), Collections.emptyList()), 0);
                case "addBatch":
                    if (template != null && args.length > 0) throw new SQLException(
                            "PreparedStatement.addBatch(String) is not permitted", "HY000");
                    batch.add(args.length == 0 ? boundSql() : (String) args[0]); return null;
                case "clearBatch": batch.clear(); return null;
                case "executeBatch": return executeBatch(false);
                case "executeLargeBatch": return executeBatch(true);
                case "clearParameters": parameters.clear(); return null;
                case "getParameterMetaData": return parameterMetaData(markers.size());
                case "getMetaData": return null;
                default:
                    if (template != null && name.startsWith("set")) { bind(name, args); return null; }
                    return unsupported(method);
            }
        }

        private String sqlArgument(Object[] args) throws SQLException {
            if (template == null) return (String) args[0];
            if (args.length != 0) throw new SQLException(
                    "SQL text cannot be supplied to an already prepared statement", "HY000");
            return executablePreparedSql();
        }

        /** Lazily prepares supported DML on the server and falls back for older servers or unsupported SQL. */
        private String executablePreparedSql() throws SQLException {
            requireAllParameters();
            if (!prepareAttempted) {
                prepareAttempted = true;
                preparedName = connection.allocatePreparedStatementName();
                try {
                    connection.executeCommand("PREPARE " + preparedName + " AS " + template);
                    serverPrepared = true;
                } catch (SQLException failure) {
                    if (failure.getSQLState() != null && failure.getSQLState().startsWith("08")) throw failure;
                    preparedName = null;
                }
            }
            if (!serverPrepared) return boundSql();
            StringBuilder sql = new StringBuilder("EXECUTE ").append(preparedName);
            if (!markers.isEmpty()) {
                sql.append(" USING ");
                for (int index = 1; index <= markers.size(); index++) {
                    if (index > 1) sql.append(',');
                    sql.append(parameters.get(index));
                }
            }
            return sql.toString();
        }

        private boolean execute(String sql) throws SQLException {
            closeCurrent();
            MiniSqlProtocol.Query query;
            executing = true;
            try { query = connection.protocol.query(sql); }
            finally { executing = false; }
            MiniSqlProtocol.Response first = query.first;
            if (first.status == MiniSqlProtocol.STATUS_ROWS) {
                currentResult = resultSet(this, query, maxRows); updateCount = -1; return true;
            }
            try { updateCount = first.affectedRows; return false; }
            finally { query.close(); }
        }

        private Object executeBatch(boolean large) throws SQLException {
            long[] counts = new long[batch.size()];
            int completed = 0;
            try {
                while (completed < batch.size()) {
                    InsertParts first = InsertParts.parse(batch.get(completed));
                    if (first == null) {
                        execute(batch.get(completed));
                        counts[completed++] = currentResult == null ? updateCount : Statement.SUCCESS_NO_INFO;
                        closeCurrent();
                        continue;
                    }

                    StringBuilder sql = new StringBuilder(first.prefix).append(first.tuple);
                    int chunkRows = 1;
                    int encodedBytes = sql.toString().getBytes(StandardCharsets.UTF_8).length;
                    while (completed + chunkRows < batch.size() && chunkRows < MAX_COALESCED_INSERT_ROWS) {
                        InsertParts next = InsertParts.parse(batch.get(completed + chunkRows));
                        if (next == null || !first.prefix.equals(next.prefix)) break;
                        int tupleBytes = next.tuple.getBytes(StandardCharsets.UTF_8).length + 1;
                        if (encodedBytes + tupleBytes > MAX_COALESCED_INSERT_BYTES) break;
                        sql.append(',').append(next.tuple);
                        encodedBytes += tupleBytes;
                        chunkRows++;
                    }

                    String coalescedSql = sql.append(';').toString();
                    String savepoint = null;
                    if (chunkRows > 1 && !connection.autoCommit) {
                        savepoint = connection.allocateBatchSavepointName();
                        connection.executeCommand("SAVEPOINT " + savepoint);
                    }
                    try {
                        execute(coalescedSql);
                        if (savepoint != null) connection.executeCommand("RELEASE SAVEPOINT " + savepoint);
                    } catch (SQLException coalescedFailure) {
                        if (savepoint != null) {
                            try {
                                connection.executeCommand("ROLLBACK TO SAVEPOINT " + savepoint);
                                connection.executeCommand("RELEASE SAVEPOINT " + savepoint);
                            } catch (SQLException recoveryFailure) {
                                coalescedFailure.addSuppressed(recoveryFailure);
                                throw coalescedFailure;
                            }
                        }
                        // A failed multi-row statement is atomic. Retrying the
                        // original entries individually preserves JDBC's
                        // partial-success counts and first-failure semantics.
                        for (int offset = 0; offset < chunkRows; offset++) {
                            execute(batch.get(completed));
                            counts[completed++] = currentResult == null ? updateCount : Statement.SUCCESS_NO_INFO;
                            closeCurrent();
                        }
                        continue;
                    }
                    long perStatement = currentResult == null ? 1L : Statement.SUCCESS_NO_INFO;
                    for (int offset = 0; offset < chunkRows; offset++) counts[completed + offset] = perStatement;
                    completed += chunkRows;
                    closeCurrent();
                }
            } catch (SQLException failure) {
                throw new BatchUpdateException(failure.getMessage(), failure.getSQLState(), failure.getErrorCode(),
                        Arrays.copyOf(counts, completed), failure);
            } finally {
                batch.clear();
            }
            if (large) return counts;
            int[] ordinary = new int[counts.length];
            for (int index = 0; index < counts.length; index++) ordinary[index] = (int) counts[index];
            return ordinary;
        }

        private void bind(String method, Object[] args) throws SQLException {
            int index = (Integer) args[0];
            if (index < 1 || index > markers.size()) throw new SQLException("Parameter index out of range: " + index, "07009");
            Object value = args.length > 1 ? args[1] : null;
            String literal;
            switch (method) {
                case "setNull": literal = "NULL"; break;
                case "setBoolean": literal = (Boolean) value ? "TRUE" : "FALSE"; break;
                case "setByte": case "setShort": case "setInt": case "setLong": case "setFloat":
                case "setDouble": case "setBigDecimal": literal = String.valueOf(value); break;
                case "setBytes": throw new SQLFeatureNotSupportedException(
                        "Protocol v1 has no SQL binary literal; setBytes is unavailable", "0A000");
                case "setDate": literal = "CAST(" + ((Date) value).toLocalDate().toEpochDay() + " AS DATE)"; break;
                case "setTime": literal = "CAST(" + (((Time) value).toLocalTime().toNanoOfDay() / 1_000L) + " AS TIME)"; break;
                case "setTimestamp": {
                    LocalDateTime timestamp = ((Timestamp) value).toLocalDateTime();
                    literal = "CAST(" + (timestamp.toLocalDate().toEpochDay() * 86_400_000_000L
                            + timestamp.toLocalTime().toNanoOfDay() / 1_000L) + " AS TIMESTAMP)";
                    break;
                }
                case "setObject": literal = objectLiteral(value); break;
                case "setString": case "setNString": literal = value == null ? "NULL" : quote((String) value); break;
                default: throw new SQLFeatureNotSupportedException(method + " is not supported", "0A000");
            }
            parameters.put(index, literal);
        }

        private String boundSql() throws SQLException {
            requireAllParameters();
            StringBuilder output = new StringBuilder(template.length() + markers.size() * 8);
            int source = 0;
            for (int index = 0; index < markers.size(); index++) {
                int marker = markers.get(index);
                output.append(template, source, marker).append(parameters.get(index + 1)); source = marker + 1;
            }
            return output.append(template, source, template.length()).toString();
        }

        private void requireAllParameters() throws SQLException {
            if (parameters.size() != markers.size()) {
                throw new SQLException("Not all prepared-statement parameters are bound", "07001");
            }
        }

        /** Releases both the active cursor and the session-local server plan. */
        private void closeStatement() throws SQLException {
            if (closed) return;
            SQLException failure = null;
            try { closeCurrent(); } catch (SQLException caught) { failure = caught; }
            if (serverPrepared && !connection.closed) {
                try { connection.executeCommand("DEALLOCATE PREPARE " + preparedName); }
                catch (SQLException caught) { if (failure == null) failure = caught; }
            }
            serverPrepared = false;
            closed = true;
            if (failure != null) throw failure;
        }

        private void closeCurrent() throws SQLException {
            if (currentResult != null) { currentResult.close(); currentResult = null; }
        }
        private void ensureOpen() throws SQLException { connection.ensureOpen(); if (closed) throw new SQLException("Statement is closed", "07000"); }
        private static int nonNegative(int value, String name) throws SQLException { if (value < 0) throw new SQLException(name + " must be non-negative", "S1009"); return value; }
    }

    /** A single-row INSERT split into its stable prefix and one VALUES tuple. */
    private static final class InsertParts {
        final String prefix;
        final String tuple;

        InsertParts(String prefix, String tuple) { this.prefix = prefix; this.tuple = tuple; }

        static InsertParts parse(String sql) {
            int values = findTopLevelKeyword(sql, "VALUES");
            if (values < 0 || !startsWithKeyword(sql, "INSERT")) return null;
            int tupleStart = values + 6;
            while (tupleStart < sql.length() && Character.isWhitespace(sql.charAt(tupleStart))) tupleStart++;
            if (tupleStart >= sql.length() || sql.charAt(tupleStart) != '(') return null;
            int tupleEnd = matchingParenthesis(sql, tupleStart);
            if (tupleEnd < 0) return null;
            int suffix = tupleEnd + 1;
            while (suffix < sql.length() && Character.isWhitespace(sql.charAt(suffix))) suffix++;
            if (suffix < sql.length() && sql.charAt(suffix) == ';') suffix++;
            while (suffix < sql.length() && Character.isWhitespace(sql.charAt(suffix))) suffix++;
            if (suffix != sql.length()) return null;
            return new InsertParts(sql.substring(0, tupleStart), sql.substring(tupleStart, tupleEnd + 1));
        }

        private static boolean startsWithKeyword(String sql, String keyword) {
            int index = 0;
            while (index < sql.length() && Character.isWhitespace(sql.charAt(index))) index++;
            return index + keyword.length() <= sql.length()
                    && sql.regionMatches(true, index, keyword, 0, keyword.length())
                    && (index + keyword.length() == sql.length()
                    || !Character.isJavaIdentifierPart(sql.charAt(index + keyword.length())));
        }

        /** Finds an unquoted keyword outside the INSERT column-list parentheses. */
        private static int findTopLevelKeyword(String sql, String keyword) {
            int depth = 0;
            boolean single = false, quotedIdentifier = false, lineComment = false, blockComment = false;
            for (int index = 0; index <= sql.length() - keyword.length(); index++) {
                char current = sql.charAt(index);
                char next = index + 1 < sql.length() ? sql.charAt(index + 1) : '\0';
                if (lineComment) { if (current == '\n' || current == '\r') lineComment = false; continue; }
                if (blockComment) { if (current == '*' && next == '/') { blockComment = false; index++; } continue; }
                if (single) {
                    if (current == '\'' && next == '\'') index++;
                    else if (current == '\'') single = false;
                    continue;
                }
                if (quotedIdentifier) {
                    if (current == '"' && next == '"') index++;
                    else if (current == '"') quotedIdentifier = false;
                    continue;
                }
                if (current == '-' && next == '-') { lineComment = true; index++; continue; }
                if (current == '/' && next == '*') { blockComment = true; index++; continue; }
                if (current == '\'') { single = true; continue; }
                if (current == '"') { quotedIdentifier = true; continue; }
                if (current == '(') { depth++; continue; }
                if (current == ')') { if (depth > 0) depth--; continue; }
                if (depth == 0 && sql.regionMatches(true, index, keyword, 0, keyword.length())) {
                    boolean left = index == 0 || !Character.isJavaIdentifierPart(sql.charAt(index - 1));
                    int end = index + keyword.length();
                    boolean right = end == sql.length() || !Character.isJavaIdentifierPart(sql.charAt(end));
                    if (left && right) return index;
                }
            }
            return -1;
        }

        private static int matchingParenthesis(String sql, int start) {
            int depth = 0;
            boolean single = false, quotedIdentifier = false, lineComment = false, blockComment = false;
            for (int index = start; index < sql.length(); index++) {
                char current = sql.charAt(index);
                char next = index + 1 < sql.length() ? sql.charAt(index + 1) : '\0';
                if (lineComment) { if (current == '\n' || current == '\r') lineComment = false; continue; }
                if (blockComment) { if (current == '*' && next == '/') { blockComment = false; index++; } continue; }
                if (single) {
                    if (current == '\'' && next == '\'') index++;
                    else if (current == '\'') single = false;
                    continue;
                }
                if (quotedIdentifier) {
                    if (current == '"' && next == '"') index++;
                    else if (current == '"') quotedIdentifier = false;
                    continue;
                }
                if (current == '-' && next == '-') { lineComment = true; index++; continue; }
                if (current == '/' && next == '*') { blockComment = true; index++; continue; }
                if (current == '\'') { single = true; continue; }
                if (current == '"') { quotedIdentifier = true; continue; }
                if (current == '(') depth++;
                else if (current == ')' && --depth == 0) return index;
            }
            return -1;
        }
    }

    /** Turns protocol frames into a forward-only, lazy ResultSet. */
    private static ResultSet resultSet(StatementHandler statement, MiniSqlProtocol.Query query, int maxRows) {
        ResultSetHandler handler = new ResultSetHandler(statement, query, maxRows);
        ResultSet proxy = proxy(ResultSet.class, handler); handler.proxy = proxy; return proxy;
    }

    private static final class ResultSetHandler extends BaseHandler {
        final StatementHandler statement;
        final MiniSqlProtocol.Query query;
        final int maxRows;
        ResultSet proxy;
        MiniSqlProtocol.Response frame;
        int frameRow = -1, rowNumber;
        boolean closed, wasNull;

        ResultSetHandler(StatementHandler statement, MiniSqlProtocol.Query query, int maxRows) {
            super("MiniSQLResultSet"); this.statement = statement; this.query = query; this.maxRows = maxRows;
        }

        @Override Object call(Object ignored, Method method, Object[] args) throws Throwable {
            String name = method.getName();
            if (name.equals("close")) { if (!closed) query.close(); closed = true; return null; }
            if (name.equals("isClosed")) return closed;
            ensureOpen();
            switch (name) {
                case "next": return next();
                case "getString": return value(args[0]);
                case "getObject":
                    if (args.length == 2 && args[1] instanceof Class<?>) return typedObject(args[0], (Class<?>) args[1]);
                    return value(args[0]);
                case "getInt": return parseInt(value(args[0]));
                case "getLong": return parseLong(value(args[0]));
                case "getShort": return (short) parseInt(value(args[0]));
                case "getByte": return (byte) parseInt(value(args[0]));
                case "getFloat": return (float) parseDouble(value(args[0]));
                case "getDouble": return parseDouble(value(args[0]));
                case "getBigDecimal": { String value = value(args[0]); return value == null ? null : new BigDecimal(value); }
                case "getBoolean": return parseBoolean(value(args[0]));
                case "getBytes": { String value = value(args[0]); return value == null ? null : decodeBytes(value); }
                case "getDate": { String value = value(args[0]); return value == null ? null : dateValue(value); }
                case "getTime": { String value = value(args[0]); return value == null ? null : timeValue(value); }
                case "getTimestamp": { String value = value(args[0]); return value == null ? null : timestampValue(value); }
                case "wasNull": return wasNull;
                case "findColumn": return findColumn((String) args[0]);
                case "getMetaData": return resultSetMetaData(columns());
                case "getStatement": return statement == null ? null : statement.proxy;
                case "getRow": return rowNumber;
                case "isBeforeFirst": return rowNumber == 0;
                case "isAfterLast": return false;
                case "isFirst": return rowNumber == 1;
                case "isLast": return false;
                case "getType": return ResultSet.TYPE_FORWARD_ONLY;
                case "getConcurrency": return ResultSet.CONCUR_READ_ONLY;
                case "getFetchDirection": return ResultSet.FETCH_FORWARD;
                case "setFetchDirection": if ((Integer) args[0] != ResultSet.FETCH_FORWARD) return unsupported(method); return null;
                case "getFetchSize": return statement == null ? 0 : statement.fetchSize;
                case "setFetchSize": return null;
                case "getHoldability": return ResultSet.CLOSE_CURSORS_AT_COMMIT;
                case "getWarnings": return null;
                case "clearWarnings": return null;
                default: return unsupported(method);
            }
        }

        private boolean next() throws SQLException {
            if (maxRows > 0 && rowNumber >= maxRows) { close(); return false; }
            while (frame == null || ++frameRow >= frame.rows.size()) {
                frame = query.nextFrame(); frameRow = -1;
                if (frame == null) { closed = true; return false; }
            }
            rowNumber++; return true;
        }

        private String value(Object selector) throws SQLException {
            if (frame == null || frameRow < 0 || frameRow >= frame.rows.size()) throw new SQLException("Cursor is not on a row", "24000");
            int index = selector instanceof Integer ? (Integer) selector : findColumn((String) selector);
            if (index < 1 || index > frame.columns.size()) throw new SQLException("Column index out of range: " + index, "07009");
            String value = frame.rows.get(frameRow)[index - 1];
            // Protocol v1 renders SQL NULL as the token NULL and has no separate null bitmap.
            wasNull = "NULL".equals(value);
            return wasNull ? null : value;
        }

        private int findColumn(String name) throws SQLException {
            List<String> columns = columns();
            for (int index = 0; index < columns.size(); index++) if (columns.get(index).equalsIgnoreCase(name)) return index + 1;
            throw new SQLException("Unknown column: " + name, "S0022");
        }
        private Object typedObject(Object selector, Class<?> requested) throws SQLException {
            String raw = value(selector);
            if (raw == null) return null;
            if (requested == String.class || requested == Object.class) return raw;
            if (requested == Integer.class || requested == int.class) return Integer.valueOf(raw);
            if (requested == Long.class || requested == long.class) return Long.valueOf(raw);
            if (requested == Short.class || requested == short.class) return Short.valueOf(raw);
            if (requested == Byte.class || requested == byte.class) return Byte.valueOf(raw);
            if (requested == Double.class || requested == double.class) return Double.valueOf(raw);
            if (requested == Float.class || requested == float.class) return Float.valueOf(raw);
            if (requested == BigDecimal.class) return new BigDecimal(raw);
            if (requested == Boolean.class || requested == boolean.class) return parseBoolean(raw);
            if (requested == byte[].class) return decodeBytes(raw);
            if (requested == Date.class || requested == LocalDate.class) {
                LocalDate date = dateValue(raw).toLocalDate(); return requested == Date.class ? Date.valueOf(date) : date;
            }
            if (requested == Time.class || requested == LocalTime.class) {
                LocalTime time = timeValue(raw).toLocalTime(); return requested == Time.class ? Time.valueOf(time) : time;
            }
            if (requested == Timestamp.class || requested == LocalDateTime.class) {
                LocalDateTime timestamp = timestampValue(raw).toLocalDateTime();
                return requested == Timestamp.class ? Timestamp.valueOf(timestamp) : timestamp;
            }
            throw new SQLFeatureNotSupportedException("Cannot convert a MiniSQL value to " + requested.getName(), "0A000");
        }
        private List<String> columns() { return frame == null ? query.first.columns : frame.columns; }
        private void close() throws SQLException { if (!closed) query.close(); closed = true; }
        private void ensureOpen() throws SQLException { if (closed) throw new SQLException("ResultSet is closed", "24000"); }
    }

    /** Supplies conservative VARCHAR metadata because protocol v1 does not transmit SQL types. */
    private static ResultSetMetaData resultSetMetaData(List<String> columns) {
        return proxy(ResultSetMetaData.class, new MetaDataHandler(columns));
    }

    private static final class MetaDataHandler extends BaseHandler {
        final List<String> columns;
        MetaDataHandler(List<String> columns) { super("MiniSQLResultSetMetaData"); this.columns = columns; }
        @Override Object call(Object ignored, Method method, Object[] args) throws Throwable {
            String name = method.getName();
            if (name.equals("getColumnCount")) return columns.size();
            int index = args.length > 0 && args[0] instanceof Integer ? (Integer) args[0] : 1;
            if (index < 1 || index > columns.size()) throw new SQLException("Column index out of range", "07009");
            switch (name) {
                case "getColumnLabel": case "getColumnName": return columns.get(index - 1);
                case "getColumnType": return Types.VARCHAR;
                case "getColumnTypeName": return "VARCHAR";
                case "getColumnClassName": return String.class.getName();
                case "getPrecision": case "getColumnDisplaySize": return Integer.MAX_VALUE;
                case "getScale": return 0;
                case "isNullable": return ResultSetMetaData.columnNullableUnknown;
                case "isAutoIncrement": case "isCurrency": case "isDefinitelyWritable": case "isWritable": return false;
                case "isCaseSensitive": case "isSearchable": case "isReadOnly": case "isSigned": return true;
                case "getSchemaName": return "public";
                case "getTableName": case "getCatalogName": return "";
                default: return unsupported(method);
            }
        }
    }

    private static DatabaseMetaData databaseMetaData(ConnectionHandler connection) {
        return proxy(DatabaseMetaData.class, new DatabaseMetaDataHandler(connection));
    }

    /** Exposes core driver capabilities and catalog tables used by IDEs and connection pools. */
    private static final class DatabaseMetaDataHandler extends BaseHandler {
        final ConnectionHandler connection;
        DatabaseMetaDataHandler(ConnectionHandler connection) { super("MiniSQLDatabaseMetaData"); this.connection = connection; }
        @Override Object call(Object ignored, Method method, Object[] args) throws Throwable {
            String name = method.getName();
            switch (name) {
                case "getConnection": return connection.proxy;
                case "getURL": return connection.url.originalUrl;
                case "getUserName": return connection.url.user == null ? "trusted-local" : connection.url.user;
                case "getDatabaseProductName": return "MiniSQL";
                case "getDatabaseProductVersion": return "1.0.0";
                case "getDriverName": return "MiniSQL JDBC Driver";
                case "getDriverVersion": return MiniSqlDriver.VERSION;
                case "getDriverMajorVersion": case "getDatabaseMajorVersion": case "getJDBCMajorVersion": return 1;
                case "getDriverMinorVersion": case "getDatabaseMinorVersion": return 0;
                case "getJDBCMinorVersion": return 3;
                case "getSQLStateType": return DatabaseMetaData.sqlStateSQL;
                case "getIdentifierQuoteString": return "\"";
                case "getCatalogSeparator": return ".";
                case "getCatalogTerm": return "database";
                case "getSchemaTerm": return "schema";
                case "getProcedureTerm": return "procedure";
                case "getSearchStringEscape": return "\\";
                case "getExtraNameCharacters": return "_";
                case "supportsTransactions": case "supportsBatchUpdates":
                case "supportsSchemasInDataManipulation": case "supportsSchemasInTableDefinitions":
                case "supportsANSI92EntryLevelSQL": case "supportsColumnAliasing": case "supportsTableCorrelationNames":
                case "supportsExpressionsInOrderBy": case "supportsOrderByUnrelated": case "supportsGroupBy":
                case "supportsOuterJoins": case "supportsFullOuterJoins": case "supportsLimitedOuterJoins":
                case "supportsUnion": case "supportsUnionAll": return true;
                case "supportsTransactionIsolationLevel":
                    int level = (Integer) args[0]; return level == Connection.TRANSACTION_READ_COMMITTED || level == Connection.TRANSACTION_SERIALIZABLE;
                case "getDefaultTransactionIsolation": return Connection.TRANSACTION_SERIALIZABLE;
                case "dataDefinitionCausesTransactionCommit": return true;
                case "dataDefinitionIgnoredInTransactions": return false;
                case "allProceduresAreCallable": case "allTablesAreSelectable": case "isReadOnly":
                case "nullsAreSortedHigh": case "nullsAreSortedLow": case "nullsAreSortedAtStart":
                case "usesLocalFiles": case "usesLocalFilePerTable": case "supportsMixedCaseIdentifiers":
                case "supportsStoredFunctionsUsingCallSyntax": case "generatedKeyAlwaysReturned":
                case "supportsSavepoints": return false;
                case "nullsAreSortedAtEnd": case "storesLowerCaseIdentifiers": return true;
                case "getMaxConnections": return 0;
                case "getMaxColumnsInTable": return 1024;
                case "getMaxStatementLength": return 16 * 1024 * 1024;
                case "getMaxTableNameLength": case "getMaxColumnNameLength": return 128;
                case "getTables": return tables((String) args[1], (String) args[2], (String[]) args[3]);
                case "getColumns": return columns((String) args[1], (String) args[2], (String) args[3]);
                case "getIndexInfo": return indexes((String) args[2]);
                case "getCatalogs": return localResult(Collections.singletonList("TABLE_CAT"), rows(row(connection.url.database)));
                case "getSchemas": return localResult(Arrays.asList("TABLE_SCHEM", "TABLE_CATALOG"), rows(row("public", connection.url.database)));
                case "getTableTypes": return localResult(Collections.singletonList("TABLE_TYPE"), rows(row("TABLE"), row("VIEW")));
                default:
                    if (method.getReturnType() == boolean.class) return false;
                    if (method.getReturnType() == int.class) return 0;
                    if (method.getReturnType() == long.class) return 0L;
                    if (method.getReturnType() == String.class) return "";
                    return unsupported(method);
            }
        }

        private ResultSet tables(String schemaPattern, String tablePattern, String[] types) throws SQLException {
            List<String[]> source = collect(connection.protocol.query("SHOW TABLES"));
            List<String[]> output = new ArrayList<>();
            boolean acceptsTables = types == null || Arrays.stream(types).anyMatch(value -> "TABLE".equalsIgnoreCase(value));
            if (acceptsTables) for (String[] row : source) {
                if (matches(schemaOf(row[0]), schemaPattern) && matches(objectOf(row[0]), tablePattern)) {
                    output.add(row(connection.url.database, schemaOf(row[0]), objectOf(row[0]), "TABLE", null,
                            null, null, null, null, null));
                }
            }
            return localResult(Arrays.asList("TABLE_CAT", "TABLE_SCHEM", "TABLE_NAME", "TABLE_TYPE", "REMARKS",
                    "TYPE_CAT", "TYPE_SCHEM", "TYPE_NAME", "SELF_REFERENCING_COL_NAME", "REF_GENERATION"), output);
        }

        private ResultSet columns(String schemaPattern, String tablePattern, String columnPattern) throws SQLException {
            List<String[]> output = new ArrayList<>();
            for (String[] table : collect(connection.protocol.query("SHOW TABLES"))) {
                if (!matches(schemaOf(table[0]), schemaPattern) || !matches(objectOf(table[0]), tablePattern)) continue;
                for (String[] column : collect(connection.protocol.query("DESCRIBE " + identifier(table[0])))) {
                    if (!matches(column[1], columnPattern)) continue;
                    int jdbcType = jdbcType(column[2]);
                    output.add(row(connection.url.database, schemaOf(table[0]), objectOf(table[0]), column[1],
                            Integer.toString(jdbcType), column[2], size(column[2]), null, scale(column[2]), "10",
                            truth(column[3]) ? Integer.toString(DatabaseMetaData.columnNullable) : Integer.toString(DatabaseMetaData.columnNoNulls),
                            null, column[4], null, null, null, Integer.toString(Integer.parseInt(column[0]) + 1),
                            truth(column[3]) ? "YES" : "NO", null, null, null, null,
                            truth(column[5]) ? "YES" : "NO", "NO"));
                }
            }
            return localResult(Arrays.asList("TABLE_CAT", "TABLE_SCHEM", "TABLE_NAME", "COLUMN_NAME", "DATA_TYPE",
                    "TYPE_NAME", "COLUMN_SIZE", "BUFFER_LENGTH", "DECIMAL_DIGITS", "NUM_PREC_RADIX", "NULLABLE",
                    "REMARKS", "COLUMN_DEF", "SQL_DATA_TYPE", "SQL_DATETIME_SUB", "CHAR_OCTET_LENGTH", "ORDINAL_POSITION",
                    "IS_NULLABLE", "SCOPE_CATALOG", "SCOPE_SCHEMA", "SCOPE_TABLE", "SOURCE_DATA_TYPE", "IS_AUTOINCREMENT",
                    "IS_GENERATEDCOLUMN"), output);
        }

        private ResultSet indexes(String table) throws SQLException {
            List<String[]> output = new ArrayList<>();
            if (table != null) {
                int ordinal = 0;
                for (String[] index : collect(connection.protocol.query("SHOW INDEXES FROM " + identifier(table)))) {
                    for (String column : index[3].split(",")) output.add(row(connection.url.database, schemaOf(table), objectOf(table),
                            truth(index[2]) ? "FALSE" : "TRUE", null, index[0], Integer.toString(DatabaseMetaData.tableIndexOther),
                            Integer.toString(++ordinal), column.trim(), "A", null, null, index.length > 5 ? index[5] : ""));
                }
            }
            return localResult(Arrays.asList("TABLE_CAT", "TABLE_SCHEM", "TABLE_NAME", "NON_UNIQUE", "INDEX_QUALIFIER",
                    "INDEX_NAME", "TYPE", "ORDINAL_POSITION", "COLUMN_NAME", "ASC_OR_DESC", "CARDINALITY", "PAGES",
                    "FILTER_CONDITION"), output);
        }
    }

    private static ResultSet localResult(List<String> columns, List<String[]> rows) {
        MiniSqlProtocol.Response response = new MiniSqlProtocol.Response(MiniSqlProtocol.STATUS_ROWS, "LOCAL", columns, rows,
                rows.size(), "", 0);
        return resultSet(null, local(columns, rows), 0);
    }

    private static MiniSqlProtocol.Query local(List<String> columns, List<String[]> rows) {
        return new LocalQuery(new MiniSqlProtocol.Response(MiniSqlProtocol.STATUS_ROWS, "LOCAL", columns, rows, rows.size(), "", 0));
    }

    /** Query adapter for metadata rows that do not use a socket. */
    private static final class LocalQuery extends MiniSqlProtocol.Query {
        LocalQuery(MiniSqlProtocol.Response response) { super(null, 0, response, false); }
        @Override MiniSqlProtocol.Response nextFrame() { if (firstPendingLocal) { firstPendingLocal = false; return first; } return null; }
        @Override public void close() { firstPendingLocal = false; }
        private boolean firstPendingLocal = true;
    }

    private static ParameterMetaData parameterMetaData(int count) {
        return proxy(ParameterMetaData.class, new BaseHandler("MiniSQLParameterMetaData") {
            @Override Object call(Object ignored, Method method, Object[] args) throws Throwable {
                switch (method.getName()) {
                    case "getParameterCount": return count;
                    case "getParameterType": return Types.VARCHAR;
                    case "getParameterTypeName": return "VARCHAR";
                    case "getParameterClassName": return String.class.getName();
                    case "getParameterMode": return ParameterMetaData.parameterModeIn;
                    case "isNullable": return ParameterMetaData.parameterNullableUnknown;
                    case "isSigned": return true;
                    case "getPrecision": case "getScale": return 0;
                    default: return unsupported(method);
                }
            }
        });
    }

    private static List<String[]> collect(MiniSqlProtocol.Query query) throws SQLException {
        List<String[]> rows = new ArrayList<>();
        try { MiniSqlProtocol.Response frame; while ((frame = query.nextFrame()) != null) rows.addAll(frame.rows); }
        finally { query.close(); }
        return rows;
    }

    /** Finds parameter markers while ignoring quoted text, identifiers, and SQL comments. */
    static List<Integer> parameterMarkers(String sql) {
        List<Integer> result = new ArrayList<>();
        boolean single = false, quoted = false, line = false, block = false;
        for (int index = 0; index < sql.length(); index++) {
            char value = sql.charAt(index), next = index + 1 < sql.length() ? sql.charAt(index + 1) : 0;
            if (line) { if (value == '\n' || value == '\r') line = false; continue; }
            if (block) { if (value == '*' && next == '/') { block = false; index++; } continue; }
            if (single) { if (value == '\'' && next == '\'') index++; else if (value == '\'') single = false; continue; }
            if (quoted) { if (value == '"' && next == '"') index++; else if (value == '"') quoted = false; continue; }
            if (value == '-' && next == '-') { line = true; index++; }
            else if (value == '/' && next == '*') { block = true; index++; }
            else if (value == '\'') single = true;
            else if (value == '"') quoted = true;
            else if (value == '?') result.add(index);
        }
        return result;
    }

    private static String objectLiteral(Object value) throws SQLException {
        if (value == null) return "NULL";
        if (value instanceof Boolean) return (Boolean) value ? "TRUE" : "FALSE";
        if (value instanceof Number) return value.toString();
        if (value instanceof byte[]) throw new SQLFeatureNotSupportedException(
                "Protocol v1 has no SQL binary literal; byte[] binding is unavailable", "0A000");
        if (value instanceof LocalDate || value instanceof LocalTime || value instanceof LocalDateTime
                || value instanceof java.util.Date || value instanceof CharSequence) return quote(value.toString());
        throw new SQLFeatureNotSupportedException("Cannot bind " + value.getClass().getName(), "0A000");
    }

    private static String quote(String text) { return '\'' + text.replace("'", "''") + '\''; }
    private static String identifier(String name) {
        StringBuilder output = new StringBuilder();
        String[] parts = name.split("\\.");
        for (int index = 0; index < parts.length; index++) {
            if (index > 0) output.append('.'); output.append('"').append(parts[index].replace("\"", "\"\"")).append('"');
        }
        return output.toString();
    }
    private static int parseInt(String value) { return value == null ? 0 : Integer.parseInt(value); }
    private static long parseLong(String value) { return value == null ? 0L : Long.parseLong(value); }
    private static double parseDouble(String value) { return value == null ? 0d : Double.parseDouble(value); }
    private static boolean parseBoolean(String value) { return value != null && ("TRUE".equalsIgnoreCase(value) || "1".equals(value)); }
    private static Date dateValue(String value) {
        if (value.indexOf('-') >= 0) return Date.valueOf(value);
        return Date.valueOf(LocalDate.ofEpochDay(Long.parseLong(value)));
    }
    private static Time timeValue(String value) {
        if (value.indexOf(':') >= 0) return Time.valueOf(value);
        long micros = Long.parseLong(value);
        return Time.valueOf(LocalTime.ofNanoOfDay(micros * 1_000L));
    }
    private static Timestamp timestampValue(String value) {
        if (value.indexOf('-') >= 0) return Timestamp.valueOf(value.replace('T', ' '));
        long micros = Long.parseLong(value);
        long days = Math.floorDiv(micros, 86_400_000_000L);
        long dayMicros = Math.floorMod(micros, 86_400_000_000L);
        return Timestamp.valueOf(LocalDateTime.of(LocalDate.ofEpochDay(days), LocalTime.ofNanoOfDay(dayMicros * 1_000L)));
    }
    private static byte[] decodeBytes(String value) {
        if (value.startsWith("0x") && (value.length() & 1) == 0) {
            byte[] output = new byte[(value.length() - 2) / 2];
            for (int index = 0; index < output.length; index++) output[index] = (byte) Integer.parseInt(value.substring(index * 2 + 2, index * 2 + 4), 16);
            return output;
        }
        return value.getBytes(StandardCharsets.UTF_8);
    }
    private static String schemaOf(String name) { int dot = name.indexOf('.'); return dot < 0 ? "public" : name.substring(0, dot); }
    private static String objectOf(String name) { int dot = name.indexOf('.'); return dot < 0 ? name : name.substring(dot + 1); }
    private static boolean truth(String value) { return "TRUE".equalsIgnoreCase(value); }
    private static boolean matches(String value, String pattern) {
        if (pattern == null || "%".equals(pattern)) return true;
        String regex = pattern.replace("\\", "\\\\").replace(".", "\\.").replace("%", ".*").replace("_", ".");
        return value.matches("(?i)" + regex);
    }
    private static int jdbcType(String type) {
        String name = type.toUpperCase(Locale.ROOT).split("\\(")[0];
        switch (name) {
            case "SMALLINT": return Types.SMALLINT; case "INTEGER": case "INT": return Types.INTEGER;
            case "BIGINT": return Types.BIGINT; case "DECIMAL": return Types.DECIMAL; case "REAL": return Types.REAL;
            case "DOUBLE": return Types.DOUBLE; case "BOOLEAN": return Types.BOOLEAN; case "DATE": return Types.DATE;
            case "TIME": return Types.TIME; case "TIMESTAMP": return Types.TIMESTAMP; case "BINARY": return Types.BINARY;
            case "VARBINARY": return Types.VARBINARY; case "BLOB": return Types.BLOB; case "TEXT": return Types.LONGVARCHAR;
            case "CHAR": return Types.CHAR; default: return Types.VARCHAR;
        }
    }
    private static String size(String type) {
        int open = type.indexOf('('), comma = type.indexOf(',');
        if (open < 0) return null;
        int close = comma > open ? comma : type.indexOf(')', open);
        return close < 0 ? null : type.substring(open + 1, close).trim();
    }
    private static String scale(String type) {
        int comma = type.indexOf(','), close = type.indexOf(')', comma);
        return comma < 0 || close < 0 ? null : type.substring(comma + 1, close).trim();
    }
    private static List<String[]> rows(String[]... rows) { return new ArrayList<>(Arrays.asList(rows)); }
    private static String[] row(String... values) { return values; }
}
