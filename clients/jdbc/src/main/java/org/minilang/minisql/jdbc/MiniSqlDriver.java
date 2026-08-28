/*
 * Copyright 2026 MiniLangProject contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.minilang.minisql.jdbc;

import java.sql.Connection;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.DriverPropertyInfo;
import java.sql.SQLException;
import java.sql.SQLNonTransientConnectionException;
import java.util.Properties;
import java.util.logging.Logger;

/** JDBC 4.3 entry point for the native MiniSQL protocol. */
public final class MiniSqlDriver implements Driver {
    public static final String URL_PREFIX = "jdbc:minisql://";
    public static final String VERSION = "1.0.0";

    static {
        try {
            DriverManager.registerDriver(new MiniSqlDriver());
        } catch (SQLException exception) {
            throw new ExceptionInInitializerError(exception);
        }
    }

    /** Creates and authenticates a MiniSQL connection when the URL belongs to this driver. */
    @Override
    public Connection connect(String url, Properties properties) throws SQLException {
        if (!acceptsURL(url)) {
            return null;
        }
        MiniSqlUrl configuration = MiniSqlUrl.parse(url, properties);
        try {
            return MiniSqlJdbc.connection(configuration, MiniSqlProtocol.open(configuration));
        } catch (SQLException exception) {
            throw exception;
        } catch (Exception exception) {
            throw new SQLNonTransientConnectionException(
                    "Cannot connect to MiniSQL at " + configuration.host + ':' + configuration.port,
                    "08001", exception);
        }
    }

    @Override
    public boolean acceptsURL(String url) {
        return url != null && url.startsWith(URL_PREFIX);
    }

    @Override
    public DriverPropertyInfo[] getPropertyInfo(String url, Properties properties) throws SQLException {
        MiniSqlUrl parsed = MiniSqlUrl.parse(url == null ? URL_PREFIX + "127.0.0.1:7432/main" : url, properties);
        return new DriverPropertyInfo[] {
            property("user", parsed.user, false, "MiniSQL principal; omit for trusted-local mode"),
            property("password", null, false, "MiniSQL password"),
            property("tls", Boolean.toString(parsed.tls), false, "Enable TLS 1.3"),
            property("serverName", parsed.serverName, false, "TLS certificate DNS name"),
            property("pinSha256", parsed.pinSha256, false, "SHA-256 leaf-certificate pin"),
            property("trustServerCertificate", Boolean.toString(parsed.trustServerCertificate), false,
                    "Allow a self-signed certificate only when pinSha256 is also set"),
            property("connectTimeoutMs", Integer.toString(parsed.connectTimeoutMs), false, "TCP connect timeout"),
            property("socketTimeoutMs", Integer.toString(parsed.socketTimeoutMs), false, "Socket read timeout")
        };
    }

    private static DriverPropertyInfo property(String name, String value, boolean required, String description) {
        DriverPropertyInfo info = new DriverPropertyInfo(name, value);
        info.required = required;
        info.description = description;
        return info;
    }

    @Override public int getMajorVersion() { return 1; }
    @Override public int getMinorVersion() { return 0; }
    @Override public boolean jdbcCompliant() { return false; }
    @Override public Logger getParentLogger() { return Logger.getLogger("org.minilang.minisql.jdbc"); }
}
