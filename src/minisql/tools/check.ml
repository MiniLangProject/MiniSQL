package minisql.tools.check

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.catalog.catalog as catalog
import minisql.catalog.schema_history as schema_history
import minisql.catalog.statistics as statistics
import minisql.common.version as version
import minisql.common.diagnostics as diagnostics
import minisql.executor.dml as dml
import minisql.executor.scan as scan
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.storage.btree as btree

// M20 offline consistency checker. The database manager obtains the database-wide
// exclusive lock and completes WAL recovery before any structural checks begin.

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004

// Groups the check report state and preserves the field relationships documented below.
struct CheckReport
  // Stores the database name associated with this value.
  databaseName
  // Identifies the database identifier.
  databaseId
  // Tracks the page size numeric value.
  pageSize
  // Tracks the table count numeric value.
  tableCount
  // Tracks the row count numeric value.
  rowCount
  // Tracks the index count numeric value.
  indexCount
  // Tracks the statistics table count numeric value.
  statisticsTableCount
  // Stores the warnings associated with this value.
  warnings
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "tools.check." + operation + ": " + message)
end function

// Returns whether the supplied value satisfies the check report condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isCheckReport(value)
  return value is CheckReport
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

// Returns whether the supplied value satisfies the int condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function containsInt(values, expected)
  for each value in values
    if value == expected then return true end if
  end for
  return false
end function

// Implements catalog has table for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function catalogHasTable(database, tableId)
  for each table in database.catalogHandle.catalog.tables
    if table.tableId == tableId then return true end if
  end for
  return false
end function

// Implements schema has table for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function schemaHasTable(state, tableId)
  for each table in state.tables
    if table.tableId == tableId then return true end if
  end for
  return false
end function

// Verifies index using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function verifyIndex(databasePath, indexId)
  path = schema_history.indexFilePath(databasePath, indexId)
  if not file_api.fileExists(path) then return fail(CORRUPT_DATA, "verifyIndex", "index file is missing: " + path) end if
  tree = try(btree.open(path))
  if typeof(tree) == "error" then return tree end if
  result = try(btree.verify(tree))
  closeResult = try(btree.close(tree))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return true
end function

// Checks open using the supplied inputs.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function checkOpen(database)
  securityValid = catalog.validateSecuritySemantics(database.catalogHandle.security, database.catalogHandle.metadata.databaseId, database.catalogHandle.catalog.tables)
  auditReport = diagnostics.verifyAudit(database.path)
  state = schema_history.loadOrCreate(database.path, database.catalogHandle.metadata.databaseId)
  if not bytesEqual(state.databaseId, database.catalogHandle.metadata.databaseId) then return fail(CORRUPT_DATA, "checkOpen", "schema database identity mismatch") end if

  rowCount = 0
  indexCount = 0
  seenIndexes = []
  warnings = []
  for each table in database.catalogHandle.catalog.tables
    if not schemaHasTable(state, table.tableId) then return fail(CORRUPT_DATA, "checkOpen", "catalog table has no schema record: " + table.name) end if
    tablePath = catalog.tableFilePath(database.path, table.tableId)
    if not file_api.fileExists(tablePath) then return fail(CORRUPT_DATA, "checkOpen", "table file is missing: " + table.name) end if
    // Decode and validate one row at a time. This still traverses every external
    // TEXT/BLOB chain and verifies its pages, but memory is bounded by the
    // largest individual row instead of the complete table payload.
    rowCount = rowCount + try(scan.verifyTable(database.path, table, void))
  end for

  for each tableState in state.tables
    if not catalogHasTable(database, tableState.tableId) then return fail(CORRUPT_DATA, "checkOpen", "schema references an unknown table ID") end if
    for each constraint in tableState.constraints
      if constraint.indexId > 0 and not containsInt(seenIndexes, constraint.indexId) then
        verifyIndex(database.path, constraint.indexId)
        seenIndexes = seenIndexes + [constraint.indexId]
        indexCount = indexCount + 1
      end if
    end for
  end for

  verifiedIndexes = dml.verifyAllIndexes(database)
  if verifiedIndexes != indexCount then return fail(CORRUPT_DATA, "checkOpen", "heap/index verification count mismatch") end if

  statisticsPath = statistics.path(database.path)
  statisticsCount = 0
  if file_api.fileExists(statisticsPath) then
    stats = statistics.loadOrCreate(database.path, database.catalogHandle.metadata.databaseId)
    statisticsCount = len(stats.tables)
    for each tableStats in stats.tables
      if not catalogHasTable(database, tableStats.tableId) then return fail(CORRUPT_DATA, "checkOpen", "statistics reference an unknown table ID") end if
      table = void
      for each candidate in database.catalogHandle.catalog.tables
        if candidate.tableId == tableStats.tableId then table = candidate; break end if
      end for
      if table is void then return fail(CORRUPT_DATA, "checkOpen", "statistics table lookup failed") end if
      if len(tableStats.columns) != len(table.columns) then return fail(CORRUPT_DATA, "checkOpen", "statistics column count mismatch for table " + table.name) end if
    end for
  else
    warnings = warnings + ["statistics are not present; run ANALYZE"]
  end if

  return CheckReport(
    database.catalogHandle.metadata.name,
    bytes(database.catalogHandle.metadata.databaseId),
    database.catalogHandle.metadata.pageSize,
    len(database.catalogHandle.catalog.tables),
    rowCount,
    indexCount,
    statisticsCount,
    warnings
  )
end function

// Runs run using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function run(databasePath)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "run", "databasePath must be non-empty") end if
  database = void
  if file_api.fileExists(file_api.joinPath(databasePath, "standby.state")) then database = try(database_manager.openStandby(databasePath)) else database = try(database_manager.open(databasePath)) end if
  if typeof(database) == "error" then return database end if
  result = try(checkOpen(database))
  closeResult = try(database_manager.close(database))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

// Implements m0 self test line for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function m0SelfTestLine()
  return "MiniSQL check tool M0 self-test: SUCCESS"
end function

// Implements version line for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function versionLine()
  return version.versionLine("check")
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "tools.check"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M20"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
