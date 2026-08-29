// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.client.client as client
import minisql.platform.clock as clock
import minisql.protocol.constants as constants
import std.threading as threading

// Native counterpart to concurrent_indexed_reads.py. Keeping transport,
// protocol decoding, and worker scheduling inside MiniLang separates server
// scaling from Python interpreter and GIL effects.

const SEED_ROWS = 10000
const WARMUP_OPERATIONS = 16
const READY_TIMEOUT_MS = 30000
const TRIAL_TIMEOUT_MS = 120000

// Immutable arguments owned by one persistent client worker.
struct ReadWorkerTask
  // Loopback TCP port of the isolated benchmark server.
  port
  // Stable worker ordinal used to choose deterministic lookup keys.
  workerIndex
  // Number of measured prepared statements executed by this worker.
  operations
  // Manual-reset event that aligns the measured interval.
  start
  // Counting semaphore announcing that warm-up has completed.
  ready
  // Counting semaphore announcing that measured requests have completed.
  finished
  // Event keeping connection teardown outside the measured interval.
  cleanup
end struct

// Converts a response failure into one benchmark-specific error.
function requireRows(response, expected, operation)
  if typeof(response) == "error" then return response end if
  if response.status == constants.STATUS_ERROR then return error(response.errorCode, operation + ": " + response.message) end if
  if len(response.rows) != 1 or len(response.rows[0]) != 1 then return error(9004, operation + ": expected one scalar row") end if
  if toNumber(response.rows[0][0]) != expected then return error(9004, operation + ": scalar result mismatch") end if
  return true
end function

// Opens and warms one session, then performs aligned prepared primary-key reads.
function runReadWorker(task)
  active = try(client.openLoopback(task.port))
  if typeof(active) == "error" then task.ready.release(); task.finished.release(); return active end if
  prepared = try(client.query(active, "PREPARE native_parallel_lookup AS SELECT metric FROM connector_seed WHERE id = ?"))
  if typeof(prepared) == "error" or prepared.status == constants.STATUS_ERROR then
    task.ready.release()
    task.finished.release()
    client.abort(active)
    if typeof(prepared) == "error" then return prepared end if
    return error(prepared.errorCode, "native prepare failed: " + prepared.message)
  end if
  for warmup = 0 to WARMUP_OPERATIONS - 1
    key = 1 + ((task.workerIndex * 257 + warmup) % SEED_ROWS)
    checked = try(requireRows(try(client.query(active, "EXECUTE native_parallel_lookup USING " + key)), key % 97, "warmup"))
    if typeof(checked) == "error" then task.ready.release(); task.finished.release(); client.abort(active); return checked end if
  end for
  baselineByteCounts = client.protocolByteCounts(active)
  task.ready.release()
  if not task.start.waitFor(READY_TIMEOUT_MS) then task.finished.release(); client.abort(active); return error(9004, "native worker start timed out") end if
  for operation = 0 to task.operations - 1
    key = 1 + ((task.workerIndex * task.operations + operation) % SEED_ROWS)
    checked = try(requireRows(try(client.query(active, "EXECUTE native_parallel_lookup USING " + key)), key % 97, "lookup"))
    if typeof(checked) == "error" then task.finished.release(); client.abort(active); return checked end if
  end for
  finalByteCounts = client.protocolByteCounts(active)
  task.finished.release()
  if not task.cleanup.waitFor(READY_TIMEOUT_MS) then client.abort(active); return error(9004, "native worker cleanup timed out") end if
  deallocated = try(client.query(active, "DEALLOCATE PREPARE native_parallel_lookup"))
  if typeof(deallocated) == "error" then client.abort(active); return deallocated end if
  closed = try(client.close(active))
  if typeof(closed) == "error" then return closed end if
  return [task.operations, finalByteCounts[0] - baselineByteCounts[0], finalByteCounts[1] - baselineByteCounts[1]]
end function

// Runs one aligned trial and prints a machine-readable summary line.
function runTrial(port, clients, operations, trial)
  start = threading.Event.new(true, false)
  ready = threading.Semaphore.new(0, clients)
  finished = threading.Semaphore.new(0, clients)
  cleanup = threading.Event.new(true, false)
  workers = array(clients)
  for workerIndex = 0 to clients - 1
    workers[workerIndex] = Thread(runReadWorker, "minisql-native-read-" + workerIndex)
    if not workers[workerIndex].Start(ReadWorkerTask(port, workerIndex, operations, start, ready, finished, cleanup)) then
      start.set()
      return error(9004, "could not start native read worker " + workerIndex)
    end if
  end for
  allReady = true
  for workerIndex = 0 to clients - 1
    if not ready.acquireFor(READY_TIMEOUT_MS) then allReady = false; break end if
  end for
  started = clock.monotonicMilliseconds()
  start.set()
  completed = allReady
  for workerIndex = 0 to clients - 1
    if not finished.acquireFor(TRIAL_TIMEOUT_MS) then completed = false; break end if
  end for
  elapsed = clock.monotonicMilliseconds() - started
  cleanup.set()
  for workerIndex = 0 to clients - 1
    if not workers[workerIndex].Join(TRIAL_TIMEOUT_MS) then completed = false end if
  end for
  failure = void
  sentBytes = 0
  receivedBytes = 0
  for workerIndex = 0 to clients - 1
    workerResult = try(workers[workerIndex].Result())
    if workers[workerIndex].Status() != "Completed" then
      if typeof(workerResult) == "error" and failure is void then failure = workerResult end if
      completed = false
    else
      sentBytes = sentBytes + workerResult[1]
      receivedBytes = receivedBytes + workerResult[2]
    end if
    workers[workerIndex].Close()
  end for
  start.close()
  ready.close()
  finished.close()
  cleanup.close()
  if failure is not void then return failure end if
  if not completed or elapsed <= 0 then return error(9004, "native concurrent trial did not complete") end if
  requests = clients * operations
  rate = requests * 1000 / elapsed
  print "clients=" + clients + " trial=" + trial + " operationsPerClient=" + operations + " elapsedMs=" + elapsed + " requestsPerSecond=" + rate + " protocolSentBytes=" + sentBytes + " protocolReceivedBytes=" + receivedBytes
  return rate
end function

// Usage: native-concurrent-indexed-reads <port> <clients> <operations> <trials>.
function main(args)
  if len(args) != 4 then
    print "Usage: native-concurrent-indexed-reads <port> <clients> <operations> <trials>"
    return 2
  end if
  port = toNumber(args[0])
  clients = toNumber(args[1])
  operations = toNumber(args[2])
  trials = toNumber(args[3])
  if typeof(port) != "int" or port < 1 or port > 65535 or typeof(clients) != "int" or clients < 1 or clients > 64 or typeof(operations) != "int" or operations < 1 or typeof(trials) != "int" or trials < 1 then
    print "native concurrent indexed-read benchmark: invalid arguments"
    return 2
  end if
  for trial = 0 to trials - 1
    result = try(runTrial(port, clients, operations, trial))
    if typeof(result) == "error" then print "native concurrent indexed-read benchmark: FAIL " + result.message; return 1 end if
  end for
  print "native concurrent indexed-read benchmark: SUCCESS"
  return 0
end function
