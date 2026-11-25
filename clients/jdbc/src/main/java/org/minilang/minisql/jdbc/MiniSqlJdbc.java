/*
 * Copyright 2026 MiniLangProject contributors
 * SPDX-License-Identifier: Apache-2.0
 * Licensed under the Apache License, Version 2.0; see LICENSE for details.
 */
package org.minilang.minisql.jdbc;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.SQLType;
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
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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
        String callVariablePrefix;
        List<MiniSqlProtocol.Condition> warnings = Collections.emptyList();
        int warningsCleared;
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
                case "prepareCall": return callableStatement(this, (String) args[0]);
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
                case "getWarnings": return warningChain(warnings, warningsCleared);
                case "clearWarnings": warningsCleared = warnings.size(); return null;
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

        /** One reusable namespace bounds helper-variable storage across callable statements. */
        String callVariables() {
            if (callVariablePrefix == null) callVariablePrefix = "@" + allocatePreparedStatementName() + "_call_";
            return callVariablePrefix;
        }

        void observeWarnings(List<MiniSqlProtocol.Condition> conditions) {
            warnings = conditions;
            warningsCleared = 0;
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

    private static final String CALL_IDENTIFIER = "(?:[A-Za-z_][A-Za-z0-9_]*|\"(?:[^\"]|\"\")+\"|`(?:[^`]|``)+`)";
    private static final Pattern CALL_PATTERN = Pattern.compile("(?is)CALL\\s+(" + CALL_IDENTIFIER
            + ")(?:\\s*\\.\\s*(" + CALL_IDENTIFIER + "))?\\s*(?:\\(\\s*(?:\\?(?:\\s*,\\s*\\?)*)?\\s*\\))?\\s*;?");

    /** Preserves quoted routine identifiers while validating JDBC procedure call escapes. */
    static String procedureCallSql(String source) throws SQLException {
        if (source == null) throw new SQLException("Procedure call must be SQL text", "42000");
        String sql = source.trim();
        if (sql.startsWith("{") && sql.endsWith("}")) sql = sql.substring(1, sql.length() - 1).trim();
        if (!CALL_PATTERN.matcher(sql).matches()) {
            throw new SQLFeatureNotSupportedException("Use {call schema.procedure(?, ...)} or a zero-argument CALL", "0A000");
        }
        return sql;
    }

    /** Creates an IN/OUT CallableStatement with optional lazy metadata-based name binding. */
    private static CallableStatement callableStatement(ConnectionHandler connection, String source) throws SQLException {
        StatementHandler handler = new StatementHandler(connection, procedureCallSql(source), true);
        CallableStatement proxy = proxy(CallableStatement.class, handler);
        handler.proxy = proxy;
        return proxy;
    }

    /** Implements statements, server-backed prepared statements, and bounded insert batching. */
    private static final class StatementHandler extends BaseHandler {
        private static final int MAX_COALESCED_INSERT_ROWS = 256;
        private static final int MAX_COALESCED_INSERT_BYTES = 768 * 1024;
        final ConnectionHandler connection;
        final String template;
        final boolean callable;
        final List<Integer> markers;
        final Map<Integer, String> parameters = new LinkedHashMap<>();
        final List<String> batch = new ArrayList<>();
        final List<Map<Integer, String>> callBatch = new ArrayList<>();
        final List<ResultSet> keptResults = new ArrayList<>();
        Statement proxy;
        ResultSet currentResult;
        MiniSqlProtocol.Query currentQuery;
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
        final Map<Integer, Integer> outputTypes = new LinkedHashMap<>();
        final Map<Integer, String> outputValues = new LinkedHashMap<>();
        final Map<Integer, Integer> outputNativeTypes = new LinkedHashMap<>();
        List<RoutineParameter> routineParameters;
        List<MiniSqlProtocol.Condition> warnings = Collections.emptyList();
        int warningsCleared;
        boolean outputWasNull;
        String callVariablePrefix;

        StatementHandler(ConnectionHandler connection, String template) {
            this(connection, template, false);
        }

        StatementHandler(ConnectionHandler connection, String template, boolean callable) {
            super(callable ? "MiniSQLCallableStatement" : template == null ? "MiniSQLStatement" : "MiniSQLPreparedStatement");
            this.connection = connection; this.template = template; this.callable = callable;
            this.markers = template == null ? Collections.emptyList() : parameterMarkers(template);
        }

        @Override Object call(Object ignored, Method method, Object[] args) throws Throwable {
            String name = method.getName();
            if (name.equals("close")) { closeStatement(); return null; }
            if (name.equals("isClosed")) return closed;
            ensureOpen();
            if (callable && name.equals("registerOutParameter")) {
                int index = parameterIndex(args[0]);
                if (index < 1 || index > markers.size()) throw new SQLException("Output parameter index out of range", "07009");
                Object type = args[1];
                int number = type instanceof SQLType ? ((SQLType) type).getVendorTypeNumber() : (Integer) type;
                outputTypes.put(index, number);
                return null;
            }
            if (callable && name.equals("wasNull")) return outputWasNull;
            if (callable && outputGetter(name)) {
                if (args.length == 0) return unsupported(method);
                return outputValue(name, parameterIndex(args[0]), args);
            }
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
                case "getMoreResults":
                    return moreResults(args.length == 0 ? Statement.CLOSE_CURRENT_RESULT : (Integer) args[0]);
                case "getConnection": return connection.proxy;
                case "cancel": if (executing || currentResult != null) connection.protocol.cancelCurrentSession(); return null;
                case "getWarnings": return warningChain(warnings, warningsCleared);
                case "clearWarnings": warningsCleared = warnings.size(); return null;
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
                    if (callable) {
                        requireInputOnlyBatch(); requireAllParameters();
                        callBatch.add(new LinkedHashMap<>(parameters)); return null;
                    }
                    batch.add(args.length == 0 ? boundSql() : (String) args[0]); return null;
                case "clearBatch": batch.clear(); callBatch.clear(); return null;
                case "executeBatch": return callable ? executeCallBatch(false) : executeBatch(false);
                case "executeLargeBatch": return callable ? executeCallBatch(true) : executeBatch(true);
                case "clearParameters": parameters.clear(); return null;
                case "getParameterMetaData": return callable ? routineParameterMetaData(loadRoutineParameters()) : parameterMetaData(markers.size());
                case "getMetaData": return null;
                default:
                    if (template != null && name.startsWith("set")) {
                        if (args.length == 0) return unsupported(method);
                        if (callable) { args = args.clone(); args[0] = parameterIndex(args[0]); }
                        else if (!(args[0] instanceof Integer)) return unsupported(method);
                        bind(name, args); return null;
                    }
                    return unsupported(method);
            }
        }

        private String sqlArgument(Object[] args) throws SQLException {
            if (template == null) return (String) args[0];
            if (args.length != 0) throw new SQLException(
                    "SQL text cannot be supplied to an already prepared statement", "HY000");
            if (callable) return template;
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
            warnings = Collections.emptyList(); warningsCleared = 0;
            if (callable) return executeCall();
            MiniSqlProtocol.Query query;
            executing = true;
            try { query = connection.protocol.query(sql); }
            finally { executing = false; }
            currentQuery = query;
            warnings = query.warnings;
            connection.observeWarnings(warnings);
            return selectResult();
        }

        /** Publishes one result while retaining later CALL results on the owning stream. */
        private boolean selectResult() {
            MiniSqlProtocol.Response first = currentQuery.first;
            if (first.status == MiniSqlProtocol.STATUS_ROWS) {
                currentResult = resultSet(this, currentQuery, maxRows); updateCount = -1; return true;
            }
            currentResult = null;
            updateCount = first.affectedRows;
            return false;
        }

        /** Implements JDBC's getMoreResults boundary without merging equal-column SELECTs. */
        private boolean moreResults(int disposition) throws SQLException {
            if (disposition != Statement.KEEP_CURRENT_RESULT && disposition != Statement.CLOSE_CURRENT_RESULT
                    && disposition != Statement.CLOSE_ALL_RESULTS) throw new SQLException("Invalid result disposition", "HY092");
            if (disposition == Statement.CLOSE_ALL_RESULTS) closeKeptResults();
            if (currentResult != null) {
                if (disposition == Statement.KEEP_CURRENT_RESULT && !currentResult.isClosed()) {
                    ((ResultSetHandler) Proxy.getInvocationHandler(currentResult)).detach();
                    keptResults.add(currentResult);
                } else currentResult.close();
                currentResult = null;
            }
            if (currentQuery == null || !currentQuery.nextResult()) {
                if (currentQuery != null) currentQuery.close();
                currentQuery = null; updateCount = -1; return false;
            }
            return selectResult();
        }

        /** Binds variables and spools result frames; v2 carries outputs without another SQL query. */
        private boolean executeCall() throws SQLException {
            outputValues.clear();
            outputNativeTypes.clear();
            if (callVariablePrefix == null) callVariablePrefix = connection.callVariables();
            List<String> names = new ArrayList<>();
            StringBuilder initialization = new StringBuilder("SET ");
            StringBuilder cleanup = new StringBuilder("SET ");
            for (int index = 1; index <= markers.size(); index++) {
                if (!parameters.containsKey(index) && !outputTypes.containsKey(index)) {
                    throw new SQLException("Unbound procedure input parameter " + index, "07001");
                }
                String name = callVariablePrefix + index;
                names.add(name);
                if (index > 1) { initialization.append(','); cleanup.append(','); }
                initialization.append(name).append(" = ").append(parameters.getOrDefault(index, "NULL"));
                cleanup.append(name).append(" = NULL");
            }
            StringBuilder call = new StringBuilder(template.length() + names.size() * 40);
            int offset = 0;
            for (int index = 0; index < markers.size(); index++) {
                int marker = markers.get(index);
                call.append(template, offset, marker).append(names.get(index)); offset = marker + 1;
            }
            call.append(template, offset, template.length());
            if (!names.isEmpty()) connection.executeCommand(initialization.toString());
            SQLException failure = null;
            executing = true;
            try (MiniSqlProtocol.ResultSpool spool = new MiniSqlProtocol.ResultSpool()) {
                int frameCount = 0;
                boolean deferredError = false;
                boolean extendedOutputs = false;
                try (MiniSqlProtocol.Query query = connection.protocol.query(call.toString())) {
                    warnings = query.warnings;
                    connection.observeWarnings(warnings);
                    try {
                        do {
                            MiniSqlProtocol.Response frame;
                            while ((frame = query.nextFrame()) != null) {
                                spool.append(frame); frameCount++;
                                if (frame.extended && "CALL".equalsIgnoreCase(frame.command)) extendedOutputs = true;
                                for (MiniSqlProtocol.OutputParameter value : frame.outputs) {
                                    if (outputTypes.containsKey(value.ordinal)) {
                                        outputValues.put(value.ordinal, value.value);
                                        outputNativeTypes.put(value.ordinal, value.typeKind);
                                    }
                                }
                            }
                        } while (query.nextResult());
                    } catch (SQLException caught) {
                        if (frameCount == 0) throw caught;
                        spool.appendError(caught); deferredError = true;
                        outputValues.clear(); outputNativeTypes.clear();
                    }
                }
                if (!deferredError && !extendedOutputs && !outputTypes.isEmpty()) {
                    StringBuilder select = new StringBuilder("SELECT ");
                    int count = 0;
                    for (int index : outputTypes.keySet()) {
                        if (count++ > 0) select.append(',');
                        select.append(names.get(index - 1));
                    }
                    try (MiniSqlProtocol.Query query = connection.protocol.query(select.toString())) {
                        if (query.first.rows.size() != 1) throw new SQLException("Invalid procedure output row count", "HY000");
                        String[] row = query.first.rows.get(0);
                        int column = 0;
                        for (int index : outputTypes.keySet()) {
                            String value = row[column++];
                            outputValues.put(index, !query.first.extended && "NULL".equals(value) ? null : value);
                        }
                    }
                }
                if (frameCount == 0) throw new SQLException("Procedure returned an empty response stream", "HY000");
                if (!deferredError && extendedOutputs && !outputValues.keySet().containsAll(outputTypes.keySet())) {
                    throw new SQLException("Registered output parameter was not returned by the procedure", "07009");
                }
                currentQuery = spool.finish();
                return selectResult();
            } catch (SQLException caught) {
                failure = caught;
                throw caught;
            } finally {
                executing = false;
                if (!names.isEmpty() && !connection.protocol.extendedResults()) {
                    try { connection.executeCommand(cleanup.toString()); }
                    catch (SQLException cleanupFailure) {
                        if (failure == null) throw cleanupFailure;
                        failure.addSuppressed(cleanupFailure);
                    }
                }
            }
        }

        /** Recognizes only JDBC output getters, leaving statement metadata methods unchanged. */
        private static boolean outputGetter(String name) {
            return Arrays.asList("getString", "getNString", "getObject", "getInt", "getLong", "getShort", "getByte",
                    "getFloat", "getDouble", "getBigDecimal", "getBoolean", "getBytes", "getDate", "getTime", "getTimestamp").contains(name);
        }

        /** Converts one registered output using the same text protocol rules as ResultSet getters. */
        private Object outputValue(String getter, int index, Object[] args) throws SQLException {
            if (!outputTypes.containsKey(index)) throw new SQLException("Parameter is not registered for output", "07009");
            if (!outputValues.containsKey(index)) throw new SQLException("Procedure has not completed", "HY010");
            String value = outputValues.get(index);
            outputWasNull = value == null;
            if (outputWasNull) value = null;
            switch (getter) {
                case "getString": case "getNString": return value;
                case "getInt": return parseInt(value);
                case "getLong": return parseLong(value);
                case "getShort": return (short) parseInt(value);
                case "getByte": return (byte) parseInt(value);
                case "getFloat": return (float) parseDouble(value);
                case "getDouble": return parseDouble(value);
                case "getBoolean": return parseBoolean(value);
                case "getBigDecimal": return value == null ? null : new BigDecimal(value);
                case "getBytes": return value == null ? null : decodeBytes(value);
                case "getDate": return value == null ? null : dateValue(value);
                case "getTime": return value == null ? null : timeValue(value);
                case "getTimestamp": return value == null ? null : timestampValue(value);
                case "getObject":
                    if (args.length < 2) return convertObject(value, outputNativeTypes.containsKey(index)
                            ? nativeJdbcType(outputNativeTypes.get(index)) : outputTypes.get(index));
                    if (!(args[1] instanceof Class<?>)) throw new SQLFeatureNotSupportedException("Output type maps are unavailable", "0A000");
                    Class<?> type = (Class<?>) args[1];
                    if (value == null || type == String.class || type == Object.class) return value;
                    if (type == Integer.class || type == int.class) return parseInt(value);
                    if (type == Long.class || type == long.class) return parseLong(value);
                    if (type == Double.class || type == double.class) return parseDouble(value);
                    if (type == Boolean.class || type == boolean.class) return parseBoolean(value);
                    if (type == BigDecimal.class) return new BigDecimal(value);
                    throw new SQLFeatureNotSupportedException("Unsupported procedure output class " + type.getName(), "0A000");
                default: throw new SQLFeatureNotSupportedException("Unsupported output getter " + getter, "0A000");
            }
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

        /** JDBC batches have update counts, so output parameters/result sets are excluded. */
        private void requireInputOnlyBatch() throws SQLException {
            if (!outputTypes.isEmpty()) throw new SQLFeatureNotSupportedException("Callable batches require IN-only parameters", "0A000");
        }

        private Object executeCallBatch(boolean large) throws SQLException {
            requireInputOnlyBatch();
            long[] counts = new long[callBatch.size()];
            Map<Integer, String> saved = new LinkedHashMap<>(parameters);
            int completed = 0;
            try {
                for (Map<Integer, String> entry : callBatch) {
                    parameters.clear(); parameters.putAll(entry);
                    execute(template);
                    if (currentResult != null) throw new SQLException("Callable batch entry produced a result set", "HY000");
                    long count = updateCount < 0 ? Statement.SUCCESS_NO_INFO : updateCount;
                    closeCurrent(); counts[completed++] = count;
                }
            } catch (SQLException caught) {
                throw new BatchUpdateException(caught.getMessage(), caught.getSQLState(), caught.getErrorCode(),
                        Arrays.copyOf(counts, completed), caught);
            } finally {
                callBatch.clear(); parameters.clear(); parameters.putAll(saved);
            }
            if (large) return counts;
            int[] ordinary = new int[counts.length];
            for (int index = 0; index < counts.length; index++) ordinary[index] = (int) counts[index];
            return ordinary;
        }

        private int parameterIndex(Object selector) throws SQLException {
            if (selector instanceof Integer) return (Integer) selector;
            if (!(selector instanceof String)) throw new SQLException("Invalid parameter selector", "07009");
            String requested = (String) selector;
            for (RoutineParameter parameter : loadRoutineParameters()) {
                if (parameter.name.equalsIgnoreCase(requested)) return parameter.ordinal;
            }
            throw new SQLException("Unknown procedure parameter: " + requested, "07009");
        }

        private List<RoutineParameter> loadRoutineParameters() throws SQLException {
            if (routineParameters == null) {
                Matcher call = CALL_PATTERN.matcher(template);
                if (!call.matches()) throw new SQLException("Invalid procedure call", "42000");
                String schema = call.group(2) == null ? "public" : unquoteIdentifier(call.group(1));
                String name = unquoteIdentifier(call.group(2) == null ? call.group(1) : call.group(2));
                routineParameters = routineParameters(connection, schema, name);
                if (routineParameters.size() != markers.size()) {
                    routineParameters = null;
                    throw new SQLException("Procedure parameter metadata does not match the call arguments", "07001");
                }
            }
            return routineParameters;
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
            closeKeptResults();
            if (currentResult != null) { currentResult.close(); currentResult = null; }
            if (currentQuery != null) { currentQuery.close(); currentQuery = null; }
            updateCount = -1;
        }

        private void closeKeptResults() throws SQLException {
            SQLException failure = null;
            for (ResultSet result : keptResults) {
                try { result.close(); } catch (SQLException caught) { if (failure == null) failure = caught; else failure.addSuppressed(caught); }
            }
            keptResults.clear();
            if (failure != null) throw failure;
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
        MiniSqlProtocol.Query query;
        final int maxRows;
        ResultSet proxy;
        MiniSqlProtocol.Response frame;
        int frameRow = -1, rowNumber;
        boolean closed, wasNull, exhausted, ownsQuery;
        int warningsCleared;

        ResultSetHandler(StatementHandler statement, MiniSqlProtocol.Query query, int maxRows) {
            super("MiniSQLResultSet"); this.statement = statement; this.query = query; this.maxRows = maxRows;
        }

        @Override Object call(Object ignored, Method method, Object[] args) throws Throwable {
            String name = method.getName();
            if (name.equals("close")) { close(); return null; }
            if (name.equals("isClosed")) return closed;
            ensureOpen();
            switch (name) {
                case "next": return next();
                case "getString": return value(args[0]);
                case "getObject":
                    if (args.length == 2 && args[1] instanceof Class<?>) return typedObject(args[0], (Class<?>) args[1]);
                    String raw = value(args[0]);
                    int column = args[0] instanceof Integer ? (Integer) args[0] : findColumn((String) args[0]);
                    return convertObject(raw, nativeJdbcType(columnTypes(), column));
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
                case "getMetaData": return resultSetMetaData(columns(), columnTypes());
                case "getStatement": return statement == null ? null : statement.proxy;
                case "getRow": return exhausted ? 0 : rowNumber;
                case "isBeforeFirst": return rowNumber == 0 && !exhausted;
                case "isAfterLast": return exhausted && rowNumber > 0;
                case "isFirst": return rowNumber == 1 && !exhausted;
                case "isLast": return false;
                case "getType": return ResultSet.TYPE_FORWARD_ONLY;
                case "getConcurrency": return ResultSet.CONCUR_READ_ONLY;
                case "getFetchDirection": return ResultSet.FETCH_FORWARD;
                case "setFetchDirection": if ((Integer) args[0] != ResultSet.FETCH_FORWARD) return unsupported(method); return null;
                case "getFetchSize": return statement == null ? 0 : statement.fetchSize;
                case "setFetchSize": return null;
                case "getHoldability": return ResultSet.CLOSE_CURSORS_AT_COMMIT;
                case "getWarnings": return warningChain(query.warnings, warningsCleared);
                case "clearWarnings": warningsCleared = query.warnings.size(); return null;
                default: return unsupported(method);
            }
        }

        private boolean next() throws SQLException {
            if (exhausted) return false;
            if (maxRows > 0 && rowNumber >= maxRows) { query.finishResult(); exhausted = true; return false; }
            while (frame == null || ++frameRow >= frame.rows.size()) {
                frame = query.nextFrame(); frameRow = -1;
                if (frame == null) { exhausted = true; return false; }
            }
            rowNumber++; return true;
        }

        private String value(Object selector) throws SQLException {
            if (exhausted || frame == null || frameRow < 0 || frameRow >= frame.rows.size()) throw new SQLException("Cursor is not on a row", "24000");
            int index = selector instanceof Integer ? (Integer) selector : findColumn((String) selector);
            if (index < 1 || index > frame.columns.size()) throw new SQLException("Column index out of range: " + index, "07009");
            String value = frame.rows.get(frameRow)[index - 1];
            wasNull = value == null || (!frame.extended && "NULL".equals(value));
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
        private List<Integer> columnTypes() { return frame == null ? query.first.columnTypes : frame.columnTypes; }

        /** Detaches unread continuation frames, keeping the current row and remaining rows usable. */
        private void detach() throws SQLException {
            if (closed || ownsQuery) return;
            try (MiniSqlProtocol.ResultSpool spool = new MiniSqlProtocol.ResultSpool()) {
                if (frame != null || exhausted) spool.append(query.first.withRows(Collections.emptyList()));
                MiniSqlProtocol.Response remaining;
                while ((remaining = query.nextFrame()) != null) spool.append(remaining);
                query = spool.finish(); ownsQuery = true;
            }
        }

        private void close() throws SQLException {
            if (closed) return;
            try { if (ownsQuery) query.close(); else query.finishResult(); }
            finally { closed = true; }
        }
        private void ensureOpen() throws SQLException { if (closed) throw new SQLException("ResultSet is closed", "24000"); }
    }

    /** Uses transmitted native type codes, preserving VARCHAR fallback for legacy peers. */
    private static ResultSetMetaData resultSetMetaData(List<String> columns, List<Integer> types) {
        return proxy(ResultSetMetaData.class, new MetaDataHandler(columns, types));
    }

    private static final class MetaDataHandler extends BaseHandler {
        final List<String> columns;
        final List<Integer> types;
        MetaDataHandler(List<String> columns, List<Integer> types) { super("MiniSQLResultSetMetaData"); this.columns = columns; this.types = types; }
        @Override Object call(Object ignored, Method method, Object[] args) throws Throwable {
            String name = method.getName();
            if (name.equals("getColumnCount")) return columns.size();
            int index = args.length > 0 && args[0] instanceof Integer ? (Integer) args[0] : 1;
            if (index < 1 || index > columns.size()) throw new SQLException("Column index out of range", "07009");
            int type = nativeJdbcType(types, index);
            switch (name) {
                case "getColumnLabel": case "getColumnName": return columns.get(index - 1);
                case "getColumnType": return type;
                case "getColumnTypeName": return jdbcTypeName(type);
                case "getColumnClassName": return jdbcClass(type).getName();
                case "getPrecision": return typePrecision(type);
                case "getColumnDisplaySize": return typePrecision(type);
                case "getScale": return 0;
                case "isNullable": return ResultSetMetaData.columnNullableUnknown;
                case "isAutoIncrement": case "isCurrency": case "isDefinitelyWritable": case "isWritable": return false;
                case "isSigned": return numericType(type);
                case "isCaseSensitive": return type == Types.CHAR || type == Types.VARCHAR || type == Types.LONGVARCHAR;
                case "isSearchable": case "isReadOnly": return true;
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
                case "getDatabaseProductVersion": return "1.1.1";
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
                case "supportsUnion": case "supportsUnionAll": case "supportsStoredProcedures":
                case "supportsMultipleResultSets": case "supportsMultipleOpenResults": case "supportsNamedParameters":
                case "supportsMixedCaseQuotedIdentifiers": return true;
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
                case "getProcedures": return procedures((String) args[0], (String) args[1], (String) args[2]);
                case "getProcedureColumns": return procedureColumns((String) args[0], (String) args[1], (String) args[2], (String) args[3]);
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

        /** Converts visible routine catalog rows into the nine JDBC procedure columns. */
        private ResultSet procedures(String catalog, String schemaPattern, String procedurePattern) throws SQLException {
            List<String[]> output = new ArrayList<>();
            if (catalog == null || connection.url.database.equals(catalog)) {
                for (String[] routine : collect(connection.protocol.query("SELECT ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_COMMENT, SPECIFIC_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' ORDER BY ROUTINE_SCHEMA, ROUTINE_NAME"))) {
                    if (!matches(routine[0], schemaPattern) || !matches(routine[1], procedurePattern)) continue;
                    output.add(row(connection.url.database, routine[0], routine[1], null, null, null,
                            routine[2], Integer.toString(DatabaseMetaData.procedureResultUnknown), routine[3]));
                }
            }
            return localResult(Arrays.asList("PROCEDURE_CAT", "PROCEDURE_SCHEM", "PROCEDURE_NAME", "reserved1", "reserved2", "reserved3",
                    "REMARKS", "PROCEDURE_TYPE", "SPECIFIC_NAME"), output);
        }

        /** Reports ordered IN/OUT/INOUT parameters with their actual type dimensions. */
        private ResultSet procedureColumns(String catalog, String schemaPattern, String procedurePattern, String columnPattern) throws SQLException {
            List<String[]> output = new ArrayList<>();
            if (catalog == null || connection.url.database.equals(catalog)) {
                for (RoutineParameter parameter : routineParameters(connection, null, null)) {
                    if (!matches(parameter.schema, schemaPattern) || !matches(parameter.procedure, procedurePattern)
                            || !matches(parameter.name, columnPattern)) continue;
                    output.add(row(connection.url.database, parameter.schema, parameter.procedure, parameter.name,
                            Integer.toString(parameter.jdbcMode()), Integer.toString(parameter.type), parameter.typeName,
                            Integer.toString(parameter.precision), parameter.octetLength, parameter.scaleText,
                            numericType(parameter.type) ? "10" : null, Integer.toString(DatabaseMetaData.procedureNullable),
                            null, null, null, null, parameter.octetLength, Integer.toString(parameter.ordinal), "YES", parameter.procedure));
                }
            }
            return localResult(Arrays.asList("PROCEDURE_CAT", "PROCEDURE_SCHEM", "PROCEDURE_NAME", "COLUMN_NAME", "COLUMN_TYPE", "DATA_TYPE",
                    "TYPE_NAME", "PRECISION", "LENGTH", "SCALE", "RADIX", "NULLABLE", "REMARKS", "COLUMN_DEF", "SQL_DATA_TYPE",
                    "SQL_DATETIME_SUB", "CHAR_OCTET_LENGTH", "ORDINAL_POSITION", "IS_NULLABLE", "SPECIFIC_NAME"), output);
        }
    }

    /** Stable metadata projection shared by named bindings and JDBC catalog discovery. */
    private static List<RoutineParameter> routineParameters(ConnectionHandler connection, String schema, String name) throws SQLException {
        String sql = "SELECT SPECIFIC_SCHEMA, SPECIFIC_NAME, ORDINAL_POSITION, PARAMETER_MODE, PARAMETER_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, CHARACTER_OCTET_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE, DATETIME_PRECISION, DTD_IDENTIFIER FROM INFORMATION_SCHEMA.PARAMETERS WHERE ROUTINE_TYPE = 'PROCEDURE'";
        if (schema != null) sql += " AND SPECIFIC_SCHEMA = " + quote(schema);
        if (name != null) sql += " AND SPECIFIC_NAME = " + quote(name);
        sql += " ORDER BY SPECIFIC_SCHEMA, SPECIFIC_NAME, ORDINAL_POSITION";
        List<RoutineParameter> parameters = new ArrayList<>();
        for (String[] fields : collect(connection.protocol.query(sql))) parameters.add(new RoutineParameter(fields));
        return parameters;
    }

    private static final class RoutineParameter {
        final String schema, procedure, name, mode, typeName, octetLength, scaleText;
        final int ordinal, type, precision, scale;
        RoutineParameter(String[] fields) throws SQLException {
            if (fields.length != 12) throw new SQLException("Invalid routine parameter metadata projection", "HY000");
            schema = fields[0]; procedure = fields[1]; ordinal = metadataNumber(fields[2], 0);
            mode = fields[3]; name = fields[4]; typeName = fields[5].toUpperCase(Locale.ROOT); type = jdbcType(typeName);
            octetLength = metadataNull(fields[7]);
            scaleText = metadataNull(fields[9]) == null ? metadataNull(fields[10]) : fields[9];
            scale = metadataNumber(scaleText, 0);
            if (metadataNull(fields[6]) != null) precision = metadataNumber(fields[6], 0);
            else if (metadataNull(fields[8]) != null) precision = metadataNumber(fields[8], 0);
            else if (type == Types.DATE) precision = 10;
            else if (type == Types.TIME || type == Types.TIMESTAMP) precision = (type == Types.TIME ? 8 : 19) + (scale > 0 ? scale + 1 : 0);
            else precision = typePrecision(type);
            if (ordinal < 1 || name == null) throw new SQLException("Invalid procedure parameter ordinal or name", "HY000");
        }
        int mode() {
            if ("OUT".equalsIgnoreCase(mode)) return ParameterMetaData.parameterModeOut;
            if ("INOUT".equalsIgnoreCase(mode)) return ParameterMetaData.parameterModeInOut;
            return ParameterMetaData.parameterModeIn;
        }
        int jdbcMode() {
            if ("OUT".equalsIgnoreCase(mode)) return DatabaseMetaData.procedureColumnOut;
            if ("INOUT".equalsIgnoreCase(mode)) return DatabaseMetaData.procedureColumnInOut;
            return DatabaseMetaData.procedureColumnIn;
        }
    }

    private static ParameterMetaData routineParameterMetaData(List<RoutineParameter> parameters) {
        return proxy(ParameterMetaData.class, new BaseHandler("MiniSQLRoutineParameterMetaData") {
            @Override Object call(Object ignored, Method method, Object[] args) throws Throwable {
                String name = method.getName();
                if (name.equals("getParameterCount")) return parameters.size();
                int index = (Integer) args[0];
                if (index < 1 || index > parameters.size()) throw new SQLException("Parameter index out of range", "07009");
                RoutineParameter parameter = parameters.get(index - 1);
                switch (name) {
                    case "getParameterType": return parameter.type;
                    case "getParameterTypeName": return parameter.typeName;
                    case "getParameterClassName": return jdbcClass(parameter.type).getName();
                    case "getParameterMode": return parameter.mode();
                    case "isNullable": return ParameterMetaData.parameterNullable;
                    case "isSigned": return numericType(parameter.type);
                    case "getPrecision": return parameter.precision;
                    case "getScale": return parameter.scale;
                    default: return unsupported(method);
                }
            }
        });
    }

    private static ResultSet localResult(List<String> columns, List<String[]> rows) {
        return resultSet(null, local(columns, rows), 0);
    }

    private static MiniSqlProtocol.Query local(List<String> columns, List<String[]> rows) {
        List<Integer> types = new ArrayList<>();
        List<String> numericColumns = Arrays.asList("PROCEDURE_TYPE", "COLUMN_TYPE", "DATA_TYPE", "PRECISION", "LENGTH", "SCALE", "RADIX",
                "NULLABLE", "SQL_DATA_TYPE", "SQL_DATETIME_SUB", "CHAR_OCTET_LENGTH", "ORDINAL_POSITION", "COLUMN_SIZE", "BUFFER_LENGTH",
                "DECIMAL_DIGITS", "NUM_PREC_RADIX", "SOURCE_DATA_TYPE", "TYPE", "CARDINALITY", "PAGES");
        for (String column : columns) types.add(numericColumns.contains(column) ? 3 : 9);
        return new LocalQuery(new MiniSqlProtocol.Response(MiniSqlProtocol.STATUS_ROWS, "LOCAL", columns, rows, rows.size(), "", 0,
                false, "00000", Collections.emptyList(), types, Collections.emptyList(), true));
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
                if (!method.getName().equals("getParameterCount") && args.length > 0 && args[0] instanceof Integer
                        && ((Integer) args[0] < 1 || (Integer) args[0] > count)) throw new SQLException("Parameter index out of range", "07009");
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
        char identifierQuote = '"';
        for (int index = 0; index < sql.length(); index++) {
            char value = sql.charAt(index), next = index + 1 < sql.length() ? sql.charAt(index + 1) : 0;
            if (line) { if (value == '\n' || value == '\r') line = false; continue; }
            if (block) { if (value == '*' && next == '/') { block = false; index++; } continue; }
            if (single) { if (value == '\'' && next == '\'') index++; else if (value == '\'') single = false; continue; }
            if (quoted) { if (value == identifierQuote && next == identifierQuote) index++; else if (value == identifierQuote) quoted = false; continue; }
            if (value == '-' && next == '-') { line = true; index++; }
            else if (value == '/' && next == '*') { block = true; index++; }
            else if (value == '\'') single = true;
            else if (value == '"' || value == '`') { quoted = true; identifierQuote = value; }
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
    private static String unquoteIdentifier(String text) {
        char quote = text.charAt(0);
        if (quote == '"' || quote == '`') return text.substring(1, text.length() - 1).replace("" + quote + quote, "" + quote);
        return text.toLowerCase(Locale.ROOT);
    }

    /** JDBC warnings remain independent linked objects, even when their source list grows. */
    private static SQLWarning warningChain(List<MiniSqlProtocol.Condition> conditions, int first) {
        SQLWarning head = null, tail = null;
        for (int index = first; index < conditions.size(); index++) {
            MiniSqlProtocol.Condition condition = conditions.get(index);
            SQLWarning warning = new SQLWarning(condition.message, condition.sqlState, condition.code);
            if (head == null) head = warning; else tail.setNextWarning(warning);
            tail = warning;
        }
        return head;
    }

    private static String metadataNull(String value) { return value == null || value.equals("NULL") ? null : value; }
    private static int metadataNumber(String value, int fallback) throws SQLException {
        if (metadataNull(value) == null) return fallback;
        try { return (int) Math.min(Integer.MAX_VALUE, Long.parseLong(value)); }
        catch (NumberFormatException failure) { throw new SQLException("Invalid numeric catalog metadata: " + value, "HY000", failure); }
    }

    private static int nativeJdbcType(List<Integer> types, int column) {
        return column > 0 && column <= types.size() ? nativeJdbcType(types.get(column - 1)) : Types.VARCHAR;
    }

    /** Type codes mirror minisql.sql.types.SqlTypeKind and the negotiated protocol extension. */
    private static int nativeJdbcType(int kind) {
        int[] types = {Types.NULL, Types.BOOLEAN, Types.SMALLINT, Types.INTEGER, Types.BIGINT, Types.REAL,
                Types.DOUBLE, Types.DECIMAL, Types.CHAR, Types.VARCHAR, Types.LONGVARCHAR, Types.BINARY,
                Types.VARBINARY, Types.BLOB, Types.DATE, Types.TIME, Types.TIMESTAMP};
        return kind >= 0 && kind < types.length ? types[kind] : Types.VARCHAR;
    }

    private static String jdbcTypeName(int type) {
        switch (type) {
            case Types.NULL: return "NULL"; case Types.BOOLEAN: return "BOOLEAN"; case Types.SMALLINT: return "SMALLINT";
            case Types.INTEGER: return "INTEGER"; case Types.BIGINT: return "BIGINT"; case Types.REAL: return "REAL";
            case Types.DOUBLE: return "DOUBLE"; case Types.DECIMAL: return "DECIMAL"; case Types.CHAR: return "CHAR";
            case Types.LONGVARCHAR: return "TEXT"; case Types.BINARY: return "BINARY"; case Types.VARBINARY: return "VARBINARY";
            case Types.BLOB: return "BLOB"; case Types.DATE: return "DATE"; case Types.TIME: return "TIME";
            case Types.TIMESTAMP: return "TIMESTAMP"; default: return "VARCHAR";
        }
    }

    private static boolean numericType(int type) {
        return type == Types.SMALLINT || type == Types.INTEGER || type == Types.BIGINT || type == Types.REAL
                || type == Types.DOUBLE || type == Types.DECIMAL || type == Types.NUMERIC;
    }

    private static int typePrecision(int type) {
        switch (type) {
            case Types.BOOLEAN: return 1; case Types.SMALLINT: return 5; case Types.INTEGER: return 10;
            case Types.BIGINT: return 19; case Types.REAL: return 7; case Types.DOUBLE: return 15;
            case Types.DECIMAL: case Types.NULL: return 0; case Types.DATE: return 10;
            case Types.TIME: return 15; case Types.TIMESTAMP: return 26; default: return Integer.MAX_VALUE;
        }
    }

    private static Class<?> jdbcClass(int type) {
        switch (type) {
            case Types.BOOLEAN: return Boolean.class; case Types.SMALLINT: return Short.class;
            case Types.INTEGER: return Integer.class; case Types.BIGINT: return Long.class;
            case Types.REAL: return Float.class; case Types.DOUBLE: return Double.class;
            case Types.DECIMAL: return BigDecimal.class;
            case Types.BINARY: case Types.VARBINARY: case Types.BLOB: return byte[].class;
            case Types.DATE: return Date.class; case Types.TIME: return Time.class; case Types.TIMESTAMP: return Timestamp.class;
            default: return String.class;
        }
    }

    private static Object convertObject(String value, int type) throws SQLException {
        if (value == null) return null;
        try {
            switch (type) {
                case Types.BOOLEAN: return parseBoolean(value); case Types.SMALLINT: return Short.valueOf(value);
                case Types.INTEGER: return Integer.valueOf(value); case Types.BIGINT: return Long.valueOf(value);
                case Types.REAL: return Float.valueOf(value); case Types.DOUBLE: return Double.valueOf(value);
                case Types.DECIMAL: case Types.NUMERIC: return new BigDecimal(value);
                case Types.BINARY: case Types.VARBINARY: case Types.BLOB: return decodeBytes(value);
                case Types.DATE: return dateValue(value); case Types.TIME: return timeValue(value);
                case Types.TIMESTAMP: return timestampValue(value); default: return value;
            }
        } catch (IllegalArgumentException failure) {
            throw new SQLException("Cannot convert column value to " + jdbcTypeName(type), "22018", failure);
        }
    }
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
        if (!value.matches("-?\\d+")) return Date.valueOf(value);
        return Date.valueOf(LocalDate.ofEpochDay(Long.parseLong(value)));
    }
    private static Time timeValue(String value) {
        if (value.indexOf(':') >= 0) return Time.valueOf(value);
        long micros = Long.parseLong(value);
        return Time.valueOf(LocalTime.ofNanoOfDay(micros * 1_000L));
    }
    private static Timestamp timestampValue(String value) {
        if (!value.matches("-?\\d+")) return Timestamp.valueOf(value.replace('T', ' '));
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
        StringBuilder regex = new StringBuilder("(?is)");
        boolean escaped = false;
        for (int index = 0; index < pattern.length(); index++) {
            char character = pattern.charAt(index);
            if (!escaped && character == '\\') { escaped = true; continue; }
            if (!escaped && character == '%') regex.append(".*");
            else if (!escaped && character == '_') regex.append('.');
            else regex.append(Pattern.quote(String.valueOf(character)));
            escaped = false;
        }
        if (escaped) regex.append(Pattern.quote("\\"));
        return value != null && value.matches(regex.toString());
    }
    private static int jdbcType(String type) {
        String name = type.toUpperCase(Locale.ROOT).split("\\(")[0].trim();
        switch (name) {
            case "SMALLINT": return Types.SMALLINT; case "INTEGER": case "INT": return Types.INTEGER;
            case "BIGINT": return Types.BIGINT; case "DECIMAL": case "NUMERIC": return Types.DECIMAL; case "REAL": case "FLOAT": return Types.REAL;
            case "DOUBLE": case "DOUBLE PRECISION": return Types.DOUBLE; case "BOOLEAN": return Types.BOOLEAN; case "DATE": return Types.DATE;
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
