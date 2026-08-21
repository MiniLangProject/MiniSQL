// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.admin.fullclient as fullclient
import minisql.admin.win32_client as win32_client
import tests.support.testkit as testkit

// Exercises the complete workbench model over a real trusted-local server connection.
function main(args)
  if len(args) != 1 then print "MiniSQL M74 workbench network worker: FAIL args"; return 2 end if
  port = toNumber(args[0])
  if typeof(port) != "int" then print "MiniSQL M74 workbench network worker: FAIL port"; return 2 end if
  test = testkit.create()
  profile = fullclient.createProfile("Network test", "127.0.0.1", port, "localhost", "workbench", "", false, "", true)
  active = try(fullclient.openProfile(profile, bytes(0)))
  if typeof(active) == "error" then print active.message; return 1 end if
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
  smoke = try(win32_client.stateSmoke(active))
  testkit.record(test, typeof(smoke) != "error" and smoke, "connected hidden workbench renders")
  closed = try(fullclient.close(active))
  testkit.record(test, typeof(closed) != "error" and closed, "workbench closes protocol session")
  return testkit.finish(test, "MiniSQL M74 workbench network worker: SUCCESS", "MiniSQL M74 workbench network worker: FAIL")
end function
