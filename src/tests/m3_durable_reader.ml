// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.platform.file as file_api
import tests.support.testkit as test

// Runs the durable reader test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = test.create()
  if len(args) != 1 then
    print "MiniSQL M3 durability reader: FAIL (expected one path argument)"
    return 2
  end if
  file = file_api.openRead(args[0])
  data = bytes(4096, 0)
  file_api.readExactAt(file, 0, data, 0, len(data))
  for index = 0 to 4095
    test.equal(state, data[index], (index * 37 + 11) % 256, "durable byte " + index)
  end for
  test.record(state, file_api.close(file), "reader close")
  return test.finish(state, "MiniSQL M3 durability reader: SUCCESS", "MiniSQL M3 durability reader: FAIL")
end function
