//! Provides minisql admin win32 client facilities for this project.

package minisql.admin.win32_client

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.admin.connection_profiles as connection_profiles
import minisql.admin.fullclient as fullclient
import minisql.common.uuid as uuid
import minisql.config.loader as json
import minisql.platform.clock as clock
import minisql.platform.file as file_api
import minisql.platform.win32_gui as gui

/// Defines the invalid argument constant used by the minisql admin win32 client module.
const INVALID_ARGUMENT = 9001
/// Defines the lbn selchange constant used by the minisql admin win32 client module.
const LBN_SELCHANGE = 1
/// Defines the lbn dblclk constant used by the minisql admin win32 client module.
const LBN_DBLCLK = 2
/// Defines the tcn selchange constant used by the minisql admin win32 client module.
const TCN_SELCHANGE = -551
/// Defines the tvn selchangedw constant used by the minisql admin win32 client module.
const TVN_SELCHANGEDW = -451
/// Defines the nm click constant used by the minisql admin win32 client module.
const NM_CLICK = -2
/// Defines the nm dblclk constant used by the minisql admin win32 client module.
const NM_DBLCLK = -3
/// Defines the lvn columnclick constant used by the minisql admin win32 client module.
const LVN_COLUMNCLICK = -108
/// Defines the en change constant used by the minisql admin win32 client module.
const EN_CHANGE = 0x0300

/// Defines the query execute constant used by the minisql admin win32 client module.
const QUERY_EXECUTE = 1
/// Defines the query explain constant used by the minisql admin win32 client module.
const QUERY_EXPLAIN = 2
/// Defines the query begin constant used by the minisql admin win32 client module.
const QUERY_BEGIN = 3
/// Defines the query commit constant used by the minisql admin win32 client module.
const QUERY_COMMIT = 4
/// Defines the query rollback constant used by the minisql admin win32 client module.
const QUERY_ROLLBACK = 5
/// Defines the query refresh constant used by the minisql admin win32 client module.
const QUERY_REFRESH = 6
/// Defines the query describe constant used by the minisql admin win32 client module.
const QUERY_DESCRIBE = 7
/// Defines the query data mutation constant used by the minisql admin win32 client module.
const QUERY_DATA_MUTATION = 8
/// Defines the query schema mutation constant used by the minisql admin win32 client module.
const QUERY_SCHEMA_MUTATION = 9

/// Defines the id profile list constant used by the minisql admin win32 client module.
const ID_PROFILE_LIST = 8001
/// Defines the id profile name constant used by the minisql admin win32 client module.
const ID_PROFILE_NAME = 8002
/// Defines the id profile address constant used by the minisql admin win32 client module.
const ID_PROFILE_ADDRESS = 8003
/// Defines the id profile port constant used by the minisql admin win32 client module.
const ID_PROFILE_PORT = 8004
/// Defines the id profile server constant used by the minisql admin win32 client module.
const ID_PROFILE_SERVER = 8005
/// Defines the id profile database constant used by the minisql admin win32 client module.
const ID_PROFILE_DATABASE = 8006
/// Defines the id profile user constant used by the minisql admin win32 client module.
const ID_PROFILE_USER = 8007
/// Defines the id profile password constant used by the minisql admin win32 client module.
const ID_PROFILE_PASSWORD = 8008
/// Defines the id profile tls constant used by the minisql admin win32 client module.
const ID_PROFILE_TLS = 8009
/// Defines the id profile trusted constant used by the minisql admin win32 client module.
const ID_PROFILE_TRUSTED = 8010
/// Defines the id profile pin constant used by the minisql admin win32 client module.
const ID_PROFILE_PIN = 8011
/// Defines the id profile save constant used by the minisql admin win32 client module.
const ID_PROFILE_SAVE = 8012
/// Defines the id profile connect constant used by the minisql admin win32 client module.
const ID_PROFILE_CONNECT = 8013
/// Defines the id profile delete constant used by the minisql admin win32 client module.
const ID_PROFILE_DELETE = 8014
/// Defines the id profile new constant used by the minisql admin win32 client module.
const ID_PROFILE_NEW = 8015
/// Defines the id profile close constant used by the minisql admin win32 client module.
const ID_PROFILE_CLOSE = 8016

/// Defines the id sidebar tabs constant used by the minisql admin win32 client module.
const ID_SIDEBAR_TABS = 8101
/// Defines the id object tree constant used by the minisql admin win32 client module.
const ID_OBJECT_TREE = 8102
/// Defines the id bookmark list constant used by the minisql admin win32 client module.
const ID_BOOKMARK_LIST = 8103
/// Defines the id history list constant used by the minisql admin win32 client module.
const ID_HISTORY_LIST = 8104
/// Defines the id workspace tabs constant used by the minisql admin win32 client module.
const ID_WORKSPACE_TABS = 8105
/// Defines the id detail tabs constant used by the minisql admin win32 client module.
const ID_DETAIL_TABS = 8106
/// Defines the id result tabs constant used by the minisql admin win32 client module.
const ID_RESULT_TABS = 8107
/// Defines the id result grid constant used by the minisql admin win32 client module.
const ID_RESULT_GRID = 8108
/// Defines the id refresh constant used by the minisql admin win32 client module.
const ID_REFRESH = 8110
/// Defines the id open object constant used by the minisql admin win32 client module.
const ID_OPEN_OBJECT = 8111
/// Defines the id new sql constant used by the minisql admin win32 client module.
const ID_NEW_SQL = 8112
/// Defines the id execute constant used by the minisql admin win32 client module.
const ID_EXECUTE = 8113
/// Defines the id explain constant used by the minisql admin win32 client module.
const ID_EXPLAIN = 8114
/// Defines the id begin constant used by the minisql admin win32 client module.
const ID_BEGIN = 8115
/// Defines the id commit constant used by the minisql admin win32 client module.
const ID_COMMIT = 8116
/// Defines the id rollback constant used by the minisql admin win32 client module.
const ID_ROLLBACK = 8117
/// Defines the id stop constant used by the minisql admin win32 client module.
const ID_STOP = 8118
/// Defines the id clear constant used by the minisql admin win32 client module.
const ID_CLEAR = 8119
/// Defines the id close constant used by the minisql admin win32 client module.
const ID_CLOSE = 8120
/// Defines the id execute script constant used by the minisql admin win32 client module.
const ID_EXECUTE_SCRIPT = 8121
/// Defines the id query edit constant used by the minisql admin win32 client module.
const ID_QUERY_EDIT = 8122
/// Defines the id detail grid constant used by the minisql admin win32 client module.
const ID_DETAIL_GRID = 8123
/// Defines the id data add constant used by the minisql admin win32 client module.
const ID_DATA_ADD = 8124
/// Defines the id data copy constant used by the minisql admin win32 client module.
const ID_DATA_COPY = 8125
/// Defines the id data edit constant used by the minisql admin win32 client module.
const ID_DATA_EDIT = 8126
/// Defines the id data delete constant used by the minisql admin win32 client module.
const ID_DATA_DELETE = 8127
/// Defines the id data refresh constant used by the minisql admin win32 client module.
const ID_DATA_REFRESH = 8128
/// Defines the id data copy clipboard constant used by the minisql admin win32 client module.
const ID_DATA_COPY_CLIPBOARD = 8129
/// Defines the id data paste constant used by the minisql admin win32 client module.
const ID_DATA_PASTE = 8130
/// Defines the id data filter constant used by the minisql admin win32 client module.
const ID_DATA_FILTER = 8131
/// Defines the id data filter apply constant used by the minisql admin win32 client module.
const ID_DATA_FILTER_APPLY = 8132
/// Defines the id data previous page constant used by the minisql admin win32 client module.
const ID_DATA_PREVIOUS_PAGE = 8133
/// Defines the id data next page constant used by the minisql admin win32 client module.
const ID_DATA_NEXT_PAGE = 8134
/// Defines the id data page label constant used by the minisql admin win32 client module.
const ID_DATA_PAGE_LABEL = 8135
/// Defines the id data apply changes constant used by the minisql admin win32 client module.
const ID_DATA_APPLY_CHANGES = 8136
/// Defines the id data revert changes constant used by the minisql admin win32 client module.
const ID_DATA_REVERT_CHANGES = 8137
/// Defines the id data preview changes constant used by the minisql admin win32 client module.
const ID_DATA_PREVIEW_CHANGES = 8138
/// Defines the id schema designer constant used by the minisql admin win32 client module.
const ID_SCHEMA_DESIGNER = 8139
/// Defines the id export csv constant used by the minisql admin win32 client module.
const ID_EXPORT_CSV = 8140
/// Defines the id close sql constant used by the minisql admin win32 client module.
const ID_CLOSE_SQL = 8141
/// Defines the id worksheet tabs constant used by the minisql admin win32 client module.
const ID_WORKSHEET_TABS = 8142
/// Defines the id history filter constant used by the minisql admin win32 client module.
const ID_HISTORY_FILTER = 8143

/// Defines the id row values constant used by the minisql admin win32 client module.
const ID_ROW_VALUES = 8201
/// Defines the id row value constant used by the minisql admin win32 client module.
const ID_ROW_VALUE = 8202
/// Defines the id row previous constant used by the minisql admin win32 client module.
const ID_ROW_PREVIOUS = 8203
/// Defines the id row next constant used by the minisql admin win32 client module.
const ID_ROW_NEXT = 8204
/// Defines the id row save constant used by the minisql admin win32 client module.
const ID_ROW_SAVE = 8205
/// Defines the id row cancel constant used by the minisql admin win32 client module.
const ID_ROW_CANCEL = 8206

/// Defines the id schema actions constant used by the minisql admin win32 client module.
const ID_SCHEMA_ACTIONS = 8301
/// Defines the id schema table constant used by the minisql admin win32 client module.
const ID_SCHEMA_TABLE = 8302
/// Defines the id schema object constant used by the minisql admin win32 client module.
const ID_SCHEMA_OBJECT = 8303
/// Defines the id schema definition constant used by the minisql admin win32 client module.
const ID_SCHEMA_DEFINITION = 8304
/// Defines the id schema option constant used by the minisql admin win32 client module.
const ID_SCHEMA_OPTION = 8305
/// Defines the id schema preview constant used by the minisql admin win32 client module.
const ID_SCHEMA_PREVIEW = 8306
/// Defines the id schema execute constant used by the minisql admin win32 client module.
const ID_SCHEMA_EXECUTE = 8307
/// Defines the id schema insert constant used by the minisql admin win32 client module.
const ID_SCHEMA_INSERT = 8308
/// Defines the id schema cancel constant used by the minisql admin win32 client module.
const ID_SCHEMA_CANCEL = 8309

/// Owns all native controls in the connection-alias window.
struct ConnectionWindow
  /// Stores the top-level connection window handle.
  hwnd
  /// Stores the primary connection-manager heading.
  titleLabel
  /// Stores the explanatory connection-manager subheading.
  subtitleLabel
  /// Stores the alias list control.
  aliasList
  /// Stores the section heading above editable connection fields.
  detailsLabel
  /// Stores the ordered labels paired with the connection editors.
  fieldLabels
  /// Stores the alias-name editor.
  nameEdit
  /// Stores the network-address editor.
  addressEdit
  /// Stores the network-port editor.
  portEdit
  /// Stores the TLS server-name editor.
  serverEdit
  /// Stores the database-label editor.
  databaseEdit
  /// Stores the MiniSQL user editor.
  userEdit
  /// Stores the transient password editor.
  passwordEdit
  /// Stores the optional certificate-pin editor.
  pinEdit
  /// Stores the native TLS checkbox.
  tlsCheck
  /// Stores the trusted-local checkbox.
  trustedCheck
  /// Stores the explanatory certificate and password note.
  hintLabel
  /// Stores the new-alias action button.
  newButton
  /// Stores the delete-alias action button.
  deleteButton
  /// Stores the save-alias action button.
  saveButton
  /// Stores the default connect action button.
  connectButton
  /// Stores the close-window action button.
  closeButton
  /// Stores the connection-manager status label.
  statusLabel
end struct

/// Owns all native controls in one MiniSQL session workbench.
struct AdminWindow
  /// Stores the top-level workbench handle.
  hwnd
  /// Stores the active endpoint heading.
  connectionLabel
  /// Stores the sidebar tab control.
  sidebarTabs
  /// Stores the hierarchical database object browser.
  objectTree
  /// Stores reusable SQL bookmarks.
  bookmarkList
  /// Stores redacted SQL history.
  historyList
  /// Stores the SQL/details workspace tab control.
  workspaceTabs
  /// Stores table-detail page tabs.
  detailTabs
  /// Stores SQL result tabs.
  resultTabs
  /// Stores the multiline SQL editor.
  queryEdit
  /// Stores read-only table-detail text.
  detailEdit
  /// Stores structured Columns, Indexes, Data, and Row Count detail pages.
  detailGrid
  /// Starts a blank row editor on the Data page.
  dataAddButton
  /// Starts an insert editor populated from the selected row.
  dataCopyButton
  /// Starts an update editor for the selected keyed row.
  dataEditButton
  /// Deletes the selected keyed row after explicit confirmation.
  dataDeleteButton
  /// Reloads table metadata and preview rows.
  dataRefreshButton
  /// Stores structured SQL result rows.
  resultGrid
  /// Stores the object-tree refresh button.
  refreshButton
  /// Stores the open-object button.
  openButton
  /// Stores the new-worksheet button.
  newSqlButton
  /// Stores the execute button.
  executeButton
  /// Stores the whole-script execution button.
  executeScriptButton
  /// Stores the explain button.
  explainButton
  /// Stores the begin-transaction button.
  beginButton
  /// Stores the commit button.
  commitButton
  /// Stores the rollback button.
  rollbackButton
  /// Stores the stop-worker button.
  stopButton
  /// Stores the clear-results button.
  clearButton
  /// Stores the close-session button.
  closeButton
  /// Stores the workbench status line.
  statusLabel
  /// Stores independent SQL worksheet tabs above the active editor.
  worksheetTabs
  /// Closes the active SQL worksheet while retaining at least one page.
  closeSqlButton
  /// Exports the active structured result page as UTF-8 CSV.
  exportCsvButton
  /// Opens the structured MiniSQL schema designer.
  schemaButton
  /// Filters the History sidebar without changing retained history.
  historyFilterEdit
  /// Copies every selected data row to escaped TSV clipboard text.
  dataCopyClipboardButton
  /// Stages clipboard TSV rows as INSERT changes.
  dataPasteButton
  /// Stores the server-side WHERE predicate used by the Data page.
  dataFilterEdit
  /// Applies the current Data-page filter and resets pagination.
  dataFilterButton
  /// Loads the preceding bounded Data page.
  dataPreviousButton
  /// Loads the next bounded Data page.
  dataNextButton
  /// Shows current page, page size, and pending-change count.
  dataPageLabel
  /// Executes all previewed row changes through the background worker.
  dataApplyButton
  /// Discards every unapplied row change.
  dataRevertButton
  /// Shows the exact generated SQL for pending changes.
  dataPreviewButton
end struct

/// Owns the bounded modal editor used for arbitrary-width table rows.
struct RowEditorWindow
  /// Stores the modal top-level window handle.
  hwnd
  /// Describes the table and insert/update mode.
  titleLabel
  /// Shows the currently edited column name, type, and null/default policy.
  fieldLabel
  /// Shows all column values in a structured review grid.
  valuesGrid
  /// Edits the current field without truncating long text.
  valueEdit
  /// Documents the explicit NULL and DEFAULT sentinel values.
  hintLabel
  /// Moves to the preceding field.
  previousButton
  /// Applies the value and moves to the following field.
  nextButton
  /// Validates the draft and returns a mutation statement.
  saveButton
  /// Discards the row draft.
  cancelButton
end struct

/// Retains modal row-editor state independently from the connected session.
struct RowEditorState
  /// Owns the native editor controls.
  window
  /// References the immutable table metadata used for validation.
  details
  /// Stores mutable editor values aligned with DESCRIBE rows.
  values
  /// Selects the field presented in the single-line value editor.
  fieldIndex
  /// Stores -1 for inserts or the preview row index for updates.
  originalRowIndex
  /// Selects update generation instead of insert generation.
  updateMode
  /// Stores the generated SQL after Save or void after cancellation.
  resultSql
end struct

/// Owns the structured schema designer controls.
struct SchemaEditorWindow
  /// Stores the modal top-level schema designer handle.
  hwnd
  /// Stores the ordered schema action list.
  actionList
  /// Edits the target table name.
  tableEdit
  /// Edits a column, index, or constraint name.
  objectEdit
  /// Edits column definitions, index columns, or constraint expressions.
  definitionEdit
  /// Edits action-specific options such as UNIQUE or a rename target.
  optionEdit
  /// Shows the exact generated DDL before submission.
  previewEdit
  /// Returns the generated DDL for immediate execution.
  executeButton
  /// Returns the generated DDL for insertion into a worksheet.
  insertButton
  /// Closes the designer without returning DDL.
  cancelButton
  /// Stores explanatory labels for all editable fields.
  labels
end struct

/// Retains schema-designer modal state until execution, insertion, or cancellation.
struct SchemaEditorState
  /// Owns the modal native controls.
  window
  /// Stores generated DDL or void when cancelled.
  resultSql
  /// Selects direct execution instead of worksheet insertion.
  executeImmediately
end struct

/// Bundles immutable input for any protocol operation executed off the UI thread.
struct QueryTask
  /// Stores the fullclient state owned by the session.
  state
  /// Selects execute, transaction, refresh, or table-description behavior.
  operation
  /// Stores SQL submitted to execute or explain operations.
  sqlText
  /// Stores the table selected for an asynchronous description operation.
  tableName
  /// Stores the immutable page/filter/sort request for table description refreshes.
  browseOptions
end struct

/// Carries one worker result and its optional object-tree refresh back to the UI.
struct QueryCompletion
  /// Identifies the operation that produced this completion.
  operation
  /// Stores the primary operation result or structured error.
  result
  /// Stores the follow-up refresh result or void when no refresh was required.
  refreshResult
  /// Preserves the primary status text before a refresh updates shared state.
  statusText
end struct

/// Owns credentials while one connection handshake runs outside the UI thread.
struct ConnectionTask
  /// Stores the validated, secret-free connection profile.
  profile
  /// Stores transient password bytes read from the password editor.
  password
end struct

/// Tracks a connection worker and guarantees eventual credential destruction.
struct ConnectionAttempt
  /// Stores the active native handshake worker or void.
  worker
  /// Stores the caller-owned password bytes until the worker has terminated.
  password
  /// Indicates whether a handshake is currently in flight.
  busy
end struct

/// Combines one native window, client state, and optional running query worker.
struct AdminSession
  /// Owns the native workbench controls.
  window
  /// Owns the protocol and result model.
  state
  /// Stores the active native worker or void.
  worker
  /// Indicates whether SQL is currently executing.
  busy
  /// Records whether the editor currently contains a submitted secret-bearing DCL statement.
  sensitiveSql
  /// Requires transport abort because cancellation invalidated protocol framing.
  aborted
  /// Requests one deferred full-editor syntax recolor after text changes.
  highlightDirty
  /// Stores the monotonic idle deadline used to debounce worksheet recoloring.
  highlightAfterMilliseconds
  /// Persists the selected SQL/details workspace across asynchronous renders.
  workspacePage
  /// Retains every independent SQL worksheet.
  worksheets
  /// Selects the worksheet currently loaded in the RichEdit control.
  selectedWorksheetIndex
  /// Allocates monotonically increasing worksheet labels.
  nextWorksheetNumber
  /// Retains unapplied INSERT, UPDATE, and DELETE previews.
  pendingChanges
  /// Stores the active Data-page filter, order, and pagination settings.
  dataOptions
  /// Stores the case-insensitive History sidebar filter.
  historyFilter
  /// Stores the optional per-user window-layout file path.
  layoutPath
  /// Retains the last live top-level rectangle for persistence after WM_CLOSE.
  windowRect
end struct

/// Creates a namespaced GUI-controller error.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(operation, message)
  return error(INVALID_ARGUMENT, "admin.win32_client." + operation + ": " + message)
end function

/// Returns the first failed native-control creation from a heterogeneous handle array.
/// @param controls controls value consumed by this operation.
function firstControlError(controls)
  for each control in controls
    if typeof(control) == "error" then return control end if
  end for
  return void
end function

/// Recomputes all presentation spans and applies them without moving the caret.
/// @param window window value consumed by this operation.
function highlightSqlEditor(window)
  if window is not AdminWindow then return fail("highlightSqlEditor", "window must be AdminWindow") end if
  sqlText = try(gui.getText(window.queryEdit))
  if typeof(sqlText) == "error" then return sqlText end if
  spans = try(fullclient.sqlSyntaxSpans(sqlText))
  if typeof(spans) == "error" then return spans end if
  return gui.applySqlSyntaxStyles(window.queryEdit, spans)
end function

/// Reads the whole script, explicit selection, or statement under the caret.
/// @param window window value consumed by this operation.
/// @param wholeScript wholeScript value consumed by this operation.
function editorSqlForCommand(window, wholeScript)
  if window is not AdminWindow or typeof(wholeScript) != "bool" then return fail("editorSqlForCommand", "invalid window or execution mode") end if
  sqlText = try(gui.getText(window.queryEdit))
  if typeof(sqlText) == "error" then return sqlText end if
  selection = try(gui.textSelection(window.queryEdit))
  if typeof(selection) == "error" then return selection end if
  return fullclient.editorSqlForExecution(sqlText, selection[0], selection[1], wholeScript)
end function

/// Creates the modern alias manager used before a MiniSQL session opens.
/// @param visible visible value consumed by this operation.
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

/// Reflows the alias list and all connection fields in logical DPI-independent units.
/// @param window window value consumed by this operation.
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

/// Finds an alias by exact user-visible name.
/// @param profiles profiles value consumed by this operation.
/// @param name Name of the affected item.
function profileByName(profiles, name)
  for each profile in profiles
    if profile.name == name then return profile end if
  end for
  return void
end function

/// Copies an alias into connection-manager controls and clears the password.
/// @param window window value consumed by this operation.
/// @param profile profile value consumed by this operation.
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

/// Rebuilds the alias list while keeping the first row selected.
/// @param window window value consumed by this operation.
/// @param profiles profiles value consumed by this operation.
function renderConnectionProfiles(window, profiles)
  gui.listReset(window.aliasList)
  for each profile in profiles
    ignored = try(gui.listAdd(window.aliasList, profile.name))
  end for
  if len(profiles) > 0 then gui.listSelect(window.aliasList, 0); return renderConnectionProfile(window, profiles[0]) end if
  return true
end function

/// Clears fields to a sensible new local alias template.
/// @param window window value consumed by this operation.
function renderNewProfile(window)
  return renderConnectionProfile(window, connection_profiles.defaultProfile())
end function

/// Validates connection-manager fields into a secret-free profile.
/// @param window window value consumed by this operation.
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

/// Reads transient credentials, allowing password-free trusted-local sessions.
/// @param window window value consumed by this operation.
/// @param profile profile value consumed by this operation.
function passwordFromWindow(window, profile)
  if profile.trustedLocal then
    gui.setText(window.passwordEdit, "")
    return bytes(0)
  end if
  return gui.getSecretBytes(window.passwordEdit)
end function

/// Opens one profile on a native worker so DNS, TCP, TLS, and authentication cannot freeze the UI.
/// @param task task value consumed by this operation.
function connectionWorker(task)
  return fullclient.openProfile(task.profile, task.password)
end function

/// Prevents profile edits while the worker reads its immutable profile snapshot.
/// @param window window value consumed by this operation.
/// @param busy busy value consumed by this operation.
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

/// Starts an asynchronous connection attempt and transfers password ownership to it.
/// @param window window value consumed by this operation.
/// @param profile profile value consumed by this operation.
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

/// Returns void while connecting, then publishes the state or error and wipes credentials.
/// @param attempt attempt value consumed by this operation.
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

/// Cancels a handshake without wiping bytes until the native worker has terminated.
/// @param attempt attempt value consumed by this operation.
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

/// Translates common WinSock failures into actionable connection guidance.
/// @param value Value consumed or transformed by the operation.
function connectionFailureText(value)
  if typeof(value) != "error" then return "Unknown connection error" end if
  if fullclient.textContains(value.message, "10061") then return "Connection refused. Verify address/port and start minisqld for this database." end if
  if fullclient.textContains(value.message, "10054") then return "The server closed the connection. Verify its mode, account, and database path." end if
  return value.message
end function

/// Reports a failed handshake without closing the manager so the user can retry.
/// @param window window value consumed by this operation.
/// @param value Value consumed or transformed by the operation.
/// @param showDialog showDialog value consumed by this operation.
function reportConnectionFailure(window, value, showDialog)
  if window is not ConnectionWindow or typeof(showDialog) != "bool" then return fail("reportConnectionFailure", "invalid connection window or dialog mode") end if
  message = connectionFailureText(value)
  setConnectionBusy(window, false)
  gui.setText(window.statusLabel, "Connection failed: " + message)
  if showDialog then gui.showError(window.hwnd, "MiniSQL connection failed", message) end if
  gui.focus(window.connectButton)
  return message
end function

/// Runs the native alias manager using an explicit profile path for tests.
/// @param path Path of the file or directory used by the operation.
/// @param visible visible value consumed by this operation.
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
      if typeof(connected) == "error" then
        ignoredFailure = try(reportConnectionFailure(window, connected, true))
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
          if typeof(profile) == "error" then ignoredInvalidProfile = try(reportConnectionFailure(window, profile, true))
          else
            gui.setText(window.statusLabel, "Connecting to " + fullclient.endpointText(profile) + " …")
            started = try(startConnection(window, profile))
            if typeof(started) == "error" then ignoredStartFailure = try(reportConnectionFailure(window, started, true)) else attempt = started end if
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

/// Launches the per-user connection manager.
function launchConnectionManager()
  path = try(connection_profiles.defaultPath())
  if typeof(path) == "error" then return path end if
  return runConnectionManagerWithPath(path, true)
end function

/// Runs a hidden connection-manager construction smoke test.
/// @param path Path of the file or directory used by the operation.
function connectionManagerSmoke(path)
  return runConnectionManagerWithPath(path, false)
end function

/// Returns true when a child rectangle is positive and fully contained by a client area.
/// @param rectangle rectangle value consumed by this operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function rectangleInside(rectangle, width, height)
  if typeof(rectangle) != "array" or len(rectangle) != 4 then return false end if
  return rectangle[0] >= 0 and rectangle[1] >= 0 and rectangle[2] > 0 and rectangle[3] > 0 and rectangle[0] + rectangle[2] <= width + 2 and rectangle[1] + rectangle[3] <= height + 2
end function

/// Detects whether two parent-relative rectangles consume the same layout area.
/// @param first first value consumed by this operation.
/// @param second second value consumed by this operation.
function rectanglesOverlap(first, second)
  if typeof(first) != "array" or typeof(second) != "array" or len(first) != 4 or len(second) != 4 then return true end if
  return first[0] < second[0] + second[2] and second[0] < first[0] + first[2] and first[1] < second[1] + second[3] and second[1] < first[1] + first[3]
end function

/// Verifies one responsive connection-manager size through actual Win32 child rectangles.
/// @param window window value consumed by this operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
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

/// Exercises responsive geometry, editor roundtrips, checkboxes, and command delivery for supplied aliases.
/// @param profiles profiles value consumed by this operation.
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

/// Loads aliases from a test path and runs the complete connection-layout probe.
/// @param path Path of the file or directory used by the operation.
function connectionLayoutSmoke(path)
  profiles = try(connection_profiles.load(path))
  if typeof(profiles) == "error" then return profiles end if
  return connectionLayoutProbe(profiles)
end function

/// Creates the SQuirreL-style MiniSQL session workbench.
/// @param visible visible value consumed by this operation.
function createWindow(visible)
  hwnd = try(gui.createTopLevel("MiniSQL Workbench", 1440, 900, false))
  if typeof(hwnd) == "error" then return hwnd end if
  // Native title-bar closes must pass through the session controller so staged
  // table changes receive the same warning as the Disconnect command.
  gui.setCloseEventRouting(hwnd, true)
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
  executeButton = try(gui.createDefaultButtonId(hwnd, ID_EXECUTE, "▶ Current", 312, 10, 116, 34))
  executeScriptButton = try(gui.createButtonId(hwnd, ID_EXECUTE_SCRIPT, "Run script", 436, 10, 96, 34))
  explainButton = try(gui.createButtonId(hwnd, ID_EXPLAIN, "Explain", 540, 10, 82, 34))
  beginButton = try(gui.createButtonId(hwnd, ID_BEGIN, "Begin", 638, 10, 72, 34))
  commitButton = try(gui.createButtonId(hwnd, ID_COMMIT, "Commit", 718, 10, 76, 34))
  rollbackButton = try(gui.createButtonId(hwnd, ID_ROLLBACK, "Rollback", 802, 10, 82, 34))
  stopButton = try(gui.createButtonId(hwnd, ID_STOP, "■ Stop", 900, 10, 72, 34))
  clearButton = try(gui.createButtonId(hwnd, ID_CLEAR, "Clear results", 980, 10, 104, 34))
  schemaButton = try(gui.createButtonId(hwnd, ID_SCHEMA_DESIGNER, "Schema", 1092, 10, 82, 34))
  exportCsvButton = try(gui.createButtonId(hwnd, ID_EXPORT_CSV, "Export CSV", 1182, 10, 92, 34))
  closeSqlButton = try(gui.createButtonId(hwnd, ID_CLOSE_SQL, "Close SQL", 1282, 10, 88, 34))
  closeButton = try(gui.createButtonId(hwnd, ID_CLOSE, "Disconnect", 1318, 10, 102, 34))
  connectionLabel = try(gui.createLabel(hwnd, "Opening MiniSQL session …", 12, 54, 1398, 24))
  sidebarTabs = try(gui.createTabControl(hwnd, ID_SIDEBAR_TABS, 12, 82, 294, 30))
  objectTree = try(gui.createTreeView(hwnd, ID_OBJECT_TREE, 12, 116, 294, 714))
  bookmarkList = try(gui.createListBoxId(hwnd, ID_BOOKMARK_LIST, 12, 116, 294, 714))
  historyList = try(gui.createListBoxId(hwnd, ID_HISTORY_LIST, 12, 116, 294, 714))
  historyFilterEdit = try(gui.createTextBoxId(hwnd, ID_HISTORY_FILTER, "", 12, 116, 294, 28, false))
  workspaceTabs = try(gui.createTabControl(hwnd, ID_WORKSPACE_TABS, 320, 82, 1100, 30))
  worksheetTabs = try(gui.createTabControl(hwnd, ID_WORKSHEET_TABS, 320, 116, 1100, 30))
  queryEdit = try(gui.createSqlEditor(hwnd, ID_QUERY_EDIT, "SHOW TABLES;", 320, 150, 1100, 276))
  resultTabs = try(gui.createTabControl(hwnd, ID_RESULT_TABS, 320, 434, 1100, 30))
  resultGrid = try(gui.createListView(hwnd, ID_RESULT_GRID, 320, 468, 1100, 362))
  detailTabs = try(gui.createTabControl(hwnd, ID_DETAIL_TABS, 320, 116, 1100, 30))
  detailEdit = try(gui.createEdit(hwnd, "Select a table in the object tree and choose Open object.", 320, 150, 1100, 680, true))
  detailGrid = try(gui.createListView(hwnd, ID_DETAIL_GRID, 320, 194, 1100, 636))
  dataAddButton = try(gui.createButtonId(hwnd, ID_DATA_ADD, "+ Add row", 320, 150, 92, 34))
  dataCopyButton = try(gui.createButtonId(hwnd, ID_DATA_COPY, "Copy row", 420, 150, 92, 34))
  dataEditButton = try(gui.createButtonId(hwnd, ID_DATA_EDIT, "Edit row", 520, 150, 92, 34))
  dataDeleteButton = try(gui.createButtonId(hwnd, ID_DATA_DELETE, "Delete row", 620, 150, 96, 34))
  dataRefreshButton = try(gui.createButtonId(hwnd, ID_DATA_REFRESH, "Refresh data", 724, 150, 104, 34))
  dataCopyClipboardButton = try(gui.createButtonId(hwnd, ID_DATA_COPY_CLIPBOARD, "Copy", 836, 150, 72, 34))
  dataPasteButton = try(gui.createButtonId(hwnd, ID_DATA_PASTE, "Paste", 916, 150, 72, 34))
  dataFilterEdit = try(gui.createTextBoxId(hwnd, ID_DATA_FILTER, "", 320, 192, 360, 30, false))
  dataFilterButton = try(gui.createButtonId(hwnd, ID_DATA_FILTER_APPLY, "Apply filter", 688, 192, 92, 30))
  dataPreviousButton = try(gui.createButtonId(hwnd, ID_DATA_PREVIOUS_PAGE, "◀ Page", 788, 192, 82, 30))
  dataNextButton = try(gui.createButtonId(hwnd, ID_DATA_NEXT_PAGE, "Page ▶", 878, 192, 82, 30))
  dataPageLabel = try(gui.createLabel(hwnd, "Page 1", 968, 196, 180, 24))
  dataApplyButton = try(gui.createButtonId(hwnd, ID_DATA_APPLY_CHANGES, "Apply changes", 996, 150, 108, 34))
  dataRevertButton = try(gui.createButtonId(hwnd, ID_DATA_REVERT_CHANGES, "Revert", 1112, 150, 78, 34))
  dataPreviewButton = try(gui.createButtonId(hwnd, ID_DATA_PREVIEW_CHANGES, "SQL preview", 1198, 150, 96, 34))
  statusLabel = try(gui.createLabel(hwnd, "Ready", 12, 842, 1408, 24))
  controlFailure = firstControlError([refreshButton, openButton, newSqlButton, executeButton, executeScriptButton, explainButton, beginButton, commitButton, rollbackButton, stopButton, clearButton, schemaButton, exportCsvButton, closeSqlButton, closeButton, connectionLabel, sidebarTabs, objectTree, bookmarkList, historyList, historyFilterEdit, workspaceTabs, worksheetTabs, queryEdit, resultTabs, resultGrid, detailTabs, detailEdit, detailGrid, dataAddButton, dataCopyButton, dataEditButton, dataDeleteButton, dataRefreshButton, dataCopyClipboardButton, dataPasteButton, dataFilterEdit, dataFilterButton, dataPreviousButton, dataNextButton, dataPageLabel, dataApplyButton, dataRevertButton, dataPreviewButton, statusLabel])
  if controlFailure is not void then gui.destroy(hwnd); return controlFailure end if
  window = AdminWindow(hwnd, connectionLabel, sidebarTabs, objectTree, bookmarkList, historyList, workspaceTabs, detailTabs, resultTabs, queryEdit, detailEdit, detailGrid, dataAddButton, dataCopyButton, dataEditButton, dataDeleteButton, dataRefreshButton, resultGrid, refreshButton, openButton, newSqlButton, executeButton, executeScriptButton, explainButton, beginButton, commitButton, rollbackButton, stopButton, clearButton, closeButton, statusLabel, worksheetTabs, closeSqlButton, exportCsvButton, schemaButton, historyFilterEdit, dataCopyClipboardButton, dataPasteButton, dataFilterEdit, dataFilterButton, dataPreviousButton, dataNextButton, dataPageLabel, dataApplyButton, dataRevertButton, dataPreviewButton)
  ignoredHistoryCue = gui.setCueBanner(historyFilterEdit, "Search history …")
  ignoredFilterCue = gui.setCueBanner(dataFilterEdit, "WHERE predicate, e.g. active = TRUE")
  gui.tabAdd(sidebarTabs, "Objects")
  gui.tabAdd(sidebarTabs, "Bookmarks")
  gui.tabAdd(sidebarTabs, "History")
  gui.tabAdd(workspaceTabs, "SQL Worksheet")
  gui.tabAdd(workspaceTabs, "Object Details")
  gui.tabAdd(worksheetTabs, "SQL 1   ×")
  gui.tabSelect(sidebarTabs, 0)
  gui.tabSelect(workspaceTabs, 0)
  applyVisibility(window)
  layoutWindow(window)
  highlighted = try(highlightSqlEditor(window))
  if typeof(highlighted) == "error" then gui.destroy(hwnd); return highlighted end if
  if visible and not gui.showTopLevel(hwnd) then gui.destroy(hwnd); return fail("createWindow", "top-level window could not be shown") end if
  return window
end function

/// Parks one inactive notebook page outside the client area without destroying it.
/// @param hwnd hwnd value consumed by this operation.
function parkControl(hwnd)
  return gui.moveDip(hwnd, -32000, -32000, 1, 1)
end function

/// Reflows every workbench pane after a top-level resize.
/// @param window window value consumed by this operation.
function layoutWindow(window)
  size = try(gui.clientSizeDip(window.hwnd))
  if typeof(size) == "error" then return size end if
  width = size[0]
  height = size[1]
  if width < 980 then width = 980 end if
  if height < 650 then height = 650 end if
  compact = width < 1520
  contentTop = 82
  gui.moveDip(window.refreshButton, 12, 10, 92, 34)
  gui.moveDip(window.openButton, 112, 10, 106, 34)
  gui.moveDip(window.schemaButton, 226, 10, 82, 34)
  gui.moveDip(window.newSqlButton, 316, 10, 70, 34)
  gui.moveDip(window.closeSqlButton, 394, 10, 88, 34)
  gui.moveDip(window.executeButton, 490, 10, 116, 34)
  gui.moveDip(window.executeScriptButton, 614, 10, 96, 34)
  gui.moveDip(window.explainButton, 718, 10, 82, 34)
  if compact then
    gui.moveDip(window.stopButton, 808, 10, 72, 34)
    gui.moveDip(window.beginButton, 12, 52, 72, 34)
    gui.moveDip(window.commitButton, 92, 52, 76, 34)
    gui.moveDip(window.rollbackButton, 176, 52, 82, 34)
    gui.moveDip(window.clearButton, 266, 52, 104, 34)
    gui.moveDip(window.exportCsvButton, 378, 52, 92, 34)
    gui.moveDip(window.closeButton, width - 122, 52, 102, 34)
    gui.moveDip(window.connectionLabel, 12, 94, width - 24, 24)
    contentTop = 124
  else
    gui.moveDip(window.beginButton, 816, 10, 72, 34)
    gui.moveDip(window.commitButton, 896, 10, 76, 34)
    gui.moveDip(window.rollbackButton, 980, 10, 82, 34)
    gui.moveDip(window.stopButton, 1070, 10, 72, 34)
    gui.moveDip(window.clearButton, 1150, 10, 104, 34)
    gui.moveDip(window.exportCsvButton, 1262, 10, 92, 34)
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
  side = gui.tabSelectedIndex(window.sidebarTabs)
  if side == 0 then gui.moveDip(window.objectTree, 12, paneTop, left, bottom - paneTop) else parkControl(window.objectTree) end if
  if side == 1 then gui.moveDip(window.bookmarkList, 12, paneTop, left, bottom - paneTop) else parkControl(window.bookmarkList) end if
  if side == 2 then
    gui.moveDip(window.historyFilterEdit, 12, paneTop, left, 30)
    gui.moveDip(window.historyList, 12, paneTop + 38, left, bottom - paneTop - 38)
  else
    parkControl(window.historyFilterEdit)
    parkControl(window.historyList)
  end if
  gui.moveDip(window.workspaceTabs, mainX, contentTop, mainWidth, 30)
  editorHeight = (bottom - paneTop - 42) >> 1
  if editorHeight < 150 then editorHeight = 150 end if
  resultTabY = paneTop + editorHeight + 8
  workspace = gui.tabSelectedIndex(window.workspaceTabs)
  if workspace == 0 then
    gui.moveDip(window.worksheetTabs, mainX, paneTop, mainWidth, 30)
    gui.moveDip(window.queryEdit, mainX, paneTop + 34, mainWidth, editorHeight - 34)
    gui.moveDip(window.resultTabs, mainX, resultTabY, mainWidth, 30)
    gui.moveDip(window.resultGrid, mainX, resultTabY + 34, mainWidth, bottom - (resultTabY + 34))
    parkControl(window.detailTabs)
    parkControl(window.detailEdit)
    parkControl(window.detailGrid)
    parkControl(window.dataAddButton)
    parkControl(window.dataCopyButton)
    parkControl(window.dataEditButton)
    parkControl(window.dataDeleteButton)
    parkControl(window.dataRefreshButton)
    parkControl(window.dataCopyClipboardButton)
    parkControl(window.dataPasteButton)
    parkControl(window.dataFilterEdit)
    parkControl(window.dataFilterButton)
    parkControl(window.dataPreviousButton)
    parkControl(window.dataNextButton)
    parkControl(window.dataPageLabel)
    parkControl(window.dataApplyButton)
    parkControl(window.dataRevertButton)
    parkControl(window.dataPreviewButton)
  else
    parkControl(window.worksheetTabs)
    parkControl(window.queryEdit)
    parkControl(window.resultTabs)
    parkControl(window.resultGrid)
    gui.moveDip(window.detailTabs, mainX, paneTop, mainWidth, 30)
    detailPage = gui.tabSelectedIndex(window.detailTabs)
    structuredPage = detailPage >= 1 and detailPage <= 4
    dataPage = detailPage == 3
    if structuredPage then
      parkControl(window.detailEdit)
      gridTop = paneTop + 34
      if dataPage then
        gui.moveDip(window.dataAddButton, mainX, gridTop, 84, 34)
        gui.moveDip(window.dataCopyButton, mainX + 92, gridTop, 84, 34)
        gui.moveDip(window.dataEditButton, mainX + 184, gridTop, 84, 34)
        gui.moveDip(window.dataDeleteButton, mainX + 276, gridTop, 88, 34)
        gui.moveDip(window.dataRefreshButton, mainX + 372, gridTop, 96, 34)
        gui.moveDip(window.dataCopyClipboardButton, mainX + 476, gridTop, 64, 34)
        gui.moveDip(window.dataPasteButton, mainX + 548, gridTop, 64, 34)
        gui.moveDip(window.dataFilterEdit, mainX, gridTop + 42, 240, 30)
        gui.moveDip(window.dataFilterButton, mainX + 248, gridTop + 42, 90, 30)
        gui.moveDip(window.dataPreviousButton, mainX + 346, gridTop + 42, 72, 30)
        gui.moveDip(window.dataNextButton, mainX + 426, gridTop + 42, 72, 30)
        gui.moveDip(window.dataPageLabel, mainX + 506, gridTop + 46, mainWidth - 506, 24)
        gui.moveDip(window.dataApplyButton, mainX, gridTop + 80, 108, 30)
        gui.moveDip(window.dataRevertButton, mainX + 116, gridTop + 80, 78, 30)
        gui.moveDip(window.dataPreviewButton, mainX + 202, gridTop + 80, 96, 30)
        gridTop = gridTop + 118
      else
        parkControl(window.dataAddButton)
        parkControl(window.dataCopyButton)
        parkControl(window.dataEditButton)
        parkControl(window.dataDeleteButton)
        parkControl(window.dataRefreshButton)
        parkControl(window.dataCopyClipboardButton)
        parkControl(window.dataPasteButton)
        parkControl(window.dataFilterEdit)
        parkControl(window.dataFilterButton)
        parkControl(window.dataPreviousButton)
        parkControl(window.dataNextButton)
        parkControl(window.dataPageLabel)
        parkControl(window.dataApplyButton)
        parkControl(window.dataRevertButton)
        parkControl(window.dataPreviewButton)
      end if
      gui.moveDip(window.detailGrid, mainX, gridTop, mainWidth, bottom - gridTop)
    else
      parkControl(window.detailGrid)
      parkControl(window.dataAddButton)
      parkControl(window.dataCopyButton)
      parkControl(window.dataEditButton)
      parkControl(window.dataDeleteButton)
      parkControl(window.dataRefreshButton)
      parkControl(window.dataCopyClipboardButton)
      parkControl(window.dataPasteButton)
      parkControl(window.dataFilterEdit)
      parkControl(window.dataFilterButton)
      parkControl(window.dataPreviousButton)
      parkControl(window.dataNextButton)
      parkControl(window.dataPageLabel)
      parkControl(window.dataApplyButton)
      parkControl(window.dataRevertButton)
      parkControl(window.dataPreviewButton)
      gui.moveDip(window.detailEdit, mainX, paneTop + 34, mainWidth, bottom - (paneTop + 34))
    end if
  end if
  gui.moveDip(window.statusLabel, 12, height - 36, width - 24, 24)
  gui.redraw(window.hwnd)
  return true
end function

/// Verifies one workbench size through actual native child rectangles and pane separation.
/// @param window window value consumed by this operation.
/// @param width Width in the coordinate or storage units used by the caller.
/// @param height Height in the coordinate or storage units used by the caller.
function verifyWorkbenchLayout(window, width, height)
  resized = try(gui.setClientSizeDip(window.hwnd, width, height, true))
  if typeof(resized) == "error" or not resized then return fail("verifyWorkbenchLayout", "top-level resize failed") end if
  laidOut = try(layoutWindow(window))
  if typeof(laidOut) == "error" then return laidOut end if
  actual = try(gui.clientSizeDip(window.hwnd))
  if typeof(actual) == "error" then return actual end if
  controls = [window.connectionLabel, window.sidebarTabs, window.objectTree, window.workspaceTabs, window.worksheetTabs, window.resultTabs, window.queryEdit, window.resultGrid, window.refreshButton, window.openButton, window.schemaButton, window.newSqlButton, window.closeSqlButton, window.executeButton, window.executeScriptButton, window.explainButton, window.beginButton, window.commitButton, window.rollbackButton, window.stopButton, window.clearButton, window.exportCsvButton, window.closeButton, window.statusLabel]
  for each control in controls
    rectangle = try(gui.controlRectDip(window.hwnd, control))
    if typeof(rectangle) == "error" or not rectangleInside(rectangle, actual[0], actual[1]) then return fail("verifyWorkbenchLayout", "a workbench control is outside the client area") end if
  end for
  sidebarRect = try(gui.controlRectDip(window.hwnd, window.objectTree))
  editorRect = try(gui.controlRectDip(window.hwnd, window.queryEdit))
  resultsRect = try(gui.controlRectDip(window.hwnd, window.resultGrid))
  if rectanglesOverlap(sidebarRect, editorRect) or rectanglesOverlap(editorRect, resultsRect) then return fail("verifyWorkbenchLayout", "workbench panes overlap") end if
  parked = [window.bookmarkList, window.historyList, window.historyFilterEdit, window.detailTabs, window.detailEdit, window.detailGrid, window.dataAddButton, window.dataCopyButton, window.dataEditButton, window.dataDeleteButton, window.dataRefreshButton, window.dataCopyClipboardButton, window.dataPasteButton, window.dataFilterEdit, window.dataFilterButton, window.dataPreviousButton, window.dataNextButton, window.dataPageLabel, window.dataApplyButton, window.dataRevertButton, window.dataPreviewButton]
  for each control in parked
    rectangle = try(gui.controlRectDip(window.hwnd, control))
    if typeof(rectangle) == "error" or rectangleInside(rectangle, actual[0], actual[1]) then return fail("verifyWorkbenchLayout", "an inactive notebook page was not parked") end if
  end for
  closeRect = try(gui.controlRectDip(window.hwnd, window.closeButton))
  clearRect = try(gui.controlRectDip(window.hwnd, window.clearButton))
  if rectanglesOverlap(closeRect, clearRect) then return fail("verifyWorkbenchLayout", "toolbar actions overlap") end if
  return true
end function

/// Exercises geometry, native SQL coloring, selection stability, and both execution commands.
function workbenchLayoutSmoke()
  window = try(createWindow(false))
  if typeof(window) == "error" then return window end if
  compact = try(verifyWorkbenchLayout(window, 980, 650))
  if typeof(compact) == "error" then gui.destroy(window.hwnd); return compact end if
  wide = try(verifyWorkbenchLayout(window, 1600, 1000))
  if typeof(wide) == "error" then gui.destroy(window.hwnd); return wide end if
  editorText = "-- note\r\nSELECT 'value;still', 42 FROM \"Order\";"
  gui.setText(window.queryEdit, editorText)
  gui.selectText(window.queryEdit, 9, 15)
  highlighted = try(highlightSqlEditor(window))
  if typeof(highlighted) == "error" then gui.destroy(window.hwnd); return highlighted end if
  if gui.getText(window.queryEdit) != editorText then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "SQL editor text did not roundtrip") end if
  selection = gui.textSelection(window.queryEdit)
  if selection[0] != 9 or selection[1] != 15 then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "syntax highlighting moved the SQL selection") end if
  keywordStyle = gui.sqlEditorStyleAt(window.queryEdit, 9)
  commentStyle = gui.sqlEditorStyleAt(window.queryEdit, 0)
  if keywordStyle[0] != gui.SQL_COLOR_KEYWORD or (keywordStyle[1] & 1) == 0 then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "SELECT did not receive keyword styling") end if
  if commentStyle[0] != gui.SQL_COLOR_COMMENT or (commentStyle[1] & 2) == 0 then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "line comment did not receive comment styling") end if
  multilineText = "SHOW TABLES;\r\n\r\nSELECT* from shop_customer;"
  gui.setText(window.queryEdit, multilineText)
  multilineStart = fullclient.utf16Length("SHOW TABLES;\r\n\r\n")
  gui.selectText(window.queryEdit, multilineStart, multilineStart)
  highlightedMultiline = try(highlightSqlEditor(window))
  if typeof(highlightedMultiline) == "error" then gui.destroy(window.hwnd); return highlightedMultiline end if
  multilineSelection = try(gui.textSelection(window.queryEdit))
  selectStyle = try(gui.sqlEditorStyleAt(window.queryEdit, multilineStart))
  fromStyle = try(gui.sqlEditorStyleAt(window.queryEdit, multilineStart + 8))
  starStyle = try(gui.sqlEditorStyleAt(window.queryEdit, multilineStart + 6))
  if multilineSelection[0] != multilineStart or multilineSelection[1] != multilineStart then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "CRLF translation moved the multiline caret") end if
  if selectStyle[0] != gui.SQL_COLOR_KEYWORD or (selectStyle[1] & 1) == 0 or fromStyle[0] != gui.SQL_COLOR_KEYWORD or (fromStyle[1] & 1) == 0 then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "keywords after CRLF did not receive complete styling") end if
  if starStyle[0] != gui.SQL_COLOR_DEFAULT or (starStyle[1] & 1) != 0 then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "operator after CRLF inherited keyword styling") end if
  tabSession = AdminSession(window, void, void, false, false, false, false, 0, 0, [fullclient.newWorksheet(1, editorText)], 0, 2, [], fullclient.defaultDataBrowseOptions(), "", "", [])
  gui.clearEvents()
  if not gui.clickTabHeaderForTest(window.workspaceTabs, 180, 12) then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "workspace tab could not be clicked") end if
  gui.pumpMessages()
  receivedWorkspaceTab = false
  event = gui.pollEvent()
  while typeof(event) == "struct"
    if event.message == gui.WM_NOTIFY and event.controlId == ID_WORKSPACE_TABS and event.notification == TCN_SELCHANGE then
      receivedWorkspaceTab = true
      handledWorkspaceTab = try(handleSessionEvent(tabSession, event))
      if typeof(handledWorkspaceTab) == "error" then gui.destroy(window.hwnd); return handledWorkspaceTab end if
    end if
    event = gui.pollEvent()
  end while
  if gui.tabSelectedIndex(window.workspaceTabs) != 1 then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "native workspace click did not select Object Details") end if
  if not receivedWorkspaceTab then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "native workspace click did not deliver TCN_SELCHANGE") end if
  actual = try(gui.clientSizeDip(window.hwnd))
  queryRect = try(gui.controlRectDip(window.hwnd, window.queryEdit))
  detailRect = try(gui.controlRectDip(window.hwnd, window.detailEdit))
  if tabSession.workspacePage != 1 or typeof(actual) == "error" or typeof(queryRect) == "error" or typeof(detailRect) == "error" or rectangleInside(queryRect, actual[0], actual[1]) or not rectangleInside(detailRect, actual[0], actual[1]) then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "Object Details geometry did not follow the native tab") end if
  worksheetSelected = try(selectWorkspace(tabSession, 0))
  if typeof(worksheetSelected) == "error" then gui.destroy(window.hwnd); return worksheetSelected end if
  queryRect = try(gui.controlRectDip(window.hwnd, window.queryEdit))
  detailRect = try(gui.controlRectDip(window.hwnd, window.detailEdit))
  if typeof(queryRect) == "error" or typeof(detailRect) == "error" or not rectangleInside(queryRect, actual[0], actual[1]) or rectangleInside(detailRect, actual[0], actual[1]) then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "SQL Worksheet geometry was not restored") end if
  gui.clearEvents()
  if not gui.postCommandForTest(window.hwnd, ID_EXECUTE) then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "execute command could not be posted") end if
  if not gui.postCommandForTest(window.hwnd, ID_EXECUTE_SCRIPT) then gui.destroy(window.hwnd); return fail("workbenchLayoutSmoke", "script command could not be posted") end if
  gui.pumpMessages()
  receivedCurrent = false
  receivedScript = false
  event = gui.pollEvent()
  while typeof(event) == "struct"
    if event.message == gui.WM_COMMAND and event.controlId == ID_EXECUTE then receivedCurrent = true end if
    if event.message == gui.WM_COMMAND and event.controlId == ID_EXECUTE_SCRIPT then receivedScript = true end if
    event = gui.pollEvent()
  end while
  gui.destroy(window.hwnd)
  if not receivedCurrent or not receivedScript then return fail("workbenchLayoutSmoke", "current/script execution command was not delivered") end if
  return true
end function

/// Runs both responsive native-window probes against the per-user profile location.
function layoutSmoke()
  connection = try(connectionLayoutProbe([connection_profiles.defaultProfile()]))
  if typeof(connection) == "error" then return connection end if
  return workbenchLayoutSmoke()
end function

/// Shows controls belonging to the selected sidebar and workspace tabs.
/// @param window window value consumed by this operation.
function applyVisibility(window)
  side = gui.tabSelectedIndex(window.sidebarTabs)
  gui.show(window.objectTree, side == 0)
  gui.show(window.bookmarkList, side == 1)
  gui.show(window.historyList, side == 2)
  gui.show(window.historyFilterEdit, side == 2)
  workspace = gui.tabSelectedIndex(window.workspaceTabs)
  gui.show(window.worksheetTabs, workspace == 0)
  gui.show(window.queryEdit, workspace == 0)
  gui.show(window.resultTabs, workspace == 0)
  gui.show(window.resultGrid, workspace == 0)
  gui.show(window.detailTabs, workspace == 1)
  detailPage = gui.tabSelectedIndex(window.detailTabs)
  structuredPage = workspace == 1 and detailPage >= 1 and detailPage <= 4
  dataPage = workspace == 1 and detailPage == 3
  gui.show(window.detailEdit, workspace == 1 and not structuredPage)
  gui.show(window.detailGrid, structuredPage)
  gui.show(window.dataAddButton, dataPage)
  gui.show(window.dataCopyButton, dataPage)
  gui.show(window.dataEditButton, dataPage)
  gui.show(window.dataDeleteButton, dataPage)
  gui.show(window.dataRefreshButton, dataPage)
  gui.show(window.dataCopyClipboardButton, dataPage)
  gui.show(window.dataPasteButton, dataPage)
  gui.show(window.dataFilterEdit, dataPage)
  gui.show(window.dataFilterButton, dataPage)
  gui.show(window.dataPreviousButton, dataPage)
  gui.show(window.dataNextButton, dataPage)
  gui.show(window.dataPageLabel, dataPage)
  gui.show(window.dataApplyButton, dataPage)
  gui.show(window.dataRevertButton, dataPage)
  gui.show(window.dataPreviewButton, dataPage)
  return layoutWindow(window)
end function

/// Selects and persists one main workspace page before updating child visibility.
/// @param session session value consumed by this operation.
/// @param page page value consumed by this operation.
function selectWorkspace(session, page)
  if session is not AdminSession or typeof(page) != "int" or page < 0 or page > 1 then return fail("selectWorkspace", "workspace page must be zero or one") end if
  session.workspacePage = page
  ignoredSelection = gui.tabSelect(session.window.workspaceTabs, page)
  return applyVisibility(session.window)
end function

/// Reconciles a user-driven native tab selection before asynchronous rendering.
/// @param session session value consumed by this operation.
function synchronizeWorkspace(session)
  if session is not AdminSession then return fail("synchronizeWorkspace", "session must be AdminSession") end if
  selectedPage = gui.tabSelectedIndex(session.window.workspaceTabs)
  if selectedPage < 0 or selectedPage > 1 then return fail("synchronizeWorkspace", "native workspace selection is invalid") end if
  if selectedPage == session.workspacePage then return false end if
  session.workspacePage = selectedPage
  applied = try(applyVisibility(session.window))
  if typeof(applied) == "error" then return applied end if
  return true
end function

/// Restores the session-owned page after native controls were repopulated.
/// @param session session value consumed by this operation.
function restoreWorkspace(session)
  if session is not AdminSession then return fail("restoreWorkspace", "session must be AdminSession") end if
  if gui.tabSelectedIndex(session.window.workspaceTabs) != session.workspacePage then ignoredSelection = gui.tabSelect(session.window.workspaceTabs, session.workspacePage) end if
  return applyVisibility(session.window)
end function

/// Populates a list box from ordered display strings.
/// @param hwnd hwnd value consumed by this operation.
/// @param values values value consumed by this operation.
function fillList(hwnd, values)
  reset = try(gui.listReset(hwnd))
  if typeof(reset) == "error" then return reset end if
  for each value in values
    added = try(gui.listAdd(hwnd, value))
    if typeof(added) == "error" then return added end if
  end for
  return true
end function

/// Rebuilds the MiniSQL-only database object hierarchy.
/// @param window window value consumed by this operation.
/// @param state Mutable state inspected or updated by the operation.
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

/// Replaces tab captions and restores a valid selection.
/// @param hwnd hwnd value consumed by this operation.
/// @param labels labels value consumed by this operation.
/// @param selected selected value consumed by this operation.
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

/// Renders notebook labels with a trailing multiplication-sign close target.
/// @param hwnd hwnd value consumed by this operation.
/// @param labels labels value consumed by this operation.
/// @param selected selected value consumed by this operation.
function fillClosableTabs(hwnd, labels, selected)
  closable = []
  for each label in labels
    closable = closable + [label + "   ×"]
  end for
  return fillTabs(hwnd, closable, selected)
end function

/// Renders the active structured result into the native ListView grid.
/// @param window window value consumed by this operation.
/// @param state Mutable state inspected or updated by the operation.
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

/// Chooses readable report-column widths while keeping compact metadata flags narrow.
/// @param caption caption value consumed by this operation.
function detailColumnWidthDip(caption)
  if caption == "ordinal" or caption == "id" or caption == "nullable" or caption == "identity" or caption == "unique" or caption == "row_count" then return 100 end if
  if caption == "data_type" or caption == "default_sql" or caption == "index_kind" then return 150 end if
  if caption == "column_name" or caption == "index_name" or caption == "columns" then return 190 end if
  return 180
end function

/// Renders a structured object-detail response into the shared native report grid.
/// @param session session value consumed by this operation.
/// @param detailName detailName value consumed by this operation.
function fillDetailGrid(session, detailName)
  window = session.window
  state = session.state
  resetRows = try(gui.listViewReset(window.detailGrid))
  if typeof(resetRows) == "error" then return resetRows end if
  resetColumns = try(gui.listViewResetColumns(window.detailGrid))
  if typeof(resetColumns) == "error" then return resetColumns end if
  grid = fullclient.detailGridByName(state, detailName)
  if detailName == "Data" then grid = fullclient.dataGridWithChanges(state.tableDetails, session.pendingChanges) end if
  if grid is void or len(grid.columns) == 0 then
    messageColumn = try(gui.listViewAddColumn(window.detailGrid, 0, "Message", gui.scaleDip(window.hwnd, 600)))
    if typeof(messageColumn) == "error" then return messageColumn end if
    return true
  end if
  for index = 0 to len(grid.columns) - 1
    width = gui.scaleDip(window.hwnd, detailColumnWidthDip(grid.columns[index]))
    insertedColumn = try(gui.listViewAddColumn(window.detailGrid, index, grid.columns[index], width))
    if typeof(insertedColumn) == "error" then return insertedColumn end if
  end for
  if len(grid.rows) > 0 then
    for rowIndex = 0 to len(grid.rows) - 1
      insertedRow = try(gui.listViewAddRow(window.detailGrid, rowIndex, grid.rows[rowIndex]))
      if typeof(insertedRow) == "error" then return insertedRow end if
    end for
  end if
  return true
end function

/// Enables query actions only when no native SQL worker owns the client session.
/// @param session session value consumed by this operation.
function setBusyControls(session)
  enabled = not session.busy
  gui.setEnabled(session.window.sidebarTabs, enabled)
  gui.setEnabled(session.window.objectTree, enabled)
  gui.setEnabled(session.window.bookmarkList, enabled)
  gui.setEnabled(session.window.historyList, enabled)
  gui.setEnabled(session.window.workspaceTabs, enabled)
  gui.setEnabled(session.window.detailTabs, enabled)
  gui.setEnabled(session.window.detailGrid, enabled)
  gui.setEnabled(session.window.dataAddButton, enabled)
  gui.setEnabled(session.window.dataCopyButton, enabled)
  gui.setEnabled(session.window.dataEditButton, enabled)
  gui.setEnabled(session.window.dataDeleteButton, enabled)
  gui.setEnabled(session.window.dataRefreshButton, enabled)
  gui.setEnabled(session.window.dataCopyClipboardButton, enabled)
  gui.setEnabled(session.window.dataPasteButton, enabled)
  gui.setEnabled(session.window.dataFilterEdit, enabled)
  gui.setEnabled(session.window.dataFilterButton, enabled)
  gui.setEnabled(session.window.dataPreviousButton, enabled and session.dataOptions.page > 0)
  gui.setEnabled(session.window.dataNextButton, enabled and len(session.state.tableDetails.contentsGrid.rows) >= session.dataOptions.pageSize)
  gui.setEnabled(session.window.dataApplyButton, enabled and len(session.pendingChanges) > 0)
  gui.setEnabled(session.window.dataRevertButton, enabled and len(session.pendingChanges) > 0)
  gui.setEnabled(session.window.dataPreviewButton, enabled and len(session.pendingChanges) > 0)
  gui.setEnabled(session.window.resultTabs, enabled)
  gui.setEnabled(session.window.queryEdit, enabled)
  gui.setEnabled(session.window.executeButton, enabled)
  gui.setEnabled(session.window.executeScriptButton, enabled)
  gui.setEnabled(session.window.explainButton, enabled)
  gui.setEnabled(session.window.beginButton, enabled)
  gui.setEnabled(session.window.commitButton, enabled)
  gui.setEnabled(session.window.rollbackButton, enabled)
  gui.setEnabled(session.window.refreshButton, enabled)
  gui.setEnabled(session.window.openButton, enabled)
  gui.setEnabled(session.window.newSqlButton, enabled)
  gui.setEnabled(session.window.clearButton, enabled)
  gui.setEnabled(session.window.worksheetTabs, enabled)
  gui.setEnabled(session.window.closeSqlButton, enabled)
  gui.setEnabled(session.window.exportCsvButton, enabled and fullclient.activeResultTab(session.state) is not void)
  gui.setEnabled(session.window.schemaButton, enabled)
  gui.setEnabled(session.window.historyFilterEdit, enabled)
  gui.setEnabled(session.window.stopButton, session.busy)
  return true
end function

/// Renders all workbench panes from the current fullclient model.
/// @param session session value consumed by this operation.
function render(session)
  treeRendered = try(fillObjectTree(session.window, session.state))
  if typeof(treeRendered) == "error" then return treeRendered end if
  bookmarksRendered = try(fillList(session.window.bookmarkList, fullclient.bookmarkLines(session.state.bookmarks)))
  if typeof(bookmarksRendered) == "error" then return bookmarksRendered end if
  historyRendered = try(fillList(session.window.historyList, fullclient.filterHistory(session.state.history, session.historyFilter)))
  if typeof(historyRendered) == "error" then return historyRendered end if
  worksheetsRendered = try(fillClosableTabs(session.window.worksheetTabs, fullclient.worksheetLines(session.worksheets), session.selectedWorksheetIndex))
  if typeof(worksheetsRendered) == "error" then return worksheetsRendered end if
  detailSelected = gui.tabSelectedIndex(session.window.detailTabs)
  detailsRendered = try(fillTabs(session.window.detailTabs, fullclient.detailTabLines(session.state), detailSelected))
  if typeof(detailsRendered) == "error" then return detailsRendered end if
  tabsRendered = try(fillClosableTabs(session.window.resultTabs, fullclient.resultTabLines(session.state.resultTabs), session.state.selectedResultIndex))
  if typeof(tabsRendered) == "error" then return tabsRendered end if
  gridRendered = try(fillResultGrid(session.window, session.state))
  if typeof(gridRendered) == "error" then return gridRendered end if
  detailName = "Database"
  labels = fullclient.detailTabLines(session.state)
  detailSelected = gui.tabSelectedIndex(session.window.detailTabs)
  if detailSelected >= 0 and detailSelected < len(labels) then detailName = labels[detailSelected] end if
  gui.setText(session.window.detailEdit, fullclient.detailTextByName(session.state, detailName))
  detailGridRendered = try(fillDetailGrid(session, detailName))
  if typeof(detailGridRendered) == "error" then return detailGridRendered end if
  totalText = "?"
  if len(session.state.tableDetails.rowCountGrid.rows) > 0 and len(session.state.tableDetails.rowCountGrid.rows[0]) > 0 then totalText = session.state.tableDetails.rowCountGrid.rows[0][0] end if
  sortText = "natural order"
  if len(session.dataOptions.sortColumn) > 0 then sortText = session.dataOptions.sortColumn + " ASC"; if not session.dataOptions.ascending then sortText = session.dataOptions.sortColumn + " DESC" end if end if
  pageText = "Page " + (session.dataOptions.page + 1) + "   •   " + totalText + " rows   •   " + sortText + "   •   " + len(session.pendingChanges) + " pending"
  gui.setText(session.window.dataPageLabel, pageText)
  gui.setText(session.window.connectionLabel, session.state.profile.name + "   •   " + fullclient.endpointText(session.state.profile))
  gui.setText(session.window.statusLabel, session.state.statusText)
  setBusyControls(session)
  restoredWorkspace = try(restoreWorkspace(session))
  if typeof(restoredWorkspace) == "error" then return restoredWorkspace end if
  layoutWindow(session.window)
  return true
end function

/// Creates the modal structured MiniSQL schema designer.
/// @param tableName tableName value consumed by this operation.
/// @param visible visible value consumed by this operation.
function createSchemaEditorWindow(tableName, visible)
  hwnd = try(gui.createTopLevel("MiniSQL Schema Designer", 900, 650, false))
  if typeof(hwnd) == "error" then return hwnd end if
  gui.setMinimumClientSizeDip(hwnd, 700, 500)
  actions = try(gui.createListBoxId(hwnd, ID_SCHEMA_ACTIONS, 16, 54, 210, 510))
  title = try(gui.createLabel(hwnd, "Schema operation", 16, 18, 210, 28))
  tableLabel = try(gui.createLabel(hwnd, "Table", 246, 18, 620, 24))
  tableEdit = try(gui.createTextBoxId(hwnd, ID_SCHEMA_TABLE, tableName, 246, 44, 620, 30, false))
  objectLabel = try(gui.createLabel(hwnd, "Column / index / constraint name", 246, 84, 620, 24))
  objectEdit = try(gui.createTextBoxId(hwnd, ID_SCHEMA_OBJECT, "", 246, 110, 620, 30, false))
  definitionLabel = try(gui.createLabel(hwnd, "Definition / comma-separated index columns", 246, 150, 620, 24))
  definitionEdit = try(gui.createTextBoxId(hwnd, ID_SCHEMA_DEFINITION, "", 246, 176, 620, 30, false))
  optionLabel = try(gui.createLabel(hwnd, "Option (UNIQUE or rename target)", 246, 216, 620, 24))
  optionEdit = try(gui.createTextBoxId(hwnd, ID_SCHEMA_OPTION, "", 246, 242, 620, 30, false))
  previewLabel = try(gui.createLabel(hwnd, "Generated DDL preview", 246, 284, 620, 24))
  previewEdit = try(gui.createEdit(hwnd, "Enter the required fields to generate DDL.", 246, 310, 620, 254, true))
  executeButton = try(gui.createDefaultButtonId(hwnd, ID_SCHEMA_EXECUTE, "Execute DDL", 548, 584, 102, 34))
  insertButton = try(gui.createButtonId(hwnd, ID_SCHEMA_INSERT, "Insert into SQL", 658, 584, 112, 34))
  cancelButton = try(gui.createButtonId(hwnd, ID_SCHEMA_CANCEL, "Cancel", 778, 584, 88, 34))
  labels = [title, tableLabel, objectLabel, definitionLabel, optionLabel, previewLabel]
  controlFailure = firstControlError([actions, tableEdit, objectEdit, definitionEdit, optionEdit, previewEdit, executeButton, insertButton, cancelButton] + labels)
  if controlFailure is not void then gui.destroy(hwnd); return controlFailure end if
  for each action in fullclient.schemaActionLines()
    added = try(gui.listAdd(actions, action))
    if typeof(added) == "error" then gui.destroy(hwnd); return added end if
  end for
  gui.listSelect(actions, 0)
  window = SchemaEditorWindow(hwnd, actions, tableEdit, objectEdit, definitionEdit, optionEdit, previewEdit, executeButton, insertButton, cancelButton, labels)
  layoutSchemaEditor(window)
  if visible and not gui.showTopLevel(hwnd) then gui.destroy(hwnd); return fail("createSchemaEditorWindow", "schema designer could not be shown") end if
  return window
end function

/// Reflows the schema designer at its current DPI and client size.
/// @param window window value consumed by this operation.
function layoutSchemaEditor(window)
  size = try(gui.clientSizeDip(window.hwnd))
  if typeof(size) == "error" then return size end if
  width = size[0]
  height = size[1]
  if width < 700 then width = 700 end if
  if height < 500 then height = 500 end if
  leftWidth = 210
  rightX = 246
  rightWidth = width - rightX - 24
  gui.moveDip(window.labels[0], 16, 18, leftWidth, 28)
  gui.moveDip(window.actionList, 16, 54, leftWidth, height - 78)
  y = 18
  for index = 1 to 4
    gui.moveDip(window.labels[index], rightX, y, rightWidth, 24)
    editor = window.tableEdit
    if index == 2 then editor = window.objectEdit end if
    if index == 3 then editor = window.definitionEdit end if
    if index == 4 then editor = window.optionEdit end if
    gui.moveDip(editor, rightX, y + 26, rightWidth, 30)
    y = y + 66
  end for
  gui.moveDip(window.labels[5], rightX, y + 2, rightWidth, 24)
  buttonY = height - 50
  gui.moveDip(window.previewEdit, rightX, y + 28, rightWidth, buttonY - y - 36)
  gui.moveDip(window.executeButton, width - 342, buttonY, 102, 34)
  gui.moveDip(window.insertButton, width - 232, buttonY, 112, 34)
  gui.moveDip(window.cancelButton, width - 112, buttonY, 88, 34)
  gui.redraw(window.hwnd)
  return true
end function

/// Rebuilds the exact DDL preview from all current schema-designer fields.
/// @param editor editor value consumed by this operation.
function renderSchemaEditor(editor)
  action = gui.listSelectedIndex(editor.window.actionList)
  tableName = try(gui.getText(editor.window.tableEdit))
  objectName = try(gui.getText(editor.window.objectEdit))
  definition = try(gui.getText(editor.window.definitionEdit))
  optionText = try(gui.getText(editor.window.optionEdit))
  sqlText = try(fullclient.schemaEditorSql(action, tableName, objectName, definition, optionText))
  if typeof(sqlText) == "error" then gui.setText(editor.window.previewEdit, "Cannot generate DDL yet:\r\n" + sqlText.message); return sqlText end if
  gui.setText(editor.window.previewEdit, sqlText)
  return sqlText
end function

/// Runs the modal schema designer and returns generated SQL plus execution intent.
/// @param session session value consumed by this operation.
function runSchemaEditor(session)
  window = try(createSchemaEditorWindow(session.state.selectedTable, false))
  if typeof(window) == "error" then return window end if
  editor = SchemaEditorState(window, void, false)
  ignoredPreview = try(renderSchemaEditor(editor))
  gui.setEnabled(session.window.hwnd, false)
  if not gui.showTopLevel(window.hwnd) then gui.setEnabled(session.window.hwnd, true); gui.destroy(window.hwnd); return fail("runSchemaEditor", "schema designer could not be shown") end if
  while gui.isOpen(window.hwnd) and gui.isOpen(session.window.hwnd)
    ignoredPump = gui.pumpMessages()
    event = gui.pollEvent()
    while typeof(event) == "struct"
      if event.hwnd == window.hwnd and (event.message == gui.WM_SIZE or event.message == gui.WM_DPICHANGED) then
        ignoredLayout = try(layoutSchemaEditor(window))
      else if event.hwnd == window.hwnd and event.message == gui.WM_COMMAND then
        if event.controlId == ID_SCHEMA_CANCEL then
          gui.destroy(window.hwnd)
        else if event.controlId == ID_SCHEMA_EXECUTE or event.controlId == ID_SCHEMA_INSERT then
          sqlText = try(renderSchemaEditor(editor))
          if typeof(sqlText) != "error" then editor.resultSql = sqlText; editor.executeImmediately = event.controlId == ID_SCHEMA_EXECUTE; gui.destroy(window.hwnd) end if
        else if event.controlId == ID_SCHEMA_ACTIONS or event.controlId == ID_SCHEMA_TABLE or event.controlId == ID_SCHEMA_OBJECT or event.controlId == ID_SCHEMA_DEFINITION or event.controlId == ID_SCHEMA_OPTION then
          ignoredChangedPreview = try(renderSchemaEditor(editor))
        end if
      end if
      event = gui.pollEvent()
    end while
    gui.sleep(10)
  end while
  if gui.isOpen(window.hwnd) then gui.destroy(window.hwnd) end if
  if gui.isOpen(session.window.hwnd) then gui.setEnabled(session.window.hwnd, true) end if
  if editor.resultSql is void then return void end if
  return [editor.resultSql, editor.executeImmediately]
end function

/// Opens the schema designer and either executes or inserts its generated DDL.
/// @param session session value consumed by this operation.
function openSchemaDesigner(session)
  result = try(runSchemaEditor(session))
  if typeof(result) == "error" then session.state.statusText = result.message; return result end if
  if result is void then session.state.statusText = "Schema design cancelled"; return false end if
  if result[1] then
    if not gui.confirmWarning(session.window.hwnd, "Execute schema DDL", "Execute this schema change?\r\n\r\n" + result[0]) then session.state.statusText = "Schema change cancelled"; return false end if
    return startSchemaMutation(session, result[0])
  end if
  return addWorksheet(session, result[0])
end function

/// Creates the modal field-by-field editor used for inserts, copies, and updates.
/// @param details details value consumed by this operation.
/// @param updateMode updateMode value consumed by this operation.
/// @param visible visible value consumed by this operation.
function createRowEditorWindow(details, updateMode, visible)
  if typeof(details) != "struct" or typeof(updateMode) != "bool" or typeof(visible) != "bool" then return fail("createRowEditorWindow", "invalid row-editor arguments") end if
  title = "Add row — " + details.tableName
  if updateMode then title = "Edit row — " + details.tableName end if
  hwnd = try(gui.createTopLevel(title, 760, 560, false))
  if typeof(hwnd) == "error" then return hwnd end if
  ignoredSize = try(gui.setClientSizeDip(hwnd, 760, 560, false))
  if typeof(ignoredSize) == "error" or not ignoredSize then gui.destroy(hwnd); return fail("createRowEditorWindow", "row editor could not be sized") end if
  gui.setMinimumClientSizeDip(hwnd, 680, 520)
  titleLabel = try(gui.createLabel(hwnd, title, 20, 16, 720, 26))
  fieldLabel = try(gui.createLabel(hwnd, "Column", 20, 48, 720, 24))
  valuesGrid = try(gui.createListView(hwnd, ID_ROW_VALUES, 20, 78, 720, 310))
  valueEdit = try(gui.createTextBoxId(hwnd, ID_ROW_VALUE, "", 20, 400, 720, 30, false))
  hintLabel = try(gui.createLabel(hwnd, "Use <NULL> for SQL NULL. <DEFAULT> is available for inserts.", 20, 438, 720, 24))
  previousButton = try(gui.createButtonId(hwnd, ID_ROW_PREVIOUS, "Previous", 20, 482, 96, 34))
  nextButton = try(gui.createButtonId(hwnd, ID_ROW_NEXT, "Next", 124, 482, 96, 34))
  saveButton = try(gui.createDefaultButtonId(hwnd, ID_ROW_SAVE, "Save row", 528, 482, 96, 34))
  cancelButton = try(gui.createButtonId(hwnd, ID_ROW_CANCEL, "Cancel", 632, 482, 108, 34))
  controlFailure = firstControlError([titleLabel, fieldLabel, valuesGrid, valueEdit, hintLabel, previousButton, nextButton, saveButton, cancelButton])
  if controlFailure is not void then gui.destroy(hwnd); return controlFailure end if
  window = RowEditorWindow(hwnd, titleLabel, fieldLabel, valuesGrid, valueEdit, hintLabel, previousButton, nextButton, saveButton, cancelButton)
  laidOut = try(layoutRowEditor(window))
  if typeof(laidOut) == "error" then gui.destroy(hwnd); return laidOut end if
  if visible and not gui.showTopLevel(hwnd) then gui.destroy(hwnd); return fail("createRowEditorWindow", "row editor could not be shown") end if
  return window
end function

/// Reflows the modal row editor for DPI changes and user-driven resizing.
/// @param window window value consumed by this operation.
function layoutRowEditor(window)
  size = try(gui.clientSizeDip(window.hwnd))
  if typeof(size) == "error" then return size end if
  width = size[0]
  height = size[1]
  if width < 680 then width = 680 end if
  if height < 520 then height = 520 end if
  buttonsY = height - 58
  hintY = buttonsY - 44
  valueY = hintY - 38
  gridHeight = valueY - 90
  gui.moveDip(window.titleLabel, 20, 16, width - 40, 26)
  gui.moveDip(window.fieldLabel, 20, 48, width - 40, 24)
  gui.moveDip(window.valuesGrid, 20, 78, width - 40, gridHeight)
  gui.moveDip(window.valueEdit, 20, valueY, width - 40, 30)
  gui.moveDip(window.hintLabel, 20, hintY, width - 40, 24)
  gui.moveDip(window.previousButton, 20, buttonsY, 96, 34)
  gui.moveDip(window.nextButton, 124, buttonsY, 96, 34)
  gui.moveDip(window.saveButton, width - 232, buttonsY, 96, 34)
  gui.moveDip(window.cancelButton, width - 128, buttonsY, 108, 34)
  gui.redraw(window.hwnd)
  return true
end function

/// Rebuilds the row-editor review table and focuses the active field value.
/// @param editor editor value consumed by this operation.
function renderRowEditor(editor)
  if editor is not RowEditorState or len(editor.details.columnsGrid.rows) == 0 then return fail("renderRowEditor", "row editor has no columns") end if
  if editor.fieldIndex < 0 then editor.fieldIndex = 0 end if
  if editor.fieldIndex >= len(editor.values) then editor.fieldIndex = len(editor.values) - 1 end if
  metadataRow = editor.details.columnsGrid.rows[editor.fieldIndex]
  policy = "NOT NULL"
  if metadataRow[3] == "TRUE" then policy = "nullable" end if
  if metadataRow[5] == "TRUE" then policy = "identity" else if metadataRow[4] != "NULL" then policy = "default " + metadataRow[4] end if
  gui.setText(editor.window.fieldLabel, "Column " + (editor.fieldIndex + 1) + " of " + len(editor.values) + ": " + metadataRow[1] + "   •   " + metadataRow[2] + "   •   " + policy)
  gui.setText(editor.window.valueEdit, editor.values[editor.fieldIndex])
  resetRows = try(gui.listViewReset(editor.window.valuesGrid))
  if typeof(resetRows) == "error" then return resetRows end if
  resetColumns = try(gui.listViewResetColumns(editor.window.valuesGrid))
  if typeof(resetColumns) == "error" then return resetColumns end if
  gui.listViewAddColumn(editor.window.valuesGrid, 0, "Column", gui.scaleDip(editor.window.hwnd, 220))
  gui.listViewAddColumn(editor.window.valuesGrid, 1, "Type", gui.scaleDip(editor.window.hwnd, 150))
  gui.listViewAddColumn(editor.window.valuesGrid, 2, "Value", gui.scaleDip(editor.window.hwnd, 320))
  for index = 0 to len(editor.values) - 1
    row = editor.details.columnsGrid.rows[index]
    inserted = try(gui.listViewAddRow(editor.window.valuesGrid, index, [row[1], row[2], editor.values[index]]))
    if typeof(inserted) == "error" then return inserted end if
  end for
  gui.listViewSelect(editor.window.valuesGrid, editor.fieldIndex)
  gui.setEnabled(editor.window.previousButton, editor.fieldIndex > 0)
  gui.setEnabled(editor.window.nextButton, editor.fieldIndex + 1 < len(editor.values))
  gui.focus(editor.window.valueEdit)
  return true
end function

/// Copies the active text box into its aligned row-editor draft slot.
/// @param editor editor value consumed by this operation.
function storeRowEditorValue(editor)
  if editor is not RowEditorState or editor.fieldIndex < 0 or editor.fieldIndex >= len(editor.values) then return fail("storeRowEditorValue", "active field is invalid") end if
  value = try(gui.getText(editor.window.valueEdit))
  if typeof(value) == "error" then return value end if
  editor.values[editor.fieldIndex] = value
  return true
end function

/// Commits the active value and navigates by one bounded field.
/// @param editor editor value consumed by this operation.
/// @param delta delta value consumed by this operation.
function moveRowEditor(editor, delta)
  stored = try(storeRowEditorValue(editor))
  if typeof(stored) == "error" then return stored end if
  target = editor.fieldIndex + delta
  if target < 0 then target = 0 end if
  if target >= len(editor.values) then target = len(editor.values) - 1 end if
  editor.fieldIndex = target
  return renderRowEditor(editor)
end function

/// Validates the complete draft and builds its INSERT or keyed UPDATE statement.
/// @param editor editor value consumed by this operation.
function rowEditorSql(editor)
  stored = try(storeRowEditorValue(editor))
  if typeof(stored) == "error" then return stored end if
  if editor.updateMode then
    if editor.originalRowIndex < 0 or editor.originalRowIndex >= len(editor.details.contentsGrid.rows) then return fail("rowEditorSql", "original preview row is unavailable") end if
    return fullclient.updateDataSql(editor.details, editor.details.contentsGrid.rows[editor.originalRowIndex], editor.values)
  end if
  return fullclient.insertDataSql(editor.details, editor.values)
end function

/// Runs one modal row editor and returns generated SQL plus its preview values.
/// @param session session value consumed by this operation.
/// @param rowIndex Zero-based index of row.
/// @param duplicate duplicate value consumed by this operation.
/// @param updateMode updateMode value consumed by this operation.
/// @param initialField initialField value consumed by this operation.
function runRowEditor(session, rowIndex, duplicate, updateMode, initialField)
  values = try(fullclient.dataEditorValues(session.state.tableDetails, rowIndex, duplicate))
  if typeof(values) == "error" then return values end if
  window = try(createRowEditorWindow(session.state.tableDetails, updateMode, false))
  if typeof(window) == "error" then return window end if
  if typeof(initialField) != "int" or initialField < 0 or initialField >= len(values) then initialField = 0 end if
  editor = RowEditorState(window, session.state.tableDetails, values, initialField, rowIndex, updateMode, void)
  rendered = try(renderRowEditor(editor))
  if typeof(rendered) == "error" then gui.destroy(window.hwnd); return rendered end if
  gui.setEnabled(session.window.hwnd, false)
  if not gui.showTopLevel(window.hwnd) then gui.setEnabled(session.window.hwnd, true); gui.destroy(window.hwnd); return fail("runRowEditor", "row editor could not be shown") end if
  while gui.isOpen(window.hwnd) and gui.isOpen(session.window.hwnd)
    ignoredPump = gui.pumpMessages()
    event = gui.pollEvent()
    while typeof(event) == "struct"
      if event.hwnd == window.hwnd and (event.message == gui.WM_SIZE or event.message == gui.WM_DPICHANGED) then
        ignoredEditorLayout = try(layoutRowEditor(window))
      else if event.hwnd == window.hwnd and event.message == gui.WM_COMMAND then
        if event.controlId == ID_ROW_PREVIOUS then
          movedPrevious = try(moveRowEditor(editor, -1))
          if typeof(movedPrevious) == "error" then gui.setText(window.hintLabel, movedPrevious.message) end if
        else if event.controlId == ID_ROW_NEXT then
          movedNext = try(moveRowEditor(editor, 1))
          if typeof(movedNext) == "error" then gui.setText(window.hintLabel, movedNext.message) end if
        else if event.controlId == ID_ROW_SAVE then
          sqlText = try(rowEditorSql(editor))
          if typeof(sqlText) == "error" then gui.setText(window.hintLabel, sqlText.message) else editor.resultSql = sqlText; gui.destroy(window.hwnd) end if
        else if event.controlId == ID_ROW_CANCEL then
          gui.destroy(window.hwnd)
        end if
      else if event.hwnd == window.hwnd and event.message == gui.WM_NOTIFY and event.controlId == ID_ROW_VALUES and event.notification == NM_DBLCLK then
        selected = gui.listViewSelectedIndex(window.valuesGrid)
        if selected >= 0 and selected < len(editor.values) then
          storedSelection = try(storeRowEditorValue(editor))
          if typeof(storedSelection) != "error" then editor.fieldIndex = selected; ignoredSelectedRender = try(renderRowEditor(editor)) end if
        end if
      end if
      event = gui.pollEvent()
    end while
    gui.sleep(10)
  end while
  if gui.isOpen(window.hwnd) then gui.destroy(window.hwnd) end if
  if gui.isOpen(session.window.hwnd) then gui.setEnabled(session.window.hwnd, true); gui.focus(session.window.detailGrid) end if
  if editor.resultSql is void then return void end if
  return [editor.resultSql, editor.values]
end function

/// Returns the selected Data-grid row index or a descriptive validation error.
/// @param session session value consumed by this operation.
function selectedDataRow(session)
  selected = gui.listViewSelectedIndex(session.window.detailGrid)
  if selected < 0 or selected >= len(session.state.tableDetails.contentsGrid.rows) then return fail("selectedDataRow", "select a row in the Data grid first") end if
  return selected
end function

/// Resolves a SELECT-grid column to its DESCRIBE editor field.
/// @param details details value consumed by this operation.
/// @param dataColumn dataColumn value consumed by this operation.
function editorFieldForDataColumn(details, dataColumn)
  if typeof(details) != "struct" or typeof(dataColumn) != "int" or dataColumn < 0 or dataColumn >= len(details.contentsGrid.columns) then return 0 end if
  name = details.contentsGrid.columns[dataColumn]
  for index = 0 to len(details.columnsGrid.rows) - 1
    row = details.columnsGrid.rows[index]
    if len(row) >= 2 and row[1] == name then return index end if
  end for
  return 0
end function

/// Returns whether one preview row already has an unapplied update or delete.
/// @param session session value consumed by this operation.
/// @param rowIndex Zero-based index of row.
function rowHasPendingChange(session, rowIndex)
  for each change in session.pendingChanges
    if change.rowIndex == rowIndex then return true end if
  end for
  return false
end function

/// Opens an insert/update draft and stages its exact SQL after explicit preview.
/// @param session session value consumed by this operation.
/// @param rowIndex Zero-based index of row.
/// @param duplicate duplicate value consumed by this operation.
/// @param updateMode updateMode value consumed by this operation.
/// @param initialField initialField value consumed by this operation.
function editDataRow(session, rowIndex, duplicate, updateMode, initialField)
  if updateMode and rowHasPendingChange(session, rowIndex) then session.state.statusText = "This row already has a pending change; apply or revert it first"; return false end if
  editResult = try(runRowEditor(session, rowIndex, duplicate, updateMode, initialField))
  if typeof(editResult) == "error" then session.state.statusText = editResult.message; return editResult end if
  if editResult is void then session.state.statusText = "Row edit cancelled"; return false end if
  sqlText = editResult[0]
  kind = "INSERT"
  pendingRow = -1
  if updateMode then kind = "UPDATE"; pendingRow = rowIndex end if
  if not gui.confirmWarning(session.window.hwnd, "Preview " + kind + " change", "Stage this generated SQL?\r\n\r\n" + sqlText + "\r\n\r\nUse Apply changes to commit it or Revert to discard it.") then session.state.statusText = "Row change was not staged"; return false end if
  change = try(fullclient.pendingDataChange(kind, sqlText, pendingRow, editResult[1]))
  if typeof(change) == "error" then session.state.statusText = change.message; return change end if
  session.pendingChanges = session.pendingChanges + [change]
  session.state.statusText = kind + " staged; " + len(session.pendingChanges) + " pending change(s)"
  render(session)
  return true
end function

/// Saves the RichEdit contents into the selected worksheet model.
/// @param session session value consumed by this operation.
function storeActiveWorksheet(session)
  if session is not AdminSession or session.selectedWorksheetIndex < 0 or session.selectedWorksheetIndex >= len(session.worksheets) then return fail("storeActiveWorksheet", "active worksheet is invalid") end if
  text = try(gui.getText(session.window.queryEdit))
  if typeof(text) == "error" then return text end if
  session.worksheets[session.selectedWorksheetIndex].sqlText = text
  return true
end function

/// Loads one worksheet into the shared colorized RichEdit control.
/// @param session session value consumed by this operation.
/// @param index Zero-based index of the affected item.
function activateWorksheet(session, index)
  if session is not AdminSession or typeof(index) != "int" or index < 0 or index >= len(session.worksheets) then return fail("activateWorksheet", "worksheet index is invalid") end if
  stored = try(storeActiveWorksheet(session))
  if typeof(stored) == "error" then return stored end if
  session.selectedWorksheetIndex = index
  gui.tabSelect(session.window.worksheetTabs, index)
  gui.setText(session.window.queryEdit, session.worksheets[index].sqlText)
  highlighted = try(highlightSqlEditor(session.window))
  if typeof(highlighted) == "error" then return highlighted end if
  gui.focus(session.window.queryEdit)
  return true
end function

/// Adds and activates a separately retained SQL worksheet.
/// @param session session value consumed by this operation.
/// @param initialSql initialSql value consumed by this operation.
function addWorksheet(session, initialSql)
  if typeof(initialSql) != "string" then return fail("addWorksheet", "initial SQL must be a string") end if
  stored = try(storeActiveWorksheet(session))
  if typeof(stored) == "error" then return stored end if
  worksheet = try(fullclient.newWorksheet(session.nextWorksheetNumber, initialSql))
  if typeof(worksheet) == "error" then return worksheet end if
  session.nextWorksheetNumber = session.nextWorksheetNumber + 1
  session.worksheets = session.worksheets + [worksheet]
  session.selectedWorksheetIndex = len(session.worksheets) - 1
  rendered = try(fillClosableTabs(session.window.worksheetTabs, fullclient.worksheetLines(session.worksheets), session.selectedWorksheetIndex))
  if typeof(rendered) == "error" then return rendered end if
  gui.setText(session.window.queryEdit, initialSql)
  selectWorkspace(session, 0)
  highlighted = try(highlightSqlEditor(session.window))
  if typeof(highlighted) == "error" then return highlighted end if
  session.state.statusText = "Opened " + worksheet.title
  setBusyControls(session)
  gui.focus(session.window.queryEdit)
  return true
end function

/// Closes any worksheet tab and selects the nearest surviving editor page.
/// @param session session value consumed by this operation.
/// @param closingIndex Zero-based index of closing.
function closeWorksheetAt(session, closingIndex)
  if session is not AdminSession or typeof(closingIndex) != "int" or closingIndex < 0 or closingIndex >= len(session.worksheets) then return fail("closeWorksheetAt", "worksheet index is invalid") end if
  stored = try(storeActiveWorksheet(session))
  if typeof(stored) == "error" then return stored end if
  active = session.worksheets[closingIndex]
  if len(active.sqlText) > 0 and not gui.confirmWarning(session.window.hwnd, "Close SQL worksheet", "Close " + active.title + " and discard its SQL text?") then session.state.statusText = "SQL worksheet close cancelled"; return false end if
  if len(session.worksheets) == 1 then
    replacement = try(fullclient.newWorksheet(session.nextWorksheetNumber, ""))
    if typeof(replacement) == "error" then return replacement end if
    session.nextWorksheetNumber = session.nextWorksheetNumber + 1
    session.worksheets = [replacement]
    session.selectedWorksheetIndex = 0
  else
    retained = []
    for index = 0 to len(session.worksheets) - 1
      if index != closingIndex then retained = retained + [session.worksheets[index]] end if
    end for
    selected = session.selectedWorksheetIndex
    if closingIndex < selected then selected = selected - 1
    else if closingIndex == selected and selected >= len(retained) then selected = len(retained) - 1
    end if
    session.worksheets = retained
    session.selectedWorksheetIndex = selected
  end if
  rendered = try(fillClosableTabs(session.window.worksheetTabs, fullclient.worksheetLines(session.worksheets), session.selectedWorksheetIndex))
  if typeof(rendered) == "error" then return rendered end if
  gui.setText(session.window.queryEdit, session.worksheets[session.selectedWorksheetIndex].sqlText)
  session.state.statusText = "SQL worksheet closed"
  render(session)
  return true
end function

/// Closes the worksheet currently loaded in the shared RichEdit control.
/// @param session session value consumed by this operation.
function closeWorksheet(session)
  return closeWorksheetAt(session, session.selectedWorksheetIndex)
end function

/// Closes one structured result page selected through its tab-header glyph.
/// @param session session value consumed by this operation.
/// @param closingIndex Zero-based index of closing.
function closeResultAt(session, closingIndex)
  closed = try(fullclient.closeResultTab(session.state, closingIndex))
  if typeof(closed) == "error" then return closed end if
  return render(session)
end function

/// Writes a complete UTF-8 text artifact and flushes it before returning success.
/// @param path Path of the file or directory used by the operation.
/// @param text Text consumed by the operation.
function writeTextFile(path, text)
  if typeof(path) != "string" or len(path) == 0 or typeof(text) != "string" then return fail("writeTextFile", "path and text are required") end if
  handle = try(file_api.create(path))
  if typeof(handle) == "error" then return handle end if
  payload = bytes(text)
  written = try(file_api.writeAt(handle, 0, payload, 0, len(payload)))
  if typeof(written) == "error" then ignoredClose = try(file_api.close(handle)); return written end if
  flushed = try(file_api.flush(handle))
  closed = try(file_api.close(handle))
  if typeof(flushed) == "error" then return flushed end if
  return closed
end function

/// Exports the active result grid through the native Save As dialog.
/// @param session session value consumed by this operation.
function exportActiveResult(session)
  tab = fullclient.activeResultTab(session.state)
  if tab is void then session.state.statusText = "There is no active result to export"; return false end if
  columns = tab.columns
  rows = tab.rows
  if len(columns) == 0 then columns = ["message"]; rows = [[tab.resultText]] end if
  csv = try(fullclient.gridCsv(fullclient.DetailGrid(columns, rows)))
  if typeof(csv) == "error" then session.state.statusText = csv.message; return csv end if
  path = try(gui.chooseCsvPath(session.window.hwnd, "minisql-result.csv"))
  if typeof(path) == "error" then session.state.statusText = path.message; return path end if
  if len(path) == 0 then session.state.statusText = "CSV export cancelled"; return false end if
  saved = try(writeTextFile(path, csv))
  if typeof(saved) == "error" then session.state.statusText = "CSV export failed: " + saved.message; return saved end if
  session.state.statusText = "Exported " + len(rows) + " row(s) to " + path
  return true
end function

/// Copies all selected preview rows as escaped, header-bearing TSV.
/// @param session session value consumed by this operation.
function copySelectedDataRows(session)
  selected = gui.listViewSelectedIndices(session.window.detailGrid)
  if len(selected) == 0 then session.state.statusText = "Select one or more Data rows first"; return false end if
  marked = fullclient.dataGridWithChanges(session.state.tableDetails, session.pendingChanges)
  clipboardRows = []
  for each markedRow in marked.rows
    row = []
    if len(markedRow) > 1 then
      for columnIndex = 1 to len(markedRow) - 1
        row = row + [markedRow[columnIndex]]
      end for
    end if
    clipboardRows = clipboardRows + [row]
  end for
  grid = fullclient.DetailGrid(session.state.tableDetails.contentsGrid.columns, clipboardRows)
  text = try(fullclient.gridClipboardText(grid, selected, true))
  if typeof(text) == "error" then session.state.statusText = text.message; return text end if
  copied = try(gui.clipboardSetText(session.window.hwnd, text))
  if typeof(copied) == "error" then session.state.statusText = copied.message; return copied end if
  session.state.statusText = "Copied " + len(selected) + " row(s) to the clipboard"
  return true
end function

/// Tests whether a clipboard row is the exact Data-grid header.
/// @param details details value consumed by this operation.
/// @param row row value consumed by this operation.
function clipboardHeader(details, row)
  if typeof(row) != "array" or len(row) != len(details.contentsGrid.columns) then return false end if
  for index = 0 to len(row) - 1
    if row[index] != details.contentsGrid.columns[index] then return false end if
  end for
  return true
end function

/// Converts one SELECT-ordered clipboard row into DESCRIBE-ordered editor values.
/// @param details details value consumed by this operation.
/// @param row row value consumed by this operation.
function clipboardEditorValues(details, row)
  if typeof(row) != "array" or len(row) != len(details.contentsGrid.columns) then return fail("clipboardEditorValues", "clipboard column count does not match the table") end if
  values = try(fullclient.dataEditorValues(details, -1, false))
  if typeof(values) == "error" then return values end if
  for metadataIndex = 0 to len(details.columnsGrid.rows) - 1
    metadata = details.columnsGrid.rows[metadataIndex]
    dataIndex = fullclient.dataColumnIndex(details, metadata[1])
    if dataIndex >= 0 then
      value = row[dataIndex]
      if value == "NULL" and metadata[3] == "TRUE" then value = "<NULL>" end if
      values[metadataIndex] = value
    end if
  end for
  return values
end function

/// Stages clipboard TSV rows as validated INSERT statements.
/// @param session session value consumed by this operation.
function pasteDataRows(session)
  text = try(gui.clipboardText(session.window.hwnd))
  if typeof(text) == "error" then session.state.statusText = text.message; return text end if
  rows = try(fullclient.parseClipboardRows(text))
  if typeof(rows) == "error" then session.state.statusText = rows.message; return rows end if
  start = 0
  if clipboardHeader(session.state.tableDetails, rows[0]) then start = 1 end if
  if start >= len(rows) then session.state.statusText = "Clipboard contains only a header"; return false end if
  if len(rows) - start > 1000 then session.state.statusText = "Clipboard paste is limited to 1000 rows per operation"; return false end if
  additions = []
  for rowIndex = start to len(rows) - 1
    values = try(clipboardEditorValues(session.state.tableDetails, rows[rowIndex]))
    if typeof(values) == "error" then session.state.statusText = values.message; return values end if
    sqlText = try(fullclient.insertDataSql(session.state.tableDetails, values))
    if typeof(sqlText) == "error" then session.state.statusText = "Clipboard row " + (rowIndex + 1) + ": " + sqlText.message; return sqlText end if
    change = try(fullclient.pendingDataChange("INSERT", sqlText, -1, values))
    if typeof(change) == "error" then return change end if
    additions = additions + [change]
  end for
  if not gui.confirmWarning(session.window.hwnd, "Paste table rows", "Stage " + len(additions) + " clipboard row(s) as INSERT changes?\r\n\r\nReview them with SQL preview before applying.") then session.state.statusText = "Clipboard paste cancelled"; return false end if
  session.pendingChanges = session.pendingChanges + additions
  session.state.statusText = "Staged " + len(additions) + " clipboard INSERT(s)"
  render(session)
  return true
end function

/// Stages safe key-constrained DELETE statements for all selected rows.
/// @param session session value consumed by this operation.
function stageSelectedDeletes(session)
  selected = gui.listViewSelectedIndices(session.window.detailGrid)
  if len(selected) == 0 then session.state.statusText = "Select one or more Data rows first"; return false end if
  additions = []
  for each rowIndex in selected
    if rowIndex < 0 or rowIndex >= len(session.state.tableDetails.contentsGrid.rows) then return fail("stageSelectedDeletes", "pending insert rows cannot be deleted before Apply") end if
    if rowHasPendingChange(session, rowIndex) then session.state.statusText = "A selected row already has a pending change"; return false end if
    sqlText = try(fullclient.deleteDataSql(session.state.tableDetails, session.state.tableDetails.contentsGrid.rows[rowIndex]))
    if typeof(sqlText) == "error" then session.state.statusText = sqlText.message; return sqlText end if
    change = try(fullclient.pendingDataChange("DELETE", sqlText, rowIndex, []))
    if typeof(change) == "error" then return change end if
    additions = additions + [change]
  end for
  preview = try(fullclient.pendingDataSql(additions))
  if not gui.confirmWarning(session.window.hwnd, "Preview DELETE changes", "Stage " + len(additions) + " key-constrained DELETE statement(s)?\r\n\r\n" + preview) then session.state.statusText = "Delete cancelled"; return false end if
  session.pendingChanges = session.pendingChanges + additions
  session.state.statusText = "Staged " + len(additions) + " DELETE change(s)"
  render(session)
  return true
end function

/// Applies a new filter/page/sort request only when pending row indices remain stable.
/// @param session session value consumed by this operation.
/// @param options Options controlling the operation.
function startDataPage(session, options)
  if len(session.pendingChanges) > 0 then session.state.statusText = "Apply or revert pending changes before filtering, sorting, or changing page"; return false end if
  if typeof(options) != "struct" then return fail("startDataPage", "options must be DataBrowseOptions") end if
  session.dataOptions = options
  return startDescribe(session, session.state.selectedTable)
end function

/// Persists one validated physical window rectangle as a tiny JSON document.
/// @param path Path of the file or directory used by the operation.
/// @param rectangle rectangle value consumed by this operation.
function saveWindowLayout(path, rectangle)
  if typeof(path) != "string" or len(path) == 0 or typeof(rectangle) != "array" or len(rectangle) != 4 then return false end if
  document = "{\"schemaVersion\":1,\"left\":" + rectangle[0] + ",\"top\":" + rectangle[1] + ",\"width\":" + rectangle[2] + ",\"height\":" + rectangle[3] + "}\n"
  return connection_profiles.write(path, document)
end function

/// Restores a previously persisted workbench rectangle when every field is valid.
/// @param path Path of the file or directory used by the operation.
/// @param hwnd hwnd value consumed by this operation.
function restoreWindowLayout(path, hwnd)
  if typeof(path) != "string" or len(path) == 0 or not file_api.fileExists(path) then return false end if
  text = try(file_api.readAllText(path, 4096))
  if typeof(text) == "error" then return false end if
  document = try(json.parse(text))
  if typeof(document) == "error" then return false end if
  version = try(json.intMember(document, "schemaVersion"))
  left = try(json.intMember(document, "left"))
  top = try(json.intMember(document, "top"))
  width = try(json.intMember(document, "width"))
  height = try(json.intMember(document, "height"))
  if typeof(version) != "int" or version != 1 or typeof(left) != "int" or typeof(top) != "int" or typeof(width) != "int" or typeof(height) != "int" then return false end if
  return gui.setTopLevelRect(hwnd, [left, top, width, height])
end function

/// Wraps an existing connected state in a native workbench window.
/// @param state Mutable state inspected or updated by the operation.
/// @param visible visible value consumed by this operation.
function openState(state, visible)
  window = try(createWindow(visible))
  if typeof(window) == "error" then return window end if
  session = AdminSession(window, state, void, false, false, false, false, 0, 0, [fullclient.newWorksheet(1, state.queryText)], 0, 2, [], fullclient.defaultDataBrowseOptions(), "", "", [])
  if visible then
    profilePath = try(connection_profiles.defaultPath())
    if typeof(profilePath) == "string" then
      session.layoutPath = profilePath + ".layout.json"
      ignoredRestore = try(restoreWindowLayout(session.layoutPath, window.hwnd))
      currentRect = try(gui.topLevelRect(window.hwnd))
      if typeof(currentRect) == "array" then session.windowRect = currentRect end if
    end if
  end if
  rendered = try(render(session))
  if typeof(rendered) == "error" then gui.destroy(window.hwnd); return rendered end if
  return session
end function

/// Opens a profile directly for command-line and network smoke workflows.
/// @param profile profile value consumed by this operation.
/// @param passwordBytes passwordBytes value consumed by this operation.
/// @param visible visible value consumed by this operation.
function openProfile(profile, passwordBytes, visible)
  state = try(fullclient.openProfile(profile, passwordBytes))
  if typeof(state) == "error" then return state end if
  session = try(openState(state, visible))
  if typeof(session) == "error" then ignoredClose = try(fullclient.close(state)); return session end if
  return session
end function

/// Executes one protocol operation and any dependent refresh on the same worker.
/// @param task task value consumed by this operation.
function queryWorker(task)
  if task.operation == QUERY_REFRESH then
    result = try(fullclient.refresh(task.state))
    return QueryCompletion(task.operation, result, void, task.state.statusText)
  end if
  if task.operation == QUERY_DESCRIBE then
    result = try(fullclient.describeTableView(task.state, task.tableName, task.browseOptions))
    return QueryCompletion(task.operation, result, void, task.state.statusText)
  end if
  if task.operation == QUERY_DATA_MUTATION then
    result = try(fullclient.executeAtomicSql(task.state, task.sqlText))
    statusText = task.state.statusText
    refreshed = void
    if typeof(result) != "error" and result.success then refreshed = try(fullclient.describeTableView(task.state, task.tableName, task.browseOptions)) end if
    return QueryCompletion(task.operation, result, refreshed, statusText)
  end if
  if task.operation == QUERY_SCHEMA_MUTATION then
    result = try(fullclient.executeSql(task.state, task.sqlText))
    statusText = task.state.statusText
    refreshed = void
    if typeof(result) != "error" and result.success then refreshed = try(fullclient.refresh(task.state)) end if
    return QueryCompletion(task.operation, result, refreshed, statusText)
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

/// Starts one responsive background protocol operation.
/// @param session session value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param sqlText sqlText value consumed by this operation.
/// @param tableName tableName value consumed by this operation.
function startOperation(session, operation, sqlText, tableName)
  if session.aborted then return fail("startQuery", "the cancelled session cannot be reused") end if
  if session.busy then return fail("startQuery", "a query is already running") end if
  worker = Thread(queryWorker, "minisql-workbench-query")
  if not worker.Start(QueryTask(session.state, operation, sqlText, tableName, session.dataOptions)) then return fail("startQuery", "native SQL worker could not be started") end if
  session.worker = worker
  session.busy = true
  session.sensitiveSql = (operation == QUERY_EXECUTE or operation == QUERY_EXPLAIN) and fullclient.isSensitiveSql(sqlText)
  if operation == QUERY_REFRESH then session.state.statusText = "Refreshing the object tree …"
  else if operation == QUERY_DESCRIBE then session.state.statusText = "Loading metadata for table " + tableName + " …"
  else if operation == QUERY_DATA_MUTATION then session.state.statusText = "Saving table data on a native worker thread …"
  else if operation == QUERY_SCHEMA_MUTATION then session.state.statusText = "Applying schema DDL on a native worker thread …"
  else session.state.statusText = "Executing SQL on a native worker thread …"
  end if
  setBusyControls(session)
  gui.setText(session.window.statusLabel, session.state.statusText)
  return true
end function

/// Starts normal or EXPLAIN SQL while preserving the established public API.
/// @param session session value consumed by this operation.
/// @param sqlText sqlText value consumed by this operation.
/// @param explain explain value consumed by this operation.
function startQuery(session, sqlText, explain)
  operation = QUERY_EXECUTE
  if explain then operation = QUERY_EXPLAIN end if
  if not explain and sqlText == "BEGIN;" then operation = QUERY_BEGIN end if
  if not explain and sqlText == "COMMIT;" then operation = QUERY_COMMIT end if
  if not explain and sqlText == "ROLLBACK;" then operation = QUERY_ROLLBACK end if
  return startOperation(session, operation, sqlText, "")
end function

/// Starts a background object-tree refresh.
/// @param session session value consumed by this operation.
function startRefresh(session)
  return startOperation(session, QUERY_REFRESH, "", "")
end function

/// Starts background metadata loading for one validated tree selection.
/// @param session session value consumed by this operation.
/// @param tableName tableName value consumed by this operation.
function startDescribe(session, tableName)
  return startOperation(session, QUERY_DESCRIBE, "", tableName)
end function

/// Starts a generated INSERT, UPDATE, or DELETE and reloads the edited table preview.
/// @param session session value consumed by this operation.
/// @param sqlText sqlText value consumed by this operation.
function startDataMutation(session, sqlText)
  if session is not AdminSession or typeof(sqlText) != "string" or len(sqlText) == 0 or len(session.state.selectedTable) == 0 then return fail("startDataMutation", "a selected table and generated SQL are required") end if
  return startOperation(session, QUERY_DATA_MUTATION, sqlText, session.state.selectedTable)
end function

/// Starts one generated schema mutation and reloads the object tree on success.
/// @param session session value consumed by this operation.
/// @param sqlText sqlText value consumed by this operation.
function startSchemaMutation(session, sqlText)
  if session is not AdminSession or typeof(sqlText) != "string" or len(sqlText) == 0 then return fail("startSchemaMutation", "generated DDL is required") end if
  return startOperation(session, QUERY_SCHEMA_MUTATION, sqlText, "")
end function

/// Publishes a completed worker result without performing network I/O on the UI thread.
/// @param session session value consumed by this operation.
function pollQuery(session)
  if not session.busy or session.worker is void then return false end if
  if not session.worker.Join(0) then return false end if
  completion = try(session.worker.Result())
  ignoredClose = session.worker.Close()
  session.worker = void
  session.busy = false
  if session.sensitiveSql then gui.setText(session.window.queryEdit, ""); session.worksheets[session.selectedWorksheetIndex].sqlText = "" end if
  session.sensitiveSql = false
  if typeof(completion) == "error" then
    session.state.statusText = "Operation failed: " + completion.message
  else if typeof(completion.result) == "error" then
    session.state.statusText = "Operation failed: " + completion.result.message
  else if typeof(completion.refreshResult) == "error" then
    session.state.statusText = completion.statusText + "; object refresh failed: " + completion.refreshResult.message
  else if completion.operation == QUERY_DATA_MUTATION and completion.refreshResult is not void then
    session.state.statusText = completion.statusText + "   •   Data grid refreshed"
  else if completion.refreshResult is not void then
    session.state.statusText = completion.statusText + "   •   " + len(session.state.tables) + " table(s)"
  else
    session.state.statusText = completion.statusText
  end if
  if typeof(completion) != "error" and completion.operation == QUERY_DATA_MUTATION and typeof(completion.result) != "error" and completion.result.success then session.pendingChanges = [] end if
  if typeof(completion) != "error" and (completion.operation == QUERY_DESCRIBE or completion.operation == QUERY_DATA_MUTATION) and typeof(completion.result) != "error" then session.workspacePage = 1 end if
  render(session)
  return true
end function

/// Stops the native worker before disconnecting the affected session.
/// @param session session value consumed by this operation.
function stopQuery(session)
  if not session.busy or session.worker is void then return false end if
  stopped = session.worker.Stop()
  if not session.worker.Join(2000) then session.state.statusText = "The worker did not terminate; the session remains locked for safety."; gui.setText(session.window.statusLabel, session.state.statusText); return false end if
  ignoredClose = session.worker.Close()
  session.worker = void
  session.busy = false
  session.aborted = true
  if session.sensitiveSql then gui.setText(session.window.queryEdit, ""); session.worksheets[session.selectedWorksheetIndex].sqlText = "" end if
  session.sensitiveSql = false
  session.state.statusText = "Execution stopped. Disconnecting this session to preserve protocol framing."
  gui.setText(session.window.statusLabel, session.state.statusText)
  gui.destroy(session.window.hwnd)
  return stopped
end function

/// Opens table details for the current object-tree selection.
/// @param session session value consumed by this operation.
function openSelectedObject(session)
  selected = try(gui.treeSelectedText(session.window.objectTree))
  if typeof(selected) != "string" or not fullclient.containsText(session.state.tables, selected) then session.state.statusText = "Select a table in the object tree"; return false end if
  if selected != session.state.tableDetails.tableName then session.pendingChanges = []; session.dataOptions = fullclient.defaultDataBrowseOptions(); gui.setText(session.window.dataFilterEdit, "") end if
  selectWorkspace(session, 1)
  return startDescribe(session, selected)
end function

/// Inserts a table preview query for the selected object.
/// @param session session value consumed by this operation.
function querySelectedObject(session)
  selected = try(gui.treeSelectedText(session.window.objectTree))
  if typeof(selected) != "string" or not fullclient.containsText(session.state.tables, selected) then session.state.statusText = "Select a table in the object tree"; return false end if
  sqlText = try(fullclient.queryForTable(session.state, selected))
  if typeof(sqlText) == "error" then return false end if
  gui.setText(session.window.queryEdit, sqlText)
  selectWorkspace(session, 0)
  gui.focus(session.window.queryEdit)
  return true
end function

/// Inserts a selected bookmark into the SQL worksheet.
/// @param session session value consumed by this operation.
function insertSelectedBookmark(session)
  label = try(gui.listSelectedText(session.window.bookmarkList))
  sqlText = fullclient.bookmarkSqlForSelection(session.state, label)
  if len(sqlText) == 0 then session.state.statusText = "This bookmark requires a selected table"; gui.setText(session.window.statusLabel, session.state.statusText); return false end if
  gui.setText(session.window.queryEdit, sqlText)
  selectWorkspace(session, 0)
  gui.focus(session.window.queryEdit)
  return true
end function

/// Reopens a redacted history item in the SQL worksheet.
/// @param session session value consumed by this operation.
function insertSelectedHistory(session)
  sqlText = try(gui.listSelectedText(session.window.historyList))
  if typeof(sqlText) != "string" or len(sqlText) == 0 or fullclient.textContains(sqlText, "redacted") then return false end if
  gui.setText(session.window.queryEdit, sqlText)
  selectWorkspace(session, 0)
  gui.focus(session.window.queryEdit)
  return true
end function

/// Resolves the requested editor scope and starts its background execution.
/// @param session session value consumed by this operation.
/// @param wholeScript wholeScript value consumed by this operation.
/// @param explain explain value consumed by this operation.
function startEditorCommand(session, wholeScript, explain)
  stored = try(storeActiveWorksheet(session))
  if typeof(stored) == "error" then session.state.statusText = stored.message; return stored end if
  sqlText = try(editorSqlForCommand(session.window, wholeScript))
  if typeof(sqlText) == "error" then session.state.statusText = "Cannot execute SQL: " + sqlText.message; return sqlText end if
  started = try(startQuery(session, sqlText, explain))
  if typeof(started) == "error" then session.state.statusText = started.message end if
  return started
end function

/// Handles a native menu or toolbar command.
/// @param session session value consumed by this operation.
/// @param command command value consumed by this operation.
function handleCommand(session, command)
  if session.busy and command != ID_STOP and command != gui.MENU_SQL_CANCEL and command != ID_CLOSE and command != gui.MENU_FILE_CLOSE and command != gui.MENU_FILE_EXIT then return true end if
  if command == ID_CLOSE or command == gui.MENU_FILE_CLOSE or command == gui.MENU_FILE_EXIT then
    if len(session.pendingChanges) > 0 and not gui.confirmWarning(session.window.hwnd, "Discard pending changes", "Disconnect and discard " + len(session.pendingChanges) + " unapplied table change(s)?") then return true end if
    if session.busy then stopQuery(session) else gui.destroy(session.window.hwnd) end if
  else if command == ID_REFRESH or command == gui.MENU_SESSION_REFRESH then
    started = try(startRefresh(session))
    if typeof(started) == "error" then session.state.statusText = "Refresh failed: " + started.message end if
  else if command == ID_OPEN_OBJECT or command == gui.MENU_OBJECT_DESCRIBE then
    openSelectedObject(session)
  else if command == ID_SCHEMA_DESIGNER or command == gui.MENU_OBJECT_SCHEMA then
    ignoredSchema = try(openSchemaDesigner(session))
  else if command == gui.MENU_OBJECT_QUERY then
    querySelectedObject(session)
  else if command == ID_NEW_SQL or command == gui.MENU_FILE_NEW then
    ignoredNewWorksheet = try(addWorksheet(session, ""))
  else if command == ID_CLOSE_SQL or command == gui.MENU_FILE_CLOSE_WORKSHEET then
    ignoredClosedWorksheet = try(closeWorksheet(session))
  else if command == ID_EXPORT_CSV or command == gui.MENU_FILE_EXPORT then
    ignoredExport = try(exportActiveResult(session))
  else if command == ID_EXECUTE or command == gui.MENU_SQL_EXECUTE then
    ignoredCurrent = try(startEditorCommand(session, false, false))
  else if command == ID_EXECUTE_SCRIPT or command == gui.MENU_SQL_EXECUTE_SCRIPT then
    ignoredScript = try(startEditorCommand(session, true, false))
  else if command == ID_EXPLAIN or command == gui.MENU_SQL_EXPLAIN then
    ignoredExplain = try(startEditorCommand(session, false, true))
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
  else if command == ID_DATA_ADD or command == gui.MENU_DATA_ADD then
    ignoredAdd = try(editDataRow(session, -1, false, false, 0))
  else if command == ID_DATA_COPY then
    selectedCopy = try(selectedDataRow(session))
    if typeof(selectedCopy) == "error" then session.state.statusText = selectedCopy.message else ignoredCopy = try(editDataRow(session, selectedCopy, true, false, 0)) end if
  else if command == ID_DATA_EDIT or command == gui.MENU_DATA_EDIT then
    selectedEdit = try(selectedDataRow(session))
    if typeof(selectedEdit) == "error" then session.state.statusText = selectedEdit.message else ignoredEdit = try(editDataRow(session, selectedEdit, false, true, 0)) end if
  else if command == ID_DATA_DELETE or command == gui.MENU_DATA_DELETE then
    ignoredDelete = try(stageSelectedDeletes(session))
  else if command == ID_DATA_REFRESH then
    if len(session.pendingChanges) > 0 then session.state.statusText = "Apply or revert pending changes before refreshing data"
    else if len(session.state.selectedTable) > 0 then ignoredDataRefresh = try(startDescribe(session, session.state.selectedTable))
    end if
  else if command == ID_DATA_COPY_CLIPBOARD or command == gui.MENU_DATA_COPY then
    ignoredCopyRows = try(copySelectedDataRows(session))
  else if command == ID_DATA_PASTE or command == gui.MENU_DATA_PASTE then
    ignoredPasteRows = try(pasteDataRows(session))
  else if command == ID_DATA_FILTER_APPLY then
    filterText = try(gui.getText(session.window.dataFilterEdit))
    options = try(fullclient.createDataBrowseOptions(filterText, session.dataOptions.sortColumn, session.dataOptions.ascending, 0, session.dataOptions.pageSize))
    if typeof(options) == "error" then session.state.statusText = options.message else ignoredFilter = try(startDataPage(session, options)) end if
  else if command == ID_DATA_PREVIOUS_PAGE then
    page = session.dataOptions.page - 1
    if page < 0 then page = 0 end if
    options = try(fullclient.createDataBrowseOptions(session.dataOptions.filterText, session.dataOptions.sortColumn, session.dataOptions.ascending, page, session.dataOptions.pageSize))
    if typeof(options) != "error" then ignoredPrevious = try(startDataPage(session, options)) end if
  else if command == ID_DATA_NEXT_PAGE then
    options = try(fullclient.createDataBrowseOptions(session.dataOptions.filterText, session.dataOptions.sortColumn, session.dataOptions.ascending, session.dataOptions.page + 1, session.dataOptions.pageSize))
    if typeof(options) != "error" then ignoredNext = try(startDataPage(session, options)) end if
  else if command == ID_DATA_APPLY_CHANGES or command == gui.MENU_DATA_APPLY then
    pendingSql = try(fullclient.pendingDataSql(session.pendingChanges))
    if typeof(pendingSql) == "error" or len(session.pendingChanges) == 0 then session.state.statusText = "There are no valid pending changes"
    else if gui.confirmWarning(session.window.hwnd, "Apply table changes", "Execute " + len(session.pendingChanges) + " pending change(s)?\r\n\r\n" + pendingSql) then ignoredApply = try(startDataMutation(session, pendingSql))
    else session.state.statusText = "Apply changes cancelled"
    end if
  else if command == ID_DATA_REVERT_CHANGES or command == gui.MENU_DATA_REVERT then
    if len(session.pendingChanges) > 0 and gui.confirmWarning(session.window.hwnd, "Revert table changes", "Discard all " + len(session.pendingChanges) + " unapplied change(s)?") then session.pendingChanges = []; session.state.statusText = "Pending changes reverted"; render(session) end if
  else if command == ID_DATA_PREVIEW_CHANGES or command == gui.MENU_DATA_PREVIEW then
    pendingSql = try(fullclient.pendingDataSql(session.pendingChanges))
    if typeof(pendingSql) == "string" and len(pendingSql) > 0 then gui.showInfo(session.window.hwnd, "Pending MiniSQL changes", pendingSql) else session.state.statusText = "There are no pending changes" end if
  else if command == gui.MENU_HELP_ABOUT then
    gui.showInfo(session.window.hwnd, "About MiniSQL Workbench", "MiniSQL Workbench\r\n\r\nA native Windows SQL client inspired by the SQuirreL SQL workflow and built exclusively for MiniSQL.")
  end if
  gui.setText(session.window.statusLabel, session.state.statusText)
  return true
end function

/// Opens the context menu appropriate for the control under the pointer.
/// @param session Active Workbench session that owns the native controls.
/// @param event Native context-menu event to dispatch.
function handleContextMenuEvent(session, event)
  if event.controlId == ID_DETAIL_GRID and gui.tabSelectedIndex(session.window.detailTabs) == 3 then
    ignoredDataMenu = gui.showContextMenu(session.window.hwnd, ["Add row", "Edit selected row", "Delete selected row(s)", "Copy selected row(s)", "Paste rows", "Apply changes", "Revert changes", "SQL preview"], [gui.MENU_DATA_ADD, gui.MENU_DATA_EDIT, gui.MENU_DATA_DELETE, gui.MENU_DATA_COPY, gui.MENU_DATA_PASTE, gui.MENU_DATA_APPLY, gui.MENU_DATA_REVERT, gui.MENU_DATA_PREVIEW])
  else if event.controlId == ID_OBJECT_TREE then
    ignoredObjectMenu = gui.showContextMenu(session.window.hwnd, ["Open table details", "Select first 100 rows", "Open schema designer"], [gui.MENU_OBJECT_DESCRIBE, gui.MENU_OBJECT_QUERY, gui.MENU_OBJECT_SCHEMA])
  else if event.controlId == ID_QUERY_EDIT then
    ignoredSqlMenu = gui.showContextMenu(session.window.hwnd, ["Execute current / selection", "Execute script", "Explain", "New SQL worksheet", "Close SQL worksheet"], [gui.MENU_SQL_EXECUTE, gui.MENU_SQL_EXECUTE_SCRIPT, gui.MENU_SQL_EXPLAIN, gui.MENU_FILE_NEW, gui.MENU_FILE_CLOSE_WORKSHEET])
  else if event.controlId == ID_RESULT_GRID then
    ignoredResultMenu = gui.showContextMenu(session.window.hwnd, ["Export active result as CSV", "Clear results"], [gui.MENU_FILE_EXPORT, gui.MENU_SQL_CLEAR])
  end if
  return true
end function

/// Handles tab, list-view, and object-tree WM_NOTIFY events.
/// @param session Active Workbench session that receives the notification.
/// @param event Native notification event and control identifiers.
function handleNotifyEvent(session, event)
  if event.controlId == ID_WORKSHEET_TABS and event.notification == NM_CLICK then
    closingWorksheet = gui.tabCloseHitIndexAt(session.window.worksheetTabs, event.source & 65535, (event.source >> 16) & 65535)
    if closingWorksheet >= 0 then ignoredWorksheetClose = try(closeWorksheetAt(session, closingWorksheet)) end if
  else if event.controlId == ID_RESULT_TABS and event.notification == NM_CLICK then
    closingResult = gui.tabCloseHitIndexAt(session.window.resultTabs, event.source & 65535, (event.source >> 16) & 65535)
    if closingResult >= 0 then ignoredResultClose = try(closeResultAt(session, closingResult)) end if
  else if event.controlId == ID_SIDEBAR_TABS and event.notification == TCN_SELCHANGE then
    applyVisibility(session.window)
  else if event.controlId == ID_WORKSPACE_TABS and event.notification == TCN_SELCHANGE then
    ignoredWorkspaceNotify = try(synchronizeWorkspace(session))
  else if event.controlId == ID_WORKSHEET_TABS and event.notification == TCN_SELCHANGE then
    selectedWorksheet = gui.tabSelectedIndex(session.window.worksheetTabs)
    if selectedWorksheet >= 0 and selectedWorksheet < len(session.worksheets) and selectedWorksheet != session.selectedWorksheetIndex then ignoredWorksheet = try(activateWorksheet(session, selectedWorksheet)) end if
  else if event.controlId == ID_DETAIL_TABS and event.notification == TCN_SELCHANGE then
    labels = fullclient.detailTabLines(session.state)
    selected = gui.tabSelectedIndex(session.window.detailTabs)
    if selected >= 0 and selected < len(labels) then
      gui.setText(session.window.detailEdit, fullclient.detailTextByName(session.state, labels[selected]))
      ignoredDetailGrid = try(fillDetailGrid(session, labels[selected]))
      applyVisibility(session.window)
    end if
  else if event.controlId == ID_DETAIL_GRID and event.notification == NM_DBLCLK and gui.tabSelectedIndex(session.window.detailTabs) == 3 then
    selectedData = try(selectedDataRow(session))
    cell = gui.listViewPointerCell(session.window.detailGrid)
    initialField = 0
    if len(cell) == 2 and cell[1] > 0 then initialField = editorFieldForDataColumn(session.state.tableDetails, cell[1] - 1) end if
    if typeof(selectedData) == "error" then session.state.statusText = selectedData.message else ignoredDoubleEdit = try(editDataRow(session, selectedData, false, true, initialField)) end if
  else if event.controlId == ID_DETAIL_GRID and event.notification == LVN_COLUMNCLICK and gui.tabSelectedIndex(session.window.detailTabs) == 3 then
    dataColumn = event.source - 1
    if dataColumn >= 0 and dataColumn < len(session.state.tableDetails.contentsGrid.columns) then
      sortColumn = session.state.tableDetails.contentsGrid.columns[dataColumn]
      ascending = true
      if sortColumn == session.dataOptions.sortColumn then ascending = not session.dataOptions.ascending end if
      options = try(fullclient.createDataBrowseOptions(session.dataOptions.filterText, sortColumn, ascending, 0, session.dataOptions.pageSize))
      if typeof(options) == "error" then session.state.statusText = options.message else ignoredSort = try(startDataPage(session, options)) end if
    end if
  else if event.controlId == ID_RESULT_TABS and event.notification == TCN_SELCHANGE then
    selected = gui.tabSelectedIndex(session.window.resultTabs)
    if selected >= 0 and selected < len(session.state.resultTabs) then session.state.selectedResultIndex = selected; fillResultGrid(session.window, session.state) end if
  else if event.controlId == ID_OBJECT_TREE and event.notification == TVN_SELCHANGEDW then
    selectedObject = try(gui.treeSelectedText(session.window.objectTree))
    if typeof(selectedObject) == "string" and fullclient.containsText(session.state.tables, selectedObject) then session.state.selectedTable = selectedObject; session.state.statusText = "Selected table " + selectedObject; gui.setText(session.window.statusLabel, session.state.statusText) end if
  else if event.controlId == ID_OBJECT_TREE and event.notification == NM_DBLCLK then
    openSelectedObject(session)
  end if
  return true
end function

/// Handles edit, filter, bookmark, history, and toolbar WM_COMMAND events.
/// @param session Active Workbench session that receives the command.
/// @param event Native command event and control identifiers.
function handleWindowCommandEvent(session, event)
  if event.controlId == ID_QUERY_EDIT and event.notification == EN_CHANGE then
    session.highlightDirty = true
    session.highlightAfterMilliseconds = clock.monotonicMilliseconds() + 120
  else if event.controlId == ID_HISTORY_FILTER and event.notification == EN_CHANGE then
    filterText = try(gui.getText(session.window.historyFilterEdit))
    if typeof(filterText) == "string" then session.historyFilter = filterText; ignoredFilteredHistory = try(fillList(session.window.historyList, fullclient.filterHistory(session.state.history, filterText))) end if
  else if event.controlId == ID_BOOKMARK_LIST and event.notification == LBN_DBLCLK then
    insertSelectedBookmark(session)
  else if event.controlId == ID_HISTORY_LIST and event.notification == LBN_DBLCLK then
    insertSelectedHistory(session)
  else
    handleCommand(session, event.controlId)
  end if
  return true
end function

/// Routes one native event after verifying that it belongs to this workbench.
/// @param session Active Workbench session and top-level window state.
/// @param event Native window event to route.
function handleSessionEvent(session, event)
  if event.hwnd != session.window.hwnd then return true end if
  if event.message == gui.WM_CLOSE then return handleCommand(session, ID_CLOSE) end if
  if event.message == gui.WM_SIZE or event.message == gui.WM_DPICHANGED then
    layoutWindow(session.window)
    currentRect = try(gui.topLevelRect(session.window.hwnd))
    if typeof(currentRect) == "array" then session.windowRect = currentRect end if
    return true
  end if
  if event.message == gui.WM_MOVE then
    currentRect = try(gui.topLevelRect(session.window.hwnd))
    if typeof(currentRect) == "array" then session.windowRect = currentRect end if
    return true
  end if
  if event.message == gui.WM_CONTEXTMENU and not session.busy then return handleContextMenuEvent(session, event) end if
  if event.message == gui.WM_NOTIFY and not session.busy then return handleNotifyEvent(session, event) end if
  if event.message == gui.WM_COMMAND then return handleWindowCommandEvent(session, event) end if
  return true
end function

/// Runs the responsive Win32 event loop for one connected session.
/// @param session session value consumed by this operation.
function runSession(session)
  while gui.isOpen(session.window.hwnd)
    ignoredPump = gui.pumpMessages()
    // A native tab changes before its queued WM_NOTIFY is consumed. Capture
    // that state first so a simultaneously finishing worker cannot render the
    // previous page back over the user's choice.
    if gui.isOpen(session.window.hwnd) then ignoredWorkspace = try(synchronizeWorkspace(session)) end if
    if gui.isOpen(session.window.hwnd) then ignoredWorker = pollQuery(session) end if
    event = gui.pollEvent()
    while typeof(event) == "struct"
      ignoredEvent = try(handleSessionEvent(session, event))
      event = gui.pollEvent()
    end while
    // Coalesce every edit burst into one full recolor after the native event
    // queue drains. CHARFORMAT changes preserve text and emit no EN_CHANGE.
    if session.highlightDirty and not session.busy and clock.monotonicMilliseconds() >= session.highlightAfterMilliseconds then
      session.highlightDirty = false
      highlighted = try(highlightSqlEditor(session.window))
      if typeof(highlighted) == "error" then session.state.statusText = "Syntax highlighting failed: " + highlighted.message; gui.setText(session.window.statusLabel, session.state.statusText) end if
    end if
    gui.sleep(10)
  end while
  if len(session.layoutPath) > 0 and len(session.windowRect) == 4 then ignoredLayoutSave = try(saveWindowLayout(session.layoutPath, session.windowRect)) end if
  if session.busy then stopQuery(session) end if
  closed = true
  if session.aborted then closed = try(fullclient.abort(session.state)) else closed = try(fullclient.close(session.state)) end if
  if typeof(closed) == "error" then return closed end if
  return true
end function

/// Runs a hidden workbench construction smoke test against an existing state.
/// @param state Mutable state inspected or updated by the operation.
function stateSmoke(state)
  session = try(openState(state, false))
  if typeof(session) == "error" then return session end if
  rendered = try(render(session))
  gui.destroy(session.window.hwnd)
  if typeof(rendered) == "error" then return rendered end if
  return true
end function

/// Performs the componentName operation for the minisql admin win32 client module.
function componentName()
  return "admin.win32_client"
end function

/// Performs the targetMilestone operation for the minisql admin win32 client module.
function targetMilestone()
  return "M74"
end function

/// Reports that the native workbench is implemented.
function isImplemented()
  return true
end function
