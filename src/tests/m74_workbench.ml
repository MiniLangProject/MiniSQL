// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.admin.connection_profiles as profiles
import minisql.admin.fullclient as fullclient
import minisql.admin.win32_client as win32_client
import minisql.platform.file as file_api
import minisql.platform.win32_gui as gui
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages
import tests.support.testkit as testkit

// Returns whether the presentation lexer emitted at least one requested style.
function hasSyntaxKind(spans, wanted)
  for each span in spans
    if span.kind == wanted then return true end if
  end for
  return false
end function

// Runs model, profile-store, and hidden native-control coverage for the MiniSQL Workbench.
function main(args)
  if len(args) != 1 then print "MiniSQL M74 workbench tests: FAIL args"; return 2 end if
  state = testkit.create()
  plain = fullclient.createProfile("Development", "127.0.0.1", 7432, "localhost", "shop", "admin", false, "", false)
  pinned = fullclient.createProfile("Pinned TLS", "shop.example.test", 7433, "shop.example.test", "shop", "operator", true, "AA:BB:CC", false)
  unicode = fullclient.createProfile("Produktion München", "127.0.0.1", 7434, "localhost", "geschäft", "admin", false, "", false)
  trusted = profiles.defaultProfile()
  testkit.equal(state, fullclient.endpointText(plain), "tcp://127.0.0.1:7432/shop", "plain endpoint text")
  testkit.record(state, pinned.tls and len(pinned.pinSha256) > 0, "TLS pin retained in alias")
  testkit.record(state, trusted.trustedLocal and not trusted.tls, "first-run alias uses trusted local mode")
  testkit.errorCode(state, try(fullclient.createProfile("Bad", "remote.example", 7432, "remote.example", "main", "", false, "", true)), 9001, "trusted local rejects remote address")
  testkit.errorCode(state, try(fullclient.createProfile("Bad Pin", "127.0.0.1", 7432, "localhost", "main", "admin", false, "AA", false)), 9001, "pin requires TLS")
  testkit.equal(state, len(fullclient.defaultBookmarks()), 8, "built-in MiniSQL bookmark count")
  testkit.equal(state, fullclient.quotedIdentifier("Bestellung \"München\""), "\"Bestellung \"\"München\"\"\"", "Unicode and quotes are safe in generated metadata SQL")
  testkit.equal(state, profiles.escape(decode(bytes([1]))), "\\u0001", "profile JSON escapes uncommon control bytes")

  profilePath = file_api.joinPath(args[0], "workbench-profiles.json")
  saved = try(profiles.save(profilePath, [plain, pinned, trusted, unicode]))
  testkit.record(state, typeof(saved) != "error" and saved, "profiles save atomically")
  testkit.record(state, not file_api.fileExists(profilePath + ".new"), "atomic profile save leaves no temporary sibling")
  loaded = profiles.load(profilePath)
  testkit.equal(state, len(loaded), 4, "profiles roundtrip")
  if len(loaded) == 4 then
    testkit.equal(state, loaded[1].pinSha256, "AA:BB:CC", "certificate pin roundtrip")
    testkit.record(state, loaded[2].trustedLocal, "trusted-local flag roundtrip")
    testkit.equal(state, loaded[3].name, "Produktion München", "Unicode alias roundtrip")
    testkit.equal(state, loaded[3].databaseName, "geschäft", "Unicode database label roundtrip")
  else
    testkit.record(state, false, "certificate pin roundtrip")
    testkit.record(state, false, "trusted-local flag roundtrip")
    testkit.record(state, false, "Unicode alias roundtrip")
    testkit.record(state, false, "Unicode database label roundtrip")
  end if
  raw = file_api.readAllText(profilePath, 1048576)
  testkit.record(state, not fullclient.textContains(raw, "password"), "profile file contains no password field")
  spacedSecret = "CREATE USER alice WITH /* policy */\r\n PASSWORD 'never-store-this';"
  redacted = fullclient.historySql(spacedSecret)
  testkit.record(state, fullclient.textContains(redacted, "redacted") and not fullclient.textContains(redacted, "never-store-this"), "DCL redaction tolerates comments and whitespace")
  malformed = messages.Response(constants.STATUS_ROWS, "DESCRIBE", ["ordinal"], [["0"]], 0, "", 0)
  testkit.record(state, fullclient.textContains(fullclient.ddlFromDescribe("example", malformed), "Invalid DESCRIBE response"), "malformed metadata cannot crash DDL rendering")

  columnGrid = fullclient.DetailGrid(
    ["ordinal", "column_name", "data_type", "nullable", "default_sql", "identity"],
    [["0", "id", "INTEGER", "FALSE", "NULL", "TRUE"], ["1", "code", "VARCHAR(80)", "FALSE", "NULL", "FALSE"], ["2", "note", "VARCHAR(120)", "TRUE", "NULL", "FALSE"], ["3", "active", "BOOLEAN", "FALSE", "TRUE", "FALSE"], ["4", "amount", "DECIMAL(10,2)", "FALSE", "0", "FALSE"]]
  )
  indexGrid = fullclient.DetailGrid(["index_name", "index_kind", "unique", "columns"], [["pk_shop_item", "PRIMARY KEY", "TRUE", "id"]])
  dataGrid = fullclient.DetailGrid(["id", "code", "note", "active", "amount"], [["7", "O'Reilly", "NULL", "TRUE", "3.30"]])
  countGrid = fullclient.DetailGrid(["row_count"], [["1"]])
  editableDetails = fullclient.TableDetails("shop_item", "", "", "", "", "", "", columnGrid, indexGrid, dataGrid, countGrid)
  insertSql = fullclient.insertDataSql(editableDetails, ["<DEFAULT>", "new's", "<NULL>", "FALSE", "2.50"])
  testkit.equal(state, insertSql, "INSERT INTO \"shop_item\" (\"code\", \"note\", \"active\", \"amount\") VALUES ('new''s', NULL, FALSE, 2.50);", "row editor builds escaped typed INSERT SQL")
  updateSql = fullclient.updateDataSql(editableDetails, dataGrid.rows[0], ["7", "updated", "memo", "FALSE", "9.75"])
  testkit.equal(state, updateSql, "UPDATE \"shop_item\" SET \"code\" = 'updated', \"note\" = 'memo', \"active\" = FALSE, \"amount\" = 9.75 WHERE \"id\" = 7;", "row editor builds primary-key constrained UPDATE SQL")
  testkit.errorCode(state, try(fullclient.updateDataSql(editableDetails, dataGrid.rows[0], ["7", "O'Reilly", "<NULL>", "TRUE", "3.30"])), 9001, "unchanged row edit does not issue a destructive no-op")
  testkit.errorCode(state, try(fullclient.insertDataSql(editableDetails, ["<DEFAULT>", "bad numeric", "<NULL>", "TRUE", "1e++2"])), 9001, "invalid numeric editor input is rejected before SQL execution")
  deleteSql = fullclient.deleteDataSql(editableDetails, dataGrid.rows[0])
  testkit.equal(state, deleteSql, "DELETE FROM \"shop_item\" WHERE \"id\" = 7;", "row editor builds primary-key constrained DELETE SQL")
  copiedValues = fullclient.dataEditorValues(editableDetails, 0, true)
  testkit.record(state, typeof(copiedValues) == "array" and copiedValues[0] == "<DEFAULT>" and copiedValues[1] == "O'Reilly" and copiedValues[2] == "<NULL>", "duplicate-row draft clears identity and preserves nullable data")
  unkeyedDetails = fullclient.TableDetails("unkeyed", "", "", "", "", "", "", columnGrid, fullclient.DetailGrid([], []), dataGrid, countGrid)
  testkit.errorCode(state, try(fullclient.deleteDataSql(unkeyedDetails, dataGrid.rows[0])), 9001, "unsafe delete without a key is rejected")
  rowWindow = try(win32_client.createRowEditorWindow(editableDetails, false, false))
  testkit.record(state, typeof(rowWindow) != "error", "native row editor constructs for arbitrary table columns")
  if typeof(rowWindow) != "error" then
    rowState = win32_client.RowEditorState(rowWindow, editableDetails, copiedValues, 0, 0, false, void)
    rowRendered = try(win32_client.renderRowEditor(rowState))
    testkit.record(state, typeof(rowRendered) != "error" and gui.listViewRowCount(rowWindow.valuesGrid) == 5, "row editor renders every field in a structured review grid")
    ignoredRowResize = try(gui.setClientSizeDip(rowWindow.hwnd, 900, 650, true))
    rowLayout = try(win32_client.layoutRowEditor(rowWindow))
    rowClient = try(gui.clientSizeDip(rowWindow.hwnd))
    rowGridRect = try(gui.controlRectDip(rowWindow.hwnd, rowWindow.valuesGrid))
    rowValueRect = try(gui.controlRectDip(rowWindow.hwnd, rowWindow.valueEdit))
    testkit.record(state, typeof(rowLayout) != "error" and typeof(rowClient) == "array" and typeof(rowGridRect) == "array" and typeof(rowValueRect) == "array" and win32_client.rectangleInside(rowGridRect, rowClient[0], rowClient[1]) and win32_client.rectangleInside(rowValueRect, rowClient[0], rowClient[1]) and not win32_client.rectanglesOverlap(rowGridRect, rowValueRect), "row editor grids and fields reflow without overlap")
    gui.destroy(rowWindow.hwnd)
  end if

  editorScript = "SELECT 'a;b';\r\nUPDATE item SET label = 'München' WHERE id = 1;\r\n"
  testkit.equal(state, fullclient.editorSqlForExecution(editorScript, 3, 3, false), "SELECT 'a;b';", "collapsed caret selects its semicolon-aware statement")
  updateStart = fullclient.utf16Length("SELECT 'a;b';\r\n")
  updateEnd = fullclient.utf16Length(editorScript) - 2
  testkit.equal(state, fullclient.editorSqlForExecution(editorScript, updateStart, updateEnd, false), "UPDATE item SET label = 'München' WHERE id = 1;", "explicit Unicode selection is executed exactly")
  testkit.equal(state, fullclient.editorSqlForExecution(editorScript, fullclient.utf16Length(editorScript), fullclient.utf16Length(editorScript), false), "UPDATE item SET label = 'München' WHERE id = 1;", "caret after final delimiter selects preceding statement")
  testkit.equal(state, fullclient.editorSqlForExecution(editorScript, 0, 0, true), "SELECT 'a;b';\r\nUPDATE item SET label = 'München' WHERE id = 1;", "script mode retains every statement")
  supplementaryScript = "SELECT '😀';\r\nSELECT 2;"
  supplementaryStart = fullclient.utf16Length("SELECT '😀';\r\n")
  testkit.equal(state, fullclient.editorSqlForExecution(supplementaryScript, supplementaryStart, fullclient.utf16Length(supplementaryScript), false), "SELECT 2;", "UTF-16 selection handles supplementary characters")
  syntax = fullclient.sqlSyntaxSpans("-- note\r\nSELECT \"Order\", 'x;😀', 1.5e2;")
  testkit.record(state, hasSyntaxKind(syntax, fullclient.SQL_STYLE_COMMENT), "presentation lexer recognizes comments")
  testkit.record(state, hasSyntaxKind(syntax, fullclient.SQL_STYLE_KEYWORD), "presentation lexer recognizes MiniSQL keywords")
  testkit.record(state, hasSyntaxKind(syntax, fullclient.SQL_STYLE_QUOTED_IDENTIFIER), "presentation lexer recognizes quoted identifiers")
  testkit.record(state, hasSyntaxKind(syntax, fullclient.SQL_STYLE_STRING), "presentation lexer recognizes strings containing semicolons")
  testkit.record(state, hasSyntaxKind(syntax, fullclient.SQL_STYLE_NUMBER), "presentation lexer recognizes numeric literals")
  highlightPattern = bytes("SELECT 1; ")
  largeHighlightBytes = bytes(len(highlightPattern) * 4000, 0)
  for repetition = 0 to 3999
    for patternIndex = 0 to len(highlightPattern) - 1
      largeHighlightBytes[repetition * len(highlightPattern) + patternIndex] = highlightPattern[patternIndex]
    end for
  end for
  largeHighlightText = decode(largeHighlightBytes)
  largeHighlightSpans = fullclient.sqlSyntaxSpans(largeHighlightText)
  testkit.equal(state, len(largeHighlightSpans), 8000, "large worksheet highlighting collects spans linearly")

  smoke = try(gui.hiddenWindowSmoke())
  testkit.record(state, typeof(smoke) != "error" and smoke, "custom Win32 top-level smoke")
  window = try(win32_client.createWindow(false))
  if typeof(window) == "error" then print window.message end if
  testkit.record(state, typeof(window) != "error", "SQuirreL-style workbench controls construct")
  if typeof(window) != "error" then
    testkit.record(state, window.objectTree != 0 and window.queryEdit != 0 and window.resultGrid != 0 and window.detailGrid != 0 and window.dataAddButton != 0, "object tree worksheet and editable detail grids exist")
    testkit.equal(state, gui.tabSelectedIndex(window.workspaceTabs), 0, "SQL worksheet is default workspace")
    largeEditorText = decode(bytes(40000, 65))
    ignoredLargeText = try(gui.setText(window.queryEdit, largeEditorText))
    readLargeText = try(gui.getText(window.queryEdit))
    if typeof(readLargeText) != "string" then print readLargeText.message else if len(bytes(readLargeText)) != 40000 then print "large SQL editor roundtrip bytes=" + len(bytes(readLargeText)) end if
    testkit.record(state, typeof(readLargeText) == "string" and len(bytes(readLargeText)) == 40000, "SQL editor text is not capped at 32 KiB")
    gui.destroy(window.hwnd)
  end if
  manager = try(win32_client.connectionManagerSmoke(profilePath))
  testkit.record(state, typeof(manager) != "error" and manager, "connection manager hidden smoke")
  connectionLayout = try(win32_client.connectionLayoutSmoke(profilePath))
  if typeof(connectionLayout) == "error" then print connectionLayout.message end if
  testkit.record(state, typeof(connectionLayout) != "error" and connectionLayout, "connection manager resizes and accepts editor, checkbox, and button input")
  workbenchLayout = try(win32_client.workbenchLayoutSmoke())
  if typeof(workbenchLayout) == "error" then print workbenchLayout.message end if
  testkit.record(state, typeof(workbenchLayout) != "error" and workbenchLayout, "workbench compact and wide layouts remain non-overlapping and interactive")
  return testkit.finish(state, "MiniSQL M74 workbench tests: SUCCESS", "MiniSQL M74 workbench tests: FAIL")
end function
