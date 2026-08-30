// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.clock as clock
import minisql.protocol.codec as protocol_codec
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

// Verifies cancellation, deadlines, process admission, spill quotas and metrics.
function main(args)
  if len(args) != 1 then print "MiniSQL M77 production controls: FAIL (missing data root)"; return 1 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m77_production_controls", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)
  sessionId = executor.sessionIdentifier(engine)

  database_manager.configureProductionControls(managed, 5, 1048576, 2147483648, 1048576, 1)
  executor.beginQueryControl(engine)
  // Keep a wide scheduler margin: a two-millisecond sleep can legally return
  // in the same coarse monotonic tick on a busy Windows acceptance host.
  clock.sleepMilliseconds(50)
  timedOut = try(executor.pollQueryControl(engine, "m77.deadline"))
  testkit.errorCode(state, timedOut, 9036, "absolute execution deadline")
  executor.finishQueryControl(engine)

  database_manager.configureProductionControls(managed, 30000, 1048576, 2147483648, 1048576, 1)
  executor.beginQueryControl(engine)
  database_manager.beginOperationalStatement(managed, sessionId, 1, "SELECT controlled")
  database_manager.requestSessionCancellation(managed, sessionId)
  cancelled = try(executor.pollQueryControl(engine, "m77.cancel"))
  testkit.errorCode(state, cancelled, 9035, "administrative cancellation token")
  executor.finishQueryControl(engine)
  database_manager.finishOperationalStatement(managed, sessionId, false, 0)

  database_manager.reserveTemporaryStorage(managed, 786432)
  quota = try(database_manager.reserveTemporaryStorage(managed, 524288))
  testkit.errorCode(state, quota, 9037, "global temporary-storage quota")
  database_manager.releaseTemporaryStorage(managed, 786432)

  database_manager.configureProductionControls(managed, 30000, 1048576, 16777216, 1048576, 1)
  pressure = bytes(20000000)
  admission = try(database_manager.admitStatement(managed))
  testkit.errorCode(state, admission, 9037, "managed heap admission ceiling")
  activeMemory = try(database_manager.enforceProcessMemory(managed))
  testkit.errorCode(state, activeMemory, 9037, "active managed heap ceiling")
  pressure = void

  encodedCancel = protocol_codec.encodeMessage(messages.cancelRequest(77, sessionId))
  decodedCancel = protocol_codec.decodeMessage(encodedCancel)
  testkit.equal(state, decodedCancel.messageType, constants.TYPE_CANCEL, "cancel frame type round trip")
  testkit.equal(state, messages.decodeCancelRequest(decodedCancel.payload), sessionId, "cancel target round trip")

  status = database_manager.operationalStatus(managed)
  testkit.equal(state, len(status), 31, "production status metric count")
  testkit.equal(state, status[28], 0, "write fencing is disabled for ordinary embedded databases")
  testkit.equal(state, database_manager.maxResultBytes(managed), 1048576, "result byte limit getter")

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M77 production controls: SUCCESS", "MiniSQL M77 production controls: FAIL")
end function
