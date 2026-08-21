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

const QUERY_EXECUTE = 1
const QUERY_EXPLAIN = 2
const QUERY_BEGIN = 3
const QUERY_COMMIT = 4
const QUERY_ROLLBACK = 5
const QUERY_REFRESH = 6
const QUERY_DESCRIBE = 7

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
  // Stores the primary connection-manager heading.
  titleLabel
  // Stores the explanatory connection-manager subheading.
  subtitleLabel
  // Stores the alias list control.
  aliasList
  // Stores the section heading above editable connection fields.
  detailsLabel
  // Stores the ordered labels paired with the connection editors.
  fieldLabels
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
  // Stores the explanatory certificate and password note.
  hintLabel
  // Stores the new-alias action button.
  newButton
  // Stores the delete-alias action button.
  deleteButton
  // Stores the save-alias action button.
  saveButton
  // Stores the default connect action button.
  connectButton
  // Stores the close-window action button.
  closeButton
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

// Bundles immutable input for any protocol operation executed off the UI thread.
struct QueryTask
  // Stores the fullclient state owned by the session.
  state
  // Selects execute, transaction, refresh, or table-description behavior.
  operation
  // Stores SQL submitted to execute or explain operations.
  sqlText
  // Stores the table selected for an asynchronous description operation.
  tableName
end struct

// Carries one worker result and its optional object-tree refresh back to the UI.
struct QueryCompletion
  // Identifies the operation that produced this completion.
  operation
  // Stores the primary operation result or structured error.
  result
  // Stores the follow-up refresh result or void when no refresh was required.
  refreshResult
  // Preserves the primary status text before a refresh updates shared state.
  statusText
end struct

// Owns credentials while one connection handshake runs outside the UI thread.
struct ConnectionTask
  // Stores the validated, secret-free connection profile.
  profile
  // Stores transient password bytes read from the password editor.
  password
end struct

// Tracks a connection worker and guarantees eventual credential destruction.
struct ConnectionAttempt
  // Stores the active native handshake worker or void.
  worker
  // Stores the caller-owned password bytes until the worker has terminated.
  password
  // Indicates whether a handshake is currently in flight.
  busy
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
  // Records whether the editor currently contains a submitted secret-bearing DCL statement.
  sensitiveSql
  // Requires transport abort because cancellation invalidated protocol framing.
  aborted
end struct

// Creates a namespaced GUI-controller error.
function fail(operation, message)
  return error(INVALID_ARGUMENT, "admin.win32_client." + operation + ": " + message)
end function

// Returns the first failed native-control creation from a heterogeneous handle array.
function firstControlError(controls)
  for each control in controls
    if typeof(control) == "error" then return control end if
  end for
  return void
end function

// Creates the modern alias manager used before a MiniSQL session opens.
function createConnectionWindow(visible)
  hwnd = try(gui.createTopLevel("MiniSQL Workbench — Connections", 940, 650, false))
  if typeof(hwnd) == "error" then return hwnd end if
  ignoredMenu = try(gui.attachConnectionMenuBar(hwnd))
  if typeof(ignoredMenu) == "error" then gui.destroy(hwnd); return ignoredMenu end if
  if not ignoredMenu then gui.destroy(hwnd); return fail("createConnectionWindow", "connection menu could not be attached") end if
  ignoredSize = try(gui.setClientSizeDip(hwnd, 940, 650, true))
  if typeof(ignoredSize) == "error" then gui.destroy(hwnd); return ignoredSize end if
  if not ignoredSize then gui.destroy(hwnd); return fail("createConnectionWindow", "initial client size could not be applied") end if
  gui.setMinimumClientSizeDip(hwnd, 760, 650)
  titleLabel = try(gui.createLabel(hwnd, "MiniSQL connections", 0, 0, 10, 10))
  subtitleLabel = try(gui.createLabel(hwnd, "Choose an alias or configure a new MiniSQL endpoint.", 0, 0, 10, 10))
  aliasList = try(gui.createListBoxId(hwnd, ID_PROFILE_LIST, 20, 82, 278, 466))
  detailsLabel = try(gui.createLabel(hwnd, "Connection details", 0, 0, 10, 10))
  labels = ["Alias name", "Server address", "Port", "Database label", "MiniSQL user", "Password", "TLS server name", "SHA-256 certificate pin"]
  fieldLabels = []
  for index = 0 to len(labels) - 1
    fieldLabel = try(gui.createLabel(hwnd, labels[index], 0, 0, 10, 10))
    fieldLabels = fieldLabels + [fieldLabel]
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
  hintLabel = try(gui.createLabel(hwnd, "Pins are optional and useful for self-signed certificates. Passwords are never saved.", 0, 0, 10, 10))
  newButton = try(gui.createButtonId(hwnd, ID_PROFILE_NEW, "New", 0, 0, 10, 10))
  deleteButton = try(gui.createButtonId(hwnd, ID_PROFILE_DELETE, "Delete", 0, 0, 10, 10))
  saveButton = try(gui.createButtonId(hwnd, ID_PROFILE_SAVE, "Save alias", 0, 0, 10, 10))
  connectButton = try(gui.createDefaultButtonId(hwnd, ID_PROFILE_CONNECT, "Connect", 0, 0, 10, 10))
  closeButton = try(gui.createButtonId(hwnd, ID_PROFILE_CLOSE, "Close", 0, 0, 10, 10))
  statusLabel = try(gui.createLabel(hwnd, "Ready", 20, 610, 862, 22))
  controlFailure = firstControlError([titleLabel, subtitleLabel, aliasList, detailsLabel, nameEdit, addressEdit, portEdit, serverEdit, databaseEdit, userEdit, passwordEdit, pinEdit, tlsCheck, trustedCheck, hintLabel, newButton, deleteButton, saveButton, connectButton, closeButton, statusLabel] + fieldLabels)
  if controlFailure is not void then gui.destroy(hwnd); return controlFailure end if
  window = ConnectionWindow(hwnd, titleLabel, subtitleLabel, aliasList, detailsLabel, fieldLabels, nameEdit, addressEdit, portEdit, serverEdit, databaseEdit, userEdit, passwordEdit, pinEdit, tlsCheck, trustedCheck, hintLabel, newButton, deleteButton, saveButton, connectButton, closeButton, statusLabel)
  laidOut = try(layoutConnectionWindow(window))
  if typeof(laidOut) == "error" then gui.destroy(hwnd); return laidOut end if
  if visible and not gui.showTopLevel(hwnd) then gui.destroy(hwnd); return fail("createConnectionWindow", "top-level window could not be shown") end if
  return window
end function

// Reflows the alias list and all connection fields in logical DPI-independent units.
function layoutConnectionWindow(window)
  size = try(gui.clientSizeDip(window.hwnd))
  if typeof(size) == "error" then return size end if
  width = size[0]
  height = size[1]
  if width < 760 then width = 760 end if
  if height < 650 then height = 650 end if
  margin = 20
  listWidth = gui.divideInt(width * 30, 100)
  if listWidth < 220 then listWidth = 220 end if
  if listWidth > 300 then listWidth = 300 end if
  detailsX = margin + listWidth + 24
  detailsWidth = width - detailsX - margin
  labelWidth = 184
  if detailsWidth < 520 then labelWidth = 148 end if
  editorX = detailsX + labelWidth + 12
  editorWidth = detailsWidth - labelWidth - 12
  buttonY = height - 72
  statusY = height - 32
  contentBottom = buttonY - 14
  gui.moveDip(window.titleLabel, margin, 16, width - margin * 2, 26)
  gui.moveDip(window.subtitleLabel, margin, 44, width - margin * 2, 24)
  gui.moveDip(window.aliasList, margin, 82, listWidth, contentBottom - 82)
  gui.moveDip(window.detailsLabel, detailsX, 82, detailsWidth, 28)
  editors = [window.nameEdit, window.addressEdit, window.portEdit, window.databaseEdit, window.userEdit, window.passwordEdit, window.serverEdit, window.pinEdit]
  for index = 0 to len(editors) - 1
    rowY = 116 + index * 39
    gui.moveDip(window.fieldLabels[index], detailsX, rowY + 3, labelWidth, 24)
    currentWidth = editorWidth
    if index == 2 and currentWidth > 150 then currentWidth = 150 end if
    gui.moveDip(editors[index], editorX, rowY, currentWidth, 28)
  end for
  checksY = 430
  checkWidth = (detailsWidth - 12) >> 1
  gui.moveDip(window.tlsCheck, detailsX, checksY, checkWidth, 28)
  gui.moveDip(window.trustedCheck, detailsX + checkWidth + 12, checksY, checkWidth, 28)
  gui.moveDip(window.hintLabel, detailsX, checksY + 34, detailsWidth, 42)
  gui.moveDip(window.newButton, margin, buttonY, 82, 34)
  gui.moveDip(window.deleteButton, margin + 92, buttonY, 82, 34)
  gui.moveDip(window.saveButton, margin + 184, buttonY, 102, 34)
  gui.moveDip(window.connectButton, width - margin - 198, buttonY, 104, 34)
  gui.moveDip(window.closeButton, width - margin - 84, buttonY, 84, 34)
  gui.moveDip(window.statusLabel, margin, statusY, width - margin * 2, 24)
  gui.redraw(window.hwnd)
  return true
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

// Reads transient credentials, allowing password-free trusted-local sessions.
function passwordFromWindow(window, profile)
  if profile.trustedLocal then
    gui.setText(window.passwordEdit, "")
    return bytes(0)
  end if
  return gui.getSecretBytes(window.passwordEdit)
end function

// Opens one profile on a native worker so DNS, TCP, TLS, and authentication cannot freeze the UI.
function connectionWorker(task)
  return fullclient.openProfile(task.profile, task.password)
end function

// Prevents profile edits while the worker reads its immutable profile snapshot.
function setConnectionBusy(window, busy)
  enabled = not busy
  gui.setEnabled(window.aliasList, enabled)
  gui.setEnabled(window.nameEdit, enabled)
  gui.setEnabled(window.addressEdit, enabled)
  gui.setEnabled(window.portEdit, enabled)
  gui.setEnabled(window.serverEdit, enabled)
  gui.setEnabled(window.databaseEdit, enabled)
  gui.setEnabled(window.userEdit, enabled)
  gui.setEnabled(window.passwordEdit, enabled)
  gui.setEnabled(window.pinEdit, enabled)
  gui.setEnabled(window.tlsCheck, enabled)
  gui.setEnabled(window.trustedCheck, enabled)
  gui.setEnabled(window.newButton, enabled)
  gui.setEnabled(window.deleteButton, enabled)
  gui.setEnabled(window.saveButton, enabled)
  gui.setEnabled(window.connectButton, enabled)
  return true
end function

// Starts an asynchronous connection attempt and transfers password ownership to it.
function startConnection(window, profile)
  password = try(passwordFromWindow(window, profile))
  if typeof(password) == "error" then return password end if
  worker = Thread(connectionWorker, "minisql-workbench-connect")
  if not worker.Start(ConnectionTask(profile, password)) then
    uuid.wipeSecret(password)
    return fail("startConnection", "native connection worker could not be started")
  end if
  setConnectionBusy(window, true)
  return ConnectionAttempt(worker, password, true)
end function

// Returns void while connecting, then publishes the state or error and wipes credentials.
function pollConnection(attempt)
  if not attempt.busy or attempt.worker is void then return void end if
  if not attempt.worker.Join(0) then return void end if
  result = try(attempt.worker.Result())
  ignoredClose = attempt.worker.Close()
  uuid.wipeSecret(attempt.password)
  attempt.worker = void
  attempt.password = bytes(0)
  attempt.busy = false
  return result
end function

// Cancels a handshake without wiping bytes until the native worker has terminated.
function stopConnection(attempt)
  if not attempt.busy or attempt.worker is void then return true end if
  if attempt.worker.Join(0) then
    completed = try(attempt.worker.Result())
    if typeof(completed) == "struct" then ignoredStateClose = try(fullclient.close(completed)) end if
  else
    ignoredStop = attempt.worker.Stop()
    if not attempt.worker.Join(2000) then return fail("stopConnection", "connection worker did not terminate") end if
  end if
  ignoredClose = attempt.worker.Close()
  uuid.wipeSecret(attempt.password)
  attempt.worker = void
  attempt.password = bytes(0)
  attempt.busy = false
  return true
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
  attempt = ConnectionAttempt(void, bytes(0), false)
  while gui.isOpen(window.hwnd)
    ignoredPump = gui.pumpMessages()
    connected = void
    if gui.isOpen(window.hwnd) then connected = pollConnection(attempt) end if
    if connected is not void then
      setConnectionBusy(window, false)
      if typeof(connected) == "error" then
        gui.setText(window.statusLabel, "Connection failed: " + connectionFailureText(connected))
      else
        gui.destroy(window.hwnd)
        session = try(openState(connected, true))
        if typeof(session) == "error" then ignoredStateClose = try(fullclient.close(connected)); return session end if
        return runSession(session)
      end if
    end if
    event = gui.pollEvent()
    while typeof(event) == "struct"
      // The GUI abstraction owns one process-wide event queue; stale events
      // from a just-closed workbench must never control this new window.
      if event.hwnd != window.hwnd then
        ignoredForeignEvent = true
      else if event.message == gui.WM_SIZE or event.message == gui.WM_DPICHANGED then
        layoutConnectionWindow(window)
      else if event.message == gui.WM_COMMAND then
        command = event.controlId
        if attempt.busy and command != ID_PROFILE_CLOSE and command != gui.MENU_FILE_CLOSE and command != gui.MENU_FILE_EXIT and command != gui.MENU_HELP_ABOUT then
          gui.setText(window.statusLabel, "Connection handshake is still running …")
        else if command == ID_PROFILE_LIST and event.notification == LBN_SELCHANGE then
          selected = profileByName(profiles, gui.listSelectedText(window.aliasList))
          if selected is not void then ignoredRender = try(renderConnectionProfile(window, selected)) end if
        else if command == ID_PROFILE_NEW or command == gui.MENU_ALIAS_NEW or command == gui.MENU_FILE_NEW then
          renderNewProfile(window)
          gui.setText(window.statusLabel, "New alias — enter connection details and save.")
          gui.focus(window.nameEdit)
        else if command == gui.MENU_ALIAS_EDIT then
          gui.setText(window.statusLabel, "Edit the selected alias, then choose Save alias.")
          gui.focus(window.nameEdit)
        else if command == ID_PROFILE_TLS then
          if gui.checkBoxChecked(window.tlsCheck) then gui.checkBoxSet(window.trustedCheck, false) end if
        else if command == ID_PROFILE_TRUSTED then
          if gui.checkBoxChecked(window.trustedCheck) then gui.checkBoxSet(window.tlsCheck, false) end if
        else if command == ID_PROFILE_SAVE or command == gui.MENU_ALIAS_SAVE then
          profile = try(profileFromWindow(window))
          if typeof(profile) == "error" then gui.setText(window.statusLabel, "Cannot save: " + profile.message)
          else
            profiles = try(connection_profiles.replace(profiles, profile))
            saved = try(connection_profiles.save(path, profiles))
            if typeof(saved) == "error" then gui.setText(window.statusLabel, "Cannot save: " + saved.message) else renderConnectionProfiles(window, profiles); gui.setText(window.statusLabel, "Alias saved. No password was stored.") end if
          end if
        else if command == ID_PROFILE_DELETE or command == gui.MENU_ALIAS_DELETE then
          profiles = connection_profiles.remove(profiles, gui.listSelectedText(window.aliasList))
          saved = try(connection_profiles.save(path, profiles))
          if typeof(saved) == "error" then gui.setText(window.statusLabel, "Cannot delete: " + saved.message) else renderConnectionProfiles(window, profiles); gui.setText(window.statusLabel, "Alias deleted.") end if
        else if command == ID_PROFILE_CONNECT or command == gui.MENU_ALIAS_CONNECT or (command == ID_PROFILE_LIST and event.notification == LBN_DBLCLK) then
          profile = try(profileFromWindow(window))
          if typeof(profile) == "error" then gui.setText(window.statusLabel, "Cannot connect: " + profile.message)
          else
            gui.setText(window.statusLabel, "Connecting to " + fullclient.endpointText(profile) + " …")
            started = try(startConnection(window, profile))
            if typeof(started) == "error" then gui.setText(window.statusLabel, "Connection failed: " + connectionFailureText(started)) else attempt = started end if
          end if
        else if command == gui.MENU_HELP_ABOUT then
          gui.showInfo(window.hwnd, "About MiniSQL Workbench", "MiniSQL Workbench\r\n\r\nA native Windows SQL client built exclusively for MiniSQL.")
        else if command == ID_PROFILE_CLOSE or command == gui.MENU_FILE_CLOSE or command == gui.MENU_FILE_EXIT then
          stopped = try(stopConnection(attempt))
          if typeof(stopped) == "error" then gui.setText(window.statusLabel, "Cannot close safely: " + stopped.message) else gui.destroy(window.hwnd) end if
        end if
      end if
      event = gui.pollEvent()
    end while
    gui.sleep(15)
  end while
  if attempt.busy then
    stopped = try(stopConnection(attempt))
    if typeof(stopped) == "error" then return stopped end if
  end if
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

// Returns true when a child rectangle is positive and fully contained by a client area.
function rectangleInside(rectangle, width, height)
  if typeof(rectangle) != "array" or len(rectangle) != 4 then return false end if
  return rectangle[0] >= 0 and rectangle[1] >= 0 and rectangle[2] > 0 and rectangle[3] > 0 and rectangle[0] + rectangle[2] <= width + 2 and rectangle[1] + rectangle[3] <= height + 2
end function

// Detects whether two parent-relative rectangles consume the same layout area.
function rectanglesOverlap(first, second)
  if typeof(first) != "array" or typeof(second) != "array" or len(first) != 4 or len(second) != 4 then return true end if
  return first[0] < second[0] + second[2] and second[0] < first[0] + first[2] and first[1] < second[1] + second[3] and second[1] < first[1] + first[3]
end function

// Verifies one responsive connection-manager size through actual Win32 child rectangles.
function verifyConnectionLayout(window, width, height)
  resized = try(gui.setClientSizeDip(window.hwnd, width, height, true))
  if typeof(resized) == "error" or not resized then return fail("verifyConnectionLayout", "top-level resize failed") end if
  laidOut = try(layoutConnectionWindow(window))
  if typeof(laidOut) == "error" then return laidOut end if
  actual = try(gui.clientSizeDip(window.hwnd))
  if typeof(actual) == "error" then return actual end if
  controls = [window.titleLabel, window.subtitleLabel, window.aliasList, window.detailsLabel, window.nameEdit, window.addressEdit, window.portEdit, window.databaseEdit, window.userEdit, window.passwordEdit, window.serverEdit, window.pinEdit, window.tlsCheck, window.trustedCheck, window.hintLabel, window.newButton, window.deleteButton, window.saveButton, window.connectButton, window.closeButton, window.statusLabel]
  for each control in controls
    rectangle = try(gui.controlRectDip(window.hwnd, control))
    if typeof(rectangle) == "error" or not rectangleInside(rectangle, actual[0], actual[1]) then return fail("verifyConnectionLayout", "a connection control is outside the client area") end if
  end for
  aliasRect = try(gui.controlRectDip(window.hwnd, window.aliasList))
  nameLabelRect = try(gui.controlRectDip(window.hwnd, window.fieldLabels[0]))
  nameEditRect = try(gui.controlRectDip(window.hwnd, window.nameEdit))
  connectRect = try(gui.controlRectDip(window.hwnd, window.connectButton))
  closeRect = try(gui.controlRectDip(window.hwnd, window.closeButton))
  if rectanglesOverlap(aliasRect, nameEditRect) or rectanglesOverlap(nameLabelRect, nameEditRect) then return fail("verifyConnectionLayout", "connection panes or label/editor columns overlap") end if
  if rectanglesOverlap(connectRect, closeRect) then return fail("verifyConnectionLayout", "connection actions overlap") end if
  return true
end function

// Exercises responsive geometry, editor roundtrips, checkboxes, and command delivery for supplied aliases.
function connectionLayoutProbe(profiles)
  window = try(createConnectionWindow(false))
  if typeof(window) == "error" then return window end if
  rendered = void
  if len(profiles) > 0 then rendered = try(renderConnectionProfiles(window, profiles)) else rendered = try(renderNewProfile(window)) end if
  if typeof(rendered) == "error" then gui.destroy(window.hwnd); return rendered end if
  compact = try(verifyConnectionLayout(window, 760, 650))
  if typeof(compact) == "error" then gui.destroy(window.hwnd); return compact end if
  wide = try(verifyConnectionLayout(window, 1280, 820))
  if typeof(wide) == "error" then gui.destroy(window.hwnd); return wide end if
  gui.setText(window.nameEdit, "Keyboard Test Alias")
  if gui.getText(window.nameEdit) != "Keyboard Test Alias" then gui.destroy(window.hwnd); return fail("connectionLayoutSmoke", "editable alias text did not roundtrip") end if
  gui.checkBoxSet(window.tlsCheck, true)
  if not gui.checkBoxChecked(window.tlsCheck) then gui.destroy(window.hwnd); return fail("connectionLayoutSmoke", "TLS checkbox did not retain state") end if
  gui.clearEvents()
  if not gui.postCommandForTest(window.hwnd, ID_PROFILE_NEW) then gui.destroy(window.hwnd); return fail("connectionLayoutSmoke", "button command could not be posted") end if
  gui.pumpMessages()
  received = false
  event = gui.pollEvent()
  while typeof(event) == "struct"
    if event.message == gui.WM_COMMAND and event.controlId == ID_PROFILE_NEW then received = true end if
    event = gui.pollEvent()
  end while
  gui.destroy(window.hwnd)
  if not received then return fail("connectionLayoutSmoke", "button command was not delivered") end if
  return true
end function

// Loads aliases from a test path and runs the complete connection-layout probe.
function connectionLayoutSmoke(path)
  profiles = try(connection_profiles.load(path))
  if typeof(profiles) == "error" then return profiles end if
  return connectionLayoutProbe(profiles)
end function

// Creates the SQuirreL-style MiniSQL session workbench.
function createWindow(visible)
  hwnd = try(gui.createTopLevel("MiniSQL Workbench", 1440, 900, false))
  if typeof(hwnd) == "error" then return hwnd end if
  ignoredMenu = try(gui.attachWorkbenchMenuBar(hwnd))
  if typeof(ignoredMenu) == "error" then gui.destroy(hwnd); return ignoredMenu end if
  if not ignoredMenu then gui.destroy(hwnd); return fail("createWindow", "workbench menu could not be attached") end if
  ignoredSize = try(gui.setClientSizeDip(hwnd, 1440, 900, true))
  if typeof(ignoredSize) == "error" then gui.destroy(hwnd); return ignoredSize end if
  if not ignoredSize then gui.destroy(hwnd); return fail("createWindow", "initial client size could not be applied") end if
  gui.setMinimumClientSizeDip(hwnd, 980, 650)
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
  objectTree = try(gui.createTreeView(hwnd, ID_OBJECT_TREE, 12, 116, 294, 714))
  bookmarkList = try(gui.createListBoxId(hwnd, ID_BOOKMARK_LIST, 12, 116, 294, 714))
  historyList = try(gui.createListBoxId(hwnd, ID_HISTORY_LIST, 12, 116, 294, 714))
  workspaceTabs = try(gui.createTabControl(hwnd, ID_WORKSPACE_TABS, 320, 82, 1100, 30))
  queryEdit = try(gui.createEdit(hwnd, "SHOW TABLES;", 320, 116, 1100, 310, false))
  resultTabs = try(gui.createTabControl(hwnd, ID_RESULT_TABS, 320, 434, 1100, 30))
  resultGrid = try(gui.createListView(hwnd, ID_RESULT_GRID, 320, 468, 1100, 362))
  detailTabs = try(gui.createTabControl(hwnd, ID_DETAIL_TABS, 320, 116, 1100, 30))
  detailEdit = try(gui.createEdit(hwnd, "Select a table in the object tree and choose Open object.", 320, 150, 1100, 680, true))
  statusLabel = try(gui.createLabel(hwnd, "Ready", 12, 842, 1408, 24))
  controlFailure = firstControlError([refreshButton, openButton, newSqlButton, executeButton, explainButton, beginButton, commitButton, rollbackButton, stopButton, clearButton, closeButton, connectionLabel, sidebarTabs, objectTree, bookmarkList, historyList, workspaceTabs, queryEdit, resultTabs, resultGrid, detailTabs, detailEdit, statusLabel])
  if controlFailure is not void then gui.destroy(hwnd); return controlFailure end if
  window = AdminWindow(hwnd, connectionLabel, sidebarTabs, objectTree, bookmarkList, historyList, workspaceTabs, detailTabs, resultTabs, queryEdit, detailEdit, resultGrid, refreshButton, openButton, newSqlButton, executeButton, explainButton, beginButton, commitButton, rollbackButton, stopButton, clearButton, closeButton, statusLabel)
  gui.tabAdd(sidebarTabs, "Objects")
  gui.tabAdd(sidebarTabs, "Bookmarks")
  gui.tabAdd(sidebarTabs, "History")
  gui.tabAdd(workspaceTabs, "SQL Worksheet")
  gui.tabAdd(workspaceTabs, "Object Details")
  gui.tabSelect(sidebarTabs, 0)
  gui.tabSelect(workspaceTabs, 0)
  applyVisibility(window)
  layoutWindow(window)
  if visible and not gui.showTopLevel(hwnd) then gui.destroy(hwnd); return fail("createWindow", "top-level window could not be shown") end if
  return window
end function

// Reflows every workbench pane after a top-level resize.
function layoutWindow(window)
  size = try(gui.clientSizeDip(window.hwnd))
  if typeof(size) == "error" then return size end if
  width = size[0]
  height = size[1]
  if width < 980 then width = 980 end if
  if height < 650 then height = 650 end if
  compact = width < 1250
  contentTop = 82
  gui.moveDip(window.refreshButton, 12, 10, 92, 34)
  gui.moveDip(window.openButton, 112, 10, 106, 34)
  gui.moveDip(window.newSqlButton, 226, 10, 70, 34)
  gui.moveDip(window.executeButton, 312, 10, 100, 34)
  gui.moveDip(window.explainButton, 420, 10, 82, 34)
  if compact then
    gui.moveDip(window.stopButton, 518, 10, 72, 34)
    gui.moveDip(window.beginButton, 12, 52, 72, 34)
    gui.moveDip(window.commitButton, 92, 52, 76, 34)
    gui.moveDip(window.rollbackButton, 176, 52, 82, 34)
    gui.moveDip(window.clearButton, 266, 52, 104, 34)
    gui.moveDip(window.closeButton, width - 122, 52, 102, 34)
    gui.moveDip(window.connectionLabel, 12, 94, width - 24, 24)
    contentTop = 124
  else
    gui.moveDip(window.beginButton, 518, 10, 72, 34)
    gui.moveDip(window.commitButton, 598, 10, 76, 34)
    gui.moveDip(window.rollbackButton, 682, 10, 82, 34)
    gui.moveDip(window.stopButton, 780, 10, 72, 34)
    gui.moveDip(window.clearButton, 860, 10, 104, 34)
    gui.moveDip(window.closeButton, width - 122, 10, 102, 34)
    gui.moveDip(window.connectionLabel, 12, 54, width - 24, 24)
  end if
  left = gui.divideInt(width * 22, 100)
  if left < 240 then left = 240 end if
  if left > 320 then left = 320 end if
  mainX = left + 26
  mainWidth = width - mainX - 20
  bottom = height - 48
  paneTop = contentTop + 34
  gui.moveDip(window.sidebarTabs, 12, contentTop, left, 30)
  gui.moveDip(window.objectTree, 12, paneTop, left, bottom - paneTop)
  gui.moveDip(window.bookmarkList, 12, paneTop, left, bottom - paneTop)
  gui.moveDip(window.historyList, 12, paneTop, left, bottom - paneTop)
  gui.moveDip(window.workspaceTabs, mainX, contentTop, mainWidth, 30)
  editorHeight = (bottom - paneTop - 42) >> 1
  if editorHeight < 150 then editorHeight = 150 end if
  gui.moveDip(window.queryEdit, mainX, paneTop, mainWidth, editorHeight)
  resultTabY = paneTop + editorHeight + 8
  gui.moveDip(window.resultTabs, mainX, resultTabY, mainWidth, 30)
  gui.moveDip(window.resultGrid, mainX, resultTabY + 34, mainWidth, bottom - (resultTabY + 34))
  gui.moveDip(window.detailTabs, mainX, paneTop, mainWidth, 30)
  gui.moveDip(window.detailEdit, mainX, paneTop + 34, mainWidth, bottom - (paneTop + 34))
  gui.moveDip(window.statusLabel, 12, height - 36, width - 24, 24)
  gui.redraw(window.hwnd)
  return true
end function

// Verifies one workbench size through actual native child rectangles and pane separation.
function verifyWorkbenchLayout(window, width, height)
  resized = try(gui.setClientSizeDip(window.hwnd, width, height, true))
  if typeof(resized) == "error" or not resized then return fail("verifyWorkbenchLayout", "top-level resize failed") end if
  laidOut = try(layoutWindow(window))
  if typeof(laidOut) == "error" then return laidOut end if
  actual = try(gui.clientSizeDip(window.hwnd))
  if typeof(actual) == "error" then return actual end if
  controls = [window.connectionLabel, window.sidebarTabs, window.objectTree, window.bookmarkList, window.historyList, window.workspaceTabs, window.detailTabs, window.resultTabs, window.queryEdit, window.detailEdit, window.resultGrid, window.refreshButton, window.openButton, window.newSqlButton, window.executeButton, window.explainButton, window.beginButton, window.commitButton, window.rollbackButton, window.stopButton, window.clearButton, window.closeButton, window.statusLabel]
  for each control in controls
    rectangle = try(gui.controlRectDip(window.hwnd, control))
    if typeof(rectangle) == "error" or not rectangleInside(rectangle, actual[0], actual[1]) then return fail("verifyWorkbenchLayout", "a workbench control is outside the client area") end if
  end for
  sidebarRect = try(gui.controlRectDip(window.hwnd, window.objectTree))
  editorRect = try(gui.controlRectDip(window.hwnd, window.queryEdit))
  resultsRect = try(gui.controlRectDip(window.hwnd, window.resultGrid))
  if rectanglesOverlap(sidebarRect, editorRect) or rectanglesOverlap(editorRect, resultsRect) then return fail("verifyWorkbenchLayout", "workbench panes overlap") end if
  closeRect = try(gui.controlRectDip(window.hwnd, window.closeButton))
  clearRect = try(gui.controlRectDip(window.hwnd, window.clearButton))
  if rectanglesOverlap(closeRect, clearRect) then return fail("verifyWorkbenchLayout", "toolbar actions overlap") end if
  return true
end function

// Exercises compact and wide workbench geometry plus SQL editor command delivery.
function workbenchLayoutSmoke()
  window = try(createWindow(false))
  if typeof(window) == "error" then return window end if
  compact = try(verifyWorkbenchLayout(window, 980, 650))
  if typeof(compact) == "error" then gui.destroy(window.hwnd); return compact end if
  wide = try(verifyWorkbenchLayout(window, 1600, 1000))
  if typeof(wide) == "error" then gui.destroy(window.hwnd); return wide end if
  gui.setText(window.queryEdit, "SELECT 42;")
  if gui.getText(window.queryEdit) != "SELECT 42;" then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "SQL editor text did not roundtrip") end if
  gui.clearEvents()
  if not gui.postCommandForTest(window.hwnd, ID_EXECUTE) then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "execute command could not be posted") end if
  gui.pumpMessages()
  received = false
  event = gui.pollEvent()
  while typeof(event) == "struct"
    if event.message == gui.WM_COMMAND and event.controlId == ID_EXECUTE then received = true end if
    event = gui.pollEvent()
  end while
  gui.destroy(window.hwnd)
  if not received then return fail("workbenchLayoutSmoke", "execute command was not delivered") end if
  return true
end function

// Runs both responsive native-window probes against the per-user profile location.
function layoutSmoke()
  connection = try(connectionLayoutProbe([connection_profiles.defaultProfile()]))
  if typeof(connection) == "error" then return connection end if
  return workbenchLayoutSmoke()
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
  reset = try(gui.listReset(hwnd))
  if typeof(reset) == "error" then return reset end if
  for each value in values
    added = try(gui.listAdd(hwnd, value))
    if typeof(added) == "error" then return added end if
  end for
  return true
end function

// Rebuilds the MiniSQL-only database object hierarchy.
function fillObjectTree(window, state)
  reset = try(gui.treeReset(window.objectTree))
  if typeof(reset) == "error" then return reset end if
  database = try(gui.treeInsert(window.objectTree, 0, state.profile.databaseName, true))
  if typeof(database) == "error" then return database end if
  tables = try(gui.treeInsert(window.objectTree, database, "Tables (" + len(state.tables) + ")", true))
  if typeof(tables) == "error" then return tables end if
  selectedItem = 0
  for each tableName in state.tables
    table = try(gui.treeInsert(window.objectTree, tables, tableName, tableName == state.selectedTable))
    if typeof(table) != "error" and tableName == state.selectedTable then
      selectedItem = table
      insertedColumns = try(gui.treeInsert(window.objectTree, table, "Columns", false))
      if typeof(insertedColumns) == "error" then return insertedColumns end if
      insertedIndexes = try(gui.treeInsert(window.objectTree, table, "Indexes", false))
      if typeof(insertedIndexes) == "error" then return insertedIndexes end if
      insertedData = try(gui.treeInsert(window.objectTree, table, "Data", false))
      if typeof(insertedData) == "error" then return insertedData end if
    else if typeof(table) == "error" then
      return table
    end if
  end for
  // Rebuilds are common after DDL; restoring expansion and selection avoids
  // making the user repeatedly reopen the same navigation path.
  gui.treeExpand(window.objectTree, database)
  gui.treeExpand(window.objectTree, tables)
  if selectedItem != 0 then gui.treeExpand(window.objectTree, selectedItem); gui.treeSelect(window.objectTree, selectedItem) end if
  return true
end function

// Replaces tab captions and restores a valid selection.
function fillTabs(hwnd, labels, selected)
  reset = try(gui.tabReset(hwnd))
  if typeof(reset) == "error" then return reset end if
  for each label in labels
    added = try(gui.tabAdd(hwnd, label))
    if typeof(added) == "error" then return added end if
  end for
  if len(labels) > 0 then
    if selected < 0 or selected >= len(labels) then selected = 0 end if
    gui.tabSelect(hwnd, selected)
  end if
  return true
end function

// Renders the active structured result into the native ListView grid.
function fillResultGrid(window, state)
  resetRows = try(gui.listViewReset(window.resultGrid))
  if typeof(resetRows) == "error" then return resetRows end if
  resetColumns = try(gui.listViewResetColumns(window.resultGrid))
  if typeof(resetColumns) == "error" then return resetColumns end if
  tab = fullclient.activeResultTab(state)
  if tab is void or len(tab.columns) == 0 then
    messageWidthDip = 900
    gridRectangle = try(gui.controlRectDip(window.hwnd, window.resultGrid))
    if typeof(gridRectangle) != "error" and gridRectangle[2] > 24 then messageWidthDip = gridRectangle[2] - 4 end if
    messageColumn = try(gui.listViewAddColumn(window.resultGrid, 0, "Messages", gui.scaleDip(window.hwnd, messageWidthDip)))
    if typeof(messageColumn) == "error" then return messageColumn end if
    if tab is not void then
      messageRow = try(gui.listViewAddRow(window.resultGrid, 0, [tab.resultText]))
      if typeof(messageRow) == "error" then return messageRow end if
    end if
    return true
  end if
  // ListView column widths are physical pixels even though the surrounding
  // layout API is DIP-based, so scale explicitly for high-DPI monitors.
  columnWidth = gui.scaleDip(window.hwnd, 180)
  for index = 0 to len(tab.columns) - 1
    insertedColumn = try(gui.listViewAddColumn(window.resultGrid, index, tab.columns[index], columnWidth))
    if typeof(insertedColumn) == "error" then return insertedColumn end if
  end for
  if len(tab.rows) > 0 then
    for rowIndex = 0 to len(tab.rows) - 1
      insertedRow = try(gui.listViewAddRow(window.resultGrid, rowIndex, tab.rows[rowIndex]))
      if typeof(insertedRow) == "error" then return insertedRow end if
    end for
  end if
  return true
end function

// Enables query actions only when no native SQL worker owns the client session.
function setBusyControls(session)
  enabled = not session.busy
  gui.setEnabled(session.window.sidebarTabs, enabled)
  gui.setEnabled(session.window.objectTree, enabled)
  gui.setEnabled(session.window.bookmarkList, enabled)
  gui.setEnabled(session.window.historyList, enabled)
  gui.setEnabled(session.window.workspaceTabs, enabled)
  gui.setEnabled(session.window.detailTabs, enabled)
  gui.setEnabled(session.window.resultTabs, enabled)
  gui.setEnabled(session.window.queryEdit, enabled)
  gui.setEnabled(session.window.executeButton, enabled)
  gui.setEnabled(session.window.explainButton, enabled)
  gui.setEnabled(session.window.beginButton, enabled)
  gui.setEnabled(session.window.commitButton, enabled)
  gui.setEnabled(session.window.rollbackButton, enabled)
  gui.setEnabled(session.window.refreshButton, enabled)
  gui.setEnabled(session.window.openButton, enabled)
  gui.setEnabled(session.window.newSqlButton, enabled)
  gui.setEnabled(session.window.clearButton, enabled)
  gui.setEnabled(session.window.stopButton, session.busy)
  return true
end function

// Renders all workbench panes from the current fullclient model.
function render(session)
  treeRendered = try(fillObjectTree(session.window, session.state))
  if typeof(treeRendered) == "error" then return treeRendered end if
  bookmarksRendered = try(fillList(session.window.bookmarkList, fullclient.bookmarkLines(session.state.bookmarks)))
  if typeof(bookmarksRendered) == "error" then return bookmarksRendered end if
  historyRendered = try(fillList(session.window.historyList, session.state.history))
  if typeof(historyRendered) == "error" then return historyRendered end if
  detailSelected = gui.tabSelectedIndex(session.window.detailTabs)
  detailsRendered = try(fillTabs(session.window.detailTabs, fullclient.detailTabLines(session.state), detailSelected))
  if typeof(detailsRendered) == "error" then return detailsRendered end if
  tabsRendered = try(fillTabs(session.window.resultTabs, fullclient.resultTabLines(session.state.resultTabs), session.state.selectedResultIndex))
  if typeof(tabsRendered) == "error" then return tabsRendered end if
  gridRendered = try(fillResultGrid(session.window, session.state))
  if typeof(gridRendered) == "error" then return gridRendered end if
  detailName = "Database"
  labels = fullclient.detailTabLines(session.state)
  detailSelected = gui.tabSelectedIndex(session.window.detailTabs)
  if detailSelected >= 0 and detailSelected < len(labels) then detailName = labels[detailSelected] end if
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
  session = AdminSession(window, state, void, false, false, false)
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

// Executes one protocol operation and any dependent refresh on the same worker.
function queryWorker(task)
  if task.operation == QUERY_REFRESH then
    result = try(fullclient.refresh(task.state))
    return QueryCompletion(task.operation, result, void, task.state.statusText)
  end if
  if task.operation == QUERY_DESCRIBE then
    result = try(fullclient.describeTable(task.state, task.tableName))
    return QueryCompletion(task.operation, result, void, task.state.statusText)
  end if
  result = void
  if task.operation == QUERY_EXPLAIN then result = try(fullclient.explainSql(task.state, task.sqlText))
  else if task.operation == QUERY_BEGIN then result = try(fullclient.beginTransaction(task.state))
  else if task.operation == QUERY_COMMIT then result = try(fullclient.commitTransaction(task.state))
  else if task.operation == QUERY_ROLLBACK then result = try(fullclient.rollbackTransaction(task.state))
  else result = try(fullclient.executeSql(task.state, task.sqlText))
  end if
  statusText = task.state.statusText
  refreshed = void
  // Refresh shares the ordered protocol stream with its triggering statement;
  // doing both here prevents the UI thread from racing or blocking on the socket.
  if typeof(result) != "error" then refreshed = try(fullclient.refresh(task.state)) end if
  return QueryCompletion(task.operation, result, refreshed, statusText)
end function

// Starts one responsive background protocol operation.
function startOperation(session, operation, sqlText, tableName)
  if session.aborted then return fail("startQuery", "the cancelled session cannot be reused") end if
  if session.busy then return fail("startQuery", "a query is already running") end if
  worker = Thread(queryWorker, "minisql-workbench-query")
  if not worker.Start(QueryTask(session.state, operation, sqlText, tableName)) then return fail("startQuery", "native SQL worker could not be started") end if
  session.worker = worker
  session.busy = true
  session.sensitiveSql = (operation == QUERY_EXECUTE or operation == QUERY_EXPLAIN) and fullclient.isSensitiveSql(sqlText)
  if operation == QUERY_REFRESH then session.state.statusText = "Refreshing the object tree …"
  else if operation == QUERY_DESCRIBE then session.state.statusText = "Loading metadata for table " + tableName + " …"
  else session.state.statusText = "Executing SQL on a native worker thread …"
  end if
  setBusyControls(session)
  gui.setText(session.window.statusLabel, session.state.statusText)
  return true
end function

// Starts normal or EXPLAIN SQL while preserving the established public API.
function startQuery(session, sqlText, explain)
  operation = QUERY_EXECUTE
  if explain then operation = QUERY_EXPLAIN end if
  if not explain and sqlText == "BEGIN;" then operation = QUERY_BEGIN end if
  if not explain and sqlText == "COMMIT;" then operation = QUERY_COMMIT end if
  if not explain and sqlText == "ROLLBACK;" then operation = QUERY_ROLLBACK end if
  return startOperation(session, operation, sqlText, "")
end function

// Starts a background object-tree refresh.
function startRefresh(session)
  return startOperation(session, QUERY_REFRESH, "", "")
end function

// Starts background metadata loading for one validated tree selection.
function startDescribe(session, tableName)
  return startOperation(session, QUERY_DESCRIBE, "", tableName)
end function

// Publishes a completed worker result without performing network I/O on the UI thread.
function pollQuery(session)
  if not session.busy or session.worker is void then return false end if
  if not session.worker.Join(0) then return false end if
  completion = try(session.worker.Result())
  ignoredClose = session.worker.Close()
  session.worker = void
  session.busy = false
  if session.sensitiveSql then gui.setText(session.window.queryEdit, "") end if
  session.sensitiveSql = false
  if typeof(completion) == "error" then
    session.state.statusText = "Operation failed: " + completion.message
  else if typeof(completion.result) == "error" then
    session.state.statusText = "Operation failed: " + completion.result.message
  else if typeof(completion.refreshResult) == "error" then
    session.state.statusText = completion.statusText + "; object refresh failed: " + completion.refreshResult.message
  else if completion.refreshResult is not void then
    session.state.statusText = completion.statusText + "   •   " + len(session.state.tables) + " table(s)"
  else
    session.state.statusText = completion.statusText
  end if
  if typeof(completion) != "error" and completion.operation == QUERY_DESCRIBE and typeof(completion.result) != "error" then gui.tabSelect(session.window.workspaceTabs, 1) end if
  render(session)
  return true
end function

// Stops the native worker before disconnecting the affected session.
function stopQuery(session)
  if not session.busy or session.worker is void then return false end if
  stopped = session.worker.Stop()
  if not session.worker.Join(2000) then session.state.statusText = "The worker did not terminate; the session remains locked for safety."; gui.setText(session.window.statusLabel, session.state.statusText); return false end if
  ignoredClose = session.worker.Close()
  session.worker = void
  session.busy = false
  session.aborted = true
  if session.sensitiveSql then gui.setText(session.window.queryEdit, "") end if
  session.sensitiveSql = false
  session.state.statusText = "Execution stopped. Disconnecting this session to preserve protocol framing."
  gui.setText(session.window.statusLabel, session.state.statusText)
  gui.destroy(session.window.hwnd)
  return stopped
end function

// Opens table details for the current object-tree selection.
function openSelectedObject(session)
  selected = try(gui.treeSelectedText(session.window.objectTree))
  if typeof(selected) != "string" or not fullclient.containsText(session.state.tables, selected) then session.state.statusText = "Select a table in the object tree"; return false end if
  gui.tabSelect(session.window.workspaceTabs, 1)
  applyVisibility(session.window)
  return startDescribe(session, selected)
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
    started = try(startRefresh(session))
    if typeof(started) == "error" then session.state.statusText = "Refresh failed: " + started.message end if
  else if command == ID_OPEN_OBJECT or command == gui.MENU_OBJECT_DESCRIBE then
    openSelectedObject(session)
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
    if gui.isOpen(session.window.hwnd) then ignoredWorker = pollQuery(session) end if
    event = gui.pollEvent()
    while typeof(event) == "struct"
      if event.hwnd != session.window.hwnd then
        ignoredForeignEvent = true
      else if event.message == gui.WM_SIZE or event.message == gui.WM_DPICHANGED then
        layoutWindow(session.window)
      else if event.message == gui.WM_NOTIFY and not session.busy then
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
  closed = true
  if session.aborted then closed = try(fullclient.abort(session.state)) else closed = try(fullclient.close(session.state)) end if
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
