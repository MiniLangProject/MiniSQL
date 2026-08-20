// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.endian as endian
import minisql.platform.file as file_api
import minisql.transaction.checkpoint as checkpoint
import tests.support.testkit as testkit

// Removes a test artifact when present; absence is accepted so repeated test runs start from the same state.
function cleanup(path)
  ignored = try(file_api.deletePath(path))
  return true
end function

// Returns the deterministic database identifier used to make on-disk test fixtures reproducible.
function databaseId()
  return fromHex("00112233445566778899aabbccddeeff")
end function

// Runs the checkpoint test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M7 checkpoint tests: FAIL (missing path)"
    return 1
  end if
  path = args[0]
  cleanup(path)
  state = testkit.create()

  cp = checkpoint.create(path, databaseId())
  testkit.equal(state, cp.metadata.generation.low, 1, "initial generation")
  testkit.errorCode(state, try(checkpoint.publish(cp, 10, 11, 1)), checkpoint.INVALID_ARGUMENT, "redo start cannot exceed checkpoint LSN")
  checkpoint.publish(cp, 100, 64, 7)
  testkit.equal(state, cp.metadata.generation.low, 2, "published generation")
  testkit.equal(state, cp.metadata.checkpointLsn, 100, "checkpoint LSN")
  testkit.equal(state, cp.metadata.redoStartLsn, 64, "redo start")
  checkpoint.publish(cp, 200, 128, 11)
  testkit.equal(state, cp.metadata.generation.low, 3, "second published generation")
  checkpoint.close(cp)

  reopened = checkpoint.open(path)
  testkit.equal(state, reopened.metadata.checkpointLsn, 200, "reopen newest checkpoint")
  testkit.equal(state, reopened.metadata.recordCount, 11, "reopen record count")
  activeSlot = reopened.activeSlot
  checkpoint.close(reopened)

  raw = file_api.openReadWrite(path, false)
  offset = checkpoint.SLOT_A_OFFSET
  if activeSlot == checkpoint.SLOT_B then offset = checkpoint.SLOT_B_OFFSET end if
  byte = bytes(1, 0)
  file_api.readExactAt(raw, offset + 20, byte, 0, 1)
  byte[0] = byte[0] ^ 0x40
  file_api.writeAt(raw, offset + 20, byte, 0, 1)
  file_api.flush(raw)
  file_api.close(raw)

  fallback = checkpoint.open(path)
  testkit.equal(state, fallback.metadata.checkpointLsn, 100, "corrupt newest slot falls back")
  testkit.equal(state, fallback.metadata.generation.low, 2, "fallback generation")
  checkpoint.close(fallback)

  cleanup(path)
  return testkit.finish(state, "MiniSQL M7 checkpoint tests: SUCCESS", "MiniSQL M7 checkpoint tests: FAIL")
end function
