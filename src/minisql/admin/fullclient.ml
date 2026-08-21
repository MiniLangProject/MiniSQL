package minisql.admin.fullclient

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.client.client as client
import minisql.client.console as console
import minisql.client.formatter as formatter
import minisql.common.uuid as uuid
import minisql.platform.clock as clock
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages

const INVALID_ARGUMENT = 9001
const MAX_RESULT_TABS = 32
const MAX_HISTORY_ITEMS = 100

// Describes one persistent MiniSQL connection alias without retaining a password.
struct ConnectionProfile
  // Stores the user-visible alias name.
  name
  // Stores the TCP address of the MiniSQL server.
  address
  // Stores the TCP port of the MiniSQL server.
  port
  // Stores the TLS server name used for X.509 hostname validation.
  serverName
  // Stores a user-visible label for the single database served by the endpoint.
  databaseName
  // Stores the MiniSQL account name used for challenge-response authentication.
  userName
  // Selects native TLS 1.3 transport protection.
  tls
  // Stores an optional exact SHA-256 leaf-certificate pin.
  pinSha256
  // Selects the loopback-only trusted-local server mode.
  trustedLocal
end struct

// Captures the metadata pages shown for a selected table.
struct TableDetails
  // Stores the selected table name.
  tableName
  // Stores the compact table summary.
  summaryText
  // Stores the formatted DESCRIBE response.
  columnsText
  // Stores the formatted SHOW INDEXES response.
  indexesText
  // Stores the formatted preview query response.
  contentsText
  // Stores the formatted row-count response.
  rowCountText
  // Stores reconstructed CREATE TABLE SQL.
  ddlText
end struct

// Summarizes the outcome of one editor execution.
struct QueryView
  // Counts statements submitted by the editor.
  statementCount
  // Counts command responses returned by the server.
  commandCount
  // Counts rows in the final row-producing response.
  rowCount
  // Indicates whether every response completed successfully.
  success
  // Stores the combined human-readable server output.
  resultText
end struct

// Retains one structured SQL result page for native grid rendering.
struct ResultTab
  // Stores the concise tab title derived from SQL text.
  title
  // Stores redacted SQL suitable for history display.
  sqlText
  // Stores the formatted response text.
  resultText
  // Counts rows retained in this result.
  rowCount
  // Indicates whether execution succeeded.
  success
  // Stores ordered result column names.
  columns
  // Stores ordered textual result rows.
  rows
  // Stores elapsed wall-clock milliseconds.
  elapsedMilliseconds
end struct

// Defines a reusable SQL template offered by the editor.
struct Bookmark
  // Stores the bookmark label shown in the UI.
  label
  // Stores SQL inserted into the editor.
  sqlText
end struct

// Owns the state shared by the MiniSQL object browser and SQL worksheet.
struct FullClientState
  // Stores the immutable connection profile.
  profile
  // Owns the active protocol client.
  remoteClient
  // Contains table names reported by SHOW TABLES.
  tables
  // Stores the object-browser selection.
  selectedTable
  // Stores details for the selected table.
  tableDetails
  // Stores the latest editor text.
  queryText
  // Stores the latest execution summary.
  queryView
  // Stores a concise user-facing state message.
  statusText
  // Retains bounded structured result tabs.
  resultTabs
  // Selects the result tab rendered in the grid.
  selectedResultIndex
  // Retains bounded, redacted SQL history.
  history
  // Contains built-in reusable SQL templates.
  bookmarks
  // Tracks an explicit transaction started by the workbench.
  transactionActive
end struct

// Creates a namespaced structured error for the workbench model.
function fail(operation, message)
  return error(INVALID_ARGUMENT, "admin.fullclient." + operation + ": " + message)
end function

// Returns an empty successful query summary.
function emptyQueryView()
  return QueryView(0, 0, 0, true, "")
end function

// Returns empty table-detail pages before an object is selected.
function emptyTableDetails()
  return TableDetails("", "", "", "", "", "", "")
end function

// Quotes any non-empty MiniSQL identifier and doubles embedded quote characters.
function quotedIdentifier(value)
  if typeof(value) != "string" or len(bytes(value)) == 0 then return fail("quotedIdentifier", "identifier must be a non-empty string") end if
  output = bytes([34])
  for each item in bytes(value)
    output = output + bytes([item])
    if item == 34 then output = output + bytes([34]) end if
  end for
  output = output + bytes([34])
  quoted = decode(output)
  if typeof(quoted) != "string" then return fail("quotedIdentifier", "identifier is not valid UTF-8") end if
  return quoted
end function

// Performs a byte-safe substring search without relying on host helpers.
function textContains(text, wanted)
  if typeof(text) != "string" or typeof(wanted) != "string" then return false end if
  source = bytes(text)
  target = bytes(wanted)
  if len(target) == 0 then return true end if
  if len(source) < len(target) then return false end if
  for offset = 0 to len(source) - len(target)
    matched = true
    for index = 0 to len(target) - 1
      if source[offset + index] != target[index] then matched = false end if
    end for
    if matched then return true end if
  end for
  return false
end function

// Converts ASCII letters to upper case for secret-bearing DCL detection.
function asciiUpper(text)
  raw = bytes(text)
  output = bytes(len(raw), 0)
  if len(raw) > 0 then
    for index = 0 to len(raw) - 1
      value = raw[index]
      if value >= 97 and value <= 122 then value = value - 32 end if
      output[index] = value
    end for
  end if
  decoded = decode(output)
  if typeof(decoded) != "string" then return text end if
  return decoded
end function

// Conservatively identifies account DCL before it can enter long-lived UI state.
function isSensitiveSql(sqlText)
  if typeof(sqlText) != "string" then return false end if
  // Match secret-bearing keywords independently of surrounding whitespace or
  // comments. PASSWORD is MiniSQL's DCL spelling; IDENTIFIED covers imported
  // MySQL-style scripts before the server rejects or accepts an extension.
  upper = asciiUpper(sqlText)
  return textContains(upper, "PASSWORD") or textContains(upper, "IDENTIFIED")
end function

// Redacts account DCL so passwords never enter result, history, or query state.
function historySql(sqlText)
  if isSensitiveSql(sqlText) then return "<sensitive account DCL redacted>" end if
  return sqlText
end function

// Joins display lines using Windows edit-control newlines.
function lineJoin(values)
  output = ""
  for each value in values
    if len(output) > 0 then output = output + "\r\n" end if
    output = output + value
  end for
  return output
end function

// Provides SQuirreL-style starter templates specialized for MiniSQL.
function defaultBookmarks()
  return [
    Bookmark("Show tables", "SHOW TABLES;"),
    Bookmark("Describe selected table", "DESCRIBE <table>;"),
    Bookmark("Preview selected table", "SELECT * FROM <table> LIMIT 100;"),
    Bookmark("Count selected table", "SELECT COUNT(*) AS row_count FROM <table>;"),
    Bookmark("Create table", "CREATE TABLE example (id INTEGER PRIMARY KEY, label VARCHAR(120) NOT NULL);"),
    Bookmark("Begin transaction", "BEGIN;"),
    Bookmark("Commit transaction", "COMMIT;"),
    Bookmark("Rollback transaction", "ROLLBACK;")
  ]
end function

// Returns bookmark labels for native list rendering.
function bookmarkLines(bookmarks)
  lines = []
  for each bookmark in bookmarks
    lines = lines + [bookmark.label]
  end for
  return lines
end function

// Constructs and validates one MiniSQL-only connection profile.
function createProfile(name, address, port, serverName, databaseName, userName, tls, pinSha256, trustedLocal)
  if typeof(name) != "string" or len(name) == 0 then return fail("createProfile", "name must be non-empty") end if
  if typeof(address) != "string" or len(address) == 0 then return fail("createProfile", "address must be non-empty") end if
  if typeof(port) != "int" or port < 1 or port > 65535 then return fail("createProfile", "port is invalid") end if
  if typeof(serverName) != "string" or len(serverName) == 0 then return fail("createProfile", "TLS server name must be non-empty") end if
  if typeof(databaseName) != "string" or len(databaseName) == 0 then return fail("createProfile", "database label must be non-empty") end if
  if typeof(userName) != "string" then return fail("createProfile", "user name must be string") end if
  if typeof(tls) != "bool" or typeof(trustedLocal) != "bool" then return fail("createProfile", "TLS and trusted-local flags must be bool") end if
  if typeof(pinSha256) != "string" then return fail("createProfile", "certificate pin must be string") end if
  if trustedLocal and (address != "127.0.0.1" and address != "localhost") then return fail("createProfile", "trusted-local mode requires a loopback address") end if
  if trustedLocal and tls then return fail("createProfile", "trusted-local and TLS modes are mutually exclusive") end if
  if not trustedLocal and len(userName) == 0 then return fail("createProfile", "authenticated connections require a user name") end if
  if len(pinSha256) > 0 and not tls then return fail("createProfile", "certificate pinning requires TLS") end if
  return ConnectionProfile(name, address, port, serverName, databaseName, userName, tls, pinSha256, trustedLocal)
end function

// Formats the endpoint shown in alias and session status areas.
function endpointText(profile)
  prefix = "tcp://"
  if profile.tls then prefix = "tls://" end if
  mode = ""
  if profile.trustedLocal then mode = " (trusted local)" end if
  return prefix + profile.address + ":" + profile.port + "/" + profile.databaseName + mode
end function

// Opens the transport selected by a profile and wipes no caller-owned secret.
function openTransport(profile, passwordBytes)
  if profile.trustedLocal then return client.openLoopback(profile.port) end if
  if typeof(passwordBytes) != "bytes" then return fail("openTransport", "password must be bytes") end if
  if profile.tls then
    if len(profile.pinSha256) > 0 then return client.openTlsPinnedAuthenticatedAddressBytes(profile.address, profile.port, profile.serverName, profile.pinSha256, profile.userName, passwordBytes) end if
    return client.openTlsAuthenticatedAddressBytes(profile.address, profile.port, profile.serverName, profile.userName, passwordBytes)
  end if
  return client.openAuthenticatedAddressBytes(profile.address, profile.port, profile.userName, passwordBytes)
end function

// Opens a profile and eagerly loads the table tree.
function openProfile(profile, passwordBytes)
  if profile is not ConnectionProfile then return fail("openProfile", "profile must be ConnectionProfile") end if
  remote = try(openTransport(profile, passwordBytes))
  if typeof(remote) == "error" then return remote end if
  state = FullClientState(profile, remote, [], "", emptyTableDetails(), "SHOW TABLES;", emptyQueryView(), "Connected to " + endpointText(profile), [], -1, [], defaultBookmarks(), false)
  refreshed = try(refresh(state))
  if typeof(refreshed) == "error" then
    ignoredClose = try(client.close(remote))
    return refreshed
  end if
  return state
end function

// Closes the active protocol session.
function close(state)
  if state is not FullClientState then return fail("close", "state must be FullClientState") end if
  return client.close(state.remoteClient)
end function

// Aborts a session after cancellation invalidated its request/response stream.
function abort(state)
  if state is not FullClientState then return fail("abort", "state must be FullClientState") end if
  return client.abort(state.remoteClient)
end function

// Converts a protocol response into an operation error when the server rejected SQL.
function responseFailure(response, operation)
  if not messages.isResponse(response) then return fail(operation, "response is invalid") end if
  if response.status == constants.STATUS_ERROR then return error(response.errorCode, "admin.fullclient." + operation + ": " + response.message) end if
  return response
end function

// Executes exactly one statement without changing editor history.
function queryOne(state, sqlText)
  if state is not FullClientState then return fail("queryOne", "state must be FullClientState") end if
  response = try(client.query(state.remoteClient, sqlText))
  if typeof(response) == "error" then return response end if
  return responseFailure(response, "queryOne")
end function

// Renders a response for detail pages and result messages.
function renderResponse(response)
  if typeof(response) == "error" then return "ERROR " + response.code + ": " + response.message end if
  formatted = try(formatter.formatResponse(response))
  if typeof(formatted) == "error" then return "ERROR " + formatted.code + ": " + formatted.message end if
  return formatted
end function

// Derives a compact result-tab title from the submitted SQL.
function sqlTitle(sqlText)
  text = try(console.trimAscii(sqlText))
  if typeof(text) == "error" then return "SQL" end if
  raw = bytes(text)
  if len(raw) <= 40 then return text end if
  prefix = decode(slice(raw, 0, 40))
  if typeof(prefix) != "string" then return "SQL result" end if
  return prefix + "..."
end function

// Returns the final row response in a multi-statement batch.
function lastRowResponse(responses)
  index = len(responses) - 1
  while index >= 0
    response = responses[index]
    if messages.isResponse(response) and response.status == constants.STATUS_ROWS then return response end if
    index = index - 1
  end while
  return void
end function

// Bounds an array by retaining its newest entries.
function keepNewest(values, maximum)
  if len(values) <= maximum then return values end if
  output = []
  for index = len(values) - maximum to len(values) - 1
    output = output + [values[index]]
  end for
  return output
end function

// Stores one result tab and selects it for grid rendering.
function addResultTab(state, sqlText, view, responses, elapsedMilliseconds)
  columns = []
  rows = []
  rowResponse = lastRowResponse(responses)
  if rowResponse is not void then columns = rowResponse.columns; rows = rowResponse.rows end if
  safeSql = historySql(sqlText)
  tab = ResultTab(sqlTitle(safeSql), safeSql, view.resultText, view.rowCount, view.success, columns, rows, elapsedMilliseconds)
  state.resultTabs = keepNewest(state.resultTabs + [tab], MAX_RESULT_TABS)
  state.selectedResultIndex = len(state.resultTabs) - 1
  state.history = keepNewest(state.history + [safeSql], MAX_HISTORY_ITEMS)
  return tab
end function

// Executes a semicolon-delimited editor batch and retains bounded, redacted results.
function executeSql(state, sqlText)
  if state is not FullClientState then return fail("executeSql", "state must be FullClientState") end if
  text = try(console.trimAscii(sqlText))
  if typeof(text) == "error" or len(text) == 0 then return fail("executeSql", "SQL text must be non-empty") end if
  statements = try(console.splitSqlStatements(text))
  if typeof(statements) == "error" then return statements end if
  if len(statements) == 0 then return fail("executeSql", "finish the statement with a semicolon") end if
  started = clock.monotonicMilliseconds()
  responses = []
  commandCount = 0
  rowCount = 0
  success = true
  lines = []
  for each statement in statements
    response = try(client.query(state.remoteClient, statement))
    if typeof(response) == "error" then return response end if
    responses = responses + [response]
    if response.status == constants.STATUS_ERROR then success = false end if
    if response.status == constants.STATUS_COMMAND then commandCount = commandCount + 1 end if
    if response.status == constants.STATUS_ROWS then rowCount = len(response.rows) end if
    lines = lines + [renderResponse(response)]
  end for
  elapsed = clock.monotonicMilliseconds() - started
  view = QueryView(len(statements), commandCount, rowCount, success, lineJoin(lines))
  // The network call needs the original SQL, but retained state must never keep
  // account secrets alive after the request has left this stack frame.
  state.queryText = historySql(text)
  state.queryView = view
  ignoredTab = addResultTab(state, text, view, responses, elapsed)
  if success then state.statusText = "Completed " + len(statements) + " statement(s), " + rowCount + " row(s) in " + elapsed + " ms" else state.statusText = "SQL completed with an error in " + elapsed + " ms" end if
  return view
end function

// Executes EXPLAIN for the editor selection.
function explainSql(state, sqlText)
  text = try(console.trimAscii(sqlText))
  if typeof(text) == "error" or len(text) == 0 then return fail("explainSql", "SQL text must be non-empty") end if
  raw = bytes(text)
  if len(raw) > 0 and raw[len(raw) - 1] == 59 then text = decode(slice(raw, 0, len(raw) - 1)) end if
  return executeSql(state, "EXPLAIN " + text + ";")
end function

// Executes a transaction-control statement and updates toolbar state.
function transactionCommand(state, sqlText, activeAfter)
  view = try(executeSql(state, sqlText))
  if typeof(view) == "error" then return view end if
  if view.success then state.transactionActive = activeAfter end if
  return view
end function

// Begins an explicit MiniSQL transaction.
function beginTransaction(state)
  return transactionCommand(state, "BEGIN;", true)
end function

// Commits the current explicit MiniSQL transaction.
function commitTransaction(state)
  return transactionCommand(state, "COMMIT;", false)
end function

// Rolls back the current explicit MiniSQL transaction.
function rollbackTransaction(state)
  return transactionCommand(state, "ROLLBACK;", false)
end function

// Refreshes the object browser from SHOW TABLES without creating a result tab.
function refresh(state)
  response = try(queryOne(state, "SHOW TABLES"))
  if typeof(response) == "error" then return response end if
  tables = []
  for each row in response.rows
    if len(row) > 0 then tables = tables + [row[0]] end if
  end for
  state.tables = tables
  if len(state.selectedTable) > 0 and not containsText(tables, state.selectedTable) then state.selectedTable = ""; state.tableDetails = emptyTableDetails() end if
  state.statusText = "Object tree refreshed: " + len(tables) + " table(s)"
  return true
end function

// Returns whether an array contains an exact string.
function containsText(values, wanted)
  for each value in values
    if value == wanted then return true end if
  end for
  return false
end function

// Converts validated DESCRIBE metadata into a readable CREATE TABLE preview.
function ddlFromDescribe(tableName, response)
  quoted = try(quotedIdentifier(tableName))
  if typeof(quoted) == "error" then return "" end if
  output = "CREATE TABLE " + quoted + " (\r\n"
  if len(response.rows) > 0 then
    for index = 0 to len(response.rows) - 1
      row = response.rows[index]
      // A malformed or version-incompatible server row must not crash the GUI
      // and must not be interpolated into executable-looking SQL.
      if len(row) < 6 then return "-- Invalid DESCRIBE response: expected six metadata columns." end if
      columnName = try(quotedIdentifier(row[1]))
      if typeof(columnName) == "error" then return "-- Invalid DESCRIBE response: unsafe column identifier." end if
      if index > 0 then output = output + ",\r\n" end if
      line = "  " + columnName + " " + row[2]
      if row[3] == "FALSE" then line = line + " NOT NULL" end if
      if row[4] != "NULL" then line = line + " DEFAULT " + row[4] end if
      if row[5] == "TRUE" then line = line + " AUTO_INCREMENT" end if
      output = output + line
    end for
  end if
  return output + "\r\n);"
end function

// Loads all SQuirreL-style detail pages for one selected MiniSQL table.
function describeTable(state, tableName)
  quoted = try(quotedIdentifier(tableName))
  if typeof(quoted) == "error" then return quoted end if
  columns = try(queryOne(state, "DESCRIBE " + quoted))
  if typeof(columns) == "error" then return columns end if
  indexes = try(queryOne(state, "SHOW INDEXES FROM " + quoted))
  if typeof(indexes) == "error" then return indexes end if
  contents = try(queryOne(state, "SELECT * FROM " + quoted + " LIMIT 100"))
  if typeof(contents) == "error" then return contents end if
  rowCount = try(queryOne(state, "SELECT COUNT(*) AS row_count FROM " + quoted))
  if typeof(rowCount) == "error" then return rowCount end if
  summary = "Table: " + tableName + "\r\nColumns: " + len(columns.rows) + "\r\nIndexes: " + len(indexes.rows) + "\r\nPreview rows: " + len(contents.rows)
  details = TableDetails(tableName, summary, renderResponse(columns), renderResponse(indexes), renderResponse(contents), renderResponse(rowCount), ddlFromDescribe(tableName, columns))
  state.selectedTable = tableName
  state.tableDetails = details
  state.statusText = "Loaded metadata for table " + tableName
  return details
end function

// Returns names of the object-detail notebook pages.
function detailTabLines(state)
  if len(state.selectedTable) == 0 then return ["Database"] end if
  return ["Summary", "Columns", "Indexes", "Data", "Row Count", "DDL"]
end function

// Returns the selected detail-page text by its tab label.
function detailTextByName(state, name)
  details = state.tableDetails
  if name == "Columns" then return details.columnsText end if
  if name == "Indexes" then return details.indexesText end if
  if name == "Data" then return details.contentsText end if
  if name == "Row Count" then return details.rowCountText end if
  if name == "DDL" then return details.ddlText end if
  if name == "Summary" then return details.summaryText end if
  return "MiniSQL database\r\nEndpoint: " + endpointText(state.profile) + "\r\nTables: " + len(state.tables) + "\r\nTLS: " + state.profile.tls
end function

// Returns compact result-tab labels including status, rows, and elapsed time.
function resultTabLines(tabs)
  lines = []
  if len(tabs) > 0 then
    for index = 0 to len(tabs) - 1
      tab = tabs[index]
      marker = "OK"
      if not tab.success then marker = "ERROR" end if
      lines = lines + ["" + (index + 1) + " " + marker + "  " + tab.rowCount + " rows  " + tab.elapsedMilliseconds + " ms"]
    end for
  end if
  return lines
end function

// Returns the currently selected structured result tab.
function activeResultTab(state)
  if state.selectedResultIndex >= 0 and state.selectedResultIndex < len(state.resultTabs) then return state.resultTabs[state.selectedResultIndex] end if
  return void
end function

// Clears result tabs while preserving SQL history.
function clearResultTabs(state)
  state.resultTabs = []
  state.selectedResultIndex = -1
  state.queryView = emptyQueryView()
  state.statusText = "Result tabs cleared"
  return true
end function

// Returns SQL for a bookmark and substitutes the selected table where required.
function bookmarkSqlForSelection(state, label)
  for each bookmark in state.bookmarks
    if bookmark.label == label then
      sqlText = bookmark.sqlText
      if textContains(sqlText, "<table>") then
        if len(state.selectedTable) == 0 then return "" end if
        quoted = try(quotedIdentifier(state.selectedTable))
        if typeof(quoted) == "error" then return "" end if
        if label == "Describe selected table" then return "DESCRIBE " + quoted + ";" end if
        if label == "Preview selected table" then return "SELECT * FROM " + quoted + " LIMIT 100;" end if
        if label == "Count selected table" then return "SELECT COUNT(*) AS row_count FROM " + quoted + ";" end if
      end if
      return sqlText
    end if
  end for
  return ""
end function

// Returns a SELECT template for the selected table.
function queryForTable(state, tableName)
  quoted = try(quotedIdentifier(tableName))
  if typeof(quoted) == "error" then return quoted end if
  return "SELECT * FROM " + quoted + " LIMIT 100;"
end function

// Returns the stable module name used by smoke tests.
function componentName()
  return "admin.fullclient"
end function

// Identifies the GUI integration milestone.
function targetMilestone()
  return "M74"
end function

// Reports that the workbench model is implemented.
function isImplemented()
  return true
end function
