// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.platform.clock as clock
import minisql.platform.file as file_api
import tests.support.testkit as test

// Runs the file test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = test.create()
  if len(args) != 1 then
    print "MiniSQL M3 random-access file tests: FAIL (expected one path argument)"
    return 2
  end if
  path = args[0]

  file = file_api.create(path)
  ramp = bytes(256, 0)
  for index = 0 to 255
    ramp[index] = index
  end for
  test.equal(state, file_api.writeAt(file, 0, ramp, 0, len(ramp)), 256, "write ramp")

  tail = bytes(100, 0)
  for index = 0 to 99
    tail[index] = (index * 3 + 7) % 256
  end for
  test.equal(state, file_api.writeAt(file, 512, tail, 0, len(tail)), 100, "write after sparse hole")
  test.equal(state, file_api.size(file), 612, "sparse file size")

  content = bytes(612, 0xCC)
  test.equal(state, file_api.readExactAt(file, 0, content, 0, len(content)), 612, "read complete file")
  for index = 0 to 255
    test.equal(state, content[index], index, "ramp byte " + index)
  end for
  for index = 0 to 99
    test.equal(state, content[512 + index], tail[index], "tail byte " + index)
  end for

  patch = fromHex("deadbeef")
  file_api.writeAt(file, 10, patch, 0, len(patch))
  appendedAt = file_api.append(file, fromHex("aabbcc"), 0, 3)
  test.equal(state, appendedAt, 612, "append offset")
  test.equal(state, file_api.size(file), 615, "append size")
  appended = bytes(3, 0)
  file_api.readExactAt(file, 612, appended, 0, 3)
  test.equal(state, hex(appended), "aabbcc", "append contents")
  file_api.flush(file)

  file_api.truncate(file, 100)
  test.equal(state, file_api.size(file), 100, "truncate down")
  file_api.truncate(file, 200)
  test.equal(state, file_api.size(file), 200, "truncate up")
  file_api.flush(file)
  file_api.close(file)
  test.errorCode(state, try(file_api.size(file)), 9008, "closed file rejected")

  reopened = file_api.openRead(path)
  first = bytes(100, 0)
  file_api.readExactAt(reopened, 0, first, 0, len(first))
  test.equal(state, hex(slice(first, 10, 4)), "deadbeef", "persisted patch")
  test.equal(state, file_api.size(reopened), 200, "persisted size")
  file_api.close(reopened)

  before = clock.monotonicMilliseconds()
  clock.sleepMilliseconds(20)
  after = clock.monotonicMilliseconds()
  test.record(state, after >= before, "monotonic clock does not go backwards")

  return test.finish(state, "MiniSQL M3 random-access file tests: SUCCESS", "MiniSQL M3 random-access file tests: FAIL")
end function
