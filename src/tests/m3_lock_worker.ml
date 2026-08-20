// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.platform.clock as clock
import minisql.platform.file as file_api
import minisql.platform.lock as lock_api
import tests.support.testkit as test

// Runs the lock worker test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 4 then
    print "MiniSQL M3 lock worker: FAIL (expected mode, file, ready, milliseconds)"
    return 2
  end if
  mode = args[0]
  path = args[1]
  readyPath = args[2]
  milliseconds = toNumber(args[3])
  if milliseconds is not int then
    print "MiniSQL M3 lock worker: FAIL (invalid milliseconds)"
    return 2
  end if

  state = test.create()
  if mode == "hold" then
    file = file_api.openReadWrite(path, true)
    held = lock_api.acquireExclusive(file, false)
    ready = file_api.createDurable(readyPath)
    marker = bytes("ready")
    file_api.writeAt(ready, 0, marker, 0, len(marker))
    file_api.flush(ready)
    file_api.close(ready)
    clock.sleepMilliseconds(milliseconds)
    test.record(state, lock_api.release(held), "holder release")
    test.record(state, file_api.close(file), "holder close")
    return test.finish(state, "MiniSQL M3 lock holder: SUCCESS", "MiniSQL M3 lock holder: FAIL")
  end if

  if mode == "try" then
    file = file_api.openReadWrite(path, false)
    attempt = try(lock_api.acquireExclusive(file, true))
    test.errorCode(state, attempt, 9007, "contender sees lock conflict")
    test.record(state, file_api.close(file), "contender close")
    return test.finish(state, "MiniSQL M3 lock contender: SUCCESS", "MiniSQL M3 lock contender: FAIL")
  end if

  print "MiniSQL M3 lock worker: FAIL (unknown mode)"
  return 2
end function
