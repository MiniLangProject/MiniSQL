# MiniSQL Workbench

`minisql-admin.exe` is the native Windows graphical client for MiniSQL. Its
workflow follows the parts of SQuirreL SQL that are useful for MiniSQL: saved
connection aliases, a session object tree, SQL worksheets, reusable bookmarks,
query history, object-detail notebooks, result tabs, and a structured result
grid. It intentionally has no driver manager or support for other DBMSs.

## Start the application

Build the public applications and launch the workbench:

```powershell
.\build.ps1 -AppsOnly
.\build\bin\minisql-admin.exe
```

The first-run `Local MiniSQL` alias connects to a trusted loopback server on
port 7432. Select `Trusted local loopback` only when `minisqld` was started with
`--serve`; this mode cannot target a remote address. For an authenticated
server, clear that option, enter the MiniSQL user, and supply the password when
connecting. Passwords exist only for the connection attempt and are never
written to the alias file or SQL history.

MiniSQL serves one database per endpoint. The alias therefore stores a database
label for the UI; it does not send a `USE` command or expose databases belonging
to a different server process.

## Native TLS and self-signed certificates

Enable `Native TLS 1.3 / X.509` and enter the certificate DNS name in `TLS
server name`. With an empty pin field the client uses the Windows trust store,
validity dates, hostname, EKU, signature, TLS 1.3 policy,
`TLS_AES_256_GCM_SHA384`, and X25519 validation implemented by the native client.

For a self-signed leaf certificate, enter its exact SHA-256 DER fingerprint in
the pin field, with or without the `sha256:` prefix and colon separators. Pinning
only permits an otherwise unknown root; it does not bypass hostname, validity,
EKU, signature, protocol, cipher-suite, or key-exchange checks.

## Workbench layout

The left sidebar switches between:

- **Objects**: the connected database and all tables returned by `SHOW TABLES`;
- **Bookmarks**: MiniSQL-specific SQL templates; double-click to insert one;
- **History**: the latest 100 worksheet batches; secret-bearing account DCL is
  replaced by a redaction marker.

The main area switches between the SQL worksheet and object details. **Current**
executes the explicit selection, or the complete statement containing the caret
when no text is selected. **Run script** executes every statement in the editor
in source order. Both paths use the quote/comment-aware SQL scanner, so semicolons
inside strings, quoted identifiers, line comments, or block comments do not split
a statement. Explain uses the same current/selection scope and requires exactly
one statement.

Execution runs on a native MiniLang worker thread so window messages continue to
be processed. Connection handshakes, object-tree refreshes, table descriptions,
and the automatic refresh after SQL execution use the same non-blocking worker
model. Controls that read shared session state remain disabled until the active
worker publishes its result. Each execution creates a bounded result tab with
elapsed time, success state, columns, rows, and server messages. Select a table
and choose **Open object** to load Summary, Columns, Indexes, Data, Row Count,
and reconstructed DDL pages. Columns, indexes, preview data, and row counts are
rendered as native report grids with real column headers, selectable rows,
independent column widths, and horizontal/vertical scrolling rather than as
pipe-delimited text.

The **Data** page previews at most 100 rows and provides **Add row**, **Copy
row**, **Edit row**, **Delete row**, and **Refresh data** actions. Add, copy, and
edit open a resizable native row editor that presents every table field in a
review grid and edits one field at a time, so tables with many columns do not
require an oversized fixed form. Use `<NULL>` for SQL NULL; identity and default
fields use `<DEFAULT>` during inserts. Text is SQL-escaped, numeric and Boolean
input is validated before submission, and every mutation runs on the existing
background worker before the preview is reloaded. Double-clicking a Data row
opens it for editing. Updates and deletes require a primary key or unique index;
the workbench refuses an unsafe mutation that could target multiple rows, and
deletion always displays a confirmation dialog.

The selected SQL/Object Details workspace is part
of the session state, so metadata completion, refreshes, and full renders cannot
switch the user back to the worksheet. The toolbar also exposes EXPLAIN, BEGIN,
COMMIT, ROLLBACK, refresh, clear-results, and disconnect actions.

The SQL worksheet uses the system Unicode RichEdit control and highlights
MiniSQL keywords, strings, numbers, quoted identifiers, and comments while
preserving the caret, selection, and scroll position. Recoloring is debounced
until 120 ms after the latest native text change. The editor raises the text
limit to the native signed-count ceiling and transfers text through dynamically
sized UTF-16 buffers, so scripts
are not truncated at the compiler FFI scratch-buffer size. Generated metadata
SQL quotes Unicode and punctuation-bearing object names and doubles embedded
quote characters according to MiniSQL syntax.

Both the connection manager and the session workbench use DPI-independent
layout units. Native controls, Segoe UI fonts, editor panes, result grids, and
toolbars reflow when a window is resized, maximized, restored, or moved between
monitors with different scaling. Minimum client sizes prevent controls from
being clipped. Tab and Shift+Tab traverse editors and actions, while Enter
invokes the current default action.

Stopping an executing worker also disconnects that session. MiniSQL wire
protocol v1 has no server-side statement-cancellation frame, so disconnecting
is the only way to guarantee that response framing cannot be reused incorrectly.

## Alias storage

Aliases are stored atomically in
`%APPDATA%\MiniSQL\workbench-profiles.json`. Set
`MINISQL_ADMIN_PROFILE_PATH` to override this location. The schema stores the
endpoint, database label, user, TLS settings, optional certificate pin, and
trusted-local setting. Windows profile paths and JSON fields preserve Unicode.
The file never contains a password, and password-bearing `CREATE USER` or
`ALTER USER` SQL is redacted from worksheet state, history, and result tabs.

## Command-line shortcuts

```powershell
.\build\bin\minisql-admin.exe --connect-local 7432 shop
.\build\bin\minisql-admin.exe --connect 127.0.0.1 7432 admin shop
.\build\bin\minisql-admin.exe --connect-tls db.example.test 7443 db.example.test admin shop
```

Append a SHA-256 pin after the database label in the TLS form when connecting
to a pinned self-signed certificate.
