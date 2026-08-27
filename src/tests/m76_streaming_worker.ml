// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.client.client as client

// Parses a positive decimal argument used by the standalone performance worker.
function positiveInteger(text)
  value = toNumber(text)
  if typeof(value) != "int" or value <= 0 then return error(9001, "streaming worker expects positive integers") end if
  return value
end function

// Consumes a large unordered result through the cursor API without retaining
// prior batches. The output exposes row, batch, and payload invariants to the
// Python process-memory monitor.
function main(args)
  if len(args) != 3 then print "Usage: streaming-worker <port> <rows> <payload-bytes>"; return 1 end if
  port = positiveInteger(args[0])
  expectedRows = positiveInteger(args[1])
  payloadBytes = positiveInteger(args[2])
  active = try(client.openLoopback(port))
  if typeof(active) == "error" then return active end if
  cursor = try(client.beginQuery(active, "SELECT id, payload FROM capacity_data"))
  if typeof(cursor) == "error" then client.abort(active); return cursor end if
  rows = 0
  batches = 0
  maximumBatchRows = 0
  while true
    batch = try(client.nextQueryBatch(cursor))
    if typeof(batch) == "error" then client.abort(active); return batch end if
    if batch is void then break end if
    batches = batches + 1
    if len(batch.rows) > maximumBatchRows then maximumBatchRows = len(batch.rows) end if
    for each row in batch.rows
      if len(row) != 2 or len(bytes(row[1])) != payloadBytes then client.abort(active); return error(9004, "streaming worker received an invalid row") end if
      rows = rows + 1
    end for
  end while
  client.close(active)
  if rows != expectedRows then return error(9004, "streaming worker row count mismatch") end if
  print "STREAM_SUCCESS rows=" + rows + " batches=" + batches + " maximumBatchRows=" + maximumBatchRows + " payloadBytes=" + payloadBytes
  return 0
end function
