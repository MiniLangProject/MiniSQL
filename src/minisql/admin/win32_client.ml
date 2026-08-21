package minisql.admin.win32_client

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.admin.connection_profiles as connection_profiles
import minisql.admin.fullclient as fullclient
import minisql.common.uuid as uuid
import minisql.platform.win32_gui as gui

const INVALID_ARGUMENT = 9001
const LBN_SELCHANGE = 1
const LBN_DBLCLK = 2
const TCN_SELCHANGE = -551
const TVN_SELCHANGEDW = -451
const NM_DBLCLK = -3

const ID_PROFILE_LIST = 8001
const ID_PROFILE_NAME = 8002
const ID_PROFILE_ADDRESS = 8003
const ID_PROFILE_PORT = 8004
const ID_PROFILE_SERVER = 8005
const ID_PROFILE_DATABASE = 8006
const ID_PROFILE_USER = 8007
const ID_PROFILE_PASSWORD = 8008
const ID_PROFILE_TLS = 8009
const ID_PROFILE_TRUSTED = 8010
const ID_PROFILE_PIN = 8011
const ID_PROFILE_SAVE = 8012
const ID_PROFILE_CONNECT = 8013
const ID_PROFILE_DELETE = 8014
const ID_PROFILE_NEW = 8015
const ID_PROFILE_CLOSE = 8016

const ID_SIDEBAR_TABS = 8101
const ID_OBJECT_TREE = 8102
const ID_BOOKMARK_LIST = 8103
const ID_HISTORY_LIST = 8104
const ID_WORKSPACE_TABS = 8105
const ID_DETAIL_TABS = 8106
const ID_RESULT_TABS = 8107
const ID_RESULT_GRID = 8108
const ID_REFRESH = 8110
const ID_OPEN_OBJECT = 8111
const ID_NEW_SQL = 8112
const ID_EXECUTE = 8113
const ID_EXPLAIN = 8114
const ID_BEGIN = 8115
const ID_COMMIT = 8116
const ID_ROLLBACK = 8117
const ID_STOP = 8118
const ID_CLEAR = 8119
const ID_CLOSE = 8120

// Owns all native controls in the connection-alias window.
struct ConnectionWindow
  // Stores the top-level connection window handle.
  hwnd
  // Stores the alias list control.
  aliasList
  // Stores the alias-name editor.
  nameEdit
  // Stores the network-address editor.
  addressEdit
  // Stores the network-port editor.
  portEdit
  // Stores the TLS server-name editor.
  serverEdit
  // Stores the database-label editor.
  databaseEdit
  // Stores the MiniSQL user editor.
  userEdit
  // Stores the transient password editor.
  passwordEdit
  // Stores the optional certificate-pin editor.
  pinEdit
  // Stores the native TLS checkbox.
  tlsCheck
  // Stores the trusted-local checkbox.
  trustedCheck
  // Stores the connection-manager status label.
  statusLabel
end struct

// Owns all native controls in one MiniSQL session workbench.
struct AdminWindow
  // Stores the top-level workbench handle.
  hwnd
  // Stores the active endpoint heading.
  connectionLabel
  // Stores the sidebar tab control.
  sidebarTabs
  // Stores the hierarchical database object browser.
  objectTree
  // Stores reusable SQL bookmarks.
  bookmarkList
  // Stores redacted SQL history.
  historyList
  // Stores the SQL/details workspace tab control.
  workspaceTabs
  // Stores table-detail page tabs.
  detailTabs
  // Stores SQL result tabs.
  resultTabs
  // Stores the multiline SQL editor.
  queryEdit
  // Stores read-only table-detail text.
  detailEdit
  // Stores structured SQL result rows.
  resultGrid
  // Stores the object-tree refresh button.
  refreshButton
  // Stores the open-object button.
  openButton
  // Stores the new-worksheet button.
  newSqlButton
  // Stores the execute button.
  executeButton
  // Stores the explain button.
  explainButton
  // Stores the begin-transaction button.
  beginButton
  // Stores the commit button.
  commitButton
  // Stores the rollback button.
  rollbackButton
  // Stores the stop-worker button.
  stopButton
  // Stores the clear-results button.
  clearButton
  // Stores the close-session button.
  closeButton
  // Stores the workbench status line.
  statusLabel
end struct

// Bundles immutable input for a native SQL worker thread.
struct QueryTask
  // Stores the fullclient state owned by the session.
  state
  // Stores the SQL submitted to the worker.
  sqlText
  // Selects normal execution or EXPLAIN.
  explain
end struct

// Combines one native window, client state, and optional running query worker.
struct AdminSession
  // Owns the native workbench controls.
  window
  // Owns the protocol and result model.
  state
  // Stores the active native worker or void.
  worker
  // Indicates whether SQL is currently executing.
  busy
end struct

// Creates a namespaced GUI-controller error.
function fail(operation, message)
  return error(INVALID_ARGUMENT, "admin.win32_client." + operation + ": " + message)
end function

// Creates the modern alias manager used before a MiniSQL session opens.
function createConnectionWindow(visible)
  hwnd = try(gui.createTopLevel("MiniSQL Workbench — Connections", 940, 650, visible))
  if typeof(hwnd) == "error" then return hwnd end if
  ignoredTitle = try(gui.createLabel(hwnd, "MiniSQL connections", 20, 18, 280, 28))
  ignoredSubtitle = try(gui.createLabel(hwnd, "Choose an alias or configure a new MiniSQL endpoint.", 20, 46, 560, 22))
  aliasList = try(gui.createListBoxId(hwnd, ID_PROFILE_LIST, 20, 82, 278, 466))
  if typeof(aliasList) == "error" then return aliasList end if
  ignoredDetails = try(gui.createGroupBox(hwnd, "Connection details", 320, 76, 590, 472))
  labels = ["Alias name", "Server address", "Port", "Database label", "MiniSQL user", "Password", "TLS server name", "SHA-256 certificate pin"]
  for index = 0 to len(labels) - 1
    ignoredLabel = try(gui.createLabel(hwnd, labels[index], 344, 108 + index * 43, 188, 22))
  end for
  nameEdit = try(gui.createTextBoxId(hwnd, ID_PROFILE_NAME, "", 538, 104, 344, 28, false))
  addressEdit = try(gui.createTextBoxId(hwnd, ID_PROFILE_ADDRESS, "", 538, 147, 344, 28, false))
  portEdit = try(gui.createTextBoxId(hwnd, ID_PROFILE_PORT, "", 538, 190, 120, 28, false))
  databaseEdit = try(gui.createTextBoxId(hwnd, ID_PROFILE_DATABASE, "", 538, 233, 344, 28, false))
  userEdit = try(gui.createTextBoxId(hwnd, ID_PROFILE_USER, "", 538, 276, 344, 28, false))
  passwordEdit = try(gui.createTextBoxId(hwnd, ID_PROFILE_PASSWORD, "", 538, 319, 344, 28, true))
  serverEdit = try(gui.createTextBoxId(hwnd, ID_PROFILE_SERVER, "", 538, 362, 344, 28, false))
  pinEdit = try(gui.createTextBoxId(hwnd, ID_PROFILE_PIN, "", 538, 405, 344, 28, false))
  tlsCheck = try(gui.createCheckBoxId(hwnd, ID_PROFILE_TLS, "Native TLS 1.3 / X.509", 344, 448, 236, 26))
  trustedCheck = try(gui.createCheckBoxId(hwnd, ID_PROFILE_TRUSTED, "Trusted local loopback", 612, 448, 220, 26))
  ignoredHint = try(gui.createLabel(hwnd, "Pins are optional and useful for self-signed certificates. Passwords are never saved.", 344, 480, 538, 42))
  ignoredNew = try(gui.createButtonId(hwnd, ID_PROFILE_NEW, "New", 20, 562, 82, 34))
  ignoredDelete = try(gui.createButtonId(hwnd, ID_PROFILE_DELETE, "Delete", 112, 562, 82, 34))
  ignoredSave = try(gui.createButtonId(hwnd, ID_PROFILE_SAVE, "Save alias", 204, 562, 94, 34))
  ignoredConnect = try(gui.createDefaultButtonId(hwnd, ID_PROFILE_CONNECT, "Connect", 686, 562, 104, 34))
  ignoredClose = try(gui.createButtonId(hwnd, ID_PROFILE_CLOSE, "Close", 800, 562, 82, 34))
  statusLabel = try(gui.createLabel(hwnd, "Ready", 20, 610, 862, 22))
  return ConnectionWindow(hwnd, aliasList, nameEdit, addressEdit, portEdit, serverEdit, databaseEdit, userEdit, passwordEdit, pinEdit, tlsCheck, trustedCheck, statusLabel)
end function

// Finds an alias by exact user-visible name.
function profileByName(profiles, name)
  for each profile in profiles
    if profile.name == name then return profile end if
  end for
  return void
end function

// Copies an alias into connection-manager controls and clears the password.
function renderConnectionProfile(window, profile)
  gui.setText(window.nameEdit, profile.name)
  gui.setText(window.addressEdit, profile.address)
  gui.setText(window.portEdit, "" + profile.port)
  gui.setText(window.serverEdit, profile.serverName)
  gui.setText(window.databaseEdit, profile.databaseName)
  gui.setText(window.userEdit, profile.userName)
  gui.setText(window.passwordEdit, "")
  gui.setText(window.pinEdit, profile.pinSha256)
  gui.checkBoxSet(window.tlsCheck, profile.tls)
  gui.checkBoxSet(window.trustedCheck, profile.trustedLocal)
  return true
end function

// Rebuilds the alias list while keeping the first row selected.
function renderConnectionProfiles(window, profiles)
  gui.listReset(window.aliasList)
  for each profile in profiles
    ignored = try(gui.listAdd(window.aliasList, profile.name))
  end for
  if len(profiles) > 0 then gui.listSelect(window.aliasList, 0); return renderConnectionProfile(window, profiles[0]) end if
  return true
end function

// Clears fields to a sensible new local alias template.
function renderNewProfile(window)
  return renderConnectionProfile(window, connection_profiles.defaultProfile())
end function

// Validates connection-manager fields into a secret-free profile.
function profileFromWindow(window)
  name = try(gui.getText(window.nameEdit))
  if typeof(name) == "error" then return name end if
  address = try(gui.getText(window.addressEdit))
  if typeof(address) == "error" then return address end if
  portText = try(gui.getText(window.portEdit))
  if typeof(portText) == "error" then return portText end if
  port = toNumber(portText)
  if typeof(port) != "int" then return fail("profileFromWindow", "port must be an integer") end if
  serverName = try(gui.getText(window.serverEdit))
  if typeof(serverName) == "error" then return serverName end if
  databaseName = try(gui.getText(window.databaseEdit))
  if typeof(databaseName) == "error" then return databaseName end if
  userName = try(gui.getText(window.userEdit))
  if typeof(userName) == "error" then return userName end if
  pinSha256 = try(gui.getText(window.pinEdit))
  if typeof(pinSha256) == "error" then return pinSha256 end if
  return fullclient.createProfile(name, address, port, serverName, databaseName, userName, gui.checkBoxChecked(window.tlsCheck), pinSha256, gui.checkBoxChecked(window.trustedCheck))
end function

// Opens the current profile and wipes the password immediately after use.
function connectFromWindow(window, profile)
  password = try(gui.getSecretBytes(window.passwordEdit))
  if typeof(password) == "error" then return password end if
  state = try(fullclient.openProfile(profile, password))
  uuid.wipeSecret(password)
  return state
end function

// Translates common WinSock failures into actionable connection guidance.
function connectionFailureText(value)
  if typeof(value) != "error" then return "Unknown connection error" end if
  if fullclient.textContains(value.message, "10061") then return "Connection refused. Verify address/port and start minisqld for this database." end if
  if fullclient.textContains(value.message, "10054") then return "The server closed the connection. Verify its mode, account, and database path." end if
  return value.message
end function

// Runs the native alias manager using an explicit profile path for tests.
function runConnectionManagerWithPath(path, visible)
  profiles = try(connection_profiles.load(path))
  if typeof(profiles) == "error" then return profiles end if
  window = try(createConnectionWindow(visible))
  if typeof(window) == "error" then return window end if
  rendered = try(renderConnectionProfiles(window, profiles))
  if typeof(rendered) == "error" then gui.destroy(window.hwnd); return rendered end if
  if not visible then gui.destroy(window.hwnd); return true end if
  while gui.isOpen(window.hwnd)
    ignoredPump = gui.pumpMessages()
    event = gui.pollEvent()
    while typeof(event) == "struct"
      if event.message == gui.WM_COMMAND then
        if event.controlId == ID_PROFILE_LIST and event.notification == LBN_SELCHANGE then
          selected = profileByName(profiles, gui.listSelectedText(window.aliasList))
          if selected is not void then ignoredRender = try(renderConnectionProfile(window, selected)) end if
        else if event.controlId == ID_PROFILE_NEW then
          renderNewProfile(window)
          gui.setText(window.statusLabel, "New alias — enter connection details and save.")
        else if event.controlId == ID_PROFILE_TLS then
          if gui.checkBoxChecked(window.tlsCheck) then gui.checkBoxSet(window.trustedCheck, false) end if
        else if event.controlId == ID_PROFILE_TRUSTED then
          if gui.checkBoxChecked(window.trustedCheck) then gui.checkBoxSet(window.tlsCheck, false) end if
        else if event.controlId == ID_PROFILE_SAVE then
          profile = try(profileFromWindow(window))
          if typeof(profile) == "error" then gui.setText(window.statusLabel, "Cannot save: " + profile.message)
          else
            profiles = try(connection_profiles.replace(profiles, profile))
            saved = try(connection_profiles.save(path, profiles))
            if typeof(saved) == "error" then gui.setText(window.statusLabel, "Cannot save: " + saved.message) else renderConnectionProfiles(window, profiles); gui.setText(window.statusLabel, "Alias saved. No password was stored.") end if
          end if
        else if event.controlId == ID_PROFILE_DELETE then
          profiles = connection_profiles.remove(profiles, gui.listSelectedText(window.aliasList))
          saved = try(connection_profiles.save(path, profiles))
          if typeof(saved) == "error" then gui.setText(window.statusLabel, "Cannot delete: " + saved.message) else renderConnectionProfiles(window, profiles); gui.setText(window.statusLabel, "Alias deleted.") end if
        else if event.controlId == ID_PROFILE_CONNECT or (event.controlId == ID_PROFILE_LIST and event.notification == LBN_DBLCLK) then
          profile = try(profileFromWindow(window))
          if typeof(profile) == "error" then gui.setText(window.statusLabel, "Cannot connect: " + profile.message)
          else
            gui.setText(window.statusLabel, "Connecting to " + fullclient.endpointText(profile) + " …")
            state = try(connectFromWindow(window, profile))
            if typeof(state) == "error" then gui.setText(window.statusLabel, "Connection failed: " + connectionFailureText(state))
            else
              gui.destroy(window.hwnd)
              session = try(openState(state, true))
              if typeof(session) == "error" then ignoredClose = try(fullclient.close(state)); return session end if
              return runSession(session)
            end if
          end if
        else if event.controlId == ID_PROFILE_CLOSE or event.controlId == gui.MENU_FILE_EXIT then
          gui.destroy(window.hwnd)
        end if
      end if
      event = gui.pollEvent()
    end while
    gui.sleep(15)
  end while
  return true
end function

// Launches the per-user connection manager.
function launchConnectionManager()
  path = try(connection_profiles.defaultPath())
  if typeof(path) == "error" then return path end if
  return runConnectionManagerWithPath(path, true)
end function

// Runs a hidden connection-manager construction smoke test.
function connectionManagerSmoke(path)
  return runConnectionManagerWithPath(path, false)
end function

// Creates the SQuirreL-style MiniSQL session workbench.
function createWindow(visible)
  hwnd = try(gui.createTopLevel("MiniSQL Workbench", 1440, 900, visible))
  if typeof(hwnd) == "error" then return hwnd end if
  refreshButton = try(gui.createButtonId(hwnd, ID_REFRESH, "↻ Refresh", 12, 10, 92, 34))
  openButton = try(gui.createButtonId(hwnd, ID_OPEN_OBJECT, "Open object", 112, 10, 106, 34))
  newSqlButton = try(gui.createButtonId(hwnd, ID_NEW_SQL, "+ SQL", 226, 10, 70, 34))
  executeButton = try(gui.createDefaultButtonId(hwnd, ID_EXECUTE, "▶ Execute", 312, 10, 100, 34))
  explainButton = try(gui.createButtonId(hwnd, ID_EXPLAIN, "Explain", 420, 10, 82, 34))
  beginButton = try(gui.createButtonId(hwnd, ID_BEGIN, "Begin", 518, 10, 72, 34))
  commitButton = try(gui.createButtonId(hwnd, ID_COMMIT, "Commit", 598, 10, 76, 34))
  rollbackButton = try(gui.createButtonId(hwnd, ID_ROLLBACK, "Rollback", 682, 10, 82, 34))
  stopButton = try(gui.createButtonId(hwnd, ID_STOP, "■ Stop", 780, 10, 72, 34))
  clearButton = try(gui.createButtonId(hwnd, ID_CLEAR, "Clear results", 860, 10, 104, 34))
  closeButton = try(gui.createButtonId(hwnd, ID_CLOSE, "Disconnect", 1318, 10, 102, 34))
  connectionLabel = try(gui.createLabel(hwnd, "Opening MiniSQL session …", 12, 54, 1398, 24))
  sidebarTabs = try(gui.createTabControl(hwnd, ID_SIDEBAR_TABS, 12, 82, 294, 30))
  gui.tabAdd(sidebarTabs, "Objects")
  gui.tabAdd(sidebarTabs, "Bookmarks")
  gui.tabAdd(sidebarTabs, "History")
  objectTree = try(gui.createTreeView(hwnd, ID_OBJECT_TREE, 12, 116, 294, 714))
  bookmarkList = try(gui.createListBoxId(hwnd, ID_BOOKMARK_LIST, 12, 116, 294, 714))
  historyList = try(gui.createListBoxId(hwnd, ID_HISTORY_LIST, 12, 116, 294, 714))
  workspaceTabs = try(gui.createTabControl(hwnd, ID_WORKSPACE_TABS, 320, 82, 1100, 30))
  gui.tabAdd(workspaceTabs, "SQL Worksheet")
  gui.tabAdd(workspaceTabs, "Object Details")
  queryEdit = try(gui.createEdit(hwnd, "SHOW TABLES;", 320, 116, 1100, 310, false))
  resultTabs = try(gui.createTabControl(hwnd, ID_RESULT_TABS, 320, 434, 1100, 30))
  resultGrid = try(gui.createListView(hwnd, ID_RESULT_GRID, 320, 468, 1100, 362))
  detailTabs = try(gui.createTabControl(hwnd, ID_DETAIL_TABS, 320, 116, 1100, 30))
  detailEdit = try(gui.createEdit(hwnd, "Select a table in the object tree and choose Open object.", 320, 150, 1100, 680, true))
  statusLabel = try(gui.createLabel(hwnd, "Ready", 12, 842, 1408, 24))
  window = AdminWindow(hwnd, connectionLabel, sidebarTabs, objectTree, bookmarkList, historyList, workspaceTabs, detailTabs, resultTabs, queryEdit, detailEdit, resultGrid, refreshButton, openButton, newSqlButton, executeButton, explainButton, beginButton, commitButton, rollbackButton, stopButton, clearButton, closeButton, statusLabel)
  gui.tabSelect(sidebarTabs, 0)
  gui.tabSelect(workspaceTabs, 0)
  applyVisibility(window)
  layoutWindow(window)
  return window
end function

// Reflows every workbench pane after a top-level resize.
function layoutWindow(window)
  size = try(gui.clientSize(window.hwnd))
  if typeof(size) == "error" then return size end if
  width = size[0]
  height = size[1]
  if width < 960 then width = 960 end if
  if height < 620 then height = 620 end if
  left = 294
  mainX = left + 26
  mainWidth = width - mainX - 20
  bottom = height - 48
  gui.move(window.closeButton, width - 122, 10, 102, 34)
  gui.move(window.connectionLabel, 12, 54, width - 24, 24)
  gui.move(window.sidebarTabs, 12, 82, left, 30)
  gui.move(window.objectTree, 12, 116, left, bottom - 116)
  gui.move(window.bookmarkList, 12, 116, left, bottom - 116)
  gui.move(window.historyList, 12, 116, left, bottom - 116)
  gui.move(window.workspaceTabs, mainX, 82, mainWidth, 30)
  editorHeight = (bottom - 124) >> 1
  gui.move(window.queryEdit, mainX, 116, mainWidth, editorHeight)
  gui.move(window.resultTabs, mainX, 124 + editorHeight, mainWidth, 30)
  gui.move(window.resultGrid, mainX, 158 + editorHeight, mainWidth, bottom - (158 + editorHeight))
  gui.move(window.detailTabs, mainX, 116, mainWidth, 30)
  gui.move(window.detailEdit, mainX, 150, mainWidth, bottom - 150)
  gui.move(window.statusLabel, 12, height - 36, width - 24, 24)
  return true
end function

// Shows controls belonging to the selected sidebar and workspace tabs.
function applyVisibility(window)
  side = gui.tabSelectedIndex(window.sidebarTabs)
  gui.show(window.objectTree, side == 0)
  gui.show(window.bookmarkList, side == 1)
  gui.show(window.historyList, side == 2)
  workspace = gui.tabSelectedIndex(window.workspaceTabs)
  gui.show(window.queryEdit, workspace == 0)
  gui.show(window.resultTabs, workspace == 0)
  gui.show(window.resultGrid, workspace == 0)
  gui.show(window.detailTabs, workspace == 1)
  gui.show(window.detailEdit, workspace == 1)
  return true
end function

// Populates a list box from ordered display strings.
function fillList(hwnd, values)
  gui.listReset(hwnd)
  for each value in values
    ignored = try(gui.listAdd(hwnd, value))
  end for
  return true
end function

// Rebuilds the MiniSQL-only database object hierarchy.
function fillObjectTree(window, state)
  gui.treeReset(window.objectTree)
  database = try(gui.treeInsert(window.objectTree, 0, state.profile.databaseName, true))
  tables = try(gui.treeInsert(window.objectTree, database, "Tables (" + len(state.tables) + ")", true))
  for each tableName in state.tables
    table = try(gui.treeInsert(window.objectTree, tables, tableName, tableName == state.selectedTable))
    if typeof(table) != "error" and tableName == state.selectedTable then
      ignoredColumns = try(gui.treeInsert(window.objectTree, table, "Columns", false))
      ignoredIndexes = try(gui.treeInsert(window.objectTree, table, "Indexes", false))
      ignoredData = try(gui.treeInsert(window.objectTree, table, "Data", false))
    end if
  end for
  return true
end function

// Replaces tab captions and restores a valid selection.
function fillTabs(hwnd, labels, selected)
  gui.tabReset(hwnd)
  for each label in labels
    ignored = try(gui.tabAdd(hwnd, label))
  end for
  if len(labels) > 0 then
    if selected < 0 or selected >= len(labels) then selected = 0 end if
    gui.tabSelect(hwnd, selected)
  end if
  return true
end function

// Renders the active structured result into the native ListView grid.
function fillResultGrid(window, state)
  gui.listViewReset(window.resultGrid)
  gui.listViewResetColumns(window.resultGrid)
  tab = fullclient.activeResultTab(state)
  if tab is void or len(tab.columns) == 0 then
    gui.listViewAddColumn(window.resultGrid, 0, "Messages", 900)
    if tab is not void then gui.listViewAddRow(window.resultGrid, 0, [tab.resultText]) end if
    return true
  end if
  columnWidth = 180
  for index = 0 to len(tab.columns) - 1
    ignoredColumn = try(gui.listViewAddColumn(window.resultGrid, index, tab.columns[index], columnWidth))
  end for
  for rowIndex = 0 to len(tab.rows) - 1
    ignoredRow = try(gui.listViewAddRow(window.resultGrid, rowIndex, tab.rows[rowIndex]))
  end for
  return true
end function

// Enables query actions only when no native SQL worker owns the client session.
function setBusyControls(session)
  enabled = not session.busy
  gui.setEnabled(session.window.executeButton, enabled)
  gui.setEnabled(session.window.explainButton, enabled)
  gui.setEnabled(session.window.beginButton, enabled)
  gui.setEnabled(session.window.commitButton, enabled)
  gui.setEnabled(session.window.rollbackButton, enabled)
  gui.setEnabled(session.window.refreshButton, enabled)
  gui.setEnabled(session.window.openButton, enabled)
  gui.setEnabled(session.window.stopButton, session.busy)
  return true
end function

// Renders all workbench panes from the current fullclient model.
function render(session)
  fillObjectTree(session.window, session.state)
  fillList(session.window.bookmarkList, fullclient.bookmarkLines(session.state.bookmarks))
  fillList(session.window.historyList, session.state.history)
  fillTabs(session.window.detailTabs, fullclient.detailTabLines(session.state), 0)
  fillTabs(session.window.resultTabs, fullclient.resultTabLines(session.state.resultTabs), session.state.selectedResultIndex)
  fillResultGrid(session.window, session.state)
  detailName = "Database"
  labels = fullclient.detailTabLines(session.state)
  if len(labels) > 0 then detailName = labels[0] end if
  gui.setText(session.window.detailEdit, fullclient.detailTextByName(session.state, detailName))
  gui.setText(session.window.connectionLabel, session.state.profile.name + "   •   " + fullclient.endpointText(session.state.profile))
  gui.setText(session.window.statusLabel, session.state.statusText)
  setBusyControls(session)
  applyVisibility(session.window)
  layoutWindow(session.window)
  return true
end function

// Wraps an existing connected state in a native workbench window.
function openState(state, visible)
  window = try(createWindow(visible))
  if typeof(window) == "error" then return window end if
  session = AdminSession(window, state, void, false)
  rendered = try(render(session))
  if typeof(rendered) == "error" then gui.destroy(window.hwnd); return rendered end if
  return session
end function

// Opens a profile directly for command-line and network smoke workflows.
function openProfile(profile, passwordBytes, visible)
  state = try(fullclient.openProfile(profile, passwordBytes))
  if typeof(state) == "error" then return state end if
  session = try(openState(state, visible))
  if typeof(session) == "error" then ignoredClose = try(fullclient.close(state)); return session end if
  return session
end function

// Executes editor SQL on a native worker thread.
function queryWorker(task)
  if task.explain then return fullclient.explainSql(task.state, task.sqlText) end if
  if task.sqlText == "BEGIN;" then return fullclient.beginTransaction(task.state) end if
  if task.sqlText == "COMMIT;" then return fullclient.commitTransaction(task.state) end if
  if task.sqlText == "ROLLBACK;" then return fullclient.rollbackTransaction(task.state) end if
  return fullclient.executeSql(task.state, task.sqlText)
end function

// Starts a responsive background SQL execution.
function startQuery(session, sqlText, explain)
  if session.busy then return fail("startQuery", "a query is already running") end if
  worker = Thread(queryWorker, "minisql-workbench-query")
  if not worker.Start(QueryTask(session.state, sqlText, explain)) then return fail("startQuery", "native SQL worker could not be started") end if
  session.worker = worker
  session.busy = true
  session.state.statusText = "Executing SQL on a native worker thread …"
  setBusyControls(session)
  gui.setText(session.window.statusLabel, session.state.statusText)
  return true
end function

// Publishes a completed worker result and refreshes database metadata.
function pollQuery(session)
  if not session.busy or session.worker is void then return false end if
  if not session.worker.Join(0) then return false end if
  result = try(session.worker.Result())
  ignoredClose = session.worker.Close()
  session.worker = void
  session.busy = false
  if typeof(result) == "error" then session.state.statusText = "Query failed: " + result.message end if
  completionStatus = session.state.statusText
  refreshed = try(fullclient.refresh(session.state))
  if typeof(refreshed) == "error" and typeof(result) != "error" then session.state.statusText = "Query completed; object refresh failed: " + refreshed.message end if
  if typeof(refreshed) != "error" then session.state.statusText = completionStatus + "   •   " + len(session.state.tables) + " table(s)" end if
  render(session)
  return true
end function

// Stops the native worker before disconnecting the affected session.
function stopQuery(session)
  if not session.busy or session.worker is void then return false end if
  stopped = session.worker.Stop()
  ignoredJoin = session.worker.Join(2000)
  ignoredClose = session.worker.Close()
  session.worker = void
  session.busy = false
  session.state.statusText = "Execution stopped. Disconnecting this session to preserve protocol framing."
  gui.setText(session.window.statusLabel, session.state.statusText)
  gui.destroy(session.window.hwnd)
  return stopped
end function

// Opens table details for the current object-tree selection.
function openSelectedObject(session)
  selected = try(gui.treeSelectedText(session.window.objectTree))
  if typeof(selected) != "string" or not fullclient.containsText(session.state.tables, selected) then session.state.statusText = "Select a table in the object tree"; return false end if
  details = try(fullclient.describeTable(session.state, selected))
  if typeof(details) == "error" then session.state.statusText = "Cannot open table: " + details.message; return false end if
  gui.tabSelect(session.window.workspaceTabs, 1)
  render(session)
  return true
end function

// Inserts a table preview query for the selected object.
function querySelectedObject(session)
  selected = try(gui.treeSelectedText(session.window.objectTree))
  if typeof(selected) != "string" or not fullclient.containsText(session.state.tables, selected) then session.state.statusText = "Select a table in the object tree"; return false end if
  sqlText = try(fullclient.queryForTable(session.state, selected))
  if typeof(sqlText) == "error" then return false end if
  gui.setText(session.window.queryEdit, sqlText)
  gui.tabSelect(session.window.workspaceTabs, 0)
  applyVisibility(session.window)
  gui.focus(session.window.queryEdit)
  return true
end function

// Inserts a selected bookmark into the SQL worksheet.
function insertSelectedBookmark(session)
  label = try(gui.listSelectedText(session.window.bookmarkList))
  sqlText = fullclient.bookmarkSqlForSelection(session.state, label)
  if len(sqlText) == 0 then session.state.statusText = "This bookmark requires a selected table"; gui.setText(session.window.statusLabel, session.state.statusText); return false end if
  gui.setText(session.window.queryEdit, sqlText)
  gui.tabSelect(session.window.workspaceTabs, 0)
  applyVisibility(session.window)
  gui.focus(session.window.queryEdit)
  return true
end function

// Reopens a redacted history item in the SQL worksheet.
function insertSelectedHistory(session)
  sqlText = try(gui.listSelectedText(session.window.historyList))
  if typeof(sqlText) != "string" or len(sqlText) == 0 or fullclient.textContains(sqlText, "redacted") then return false end if
  gui.setText(session.window.queryEdit, sqlText)
  gui.tabSelect(session.window.workspaceTabs, 0)
  applyVisibility(session.window)
  gui.focus(session.window.queryEdit)
  return true
end function

// Handles a native menu or toolbar command.
function handleCommand(session, command)
  if session.busy and command != ID_STOP and command != gui.MENU_SQL_CANCEL and command != ID_CLOSE and command != gui.MENU_FILE_CLOSE and command != gui.MENU_FILE_EXIT then return true end if
  if command == ID_CLOSE or command == gui.MENU_FILE_CLOSE or command == gui.MENU_FILE_EXIT then
    if session.busy then stopQuery(session) else gui.destroy(session.window.hwnd) end if
  else if command == ID_REFRESH or command == gui.MENU_SESSION_REFRESH then
    refreshed = try(fullclient.refresh(session.state))
    if typeof(refreshed) == "error" then session.state.statusText = "Refresh failed: " + refreshed.message end if
    render(session)
  else if command == ID_OPEN_OBJECT or command == gui.MENU_OBJECT_DESCRIBE then
    openSelectedObject(session)
    render(session)
  else if command == gui.MENU_OBJECT_QUERY then
    querySelectedObject(session)
  else if command == ID_NEW_SQL or command == gui.MENU_FILE_NEW then
    gui.setText(session.window.queryEdit, "")
    gui.tabSelect(session.window.workspaceTabs, 0)
    applyVisibility(session.window)
    gui.focus(session.window.queryEdit)
  else if command == ID_EXECUTE or command == gui.MENU_SQL_EXECUTE then
    sqlText = try(gui.getText(session.window.queryEdit))
    if typeof(sqlText) == "error" then session.state.statusText = "Cannot read SQL editor: " + sqlText.message else started = try(startQuery(session, sqlText, false)); if typeof(started) == "error" then session.state.statusText = started.message end if end if
  else if command == ID_EXPLAIN or command == gui.MENU_SQL_EXPLAIN then
    sqlText = try(gui.getText(session.window.queryEdit))
    if typeof(sqlText) == "error" then session.state.statusText = "Cannot read SQL editor: " + sqlText.message else started = try(startQuery(session, sqlText, true)); if typeof(started) == "error" then session.state.statusText = started.message end if end if
  else if command == ID_BEGIN then
    startQuery(session, "BEGIN;", false)
  else if command == ID_COMMIT or command == gui.MENU_SESSION_COMMIT then
    startQuery(session, "COMMIT;", false)
  else if command == ID_ROLLBACK or command == gui.MENU_SESSION_ROLLBACK then
    startQuery(session, "ROLLBACK;", false)
  else if command == ID_STOP or command == gui.MENU_SQL_CANCEL then
    stopQuery(session)
  else if command == ID_CLEAR or command == gui.MENU_SQL_CLEAR then
    fullclient.clearResultTabs(session.state)
    render(session)
  else if command == gui.MENU_HELP_ABOUT then
    gui.showInfo(session.window.hwnd, "About MiniSQL Workbench", "MiniSQL Workbench\r\n\r\nA native Windows SQL client inspired by the SQuirreL SQL workflow and built exclusively for MiniSQL.")
  end if
  gui.setText(session.window.statusLabel, session.state.statusText)
  return true
end function

// Runs the responsive Win32 event loop for one connected session.
function runSession(session)
  while gui.isOpen(session.window.hwnd)
    ignoredPump = gui.pumpMessages()
    ignoredWorker = pollQuery(session)
    event = gui.pollEvent()
    while typeof(event) == "struct"
      if event.message == gui.WM_SIZE then
        layoutWindow(session.window)
      else if event.message == gui.WM_NOTIFY then
        if event.controlId == ID_SIDEBAR_TABS and event.notification == TCN_SELCHANGE then
          applyVisibility(session.window)
        else if event.controlId == ID_WORKSPACE_TABS and event.notification == TCN_SELCHANGE then
          applyVisibility(session.window)
        else if event.controlId == ID_DETAIL_TABS and event.notification == TCN_SELCHANGE then
          labels = fullclient.detailTabLines(session.state)
          selected = gui.tabSelectedIndex(session.window.detailTabs)
          if selected >= 0 and selected < len(labels) then gui.setText(session.window.detailEdit, fullclient.detailTextByName(session.state, labels[selected])) end if
        else if event.controlId == ID_RESULT_TABS and event.notification == TCN_SELCHANGE then
          selected = gui.tabSelectedIndex(session.window.resultTabs)
          if selected >= 0 and selected < len(session.state.resultTabs) then session.state.selectedResultIndex = selected; fillResultGrid(session.window, session.state) end if
        else if event.controlId == ID_OBJECT_TREE and event.notification == TVN_SELCHANGEDW then
          selectedObject = try(gui.treeSelectedText(session.window.objectTree))
          if typeof(selectedObject) == "string" and fullclient.containsText(session.state.tables, selectedObject) then session.state.selectedTable = selectedObject; session.state.statusText = "Selected table " + selectedObject; gui.setText(session.window.statusLabel, session.state.statusText) end if
        else if event.controlId == ID_OBJECT_TREE and event.notification == NM_DBLCLK then
          openSelectedObject(session)
        end if
      else if event.message == gui.WM_COMMAND then
        if event.controlId == ID_BOOKMARK_LIST and event.notification == LBN_DBLCLK then insertSelectedBookmark(session)
        else if event.controlId == ID_HISTORY_LIST and event.notification == LBN_DBLCLK then insertSelectedHistory(session)
        else handleCommand(session, event.controlId)
        end if
      end if
      event = gui.pollEvent()
    end while
    gui.sleep(10)
  end while
  if session.busy then stopQuery(session) end if
  closed = try(fullclient.close(session.state))
  if typeof(closed) == "error" then return closed end if
  return true
end function

// Runs a hidden workbench construction smoke test against an existing state.
function stateSmoke(state)
  session = try(openState(state, false))
  if typeof(session) == "error" then return session end if
  rendered = try(render(session))
  gui.destroy(session.window.hwnd)
  if typeof(rendered) == "error" then return rendered end if
  return true
end function

// Returns the stable module name used by smoke tests.
function componentName()
  return "admin.win32_client"
end function

// Identifies the GUI integration milestone.
function targetMilestone()
  return "M74"
end function

// Reports that the native workbench is implemented.
function isImplemented()
  return true
end function
