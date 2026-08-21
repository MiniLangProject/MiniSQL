// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.admin.connection_profiles as profiles
import minisql.admin.fullclient as fullclient
import minisql.admin.win32_client as win32_client
import minisql.platform.file as file_api
import minisql.platform.win32_gui as gui
import tests.support.testkit as testkit

// Runs model, profile-store, and hidden native-control coverage for the MiniSQL Workbench.
function main(args)
  if len(args) != 1 then print "MiniSQL M74 workbench tests: FAIL args"; return 2 end if
  state = testkit.create()
  plain = fullclient.createProfile("Development", "127.0.0.1", 7432, "localhost", "shop", "admin", false, "", false)
  pinned = fullclient.createProfile("Pinned TLS", "shop.example.test", 7433, "shop.example.test", "shop", "operator", true, "AA:BB:CC", false)
  trusted = profiles.defaultProfile()
  testkit.equal(state, fullclient.endpointText(plain), "tcp://127.0.0.1:7432/shop", "plain endpoint text")
  testkit.record(state, pinned.tls and len(pinned.pinSha256) > 0, "TLS pin retained in alias")
  testkit.record(state, trusted.trustedLocal and not trusted.tls, "first-run alias uses trusted local mode")
  testkit.errorCode(state, try(fullclient.createProfile("Bad", "remote.example", 7432, "remote.example", "main", "", false, "", true)), 9001, "trusted local rejects remote address")
  testkit.errorCode(state, try(fullclient.createProfile("Bad Pin", "127.0.0.1", 7432, "localhost", "main", "admin", false, "AA", false)), 9001, "pin requires TLS")
  testkit.equal(state, len(fullclient.defaultBookmarks()), 8, "built-in MiniSQL bookmark count")

  profilePath = file_api.joinPath(args[0], "workbench-profiles.json")
  saved = try(profiles.save(profilePath, [plain, pinned, trusted]))
  testkit.record(state, typeof(saved) != "error" and saved, "profiles save atomically")
  loaded = profiles.load(profilePath)
  testkit.equal(state, len(loaded), 3, "profiles roundtrip")
  if len(loaded) == 3 then
    testkit.equal(state, loaded[1].pinSha256, "AA:BB:CC", "certificate pin roundtrip")
    testkit.record(state, loaded[2].trustedLocal, "trusted-local flag roundtrip")
  else
    testkit.record(state, false, "certificate pin roundtrip")
    testkit.record(state, false, "trusted-local flag roundtrip")
  end if
  raw = file_api.readAllText(profilePath, 1048576)
  testkit.record(state, not fullclient.textContains(raw, "password"), "profile file contains no password field")

  smoke = try(gui.hiddenWindowSmoke())
  testkit.record(state, typeof(smoke) != "error" and smoke, "custom Win32 top-level smoke")
  window = try(win32_client.createWindow(false))
  if typeof(window) == "error" then print window.message end if
  testkit.record(state, typeof(window) != "error", "SQuirreL-style workbench controls construct")
  if typeof(window) != "error" then
    testkit.record(state, window.objectTree != 0 and window.queryEdit != 0 and window.resultGrid != 0, "object tree editor and result grid exist")
    testkit.equal(state, gui.tabSelectedIndex(window.workspaceTabs), 0, "SQL worksheet is default workspace")
    gui.destroy(window.hwnd)
  end if
  manager = try(win32_client.connectionManagerSmoke(profilePath))
  testkit.record(state, typeof(manager) != "error" and manager, "connection manager hidden smoke")
  return testkit.finish(state, "MiniSQL M74 workbench tests: SUCCESS", "MiniSQL M74 workbench tests: FAIL")
end function
