//! Provides minisql executor join facilities for this project.

package minisql.executor.join

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian
import std.concurrent.thread_pool as thread_pool
import minisql.executor.projection as projection
import minisql.executor.scan as scan
import minisql.executor.sort as sort
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.sql.ast as ast
import minisql.sql.expressions as expressions
import minisql.sql.types as types
import minisql.sql.values as values

/// Join executor. M16 provides the correctness-first nested-loop implementation.

const INVALID_ARGUMENT = 9001
/// Defines the hash bucket count constant used by the minisql executor join module.
const HASH_BUCKET_COUNT = 257
/// Defines the hash mask constant used by the minisql executor join module.
const HASH_MASK = 2147483647
/// Defines the intra query workers constant used by the minisql executor join module.
const INTRA_QUERY_WORKERS = 4

/// Stores one build-side row in a hash-bucket collision chain.
struct HashJoinEntry
  /// Non-NULL equality key retained for collision verification.
  key
  /// Right/build-side row associated with the key.
  row
end struct

/// Immutable work package for one independent grace-hash-join partition.
struct JoinPartitionTask
  /// Optional validated spill run for the left input partition.
  leftRun
  /// Optional validated spill run for the right input partition.
  rightRun
  /// Bound join metadata used for equality and residual-predicate checks.
  boundJoin
  /// Optimizer-selected hash-table build orientation.
  buildRight
  /// Optional managed database used for cooperative worker cancellation.
  database
  /// Owning session identifier when database is present.
  sessionId
end struct

/// Polls a server-owned query at bounded hash-operator intervals. Direct module
/// tests pass a void database and retain the dependency-free historical API.
/// @param database database value consumed by this operation.
/// @param sessionId Identifier of session.
/// @param counter counter value consumed by this operation.
/// @param operation operation value consumed by this operation.
function pollJoinControl(database, sessionId, counter, operation)
  if database is void or counter % 256 != 0 then return true end if
  return database_manager.pollSessionControl(database, sessionId)
end function

/// Performs the fail operation for the minisql executor join module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "executor.join." + operation + ": " + message)
end function

/// Computes non-negative truncating integer division without losing precision.
/// @param numerator numerator value consumed by this operation.
/// @param denominator denominator value consumed by this operation.
function integerDivide(numerator, denominator)
  if numerator < 0 or denominator <= 0 then return fail(INVALID_ARGUMENT, "integerDivide", "invalid arguments") end if
  return (numerator - (numerator % denominator)) / denominator
end function

/// Implements combine for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function combine(left, right)
  if not scan.isScannedRow(left) or not scan.isScannedRow(right) then return fail(INVALID_ARGUMENT, "combine", "rows must be ScannedRow") end if
  return scan.ScannedRow([left.reference, right.reference], left.values + right.values)
end function

/// Implements null values for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param table table value consumed by this operation.
function nullValues(table)
  output = []
  for each column in table.columns
    output = output + [values.nullValue(column.typeCode)]
  end for
  return output
end function

/// Implements null values for types for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param typeInfos typeInfos value consumed by this operation.
function nullValuesForTypes(typeInfos)
  if typeof(typeInfos) != "array" then return fail(INVALID_ARGUMENT, "nullValuesForTypes", "types must be array") end if
  output = []
  for each typeInfo in typeInfos
    if not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "nullValuesForTypes", "entry must be SqlType") end if
    output = output + [values.nullValue(typeInfo.kind)]
  end for
  return output
end function

/// Implements condition passes for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param condition condition value consumed by this operation.
/// @param row row value consumed by this operation.
function conditionPasses(condition, row)
  if condition is void then return true end if
  return expressions.predicatePasses(condition, expressions.rowContext(row.values))
end function

/// Implements hash bytes for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param input input value consumed by this operation.
/// @param seed seed value consumed by this operation.
function hashBytes(input, seed)
  if typeof(input) != "bytes" or typeof(seed) != "int" then return fail(INVALID_ARGUMENT, "hashBytes", "invalid hash input") end if
  result = seed & HASH_MASK
  if len(input) > 0 then
    for index = 0 to len(input) - 1
      result = ((result ^ input[index]) * 16777619) & HASH_MASK
    end for
  end if
  return result
end function

/// Implements hash value for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function hashValue(value)
  if not values.isSqlValue(value) then return fail(INVALID_ARGUMENT, "hashValue", "value must be SqlValue") end if
  if value.isNull then return 0 end if
  result = (2166136261 ^ value.typeKind) & HASH_MASK
  if typeof(value.value) == "string" then return hashBytes(bytes(value.value), result) end if
  if typeof(value.value) == "bytes" then return hashBytes(value.value, result) end if
  if typeof(value.value) == "bool" then
    if value.value then return ((result ^ 1) * 16777619) & HASH_MASK end if
    return ((result ^ 0) * 16777619) & HASH_MASK
  end if
  if typeof(value.value) == "float" and value.value == 0.0 then return hashBytes(bytes("0.0"), result) end if
  if typeof(value.value) == "int" then
    result = ((result ^ (value.value & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value >> 8) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value >> 16) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value >> 24) & 255)) * 16777619) & HASH_MASK
    return result
  end if
  if endian.isInt64Words(value.value) then
    result = ((result ^ (value.value.low & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.low >> 8) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.low >> 16) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.low >> 24) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ (value.value.high & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.high >> 8) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.high >> 16) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.high >> 24) & 255)) * 16777619) & HASH_MASK
    return result
  end if
  // Floating values use the same canonical rendering as row_codec v1.
  return hashBytes(bytes("" + value.value), result)
end function

/// Implements equality columns for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param boundJoin boundJoin value consumed by this operation.
function equalityColumns(boundJoin)
  if typeof(boundJoin) != "struct" or not expressions.isBoundExpression(boundJoin.condition) then return void end if
  condition = boundJoin.condition
  if condition.kind != expressions.BOUND_BINARY or condition.operator != "=" then return void end if
  if not expressions.isBoundExpression(condition.left) or not expressions.isBoundExpression(condition.right) then return void end if
  if condition.left.kind != expressions.BOUND_COLUMN or condition.right.kind != expressions.BOUND_COLUMN then return void end if
  leftCount = len(boundJoin.leftTypes)
  leftIndex = condition.left.columnIndex
  rightIndex = condition.right.columnIndex
  if leftIndex >= 0 and leftIndex < leftCount and rightIndex >= leftCount then return [leftIndex, rightIndex - leftCount] end if
  if rightIndex >= 0 and rightIndex < leftCount and leftIndex >= leftCount then return [rightIndex, leftIndex - leftCount] end if
  return void
end function

/// Returns whether the supplied value satisfies the hash condition.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param boundJoin boundJoin value consumed by this operation.
function canHash(boundJoin)
  if typeof(boundJoin) != "struct" then return false end if
  if boundJoin.joinType != ast.JOIN_INNER and boundJoin.joinType != ast.JOIN_LEFT then return false end if
  columns = equalityColumns(boundJoin)
  if columns is void then return false end if
  // Hash equality requires the same physical type. Mixed numeric/text comparisons
  // remain on the nested-loop path so equal values can never land in different
  // buckets merely because their runtime representations differ.
  return types.sameBase(boundJoin.condition.left.typeInfo, boundJoin.condition.right.typeInfo)
end function

/// Executes an INNER or LEFT equi-join with a right-side hash table.
/// NULL keys never match, full value comparison resolves collisions, and the
/// original predicate is rechecked before emission. Unsupported shapes fall back.
/// @param leftRows leftRows value consumed by this operation.
/// @param rightRows rightRows value consumed by this operation.
/// @param boundJoin boundJoin value consumed by this operation.
/// @param database database value consumed by this operation.
/// @param sessionId Identifier of session.
function applyHashRightCore(leftRows, rightRows, boundJoin, database, sessionId)
  if not canHash(boundJoin) then return apply(leftRows, rightRows, boundJoin) end if
  if typeof(leftRows) != "array" or typeof(rightRows) != "array" then return fail(INVALID_ARGUMENT, "applyHash", "row inputs must be arrays") end if
  columns = equalityColumns(boundJoin)
  leftColumn = columns[0]
  rightColumn = columns[1]
  buckets = array(HASH_BUCKET_COUNT, void)
  pollCounter = 0
  for each right in rightRows
    polled = try(pollJoinControl(database, sessionId, pollCounter, "applyHashRight.build"))
    if typeof(polled) == "error" then return polled end if
    pollCounter = pollCounter + 1
    if not scan.isScannedRow(right) then return fail(INVALID_ARGUMENT, "applyHash", "right input contains non-row") end if
    if rightColumn < 0 or rightColumn >= len(right.values) then return fail(INVALID_ARGUMENT, "applyHash", "right join column is out of range") end if
    key = right.values[rightColumn]
    if not key.isNull then
      bucketIndex = hashValue(key) % HASH_BUCKET_COUNT
      bucket = buckets[bucketIndex]
      if bucket is void then bucket = [] end if
      bucket = bucket + [HashJoinEntry(key, right)]
      buckets[bucketIndex] = bucket
    end if
  end for

  output = []
  pollCounter = 0
  candidateCount = 0
  for each left in leftRows
    polled = try(pollJoinControl(database, sessionId, pollCounter, "applyHashRight.probe"))
    if typeof(polled) == "error" then return polled end if
    pollCounter = pollCounter + 1
    if not scan.isScannedRow(left) then return fail(INVALID_ARGUMENT, "applyHash", "left input contains non-row") end if
    if leftColumn < 0 or leftColumn >= len(left.values) then return fail(INVALID_ARGUMENT, "applyHash", "left join column is out of range") end if
    matched = false
    key = left.values[leftColumn]
    if not key.isNull then
      bucket = buckets[hashValue(key) % HASH_BUCKET_COUNT]
      if bucket is not void then
        for each entry in bucket
          if candidateCount % 4096 == 0 and database is not void then
            polledCandidate = try(database_manager.pollSessionControl(database, sessionId))
            if typeof(polledCandidate) == "error" then return polledCandidate end if
          end if
          candidateCount = candidateCount + 1
          if values.compareNonNull(key, entry.key) == 0 then
            candidate = combine(left, entry.row)
            if conditionPasses(boundJoin.condition, candidate) then
              output = output + [candidate]
              matched = true
            end if
          end if
        end for
      end if
    end if
    if boundJoin.joinType == ast.JOIN_LEFT and not matched then
      output = output + [scan.ScannedRow([left.reference, void], left.values + nullValues(boundJoin.source.table))]
    end if
  end for
  return output
end function

/// Executes an INNER equi-join with the left input as the hash-build side. The
/// emitted row remains `left.values + right.values`, so choosing the smaller
/// build side never changes bound column indexes.
/// @param leftRows leftRows value consumed by this operation.
/// @param rightRows rightRows value consumed by this operation.
/// @param boundJoin boundJoin value consumed by this operation.
/// @param database database value consumed by this operation.
/// @param sessionId Identifier of session.
function applyHashLeftCore(leftRows, rightRows, boundJoin, database, sessionId)
  if not canHash(boundJoin) or boundJoin.joinType != ast.JOIN_INNER then return applyHashRightCore(leftRows, rightRows, boundJoin, database, sessionId) end if
  if typeof(leftRows) != "array" or typeof(rightRows) != "array" then return fail(INVALID_ARGUMENT, "applyHashLeft", "row inputs must be arrays") end if
  columns = equalityColumns(boundJoin)
  leftColumn = columns[0]
  rightColumn = columns[1]
  buckets = array(HASH_BUCKET_COUNT, void)
  pollCounter = 0
  for each left in leftRows
    polled = try(pollJoinControl(database, sessionId, pollCounter, "applyHashLeft.build"))
    if typeof(polled) == "error" then return polled end if
    pollCounter = pollCounter + 1
    if not scan.isScannedRow(left) then return fail(INVALID_ARGUMENT, "applyHashLeft", "left input contains non-row") end if
    key = left.values[leftColumn]
    if not key.isNull then
      bucketIndex = hashValue(key) % HASH_BUCKET_COUNT
      bucket = buckets[bucketIndex]
      if bucket is void then bucket = [] end if
      bucket = bucket + [HashJoinEntry(key, left)]
      buckets[bucketIndex] = bucket
    end if
  end for
  output = []
  pollCounter = 0
  candidateCount = 0
  for each right in rightRows
    polled = try(pollJoinControl(database, sessionId, pollCounter, "applyHashLeft.probe"))
    if typeof(polled) == "error" then return polled end if
    pollCounter = pollCounter + 1
    if not scan.isScannedRow(right) then return fail(INVALID_ARGUMENT, "applyHashLeft", "right input contains non-row") end if
    key = right.values[rightColumn]
    if not key.isNull then
      bucket = buckets[hashValue(key) % HASH_BUCKET_COUNT]
      if bucket is not void then
        for each entry in bucket
          if candidateCount % 4096 == 0 and database is not void then
            polledCandidate = try(database_manager.pollSessionControl(database, sessionId))
            if typeof(polledCandidate) == "error" then return polledCandidate end if
          end if
          candidateCount = candidateCount + 1
          if values.compareNonNull(entry.key, key) == 0 then
            candidate = combine(entry.row, right)
            if conditionPasses(boundJoin.condition, candidate) then output = output + [candidate] end if
          end if
        end for
      end if
    end if
  end for
  return output
end function

/// Executes the optimizer-selected hash build orientation. LEFT joins keep the
/// right build side because unmatched-left tracking is part of that algorithm.
/// @param leftRows leftRows value consumed by this operation.
/// @param rightRows rightRows value consumed by this operation.
/// @param boundJoin boundJoin value consumed by this operation.
/// @param buildRight buildRight value consumed by this operation.
/// @param database database value consumed by this operation.
/// @param sessionId Identifier of session.
function applyHashBuildCore(leftRows, rightRows, boundJoin, buildRight, database, sessionId)
  if typeof(buildRight) != "bool" then return fail(INVALID_ARGUMENT, "applyHashBuild", "buildRight must be bool") end if
  if not buildRight and boundJoin.joinType == ast.JOIN_INNER then return applyHashLeftCore(leftRows, rightRows, boundJoin, database, sessionId) end if
  return applyHashRightCore(leftRows, rightRows, boundJoin, database, sessionId)
end function

/// Preserves right-build hash joins for callers without a server query token.
/// @param leftRows leftRows value consumed by this operation.
/// @param rightRows rightRows value consumed by this operation.
/// @param boundJoin boundJoin value consumed by this operation.
function applyHashRight(leftRows, rightRows, boundJoin)
  return applyHashRightCore(leftRows, rightRows, boundJoin, void, 0)
end function

/// Preserves left-build hash joins for callers without a server query token.
/// @param leftRows leftRows value consumed by this operation.
/// @param rightRows rightRows value consumed by this operation.
/// @param boundJoin boundJoin value consumed by this operation.
function applyHashLeft(leftRows, rightRows, boundJoin)
  return applyHashLeftCore(leftRows, rightRows, boundJoin, void, 0)
end function

/// Selects a direct hash-build orientation without a server query token.
/// @param leftRows leftRows value consumed by this operation.
/// @param rightRows rightRows value consumed by this operation.
/// @param boundJoin boundJoin value consumed by this operation.
/// @param buildRight buildRight value consumed by this operation.
function applyHashBuild(leftRows, rightRows, boundJoin, buildRight)
  return applyHashBuildCore(leftRows, rightRows, boundJoin, buildRight, void, 0)
end function

/// Converts scanned rows to the generic validated spill-run representation.
/// @param rows rows value consumed by this operation.
function projectedSpillRows(rows)
  output = []
  for each row in rows
    if not scan.isScannedRow(row) then return fail(INVALID_ARGUMENT, "projectedSpillRows", "input contains non-row") end if
    output = output + [projection.ProjectedRow(void, row.values, [])]
  end for
  return output
end function

/// Restores value-only scanned rows after a validated spill-run read.
/// @param rows rows value consumed by this operation.
function scannedSpillRows(rows)
  output = []
  for each row in rows
    output = output + [scan.ScannedRow(void, row.values)]
  end for
  return output
end function

/// Removes every spill run already owned by not-yet-submitted partition tasks.
/// @param tasks tasks value consumed by this operation.
function cleanupPartitionTasks(tasks)
  for each task in tasks
    runs = []
    if task.leftRun is not void then runs = runs + [task.leftRun] end if
    if task.rightRun is not void then runs = runs + [task.rightRun] end if
    sort.cleanupRuns(runs)
  end for
  return true
end function

/// Reads and joins one pair of hash partitions on a native worker. Runs are
/// deleted by their owning task on both successful and failed reads.
/// @param task task value consumed by this operation.
function applySpilledPartition(task)
  runs = []
  leftRows = []
  rightRows = []
  if task.leftRun is not void then
    runs = runs + [task.leftRun]
    restoredLeft = try(sort.readRun(task.leftRun))
    if typeof(restoredLeft) == "error" then sort.cleanupRuns(runs); return restoredLeft end if
    leftRows = scannedSpillRows(restoredLeft)
  end if
  if task.rightRun is not void then
    runs = runs + [task.rightRun]
    restoredRight = try(sort.readRun(task.rightRun))
    if typeof(restoredRight) == "error" then sort.cleanupRuns(runs); return restoredRight end if
    rightRows = scannedSpillRows(restoredRight)
  end if
  output = try(applyHashBuildCore(leftRows, rightRows, task.boundJoin, task.buildRight, task.database, task.sessionId))
  cleanup = try(sort.cleanupRuns(runs))
  if typeof(output) == "error" then return output end if
  if typeof(cleanup) == "error" then return cleanup end if
  return output
end function

/// Executes a grace-style partitioned hash join when the selected build input
/// exceeds the row threshold. Each partition is CRC/shape validated by the
/// shared spill codec and removed on both success and failure paths.
/// @param leftRows leftRows value consumed by this operation.
/// @param rightRows rightRows value consumed by this operation.
/// @param boundJoin boundJoin value consumed by this operation.
/// @param buildRight buildRight value consumed by this operation.
/// @param temporaryRoot temporaryRoot value consumed by this operation.
/// @param threshold threshold value consumed by this operation.
/// @param database database value consumed by this operation.
/// @param sessionId Identifier of session.
function applyHashBuildWithSpillCore(leftRows, rightRows, boundJoin, buildRight, temporaryRoot, threshold, database, sessionId)
  if typeof(temporaryRoot) != "string" or typeof(threshold) != "int" or threshold < 2 then return fail(INVALID_ARGUMENT, "applyHashBuildWithSpill", "invalid spill configuration") end if
  buildRows = rightRows
  if not buildRight then buildRows = leftRows end if
  if len(buildRows) <= threshold or not canHash(boundJoin) then return applyHashBuildCore(leftRows, rightRows, boundJoin, buildRight, database, sessionId) end if
  if not file_api.directoryExists(temporaryRoot) then
    created = try(file_api.createDirectory(temporaryRoot))
    if typeof(created) == "error" then return created end if
  end if
  columns = equalityColumns(boundJoin)
  partitionCount = integerDivide(len(buildRows) + threshold - 1, threshold)
  if partitionCount < 2 then partitionCount = 2 end if
  if partitionCount > HASH_BUCKET_COUNT then partitionCount = HASH_BUCKET_COUNT end if
  token = sort.nextSpillToken()
  tasks = []
  for partitionIndex = 0 to partitionCount - 1
    polledPartition = try(pollJoinControl(database, sessionId, partitionIndex * 256, "applyHashBuildWithSpill.partition"))
    if typeof(polledPartition) == "error" then cleanupPartitionTasks(tasks); return polledPartition end if
    leftPartition = []
    rightPartition = []
    pollCounter = 0
    for each row in leftRows
      polledLeft = try(pollJoinControl(database, sessionId, pollCounter, "applyHashBuildWithSpill.left"))
      if typeof(polledLeft) == "error" then cleanupPartitionTasks(tasks); return polledLeft end if
      pollCounter = pollCounter + 1
      key = row.values[columns[0]]
      if (key.isNull and boundJoin.joinType == ast.JOIN_LEFT and partitionIndex == 0) or (not key.isNull and hashValue(key) % partitionCount == partitionIndex) then leftPartition = leftPartition + [row] end if
    end for
    pollCounter = 0
    for each row in rightRows
      polledRight = try(pollJoinControl(database, sessionId, pollCounter, "applyHashBuildWithSpill.right"))
      if typeof(polledRight) == "error" then cleanupPartitionTasks(tasks); return polledRight end if
      pollCounter = pollCounter + 1
      key = row.values[columns[1]]
      if not key.isNull and hashValue(key) % partitionCount == partitionIndex then rightPartition = rightPartition + [row] end if
    end for
    leftRun = void
    rightRun = void
    if len(leftPartition) > 0 then
      leftRun = try(sort.writeRun(sort.runPath(temporaryRoot, "join-left-" + token, partitionIndex), projectedSpillRows(leftPartition), len(leftPartition[0].values), 0))
      if typeof(leftRun) == "error" then return leftRun end if
    end if
    if len(rightPartition) > 0 then
      rightRun = try(sort.writeRun(sort.runPath(temporaryRoot, "join-right-" + token, partitionIndex), projectedSpillRows(rightPartition), len(rightPartition[0].values), 0))
      if typeof(rightRun) == "error" then
        if leftRun is not void then sort.cleanupRuns([leftRun]) end if
        return rightRun
      end if
    end if
    tasks = tasks + [JoinPartitionTask(leftRun, rightRun, boundJoin, buildRight, database, sessionId)]
  end for
  workerCount = len(tasks)
  if workerCount > INTRA_QUERY_WORKERS then workerCount = INTRA_QUERY_WORKERS end if
  pool = try(thread_pool.ThreadPool.withQueueCapacity(workerCount, len(tasks)))
  if typeof(pool) == "error" then
    for each task in tasks
      runs = []
      if task.leftRun is not void then runs = runs + [task.leftRun] end if
      if task.rightRun is not void then runs = runs + [task.rightRun] end if
      sort.cleanupRuns(runs)
    end for
    return pool
  end if
  jobs = []
  for each task in tasks
    job = pool.Submit(applySpilledPartition, task)
    if job is void then
      pool.ShutdownNow()
      pool.AwaitTermination()
      for each pending in tasks
        runs = []
        if pending.leftRun is not void then runs = runs + [pending.leftRun] end if
        if pending.rightRun is not void then runs = runs + [pending.rightRun] end if
        sort.cleanupRuns(runs)
      end for
      pool.Dispose()
      return fail(INVALID_ARGUMENT, "applyHashBuildWithSpill", "join partition task was rejected")
    end if
    jobs = jobs + [job]
  end for
  pool.Shutdown()
  pool.AwaitTermination()
  output = []
  for each job in jobs
    partitionOutput = try(job.GetResult())
    disposed = job.Dispose()
    if typeof(partitionOutput) == "error" then pool.Dispose(); return partitionOutput end if
    output = output + partitionOutput
  end for
  pool.Dispose()
  return output
end function

/// Historical direct API retains behavior without a cooperative server token.
/// @param leftRows leftRows value consumed by this operation.
/// @param rightRows rightRows value consumed by this operation.
/// @param boundJoin boundJoin value consumed by this operation.
/// @param buildRight buildRight value consumed by this operation.
/// @param temporaryRoot temporaryRoot value consumed by this operation.
/// @param threshold threshold value consumed by this operation.
function applyHashBuildWithSpill(leftRows, rightRows, boundJoin, buildRight, temporaryRoot, threshold)
  return applyHashBuildWithSpillCore(leftRows, rightRows, boundJoin, buildRight, temporaryRoot, threshold, void, 0)
end function

/// Server execution path propagates cancellation/deadline state into spill workers.
/// @param leftRows leftRows value consumed by this operation.
/// @param rightRows rightRows value consumed by this operation.
/// @param boundJoin boundJoin value consumed by this operation.
/// @param buildRight buildRight value consumed by this operation.
/// @param temporaryRoot temporaryRoot value consumed by this operation.
/// @param threshold threshold value consumed by this operation.
/// @param database database value consumed by this operation.
/// @param sessionId Identifier of session.
function applyHashBuildWithSpillControlled(leftRows, rightRows, boundJoin, buildRight, temporaryRoot, threshold, database, sessionId)
  return applyHashBuildWithSpillCore(leftRows, rightRows, boundJoin, buildRight, temporaryRoot, threshold, database, sessionId)
end function

/// Backward-compatible entry point used by direct executor tests.
/// @param leftRows leftRows value consumed by this operation.
/// @param rightRows rightRows value consumed by this operation.
/// @param boundJoin boundJoin value consumed by this operation.
function applyHash(leftRows, rightRows, boundJoin)
  return applyHashBuild(leftRows, rightRows, boundJoin, true)
end function

/// Executes the semantic nested-loop fallback for every supported join type.
/// Tracks matched right rows for RIGHT/FULL padding and emits typed NULL padding
/// for unmatched outer rows. Returns rows in deterministic left-major order.
/// @param leftRows leftRows value consumed by this operation.
/// @param rightRows rightRows value consumed by this operation.
/// @param boundJoin boundJoin value consumed by this operation.
function apply(leftRows, rightRows, boundJoin)
  if typeof(leftRows) != "array" or typeof(rightRows) != "array" then return fail(INVALID_ARGUMENT, "apply", "row inputs must be arrays") end if
  if typeof(boundJoin) != "struct" then return fail(INVALID_ARGUMENT, "apply", "join must be bound") end if
  output = []
  rightMatched = array(len(rightRows), false)
  for each left in leftRows
    if not scan.isScannedRow(left) then return fail(INVALID_ARGUMENT, "apply", "left input contains non-row") end if
    matched = false
    if len(rightRows) > 0 then
      for rightIndex = 0 to len(rightRows) - 1
        right = rightRows[rightIndex]
        if not scan.isScannedRow(right) then return fail(INVALID_ARGUMENT, "apply", "right input contains non-row") end if
        candidate = combine(left, right)
        if boundJoin.joinType == ast.JOIN_CROSS or conditionPasses(boundJoin.condition, candidate) then
          output = output + [candidate]
          matched = true
          rightMatched[rightIndex] = true
        end if
      end for
    end if
    if (boundJoin.joinType == ast.JOIN_LEFT or boundJoin.joinType == ast.JOIN_FULL) and not matched then
      output = output + [scan.ScannedRow([left.reference, void], left.values + nullValues(boundJoin.source.table))]
    end if
  end for
  if boundJoin.joinType == ast.JOIN_RIGHT or boundJoin.joinType == ast.JOIN_FULL then
    if len(rightRows) > 0 then
      leftNulls = nullValuesForTypes(boundJoin.leftTypes)
      for rightIndex = 0 to len(rightRows) - 1
        if not rightMatched[rightIndex] then
          right = rightRows[rightIndex]
          output = output + [scan.ScannedRow([void, right.reference], leftNulls + right.values)]
        end if
      end for
    end if
  end if
  return output
end function

/// Performs the componentName operation for the minisql executor join module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "executor.join"
end function

/// Performs the targetMilestone operation for the minisql executor join module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M16"
end function

/// Returns whether implemented satisfies the condition required by the minisql executor join module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
