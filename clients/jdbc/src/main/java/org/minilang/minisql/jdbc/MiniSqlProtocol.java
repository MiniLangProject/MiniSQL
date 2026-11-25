/*
 * Copyright 2026 MiniLangProject contributors
 * Licensed under the Apache License, Version 2.0; see LICENSE for details.
 */
package org.minilang.minisql.jdbc;

import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.ByteArrayOutputStream;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.sql.SQLException;
import java.sql.SQLNonTransientConnectionException;
import java.sql.SQLRecoverableException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.zip.CRC32C;
import javax.crypto.Cipher;
import javax.crypto.Mac;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import javax.net.ssl.SNIHostName;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLParameters;
import javax.net.ssl.SSLSocket;
import javax.net.ssl.TrustManager;
import javax.net.ssl.TrustManagerFactory;
import javax.net.ssl.X509TrustManager;

/** Native MiniSQL v1 framing, authentication, TLS, and streaming response codec. */
final class MiniSqlProtocol implements AutoCloseable {
    static final int TYPE_HELLO = 1, TYPE_QUERY = 2, TYPE_PING = 3, TYPE_CLOSE = 4;
    static final int TYPE_AUTH_BEGIN = 5, TYPE_AUTH_CHALLENGE = 6, TYPE_AUTH_PROOF = 7, TYPE_AUTH_OK = 8;
    static final int TYPE_CANCEL = 9;
    static final int TYPE_RESPONSE = 100, TYPE_PONG = 101, TYPE_ERROR = 102;
    static final int STATUS_COMMAND = 1, STATUS_ROWS = 2, STATUS_ERROR = 3;
    static final int FLAG_SECURE = 1, FLAG_MORE = 2, FLAG_RESULT_START = 4, FLAG_METADATA = 8;
    private static final int HEADER_BYTES = 32, MAX_PAYLOAD = 16 * 1024 * 1024;

    private final MiniSqlUrl configuration;
    private final Socket socket;
    private final InputStream input;
    private final OutputStream output;
    private int nextRequestId = 1;
    private byte[] sendKey;
    private byte[] receiveKey;
    private long sendSequence;
    private long receiveSequence;
    private boolean secure;
    private boolean closed;
    private Query activeQuery;
    private volatile int sessionId;
    private boolean extendedResults;
    private List<Condition> lastWarnings = new ArrayList<>();

    private MiniSqlProtocol(MiniSqlUrl configuration, Socket socket) throws IOException {
        this.configuration = configuration;
        this.socket = socket;
        this.input = socket.getInputStream();
        this.output = socket.getOutputStream();
    }

    /** Opens the transport, completes HELLO, and performs password authentication when configured. */
    static MiniSqlProtocol open(MiniSqlUrl configuration) throws Exception {
        Socket raw = new Socket();
        raw.connect(new InetSocketAddress(configuration.host, configuration.port), configuration.connectTimeoutMs);
        raw.setSoTimeout(configuration.socketTimeoutMs);
        raw.setTcpNoDelay(true);
        Socket connected = configuration.tls ? tlsSocket(configuration, raw) : raw;
        MiniSqlProtocol protocol = new MiniSqlProtocol(configuration, connected);
        try {
            protocol.hello();
            if (configuration.user != null) protocol.authenticate(configuration.user, configuration.password);
            return protocol;
        } catch (Exception exception) {
            protocol.closeTransport();
            throw exception;
        }
    }

    private static Socket tlsSocket(MiniSqlUrl configuration, Socket raw) throws Exception {
        X509TrustManager system = systemTrustManager();
        X509TrustManager selected = configuration.pinSha256 == null ? system
                : new PinningTrustManager(system, configuration.pinSha256, configuration.trustServerCertificate);
        SSLContext context = SSLContext.getInstance("TLSv1.3");
        context.init(null, new TrustManager[] { selected }, new SecureRandom());
        SSLSocket socket = (SSLSocket) context.getSocketFactory()
                .createSocket(raw, configuration.serverName, configuration.port, true);
        SSLParameters parameters = socket.getSSLParameters();
        parameters.setProtocols(new String[] { "TLSv1.3" });
        parameters.setCipherSuites(new String[] { "TLS_AES_256_GCM_SHA384" });
        if (!isIpLiteral(configuration.serverName)) {
            parameters.setServerNames(Collections.singletonList(new SNIHostName(configuration.serverName)));
        }
        if (!configuration.trustServerCertificate) parameters.setEndpointIdentificationAlgorithm("HTTPS");
        socket.setSSLParameters(parameters);
        socket.startHandshake();
        return socket;
    }

    private static X509TrustManager systemTrustManager() throws Exception {
        TrustManagerFactory factory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        factory.init((java.security.KeyStore) null);
        for (TrustManager manager : factory.getTrustManagers()) {
            if (manager instanceof X509TrustManager) return (X509TrustManager) manager;
        }
        throw new CertificateException("No system X.509 trust manager is available");
    }

    private static boolean isIpLiteral(String value) {
        return value.indexOf(':') >= 0 || value.matches("[0-9]+(?:\\.[0-9]+){3}");
    }

    private void hello() throws Exception {
        int requestId = nextId();
        write(new Message(TYPE_HELLO, 0, requestId, "MiniSQL/1; capabilities=results-v2".getBytes(StandardCharsets.UTF_8)));
        Message message = readExpected(requestId);
        Response response = decodeResponse(message);
        if (message.type != TYPE_RESPONSE || response.status != STATUS_COMMAND || !"HELLO".equals(response.command)) {
            throw connectionError("MiniSQL HELLO handshake was rejected", null);
        }
        sessionId = parseSessionId(response.message);
        extendedResults = response.message.contains("; capabilities=results-v2");
    }

    /** Reports whether the server negotiated exact NULLs, output values, and diagnostics. */
    boolean extendedResults() { return extendedResults; }

    /** Returns the live warning list associated with the latest query. */
    List<Condition> warnings() { return lastWarnings; }

    /** Extracts the optional backward-compatible session identifier from HELLO. */
    static int parseSessionId(String message) {
        if (message == null) return 0;
        for (String field : message.split(";")) {
            String trimmed = field.trim();
            if (!trimmed.startsWith("session=")) continue;
            try {
                long parsed = Long.parseLong(trimmed.substring("session=".length()));
                return parsed >= 1 && parsed <= 0xffffffffL ? (int) parsed : 0;
            } catch (NumberFormatException ignored) {
                return 0;
            }
        }
        return 0;
    }

    /** Performs MiniSQL's challenge/response authentication and activates inner AES-256-GCM framing. */
    private void authenticate(String user, String password) throws Exception {
        byte[] userBytes = user.getBytes(StandardCharsets.UTF_8);
        if (userBytes.length == 0 || userBytes.length > 128) throw connectionError("Invalid MiniSQL user name", null);
        ByteBuffer begin = little(2 + userBytes.length).putShort((short) userBytes.length).put(userBytes);
        int beginId = nextId();
        write(new Message(TYPE_AUTH_BEGIN, 0, beginId, begin.array()));
        Message challengeMessage = readExpected(beginId);
        if (challengeMessage.type != TYPE_AUTH_CHALLENGE
                || (challengeMessage.payload.length != 52 && challengeMessage.payload.length != 56)) {
            throw connectionError("MiniSQL authentication challenge was rejected", null);
        }
        ByteBuffer challenge = wrap(challengeMessage.payload);
        int iterations = challenge.getInt();
        if (iterations < 10_000 || iterations > 5_000_000) throw connectionError("Invalid authentication work factor", null);
        byte[] salt = new byte[16], nonce = new byte[32];
        challenge.get(salt).get(nonce);
        int scheme = challengeMessage.payload.length == 52 ? 1 : Short.toUnsignedInt(challenge.getShort());
        if (scheme != 1 && scheme != 2 || challengeMessage.payload.length == 56 && challenge.getShort() != 0) {
            throw connectionError("Invalid MiniSQL authentication scheme", null);
        }
        byte[] verifier = pbkdf2(password.getBytes(StandardCharsets.UTF_8), salt, iterations, 32);
        byte[] clientProof, expectedServer, sessionSecret = verifier;
        if (scheme == 2) {
            byte[] transcript = concat("MiniSQL-AUTH-2|".getBytes(StandardCharsets.UTF_8), userBytes,
                    new byte[] { '|' }, nonce);
            byte[] clientKey = hmac(verifier, "MiniSQL Client Key".getBytes(StandardCharsets.UTF_8));
            byte[] storedKey = MessageDigest.getInstance("SHA-256").digest(clientKey);
            byte[] serverKey = hmac(verifier, "MiniSQL Server Key".getBytes(StandardCharsets.UTF_8));
            byte[] signature = hmac(storedKey, transcript);
            clientProof = xor(clientKey, signature);
            expectedServer = hmac(serverKey, transcript);
            sessionSecret = hmac(serverKey, concat("MiniSQL-SESSION-2|".getBytes(StandardCharsets.UTF_8), transcript, storedKey));
            wipe(transcript, clientKey, storedKey, serverKey, signature);
        } else {
            clientProof = authValue(verifier, nonce, user, "client", "MiniSQL-AUTH-1|");
            expectedServer = authValue(verifier, nonce, user, "server", "MiniSQL-AUTH-1|");
        }
        int proofId = nextId();
        write(new Message(TYPE_AUTH_PROOF, 0, proofId, clientProof));
        Message ok = readExpected(proofId);
        if (ok.type != TYPE_AUTH_OK || ok.payload.length != 32 || !MessageDigest.isEqual(expectedServer, ok.payload)) {
            wipe(verifier, clientProof, expectedServer, sessionSecret, salt, nonce);
            throw connectionError("MiniSQL authentication failed", null);
        }
        sendKey = authValue(sessionSecret, nonce, user, "client-to-server", "MiniSQL-TRANSPORT-1|");
        receiveKey = authValue(sessionSecret, nonce, user, "server-to-client", "MiniSQL-TRANSPORT-1|");
        wipe(verifier, clientProof, expectedServer, sessionSecret, salt, nonce);
        secure = true;
    }

    /** Starts a query and returns its first frame plus a lazy continuation reader. */
    synchronized Query query(String sql) throws SQLException {
        ensureOpen();
        if (activeQuery != null) {
            throw new SQLNonTransientConnectionException(
                    "Consume or close the active MiniSQL ResultSet before starting another statement", "25000");
        }
        try {
            int id = nextId();
            write(new Message(TYPE_QUERY, extendedResults ? FLAG_METADATA : 0, id, sql.getBytes(StandardCharsets.UTF_8)));
            Message message = readExpected(id);
            Response first = decodeResponse(message);
            lastWarnings = new ArrayList<>(first.warnings);
            if (message.type == TYPE_ERROR || first.status == STATUS_ERROR) throw serverError(first);
            Query query = new Query(this, id, first, (message.flags & FLAG_MORE) != 0);
            lastWarnings = query.warnings;
            if (query.more) activeQuery = query;
            return query;
        } catch (SQLException exception) {
            throw exception;
        } catch (Exception exception) {
            throw recoverable("MiniSQL query transport failed", exception);
        }
    }

    /** Verifies the connection with a protocol PING/PONG exchange. */
    synchronized boolean ping() throws SQLException {
        ensureOpen();
        try {
            int id = nextId();
            write(new Message(TYPE_PING, 0, id, new byte[0]));
            return readExpected(id).type == TYPE_PONG;
        } catch (Exception exception) {
            return false;
        }
    }

    /**
     * Cancels this protocol session through a short-lived control connection.
     *
     * This method intentionally does not synchronize on the target protocol:
     * its query thread may hold that monitor while waiting for a server frame.
     */
    void cancelCurrentSession() throws SQLException {
        int target = sessionId;
        if (target == 0) {
            throw new SQLException("The MiniSQL server did not advertise a cancellable session identifier", "0A000");
        }
        MiniSqlProtocol control = null;
        try {
            control = open(configuration);
            control.cancelSession(target);
        } catch (SQLException exception) {
            throw exception;
        } catch (Exception exception) {
            throw recoverable("MiniSQL cancellation transport failed", exception);
        } finally {
            if (control != null) control.close();
        }
    }

    /** Sends the protocol-v1 administrative cancellation request. */
    private synchronized void cancelSession(int target) throws SQLException {
        ensureOpen();
        try {
            int id = nextId();
            write(new Message(TYPE_CANCEL, 0, id, little(4).putInt(target).array()));
            Message message = readExpected(id);
            Response response = decodeResponse(message);
            if (message.type == TYPE_ERROR || response.status == STATUS_ERROR) throw serverError(response);
        } catch (SQLException exception) {
            throw exception;
        } catch (Exception exception) {
            throw recoverable("MiniSQL cancellation transport failed", exception);
        }
    }

    private Response continuation(Query query) throws SQLException {
        if (activeQuery != query) throw new SQLException("MiniSQL result stream is no longer active", "24000");
        try {
            Message message = readExpected(query.requestId);
            Response response = decodeResponse(message);
            query.more = (message.flags & FLAG_MORE) != 0;
            if (!query.more) activeQuery = null;
            if (message.type == TYPE_ERROR || response.status == STATUS_ERROR) {
                activeQuery = null;
                // A terminal routine condition belongs to the next result;
                // completed SELECT rows must remain readable before it.
                if (!response.resultStart || query.more) {
                    query.warnings.addAll(response.warnings);
                    query.more = false;
                    throw serverError(response);
                }
            }
            return response;
        } catch (SQLException exception) {
            throw exception;
        } catch (Exception exception) {
            throw recoverable("MiniSQL result stream failed", exception);
        }
    }

    private void write(Message logical) throws Exception {
        Message message = secure ? protect(logical) : logical;
        byte[] header = new byte[HEADER_BYTES];
        ByteBuffer buffer = wrap(header);
        buffer.put(new byte[] { 'M', 'S', 'Q', 'L' }).putShort((short) 1).putShort((short) message.type)
                .putInt(message.flags).putInt(message.requestId).putInt(message.payload.length)
                .putInt(crc(message.payload)).putInt(0).putInt(0);
        wrap(header).putInt(24, crc(header));
        // One write produces one TLS application record for ordinary frames.
        // Writing header and payload separately makes JSSE emit two tiny TLS
        // records and can trigger a delayed-ACK round trip on Windows.
        byte[] frame = Arrays.copyOf(header, header.length + message.payload.length);
        System.arraycopy(message.payload, 0, frame, header.length, message.payload.length);
        output.write(frame);
        output.flush();
    }

    private Message read() throws Exception {
        byte[] header = readFully(HEADER_BYTES);
        if (header[0] != 'M' || header[1] != 'S' || header[2] != 'Q' || header[3] != 'L') throw new IOException("Magic mismatch");
        ByteBuffer buffer = wrap(header);
        if (Short.toUnsignedInt(buffer.getShort(4)) != 1 || buffer.getInt(28) != 0) throw new IOException("Unsupported frame header");
        int expectedHeaderCrc = buffer.getInt(24);
        buffer.putInt(24, 0);
        if (crc(header) != expectedHeaderCrc) throw new IOException("Header CRC32C mismatch");
        int length = buffer.getInt(16);
        if (length < 0 || length > MAX_PAYLOAD) throw new IOException("Payload exceeds protocol limit");
        byte[] payload = readFully(length);
        if (crc(payload) != buffer.getInt(20)) throw new IOException("Payload CRC32C mismatch");
        Message message = new Message(Short.toUnsignedInt(buffer.getShort(6)), buffer.getInt(8), buffer.getInt(12), payload);
        return secure ? unprotect(message) : message;
    }

    private Message readExpected(int requestId) throws Exception {
        Message message = read();
        if (message.requestId != requestId) throw new IOException("Unexpected MiniSQL request identifier");
        return message;
    }

    private Message protect(Message logical) throws Exception {
        int flags = logical.flags | FLAG_SECURE;
        byte[] nonce = nonce(sendKey, sendSequence);
        byte[] aad = aad(logical.type, flags, logical.requestId, sendSequence, logical.payload.length);
        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(sendKey, "AES"), new GCMParameterSpec(128, nonce));
        cipher.updateAAD(aad);
        byte[] encrypted = cipher.doFinal(logical.payload);
        ByteBuffer payload = little(8 + encrypted.length).putLong(sendSequence++).put(encrypted);
        return new Message(logical.type, flags, logical.requestId, payload.array());
    }

    private Message unprotect(Message message) throws Exception {
        if ((message.flags & FLAG_SECURE) == 0 || message.payload.length < 24) throw new IOException("Unprotected frame after authentication");
        ByteBuffer payload = wrap(message.payload);
        long sequence = payload.getLong();
        if (sequence != receiveSequence) throw new IOException("Secure sequence mismatch");
        byte[] encrypted = new byte[message.payload.length - 8];
        payload.get(encrypted);
        byte[] nonce = nonce(receiveKey, sequence);
        byte[] aad = aad(message.type, message.flags, message.requestId, sequence, encrypted.length - 16);
        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(receiveKey, "AES"), new GCMParameterSpec(128, nonce));
        cipher.updateAAD(aad);
        byte[] plaintext = cipher.doFinal(encrypted);
        receiveSequence++;
        return new Message(message.type, message.flags & ~FLAG_SECURE, message.requestId, plaintext);
    }

    static Response decodeResponse(Message message) throws SQLException {
        if (message.type != TYPE_RESPONSE && message.type != TYPE_ERROR) throw connectionError("Unexpected MiniSQL response type", null);
        try {
            ByteBuffer source = wrap(message.payload);
            if (source.remaining() < 24) throw new IOException("Truncated response");
            int status = Short.toUnsignedInt(source.getShort());
            if (source.getShort() != 0) throw new IOException("Invalid reserved field");
            int columnCount = source.getInt(), rowCount = source.getInt(), affected = source.getInt(), error = source.getInt();
            int metadataLength = source.getInt();
            if (status < 1 || status > 3 || metadataLength < 0 || metadataLength > source.remaining()
                    || columnCount < 0 || columnCount > 1024 || rowCount < 0 || rowCount > 512) {
                throw new IOException("Invalid response counts");
            }
            String command = field(source), text = field(source);
            List<String> columns = new ArrayList<>(columnCount);
            for (int index = 0; index < columnCount; index++) columns.add(field(source));
            List<String[]> rows = new ArrayList<>(rowCount);
            for (int row = 0; row < rowCount; row++) {
                String[] values = new String[columnCount];
                for (int column = 0; column < columnCount; column++) values[column] = field(source);
                rows.add(values);
            }
            if (source.remaining() != metadataLength) throw new IOException("Trailing response bytes");
            String state = "";
            List<Condition> warnings = new ArrayList<>();
            List<Integer> types = new ArrayList<>();
            List<OutputParameter> outputs = new ArrayList<>();
            if (metadataLength > 0) {
                if (source.remaining() < 4 || source.getInt() != 0x3156444d) throw new IOException("Invalid metadata version");
                state = field(source);
                if (!validState(state)) throw new IOException("Invalid SQLSTATE");
                int warningCount = count(source, 65535);
                for (int index = 0; index < warningCount; index++) {
                    String warningState = field(source);
                    if (!validState(warningState) || source.remaining() < 4) throw new IOException("Invalid warning");
                    int code = source.getInt();
                    warnings.add(new Condition(warningState, code, field(source)));
                }
                int bitmapLength = count(source, MAX_PAYLOAD);
                if (bitmapLength != (columnCount * rowCount + 7) / 8 || bitmapLength > source.remaining()) throw new IOException("Invalid NULL bitmap");
                byte[] bitmap = new byte[bitmapLength]; source.get(bitmap);
                int position = 0;
                for (String[] row : rows) for (int column = 0; column < row.length; column++, position++) {
                    if ((bitmap[position >>> 3] & (1 << (position & 7))) != 0) row[column] = null;
                }
                int typeCount = count(source, 1024);
                if (typeCount != columnCount || source.remaining() < typeCount * 2) throw new IOException("Invalid column types");
                for (int index = 0; index < typeCount; index++) {
                    int type = Short.toUnsignedInt(source.getShort());
                    if (type > 16) throw new IOException("Invalid column type");
                    types.add(type);
                }
                int outputCount = count(source, 65535);
                for (int index = 0; index < outputCount; index++) {
                    int ordinal = count(source, 65535);
                    String name = field(source);
                    if (ordinal < 1 || source.remaining() < 4) throw new IOException("Invalid output parameter");
                    int type = Short.toUnsignedInt(source.getShort()), nullFlag = Short.toUnsignedInt(source.getShort());
                    if (type > 16 || nullFlag > 1) throw new IOException("Invalid output type");
                    String value = field(source);
                    outputs.add(new OutputParameter(ordinal, name, type, nullFlag == 1 ? null : value));
                }
            }
            if (source.hasRemaining()) throw new IOException("Trailing metadata bytes");
            return new Response(status, command, columns, rows, affected, text, error,
                    (message.flags & FLAG_RESULT_START) != 0, state, warnings, types, outputs, metadataLength > 0);
        } catch (Exception exception) {
            if (exception instanceof SQLException) throw (SQLException) exception;
            throw connectionError("Invalid MiniSQL response", exception);
        }
    }

    private static String field(ByteBuffer source) throws IOException {
        if (source.remaining() < 4) throw new IOException("Truncated response field");
        int length = source.getInt();
        if (length < 0 || length > source.remaining()) throw new IOException("Invalid response field length");
        byte[] bytes = new byte[length];
        source.get(bytes);
        return StandardCharsets.UTF_8.newDecoder().decode(ByteBuffer.wrap(bytes)).toString();
    }

    /** Reads a defensive unsigned count before allocating or iterating. */
    private static int count(ByteBuffer source, int maximum) throws IOException {
        if (source.remaining() < 4) throw new IOException("Truncated metadata count");
        int value = source.getInt();
        if (value < 0 || value > maximum) throw new IOException("Invalid metadata count");
        return value;
    }

    private static boolean validState(String state) { return state != null && state.matches("[0-9A-Z]{5}"); }

    /** Encodes the same validated response layout used by spools and protocol test peers. */
    static byte[] encodeResponse(Response response) throws SQLException {
        try {
            ByteArrayOutputStream body = new ByteArrayOutputStream();
            byte[] header = little(24).putShort((short) response.status).putShort((short) 0)
                    .putInt(response.columns.size()).putInt(response.rows.size()).putInt(response.affectedRows)
                    .putInt(response.errorCode).putInt(0).array();
            body.write(header); writeField(body, response.command); writeField(body, response.message);
            for (String column : response.columns) writeField(body, column);
            for (String[] row : response.rows) {
                if (row.length != response.columns.size()) throw new IOException("Inconsistent response row");
                for (String value : row) writeField(body, value == null ? "NULL" : value);
            }
            if (response.extended) {
                ByteArrayOutputStream extra = new ByteArrayOutputStream();
                extra.write(new byte[] {'M', 'D', 'V', '1'});
                String state = validState(response.sqlState) ? response.sqlState : response.status == STATUS_ERROR ? "HY000" : "00000";
                writeField(extra, state); writeInt(extra, response.warnings.size());
                for (Condition warning : response.warnings) {
                    writeField(extra, warning.sqlState); writeInt(extra, warning.code); writeField(extra, warning.message);
                }
                byte[] bitmap = new byte[(response.rows.size() * response.columns.size() + 7) / 8];
                int position = 0;
                for (String[] row : response.rows) for (String value : row) {
                    if (value == null) bitmap[position >>> 3] |= 1 << (position & 7);
                    position++;
                }
                writeInt(extra, bitmap.length); extra.write(bitmap);
                writeInt(extra, response.columns.size());
                for (int index = 0; index < response.columns.size(); index++) {
                    int type = index < response.columnTypes.size() ? response.columnTypes.get(index) : 0;
                    extra.write(little(2).putShort((short) type).array());
                }
                writeInt(extra, response.outputs.size());
                for (OutputParameter output : response.outputs) {
                    writeInt(extra, output.ordinal); writeField(extra, output.name);
                    extra.write(little(4).putShort((short) output.typeKind).putShort((short) (output.value == null ? 1 : 0)).array());
                    writeField(extra, output.value == null ? "" : output.value);
                }
                byte[] base = body.toByteArray();
                wrap(base).putInt(20, extra.size());
                body.reset(); body.write(base); body.write(extra.toByteArray());
            }
            if (body.size() > MAX_PAYLOAD) throw new IOException("Response exceeds frame limit");
            return body.toByteArray();
        } catch (IOException exception) {
            throw recoverable("Cannot encode MiniSQL response", exception);
        }
    }

    private static void writeInt(ByteArrayOutputStream output, int value) throws IOException { output.write(little(4).putInt(value).array()); }
    private static void writeField(ByteArrayOutputStream output, String text) throws IOException {
        byte[] bytes = text.getBytes(StandardCharsets.UTF_8);
        writeInt(output, bytes.length); output.write(bytes);
    }

    private static byte[] authValue(byte[] verifier, byte[] nonce, String user, String label, String prefix) throws Exception {
        byte[] context = (prefix + label + '|' + user).getBytes(StandardCharsets.UTF_8);
        byte[] salt = Arrays.copyOf(context, context.length + nonce.length);
        System.arraycopy(nonce, 0, salt, context.length, nonce.length);
        byte[] result = pbkdf2(verifier, salt, 1, 32);
        wipe(salt);
        return result;
    }

    /** Computes HMAC-SHA-256 without provider-specific password conversions. */
    private static byte[] hmac(byte[] key, byte[] message) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(key, "HmacSHA256"));
        return mac.doFinal(message);
    }

    /** Concatenates transcript fragments while keeping the authentication code readable. */
    private static byte[] concat(byte[]... values) {
        int length = 0;
        for (byte[] value : values) length += value.length;
        byte[] result = new byte[length];
        int offset = 0;
        for (byte[] value : values) {
            System.arraycopy(value, 0, result, offset, value.length);
            offset += value.length;
        }
        return result;
    }

    /** XORs equal-sized SCRAM values to create the client proof. */
    private static byte[] xor(byte[] left, byte[] right) {
        byte[] result = new byte[left.length];
        for (int index = 0; index < result.length; index++) result[index] = (byte) (left[index] ^ right[index]);
        return result;
    }

    /** PBKDF2-HMAC-SHA256 over bytes; avoids PBEKeySpec's provider-specific character conversion. */
    static byte[] pbkdf2(byte[] password, byte[] salt, int iterations, int length) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(password, "HmacSHA256"));
        byte[] result = new byte[length];
        int offset = 0;
        for (int block = 1; offset < length; block++) {
            ByteBuffer seed = ByteBuffer.allocate(salt.length + 4).put(salt).putInt(block);
            byte[] u = mac.doFinal(seed.array()), accumulator = u.clone();
            for (int round = 1; round < iterations; round++) {
                u = mac.doFinal(u);
                for (int index = 0; index < accumulator.length; index++) accumulator[index] ^= u[index];
            }
            int copy = Math.min(accumulator.length, length - offset);
            System.arraycopy(accumulator, 0, result, offset, copy);
            offset += copy;
            wipe(u, accumulator);
        }
        return result;
    }

    private static byte[] nonce(byte[] key, long sequence) {
        ByteBuffer nonce = little(12);
        for (int index = 0; index < 4; index++) nonce.put((byte) (key[index] ^ 0xA5));
        nonce.putLong(sequence);
        return nonce.array();
    }

    private static byte[] aad(int type, int flags, int requestId, long sequence, int length) {
        return little(24).putInt(type).putInt(flags).putInt(requestId).putLong(sequence).putInt(length).array();
    }

    private byte[] readFully(int length) throws IOException {
        byte[] output = new byte[length];
        int offset = 0;
        while (offset < length) {
            int count = input.read(output, offset, length - offset);
            if (count < 0) throw new EOFException("MiniSQL server closed the connection");
            offset += count;
        }
        return output;
    }

    private int nextId() { int value = nextRequestId++; if (nextRequestId == 0) nextRequestId = 1; return value; }
    private static int crc(byte[] bytes) { CRC32C crc = new CRC32C(); crc.update(bytes, 0, bytes.length); return (int) crc.getValue(); }
    private static ByteBuffer little(int size) { return ByteBuffer.allocate(size).order(ByteOrder.LITTLE_ENDIAN); }
    private static ByteBuffer wrap(byte[] bytes) { return ByteBuffer.wrap(bytes).order(ByteOrder.LITTLE_ENDIAN); }
    private static void wipe(byte[]... values) { for (byte[] value : values) if (value != null) Arrays.fill(value, (byte) 0); }
    /** Preserves a validated SIGNAL SQLSTATE while retaining the legacy fallback for native errors. */
    private static SQLException serverError(Response response) {
        String state = response.extended && validState(response.sqlState) && !"00000".equals(response.sqlState) ? response.sqlState : "42000";
        int start = "SQLSTATE ".length();
        if (!response.extended && response.message.length() >= start + 7 && response.message.startsWith("SQLSTATE ")
                && response.message.startsWith(": ", start + 5)) {
            String candidate = response.message.substring(start, start + 5);
            if (candidate.matches("[0-9A-Z]{5}")) state = candidate;
        }
        return new SQLException(response.message, state, response.errorCode);
    }
    private static SQLNonTransientConnectionException connectionError(String message, Throwable cause) {
        return new SQLNonTransientConnectionException(message, "08001", cause);
    }
    private static SQLRecoverableException recoverable(String message, Throwable cause) {
        return new SQLRecoverableException(message, "08006", cause);
    }
    private void ensureOpen() throws SQLException { if (closed) throw new SQLNonTransientConnectionException("MiniSQL connection is closed", "08003"); }

    /** Applies the JDBC network timeout to subsequent socket reads. */
    synchronized void setSocketTimeout(int milliseconds) throws SQLException {
        ensureOpen();
        try { socket.setSoTimeout(milliseconds); }
        catch (IOException exception) { throw recoverable("Cannot set MiniSQL socket timeout", exception); }
    }

    @Override
    public synchronized void close() {
        if (closed) return;
        if (activeQuery != null) {
            try { activeQuery.close(); } catch (SQLException ignored) { }
        }
        try { int id = nextId(); write(new Message(TYPE_CLOSE, 0, id, new byte[0])); } catch (Exception ignored) { }
        closeTransport();
    }

    private void closeTransport() {
        closed = true;
        try { socket.close(); } catch (IOException ignored) { }
        wipe(sendKey, receiveKey);
    }

    /** One request with separately consumable result sets and bounded continuation frames. */
    static class Query implements AutoCloseable {
        final MiniSqlProtocol protocol;
        final int requestId;
        Response first;
        boolean more;
        final List<Condition> warnings;
        private boolean firstPending = true, resultEnded, closed;
        private Response pendingResult;
        Query(MiniSqlProtocol protocol, int requestId, Response first, boolean more) {
            this.protocol = protocol; this.requestId = requestId; this.first = first; this.more = more;
            this.warnings = new ArrayList<>(first.warnings);
        }
        /** Returns batches only from the current result, retaining the next boundary. */
        Response nextFrame() throws SQLException {
            if (closed || resultEnded) return null;
            if (firstPending) { firstPending = false; return first; }
            if (!more) { resultEnded = true; return null; }
            Response next = readContinuation();
            warnings.addAll(next.warnings);
            if (next.resultStart) { pendingResult = next; resultEnded = true; return null; }
            if (next.status != first.status || !next.columns.equals(first.columns)) {
                throw new SQLException("MiniSQL continuation result schema changed without a boundary", "08S01");
            }
            return next;
        }
        /** Allows an in-memory CALL replay to preserve exactly the same boundary semantics. */
        Response readContinuation() throws SQLException { return protocol.continuation(this); }
        /** Discards unread rows of one result without discarding later CALL results. */
        void finishResult() throws SQLException { while (nextFrame() != null) { } }
        /** Advances to another row set or command result from the same request. */
        boolean nextResult() throws SQLException {
            if (closed) return false;
            finishResult();
            if (pendingResult == null) { closed = true; return false; }
            first = pendingResult; pendingResult = null; firstPending = true; resultEnded = false;
            if (first.status == STATUS_ERROR) { closed = true; throw serverError(first); }
            return true;
        }
        @Override public void close() throws SQLException {
            do { finishResult(); } while (nextResult());
            closed = true;
        }
    }

    /** Buffered procedure results retained while JDBC output parameters are fetched. */
    static final class BufferedQuery extends Query {
        private final List<Response> frames;
        private int index = 1;
        BufferedQuery(List<Response> frames) {
            super(null, 0, frames.get(0), frames.size() > 1);
            this.frames = frames;
        }
        @Override Response readContinuation() {
            Response response = frames.get(index++);
            more = index < frames.size();
            return response;
        }
    }

    /** Ordered SQL condition delivered independently of a human-readable exception prefix. */
    static final class Condition {
        final String sqlState, message;
        final int code;
        Condition(String sqlState, int code, String message) {
            this.sqlState = sqlState; this.code = code; this.message = message;
        }
    }

    /** Final successful CALL output at its one-based declaration ordinal. */
    static final class OutputParameter {
        final int ordinal, typeKind;
        final String name, value;
        OutputParameter(int ordinal, String name, int typeKind, String value) {
            this.ordinal = ordinal; this.name = name; this.typeKind = typeKind; this.value = value;
        }
    }

    /** Bounded-memory result storage used when output parameters require draining a CALL. */
    static final class ResultSpool implements AutoCloseable {
        private Path path;
        private DataOutputStream output;
        private int count;
        ResultSpool() throws SQLException {
            try {
                path = Files.createTempFile("minisql-results-", ".spool");
                output = new DataOutputStream(new BufferedOutputStream(Files.newOutputStream(path), 65536));
            } catch (IOException exception) { close(); throw recoverable("Cannot create result spool", exception); }
        }
        /** Writes one already bounded protocol frame without retaining earlier rows. */
        void append(Response response) throws SQLException {
            if (output == null) throw new SQLException("Result spool is closed", "HY010");
            byte[] payload = encodeResponse(response);
            try {
                output.writeInt((response.resultStart ? FLAG_RESULT_START : 0) | (response.extended ? FLAG_METADATA : 0));
                output.writeInt(payload.length); output.write(payload); count++;
            } catch (IOException exception) { close(); throw recoverable("Cannot write result spool", exception); }
        }
        /** Preserves completed results before surfacing a terminal condition during replay. */
        void appendError(SQLException exception) throws SQLException {
            String state = validState(exception.getSQLState()) ? exception.getSQLState() : "HY000";
            append(new Response(STATUS_ERROR, "ERROR", Collections.emptyList(), Collections.emptyList(), 0,
                    exception.getMessage(), exception.getErrorCode(), true, state, Collections.emptyList(),
                    Collections.emptyList(), Collections.emptyList(), true));
        }
        /** Transfers exclusive file ownership to the forward-only replay query. */
        Query finish() throws SQLException {
            if (output == null || count == 0) { close(); throw new SQLException("Cannot replay an empty result spool", "HY010"); }
            try { output.close(); output = null; }
            catch (IOException exception) { close(); throw recoverable("Cannot finish result spool", exception); }
            Path completed = path;
            Query query = new SpoolQuery(new SpoolReader(completed, count));
            path = null;
            return query;
        }
        @Override public void close() {
            if (output != null) { try { output.close(); } catch (IOException ignored) { } output = null; }
            if (path != null) { try { Files.deleteIfExists(path); } catch (IOException ignored) { } path = null; }
        }
    }

    /** Owns one protected temporary file and validates every replayed frame. */
    private static final class SpoolReader implements AutoCloseable {
        private final Path path;
        private DataInputStream input;
        private int remaining;
        private final Response first;
        SpoolReader(Path path, int count) throws SQLException {
            this.path = path; this.remaining = count;
            try {
                input = new DataInputStream(new BufferedInputStream(Files.newInputStream(path), 65536));
                first = read();
            } catch (IOException exception) { close(); throw recoverable("Cannot open result spool", exception); }
            catch (SQLException exception) { close(); throw exception; }
        }
        Response read() throws SQLException {
            try {
                if (remaining <= 0 || input == null) throw new IOException("Result spool exhausted");
                int flags = input.readInt(), length = input.readInt();
                if (length < 24 || length > MAX_PAYLOAD) throw new IOException("Invalid spool frame length");
                byte[] payload = new byte[length]; input.readFully(payload); remaining--;
                return decodeResponse(new Message(TYPE_RESPONSE, flags, 0, payload));
            } catch (IOException exception) { close(); throw recoverable("Cannot read result spool", exception); }
        }
        @Override public void close() {
            if (input != null) { try { input.close(); } catch (IOException ignored) { } input = null; }
            try { Files.deleteIfExists(path); } catch (IOException ignored) { }
        }
    }

    /** Replays a CALL or retained result with a constant number of in-memory frames. */
    private static final class SpoolQuery extends Query {
        private final SpoolReader reader;
        SpoolQuery(SpoolReader reader) {
            super(null, 0, reader.first, reader.remaining > 0); this.reader = reader;
        }
        @Override Response readContinuation() throws SQLException {
            Response response = reader.read(); more = reader.remaining > 0; return response;
        }
        @Override boolean nextResult() throws SQLException {
            try {
                boolean available = super.nextResult();
                if (!available) reader.close();
                return available;
            } catch (SQLException exception) { reader.close(); throw exception; }
        }
        @Override public void close() throws SQLException {
            try { super.close(); } finally { reader.close(); }
        }
    }

    /** Decoded response frame. Values are text because protocol v1 carries no type or null bitmap. */
    static final class Response {
        final int status, affectedRows, errorCode;
        final String command, message;
        final List<String> columns;
        final List<String[]> rows;
        final boolean resultStart;
        final String sqlState;
        final List<Condition> warnings;
        final List<Integer> columnTypes;
        final List<OutputParameter> outputs;
        final boolean extended;
        Response(int status, String command, List<String> columns, List<String[]> rows,
                 int affectedRows, String message, int errorCode) {
            this(status, command, columns, rows, affectedRows, message, errorCode, false);
        }
        Response(int status, String command, List<String> columns, List<String[]> rows,
                 int affectedRows, String message, int errorCode, boolean resultStart) {
            this(status, command, columns, rows, affectedRows, message, errorCode, resultStart, "",
                    Collections.emptyList(), Collections.emptyList(), Collections.emptyList(), false);
        }
        Response(int status, String command, List<String> columns, List<String[]> rows,
                 int affectedRows, String message, int errorCode, boolean resultStart, String sqlState,
                 List<Condition> warnings, List<Integer> columnTypes, List<OutputParameter> outputs, boolean extended) {
            this.status = status; this.command = command; this.columns = columns; this.rows = rows;
            this.affectedRows = affectedRows; this.message = message; this.errorCode = errorCode;
            this.resultStart = resultStart;
            this.sqlState = sqlState; this.warnings = warnings; this.columnTypes = columnTypes;
            this.outputs = outputs; this.extended = extended;
        }
        /** Retains metadata while detaching unread rows of a kept JDBC result. */
        Response withRows(List<String[]> replacement) {
            return new Response(status, command, columns, replacement, affectedRows, message, errorCode,
                    resultStart, sqlState, warnings, columnTypes, outputs, extended);
        }
    }

    private static final class Message {
        final int type, flags, requestId; final byte[] payload;
        Message(int type, int flags, int requestId, byte[] payload) {
            this.type = type; this.flags = flags; this.requestId = requestId; this.payload = payload;
        }
    }

    /** Combines ordinary PKIX validation with an optional exact leaf certificate pin. */
    private static final class PinningTrustManager implements X509TrustManager {
        private final X509TrustManager delegate; private final String pin; private final boolean pinOnly;
        PinningTrustManager(X509TrustManager delegate, String pin, boolean pinOnly) {
            this.delegate = delegate; this.pin = pin; this.pinOnly = pinOnly;
        }
        @Override public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {
            delegate.checkClientTrusted(chain, authType);
        }
        @Override public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {
            if (chain == null || chain.length == 0) throw new CertificateException("Server certificate is missing");
            if (!pinOnly) delegate.checkServerTrusted(chain, authType);
            try {
                byte[] digest = MessageDigest.getInstance("SHA-256").digest(chain[0].getEncoded());
                if (!pin.equals(hex(digest))) throw new CertificateException("MiniSQL certificate pin mismatch");
            } catch (CertificateException exception) { throw exception; }
            catch (Exception exception) { throw new CertificateException("Cannot validate certificate pin", exception); }
        }
        @Override public X509Certificate[] getAcceptedIssuers() { return delegate.getAcceptedIssuers(); }
        private static String hex(byte[] bytes) {
            StringBuilder result = new StringBuilder(bytes.length * 2);
            for (byte value : bytes) result.append(String.format("%02x", value & 0xff));
            return result.toString();
        }
    }
}
