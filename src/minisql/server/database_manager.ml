package minisql.server.database_manager

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import std.threading as threading
import std.ds.hashmap as hashmap
import minisql.catalog.catalog as catalog
import minisql.catalog.schema_history as schema_history
import minisql.common.diagnostics as diagnostics
import minisql.common.logger as logger
import minisql.platform.file as file_api
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
  // Indicates whether the closed condition is active.
  closed
end struct

// One persistent immutable table or index handle. The per-handle guard covers
// the complete caller lease because positioned Windows reads use one shared
// native file cursor; separate files remain independently concurrent.
struct CachedReadHandle
  // Stable absolute or database-relative path used as the registry key.
  path
  // Open PagedFile or BTree owned exclusively by the database registry.
  value
  // Serializes operations using this native handle.
  guard
  // Distinguishes BTree handles from PagedFile handles during close.
  indexHandle
end struct

// Caller ownership token for one acquired persistent read handle.
struct ReadHandleLease
  // Registry entry whose guard remains acquired until release.
  entry
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
  return ReadHandleCache(hashmap.HashMap.withCapacity(64), hashmap.HashMap.withCapacity(64), guard, 0, 0, false)
end function

// Validates a caller lease and returns its guarded storage value.
function readHandleValue(lease)
  if lease is not ReadHandleLease or lease.released then return fail(INVALID_ARGUMENT, "readHandleValue", "lease must be active") end if
  return lease.entry.value
end function

// Releases one table or index lease after the complete storage operation.
function releaseReadHandle(lease)
  if lease is not ReadHandleLease or lease.released then return fail(INVALID_ARGUMENT, "releaseReadHandle", "lease must be active") end if
  lease.released = true
  if not lease.entry.guard.release() then return fail(CLOSED_HANDLE, "releaseReadHandle", "handle guard is unavailable") end if
  return true
end function

// Acquires or lazily opens one persistent read-only index tree. The registry
// guard prevents duplicate opens, while the entry guard protects the shared
// native cursor for the duration of the caller's complete B-tree probe.
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
    entryGuard = threading.Lock.new()
    if typeof(entryGuard) == "error" then btree.close(tree); cache.guard.release(); return entryGuard end if
    entry = CachedReadHandle(path, tree, entryGuard, true)
    cache.indexes.set(path, entry)
    cache.misses = cache.misses + 1
  else
    cache.hits = cache.hits + 1
  end if
  if not entry.guard.acquire() then cache.guard.release(); return fail(CLOSED_HANDLE, "acquireIndexReadHandle", "index handle guard is unavailable") end if
  cache.guard.release()
  return ReadHandleLease(entry, false)
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
    entryGuard = threading.Lock.new()
    if typeof(entryGuard) == "error" then paged_file.close(tableFile); cache.guard.release(); return entryGuard end if
    entry = CachedReadHandle(path, tableFile, entryGuard, false)
    cache.tables.set(path, entry)
    cache.misses = cache.misses + 1
  else
    cache.hits = cache.hits + 1
  end if
  if not entry.guard.acquire() then cache.guard.release(); return fail(CLOSED_HANDLE, "acquireTableReadHandle", "table handle guard is unavailable") end if
  cache.guard.release()
  return ReadHandleLease(entry, false)
end function

// Closes every entry in one raw HashMap while the registry and writer gates are
// held. Iterating occupied slots avoids allocating a temporary values array.
function closeReadHandleMap(values)
  closed = 0
  if values.cap > 0 then
    for index = 0 to values.cap - 1
      if values.states[index] == 1 then
        entry = values.values[index]
        if entry.guard.acquire() then
          if entry.indexHandle then ignoredClose = try(btree.close(entry.value)) else ignoredClose = try(paged_file.close(entry.value)) end if
          entry.guard.release()
          entry.guard.close()
          closed = closed + 1
        end if
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
  result = ReadHandleCacheStats(cache.hits, cache.misses, cache.tables.count(), cache.indexes.count())
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
  opened = ManagedDatabase(path, catalogHandle, schemaState, lockFile, lockToken, walWriter, checkpointFile, recoveryResult, lock_manager.create(), 1, auditLog, standbyMarker, executionGate, checkpointWalBytes, epochActive, 0, readCache, readHandles, false, 0, queryMemoryBytes, false)
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
