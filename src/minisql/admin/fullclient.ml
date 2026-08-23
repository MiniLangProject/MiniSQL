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
import minisql.sql.dialect as dialect

const INVALID_ARGUMENT = 9001
const MAX_RESULT_TABS = 32
const MAX_HISTORY_ITEMS = 100
const DEFAULT_DATA_PAGE_SIZE = 100
const MAX_DATA_PAGE_SIZE = 1000

const SQL_STYLE_KEYWORD = 1
const SQL_STYLE_STRING = 2
const SQL_STYLE_NUMBER = 3
const SQL_STYLE_COMMENT = 4
const SQL_STYLE_QUOTED_IDENTIFIER = 5

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

// Retains one structured table used by an object-detail page.
struct DetailGrid
  // Stores ordered native-grid column captions.
  columns
  // Stores ordered textual rows aligned with columns.
  rows
end struct

// Describes one stable server-side page of a table data browser.
struct DataBrowseOptions
  // Stores an optional SQL predicate entered in the WHERE filter box.
  filterText
  // Stores an optional exact result-column name used for ORDER BY.
  sortColumn
  // Selects ascending ordering when a sort column is present.
  ascending
  // Stores the zero-based page number.
  page
  // Stores the bounded number of rows requested per page.
  pageSize
end struct

// Retains one unapplied row change so the grid can preview and later commit it.
struct PendingDataChange
  // Stores INSERT, UPDATE, or DELETE for presentation.
  kind
  // Stores the generated, key-constrained SQL statement.
  sqlText
  // Stores -1 for inserts or the original page-row index for updates/deletes.
  rowIndex
  // Stores editor values aligned with DESCRIBE metadata when available.
  values
end struct

// Retains one independent SQL worksheet tab.
struct Worksheet
  // Stores the short user-visible tab title.
  title
  // Stores the complete SQL editor contents for this worksheet.
  sqlText
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
  // Retains structured DESCRIBE metadata for the Columns grid and row editor.
  columnsGrid
  // Retains structured SHOW INDEXES metadata for the Indexes grid.
  indexesGrid
  // Retains structured preview data for the editable Data grid.
  contentsGrid
  // Retains the structured COUNT response for the Row Count page.
  rowCountGrid
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

// Describes one syntax-colored UTF-16 range in the native SQL worksheet.
struct SqlSyntaxSpan
  // Stores the inclusive UTF-16 start offset used by the RichEdit control.
  startOffset
  // Stores the exclusive UTF-16 end offset used by the RichEdit control.
  endOffset
  // Selects one of the SQL_STYLE_* presentation categories.
  kind
end struct

// Links presentation spans during a linear-time lexer pass.
struct SqlSyntaxNode
  // Stores the syntax span owned by this node.
  span
  // Points to the next node or void at the tail.
  next
end struct

// Owns the mutable head/tail state used to avoid quadratic array appends.
struct SqlSyntaxAccumulator
  // Points to the first collected span node.
  first
  // Points to the final collected span node.
  last
  // Counts nodes for one exactly sized result allocation.
  count
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
  empty = DetailGrid([], [])
  return TableDetails("", "", "", "", "", "", "", empty, empty, empty, empty)
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

// Quotes a one- or two-part MiniSQL object name without treating a dot as data.
function quotedObjectName(value)
  if typeof(value) != "string" or len(bytes(value)) == 0 then return fail("quotedObjectName", "object name must be a non-empty string") end if
  raw = bytes(value)
  separator = -1
  for index = 0 to len(raw) - 1
    if raw[index] == 46 then
      if separator >= 0 then return fail("quotedObjectName", "object name may contain at most one schema separator") end if
      separator = index
    end if
  end for
  if separator < 0 then return quotedIdentifier(value) end if
  if separator == 0 or separator == len(raw) - 1 then return fail("quotedObjectName", "schema and object names must be non-empty") end if
  schemaName = decode(slice(raw, 0, separator))
  objectName = decode(slice(raw, separator + 1, len(raw) - separator - 1))
  if typeof(schemaName) != "string" or typeof(objectName) != "string" then return fail("quotedObjectName", "object name is not valid UTF-8") end if
  quotedSchema = try(quotedIdentifier(schemaName))
  if typeof(quotedSchema) == "error" then return quotedSchema end if
  quotedObject = try(quotedIdentifier(objectName))
  if typeof(quotedObject) == "error" then return quotedObject end if
  return quotedSchema + "." + quotedObject
end function

// Quotes user-entered text as one SQL string literal and doubles embedded apostrophes.
function quotedTextLiteral(value)
  if typeof(value) != "string" then return fail("quotedTextLiteral", "value must be a string") end if
  output = bytes([39])
  for each item in bytes(value)
    output = output + bytes([item])
    if item == 39 then output = output + bytes([39]) end if
  end for
  output = output + bytes([39])
  quoted = decode(output)
  if typeof(quoted) != "string" then return fail("quotedTextLiteral", "value is not valid UTF-8") end if
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

// Returns the UTF-8 byte width and UTF-16 code-unit width of one valid scalar.
function utf8Step(raw, index)
  if typeof(raw) != "bytes" or typeof(index) != "int" or index < 0 or index >= len(raw) then return fail("utf8Step", "byte offset is outside the text") end if
  value = raw[index]
  if value < 128 then return [1, 1] end if
  if value < 224 then return [2, 1] end if
  if value < 240 then return [3, 1] end if
  return [4, 2]
end function

// Counts native RichEdit UTF-16 code units without losing supplementary characters.
function utf16Length(text)
  if typeof(text) != "string" then return fail("utf16Length", "text must be string") end if
  raw = bytes(text)
  index = 0
  units = 0
  while index < len(raw)
    step = utf8Step(raw, index)
    index = index + step[0]
    units = units + step[1]
  end while
  return units
end function

// Converts a native UTF-16 caret offset to an exact UTF-8 byte boundary.
function byteOffsetForUtf16(text, wantedUnits)
  if typeof(text) != "string" or typeof(wantedUnits) != "int" or wantedUnits < 0 then return fail("byteOffsetForUtf16", "invalid text or UTF-16 offset") end if
  raw = bytes(text)
  index = 0
  units = 0
  while index < len(raw) and units < wantedUnits
    step = utf8Step(raw, index)
    if units + step[1] > wantedUnits then return fail("byteOffsetForUtf16", "offset splits a Unicode character") end if
    index = index + step[0]
    units = units + step[1]
  end while
  if units != wantedUnits then return fail("byteOffsetForUtf16", "offset is beyond the editor text") end if
  return index
end function

// Decodes one byte range whose boundaries were validated against UTF-16 offsets.
function textForUtf16Range(text, startOffset, endOffset)
  if typeof(text) != "string" or typeof(startOffset) != "int" or typeof(endOffset) != "int" or startOffset < 0 or endOffset < startOffset then return fail("textForUtf16Range", "invalid editor range") end if
  startByte = try(byteOffsetForUtf16(text, startOffset))
  if typeof(startByte) == "error" then return startByte end if
  endByte = try(byteOffsetForUtf16(text, endOffset))
  if typeof(endByte) == "error" then return endByte end if
  decoded = decode(slice(bytes(text), startByte, endByte - startByte))
  if typeof(decoded) != "string" then return fail("textForUtf16Range", "selected text is not valid UTF-8") end if
  return decoded
end function

// Returns whether one editor fragment contains executable SQL rather than comments only.
function executableSqlFragment(text)
  trimmed = try(console.trimAscii(text))
  if typeof(trimmed) == "error" or len(trimmed) == 0 then return "" end if
  statements = try(console.splitSqlStatements(trimmed))
  if typeof(statements) == "error" then return statements end if
  if len(statements) == 0 then return "" end if
  return trimmed
end function

// Locates the statement containing a collapsed caret while honoring SQL lexical regions.
// A caret after the final delimiter selects the preceding statement, matching common
// worksheet behavior; semicolons inside strings, identifiers, and comments are ignored.
function currentStatementSql(text, caretOffset)
  if typeof(text) != "string" or typeof(caretOffset) != "int" then return fail("currentStatementSql", "invalid editor text or caret") end if
  caretByte = try(byteOffsetForUtf16(text, caretOffset))
  if typeof(caretByte) == "error" then return caretByte end if
  source = bytes(text)
  startOffset = 0
  previousStart = -1
  previousEnd = -1
  index = 0
  mode = 0 // 0 normal, 1 string, 2 quoted identifier, 3 line comment, 4 block comment, 5 shell hash comment
  lineStart = true
  while index < len(source)
    value = source[index]
    nextValue = -1
    if index + 1 < len(source) then nextValue = source[index + 1] end if
    if mode == 1 then
      if value == 39 then
        if nextValue == 39 then index = index + 1 else mode = 0 end if
      end if
    else if mode == 2 then
      if value == 34 then
        if nextValue == 34 then index = index + 1 else mode = 0 end if
      end if
    else if mode == 3 or mode == 5 then
      if value == 10 or value == 13 then mode = 0; lineStart = true end if
    else if mode == 4 then
      if value == 42 and nextValue == 47 then mode = 0; index = index + 1 end if
    else
      if value == 39 then mode = 1; lineStart = false
      else if value == 34 then mode = 2; lineStart = false
      else if value == 45 and nextValue == 45 then mode = 3; index = index + 1
      else if value == 47 and nextValue == 42 then mode = 4; index = index + 1
      else if value == 35 and lineStart then mode = 5
      else if value == 59 then
        if caretByte <= index then
          candidate = decode(slice(source, startOffset, index + 1 - startOffset))
          if typeof(candidate) != "string" then return fail("currentStatementSql", "statement text is not valid UTF-8") end if
          return executableSqlFragment(candidate)
        end if
        previousStart = startOffset
        previousEnd = index + 1
        startOffset = index + 1
        lineStart = true
      else if value == 10 or value == 13 then lineStart = true
      else if value != 9 and value != 32 then lineStart = false
      end if
    end if
    index = index + 1
  end while
  candidate = decode(slice(source, startOffset, len(source) - startOffset))
  if typeof(candidate) != "string" then return fail("currentStatementSql", "statement text is not valid UTF-8") end if
  executable = try(executableSqlFragment(candidate))
  if typeof(executable) == "error" then return executable end if
  if len(executable) > 0 then return executable end if
  if previousStart >= 0 then
    previous = decode(slice(source, previousStart, previousEnd - previousStart))
    if typeof(previous) != "string" then return fail("currentStatementSql", "previous statement is not valid UTF-8") end if
    return executableSqlFragment(previous)
  end if
  return ""
end function

// Chooses the whole script, an explicit selection, or the caret's current statement.
function editorSqlForExecution(text, selectionStart, selectionEnd, wholeScript)
  if typeof(text) != "string" or typeof(selectionStart) != "int" or typeof(selectionEnd) != "int" or typeof(wholeScript) != "bool" then return fail("editorSqlForExecution", "invalid arguments") end if
  if selectionStart > selectionEnd then temporary = selectionStart; selectionStart = selectionEnd; selectionEnd = temporary end if
  chosen = ""
  if wholeScript then
    chosen = try(executableSqlFragment(text))
  else if selectionEnd > selectionStart then
    selected = try(textForUtf16Range(text, selectionStart, selectionEnd))
    if typeof(selected) == "error" then return selected end if
    chosen = try(executableSqlFragment(selected))
  else
    chosen = try(currentStatementSql(text, selectionStart))
  end if
  if typeof(chosen) == "error" then return chosen end if
  if len(chosen) == 0 then return fail("editorSqlForExecution", "the selected editor range contains no SQL statement") end if
  return chosen
end function

// Appends one non-empty native syntax range in constant time.
function appendSyntaxSpan(accumulator, startOffset, endOffset, kind)
  if accumulator is not SqlSyntaxAccumulator then return fail("appendSyntaxSpan", "accumulator must be SqlSyntaxAccumulator") end if
  if endOffset <= startOffset then return true end if
  node = SqlSyntaxNode(SqlSyntaxSpan(startOffset, endOffset, kind), void)
  if accumulator.first is void then accumulator.first = node else accumulator.last.next = node end if
  accumulator.last = node
  accumulator.count = accumulator.count + 1
  return true
end function

// Materializes a linked syntax sequence into the array consumed by native code.
function syntaxSpanArray(accumulator)
  if accumulator is not SqlSyntaxAccumulator then return fail("syntaxSpanArray", "accumulator must be SqlSyntaxAccumulator") end if
  output = array(accumulator.count, void)
  node = accumulator.first
  index = 0
  while node is not void
    output[index] = node.span
    index = index + 1
    node = node.next
  end while
  return output
end function

// Lexes presentation-only SQL spans without invoking the parser or changing text.
// The scanner deliberately colors incomplete input and therefore remains useful
// while the user is typing. Offsets are UTF-16 units expected by RichEdit.
function sqlSyntaxSpans(text)
  if typeof(text) != "string" then return fail("sqlSyntaxSpans", "text must be string") end if
  raw = bytes(text)
  spans = SqlSyntaxAccumulator(void, void, 0)
  keywords = dialect.keywordList()
  index = 0
  units = 0
  lineStart = true
  while index < len(raw)
    value = raw[index]
    nextValue = -1
    if index + 1 < len(raw) then nextValue = raw[index + 1] end if
    startByte = index
    startUnits = units
    if value == 45 and nextValue == 45 then
      index = index + 2
      units = units + 2
      while index < len(raw) and raw[index] != 10 and raw[index] != 13
        step = utf8Step(raw, index)
        index = index + step[0]
        units = units + step[1]
      end while
      appendSyntaxSpan(spans, startUnits, units, SQL_STYLE_COMMENT)
    else if value == 35 and lineStart then
      index = index + 1
      units = units + 1
      while index < len(raw) and raw[index] != 10 and raw[index] != 13
        step = utf8Step(raw, index)
        index = index + step[0]
        units = units + step[1]
      end while
      appendSyntaxSpan(spans, startUnits, units, SQL_STYLE_COMMENT)
    else if value == 47 and nextValue == 42 then
      index = index + 2
      units = units + 2
      while index < len(raw)
        if index + 1 < len(raw) and raw[index] == 42 and raw[index + 1] == 47 then index = index + 2; units = units + 2; break end if
        step = utf8Step(raw, index)
        index = index + step[0]
        units = units + step[1]
      end while
      appendSyntaxSpan(spans, startUnits, units, SQL_STYLE_COMMENT)
    else if value == 39 or value == 34 then
      quote = value
      index = index + 1
      units = units + 1
      closed = false
      while index < len(raw) and not closed
        if raw[index] == quote then
          if index + 1 < len(raw) and raw[index + 1] == quote then index = index + 2; units = units + 2 else index = index + 1; units = units + 1; closed = true end if
        else
          step = utf8Step(raw, index)
          index = index + step[0]
          units = units + step[1]
        end if
      end while
      kind = SQL_STYLE_STRING
      if quote == 34 then kind = SQL_STYLE_QUOTED_IDENTIFIER end if
      appendSyntaxSpan(spans, startUnits, units, kind)
      lineStart = false
    else if value >= 48 and value <= 57 then
      index = index + 1
      units = units + 1
      exponent = false
      while index < len(raw)
        current = raw[index]
        if current >= 48 and current <= 57 then index = index + 1; units = units + 1
        else if current == 46 then index = index + 1; units = units + 1
        else if not exponent and (current == 69 or current == 101) then
          exponent = true
          index = index + 1
          units = units + 1
          if index < len(raw) and (raw[index] == 43 or raw[index] == 45) then index = index + 1; units = units + 1 end if
        else break
        end if
      end while
      appendSyntaxSpan(spans, startUnits, units, SQL_STYLE_NUMBER)
      lineStart = false
    else if (value >= 65 and value <= 90) or (value >= 97 and value <= 122) or value == 95 then
      index = index + 1
      units = units + 1
      while index < len(raw)
        current = raw[index]
        if (current >= 65 and current <= 90) or (current >= 97 and current <= 122) or (current >= 48 and current <= 57) or current == 95 or current == 36 then index = index + 1; units = units + 1 else break end if
      end while
      word = decode(slice(raw, startByte, index - startByte))
      if typeof(word) == "string" and containsText(keywords, asciiUpper(word)) then appendSyntaxSpan(spans, startUnits, units, SQL_STYLE_KEYWORD) end if
      lineStart = false
    else
      step = utf8Step(raw, index)
      index = index + step[0]
      units = units + step[1]
      if value == 10 or value == 13 then lineStart = true else if value != 9 and value != 32 then lineStart = false end if
    end if
  end while
  return syntaxSpanArray(spans)
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

// Executes a generated mutation batch atomically, using a savepoint inside an existing transaction.
function executeAtomicSql(state, sqlText)
  if state is not FullClientState then return fail("executeAtomicSql", "state must be FullClientState") end if
  text = try(console.trimAscii(sqlText))
  if typeof(text) == "error" or len(text) == 0 then return fail("executeAtomicSql", "SQL text must be non-empty") end if
  statements = try(console.splitSqlStatements(text))
  if typeof(statements) == "error" then return statements end if
  if len(statements) == 0 then return fail("executeAtomicSql", "finish every generated statement with a semicolon") end if
  started = clock.monotonicMilliseconds()
  nested = state.transactionActive
  beginSql = "BEGIN;"
  finishSql = "COMMIT;"
  rollbackSql = "ROLLBACK;"
  if nested then beginSql = "SAVEPOINT minisql_workbench_apply;"; finishSql = "RELEASE SAVEPOINT minisql_workbench_apply;"; rollbackSql = "ROLLBACK TO SAVEPOINT minisql_workbench_apply;" end if
  opened = try(client.query(state.remoteClient, beginSql))
  if typeof(opened) == "error" then return opened end if
  if opened.status == constants.STATUS_ERROR then return responseFailure(opened, "executeAtomicSql") end if
  responses = []
  commandCount = 0
  rowCount = 0
  success = true
  lines = []
  for each statement in statements
    if success then
      response = try(client.query(state.remoteClient, statement))
      if typeof(response) == "error" then
        ignoredRollback = try(client.query(state.remoteClient, rollbackSql))
        if nested then ignoredRelease = try(client.query(state.remoteClient, finishSql)) end if
        return response
      end if
      responses = responses + [response]
      lines = lines + [renderResponse(response)]
      if response.status == constants.STATUS_ERROR then success = false end if
      if response.status == constants.STATUS_COMMAND then commandCount = commandCount + 1 end if
      if response.status == constants.STATUS_ROWS then rowCount = len(response.rows) end if
    end if
  end for
  if success then
    finished = try(client.query(state.remoteClient, finishSql))
    if typeof(finished) == "error" then return finished end if
    if finished.status == constants.STATUS_ERROR then
      success = false
      lines = lines + [renderResponse(finished)]
      ignoredFinishRollback = try(client.query(state.remoteClient, rollbackSql))
      if nested then ignoredFinishRelease = try(client.query(state.remoteClient, finishSql)) end if
    end if
  else
    ignoredRollback = try(client.query(state.remoteClient, rollbackSql))
    if nested then ignoredRelease = try(client.query(state.remoteClient, finishSql)) end if
  end if
  elapsed = clock.monotonicMilliseconds() - started
  view = QueryView(len(statements), commandCount, rowCount, success, lineJoin(lines))
  state.queryText = historySql(text)
  state.queryView = view
  ignoredTab = addResultTab(state, text, view, responses, elapsed)
  if success then state.statusText = "Applied " + len(statements) + " atomic change(s) in " + elapsed + " ms" else state.statusText = "Atomic change batch rolled back in " + elapsed + " ms" end if
  return view
end function

// Executes EXPLAIN for the editor selection.
function explainSql(state, sqlText)
  text = try(console.trimAscii(sqlText))
  if typeof(text) == "error" or len(text) == 0 then return fail("explainSql", "SQL text must be non-empty") end if
  statements = try(console.splitSqlStatements(text))
  if typeof(statements) == "error" then return statements end if
  if len(statements) != 1 then return fail("explainSql", "EXPLAIN requires exactly one selected statement") end if
  statement = statements[0]
  raw = bytes(statement)
  if len(raw) > 0 and raw[len(raw) - 1] == 59 then statement = decode(slice(raw, 0, len(raw) - 1)) end if
  return executeSql(state, "EXPLAIN " + statement + ";")
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
  quoted = try(quotedObjectName(tableName))
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

// Converts one successful row response into a native-grid model without formatting loss.
function detailGridFromResponse(response)
  if not messages.isResponse(response) or response.status != constants.STATUS_ROWS then return DetailGrid([], []) end if
  return DetailGrid(response.columns, response.rows)
end function

// Returns the structured object-detail grid for a page or void for textual pages.
function detailGridByName(state, name)
  if state is not FullClientState or typeof(name) != "string" then return void end if
  details = state.tableDetails
  if name == "Columns" then return details.columnsGrid end if
  if name == "Indexes" then return details.indexesGrid end if
  if name == "Data" then return details.contentsGrid end if
  if name == "Row Count" then return details.rowCountGrid end if
  return void
end function

// Finds one DESCRIBE row by exact column name.
function columnMetadata(details, columnName)
  if details is not TableDetails or typeof(columnName) != "string" then return void end if
  for each row in details.columnsGrid.rows
    if len(row) >= 6 and row[1] == columnName then return row end if
  end for
  return void
end function

// Finds a named preview column so key values can be read from a selected row.
function dataColumnIndex(details, columnName)
  if details is not TableDetails or typeof(columnName) != "string" then return -1 end if
  if len(details.contentsGrid.columns) > 0 then
    for index = 0 to len(details.contentsGrid.columns) - 1
      if details.contentsGrid.columns[index] == columnName then return index end if
    end for
  end if
  return -1
end function

// Returns whether a DESCRIBE type must be emitted as an unquoted numeric literal.
function numericColumnType(typeText)
  upper = dialect.asciiUpper(typeText)
  if typeof(upper) != "string" then return false end if
  return console.startsWithText(upper, "INT") or console.startsWithText(upper, "BIGINT") or console.startsWithText(upper, "SMALLINT") or console.startsWithText(upper, "DECIMAL") or console.startsWithText(upper, "NUMERIC") or console.startsWithText(upper, "REAL") or console.startsWithText(upper, "DOUBLE") or console.startsWithText(upper, "FLOAT")
end function

// Performs a conservative lexical check before passing a numeric literal to MiniSQL.
function numericEditorValue(value)
  if typeof(value) != "string" then return false end if
  trimmed = try(console.trimAscii(value))
  if typeof(trimmed) == "error" or len(trimmed) == 0 then return false end if
  raw = bytes(trimmed)
  index = 0
  if raw[index] == 43 or raw[index] == 45 then index = index + 1 end if
  digits = 0
  while index < len(raw) and raw[index] >= 48 and raw[index] <= 57
    digits = digits + 1
    index = index + 1
  end while
  if index < len(raw) and raw[index] == 46 then
    index = index + 1
    while index < len(raw) and raw[index] >= 48 and raw[index] <= 57
      digits = digits + 1
      index = index + 1
    end while
  end if
  if digits == 0 then return false end if
  if index < len(raw) and (raw[index] == 69 or raw[index] == 101) then
    index = index + 1
    if index < len(raw) and (raw[index] == 43 or raw[index] == 45) then index = index + 1 end if
    exponentDigits = 0
    while index < len(raw) and raw[index] >= 48 and raw[index] <= 57
      exponentDigits = exponentDigits + 1
      index = index + 1
    end while
    if exponentDigits == 0 then return false end if
  end if
  return index == len(raw)
end function

// Converts one row-editor value into a type-aware SQL literal.
function editorSqlLiteral(metadataRow, editorValue, allowDefault)
  if typeof(metadataRow) != "array" or len(metadataRow) < 6 or typeof(editorValue) != "string" then return fail("editorSqlLiteral", "invalid column metadata or value") end if
  if editorValue == "<DEFAULT>" then
    if allowDefault then return "<DEFAULT>" end if
    return fail("editorSqlLiteral", "DEFAULT is only available while inserting a row")
  end if
  if editorValue == "<NULL>" then
    if metadataRow[3] == "TRUE" then return "NULL" end if
    return fail("editorSqlLiteral", "column " + metadataRow[1] + " is NOT NULL")
  end if
  typeText = dialect.asciiUpper(metadataRow[2])
  if numericColumnType(metadataRow[2]) then
    trimmed = try(console.trimAscii(editorValue))
    if typeof(trimmed) == "error" or not numericEditorValue(trimmed) then return fail("editorSqlLiteral", "column " + metadataRow[1] + " requires a numeric value") end if
    return trimmed
  end if
  if console.startsWithText(typeText, "BOOL") then
    booleanText = dialect.asciiUpper(editorValue)
    if booleanText != "TRUE" and booleanText != "FALSE" then return fail("editorSqlLiteral", "column " + metadataRow[1] + " requires TRUE or FALSE") end if
    return booleanText
  end if
  return quotedTextLiteral(editorValue)
end function

// Splits the SHOW INDEXES comma-separated key column list into trimmed identifiers.
function splitIndexColumns(text)
  if typeof(text) != "string" then return [] end if
  raw = bytes(text)
  values = []
  start = 0
  index = 0
  while index <= len(raw)
    if index == len(raw) or raw[index] == 44 then
      part = ""
      if index > start then part = decode(slice(raw, start, index - start)) end if
      trimmed = try(console.trimAscii(part))
      if typeof(trimmed) == "string" and len(trimmed) > 0 then values = values + [trimmed] end if
      start = index + 1
    end if
    index = index + 1
  end while
  return values
end function

// Rejects statement separators and SQL comments from a user-entered SQL fragment.
function validatedSqlFragment(value, description, allowEmpty)
  if typeof(value) != "string" or typeof(description) != "string" or typeof(allowEmpty) != "bool" then return fail("validatedSqlFragment", "invalid fragment request") end if
  trimmed = try(console.trimAscii(value))
  if typeof(trimmed) == "error" then return trimmed end if
  if len(trimmed) == 0 then
    if allowEmpty then return "" end if
    return fail("validatedSqlFragment", description + " must be non-empty")
  end if
  if textContains(trimmed, ";") or textContains(trimmed, "--") or textContains(trimmed, "/*") or textContains(trimmed, "*/") then return fail("validatedSqlFragment", description + " must contain one SQL fragment without comments or semicolons") end if
  return trimmed
end function

// Constructs validated table-browser paging, filter, and ordering options.
function createDataBrowseOptions(filterText, sortColumn, ascending, page, pageSize)
  if typeof(filterText) != "string" or typeof(sortColumn) != "string" or typeof(ascending) != "bool" or typeof(page) != "int" or typeof(pageSize) != "int" then return fail("createDataBrowseOptions", "invalid data browser options") end if
  if page < 0 then return fail("createDataBrowseOptions", "page must be non-negative") end if
  if pageSize < 1 or pageSize > MAX_DATA_PAGE_SIZE then return fail("createDataBrowseOptions", "page size must be between 1 and " + MAX_DATA_PAGE_SIZE) end if
  checkedFilter = try(validatedSqlFragment(filterText, "WHERE filter", true))
  if typeof(checkedFilter) == "error" then return checkedFilter end if
  if len(sortColumn) > 0 then
    checkedSort = try(quotedIdentifier(sortColumn))
    if typeof(checkedSort) == "error" then return checkedSort end if
  end if
  return DataBrowseOptions(checkedFilter, sortColumn, ascending, page, pageSize)
end function

// Returns the default first-page data-browser options.
function defaultDataBrowseOptions()
  return DataBrowseOptions("", "", true, 0, DEFAULT_DATA_PAGE_SIZE)
end function

// Builds the bounded SELECT used by the editable table browser.
function dataSelectSql(tableName, options)
  if options is not DataBrowseOptions then return fail("dataSelectSql", "options must be DataBrowseOptions") end if
  tableSql = try(quotedObjectName(tableName))
  if typeof(tableSql) == "error" then return tableSql end if
  sqlText = "SELECT * FROM " + tableSql
  if len(options.filterText) > 0 then sqlText = sqlText + " WHERE " + options.filterText end if
  if len(options.sortColumn) > 0 then
    columnSql = try(quotedIdentifier(options.sortColumn))
    if typeof(columnSql) == "error" then return columnSql end if
    direction = " ASC"
    if not options.ascending then direction = " DESC" end if
    sqlText = sqlText + " ORDER BY " + columnSql + direction
  end if
  return sqlText + " LIMIT " + options.pageSize + " OFFSET " + (options.page * options.pageSize)
end function

// Builds the matching filtered row-count query used by pagination controls.
function dataCountSql(tableName, options)
  if options is not DataBrowseOptions then return fail("dataCountSql", "options must be DataBrowseOptions") end if
  tableSql = try(quotedObjectName(tableName))
  if typeof(tableSql) == "error" then return tableSql end if
  sqlText = "SELECT COUNT(*) AS row_count FROM " + tableSql
  if len(options.filterText) > 0 then sqlText = sqlText + " WHERE " + options.filterText end if
  return sqlText
end function

// Returns the schema-designer actions in stable native-list order.
function schemaActionLines()
  return ["Create table", "Add column", "Rename column", "Drop column", "Create index", "Drop index", "Add constraint", "Drop constraint", "Rename table", "Drop table"]
end function

// Quotes a comma-separated identifier list for CREATE INDEX generation.
function quotedColumnList(text)
  values = splitIndexColumns(text)
  if len(values) == 0 then return fail("quotedColumnList", "at least one column is required") end if
  output = ""
  for index = 0 to len(values) - 1
    quoted = try(quotedIdentifier(values[index]))
    if typeof(quoted) == "error" then return quoted end if
    if index > 0 then output = output + ", " end if
    output = output + quoted
  end for
  return output
end function

// Generates one previewable schema mutation from the structured designer fields.
function schemaEditorSql(action, tableName, objectName, definition, optionText)
  if typeof(action) != "int" or action < 0 or action >= len(schemaActionLines()) then return fail("schemaEditorSql", "schema action is invalid") end if
  if typeof(tableName) != "string" or typeof(objectName) != "string" or typeof(definition) != "string" or typeof(optionText) != "string" then return fail("schemaEditorSql", "schema fields must be strings") end if
  tableSql = ""
  if action != 5 then
    tableSql = try(quotedObjectName(tableName))
    if typeof(tableSql) == "error" then return tableSql end if
  end if
  if action == 0 then
    body = try(validatedSqlFragment(definition, "column definitions", false))
    if typeof(body) == "error" then return body end if
    return "CREATE TABLE " + tableSql + " (" + body + ");"
  end if
  if action == 1 then
    columnSql = try(quotedIdentifier(objectName))
    if typeof(columnSql) == "error" then return columnSql end if
    body = try(validatedSqlFragment(definition, "column definition", false))
    if typeof(body) == "error" then return body end if
    return "ALTER TABLE " + tableSql + " ADD COLUMN " + columnSql + " " + body + ";"
  end if
  if action == 2 then
    oldSql = try(quotedIdentifier(objectName))
    if typeof(oldSql) == "error" then return oldSql end if
    newSql = try(quotedIdentifier(optionText))
    if typeof(newSql) == "error" then return newSql end if
    return "ALTER TABLE " + tableSql + " RENAME COLUMN " + oldSql + " TO " + newSql + ";"
  end if
  if action == 3 then
    columnSql = try(quotedIdentifier(objectName))
    if typeof(columnSql) == "error" then return columnSql end if
    return "ALTER TABLE " + tableSql + " DROP COLUMN " + columnSql + ";"
  end if
  if action == 4 then
    indexSql = try(quotedObjectName(objectName))
    if typeof(indexSql) == "error" then return indexSql end if
    columnsSql = try(quotedColumnList(definition))
    if typeof(columnsSql) == "error" then return columnsSql end if
    uniqueText = ""
    if asciiUpper(try(console.trimAscii(optionText))) == "UNIQUE" then uniqueText = "UNIQUE " end if
    return "CREATE " + uniqueText + "INDEX " + indexSql + " ON " + tableSql + " (" + columnsSql + ");"
  end if
  if action == 5 then
    indexSql = try(quotedObjectName(objectName))
    if typeof(indexSql) == "error" then return indexSql end if
    return "DROP INDEX " + indexSql + ";"
  end if
  if action == 6 then
    constraintSql = try(quotedIdentifier(objectName))
    if typeof(constraintSql) == "error" then return constraintSql end if
    body = try(validatedSqlFragment(definition, "constraint definition", false))
    if typeof(body) == "error" then return body end if
    return "ALTER TABLE " + tableSql + " ADD CONSTRAINT " + constraintSql + " " + body + ";"
  end if
  if action == 7 then
    constraintSql = try(quotedIdentifier(objectName))
    if typeof(constraintSql) == "error" then return constraintSql end if
    return "ALTER TABLE " + tableSql + " DROP CONSTRAINT " + constraintSql + ";"
  end if
  if action == 8 then
    newTableSql = try(quotedIdentifier(optionText))
    if typeof(newTableSql) == "error" then return newTableSql end if
    return "ALTER TABLE " + tableSql + " RENAME TO " + newTableSql + ";"
  end if
  return "DROP TABLE " + tableSql + ";"
end function

// Selects a primary key, or the first unique key, for safe single-row mutations.
function editableKeyColumns(details)
  if details is not TableDetails then return [] end if
  uniqueColumns = []
  for each row in details.indexesGrid.rows
    if len(row) >= 4 then
      if row[1] == "PRIMARY KEY" then return splitIndexColumns(row[3]) end if
      if len(uniqueColumns) == 0 and row[2] == "TRUE" then uniqueColumns = splitIndexColumns(row[3]) end if
    end if
  end for
  return uniqueColumns
end function

// Converts one preview value back into the explicit row-editor sentinel form.
function editorValueFromData(metadataRow, value)
  if value == "NULL" and len(metadataRow) >= 4 and metadataRow[3] == "TRUE" then return "<NULL>" end if
  return value
end function

// Creates initial editor values for a new, copied, or existing preview row.
function dataEditorValues(details, rowIndex, duplicate)
  if details is not TableDetails or typeof(rowIndex) != "int" or typeof(duplicate) != "bool" then return fail("dataEditorValues", "invalid row-editor request") end if
  existing = rowIndex >= 0 and rowIndex < len(details.contentsGrid.rows)
  if rowIndex >= 0 and not existing then return fail("dataEditorValues", "selected preview row is out of range") end if
  values = []
  for each metadataRow in details.columnsGrid.rows
    if len(metadataRow) < 6 then return fail("dataEditorValues", "DESCRIBE returned malformed metadata") end if
    value = ""
    dataIndex = dataColumnIndex(details, metadataRow[1])
    if existing and dataIndex >= 0 and dataIndex < len(details.contentsGrid.rows[rowIndex]) then
      value = editorValueFromData(metadataRow, details.contentsGrid.rows[rowIndex][dataIndex])
      if duplicate and metadataRow[5] == "TRUE" then value = "<DEFAULT>" end if
    else if metadataRow[5] == "TRUE" or metadataRow[4] != "NULL" then
      value = "<DEFAULT>"
    else if metadataRow[3] == "TRUE" then
      value = "<NULL>"
    else if numericColumnType(metadataRow[2]) then
      value = "0"
    else if console.startsWithText(dialect.asciiUpper(metadataRow[2]), "BOOL") then
      value = "FALSE"
    end if
    values = values + [value]
  end for
  return values
end function

// Builds the stable key predicate used by UPDATE and DELETE from original row values.
function dataRowPredicate(details, originalRow)
  if details is not TableDetails or typeof(originalRow) != "array" then return fail("dataRowPredicate", "invalid selected row") end if
  keys = editableKeyColumns(details)
  if len(keys) == 0 then return fail("dataRowPredicate", "editing requires a PRIMARY KEY or UNIQUE index") end if
  predicate = ""
  for index = 0 to len(keys) - 1
    metadataRow = columnMetadata(details, keys[index])
    dataIndex = dataColumnIndex(details, keys[index])
    if metadataRow is void or dataIndex < 0 or dataIndex >= len(originalRow) then return fail("dataRowPredicate", "key column " + keys[index] + " is missing from the preview") end if
    editorValue = editorValueFromData(metadataRow, originalRow[dataIndex])
    literal = try(editorSqlLiteral(metadataRow, editorValue, false))
    if typeof(literal) == "error" then return literal end if
    quoted = try(quotedIdentifier(keys[index]))
    if typeof(quoted) == "error" then return quoted end if
    if index > 0 then predicate = predicate + " AND " end if
    if literal == "NULL" then return fail("dataRowPredicate", "nullable UNIQUE key column " + keys[index] + " cannot safely identify one row") end if
    predicate = predicate + quoted + " = " + literal
  end for
  return predicate
end function

// Generates an INSERT statement while omitting identity/default sentinel fields.
function insertDataSql(details, values)
  if details is not TableDetails or typeof(values) != "array" or len(values) != len(details.columnsGrid.rows) then return fail("insertDataSql", "row values do not match table columns") end if
  columnsSql = ""
  valuesSql = ""
  included = 0
  for index = 0 to len(values) - 1
    metadataRow = details.columnsGrid.rows[index]
    literal = try(editorSqlLiteral(metadataRow, values[index], true))
    if typeof(literal) == "error" then return literal end if
    if literal != "<DEFAULT>" then
      quoted = try(quotedIdentifier(metadataRow[1]))
      if typeof(quoted) == "error" then return quoted end if
      if included > 0 then columnsSql = columnsSql + ", "; valuesSql = valuesSql + ", " end if
      columnsSql = columnsSql + quoted
      valuesSql = valuesSql + literal
      included = included + 1
    end if
  end for
  if included == 0 then return fail("insertDataSql", "at least one non-default value is required") end if
  tableSql = try(quotedObjectName(details.tableName))
  if typeof(tableSql) == "error" then return tableSql end if
  return "INSERT INTO " + tableSql + " (" + columnsSql + ") VALUES (" + valuesSql + ");"
end function

// Generates a key-constrained UPDATE statement for a selected preview row.
function updateDataSql(details, originalRow, values)
  if details is not TableDetails or typeof(values) != "array" or len(values) != len(details.columnsGrid.rows) then return fail("updateDataSql", "row values do not match table columns") end if
  assignments = ""
  count = 0
  for index = 0 to len(values) - 1
    metadataRow = details.columnsGrid.rows[index]
    if len(metadataRow) < 6 then return fail("updateDataSql", "DESCRIBE returned malformed metadata") end if
    dataIndex = dataColumnIndex(details, metadataRow[1])
    originalValue = ""
    if dataIndex >= 0 and dataIndex < len(originalRow) then originalValue = editorValueFromData(metadataRow, originalRow[dataIndex]) end if
    if metadataRow[5] != "TRUE" and values[index] != originalValue then
      literal = try(editorSqlLiteral(metadataRow, values[index], false))
      if typeof(literal) == "error" then return literal end if
      quoted = try(quotedIdentifier(metadataRow[1]))
      if typeof(quoted) == "error" then return quoted end if
      if count > 0 then assignments = assignments + ", " end if
      assignments = assignments + quoted + " = " + literal
      count = count + 1
    end if
  end for
  if count == 0 then return fail("updateDataSql", "table has no editable non-identity columns") end if
  predicate = try(dataRowPredicate(details, originalRow))
  if typeof(predicate) == "error" then return predicate end if
  tableSql = try(quotedObjectName(details.tableName))
  if typeof(tableSql) == "error" then return tableSql end if
  return "UPDATE " + tableSql + " SET " + assignments + " WHERE " + predicate + ";"
end function

// Generates a key-constrained DELETE statement for a selected preview row.
function deleteDataSql(details, originalRow)
  predicate = try(dataRowPredicate(details, originalRow))
  if typeof(predicate) == "error" then return predicate end if
  tableSql = try(quotedObjectName(details.tableName))
  if typeof(tableSql) == "error" then return tableSql end if
  return "DELETE FROM " + tableSql + " WHERE " + predicate + ";"
end function

// Creates one validated pending row change for preview and deferred application.
function pendingDataChange(kind, sqlText, rowIndex, values)
  upper = asciiUpper(kind)
  if upper != "INSERT" and upper != "UPDATE" and upper != "DELETE" then return fail("pendingDataChange", "change kind must be INSERT, UPDATE, or DELETE") end if
  if typeof(sqlText) != "string" or len(sqlText) == 0 or typeof(rowIndex) != "int" or typeof(values) != "array" then return fail("pendingDataChange", "invalid pending change") end if
  if upper == "INSERT" and rowIndex != -1 then return fail("pendingDataChange", "inserts must use row index -1") end if
  if upper != "INSERT" and rowIndex < 0 then return fail("pendingDataChange", "updates and deletes require a source row") end if
  return PendingDataChange(upper, sqlText, rowIndex, values)
end function

// Converts editor sentinels into the text shown by the optimistic data grid.
function previewEditorValue(value)
  if value == "<NULL>" then return "NULL" end if
  if value == "<DEFAULT>" then return "DEFAULT" end if
  return value
end function

// Aligns DESCRIBE-ordered editor values with SELECT result-column order.
function previewRowFromValues(details, values)
  if details is not TableDetails or typeof(values) != "array" or len(values) != len(details.columnsGrid.rows) then return fail("previewRowFromValues", "editor values do not match table metadata") end if
  row = []
  for each columnName in details.contentsGrid.columns
    matched = false
    for metadataIndex = 0 to len(details.columnsGrid.rows) - 1
      metadata = details.columnsGrid.rows[metadataIndex]
      if len(metadata) >= 2 and metadata[1] == columnName then row = row + [previewEditorValue(values[metadataIndex])]; matched = true end if
    end for
    if not matched then row = row + [""] end if
  end for
  return row
end function

// Builds an optimistic Data-page grid with explicit pending-change markers.
function dataGridWithChanges(details, changes)
  if details is not TableDetails or typeof(changes) != "array" then return DetailGrid([], []) end if
  columns = ["change"] + details.contentsGrid.columns
  rows = []
  if len(details.contentsGrid.rows) > 0 then
    for rowIndex = 0 to len(details.contentsGrid.rows) - 1
      marker = ""
      values = details.contentsGrid.rows[rowIndex]
      for each change in changes
        if change is PendingDataChange and change.rowIndex == rowIndex then
          marker = change.kind
          if change.kind == "UPDATE" and len(change.values) > 0 then
            preview = try(previewRowFromValues(details, change.values))
            if typeof(preview) == "array" then values = preview end if
          end if
        end if
      end for
      rows = rows + [[marker] + values]
    end for
  end if
  for each change in changes
    if change is PendingDataChange and change.kind == "INSERT" then
      preview = try(previewRowFromValues(details, change.values))
      if typeof(preview) == "array" then rows = rows + [["INSERT"] + preview] end if
    end if
  end for
  return DetailGrid(columns, rows)
end function

// Joins pending statements into the exact SQL preview submitted by Apply Changes.
function pendingDataSql(changes)
  if typeof(changes) != "array" then return fail("pendingDataSql", "changes must be an array") end if
  output = ""
  for each change in changes
    if change is not PendingDataChange then return fail("pendingDataSql", "changes contain an invalid item") end if
    if len(output) > 0 then output = output + "\r\n" end if
    output = output + change.sqlText
  end for
  return output
end function

// Escapes one cell for RFC 4180-compatible UTF-8 CSV output.
function csvField(value)
  if typeof(value) != "string" then return fail("csvField", "cell value must be a string") end if
  output = bytes([34])
  for each item in bytes(value)
    output = output + bytes([item])
    if item == 34 then output = output + bytes([34]) end if
  end for
  output = output + bytes([34])
  text = decode(output)
  if typeof(text) != "string" then return fail("csvField", "cell is not valid UTF-8") end if
  return text
end function

// Serializes a structured grid as deterministic CRLF-terminated CSV.
function gridCsv(grid)
  if grid is not DetailGrid then return fail("gridCsv", "grid must be DetailGrid") end if
  output = ""
  rows = [grid.columns] + grid.rows
  for rowIndex = 0 to len(rows) - 1
    row = rows[rowIndex]
    for columnIndex = 0 to len(row) - 1
      if columnIndex > 0 then output = output + "," end if
      output = output + try(csvField(row[columnIndex]))
    end for
    output = output + "\r\n"
  end for
  return output
end function

// Escapes tabs, line endings, and backslashes for lossless clipboard TSV.
function clipboardField(value)
  if typeof(value) != "string" then return fail("clipboardField", "cell value must be a string") end if
  output = bytes(0)
  for each item in bytes(value)
    if item == 92 then output = output + bytes("\\\\")
    else if item == 9 then output = output + bytes("\\t")
    else if item == 13 then output = output + bytes("\\r")
    else if item == 10 then output = output + bytes("\\n")
    else output = output + bytes([item])
    end if
  end for
  text = decode(output)
  if typeof(text) != "string" then return fail("clipboardField", "cell is not valid UTF-8") end if
  return text
end function

// Serializes selected grid rows as escaped tab-separated clipboard text.
function gridClipboardText(grid, selectedRows, includeHeader)
  if grid is not DetailGrid or typeof(selectedRows) != "array" or typeof(includeHeader) != "bool" then return fail("gridClipboardText", "invalid clipboard selection") end if
  outputRows = []
  if includeHeader then outputRows = outputRows + [grid.columns] end if
  for each rowIndex in selectedRows
    if typeof(rowIndex) != "int" or rowIndex < 0 or rowIndex >= len(grid.rows) then return fail("gridClipboardText", "selected row is out of range") end if
    outputRows = outputRows + [grid.rows[rowIndex]]
  end for
  output = ""
  for rowIndex = 0 to len(outputRows) - 1
    row = outputRows[rowIndex]
    for columnIndex = 0 to len(row) - 1
      if columnIndex > 0 then output = output + "\t" end if
      output = output + try(clipboardField(row[columnIndex]))
    end for
    if rowIndex + 1 < len(outputRows) then output = output + "\r\n" end if
  end for
  return output
end function

// Decodes one escaped clipboard field without interpreting SQL syntax.
function decodeClipboardField(raw)
  if typeof(raw) != "bytes" then return fail("decodeClipboardField", "field must be bytes") end if
  output = bytes(0)
  index = 0
  while index < len(raw)
    item = raw[index]
    if item == 92 and index + 1 < len(raw) then
      next = raw[index + 1]
      if next == 116 then output = output + bytes([9]); index = index + 2
      else if next == 114 then output = output + bytes([13]); index = index + 2
      else if next == 110 then output = output + bytes([10]); index = index + 2
      else if next == 92 then output = output + bytes([92]); index = index + 2
      else output = output + bytes([item]); index = index + 1
      end if
    else
      output = output + bytes([item])
      index = index + 1
    end if
  end while
  text = decode(output)
  if typeof(text) != "string" then return fail("decodeClipboardField", "clipboard field is not valid UTF-8") end if
  return text
end function

// Parses escaped TSV clipboard rows into a rectangular array.
function parseClipboardRows(text)
  if typeof(text) != "string" then return fail("parseClipboardRows", "clipboard text must be a string") end if
  raw = bytes(text)
  rows = []
  row = []
  start = 0
  index = 0
  while index <= len(raw)
    boundary = index == len(raw) or raw[index] == 9 or raw[index] == 10 or raw[index] == 13
    if boundary then
      field = try(decodeClipboardField(slice(raw, start, index - start)))
      if typeof(field) == "error" then return field end if
      row = row + [field]
      lineEnd = index == len(raw) or raw[index] == 10 or raw[index] == 13
      if lineEnd then
        if len(row) > 1 or len(row[0]) > 0 then rows = rows + [row] end if
        row = []
        if index < len(raw) and raw[index] == 13 and index + 1 < len(raw) and raw[index + 1] == 10 then index = index + 1 end if
      end if
      start = index + 1
    end if
    index = index + 1
  end while
  if len(rows) == 0 then return fail("parseClipboardRows", "clipboard contains no rows") end if
  width = len(rows[0])
  for each parsedRow in rows
    if len(parsedRow) != width then return fail("parseClipboardRows", "clipboard rows have different column counts") end if
  end for
  return rows
end function

// Filters redacted worksheet history case-insensitively for the sidebar search box.
function filterHistory(history, searchText)
  if typeof(history) != "array" or typeof(searchText) != "string" then return [] end if
  wanted = asciiUpper(try(console.trimAscii(searchText)))
  if len(wanted) == 0 then return history end if
  output = []
  for each item in history
    if textContains(asciiUpper(item), wanted) then output = output + [item] end if
  end for
  return output
end function

// Creates a sequentially named independent SQL worksheet.
function newWorksheet(index, sqlText)
  if typeof(index) != "int" or index < 1 or typeof(sqlText) != "string" then return fail("newWorksheet", "invalid worksheet") end if
  return Worksheet("SQL " + index, sqlText)
end function

// Returns stable worksheet labels for the native tab strip.
function worksheetLines(worksheets)
  lines = []
  for each worksheet in worksheets
    if worksheet is Worksheet then lines = lines + [worksheet.title] end if
  end for
  return lines
end function

// Loads a filtered, ordered, and paginated set of detail pages for one table.
function describeTableView(state, tableName, options)
  if options is not DataBrowseOptions then return fail("describeTableView", "options must be DataBrowseOptions") end if
  quoted = try(quotedObjectName(tableName))
  if typeof(quoted) == "error" then return quoted end if
  columns = try(queryOne(state, "DESCRIBE " + quoted))
  if typeof(columns) == "error" then return columns end if
  indexes = try(queryOne(state, "SHOW INDEXES FROM " + quoted))
  if typeof(indexes) == "error" then return indexes end if
  selectSql = try(dataSelectSql(tableName, options))
  if typeof(selectSql) == "error" then return selectSql end if
  contents = try(queryOne(state, selectSql))
  if typeof(contents) == "error" then return contents end if
  countSql = try(dataCountSql(tableName, options))
  if typeof(countSql) == "error" then return countSql end if
  rowCount = try(queryOne(state, countSql))
  if typeof(rowCount) == "error" then return rowCount end if
  summary = "Table: " + tableName + "\r\nColumns: " + len(columns.rows) + "\r\nIndexes: " + len(indexes.rows) + "\r\nPage: " + (options.page + 1) + "\r\nPage rows: " + len(contents.rows)
  details = TableDetails(tableName, summary, renderResponse(columns), renderResponse(indexes), renderResponse(contents), renderResponse(rowCount), ddlFromDescribe(tableName, columns), detailGridFromResponse(columns), detailGridFromResponse(indexes), detailGridFromResponse(contents), detailGridFromResponse(rowCount))
  state.selectedTable = tableName
  state.tableDetails = details
  state.statusText = "Loaded metadata for table " + tableName
  return details
end function

// Loads the default first page while preserving the original public API.
function describeTable(state, tableName)
  return describeTableView(state, tableName, defaultDataBrowseOptions())
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
        quoted = try(quotedObjectName(state.selectedTable))
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
  quoted = try(quotedObjectName(tableName))
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
