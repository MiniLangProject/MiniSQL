/*
 * Copyright 2026 MiniLangProject contributors
 * Licensed under the Apache License, Version 2.0; see LICENSE for details.
 */
package org.minilang.minisql.jdbc;

import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
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
    static final int TYPE_RESPONSE = 100, TYPE_PONG = 101, TYPE_ERROR = 102;
    static final int STATUS_COMMAND = 1, STATUS_ROWS = 2, STATUS_ERROR = 3;
    static final int FLAG_SECURE = 1, FLAG_MORE = 2;
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
        write(new Message(TYPE_HELLO, 0, requestId, "MiniSQL/1".getBytes(StandardCharsets.UTF_8)));
        Message message = readExpected(requestId);
        Response response = decodeResponse(message);
        if (message.type != TYPE_RESPONSE || response.status != STATUS_COMMAND || !"HELLO".equals(response.command)) {
            throw connectionError("MiniSQL HELLO handshake was rejected", null);
        }
    }

    /** Performs MiniSQL's challenge/response authentication and activates inner AES-256-GCM framing. */
    private void authenticate(String user, String password) throws Exception {
        byte[] userBytes = user.getBytes(StandardCharsets.UTF_8);
        if (userBytes.length == 0 || userBytes.length > 128) throw connectionError("Invalid MiniSQL user name", null);
        ByteBuffer begin = little(2 + userBytes.length).putShort((short) userBytes.length).put(userBytes);
        int beginId = nextId();
        write(new Message(TYPE_AUTH_BEGIN, 0, beginId, begin.array()));
        Message challengeMessage = readExpected(beginId);
        if (challengeMessage.type != TYPE_AUTH_CHALLENGE || challengeMessage.payload.length != 52) {
            throw connectionError("MiniSQL authentication challenge was rejected", null);
        }
        ByteBuffer challenge = wrap(challengeMessage.payload);
        int iterations = challenge.getInt();
        if (iterations < 10_000 || iterations > 5_000_000) throw connectionError("Invalid authentication work factor", null);
        byte[] salt = new byte[16], nonce = new byte[32];
        challenge.get(salt).get(nonce);
        byte[] verifier = pbkdf2(password.getBytes(StandardCharsets.UTF_8), salt, iterations, 32);
        byte[] clientProof = authValue(verifier, nonce, user, "client", "MiniSQL-AUTH-1|");
        int proofId = nextId();
        write(new Message(TYPE_AUTH_PROOF, 0, proofId, clientProof));
        Message ok = readExpected(proofId);
        byte[] expectedServer = authValue(verifier, nonce, user, "server", "MiniSQL-AUTH-1|");
        if (ok.type != TYPE_AUTH_OK || ok.payload.length != 32 || !MessageDigest.isEqual(expectedServer, ok.payload)) {
            wipe(verifier, clientProof, expectedServer, salt, nonce);
            throw connectionError("MiniSQL authentication failed", null);
        }
        sendKey = authValue(verifier, nonce, user, "client-to-server", "MiniSQL-TRANSPORT-1|");
        receiveKey = authValue(verifier, nonce, user, "server-to-client", "MiniSQL-TRANSPORT-1|");
        wipe(verifier, clientProof, expectedServer, salt, nonce);
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
            write(new Message(TYPE_QUERY, 0, id, sql.getBytes(StandardCharsets.UTF_8)));
            Message message = readExpected(id);
            Response first = decodeResponse(message);
            if (message.type == TYPE_ERROR || first.status == STATUS_ERROR) throw serverError(first);
            Query query = new Query(this, id, first, (message.flags & FLAG_MORE) != 0);
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

    private Response continuation(Query query) throws SQLException {
        if (activeQuery != query) throw new SQLException("MiniSQL result stream is no longer active", "24000");
        try {
            Message message = readExpected(query.requestId);
            Response response = decodeResponse(message);
            if (message.type == TYPE_ERROR || response.status == STATUS_ERROR) throw serverError(response);
            query.more = (message.flags & FLAG_MORE) != 0;
            if (!query.more) activeQuery = null;
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
            if (source.getInt() != 0 || columnCount < 0 || columnCount > 1024 || rowCount < 0 || rowCount > 512) {
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
            if (source.hasRemaining()) throw new IOException("Trailing response bytes");
            return new Response(status, command, columns, rows, affected, text, error);
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
        return new String(bytes, StandardCharsets.UTF_8);
    }

    private static byte[] authValue(byte[] verifier, byte[] nonce, String user, String label, String prefix) throws Exception {
        byte[] context = (prefix + label + '|' + user).getBytes(StandardCharsets.UTF_8);
        byte[] salt = Arrays.copyOf(context, context.length + nonce.length);
        System.arraycopy(nonce, 0, salt, context.length, nonce.length);
        byte[] result = pbkdf2(verifier, salt, 1, 32);
        wipe(salt);
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
    private static SQLException serverError(Response response) { return new SQLException(response.message, "42000", response.errorCode); }
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

    /** A logical response whose continuation frames remain on the socket until consumed or drained. */
    static class Query implements AutoCloseable {
        final MiniSqlProtocol protocol;
        final int requestId;
        final Response first;
        boolean more;
        private boolean firstPending = true;
        Query(MiniSqlProtocol protocol, int requestId, Response first, boolean more) {
            this.protocol = protocol; this.requestId = requestId; this.first = first; this.more = more;
        }
        Response nextFrame() throws SQLException {
            if (firstPending) { firstPending = false; return first; }
            return more ? protocol.continuation(this) : null;
        }
        @Override public void close() throws SQLException { while (nextFrame() != null) { /* Drain before connection reuse. */ } }
    }

    /** Decoded response frame. Values are text because protocol v1 carries no type or null bitmap. */
    static final class Response {
        final int status, affectedRows, errorCode;
        final String command, message;
        final List<String> columns;
        final List<String[]> rows;
        Response(int status, String command, List<String> columns, List<String[]> rows,
                 int affectedRows, String message, int errorCode) {
            this.status = status; this.command = command; this.columns = columns; this.rows = rows;
            this.affectedRows = affectedRows; this.message = message; this.errorCode = errorCode;
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
