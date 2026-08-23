// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import std.string as string_api
import std.string_builder as string_builder
import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.clock as clock
import minisql.server.database_manager as database_manager

// Executes SQL and returns the first result while preserving structured errors.
function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

// Parses one positive decimal command-line integer without a fixed-size parser.
function positiveInteger(text, name)
  raw = bytes(text)
  if len(raw) == 0 then return error(9001, "capacity." + name + ": value is empty") end if
  value = 0
  for index = 0 to len(raw) - 1
    digit = raw[index]
    if digit < 48 or digit > 57 then return error(9001, "capacity." + name + ": value is not decimal") end if
    value = value * 10 + digit - 48
    if value < 0 then return error(9001, "capacity." + name + ": value overflowed") end if
  end for
  if value <= 0 then return error(9001, "capacity." + name + ": value must be positive") end if
  return value
end function

// Initializes several related capacity-test tables and prints the generated
// database directory for the Python profile orchestrator.
function initializeCapacity(dataRoot, name)
  managed = database_manager.create(dataRoot, name, config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)
  executeOne(engine, "CREATE TABLE capacity_data (id INTEGER PRIMARY KEY, bucket INTEGER NOT NULL, payload TEXT NOT NULL)")
  executeOne(engine, "CREATE TABLE capacity_batches (first_id INTEGER PRIMARY KEY, row_count INTEGER NOT NULL, payload_bytes INTEGER NOT NULL)")
  executeOne(engine, "CREATE TABLE capacity_lookup (id INTEGER PRIMARY KEY, label VARCHAR(80) NOT NULL UNIQUE)")
  executeOne(engine, "INSERT INTO capacity_lookup(id, label) VALUES (1, 'one'), (2, 'two'), (3, 'three'), (4, 'four')")
  path = managed.path
  executor.close(engine)
  database_manager.close(managed)
  print "CAPACITY_DATABASE_PATH=" + path
  return 0
end function

// Adds one restart-sized chunk. Large TEXT values exercise overflow storage;
// the multi-row statement exercises grouped page/WAL append and one durable commit.
function insertCapacityChunk(databasePath, firstId, rowCount, payloadBytes)
  managed = database_manager.openWithRuntime(databasePath, 65536, 67108864)
  engine = executor.attach(managed)
  payload = string_api.repeat("x", payloadBytes)
  started = clock.monotonicMilliseconds()
  statement = string_builder.StringBuilder.withCapacity(rowCount * (payloadBytes + 64))
  statement.appendString("INSERT INTO capacity_data(id, bucket, payload) VALUES ")
  for offset = 0 to rowCount - 1
    if offset > 0 then statement.appendString(", ") end if
    id = firstId + offset
    statement.appendString("(")
    statement.append(id)
    statement.appendString(", ")
    statement.append(id % 64)
    statement.appendString(", '")
    statement.appendString(payload)
    statement.appendString("')")
  end for
  inserted = executeOne(engine, statement.toString())
  if inserted.affectedRows != rowCount then return error(9004, "capacity.insert: affected-row count mismatch") end if
  executeOne(engine, "INSERT INTO capacity_batches(first_id, row_count, payload_bytes) VALUES (" + firstId + ", " + rowCount + ", " + payloadBytes + ")")
  elapsed = clock.monotonicMilliseconds() - started
  walBytes = managed.walWriter.nextLsn
  resets = database_manager.checkpointResetCount(managed)
  executor.close(engine)
  database_manager.close(managed)
  print "CAPACITY_CHUNK firstId=" + firstId + " rows=" + rowCount + " payloadBytes=" + payloadBytes + " elapsedMs=" + elapsed + " walBytes=" + walBytes + " resets=" + resets
  return 0
end function

// Opens a clean database in a fresh process and performs one indexed lookup.
// This guards against reintroducing full heap verification on every restart.
function verifyPointCapacity(databasePath, expectedRows, payloadBytes)
  managed = database_manager.openWithRuntime(databasePath, 65536, 67108864)
  engine = executor.attach(managed)
  started = clock.monotonicMilliseconds()
  last = executeOne(engine, "SELECT payload FROM capacity_data WHERE id = " + expectedRows)
  elapsed = clock.monotonicMilliseconds() - started
  if len(last.rows) != 1 or len(last.rows[0][0].value) != payloadBytes then executor.close(engine); database_manager.close(managed); print "CAPACITY_POINT_FAIL"; return 7 end if
  executor.close(engine)
  database_manager.close(managed)
  print "CAPACITY_POINT_SUCCESS id=" + expectedRows + " payloadBytes=" + payloadBytes + " elapsedMs=" + elapsed
  return 0
end function

// Verifies row count, point access to an external value, pagination, aggregate
// execution, restart recovery, and observable page-cache hits.
function verifyCapacity(databasePath, expectedRows, payloadBytes)
  managed = database_manager.openWithRuntime(databasePath, 65536, 67108864)
  engine = executor.attach(managed)
  started = clock.monotonicMilliseconds()
  counted = executeOne(engine, "SELECT COUNT(*) FROM capacity_data")
  actualRows = endian.int64ToInt(counted.rows[0][0].value)
  if actualRows != expectedRows then executor.close(engine); database_manager.close(managed); print "CAPACITY_VERIFY_FAIL count=" + actualRows + " expected=" + expectedRows; return 2 end if
  grouped = executeOne(engine, "SELECT bucket, COUNT(*) FROM capacity_data GROUP BY bucket ORDER BY bucket")
  if len(grouped.rows) != 64 then executor.close(engine); database_manager.close(managed); print "CAPACITY_VERIFY_FAIL buckets=" + len(grouped.rows); return 3 end if
  executeOne(engine, "SELECT id FROM capacity_data LIMIT 32")
  executeOne(engine, "SELECT id FROM capacity_data LIMIT 32")
  cacheStats = database_manager.readCacheStats(managed)
  if cacheStats.hits <= 0 then executor.close(engine); database_manager.close(managed); print "CAPACITY_VERIFY_FAIL cacheHits=0"; return 4 end if
  last = executeOne(engine, "SELECT payload FROM capacity_data WHERE id = " + expectedRows)
  if len(last.rows) != 1 or len(last.rows[0][0].value) != payloadBytes then executor.close(engine); database_manager.close(managed); print "CAPACITY_VERIFY_FAIL payload"; return 5 end if
  elapsed = clock.monotonicMilliseconds() - started
  walBytes = managed.walWriter.nextLsn
  executor.close(engine)
  database_manager.close(managed)
  print "CAPACITY_VERIFY_SUCCESS rows=" + actualRows + " payloadBytes=" + payloadBytes + " elapsedMs=" + elapsed + " cacheHits=" + cacheStats.hits + " cacheMisses=" + cacheStats.misses + " walBytes=" + walBytes
  return 0
end function

// Runs bounded-memory storage compaction as an explicit optional profile step.
function vacuumCapacity(databasePath, expectedRows)
  managed = database_manager.openWithRuntime(databasePath, 65536, 67108864)
  engine = executor.attach(managed)
  started = clock.monotonicMilliseconds()
  compacted = executeOne(engine, "VACUUM capacity_data")
  elapsed = clock.monotonicMilliseconds() - started
  if compacted.affectedRows != expectedRows then executor.close(engine); database_manager.close(managed); print "CAPACITY_VACUUM_FAIL rows=" + compacted.affectedRows; return 6 end if
  executor.close(engine)
  database_manager.close(managed)
  print "CAPACITY_VACUUM_SUCCESS rows=" + expectedRows + " elapsedMs=" + elapsed
  return 0
end function

// Dispatches the small native worker modes used by the restart-aware driver.
function main(args)
  if len(args) == 3 and args[0] == "init" then return initializeCapacity(args[1], args[2]) end if
  if len(args) == 5 and args[0] == "insert" then return insertCapacityChunk(args[1], positiveInteger(args[2], "firstId"), positiveInteger(args[3], "rowCount"), positiveInteger(args[4], "payloadBytes")) end if
  if len(args) == 4 and args[0] == "point" then return verifyPointCapacity(args[1], positiveInteger(args[2], "expectedRows"), positiveInteger(args[3], "payloadBytes")) end if
  if len(args) == 4 and args[0] == "verify" then return verifyCapacity(args[1], positiveInteger(args[2], "expectedRows"), positiveInteger(args[3], "payloadBytes")) end if
  if len(args) == 3 and args[0] == "vacuum" then return vacuumCapacity(args[1], positiveInteger(args[2], "expectedRows")) end if
  print "Usage: capacity-worker init <data-root> <name> | insert <db-path> <first-id> <rows> <payload-bytes> | point <db-path> <rows> <payload-bytes> | verify <db-path> <rows> <payload-bytes> | vacuum <db-path> <rows>"
  return 1
end function
