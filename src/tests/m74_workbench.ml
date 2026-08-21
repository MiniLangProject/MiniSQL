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

  smoke = try(gui.hiddenWindowSmoke())
  testkit.record(state, typeof(smoke) != "error" and smoke, "custom Win32 top-level smoke")
  window = try(win32_client.createWindow(false))
  if typeof(window) == "error" then print window.message end if
  testkit.record(state, typeof(window) != "error", "SQuirreL-style workbench controls construct")
  if typeof(window) != "error" then
    testkit.record(state, window.objectTree != 0 and window.queryEdit != 0 and window.resultGrid != 0, "object tree editor and result grid exist")
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
