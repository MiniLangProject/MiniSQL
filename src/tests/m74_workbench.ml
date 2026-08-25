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
  testkit.equal(state, fullclient.quotedObjectName("shop.product"), "\"shop\".\"product\"", "qualified object names quote schema and object independently")
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
  pageOptions = fullclient.createDataBrowseOptions("active = TRUE", "code", false, 2, 50)
  testkit.equal(state, fullclient.dataSelectSql("shop.shop_item", pageOptions), "SELECT * FROM \"shop\".\"shop_item\" WHERE active = TRUE ORDER BY \"code\" DESC LIMIT 50 OFFSET 100", "data browser generates filtered sorted pagination SQL")
  testkit.equal(state, fullclient.dataCountSql("shop.shop_item", pageOptions), "SELECT COUNT(*) AS row_count FROM \"shop\".\"shop_item\" WHERE active = TRUE", "data browser count matches its filter")
  testkit.errorCode(state, try(fullclient.createDataBrowseOptions("TRUE; DROP TABLE x", "", true, 0, 100)), 9001, "data browser rejects statement injection in filters")
  testkit.errorCode(state, try(fullclient.createDataBrowseOptions("", "", true, 0, 1001)), 9001, "data browser bounds page size")
  pendingInsert = fullclient.pendingDataChange("INSERT", insertSql, -1, ["<DEFAULT>", "new's", "<NULL>", "FALSE", "2.50"])
  pendingUpdate = fullclient.pendingDataChange("UPDATE", updateSql, 0, ["7", "updated", "memo", "FALSE", "9.75"])
  pendingGrid = fullclient.dataGridWithChanges(editableDetails, [pendingUpdate, pendingInsert])
  testkit.record(state, len(pendingGrid.columns) == 6 and len(pendingGrid.rows) == 2 and pendingGrid.rows[0][0] == "UPDATE" and pendingGrid.rows[1][0] == "INSERT", "pending row changes render explicit optimistic grid markers")
  testkit.record(state, fullclient.textContains(fullclient.pendingDataSql([pendingUpdate, pendingInsert]), "\r\nINSERT INTO"), "pending changes preserve exact ordered SQL preview")
  csv = fullclient.gridCsv(fullclient.DetailGrid(["name", "note"], [["Müller, Anna", "line \"one\""]]))
  testkit.equal(state, csv, "\"name\",\"note\"\r\n\"Müller, Anna\",\"line \"\"one\"\"\"\r\n", "CSV export uses UTF-8, CRLF, commas, and doubled quotes")
  clipboardText = fullclient.gridClipboardText(fullclient.DetailGrid(["value"], [["tab\tline\r\nslash\\"]]), [0], false)
  clipboardRows = fullclient.parseClipboardRows(clipboardText)
  testkit.record(state, len(clipboardRows) == 1 and clipboardRows[0][0] == "tab\tline\r\nslash\\", "escaped clipboard TSV roundtrips tabs, line endings, and backslashes")
  testkit.equal(state, len(fullclient.filterHistory(["SELECT 1;", "UPDATE shop SET x = 1;"], "ShOp")), 1, "history search is case-insensitive")
  worksheets = [fullclient.newWorksheet(1, "SELECT 1;"), fullclient.newWorksheet(2, "SELECT 2;")]
  testkit.equal(state, fullclient.worksheetLines(worksheets)[1], "SQL 2", "independent worksheet tabs retain stable labels")
  resultOne = fullclient.ResultTab("First", "SELECT 1;", "first", 1, true, ["value"], [["1"]], 1)
  resultTwo = fullclient.ResultTab("Second", "SELECT 2;", "second", 1, true, ["value"], [["2"]], 2)
  resultThree = fullclient.ResultTab("Third", "SELECT 3;", "third", 1, true, ["value"], [["3"]], 3)
  tabState = fullclient.FullClientState(plain, void, [], "", fullclient.emptyTableDetails(), "", fullclient.emptyQueryView(), "Ready", [resultOne, resultTwo, resultThree], 1, [], [], false)
  closedBeforeSelection = try(fullclient.closeResultTab(tabState, 0))
  testkit.record(state, typeof(closedBeforeSelection) != "error" and len(tabState.resultTabs) == 2 and tabState.selectedResultIndex == 0 and fullclient.activeResultTab(tabState).title == "Second", "closing a result before the selection preserves the same active result")
  closedLastResult = try(fullclient.closeResultTab(tabState, 1))
  closedOnlyResult = try(fullclient.closeResultTab(tabState, 0))
  testkit.record(state, typeof(closedLastResult) != "error" and typeof(closedOnlyResult) != "error" and len(tabState.resultTabs) == 0 and tabState.selectedResultIndex == -1 and fullclient.activeResultTab(tabState) is void, "result close buttons remove the last page and clear its selection")
  testkit.errorCode(state, try(fullclient.closeResultTab(tabState, 0)), 9001, "result close rejects an invalid tab index")
  testkit.equal(state, fullclient.schemaEditorSql(0, "shop.product", "", "id INTEGER PRIMARY KEY, name VARCHAR(80) NOT NULL", ""), "CREATE TABLE \"shop\".\"product\" (id INTEGER PRIMARY KEY, name VARCHAR(80) NOT NULL);", "schema designer previews CREATE TABLE")
  testkit.equal(state, fullclient.schemaEditorSql(1, "shop.product", "active", "BOOLEAN NOT NULL DEFAULT TRUE", ""), "ALTER TABLE \"shop\".\"product\" ADD COLUMN \"active\" BOOLEAN NOT NULL DEFAULT TRUE;", "schema designer previews ADD COLUMN")
  testkit.equal(state, fullclient.schemaEditorSql(4, "shop.product", "shop.idx_product_name", "name, active", "UNIQUE"), "CREATE UNIQUE INDEX \"shop\".\"idx_product_name\" ON \"shop\".\"product\" (\"name\", \"active\");", "schema designer previews quoted unique indexes")
  testkit.equal(state, fullclient.schemaEditorSql(6, "shop.product", "chk_name", "CHECK (name <> '')", ""), "ALTER TABLE \"shop\".\"product\" ADD CONSTRAINT \"chk_name\" CHECK (name <> '');", "schema designer previews constraints")
  testkit.errorCode(state, try(fullclient.schemaEditorSql(6, "shop.product", "bad", "CHECK (TRUE); DROP TABLE x", "")), 9001, "schema designer rejects multi-statement definitions")
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
  schemaWindow = try(win32_client.createSchemaEditorWindow("shop_item", false))
  testkit.record(state, typeof(schemaWindow) != "error", "native schema designer constructs")
  if typeof(schemaWindow) != "error" then
    gui.setText(schemaWindow.objectEdit, "added")
    gui.setText(schemaWindow.definitionEdit, "INTEGER DEFAULT 0")
    gui.listSelect(schemaWindow.actionList, 1)
    schemaState = win32_client.SchemaEditorState(schemaWindow, void, false)
    schemaPreview = try(win32_client.renderSchemaEditor(schemaState))
    ignoredSchemaResize = try(gui.setClientSizeDip(schemaWindow.hwnd, 1100, 760, true))
    schemaLayout = try(win32_client.layoutSchemaEditor(schemaWindow))
    testkit.record(state, typeof(schemaPreview) == "string" and fullclient.textContains(schemaPreview, "ADD COLUMN") and typeof(schemaLayout) != "error", "schema designer updates DDL preview and responsive layout")
    gui.destroy(schemaWindow.hwnd)
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
  testkit.equal(state, gui.richEditNativeOffset("A\r\nB", 3), 2, "RichEdit mapping collapses CRLF to one native paragraph mark")
  testkit.equal(state, gui.richEditDocumentOffset("A\r\nB", 2), 3, "RichEdit mapping restores the public CRLF offset")

  smoke = try(gui.hiddenWindowSmoke())
  testkit.record(state, typeof(smoke) != "error" and smoke, "custom Win32 top-level smoke")
  window = try(win32_client.createWindow(false))
  if typeof(window) == "error" then print window.message end if
  testkit.record(state, typeof(window) != "error", "SQuirreL-style workbench controls construct")
  if typeof(window) != "error" then
    testkit.record(state, window.objectTree != 0 and window.queryEdit != 0 and window.worksheetTabs != 0 and window.resultGrid != 0 and window.detailGrid != 0 and window.dataAddButton != 0 and window.schemaButton != 0, "object tree worksheet tabs schema designer and editable detail grids exist")
    testkit.equal(state, gui.tabSelectedIndex(window.workspaceTabs), 0, "SQL worksheet is default workspace")
    worksheetRectangle = try(gui.tabItemRectangle(window.worksheetTabs, 0))
    worksheetCloseHit = -1
    worksheetBodyHit = -1
    if typeof(worksheetRectangle) == "array" then
      worksheetY = (worksheetRectangle[1] + worksheetRectangle[3]) >> 1
      worksheetCloseHit = gui.tabCloseHitIndexAt(window.worksheetTabs, worksheetRectangle[2] - 2, worksheetY)
      worksheetBodyHit = gui.tabCloseHitIndexAt(window.worksheetTabs, worksheetRectangle[0] + 2, worksheetY)
    end if
    testkit.record(state, worksheetCloseHit == 0 and worksheetBodyHit == -1, "worksheet tab exposes a bounded trailing close target")
    renderedResultTabs = try(win32_client.fillClosableTabs(window.resultTabs, ["First", "Second"], 1))
    resultRectangle = try(gui.tabItemRectangle(window.resultTabs, 1))
    resultCloseHit = -1
    if typeof(resultRectangle) == "array" then resultCloseHit = gui.tabCloseHitIndexAt(window.resultTabs, resultRectangle[2] - 2, (resultRectangle[1] + resultRectangle[3]) >> 1) end if
    testkit.record(state, typeof(renderedResultTabs) != "error" and gui.tabSelectedIndex(window.resultTabs) == 1 and resultCloseHit == 1, "result tabs render an independently clickable close target")
    controllerState = fullclient.FullClientState(plain, void, [], "", fullclient.emptyTableDetails(), "", fullclient.emptyQueryView(), "Ready", [], -1, [], [], false)
    controllerSession = win32_client.AdminSession(window, controllerState, void, false, false, false, false, 0, 0, [fullclient.newWorksheet(1, "")], 0, 2, [], fullclient.defaultDataBrowseOptions(), "", "", [])
    ignoredBlankWorksheet = try(gui.setText(window.queryEdit, ""))
    closedSoleWorksheet = try(win32_client.closeWorksheetAt(controllerSession, 0))
    testkit.record(state, typeof(ignoredBlankWorksheet) != "error" and typeof(closedSoleWorksheet) != "error" and len(controllerSession.worksheets) == 1 and controllerSession.worksheets[0].title == "SQL 2" and controllerSession.selectedWorksheetIndex == 0, "closing the sole blank worksheet replaces it with a fresh usable editor")
    largeEditorText = decode(bytes(40000, 65))
    ignoredLargeText = try(gui.setText(window.queryEdit, largeEditorText))
    readLargeText = try(gui.getText(window.queryEdit))
    if typeof(readLargeText) != "string" then print readLargeText.message else if len(bytes(readLargeText)) != 40000 then print "large SQL editor roundtrip bytes=" + len(bytes(readLargeText)) end if
    testkit.record(state, typeof(readLargeText) == "string" and len(bytes(readLargeText)) == 40000, "SQL editor text is not capped at 32 KiB")
    gui.listViewResetColumns(window.detailGrid)
    gui.listViewAddColumn(window.detailGrid, 0, "id", 120)
    gui.listViewAddRow(window.detailGrid, 0, ["first"])
    gui.listViewAddRow(window.detailGrid, 1, ["second"])
    gui.listViewSelect(window.detailGrid, 0)
    gui.listViewAddSelection(window.detailGrid, 1)
    selectedRows = gui.listViewSelectedIndices(window.detailGrid)
    testkit.record(state, len(selectedRows) == 2 and gui.listViewCellText(window.detailGrid, 1, 0) == "second", "native grids support multi-selection and cell text access")
    clipboardSet = try(gui.clipboardSetText(window.hwnd, "MiniSQL clipboard ✓"))
    clipboardValid = false
    if typeof(clipboardSet) == "error" then
      // The clipboard is a global desktop resource. A different process may
      // deliberately hold it longer than the bounded production retry window.
      clipboardValid = clipboardSet.code == 9040 and fullclient.textContains(clipboardSet.message, "OpenClipboard remained busy after retrying")
      if not clipboardValid then print "clipboard set: " + clipboardSet.message end if
    else
      clipboardRead = try(gui.clipboardText(window.hwnd))
      clipboardValid = typeof(clipboardRead) == "string" and clipboardRead == "MiniSQL clipboard ✓"
      if typeof(clipboardRead) == "error" then print "clipboard read: " + clipboardRead.message else if not clipboardValid then print "clipboard mismatch bytes=" + len(bytes(clipboardRead)) end if
    end if
    testkit.record(state, clipboardValid, "native Unicode clipboard roundtrips text or reports external ownership deterministically")
    gui.destroy(window.hwnd)
  end if
  layoutPath = file_api.joinPath(args[0], "workbench-layout.json")
  savedLayout = try(win32_client.saveWindowLayout(layoutPath, [40, 50, 1200, 800]))
  testkit.record(state, typeof(savedLayout) != "error" and savedLayout and file_api.fileExists(layoutPath), "workbench window layout persists atomically")
  manager = try(win32_client.connectionManagerSmoke(profilePath))
  testkit.record(state, typeof(manager) != "error" and manager, "connection manager hidden smoke")
  connectionLayout = try(win32_client.connectionLayoutSmoke(profilePath))
  if typeof(connectionLayout) == "error" then print connectionLayout.message end if
  testkit.record(state, typeof(connectionLayout) != "error" and connectionLayout, "connection manager resizes and accepts editor, checkbox, and button input")
  failureWindow = try(win32_client.createConnectionWindow(false))
  if typeof(failureWindow) == "struct" then
    refusal = error(9004, "connect failed with WinSock 10061")
    failureMessage = try(win32_client.reportConnectionFailure(failureWindow, refusal, false))
    failureStatus = try(gui.getText(failureWindow.statusLabel))
    testkit.record(state, typeof(failureMessage) == "string" and failureMessage == "Connection refused. Verify address/port and start minisqld for this database." and failureStatus == "Connection failed: " + failureMessage and gui.isOpen(failureWindow.hwnd), "connection failure keeps the manager open with actionable retry guidance")
    gui.destroy(failureWindow.hwnd)
  else
    testkit.record(state, false, "connection failure keeps the manager open with actionable retry guidance")
  end if
  workbenchLayout = try(win32_client.workbenchLayoutSmoke())
  if typeof(workbenchLayout) == "error" then print workbenchLayout.message end if
  testkit.record(state, typeof(workbenchLayout) != "error" and workbenchLayout, "workbench compact and wide layouts remain non-overlapping and interactive")
  return testkit.finish(state, "MiniSQL M74 workbench tests: SUCCESS", "MiniSQL M74 workbench tests: FAIL")
end function
