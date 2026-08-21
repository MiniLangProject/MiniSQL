// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.admin.fullclient as fullclient
import minisql.admin.win32_client as win32_client
import minisql.platform.win32_gui as gui
import tests.support.testkit as testkit

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
  inserted = try(fullclient.executeSql(active, "INSERT INTO workbench_item(id, label) VALUES (1, 'alpha'), (2, 'beta');"))
  testkit.record(test, typeof(inserted) != "error" and inserted.success, "worksheet inserts rows")
  selected = try(fullclient.executeSql(active, "SELECT id, label FROM workbench_item ORDER BY id;"))
  testkit.record(test, typeof(selected) != "error" and selected.success, "worksheet selects rows")
  if typeof(selected) != "error" then testkit.equal(test, selected.rowCount, 2, "worksheet row count") end if
  tab = fullclient.activeResultTab(active)
  testkit.record(test, tab is not void and len(tab.columns) == 2 and len(tab.rows) == 2, "structured grid result retained")
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
    startedDescribe = try(win32_client.startDescribe(session, "workbench_item"))
    testkit.record(test, typeof(startedDescribe) != "error" and awaitOperation(session, 30000), "asynchronous table details complete")
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
    startedQuery = try(win32_client.startQuery(session, "SELECT label FROM workbench_item ORDER BY id;", false))
    testkit.record(test, typeof(startedQuery) != "error" and awaitOperation(session, 30000), "asynchronous worksheet query and follow-up refresh complete")
    testkit.record(test, gui.isEnabled(session.window.queryEdit) and not gui.isEnabled(session.window.stopButton), "controls unlock after worker completion")
    gui.destroy(session.window.hwnd)
  end if
  closed = true
  if typeof(session) != "error" and session.aborted then closed = try(fullclient.abort(active)) else closed = try(fullclient.close(active)) end if
  testkit.record(test, typeof(closed) != "error" and closed, "workbench closes protocol session")
  return testkit.finish(test, "MiniSQL M74 workbench network worker: SUCCESS", "MiniSQL M74 workbench network worker: FAIL")
end function
