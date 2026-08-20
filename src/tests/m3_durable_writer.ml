// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.platform.file as file_api
import tests.support.testkit as test

// Runs the durable writer test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = test.create()
  if len(args) != 1 then
    print "MiniSQL M3 durability writer: FAIL (expected one path argument)"
    return 2
  end if
  data = bytes(4096, 0)
  for index = 0 to 4095
    data[index] = (index * 37 + 11) % 256
  end for
  file = file_api.createDurable(args[0])
  test.equal(state, file_api.writeAt(file, 0, data, 0, len(data)), len(data), "durable write")
  test.record(state, file_api.flush(file), "durable flush")
  test.record(state, file_api.close(file), "durable close")
  return test.finish(state, "MiniSQL M3 durability writer: SUCCESS", "MiniSQL M3 durability writer: FAIL")
end function
