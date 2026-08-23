// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.admin.fullclient as fullclient
import minisql.admin.win32_client as win32_client
import minisql.platform.win32_gui as gui
import tests.support.testkit as testkit

// Carries one independent read-only connection workload to a native thread.
struct ConcurrentReaderTask
  // Stores the shared immutable connection profile.
  profile
  // Distinguishes the worker in deterministic SELECT literals.
  workerIndex
  // Stores the bounded number of roundtrips performed by this worker.
  iterations
end struct

// Opens an independent connection and repeatedly reads the same database.
function concurrentReader(task)
  state = try(fullclient.openProfile(task.profile, bytes(0)))
  if typeof(state) == "error" then return state end if
  success = true
  for iteration = 0 to task.iterations - 1
    response = try(fullclient.queryOne(state, "SELECT COUNT(*) AS row_count FROM workbench_item WHERE id >= " + task.workerIndex))
    if typeof(response) == "error" then
      ignoredAbort = try(fullclient.abort(state))
      return error(response.code, "parallel reader " + task.workerIndex + " iteration " + iteration + ": " + response.message)
    end if
    if len(response.rows) != 1 then
      ignoredAbort = try(fullclient.abort(state))
      return error(9001, "parallel reader " + task.workerIndex + " iteration " + iteration + ": expected one aggregate row")
    end if
  end for
  closed = try(fullclient.close(state))
  if typeof(closed) == "error" then return closed end if
  return success
end function

// Waits for one asynchronous workbench operation while pumping native messages.
function awaitOperation(session, maximumMilliseconds)
  elapsed = 0
  while elapsed < maximumMilliseconds
    ignoredPump = gui.pumpMessages()
    if win32_client.pollQuery(session) then return true end if
    gui.sleep(10)
    elapsed = elapsed + 10
  end while
  // A timed-out worker still owns the protocol stream. Cancel it here so the
  // test cannot issue another request or attempt a graceful close concurrently.
  if session.busy then ignoredStop = win32_client.stopQuery(session) end if
  return false
end function

// Waits for an asynchronous connection handshake and returns its state or timeout error.
function awaitConnection(attempt, maximumMilliseconds)
  elapsed = 0
  while elapsed < maximumMilliseconds
    result = win32_client.pollConnection(attempt)
    if result is not void then return result end if
    gui.sleep(10)
    elapsed = elapsed + 10
  end while
  if attempt.busy then ignoredStop = try(win32_client.stopConnection(attempt)) end if
  return error(9001, "workbench connection worker timed out")
end function

// Finds one structured detail-grid row by exact textual column value.
function findDetailRow(grid, columnIndex, wanted)
  if typeof(grid) != "struct" or typeof(columnIndex) != "int" or typeof(wanted) != "string" then return -1 end if
  if len(grid.rows) > 0 then
    for index = 0 to len(grid.rows) - 1
      if columnIndex >= 0 and columnIndex < len(grid.rows[index]) and grid.rows[index][columnIndex] == wanted then return index end if
    end for
  end if
  return -1
end function

// Exercises the complete workbench model over a real trusted-local server connection.
function main(args)
  if len(args) != 1 then print "MiniSQL M74 workbench network worker: FAIL args"; return 2 end if
  port = toNumber(args[0])
  if typeof(port) != "int" then print "MiniSQL M74 workbench network worker: FAIL port"; return 2 end if
  test = testkit.create()
  profile = fullclient.createProfile("Network test", "127.0.0.1", port, "localhost", "workbench", "", false, "", true)

  // Exercise the same password-free, non-blocking handshake used by the visible alias manager.
  connectionWindow = try(win32_client.createConnectionWindow(false))
  connectionState = error(9001, "connection window failed")
  if typeof(connectionWindow) != "error" then
    ignoredRenderProfile = try(win32_client.renderConnectionProfile(connectionWindow, profile))
    attempt = try(win32_client.startConnection(connectionWindow, profile))
    testkit.record(test, typeof(attempt) != "error" and attempt.busy, "trusted-local GUI connection starts without a password")
    if typeof(attempt) != "error" then
      testkit.record(test, not gui.isEnabled(connectionWindow.connectButton) and gui.isEnabled(connectionWindow.closeButton), "connection controls lock while handshake runs")
      connectionState = awaitConnection(attempt, 10000)
    end if
    gui.destroy(connectionWindow.hwnd)
  else
    testkit.record(test, false, "trusted-local GUI connection starts without a password")
    testkit.record(test, false, "connection controls lock while handshake runs")
  end if
  testkit.record(test, typeof(connectionState) != "error", "GUI connection worker completes")
  if typeof(connectionState) != "error" then
    abortedConnection = try(fullclient.abort(connectionState))
    testkit.record(test, typeof(abortedConnection) != "error" and abortedConnection, "workbench transport abort releases a connection without protocol reuse")
  else
    testkit.record(test, false, "workbench transport abort releases a connection without protocol reuse")
  end if

  active = try(fullclient.openProfile(profile, bytes(0)))
  if typeof(active) == "error" then print active.message; return 1 end if
  secretText = "Workbench-Secret-74!"
  secretDcl = try(fullclient.executeSql(active, "CREATE USER workbench_secret WITH /* redaction */ PASSWORD '" + secretText + "';"))
  secretLeaked = fullclient.textContains(active.queryText, secretText)
  for each historyItem in active.history
    if fullclient.textContains(historyItem, secretText) then secretLeaked = true end if
  end for
  for each resultItem in active.resultTabs
    if fullclient.textContains(resultItem.sqlText, secretText) then secretLeaked = true end if
  end for
  testkit.record(test, typeof(secretDcl) != "error" and not secretLeaked, "password DCL never enters retained workbench state")
  ignoredSecretDrop = try(fullclient.executeSql(active, "DROP USER workbench_secret;"))
  ignoredDrop = try(fullclient.executeSql(active, "DROP TABLE IF EXISTS workbench_item;"))
  created = try(fullclient.executeSql(active, "CREATE TABLE workbench_item (id INTEGER PRIMARY KEY, label VARCHAR(80) NOT NULL);"))
  testkit.record(test, typeof(created) != "error" and created.success, "worksheet creates table")
  batch = try(fullclient.executeSql(active, "INSERT INTO workbench_item(id, label) VALUES (1, 'alpha');\r\nINSERT INTO workbench_item(id, label) VALUES (2, 'beta;still-data');\r\nSELECT id, label FROM workbench_item ORDER BY id;"))
  testkit.record(test, typeof(batch) != "error" and batch.success and batch.statementCount == 3 and batch.rowCount == 2, "worksheet executes a quote-aware multi-statement script")
  bulkSql = ""
  for id = 10 to 259
    bulkSql = bulkSql + "INSERT INTO workbench_item(id, label) VALUES (" + id + ", 'bulk-" + id + "');\r\n"
  end for
  bulk = try(fullclient.executeAtomicSql(active, bulkSql))
  testkit.record(test, typeof(bulk) != "error" and bulk.success and bulk.statementCount == 250, "large editable dataset loads atomically")
  paged = try(fullclient.describeTableView(active, "workbench_item", fullclient.createDataBrowseOptions("id >= 10", "id", false, 1, 25)))
  testkit.record(test, typeof(paged) != "error" and len(paged.contentsGrid.rows) == 25 and paged.contentsGrid.rows[0][0] == "234" and paged.rowCountGrid.rows[0][0] == "250", "server-side filter sort count and pagination remain aligned")
  rolledBackBatch = try(fullclient.executeAtomicSql(active, "INSERT INTO workbench_item(id, label) VALUES (900, 'must-rollback');\r\nINSERT INTO workbench_item(id, label) VALUES (1, 'duplicate');"))
  rolledBackProbe = try(fullclient.queryOne(active, "SELECT id FROM workbench_item WHERE id = 900"))
  testkit.record(test, typeof(rolledBackBatch) != "error" and not rolledBackBatch.success and typeof(rolledBackProbe) != "error" and len(rolledBackProbe.rows) == 0, "failed multi-row Apply transaction rolls back every staged change")
  schemaSteps = [
    fullclient.schemaEditorSql(0, "workbench_schema", "", "id INTEGER PRIMARY KEY", ""),
    fullclient.schemaEditorSql(1, "workbench_schema", "code", "VARCHAR(30)", ""),
    fullclient.schemaEditorSql(4, "workbench_schema", "idx_workbench_schema_code", "code", "UNIQUE"),
    fullclient.schemaEditorSql(6, "workbench_schema", "chk_workbench_code", "CHECK (code IS NULL OR code <> '')", ""),
    fullclient.schemaEditorSql(7, "workbench_schema", "chk_workbench_code", "", ""),
    fullclient.schemaEditorSql(5, "", "idx_workbench_schema_code", "", ""),
    fullclient.schemaEditorSql(9, "workbench_schema", "", "", "")
  ]
  schemaSucceeded = true
  for each schemaSql in schemaSteps
    schemaResult = try(fullclient.executeSql(active, schemaSql))
    if typeof(schemaResult) == "error" or not schemaResult.success then schemaSucceeded = false end if
  end for
  testkit.record(test, schemaSucceeded, "schema designer DDL executes for tables columns indexes and constraints")
  readerWorkers = []
  for workerIndex = 0 to 7
    worker = Thread(concurrentReader, "m74-parallel-reader")
    if worker.Start(ConcurrentReaderTask(profile, workerIndex, 10)) then readerWorkers = readerWorkers + [worker] else print "parallel reader failed to start: " + workerIndex end if
  end for
  readersSucceeded = len(readerWorkers) == 8
  for each worker in readerWorkers
    if not worker.Join(60000) then readersSucceeded = false; print "parallel reader join timed out"
    else
      result = try(worker.Result())
      if typeof(result) == "error" then readersSucceeded = false; print "parallel reader error: " + result.message
      else if not result then readersSucceeded = false; print "parallel reader reported unsuccessful query"
      end if
    end if
    ignoredReaderClose = worker.Close()
  end for
  testkit.record(test, readersSucceeded, "eight parallel workbench connections complete 80 shared-database reads")
  reconnectSucceeded = true
  for reconnect = 0 to 9
    reopened = try(fullclient.openProfile(profile, bytes(0)))
    if typeof(reopened) == "error" then reconnectSucceeded = false
    else
      probe = try(fullclient.queryOne(reopened, "SELECT 1 AS connected"))
      closedAgain = try(fullclient.close(reopened))
      if typeof(probe) == "error" or typeof(closedAgain) == "error" then reconnectSucceeded = false end if
    end if
  end for
  testkit.record(test, reconnectSucceeded, "repeated disconnect and reconnect cycles preserve server availability")
  selected = try(fullclient.executeSql(active, "SELECT id, label FROM workbench_item ORDER BY id;"))
  testkit.record(test, typeof(selected) != "error" and selected.success, "worksheet selects rows")
  if typeof(selected) != "error" then testkit.equal(test, selected.rowCount, 252, "worksheet row count") end if
  tab = fullclient.activeResultTab(active)
  testkit.record(test, tab is not void and len(tab.columns) == 2 and len(tab.rows) == 252, "structured grid result retained")
  refreshed = try(fullclient.refresh(active))
  testkit.record(test, typeof(refreshed) != "error" and fullclient.containsText(active.tables, "workbench_item"), "object tree refresh sees table")
  details = try(fullclient.describeTable(active, "workbench_item"))
  testkit.record(test, typeof(details) != "error", "table detail notebook loads")
  if typeof(details) != "error" then
    testkit.record(test, fullclient.textContains(details.columnsText, "label"), "columns detail includes label")
    testkit.record(test, fullclient.textContains(details.ddlText, "CREATE TABLE \"workbench_item\""), "DDL detail reconstructed")
  end if
  explained = try(fullclient.explainSql(active, "SELECT label FROM workbench_item WHERE id = 1;"))
  testkit.record(test, typeof(explained) != "error" and explained.success, "explain workflow succeeds")
  begun = try(fullclient.beginTransaction(active))
  rolledBack = try(fullclient.rollbackTransaction(active))
  testkit.record(test, typeof(begun) != "error" and begun.success and typeof(rolledBack) != "error" and rolledBack.success, "transaction toolbar workflow succeeds")
  session = try(win32_client.openState(active, false))
  testkit.record(test, typeof(session) != "error", "connected hidden workbench renders")
  if typeof(session) != "error" then
    startedRefresh = try(win32_client.startRefresh(session))
    testkit.record(test, typeof(startedRefresh) != "error" and session.busy, "object refresh starts asynchronously")
    testkit.record(test, not gui.isEnabled(session.window.queryEdit) and not gui.isEnabled(session.window.objectTree) and gui.isEnabled(session.window.stopButton), "state-reading controls lock while worker owns the session")
    testkit.record(test, awaitOperation(session, 30000), "asynchronous object refresh completes")
    session.dataOptions = fullclient.createDataBrowseOptions("", "id", true, 0, 100)
    startedDescribe = try(win32_client.startDescribe(session, "workbench_item"))
    testkit.record(test, typeof(startedDescribe) != "error" and awaitOperation(session, 30000), "asynchronous table details complete")
    testkit.record(test, session.workspacePage == 1 and gui.tabSelectedIndex(session.window.workspaceTabs) == 1, "completed table metadata keeps the Object Details workspace active")
    gui.tabSelect(session.window.detailTabs, 1)
    win32_client.render(session)
    testkit.record(test, gui.listViewRowCount(session.window.detailGrid) == 2, "Columns detail renders two native grid rows")
    gui.tabSelect(session.window.detailTabs, 3)
    win32_client.render(session)
    testkit.record(test, gui.listViewRowCount(session.window.detailGrid) == 100, "Data detail renders one bounded native-grid page")
    insertSql = try(fullclient.insertDataSql(session.state.tableDetails, ["3", "gamma"] ))
    startedInsert = error(9001, "insert SQL generation failed")
    if typeof(insertSql) == "string" then startedInsert = try(win32_client.startDataMutation(session, insertSql)) end if
    insertedThroughGrid = typeof(startedInsert) != "error" and awaitOperation(session, 30000)
    insertedRow = findDetailRow(session.state.tableDetails.contentsGrid, 0, "3")
    testkit.record(test, insertedThroughGrid and insertedRow >= 0 and gui.listViewRowCount(session.window.detailGrid) == 100, "Data-grid insert executes atomically and refreshes its bounded preview")
    updateSql = error(9001, "inserted row unavailable")
    if insertedRow >= 0 then updateSql = try(fullclient.updateDataSql(session.state.tableDetails, session.state.tableDetails.contentsGrid.rows[insertedRow], ["3", "gamma-updated"])) end if
    startedUpdate = error(9001, "update SQL generation failed")
    if typeof(updateSql) == "string" then startedUpdate = try(win32_client.startDataMutation(session, updateSql)) end if
    updatedThroughGrid = typeof(startedUpdate) != "error" and awaitOperation(session, 30000)
    updatedRow = findDetailRow(session.state.tableDetails.contentsGrid, 1, "gamma-updated")
    testkit.record(test, updatedThroughGrid and updatedRow >= 0, "Data-grid update uses the original primary key and refreshes its preview")
    deleteSql = error(9001, "updated row unavailable")
    if updatedRow >= 0 then deleteSql = try(fullclient.deleteDataSql(session.state.tableDetails, session.state.tableDetails.contentsGrid.rows[updatedRow])) end if
    startedDelete = error(9001, "delete SQL generation failed")
    if typeof(deleteSql) == "string" then startedDelete = try(win32_client.startDataMutation(session, deleteSql)) end if
    deletedThroughGrid = typeof(startedDelete) != "error" and awaitOperation(session, 30000)
    testkit.record(test, deletedThroughGrid and findDetailRow(session.state.tableDetails.contentsGrid, 0, "3") < 0 and gui.listViewRowCount(session.window.detailGrid) == 100, "Data-grid delete removes exactly the keyed row and refreshes its preview")
    gui.tabSelect(session.window.workspaceTabs, 0)
    win32_client.render(session)
    testkit.record(test, gui.tabSelectedIndex(session.window.workspaceTabs) == 1, "render restores the session-owned Object Details workspace")
    gui.tabSelect(session.window.detailTabs, 5)
    win32_client.render(session)
    detailText = try(gui.getText(session.window.detailEdit))
    testkit.record(test, gui.tabSelectedIndex(session.window.detailTabs) == 5 and typeof(detailText) == "string" and fullclient.textContains(detailText, "CREATE TABLE"), "detail-page selection survives rendering")
    asyncSecret = "Async-Workbench-Secret-74!"
    asyncDcl = "CREATE USER workbench_async_secret WITH PASSWORD '" + asyncSecret + "';"
    gui.setText(session.window.queryEdit, asyncDcl)
    startedSecret = try(win32_client.startQuery(session, asyncDcl, false))
    completedSecret = false
    if typeof(startedSecret) != "error" then completedSecret = awaitOperation(session, 30000) end if
    clearedEditor = try(gui.getText(session.window.queryEdit))
    testkit.record(test, completedSecret and clearedEditor == "" and not fullclient.textContains(session.state.queryText, asyncSecret), "asynchronous DCL clears the editor and retained state")
    startedSecretDrop = try(win32_client.startQuery(session, "DROP USER workbench_async_secret;", false))
    if typeof(startedSecretDrop) != "error" then ignoredSecretDropCompletion = awaitOperation(session, 30000) end if
    editorText = "SELECT 999;\r\nSELECT label FROM workbench_item ORDER BY id;"
    gui.setText(session.window.queryEdit, editorText)
    secondStart = fullclient.utf16Length("SELECT 999;\r\n")
    gui.selectText(session.window.queryEdit, secondStart, secondStart)
    currentSql = try(win32_client.editorSqlForCommand(session.window, false))
    testkit.equal(test, currentSql, "SELECT label FROM workbench_item ORDER BY id;", "native worksheet resolves the current caret statement")
    startedQuery = try(win32_client.startQuery(session, currentSql, false))
    testkit.record(test, typeof(startedQuery) != "error" and awaitOperation(session, 30000), "asynchronous current-statement query and follow-up refresh complete")
    testkit.record(test, gui.isEnabled(session.window.queryEdit) and not gui.isEnabled(session.window.stopButton), "controls unlock after worker completion")
    gui.destroy(session.window.hwnd)
  end if
  closed = true
  if typeof(session) != "error" and session.aborted then closed = try(fullclient.abort(active)) else closed = try(fullclient.close(active)) end if
  testkit.record(test, typeof(closed) != "error" and closed, "workbench closes protocol session")
  return testkit.finish(test, "MiniSQL M74 workbench network worker: SUCCESS", "MiniSQL M74 workbench network worker: FAIL")
end function
