// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.client.console as console
import minisql.client.formatter as formatter
import minisql.protocol.messages as messages
import tests.support.testkit as testkit

// Exercises the native stdin helper through the same scan-and-format path used
// by the interactive MiniSQL shell. The piped line must retain its exact length
// across the allocator call before it is concatenated into the shell buffer.
function main(args)
  state = testkit.create()
  line = input()
  testkit.equal(state, line, "show tables;", "interactive input content")
  testkit.equal(state, len(line), 12, "interactive input byte length")

  buffer = line + "\n"
  batch = console.scanSqlBatch(buffer, false)
  testkit.equal(state, len(batch.statements), 1, "interactive statement emitted")
  testkit.equal(state, batch.statements[0], "show tables;", "interactive statement preserved")
  testkit.equal(state, batch.remainder, "", "completed interactive input leaves no remainder")

  response = messages.rowResponse(["table_name"], [["shop_product"]])
  formatted = formatter.formatResponse(response)
  testkit.equal(state, formatted, "table_name\nshop_product\n(1 rows)", "interactive response formatting")
  return testkit.finish(state, "MiniSQL M33 interactive input tests: SUCCESS", "MiniSQL M33 interactive input tests: FAIL")
end function
