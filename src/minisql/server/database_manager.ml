package minisql.server.database_manager

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import std.threading as threading
import std.ds.hashmap as hashmap
import std.ds.list as list
import std.time as time_api
import minisql.catalog.catalog as catalog
import minisql.catalog.schema_history as schema_history
import minisql.common.crc32c as crc32c
import minisql.common.diagnostics as diagnostics
import minisql.common.endian as endian
import minisql.common.logger as logger
import minisql.platform.file as file_api
import minisql.platform.clock as clock
import minisql.platform.lock as file_lock
import minisql.storage.paged_file as paged_file
import minisql.storage.btree as btree
import minisql.storage.buffer_pool as buffer_pool
import minisql.transaction.checkpoint as checkpoint
import minisql.transaction.recovery as recovery
import minisql.transaction.transaction as transaction
import minisql.transaction.lock_manager as lock_manager
import minisql.transaction.wal as wal

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004
const CLOSED_HANDLE = 9008
const STANDBY_NOT_PROMOTED = 9033
const DEFAULT_CHECKPOINT_WAL_BYTES = 67108864
const DEFAULT_BUFFER_POOL_BYTES = 268435456
const DEFAULT_QUERY_MEMORY_BYTES = 67108864
const DEFAULT_MAX_STATEMENT_BYTES = 1048576
const DEFAULT_MAX_FRAME_BYTES = 8388608
const DEFAULT_MAX_RESULT_ROWS = 1000000
const DEFAULT_IDLE_TIMEOUT_MS = 300000
const DEFAULT_QUERY_TIMEOUT_MS = 30000
const DEFAULT_MAX_RESULT_BYTES = 268435456
const DEFAULT_PROCESS_MEMORY_BYTES = 2147483648
const DEFAULT_TEMPORARY_STORAGE_BYTES = 1073741824
const DEFAULT_SLOW_QUERY_MS = 1000
const QUERY_CANCELLED = 9035
const QUERY_TIMEOUT = 9036
const RESOURCE_LIMIT = 9037
const WRITE_FENCED = 9038
const LEADER_EPOCH_BYTES = 32
const LEADER_LEASE_BYTES = 64

// Mutable process-list entry protected by the database execution-state lock.
struct OperationalSession
  // Stable identifier allocated with the executor engine.
  sessionId
  // Remote endpoint or the literal "embedded" for local API users.
  peerEndpoint
  // Indicates whether native TLS protects the connection.
  secure
  // Current authenticated principal identifier.
  principalId
  // Monotonic connection creation time.
  createdAt
  // Monotonic time of the most recent request transition.
  lastActivity
  // Monotonic start time of the active statement, or zero while idle.
  statementStartedAt
  // Bounded statement summary suitable for an administrative process list.
  statementText
  // Human-readable connection state such as IDLE or EXECUTING.
  state
  // Number of statements completed by this session.
  requestCount
  // Cooperatively asks the executor owning this session to stop at its next poll.
  cancelRequested
end struct

// Durable marker formats used to make physical WAL reset crash-safe. The epoch
// marker remains for the lifetime of a database after its first reset and tells
// recovery to replay the bounded current WAL without comparing pre-reset page
// LSNs. The pending marker is removed after WAL and checkpoint metadata agree.
const CHECKPOINT_MARKER_BYTES = 24

// Writer-prioritized readers/writer gate. A waiting writer owns turnstile, so
// newly arriving readers cannot continuously postpone database mutations.
// Coordinates physical execution for one database. The three synchronization
// objects implement a writer-prioritized readers/writer gate; `readers` is
// accessed only while `stateLock` is held.
struct ExecutionGate
  // Protects `readers` and `peakReaders` from concurrent updates.
  stateLock
  // Serializes writers and prevents new readers from bypassing a waiting writer.
  turnstile
  // Is held by the first reader or the active writer until the database is empty.
  roomEmpty
  // Counts readers currently admitted to the database execution section.
  readers
  // Records the greatest observed reader count for diagnostics and tests.
  peakReaders
end struct

// Groups the managed database state and preserves the field relationships documented below.
struct ManagedDatabase
  // Stores the filesystem path.
  path
  // Stores the catalog handle associated with this value.
  catalogHandle
  // Immutable process-local snapshot of the durable schema sidecar. DDL
  // publishes a replacement snapshot after commit, allowing ordinary reads to
  // avoid reopening and checksumming schema.history for every row operation.
  schemaState
  // Stores the filesystem lock file.
  lockFile
  // Synchronizes access through the lock token.
  lockToken
  // Stores the WAL writer associated with this value.
  walWriter
  // Stores the filesystem checkpoint file.
  checkpointFile
  // Stores the last recovery associated with this value.
  lastRecovery
  // Synchronizes access through the lock manager.
  lockManager
  // Tracks the next session identifier numeric value.
  nextSessionId
  // Stores the audit log associated with this value.
  auditLog
  // Indicates whether the standby condition is active.
  standby
  // Stores the execution gate associated with this value.
  executionGate
  // Maximum current-WAL size before a statement boundary performs a reset.
  checkpointWalBytes
  // True after the database has entered bounded-WAL epoch replay mode.
  walEpoch
  // Counts successful automatic WAL resets for diagnostics and tests.
  checkpointResets
  // Database-owned concurrent cache for committed table pages.
  readCache
  // Database-owned persistent read handles for hot table and index paths.
  readHandles
  // Indicates that process-local index readiness checks or repair completed.
  indexesReady
  // Process-local generation invalidating optimizer metadata across sessions.
  planningEpoch
  // Soft per-query memory budget inherited by every attached session.
  queryMemoryBytes
  // Process-local operational registry and cumulative counters.
  sessions
  // Monotonic timestamp captured after successful database open.
  startedAt
  // Counts all engines attached since this database opened.
  totalConnections
  // Counts completed logical SQL statements.
  totalStatements
  // Counts logical SQL statements ending in an error.
  failedStatements
  // Counts result rows produced by completed statements.
  rowsReturned
  // Records a cooperative administrative listener-stop request.
  shutdownRequested
  // Hard protocol and result limits inherited by attached sessions.
  maxStatementBytes
  // Maximum encoded response payload accepted by the configured server.
  maxFrameBytes
  // Maximum number of rows produced by one network statement.
  maxResultRows
  // Maximum inactive lifetime for one network session.
  idleTimeoutMs
  // Maximum execution time for a statement, excluding response delivery.
  queryTimeoutMs
  // Aggregate encoded response byte ceiling for one statement.
  maxResultBytes
  // Managed-heap admission ceiling shared by all sessions.
  processMemoryBytes
  // Spill byte reservations shared by all concurrent statements.
  temporaryStorageBytes
  // Bytes currently reserved by all query spill runs.
  temporaryReservedBytes
  // Greatest concurrent spill reservation observed since database open.
  temporaryPeakBytes
  // Statements terminated by an administrative cancellation token.
  cancelledStatements
  // Statements terminated after their absolute execution deadline.
  timedOutStatements
  // Statements rejected by a managed resource policy.
  resourceRejectedStatements
  // Sum of completed statement execution durations in milliseconds.
  totalExecutionMs
  // Greatest completed statement execution duration in milliseconds.
  maximumExecutionMs
  // Statements whose duration met the configured slow-query threshold.
  slowQueryCount
  // Millisecond threshold used for slow-query warnings and accounting.
  slowQueryMs
  // Complete encoded response bytes returned by completed statements.
  resultBytesReturned
  // Enables fail-closed validation of a controller-owned leader lease.
  fencingEnabled
  // Shared, atomically replaced lease record consulted before every write.
  fencingLeasePath
  // Immutable leadership term assigned when this server process starts.
  fencingEpoch
  // Immutable numeric identity of the node owning this server process.
  fencingNodeId
  // Clock-error allowance subtracted from the externally supplied expiry.
  fencingClockSkewMs
  // Counts write attempts rejected after a missing, stale, or foreign lease.
  fencingRejections
  // Indicates whether the closed condition is active.
  closed
end struct

// One persistent immutable table or index handle. Native positioned reads let
// all database readers use the same object concurrently without a shared file
// cursor; the database writer gate still owns invalidation and close.
struct CachedReadHandle
  // Stable absolute or database-relative path used as the registry key.
  path
  // Open PagedFile or BTree owned exclusively by the database registry.
  value
  // Distinguishes BTree handles from PagedFile handles during close.
  indexHandle
end struct

// Caller ownership token for one acquired persistent read handle.
struct ReadHandleLease
  // Owning registry whose concurrency counters track this lease.
  cache
  // Immutable registry entry kept alive by the database execution gate.
  entry
  // Lazily allocated query-local positioned-read completion state.
  readContext
  // Prevents double release and use after release.
  released
end struct

// Thread-safe per-database registry. DDL and mutations invalidate it while the
// physical writer gate excludes readers, so cached metadata never outlives a
// published table or index generation.
struct ReadHandleCache
  // Maps table paths to CachedReadHandle values.
  tables
  // Maps index paths to CachedReadHandle values.
  indexes
  // Serializes registry lookup and first-open publication.
  guard
  // Counts acquisitions satisfied without opening a native handle.
  hits
  // Counts acquisitions that opened and published a native handle.
  misses
  // Number of query operations currently using cached handles.
  activeLeases
  // Highest simultaneous cached-handle lease count since open.
  peakLeases
  // Idle positioned-read contexts available for the next index lease.
  availableReadContexts
  // Total query contexts created by this database.
  readContextCount
  // Prevents acquisitions after database shutdown.
  closed
end struct

// Immutable diagnostic snapshot for handle-cache tests and performance logs.
struct ReadHandleCacheStats
  // Number of acquisitions served by an existing persistent handle.
  hits
  // Number of acquisitions that opened a new native storage handle.
  misses
  // Number of currently cached table PagedFile handles.
  tableHandles
  // Number of currently cached index BTree handles.
  indexHandles
  // Number of handle leases active at snapshot time.
  activeLeases
  // Highest simultaneous handle lease count since database open.
  peakLeases
  // Number of reusable positioned-read contexts owned by the database.
  readContexts
  // Number of contexts currently idle in the pool.
  availableReadContexts
end struct

// Returns whether the supplied value satisfies the managed database condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isManagedDatabase(value)
  return value is ManagedDatabase
end function

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "server.database_manager." + operation + ": " + message)
end function

// Implements bytes equal for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

// Returns the durable per-database leadership-term record path. The HA
// controller replaces this record while the database is offline before it
// starts a process for a newer epoch.
function leaderEpochPath(path)
  return catalog.joinPath(path, "leader.epoch")
end function

// Reads one exact fencing record without accepting a prefix, trailing bytes,
// or a partially replaced file.
function readFenceBytes(path, expectedSize, operation)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, operation, "path must be non-empty") end if
  handle = try(file_api.openRead(path))
  if typeof(handle) == "error" then return fail(WRITE_FENCED, operation, "fencing record is unavailable: " + path) end if
  actualSize = file_api.size(handle)
  if actualSize != expectedSize then file_api.close(handle); return fail(WRITE_FENCED, operation, "fencing record size mismatch: " + path) end if
  payload = bytes(expectedSize, 0)
  read = try(file_api.readExactAt(handle, 0, payload, 0, expectedSize))
  closed = try(file_api.close(handle))
  if typeof(read) == "error" then return fail(WRITE_FENCED, operation, "fencing record could not be read: " + path) end if
  if typeof(closed) == "error" then return fail(WRITE_FENCED, operation, "fencing record could not be closed: " + path) end if
  return payload
end function

// Validates a fixed-size CRC-32C protected record header shared with the Python
// HA controller. The checksum field is always the final four bytes.
function validateFenceHeader(payload, magic, expectedSize, operation)
  if not bytesEqual(slice(payload, 0, 8), bytes(magic)) then return fail(WRITE_FENCED, operation, "fencing record magic mismatch") end if
  if endian.readU16LE(payload, 8) != 1 or endian.readU16LE(payload, 10) != expectedSize then return fail(WRITE_FENCED, operation, "unsupported fencing record version") end if
  checksumOffset = expectedSize - 4
  storedChecksum = endian.readU32LE(payload, checksumOffset)
  checked = slice(payload, 0, expectedSize)
  endian.writeU32LE(checked, checksumOffset, 0)
  if crc32c.compute(checked) != storedChecksum then return fail(WRITE_FENCED, operation, "fencing record checksum mismatch") end if
  return true
end function

// Decodes the persistent database term and node identity.
function readLeaderEpoch(path)
  payload = try(readFenceBytes(path, LEADER_EPOCH_BYTES, "readLeaderEpoch"))
  if typeof(payload) == "error" then return payload end if
  valid = try(validateFenceHeader(payload, "MSHAE001", LEADER_EPOCH_BYTES, "readLeaderEpoch"))
  if typeof(valid) == "error" then return valid end if
  epoch = try(endian.uint64ToInt(endian.readU64LE(payload, 12)))
  nodeId = try(endian.uint64ToInt(endian.readU64LE(payload, 20)))
  if typeof(epoch) == "error" or typeof(nodeId) == "error" or epoch < 1 or nodeId < 1 then return fail(WRITE_FENCED, "readLeaderEpoch", "epoch and node identity must be positive native integers") end if
  return [epoch, nodeId]
end function

// Decodes the shared leader lease used as the online write-authority token.
function readLeaderLease(path)
  payload = try(readFenceBytes(path, LEADER_LEASE_BYTES, "readLeaderLease"))
  if typeof(payload) == "error" then return payload end if
  valid = try(validateFenceHeader(payload, "MSHAL001", LEADER_LEASE_BYTES, "readLeaderLease"))
  if typeof(valid) == "error" then return valid end if
  epoch = try(endian.uint64ToInt(endian.readU64LE(payload, 12)))
  nodeId = try(endian.uint64ToInt(endian.readU64LE(payload, 20)))
  expiresAt = try(endian.uint64ToInt(endian.readU64LE(payload, 28)))
  if typeof(epoch) == "error" or typeof(nodeId) == "error" or typeof(expiresAt) == "error" then return fail(WRITE_FENCED, "readLeaderLease", "lease values exceed native integer range") end if
  return [epoch, nodeId, expiresAt]
end function

// Returns the persistent marker path that selects bounded-WAL epoch recovery.
function walEpochPath(path)
  return catalog.joinPath(catalog.joinPath(path, "wal"), "wal.epoch")
end function

// Returns the transient crash-recovery journal for an in-progress WAL reset.
function walResetPendingPath(path)
  return catalog.joinPath(catalog.joinPath(path, "wal"), "wal.reset.pending")
end function

// Encodes an eight-byte marker magic and the database identity into one small,
// self-identifying durable record.
function checkpointMarkerBytes(magic, databaseId)
  if typeof(magic) != "bytes" or len(magic) != 8 then return fail(INVALID_ARGUMENT, "checkpointMarkerBytes", "magic must contain eight bytes") end if
  if typeof(databaseId) != "bytes" or len(databaseId) != 16 then return fail(INVALID_ARGUMENT, "checkpointMarkerBytes", "databaseId must contain sixteen bytes") end if
  output = bytes(CHECKPOINT_MARKER_BYTES, 0)
  for index = 0 to 7
    output[index] = magic[index]
  end for
  for index = 0 to 15
    output[8 + index] = databaseId[index]
  end for
  return output
end function

// Reads and validates a checkpoint marker before its state can affect recovery.
function validateCheckpointMarker(path, expected)
  if not file_api.fileExists(path) then return false end if
  handle = try(file_api.openRead(path))
  if typeof(handle) == "error" then return handle end if
  if file_api.size(handle) != len(expected) then file_api.close(handle); return fail(CORRUPT_DATA, "validateCheckpointMarker", "checkpoint marker size mismatch: " + path) end if
  actual = bytes(len(expected), 0)
  read = try(file_api.readExactAt(handle, 0, actual, 0, len(actual)))
  closed = try(file_api.close(handle))
  if typeof(read) == "error" then return read end if
  if typeof(closed) == "error" then return closed end if
  if not bytesEqual(actual, expected) then return fail(CORRUPT_DATA, "validateCheckpointMarker", "checkpoint marker identity mismatch: " + path) end if
  return true
end function

// Creates a marker durably or validates an already durable retry instance.
function ensureCheckpointMarker(path, expected)
  existing = try(validateCheckpointMarker(path, expected))
  if typeof(existing) == "error" then return existing end if
  if existing then return true end if
  handle = try(file_api.createNewDurable(path))
  if typeof(handle) == "error" then return handle end if
  written = try(file_api.writeAt(handle, 0, expected, 0, len(expected)))
  flushed = void
  if typeof(written) != "error" then flushed = try(file_api.flush(handle)) end if
  closed = try(file_api.close(handle))
  if typeof(written) == "error" then return written end if
  if typeof(flushed) == "error" then return flushed end if
  if typeof(closed) == "error" then return closed end if
  return true
end function


// Closes recovery files using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function closeRecoveryFiles(files)
  for each current in files
    ignored = try(paged_file.close(current))
  end for
  return true
end function

// Validates open using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function validateOpen(database, operation)
  if database is not ManagedDatabase then return fail(INVALID_ARGUMENT, operation, "database must be ManagedDatabase") end if
  if database.closed then return fail(CLOSED_HANDLE, operation, "database is closed") end if
  return true
end function

// Creates a writer-prioritized gate in the empty state.
// Returns the gate or a threading error after closing any partially created primitive.
function createExecutionGate()
  stateLock = threading.Lock.new()
  turnstile = try(threading.Semaphore.new(1, 1))
  if typeof(turnstile) == "error" then stateLock.close(); return turnstile end if
  roomEmpty = try(threading.Semaphore.new(1, 1))
  if typeof(roomEmpty) == "error" then turnstile.close(); stateLock.close(); return roomEmpty end if
  return ExecutionGate(stateLock, turnstile, roomEmpty, 0, 0)
end function

// Creates an empty persistent read-handle registry. Handles are opened lazily
// so databases with many cold tables consume no native handle resources.
function createReadHandleCache()
  guard = threading.Lock.new()
  if typeof(guard) == "error" then return guard end if
  return ReadHandleCache(hashmap.HashMap.withCapacity(64), hashmap.HashMap.withCapacity(64), guard, 0, 0, 0, 0, list.List.new(), 0, false)
end function

// Validates a caller lease and returns its storage value.
function readHandleValue(lease)
  if lease is not ReadHandleLease or lease.released then return fail(INVALID_ARGUMENT, "readHandleValue", "lease must be active") end if
  return lease.entry.value
end function

// Returns one context reused by every page read in this handle lease. Table
// scans that remain entirely in the buffer pool never allocate the context.
function readHandleContext(lease)
  if lease is not ReadHandleLease or lease.released then return fail(INVALID_ARGUMENT, "readHandleContext", "lease must be active") end if
#if TARGET_OS == "windows"
  if lease.readContext is void then
    cache = lease.cache
    created = void
    if not cache.guard.acquire() then return fail(CLOSED_HANDLE, "readHandleContext", "registry guard is unavailable") end if
    if cache.availableReadContexts.len() > 0 then
      lease.readContext = cache.availableReadContexts.pop()
    else
      created = try(file_api.createReadContext())
      if typeof(created) != "error" then
        cache.readContextCount = cache.readContextCount + 1
        lease.readContext = created
      end if
    end if
    cache.guard.release()
    if typeof(created) == "error" then return created end if
  end if
  return lease.readContext
#else
  // Linux pread has no per-operation kernel event to amortize.
  return void
#endif
end function

// Releases one table or index lease after the complete storage operation. The
// owning execution-gate read lease prevents concurrent invalidation.
function releaseReadHandle(lease)
  if lease is not ReadHandleLease or lease.released then return fail(INVALID_ARGUMENT, "releaseReadHandle", "lease must be active") end if
  if not lease.cache.guard.acquire() then return fail(CLOSED_HANDLE, "releaseReadHandle", "registry guard is unavailable") end if
  if lease.cache.activeLeases <= 0 then lease.cache.guard.release(); return fail(CORRUPT_DATA, "releaseReadHandle", "active lease counter underflow") end if
  if lease.readContext is not void then
    lease.cache.availableReadContexts.add(lease.readContext)
    lease.readContext = void
  end if
  lease.cache.activeLeases = lease.cache.activeLeases - 1
  lease.released = true
  lease.cache.guard.release()
  return true
end function

// Records one lease while the registry guard is held and returns its token.
function publishReadHandleLease(cache, entry)
  cache.activeLeases = cache.activeLeases + 1
  if cache.activeLeases > cache.peakLeases then cache.peakLeases = cache.activeLeases end if
  return ReadHandleLease(cache, entry, void, false)
end function

// Acquires or lazily opens one persistent read-only index tree. The registry
// guard prevents duplicate publication; explicit-offset native reads require no
// per-query lock after the immutable tree has been published.
function acquireIndexReadHandle(database, path)
  validateOpen(database, "acquireIndexReadHandle")
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "acquireIndexReadHandle", "path must be non-empty") end if
  cache = database.readHandles
  if cache.closed then return fail(CLOSED_HANDLE, "acquireIndexReadHandle", "read-handle cache is closed") end if
  if not cache.guard.acquire() then return fail(CLOSED_HANDLE, "acquireIndexReadHandle", "registry guard is unavailable") end if
  entry = cache.indexes.get(path)
  if entry is void then
    tree = try(btree.openReadOnlyForManagedLookup(path))
    if typeof(tree) == "error" then cache.guard.release(); return tree end if
    entry = CachedReadHandle(path, tree, true)
    cache.indexes.set(path, entry)
    cache.misses = cache.misses + 1
  else
    cache.hits = cache.hits + 1
  end if
  lease = publishReadHandleLease(cache, entry)
  cache.guard.release()
  return lease
end function

// Acquires or lazily opens one persistent read-only table PagedFile.
function acquireTableReadHandle(database, path)
  validateOpen(database, "acquireTableReadHandle")
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "acquireTableReadHandle", "path must be non-empty") end if
  cache = database.readHandles
  if cache.closed then return fail(CLOSED_HANDLE, "acquireTableReadHandle", "read-handle cache is closed") end if
  if not cache.guard.acquire() then return fail(CLOSED_HANDLE, "acquireTableReadHandle", "registry guard is unavailable") end if
  entry = cache.tables.get(path)
  if entry is void then
    tableFile = try(paged_file.openReadOnlyManaged(path))
    if typeof(tableFile) == "error" then cache.guard.release(); return tableFile end if
    entry = CachedReadHandle(path, tableFile, false)
    cache.tables.set(path, entry)
    cache.misses = cache.misses + 1
  else
    cache.hits = cache.hits + 1
  end if
  lease = publishReadHandleLease(cache, entry)
  cache.guard.release()
  return lease
end function

// Closes every entry in one raw HashMap while the registry and writer gates are
// held. Iterating occupied slots avoids allocating a temporary values array.
function closeReadHandleMap(values)
  closed = 0
  if values.cap > 0 then
    for index = 0 to values.cap - 1
      if values.states[index] == 1 then
        entry = values.values[index]
        if entry.indexHandle then ignoredClose = try(btree.close(entry.value)) else ignoredClose = try(paged_file.close(entry.value)) end if
        closed = closed + 1
      end if
    end for
  end if
  values.clear()
  return closed
end function

// Invalidates persistent file and metadata handles after any successful writer.
// The caller owns the database writer gate, so no active lease can race close.
function invalidateReadHandles(database)
  validateOpen(database, "invalidateReadHandles")
  cache = database.readHandles
  if cache.closed then return fail(CLOSED_HANDLE, "invalidateReadHandles", "read-handle cache is closed") end if
  if not cache.guard.acquire() then return fail(CLOSED_HANDLE, "invalidateReadHandles", "registry guard is unavailable") end if
  closed = closeReadHandleMap(cache.tables) + closeReadHandleMap(cache.indexes)
  cache.guard.release()
  return closed
end function

// Returns synchronized persistent-handle cache counters.
function readHandleStats(database)
  validateOpen(database, "readHandleStats")
  cache = database.readHandles
  if cache.closed then return fail(CLOSED_HANDLE, "readHandleStats", "read-handle cache is closed") end if
  if not cache.guard.acquire() then return fail(CLOSED_HANDLE, "readHandleStats", "registry guard is unavailable") end if
  result = ReadHandleCacheStats(cache.hits, cache.misses, cache.tables.count(), cache.indexes.count(), cache.activeLeases, cache.peakLeases, cache.readContextCount, cache.availableReadContexts.len())
  cache.guard.release()
  return result
end function

// Permanently closes the database-owned registry during database shutdown.
function closeReadHandleCache(database)
  cache = database.readHandles
  if cache.closed then return true end if
  if not cache.guard.acquire() then return fail(CLOSED_HANDLE, "closeReadHandleCache", "registry guard is unavailable") end if
  closeReadHandleMap(cache.tables)
  closeReadHandleMap(cache.indexes)
  while cache.availableReadContexts.len() > 0
    ignoredContextClose = try(file_api.closeReadContext(cache.availableReadContexts.pop()))
  end while
  cache.closed = true
  cache.guard.release()
  cache.guard.close()
  return true
end function

// Admits one shared reader through the writer-priority turnstile.
// The first reader acquires `roomEmpty`; later readers only increment the
// protected count. Returns true or an unavailable/closed-gate error.
function enterReadExecution(database)
  validateOpen(database, "enterReadExecution")
  gate = database.executionGate
  if not gate.turnstile.acquire() then return fail(CLOSED_HANDLE, "enterReadExecution", "database execution gate is unavailable") end if
  gate.turnstile.release()
  if not gate.stateLock.acquire() then return fail(CLOSED_HANDLE, "enterReadExecution", "database execution state is unavailable") end if
  gate.readers = gate.readers + 1
  if gate.readers == 1 and not gate.roomEmpty.acquire() then
    gate.readers = gate.readers - 1
    gate.stateLock.release()
    return fail(CLOSED_HANDLE, "enterReadExecution", "database read gate is unavailable")
  end if
  if gate.readers > gate.peakReaders then gate.peakReaders = gate.readers end if
  gate.stateLock.release()
  return true
end function

// Cancellation-aware shared-gate admission for SQL statements. Short timed
// waits keep administrative cancellation and the absolute statement deadline
// observable even while a writer currently owns the physical database gate.
function enterReadExecutionControlled(database, sessionId)
  validateOpen(database, "enterReadExecutionControlled")
  gate = database.executionGate
  while not gate.turnstile.acquireFor(10)
    control = try(pollSessionControl(database, sessionId))
    if typeof(control) == "error" then return control end if
  end while
  while not gate.stateLock.acquireFor(10)
    control = try(pollSessionControl(database, sessionId))
    if typeof(control) == "error" then gate.turnstile.release(); return control end if
  end while
  // Owning turnstile excludes every writer transition. Therefore roomEmpty is
  // immediately available when this is the first reader; later readers share
  // the room already owned by the first and never wait on its semaphore.
  if gate.readers == 0 and not gate.roomEmpty.tryAcquire() then
    gate.stateLock.release()
    gate.turnstile.release()
    return fail(CLOSED_HANDLE, "enterReadExecutionControlled", "database read gate is unavailable")
  end if
  gate.readers = gate.readers + 1
  if gate.readers > gate.peakReaders then gate.peakReaders = gate.readers end if
  gate.stateLock.release()
  gate.turnstile.release()
  return true
end function

// Removes one shared reader and releases `roomEmpty` when the last reader exits.
// Returns an error for an invalid database, unavailable lock, or unbalanced leave.
function leaveReadExecution(database)
  if database is not ManagedDatabase then return fail(INVALID_ARGUMENT, "leaveReadExecution", "database must be ManagedDatabase") end if
  gate = database.executionGate
  if not gate.stateLock.acquire() then return fail(CLOSED_HANDLE, "leaveReadExecution", "database execution state is unavailable") end if
  if gate.readers <= 0 then
    gate.stateLock.release()
    return fail(INVALID_ARGUMENT, "leaveReadExecution", "database has no active reader")
  end if
  gate.readers = gate.readers - 1
  lastReader = gate.readers == 0
  if lastReader then gate.roomEmpty.release() end if
  gate.stateLock.release()
  return true
end function

// Backward-compatible names denote exclusive engine execution. Authentication,
// session lifecycle and every mutating SQL statement use this writer path.
// Acquires exclusive database execution in writer-priority order.
// Holding the turnstile while waiting for `roomEmpty` blocks newly arriving
// readers, so a sustained read workload cannot starve mutations.
function enterExecution(database)
  validateOpen(database, "enterExecution")
  gate = database.executionGate
  if not gate.turnstile.acquire() then return fail(CLOSED_HANDLE, "enterExecution", "database execution gate is unavailable") end if
  if not gate.roomEmpty.acquire() then
    gate.turnstile.release()
    return fail(CLOSED_HANDLE, "enterExecution", "database write gate is unavailable")
  end if
  return true
end function

// Cancellation-aware exclusive admission. The writer retains turnstile while
// waiting for readers to leave, preserving writer priority between timed polls.
function enterExecutionControlled(database, sessionId)
  validateOpen(database, "enterExecutionControlled")
  gate = database.executionGate
  while not gate.turnstile.acquireFor(10)
    control = try(pollSessionControl(database, sessionId))
    if typeof(control) == "error" then return control end if
  end while
  while not gate.roomEmpty.acquireFor(10)
    control = try(pollSessionControl(database, sessionId))
    if typeof(control) == "error" then gate.turnstile.release(); return control end if
  end while
  return true
end function

// Releases exclusive database execution, opening the room before the turnstile.
// Returns an error if either synchronization primitive cannot be released.
function leaveExecution(database)
  if database is not ManagedDatabase then return fail(INVALID_ARGUMENT, "leaveExecution", "database must be ManagedDatabase") end if
  gate = database.executionGate
  roomReleased = gate.roomEmpty.release()
  turnstileReleased = gate.turnstile.release()
  if not roomReleased or not turnstileReleased then return fail(CLOSED_HANDLE, "leaveExecution", "database execution gate could not be released") end if
  return true
end function

// Implements peak concurrent readers for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function peakConcurrentReaders(database)
  validateOpen(database, "peakConcurrentReaders")
  gate = database.executionGate
  if not gate.stateLock.acquire() then return fail(CLOSED_HANDLE, "peakConcurrentReaders", "database execution state is unavailable") end if
  value = gate.peakReaders
  gate.stateLock.release()
  return value
end function

// Returns the number of readers currently admitted through the physical
// execution gate. This diagnostic is safe while sessions are still active.
function activeConcurrentReaders(database)
  validateOpen(database, "activeConcurrentReaders")
  gate = database.executionGate
  if not gate.stateLock.acquire() then return fail(CLOSED_HANDLE, "activeConcurrentReaders", "database execution state is unavailable") end if
  value = gate.readers
  gate.stateLock.release()
  return value
end function

// Resets peak concurrent readers using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function resetPeakConcurrentReaders(database)
  validateOpen(database, "resetPeakConcurrentReaders")
  gate = database.executionGate
  if not gate.stateLock.acquire() then return fail(CLOSED_HANDLE, "resetPeakConcurrentReaders", "database execution state is unavailable") end if
  if gate.readers != 0 then
    gate.stateLock.release()
    return fail(INVALID_ARGUMENT, "resetPeakConcurrentReaders", "cannot reset while readers are active")
  end if
  gate.peakReaders = 0
  gate.stateLock.release()
  return true
end function

// Opens internal using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function openInternal(path, allowStandby, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "open", "path must be non-empty") end if
  if typeof(allowStandby) != "bool" then return fail(INVALID_ARGUMENT, "open", "allowStandby must be bool") end if
  if typeof(checkpointWalBytes) != "int" or checkpointWalBytes < 4096 then return fail(INVALID_ARGUMENT, "open", "checkpointWalBytes must be at least 4096") end if
  if typeof(bufferPoolBytes) != "int" or bufferPoolBytes < 4096 then return fail(INVALID_ARGUMENT, "open", "bufferPoolBytes must be at least one 4096-byte page") end if
  if typeof(queryMemoryBytes) != "int" or queryMemoryBytes < 1048576 then return fail(INVALID_ARGUMENT, "open", "queryMemoryBytes must be at least 1 MiB") end if
  ignoredLog = logger.debug("minisql.server.database_manager.openInternal", "opening database path=" + path + " standbyAllowed=" + allowStandby)
  standbyMarker = file_api.fileExists(catalog.joinPath(path, "standby.state"))
  if standbyMarker and not allowStandby then return fail(STANDBY_NOT_PROMOTED, "open", "standby is not promoted") end if
  if allowStandby and not standbyMarker then return fail(INVALID_ARGUMENT, "openStandby", "standby.state is missing") end if
  lockPath = catalog.joinPath(path, "db.lock")
  lockFile = file_api.openReadWrite(lockPath, false)
  lockToken = try(file_lock.acquireExclusive(lockFile, true))
  if typeof(lockToken) == "error" then file_api.close(lockFile); return lockToken end if

  maintenance = try(schema_history.recoverMaintenance(path))
  if typeof(maintenance) == "error" then
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return maintenance
  end if

  pending = try(schema_history.recoverPending(path))
  if typeof(pending) == "error" then
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return pending
  end if

  catalogHandle = try(catalog.openDatabase(path))
  if typeof(catalogHandle) == "error" then
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return catalogHandle
  end if

  // Initialize every file a read-only statement may consult before publishing
  // the database to worker threads. SELECT never creates schema or temp state.
  schemaState = try(schema_history.loadOrCreate(path, catalogHandle.metadata.databaseId))
  if typeof(schemaState) == "error" then
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return schemaState
  end if
  temporaryPath = catalog.joinPath(path, "tmp")
  if not file_api.directoryExists(temporaryPath) then
    createdTemporary = try(file_api.createDirectory(temporaryPath))
    if typeof(createdTemporary) == "error" then
      catalog.close(catalogHandle)
      file_lock.release(lockToken)
      file_api.close(lockFile)
      return createdTemporary
    end if
  end if

  walPath = catalog.joinPath(catalog.joinPath(path, "wal"), "wal.log")
  walWriter = try(wal.open(walPath, catalogHandle.metadata.walSegmentBytes))
  if typeof(walWriter) == "error" then
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return walWriter
  end if

  checkpointPath = catalog.joinPath(catalog.joinPath(path, "wal"), "checkpoint.meta")
  checkpointFile = try(checkpoint.open(checkpointPath))
  if typeof(checkpointFile) == "error" then
    wal.close(walWriter)
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return checkpointFile
  end if
  if not bytesEqual(checkpointFile.metadata.databaseId, catalogHandle.metadata.databaseId) then
    checkpoint.close(checkpointFile)
    wal.close(walWriter)
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return fail(CORRUPT_DATA, "open", "checkpoint belongs to another database")
  end if

  epochMarker = checkpointMarkerBytes(bytes("MSWEP001"), catalogHandle.metadata.databaseId)
  pendingMarker = checkpointMarkerBytes(bytes("MSWRP001"), catalogHandle.metadata.databaseId)
  epochActive = try(validateCheckpointMarker(walEpochPath(path), epochMarker))
  if typeof(epochActive) == "error" then
    checkpoint.close(checkpointFile)
    wal.close(walWriter)
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return epochActive
  end if
  pendingReset = try(validateCheckpointMarker(walResetPendingPath(path), pendingMarker))
  if typeof(pendingReset) == "error" then
    checkpoint.close(checkpointFile)
    wal.close(walWriter)
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return pendingReset
  end if
  if pendingReset then
    // The pending marker is created only after every preceding committed page
    // publication is durable. Completing the reset is therefore safe whether
    // the previous process stopped before or after truncating the WAL.
    epochEnsured = try(ensureCheckpointMarker(walEpochPath(path), epochMarker))
    if typeof(epochEnsured) == "error" then
      checkpoint.close(checkpointFile); wal.close(walWriter); catalog.close(catalogHandle); file_lock.release(lockToken); file_api.close(lockFile)
      return epochEnsured
    end if
    rewound = try(wal.rewind(walWriter, 0))
    if typeof(rewound) == "error" then
      checkpoint.close(checkpointFile); wal.close(walWriter); catalog.close(catalogHandle); file_lock.release(lockToken); file_api.close(lockFile)
      return rewound
    end if
    resetCheckpoint = try(checkpoint.publish(checkpointFile, 0, 0, 0))
    if typeof(resetCheckpoint) == "error" then
      checkpoint.close(checkpointFile); wal.close(walWriter); catalog.close(catalogHandle); file_lock.release(lockToken); file_api.close(lockFile)
      return resetCheckpoint
    end if
    catalogHandle.metadata.checkpointLsn = 0
    persistedCatalog = try(catalog.persistMetadata(catalogHandle))
    if typeof(persistedCatalog) == "error" then
      checkpoint.close(checkpointFile); wal.close(walWriter); catalog.close(catalogHandle); file_lock.release(lockToken); file_api.close(lockFile)
      return persistedCatalog
    end if
    removedPending = try(file_api.deletePath(walResetPendingPath(path)))
    if typeof(removedPending) == "error" then
      checkpoint.close(checkpointFile); wal.close(walWriter); catalog.close(catalogHandle); file_lock.release(lockToken); file_api.close(lockFile)
      return removedPending
    end if
    epochActive = true
    ignoredResetLog = logger.warning("minisql.server.database_manager.openInternal", "completed interrupted WAL checkpoint reset path=" + path)
  end if

  // Complete committed table-page writes before the database is exposed to a
  // session. Catalog/DDL WAL integration is introduced with transactional DDL;
  // M7 recovery currently targets all catalog-listed table files.
  recoveryFiles = []
  recoveryTargets = []
  recoveryTargetIds = hashmap.HashMap.new()
  for each table in catalogHandle.catalog.tables
    tableFile = try(paged_file.open(catalog.tableFilePath(path, table.tableId)))
    if typeof(tableFile) == "error" then
      closeRecoveryFiles(recoveryFiles)
      checkpoint.close(checkpointFile)
      wal.close(walWriter)
      catalog.close(catalogHandle)
      file_lock.release(lockToken)
      file_api.close(lockFile)
      return tableFile
    end if
    recoveryFiles = recoveryFiles + [tableFile]
    recoveryTargets = recoveryTargets + [recovery.target(table.tableId, tableFile)]
    recoveryTargetIds.set(table.tableId, true)
  end for
  // Scan once, then classify historical page images whose object IDs were
  // allocated but are absent from the current durable catalog. Such IDs belong
  // to dropped table files: object IDs start at three, are never reused, and all
  // live tables were added above. Explicit retired targets prevent old WAL from
  // resurrecting deleted data while preserving strict errors for unknown IDs.
  recoveryScan = try(wal.scan(walWriter, true))
  if typeof(recoveryScan) == "error" then
    closeRecoveryFiles(recoveryFiles)
    checkpoint.close(checkpointFile)
    wal.close(walWriter)
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return recoveryScan
  end if
  retiredRecoveryTargets = 0
  for each record in recoveryScan.records
    if record.recordType == wal.RECORD_PAGE_IMAGE and not recoveryTargetIds.has(record.fileId) and record.fileId >= 3 and record.fileId < catalogHandle.metadata.nextObjectId then
      recoveryTargets = recoveryTargets + [recovery.retiredTarget(record.fileId)]
      recoveryTargetIds.set(record.fileId, true)
      retiredRecoveryTargets = retiredRecoveryTargets + 1
    end if
  end for
  recoveryResult = void
  if epochActive then
    recoveryResult = try(recovery.recoverScanForced(recoveryScan, recoveryTargets))
  else
    recoveryResult = try(recovery.recoverScan(recoveryScan, recoveryTargets, checkpointFile.metadata.redoStartLsn))
  end if
  closeRecoveryFiles(recoveryFiles)
  if typeof(recoveryResult) == "error" then
    checkpoint.close(checkpointFile)
    wal.close(walWriter)
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return recoveryResult
  end if
  // A live WAL archive intentionally ships table-page WAL, not concurrently
  // rewritten catalog metadata. Advance the allocator past every recovered
  // transaction before a promoted standby can accept a new writer; otherwise
  // it could reuse an archived transaction ID and create duplicate TX_BEGIN.
  maximumRecoveredTransactionId = 0
  for each record in recoveryScan.records
    if record.transactionId > maximumRecoveredTransactionId then maximumRecoveredTransactionId = record.transactionId end if
  end for
  if catalogHandle.metadata.nextTransactionId <= maximumRecoveredTransactionId then
    catalogHandle.metadata.nextTransactionId = maximumRecoveredTransactionId + 1
    synchronizedIds = try(catalog.persistMetadata(catalogHandle))
    if typeof(synchronizedIds) == "error" then
      checkpoint.close(checkpointFile); wal.close(walWriter); catalog.close(catalogHandle); file_lock.release(lockToken); file_api.close(lockFile)
      return synchronizedIds
    end if
  end if
  if retiredRecoveryTargets > 0 then
    ignoredRetiredLog = logger.info("minisql.server.database_manager.openInternal", "recovery skipped historical WAL for retired table files=" + retiredRecoveryTargets)
  end if

  auditLog = try(diagnostics.openAudit(path))
  if typeof(auditLog) == "error" then
    checkpoint.close(checkpointFile)
    wal.close(walWriter)
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return auditLog
  end if
  executionGate = try(createExecutionGate())
  if typeof(executionGate) == "error" then
    diagnostics.closeAudit(auditLog)
    checkpoint.close(checkpointFile)
    wal.close(walWriter)
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return executionGate
  end if
  readCache = try(buffer_pool.createReadCache(bufferPoolBytes, catalogHandle.metadata.pageSize))
  if typeof(readCache) == "error" then
    executionGate.roomEmpty.close(); executionGate.turnstile.close(); executionGate.stateLock.close()
    diagnostics.closeAudit(auditLog); checkpoint.close(checkpointFile); wal.close(walWriter); catalog.close(catalogHandle); file_lock.release(lockToken); file_api.close(lockFile)
    return readCache
  end if
  readHandles = try(createReadHandleCache())
  if typeof(readHandles) == "error" then
    buffer_pool.closeReadCache(readCache); executionGate.roomEmpty.close(); executionGate.turnstile.close(); executionGate.stateLock.close()
    diagnostics.closeAudit(auditLog); checkpoint.close(checkpointFile); wal.close(walWriter); catalog.close(catalogHandle); file_lock.release(lockToken); file_api.close(lockFile)
    return readHandles
  end if
  opened = ManagedDatabase(path, catalogHandle, schemaState, lockFile, lockToken, walWriter, checkpointFile, recoveryResult, lock_manager.create(), 1, auditLog, standbyMarker, executionGate, checkpointWalBytes, epochActive, 0, readCache, readHandles, false, 0, queryMemoryBytes, [], clock.monotonicMilliseconds(), 0, 0, 0, 0, false, DEFAULT_MAX_STATEMENT_BYTES, DEFAULT_MAX_FRAME_BYTES, DEFAULT_MAX_RESULT_ROWS, DEFAULT_IDLE_TIMEOUT_MS, DEFAULT_QUERY_TIMEOUT_MS, DEFAULT_MAX_RESULT_BYTES, DEFAULT_PROCESS_MEMORY_BYTES, DEFAULT_TEMPORARY_STORAGE_BYTES, 0, 0, 0, 0, 0, 0, 0, 0, DEFAULT_SLOW_QUERY_MS, 0, false, "", 0, 0, 0, 0, false)
  ignoredLog = logger.info("minisql.server.database_manager.openInternal", "database opened path=" + path + " tables=" + len(catalogHandle.catalog.tables) + " recoveryPages=" + recoveryResult.pagesRedone)
  return opened
end function

// Opens open using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function open(path)
  return openInternal(path, false, DEFAULT_CHECKPOINT_WAL_BYTES, DEFAULT_BUFFER_POOL_BYTES, DEFAULT_QUERY_MEMORY_BYTES)
end function

// Opens a primary database with a configured maximum current-WAL size.
function openWithCheckpoint(path, checkpointWalBytes)
  return openInternal(path, false, checkpointWalBytes, DEFAULT_BUFFER_POOL_BYTES, DEFAULT_QUERY_MEMORY_BYTES)
end function

// Opens a primary database with configured WAL and buffer-pool budgets.
function openWithRuntime(path, checkpointWalBytes, bufferPoolBytes)
  return openInternal(path, false, checkpointWalBytes, bufferPoolBytes, DEFAULT_QUERY_MEMORY_BYTES)
end function

// Opens a writable database with explicit WAL, cache, and per-query budgets.
function openWithBudgets(path, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  return openInternal(path, false, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
end function

// Opens standby using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function openStandby(path)
  return openInternal(path, true, DEFAULT_CHECKPOINT_WAL_BYTES, DEFAULT_BUFFER_POOL_BYTES, DEFAULT_QUERY_MEMORY_BYTES)
end function

// Opens a standby with the configured checkpoint threshold. Standbys never
// initiate a reset, but retaining the value keeps promotion configuration exact.
function openStandbyWithCheckpoint(path, checkpointWalBytes)
  return openInternal(path, true, checkpointWalBytes, DEFAULT_BUFFER_POOL_BYTES, DEFAULT_QUERY_MEMORY_BYTES)
end function

// Opens a standby with configured WAL and buffer-pool budgets.
function openStandbyWithRuntime(path, checkpointWalBytes, bufferPoolBytes)
  return openInternal(path, true, checkpointWalBytes, bufferPoolBytes, DEFAULT_QUERY_MEMORY_BYTES)
end function

// Opens a standby database with explicit WAL, cache, and per-query budgets.
function openStandbyWithBudgets(path, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  return openInternal(path, true, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
end function

// Returns the soft blocking-operator budget inherited by a new session.
function queryMemoryLimit(database)
  validateOpen(database, "queryMemoryLimit")
  return database.queryMemoryBytes
end function

// Configures the per-session query budget before a listener accepts clients.
function setQueryMemoryLimit(database, queryMemoryBytes)
  validateOpen(database, "setQueryMemoryLimit")
  if typeof(queryMemoryBytes) != "int" or queryMemoryBytes < 1048576 then return fail(INVALID_ARGUMENT, "setQueryMemoryLimit", "queryMemoryBytes must be at least 1 MiB") end if
  database.queryMemoryBytes = queryMemoryBytes
  return true
end function

// Enables controller-backed write fencing for this process. Startup fails
// closed unless the persistent database term exactly matches the process term;
// this prevents an old command line from restarting a retired primary.
function configureWriteFencing(database, leasePath, epoch, nodeId, clockSkewMs)
  validateOpen(database, "configureWriteFencing")
  if database.standby then return fail(INVALID_ARGUMENT, "configureWriteFencing", "a read-only standby cannot own a write lease") end if
  if typeof(leasePath) != "string" or len(leasePath) == 0 then return fail(INVALID_ARGUMENT, "configureWriteFencing", "leasePath must be non-empty") end if
  if typeof(epoch) != "int" or epoch < 1 then return fail(INVALID_ARGUMENT, "configureWriteFencing", "epoch must be positive") end if
  if typeof(nodeId) != "int" or nodeId < 1 then return fail(INVALID_ARGUMENT, "configureWriteFencing", "nodeId must be positive") end if
  if typeof(clockSkewMs) != "int" or clockSkewMs < 0 or clockSkewMs > 60000 then return fail(INVALID_ARGUMENT, "configureWriteFencing", "clockSkewMs must be between zero and 60000") end if
  persistent = try(readLeaderEpoch(leaderEpochPath(database.path)))
  if typeof(persistent) == "error" then return persistent end if
  if persistent[0] != epoch or persistent[1] != nodeId then return fail(WRITE_FENCED, "configureWriteFencing", "persistent leader epoch does not match this process") end if
  database.fencingLeasePath = leasePath
  database.fencingEpoch = epoch
  database.fencingNodeId = nodeId
  database.fencingClockSkewMs = clockSkewMs
  database.fencingEnabled = true
  initial = try(validateWriteFence(database))
  if typeof(initial) == "error" then database.fencingEnabled = false; return initial end if
  ignoredLog = logger.info("minisql.server.database_manager.configureWriteFencing", "write fencing enabled epoch=" + epoch + " node=" + nodeId + " lease=" + leasePath)
  return true
end function

// Validates persistent and live leadership immediately before a mutation or
// durable commit. Missing, malformed, expired, foreign, and rolled-back terms
// all reject writes while reads and rollback remain available.
function validateWriteFence(database)
  validateOpen(database, "validateWriteFence")
  if not database.fencingEnabled then return true end if
  persistent = try(readLeaderEpoch(leaderEpochPath(database.path)))
  lease = void
  if typeof(persistent) != "error" then lease = try(readLeaderLease(database.fencingLeasePath)) end if
  now = time_api.datetime.nowUnixMillisUtc()
  accepted = typeof(persistent) != "error" and typeof(lease) != "error" and now is not void
  if accepted then
    accepted = persistent[0] == database.fencingEpoch and persistent[1] == database.fencingNodeId and lease[0] == database.fencingEpoch and lease[1] == database.fencingNodeId and lease[2] - database.fencingClockSkewMs > now
  end if
  if accepted then return true end if
  database.fencingRejections = database.fencingRejections + 1
  ignoredLog = logger.warning("minisql.server.database_manager.validateWriteFence", "write rejected by leader fence epoch=" + database.fencingEpoch + " node=" + database.fencingNodeId)
  return fail(WRITE_FENCED, "validateWriteFence", "write authority is missing, expired, or belongs to another leader")
end function

// Creates create using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function create(dataRoot, name, defaults)
  created = catalog.createDatabase(dataRoot, name, defaults)
  path = created.path
  catalog.close(created)
  ignoredLog = logger.info("minisql.server.database_manager.create", "database created name=" + name + " path=" + path)
  return open(path)
end function

// Implements begin for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function begin(database, isolationLevel, readOnly)
  validateOpen(database, "begin")
  transactionId = catalog.allocateTransactionId(database.catalogHandle)
  return transaction.beginTransaction(transactionId, isolationLevel, readOnly, database.walWriter)
end function


// Implements allocate session identifier for this module.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function allocateSessionId(database)
  validateOpen(database, "allocateSessionId")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "allocateSessionId", "database execution state is unavailable") end if
  value = database.nextSessionId
  database.nextSessionId = database.nextSessionId + 1
  if database.nextSessionId <= 0 then database.nextSessionId = 1 end if
  now = clock.monotonicMilliseconds()
  database.sessions = database.sessions + [OperationalSession(value, "embedded", false, 1, now, now, 0, "", "IDLE", 0, false)]
  database.totalConnections = database.totalConnections + 1
  database.executionGate.stateLock.release()
  return value
end function

// Applies validated protocol and result limits before the listener accepts clients.
function configureOperationalLimits(database, maxStatementBytes, maxFrameBytes, maxResultRows, idleTimeoutMs)
  validateOpen(database, "configureOperationalLimits")
  if typeof(maxStatementBytes) != "int" or maxStatementBytes < 1024 then return fail(INVALID_ARGUMENT, "configureOperationalLimits", "maxStatementBytes must be at least 1024") end if
  if typeof(maxFrameBytes) != "int" or maxFrameBytes < 1024 or maxFrameBytes > 16777216 then return fail(INVALID_ARGUMENT, "configureOperationalLimits", "maxFrameBytes must be between 1024 and 16777216") end if
  if typeof(maxResultRows) != "int" or maxResultRows < 1 then return fail(INVALID_ARGUMENT, "configureOperationalLimits", "maxResultRows must be positive") end if
  if typeof(idleTimeoutMs) != "int" or idleTimeoutMs < 1000 then return fail(INVALID_ARGUMENT, "configureOperationalLimits", "idleTimeoutMs must be at least 1000") end if
  database.maxStatementBytes = maxStatementBytes
  database.maxFrameBytes = maxFrameBytes
  database.maxResultRows = maxResultRows
  database.idleTimeoutMs = idleTimeoutMs
  return true
end function

// Applies process-wide admission, response, spill, timeout, and slow-query policy.
function configureProductionControls(database, queryTimeoutMs, maxResultBytes, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
  validateOpen(database, "configureProductionControls")
  if typeof(queryTimeoutMs) != "int" or queryTimeoutMs < 1 then return fail(INVALID_ARGUMENT, "configureProductionControls", "queryTimeoutMs must be positive") end if
  if typeof(maxResultBytes) != "int" or maxResultBytes < 1048576 then return fail(INVALID_ARGUMENT, "configureProductionControls", "maxResultBytes must be at least 1 MiB") end if
  if typeof(processMemoryBytes) != "int" or processMemoryBytes < 16777216 then return fail(INVALID_ARGUMENT, "configureProductionControls", "processMemoryBytes must be at least 16 MiB") end if
  if typeof(temporaryStorageBytes) != "int" or temporaryStorageBytes < 1048576 then return fail(INVALID_ARGUMENT, "configureProductionControls", "temporaryStorageBytes must be at least 1 MiB") end if
  if typeof(slowQueryMs) != "int" or slowQueryMs < 1 then return fail(INVALID_ARGUMENT, "configureProductionControls", "slowQueryMs must be positive") end if
  database.queryTimeoutMs = queryTimeoutMs
  database.maxResultBytes = maxResultBytes
  database.processMemoryBytes = processMemoryBytes
  database.temporaryStorageBytes = temporaryStorageBytes
  database.slowQueryMs = slowQueryMs
  return true
end function

// Returns the configured hard statement-size limit.
function maxStatementBytes(database)
  validateOpen(database, "maxStatementBytes")
  return database.maxStatementBytes
end function

// Returns the configured hard response-frame limit.
function maxFrameBytes(database)
  validateOpen(database, "maxFrameBytes")
  return database.maxFrameBytes
end function

// Returns the configured hard result-row limit.
function maxResultRows(database)
  validateOpen(database, "maxResultRows")
  return database.maxResultRows
end function

// Returns the configured idle-connection timeout.
function idleTimeoutMs(database)
  validateOpen(database, "idleTimeoutMs")
  return database.idleTimeoutMs
end function

// Returns the cooperative execution deadline interval.
function queryTimeoutMs(database)
  validateOpen(database, "queryTimeoutMs")
  return database.queryTimeoutMs
end function

// Returns the aggregate encoded result byte ceiling.
function maxResultBytes(database)
  validateOpen(database, "maxResultBytes")
  return database.maxResultBytes
end function

// Rejects new statements before they can amplify an already exhausted heap.
// `heap_bytes_committed` is the runtime's reserved arena and may deliberately
// exceed the policy, so admission is based on live managed bytes instead.
function admitStatement(database)
  validateOpen(database, "admitStatement")
  if heap_bytes_used() < database.processMemoryBytes then return true end if
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "admitStatement", "database execution state is unavailable") end if
  database.resourceRejectedStatements = database.resourceRejectedStatements + 1
  database.executionGate.stateLock.release()
  return fail(RESOURCE_LIMIT, "admitStatement", "managed process heap reached configured processMemoryBytes")
end function

// Enforces the managed-heap ceiling for already admitted work at cooperative
// executor/storage poll boundaries. The terminal statement accounts the single
// resource rejection, avoiding one counter increment per observed boundary.
function enforceProcessMemory(database)
  validateOpen(database, "enforceProcessMemory")
  if heap_bytes_used() < database.processMemoryBytes then return true end if
  return fail(RESOURCE_LIMIT, "enforceProcessMemory", "managed process heap reached configured processMemoryBytes")
end function

// Reserves spill capacity atomically across all concurrent statements.
function reserveTemporaryStorage(database, byteCount)
  validateOpen(database, "reserveTemporaryStorage")
  if typeof(byteCount) != "int" or byteCount < 0 then return fail(INVALID_ARGUMENT, "reserveTemporaryStorage", "byteCount must be non-negative") end if
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "reserveTemporaryStorage", "database execution state is unavailable") end if
  if byteCount > database.temporaryStorageBytes - database.temporaryReservedBytes then
    database.executionGate.stateLock.release()
    return fail(RESOURCE_LIMIT, "reserveTemporaryStorage", "temporary-storage quota exhausted")
  end if
  database.temporaryReservedBytes = database.temporaryReservedBytes + byteCount
  if database.temporaryReservedBytes > database.temporaryPeakBytes then database.temporaryPeakBytes = database.temporaryReservedBytes end if
  database.executionGate.stateLock.release()
  return true
end function

// Releases a prior spill reservation; cleanup is idempotent at zero.
function releaseTemporaryStorage(database, byteCount)
  if not isManagedDatabase(database) or database.closed then return true end if
  if typeof(byteCount) != "int" or byteCount < 0 then return fail(INVALID_ARGUMENT, "releaseTemporaryStorage", "byteCount must be non-negative") end if
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "releaseTemporaryStorage", "database execution state is unavailable") end if
  database.temporaryReservedBytes = database.temporaryReservedBytes - byteCount
  if database.temporaryReservedBytes < 0 then database.temporaryReservedBytes = 0 end if
  database.executionGate.stateLock.release()
  return true
end function

// Updates connection metadata after the listener resolves the remote endpoint.
function registerSessionPeer(database, sessionId, peerEndpoint, secure, authenticated)
  validateOpen(database, "registerSessionPeer")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "registerSessionPeer", "database execution state is unavailable") end if
  for each entry in database.sessions
    if entry.sessionId == sessionId then
      entry.peerEndpoint = peerEndpoint
      entry.secure = secure
      if not authenticated then entry.principalId = 0 end if
    end if
  end for
  database.executionGate.stateLock.release()
  return true
end function

// Publishes the principal selected by a successful authentication exchange.
function setOperationalPrincipal(database, sessionId, principalId)
  validateOpen(database, "setOperationalPrincipal")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "setOperationalPrincipal", "database execution state is unavailable") end if
  for each entry in database.sessions
    if entry.sessionId == sessionId then entry.principalId = principalId end if
  end for
  database.executionGate.stateLock.release()
  return true
end function

// Marks a session as executing and stores only a bounded SQL summary.
function beginOperationalStatement(database, sessionId, principalId, sqlText)
  validateOpen(database, "beginOperationalStatement")
  summary = sqlText
  if len(summary) > 256 then summary = "[statement text exceeds process-list display limit]" end if
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "beginOperationalStatement", "database execution state is unavailable") end if
  now = clock.monotonicMilliseconds()
  for each entry in database.sessions
    if entry.sessionId == sessionId then entry.principalId = principalId; entry.lastActivity = now; entry.statementStartedAt = now; entry.statementText = summary; entry.state = "EXECUTING"; entry.cancelRequested = false end if
  end for
  database.executionGate.stateLock.release()
  return true
end function

// Completes one operational statement and advances cumulative counters.
function finishOperationalStatement(database, sessionId, success, rowCount)
  validateOpen(database, "finishOperationalStatement")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "finishOperationalStatement", "database execution state is unavailable") end if
  now = clock.monotonicMilliseconds()
  for each entry in database.sessions
    if entry.sessionId == sessionId then entry.lastActivity = now; entry.statementStartedAt = 0; entry.statementText = ""; entry.state = "IDLE"; entry.requestCount = entry.requestCount + 1; entry.cancelRequested = false end if
  end for
  database.totalStatements = database.totalStatements + 1
  if not success then database.failedStatements = database.failedStatements + 1 end if
  if rowCount > 0 then database.rowsReturned = database.rowsReturned + rowCount end if
  database.executionGate.stateLock.release()
  return true
end function

// Removes a closed session from the process list without changing cumulative totals.
function unregisterSession(database, sessionId)
  if not isManagedDatabase(database) or database.closed then return true end if
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "unregisterSession", "database execution state is unavailable") end if
  retained = []
  for each entry in database.sessions
    if entry.sessionId != sessionId then retained = retained + [entry] end if
  end for
  database.sessions = retained
  database.executionGate.stateLock.release()
  return true
end function

// Returns immutable copies of all active process-list entries.
function operationalSessions(database)
  validateOpen(database, "operationalSessions")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "operationalSessions", "database execution state is unavailable") end if
  result = []
  for each entry in database.sessions
    result = result + [OperationalSession(entry.sessionId, entry.peerEndpoint, entry.secure, entry.principalId, entry.createdAt, entry.lastActivity, entry.statementStartedAt, entry.statementText, entry.state, entry.requestCount, entry.cancelRequested)]
  end for
  database.executionGate.stateLock.release()
  return result
end function

// Returns a compact numeric snapshot used by SHOW STATUS.
function operationalStatus(database)
  validateOpen(database, "operationalStatus")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "operationalStatus", "database execution state is unavailable") end if
  fencingFlag = 0
  if database.fencingEnabled then fencingFlag = 1 end if
  result = [clock.monotonicMilliseconds() - database.startedAt, len(database.sessions), database.totalConnections, database.totalStatements, database.failedStatements, database.rowsReturned, database.checkpointResets, database.maxStatementBytes, database.maxFrameBytes, database.maxResultRows, database.idleTimeoutMs, database.queryMemoryBytes, database.queryTimeoutMs, database.maxResultBytes, database.processMemoryBytes, heap_bytes_used(), heap_bytes_committed(), database.temporaryStorageBytes, database.temporaryReservedBytes, database.temporaryPeakBytes, database.cancelledStatements, database.timedOutStatements, database.resourceRejectedStatements, database.totalExecutionMs, database.maximumExecutionMs, database.slowQueryCount, database.slowQueryMs, database.resultBytesReturned, fencingFlag, database.fencingEpoch, database.fencingRejections]
  database.executionGate.stateLock.release()
  return result
end function

// Records latency, encoded output, and terminal production-control outcomes.
function recordStatementDiagnostics(database, elapsedMs, resultBytes, errorCode)
  validateOpen(database, "recordStatementDiagnostics")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "recordStatementDiagnostics", "database execution state is unavailable") end if
  database.totalExecutionMs = database.totalExecutionMs + elapsedMs
  if elapsedMs > database.maximumExecutionMs then database.maximumExecutionMs = elapsedMs end if
  if elapsedMs >= database.slowQueryMs then database.slowQueryCount = database.slowQueryCount + 1 end if
  if resultBytes > 0 then database.resultBytesReturned = database.resultBytesReturned + resultBytes end if
  if errorCode == QUERY_CANCELLED then database.cancelledStatements = database.cancelledStatements + 1 end if
  if errorCode == QUERY_TIMEOUT then database.timedOutStatements = database.timedOutStatements + 1 end if
  if errorCode == RESOURCE_LIMIT then database.resourceRejectedStatements = database.resourceRejectedStatements + 1 end if
  database.executionGate.stateLock.release()
  return elapsedMs >= database.slowQueryMs
end function

// Requests cancellation of one currently executing session.
function requestSessionCancellation(database, sessionId)
  validateOpen(database, "requestSessionCancellation")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "requestSessionCancellation", "database execution state is unavailable") end if
  found = false
  for each entry in database.sessions
    if entry.sessionId == sessionId and entry.statementStartedAt > 0 then entry.cancelRequested = true; entry.state = "CANCELLING"; found = true end if
  end for
  database.executionGate.stateLock.release()
  if not found then return fail(INVALID_ARGUMENT, "requestSessionCancellation", "target session has no active statement") end if
  ignoredWait = try(cancelLockWait(database, sessionId))
  return true
end function

// Returns the synchronized cancellation flag polled by executor operators.
function isSessionCancellationRequested(database, sessionId)
  validateOpen(database, "isSessionCancellationRequested")
  if not database.executionGate.stateLock.acquire() then return true end if
  value = false
  for each entry in database.sessions
    if entry.sessionId == sessionId then value = entry.cancelRequested end if
  end for
  database.executionGate.stateLock.release()
  return value
end function

// Polls the registry without depending on executor-owned state. Storage batch
// loops use this to stop long scans at page/row boundaries.
function pollSessionControl(database, sessionId)
  validateOpen(database, "pollSessionControl")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "pollSessionControl", "database execution state is unavailable") end if
  now = clock.monotonicMilliseconds()
  cancelled = false
  timedOut = false
  for each entry in database.sessions
    if entry.sessionId == sessionId then
      cancelled = entry.cancelRequested
      timedOut = entry.statementStartedAt > 0 and now - entry.statementStartedAt >= database.queryTimeoutMs
    end if
  end for
  database.executionGate.stateLock.release()
  if cancelled then return fail(QUERY_CANCELLED, "pollSessionControl", "statement cancelled") end if
  if timedOut then return fail(QUERY_TIMEOUT, "pollSessionControl", "statement execution deadline exceeded") end if
  memory = try(enforceProcessMemory(database))
  if typeof(memory) == "error" then return memory end if
  return true
end function

// Requests a cooperative listener stop after the current statement response.
function requestShutdown(database)
  validateOpen(database, "requestShutdown")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "requestShutdown", "database execution state is unavailable") end if
  database.shutdownRequested = true
  database.executionGate.stateLock.release()
  return true
end function

// Returns whether an administrator requested cooperative listener shutdown.
function isShutdownRequested(database)
  if not isManagedDatabase(database) then return false end if
  if database.closed then return true end if
  if not database.executionGate.stateLock.acquire() then return true end if
  value = database.shutdownRequested
  database.executionGate.stateLock.release()
  return value
end function

// Returns whether the one-time process-local index readiness pass completed.
// The execution-gate state lock makes this probe safe during concurrent accepts.
function indexesReady(database)
  validateOpen(database, "indexesReady")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "indexesReady", "database execution state is unavailable") end if
  value = database.indexesReady
  database.executionGate.stateLock.release()
  return value
end function

// Publishes completion of process-local index readiness to later sessions.
function markIndexesReady(database)
  validateOpen(database, "markIndexesReady")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "markIndexesReady", "database execution state is unavailable") end if
  database.indexesReady = true
  database.executionGate.stateLock.release()
  return true
end function

// Returns the process-local optimizer invalidation generation shared by every
// session attached to this managed database.
function planningGeneration(database)
  validateOpen(database, "planningGeneration")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "planningGeneration", "database execution state is unavailable") end if
  value = database.planningEpoch
  database.executionGate.stateLock.release()
  return value
end function

// Returns the immutable schema snapshot published for this database. Schema
// states are never modified after publication, so readers may safely retain the
// returned value for the duration of their physical execution-gate lease.
function schemaSnapshot(database)
  validateOpen(database, "schemaSnapshot")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "schemaSnapshot", "database execution state is unavailable") end if
  value = database.schemaState
  database.executionGate.stateLock.release()
  return value
end function

// Reloads and atomically publishes durable schema metadata after successful
// DDL. The relatively expensive file validation therefore occurs once per
// schema change instead of once per query or affected row.
function refreshSchemaSnapshot(database)
  validateOpen(database, "refreshSchemaSnapshot")
  refreshed = schema_history.loadOrCreate(database.path, database.catalogHandle.metadata.databaseId)
  if typeof(refreshed) == "error" then return refreshed end if
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "refreshSchemaSnapshot", "database execution state is unavailable") end if
  database.schemaState = refreshed
  database.executionGate.stateLock.release()
  return refreshed
end function

// Advances the shared generation after committed DDL or statistics maintenance.
function advancePlanningGeneration(database)
  validateOpen(database, "advancePlanningGeneration")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "advancePlanningGeneration", "database execution state is unavailable") end if
  database.planningEpoch = database.planningEpoch + 1
  if database.planningEpoch < 0 then database.planningEpoch = 0 end if
  value = database.planningEpoch
  database.executionGate.stateLock.release()
  return value
end function

// Acquires statement read using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function acquireStatementRead(database, transactionId, isolationLevel)
  validateOpen(database, "acquireStatementRead")
  return lock_manager.acquireStatementRead(database.lockManager, transactionId, isolationLevel)
end function

// Implements finish statement for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function finishStatement(database, lease)
  validateOpen(database, "finishStatement")
  return lock_manager.finishStatement(database.lockManager, lease)
end function

// Acquires write using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function acquireWrite(database, transactionId)
  validateOpen(database, "acquireWrite")
  return lock_manager.acquireWrite(database.lockManager, transactionId)
end function

// Releases locks using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function releaseLocks(database, transactionId)
  validateOpen(database, "releaseLocks")
  return lock_manager.finishTransaction(database.lockManager, transactionId)
end function

// Implements cancel lock wait for this module.
// Returns the computed value or operation status.
// Does not modify its inputs.
function cancelLockWait(database, transactionId)
  validateOpen(database, "cancelLockWait")
  return lock_manager.cancelWait(database.lockManager, transactionId)
end function

// Returns whether a transaction is still blocked in the logical lock graph.
// Listener workers use this probe to wait without reparsing or re-executing SQL.
function isLockWaiting(database, transactionId)
  validateOpen(database, "isLockWaiting")
  return lock_manager.isWaiting(database.lockManager, transactionId)
end function

// Implements waiter count for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function waiterCount(database)
  validateOpen(database, "waiterCount")
  return lock_manager.waiterCount(database.lockManager)
end function

// Implements active writer for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function activeWriter(database)
  validateOpen(database, "activeWriter")
  return lock_manager.activeWriter(database.lockManager)
end function

// Implements reader count for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function readerCount(database)
  validateOpen(database, "readerCount")
  return lock_manager.readerCount(database.lockManager)
end function

// Implements audit for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function audit(database, eventType, outcome, sessionId, principalId, detail)
  validateOpen(database, "audit")
  return diagnostics.appendAudit(database.auditLog, eventType, outcome, sessionId, principalId, detail)
end function

// Implements rotate audit for this module.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function rotateAudit(database, sessionId, principalId)
  validateOpen(database, "rotateAudit")
  database.auditLog = diagnostics.rotateAudit(database.auditLog, database.path, sessionId, principalId)
  return true
end function

// Verifies audit using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function verifyAudit(database)
  validateOpen(database, "verifyAudit")
  return diagnostics.verifyAudit(database.path)
end function

// Returns whether the supplied value satisfies the standby condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isStandby(database)
  validateOpen(database, "isStandby")
  return database.standby
end function

// Finds table using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function findTable(database, name)
  validateOpen(database, "findTable")
  return catalog.findTable(database.catalogHandle, name)
end function

// Resets the current WAL at a fully published statement boundary once it
// reaches the configured threshold. The caller must hold exclusive database
// execution, which guarantees that every WAL record being discarded already
// has a durable base-file page image and that no commit can race the reset.
// Persistent epoch replay avoids comparing new low LSNs with page LSNs from a
// previous physical WAL generation.
function checkpointIfNeeded(database)
  validateOpen(database, "checkpointIfNeeded")
  if database.standby or database.walWriter.nextLsn < database.checkpointWalBytes then return false end if
  reclaimed = database.walWriter.nextLsn
  flushed = try(wal.flush(database.walWriter))
  if typeof(flushed) == "error" then return flushed end if

  epochMarker = checkpointMarkerBytes(bytes("MSWEP001"), database.catalogHandle.metadata.databaseId)
  pendingMarker = checkpointMarkerBytes(bytes("MSWRP001"), database.catalogHandle.metadata.databaseId)
  epochReady = try(ensureCheckpointMarker(walEpochPath(database.path), epochMarker))
  if typeof(epochReady) == "error" then return epochReady end if
  pendingReady = try(ensureCheckpointMarker(walResetPendingPath(database.path), pendingMarker))
  if typeof(pendingReady) == "error" then return pendingReady end if

  rewound = try(wal.rewind(database.walWriter, 0))
  if typeof(rewound) == "error" then return rewound end if
  published = try(checkpoint.publish(database.checkpointFile, 0, 0, 0))
  if typeof(published) == "error" then return published end if
  database.catalogHandle.metadata.checkpointLsn = 0
  persisted = try(catalog.persistMetadata(database.catalogHandle))
  if typeof(persisted) == "error" then return persisted end if
  removed = try(file_api.deletePath(walResetPendingPath(database.path)))
  if typeof(removed) == "error" then return removed end if

  database.walEpoch = true
  database.checkpointResets = database.checkpointResets + 1
  ignoredLog = logger.info("minisql.server.database_manager.checkpointIfNeeded", "automatic WAL checkpoint reset path=" + database.path + " reclaimedBytes=" + reclaimed + " thresholdBytes=" + database.checkpointWalBytes)
  return true
end function

// Returns the number of successful process-local automatic WAL resets.
function checkpointResetCount(database)
  validateOpen(database, "checkpointResetCount")
  return database.checkpointResets
end function

// Invalidates committed page images after a successful mutation. The caller
// holds exclusive execution, so no reader can observe a stale/new mixture.
function invalidateReadCache(database)
  validateOpen(database, "invalidateReadCache")
  invalidated = try(invalidateReadHandles(database))
  cleared = try(buffer_pool.clearReadCache(database.readCache))
  if typeof(invalidated) == "error" then return invalidated end if
  if typeof(cleared) == "error" then return cleared end if
  return true
end function

// Returns synchronized buffer-cache diagnostics.
function readCacheStats(database)
  validateOpen(database, "readCacheStats")
  return buffer_pool.readCacheStats(database.readCache)
end function

// Runs post-commit checkpoint maintenance without changing an already durable
// SQL outcome into a retryable client error. Failures remain visible in the
// server log and the next writer retries while the intact WAL stays recoverable.
function checkpointAfterStatement(database)
  result = try(checkpointIfNeeded(database))
  if typeof(result) == "error" then
    ignoredLog = logger.errorLog("minisql.server.database_manager.checkpointAfterStatement", "automatic WAL checkpoint failed path=" + database.path + " code=" + result.code + " message=" + result.message)
    return false
  end if
  return result
end function

// Creates table using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function createTable(database, name, definitions)
  validateOpen(database, "createTable")
  return catalog.createTable(database.catalogHandle, name, definitions)
end function

// Closes close using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// May mutate supplied state and perform I/O through its dependencies.
function close(database)
  closingPath = database.path
  entered = try(enterExecution(database))
  failure = void
  closedAudit = try(diagnostics.closeAudit(database.auditLog))
  if typeof(closedAudit) == "error" then failure = closedAudit end if
  closedReadHandles = try(closeReadHandleCache(database))
  if typeof(failure) != "error" and typeof(closedReadHandles) == "error" then failure = closedReadHandles end if
  closedReadCache = try(buffer_pool.closeReadCache(database.readCache))
  if typeof(failure) != "error" and typeof(closedReadCache) == "error" then failure = closedReadCache end if
  closedCheckpoint = try(checkpoint.close(database.checkpointFile))
  if typeof(failure) != "error" and typeof(closedCheckpoint) == "error" then failure = closedCheckpoint end if
  closedWal = try(wal.close(database.walWriter))
  if typeof(failure) != "error" and typeof(closedWal) == "error" then failure = closedWal end if
  closedCatalog = try(catalog.close(database.catalogHandle))
  if typeof(failure) != "error" and typeof(closedCatalog) == "error" then failure = closedCatalog end if
  releasedFileLock = try(file_lock.release(database.lockToken))
  if typeof(failure) != "error" and typeof(releasedFileLock) == "error" then failure = releasedFileLock end if
  closedLockFile = try(file_api.close(database.lockFile))
  if typeof(failure) != "error" and typeof(closedLockFile) == "error" then failure = closedLockFile end if
  closedManager = try(lock_manager.close(database.lockManager))
  if typeof(failure) != "error" and typeof(closedManager) == "error" then failure = closedManager end if
  database.closed = true
  gate = database.executionGate
  gate.roomEmpty.release()
  gate.turnstile.release()
  gate.roomEmpty.close()
  gate.turnstile.close()
  gate.stateLock.close()
  if typeof(failure) == "error" then ignoredLog = logger.errorLog("minisql.server.database_manager.close", "database close failed path=" + closingPath + " message=" + failure.message); return failure end if
  ignoredLog = logger.info("minisql.server.database_manager.close", "database closed path=" + closingPath)
  return true
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "server.database_manager"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M8"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
