package minisql.catalog.statistics
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.catalog.catalog as catalog
import minisql.common.endian as endian
import minisql.platform.file as file_api
import minisql.sql.types as types
import minisql.sql.values as values
import minisql.storage.checksum as checksum

// Persistent table/column statistics used by the M17 cost model. Statistics are
// advisory: a missing or stale file never changes query correctness. ANALYZE
// writes a complete new envelope to a temporary durable file and atomically
// replaces the previous generation.

const INVALID_ARGUMENT = 9001
const UNSUPPORTED_FORMAT = 9003
const CORRUPT_DATA = 9004
const IO_FAILURE = 9005

const FORMAT_VERSION = 3
const SAMPLED_FORMAT_VERSION = 2
const LEGACY_FORMAT_VERSION = 1
const RECORD_KIND = 50
const TABLE_HEADER_BYTES = 32
const COLUMN_BYTES = 32
const DISTINCT_BUCKET_COUNT = 257
const HASH_MASK = 2147483647
const COLUMN_FLAG_INTEGRAL_BOUNDS = 1

// Defines the column statistics record used by this module.
struct ColumnStatistics
  // Column index field of the column statistics.
  columnIndex
  // Null count field of the column statistics.
  nullCount
  // Distinct count field of the column statistics.
  distinctCount
  // Average width field of the column statistics.
  averageWidth
  // True when the sample supplied a comparable signed 32-bit minimum/maximum.
  hasIntegralBounds
  // Smallest sampled SMALLINT, INTEGER, or DATE representation.
  minimumIntegral
  // Largest sampled SMALLINT, INTEGER, or DATE representation.
  maximumIntegral
end struct

// Defines the table statistics record used by this module.
struct TableStatistics
  // Table id field of the table statistics.
  tableId
  // Row count field of the table statistics.
  rowCount
  // Page count field of the table statistics.
  pageCount
  // Number of decoded rows contributing column distribution statistics.
  sampleCount
  // Columns field of the table statistics.
  columns
end struct

// Defines the statistics catalog record used by this module.
struct StatisticsCatalog
  // Database id field of the statistics catalog.
  databaseId
  // Generation field of the statistics catalog.
  generation
  // Tables field of the statistics catalog.
  tables
end struct

// Creates the module's structured error with operation context.
// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
function fail(code, operation, message)
  return error(code, "catalog.statistics." + operation + ": " + message)
end function

// Performs the integer divide operation for this module.
// Inputs: `numerator`, `denominator`. Returns the produced value or propagates a structured error from validation or delegated operations.
function integerDivide(numerator, denominator)
  if typeof(numerator) != "int" or typeof(denominator) != "int" or numerator < 0 or denominator <= 0 then
    return fail(INVALID_ARGUMENT, "integerDivide", "arguments must be non-negative integers and denominator must be positive")
  end if
  quotient = 0
  remainder = numerator
  scale = denominator
  bit = 1
  while scale <= remainder and scale <= (endian.MAX_MINILANG_INT >> 1)
    scale = scale << 1
    bit = bit << 1
  end while
  while bit > 0
    if scale <= remainder then
      remainder = remainder - scale
      quotient = quotient + bit
    end if
    scale = scale >> 1
    bit = bit >> 1
  end while
  return quotient
end function

// Returns a fresh copy of the on-disk format magic bytes.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function magic()
  return bytes("MSSTAT01")
end function

// Evaluates whether the supplied input satisfies the column statistics predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isColumnStatistics(value)
  return value is ColumnStatistics
end function

// Evaluates whether the supplied input satisfies the table statistics predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isTableStatistics(value)
  return value is TableStatistics
end function

// Evaluates whether the supplied input satisfies the statistics catalog predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isStatisticsCatalog(value)
  return value is StatisticsCatalog
end function

// Performs the bytes equal operation for this module.
// Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.
function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

// Creates the requested value.
// Inputs: `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function create(databaseId)
  if typeof(databaseId) != "bytes" or len(databaseId) != 16 then return fail(INVALID_ARGUMENT, "create", "databaseId must be 16 bytes") end if
  return StatisticsCatalog(bytes(databaseId), 0, [])
end function

// Performs the path operation for this module.
// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
function path(databasePath)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "path", "databasePath must be non-empty") end if
  return catalog.joinPath(catalog.joinPath(databasePath, "catalog"), "statistics.tbl")
end function

// Finds the table.
// Inputs: `state`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function findTable(state, tableId)
  if state is not StatisticsCatalog or typeof(tableId) != "int" or tableId < 0 then return fail(INVALID_ARGUMENT, "findTable", "invalid arguments") end if
  for each table in state.tables
    if table.tableId == tableId then return table end if
  end for
  return void
end function

// Replaces the table.
// Inputs: `state`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function replaceTable(state, value)
  if state is not StatisticsCatalog or value is not TableStatistics then return fail(INVALID_ARGUMENT, "replaceTable", "invalid arguments") end if
  output = []
  replaced = false
  for each table in state.tables
    if table.tableId == value.tableId then
      output = output + [value]
      replaced = true
    else
      output = output + [table]
    end if
  end for
  if not replaced then output = output + [value] end if
  state.tables = output
  return value
end function

// Performs the value width operation for this module.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function valueWidth(value)
  if not values.isSqlValue(value) or value.isNull then return 0 end if
  if typeof(value.value) == "string" then return len(bytes(value.value)) end if
  if typeof(value.value) == "bytes" then return len(value.value) end if
  return 8
end function

// Compares the value.
// Inputs: `left`, `right`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function sameValue(left, right)
  if left.isNull or right.isNull then return left.isNull and right.isNull end if
  return values.compareNonNull(left, right) == 0
end function

// Hashes SQL values into deterministic collision buckets. Full SQL comparison
// below remains authoritative, so hash collisions can only affect performance.
function hashBytes(input, seed)
  result = seed & HASH_MASK
  if len(input) > 0 then
    for index = 0 to len(input) - 1
      result = ((result ^ input[index]) * 16777619) & HASH_MASK
    end for
  end if
  return result
end function

// Hashes one non-NULL SQL payload consistently with sameValue comparison.
function hashValue(value)
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
    return ((result ^ ((value.value >> 24) & 255)) * 16777619) & HASH_MASK
  end if
  if endian.isInt64Words(value.value) then
    result = ((result ^ (value.value.low & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.low >> 8) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.low >> 16) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.low >> 24) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ (value.value.high & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.high >> 8) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.high >> 16) & 255)) * 16777619) & HASH_MASK
    return ((result ^ ((value.value.high >> 24) & 255)) * 16777619) & HASH_MASK
  end if
  return hashBytes(bytes("" + value.value), result)
end function

// Performs the distinct count operation for this module.
// Inputs: `columnIndex`, `rows`. Returns the produced value or propagates a structured error from validation or delegated operations.
function distinctCount(columnIndex, rows)
  buckets = array(DISTINCT_BUCKET_COUNT, void)
  count = 0
  for each row in rows
    candidate = row.values[columnIndex]
    if not candidate.isNull then
      bucketIndex = hashValue(candidate) % DISTINCT_BUCKET_COUNT
      bucket = buckets[bucketIndex]
      if bucket is void then bucket = [] end if
      duplicate = false
      for each existing in bucket
        if sameValue(candidate, existing) then duplicate = true; break end if
      end for
      if not duplicate then
        bucket = bucket + [candidate]
        buckets[bucketIndex] = bucket
        count = count + 1
      end if
    end if
  end for
  return count
end function

// Reports whether a catalog column uses the signed 32-bit representation that
// fits the compact v3 statistics record. BIGINT and wider numeric encodings are
// intentionally left for a future variable-length histogram extension.
function supportsIntegralBounds(column)
  return column.typeCode == types.SqlTypeKind.SmallInt or column.typeCode == types.SqlTypeKind.Integer or column.typeCode == types.SqlTypeKind.Date
end function

// Finds sampled minimum and maximum values for a compact integral column. The
// boolean prefix distinguishes an all-NULL sample from a legitimate [0, 0]
// domain and keeps older statistics versions unambiguous.
function integralBounds(columnIndex, rows)
  found = false
  minimum = 0
  maximum = 0
  for each row in rows
    candidate = row.values[columnIndex]
    if not candidate.isNull then
      if typeof(candidate.value) != "int" then return [false, 0, 0] end if
      if not found or candidate.value < minimum then minimum = candidate.value end if
      if not found or candidate.value > maximum then maximum = candidate.value end if
      found = true
    end if
  end for
  return [found, minimum, maximum]
end function

// Scales a sample count without overflowing MiniLang's native integer range.
function scaleSampleCount(sampleValue, populationRows, sampleRows)
  if sampleRows == 0 then return 0 end if
  quotient = integerDivide(populationRows, sampleRows)
  remainder = populationRows - quotient * sampleRows
  return quotient * sampleValue + integerDivide(remainder * sampleValue, sampleRows)
end function

// Builds bounded-memory statistics from a uniformly spaced sample. Small
// tables, whose sample contains every row, remain exact. Low-cardinality values
// seen repeatedly are treated as saturated; high-cardinality samples are scaled
// conservatively and capped by the estimated non-NULL population.
function analyzeSample(table, populationRows, rows, pageCount)
  if typeof(table) != "struct" or typeof(populationRows) != "int" or populationRows < 0 or typeof(rows) != "array" or typeof(pageCount) != "int" or pageCount < 0 then return fail(INVALID_ARGUMENT, "analyzeSample", "invalid arguments") end if
  sampleCount = len(rows)
  columns = []
  if len(table.columns) > 0 then
    for columnIndex = 0 to len(table.columns) - 1
      sampleNulls = 0
      width = 0
      sampleNonNull = 0
      for each row in rows
        if typeof(row) != "struct" or typeof(row.values) != "array" or len(row.values) != len(table.columns) then return fail(INVALID_ARGUMENT, "analyzeSample", "row shape mismatch") end if
        value = row.values[columnIndex]
        if value.isNull then sampleNulls = sampleNulls + 1 else sampleNonNull = sampleNonNull + 1; width = width + valueWidth(value) end if
      end for
      nullCount = scaleSampleCount(sampleNulls, populationRows, sampleCount)
      if nullCount > populationRows then nullCount = populationRows end if
      averageWidth = 0
      if sampleNonNull > 0 then averageWidth = integerDivide(width, sampleNonNull) end if
      sampledDistinct = distinctCount(columnIndex, rows)
      distinctEstimate = sampledDistinct
      if sampleCount < populationRows and sampleNonNull > 0 and sampledDistinct * 10 > sampleNonNull then distinctEstimate = scaleSampleCount(sampledDistinct, populationRows, sampleCount) end if
      nonNullPopulation = populationRows - nullCount
      if distinctEstimate > nonNullPopulation then distinctEstimate = nonNullPopulation end if
      bounds = [false, 0, 0]
      if supportsIntegralBounds(table.columns[columnIndex]) then bounds = integralBounds(columnIndex, rows) end if
      columns = columns + [ColumnStatistics(columnIndex, nullCount, distinctEstimate, averageWidth, bounds[0], bounds[1], bounds[2])]
    end for
  end if
  return TableStatistics(table.tableId, populationRows, pageCount, sampleCount, columns)
end function

// Performs the analyze table operation for this module.
// Inputs: `table`, `rows`, `pageCount`. Returns the produced value or propagates a structured error from validation or delegated operations.
function analyzeTable(table, rows, pageCount)
  return analyzeSample(table, len(rows), rows, pageCount)
end function

// Encodes the d size.
// Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.
function encodedSize(state)
  size = 32
  for each table in state.tables
    size = size + TABLE_HEADER_BYTES + len(table.columns) * COLUMN_BYTES
  end for
  return size
end function

// Validates the native.
// Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.
function validateNative(value, operation, name)
  if typeof(value) != "int" or value < 0 or value > endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, operation, name + " must be non-negative native int") end if
  return true
end function

// Encodes the requested value.
// Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.
function encode(state)
  if state is not StatisticsCatalog then return fail(INVALID_ARGUMENT, "encode", "state must be StatisticsCatalog") end if
  if typeof(state.databaseId) != "bytes" or len(state.databaseId) != 16 then return fail(INVALID_ARGUMENT, "encode", "databaseId must be 16 bytes") end if
  validateNative(state.generation, "encode", "generation")
  size = encodedSize(state)
  payload = bytes(size, 0)
  copyBytes(payload, 0, state.databaseId, 0, 16)
  endian.writeU64LE(payload, 16, endian.uint64FromInt(state.generation))
  endian.writeU32LE(payload, 24, len(state.tables))
  endian.writeU32LE(payload, 28, 0)
  cursor = 32
  for each table in state.tables
    if table is not TableStatistics then return fail(INVALID_ARGUMENT, "encode", "invalid table statistics") end if
    validateNative(table.tableId, "encode", "tableId")
    validateNative(table.rowCount, "encode", "rowCount")
    validateNative(table.pageCount, "encode", "pageCount")
    validateNative(table.sampleCount, "encode", "sampleCount")
    if table.sampleCount > table.rowCount then return fail(INVALID_ARGUMENT, "encode", "sampleCount cannot exceed rowCount") end if
    if table.sampleCount > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "encode", "sampleCount must fit U32") end if
    if len(table.columns) > 65535 then return fail(INVALID_ARGUMENT, "encode", "too many column statistics") end if
    endian.writeU64LE(payload, cursor, endian.uint64FromInt(table.tableId))
    endian.writeU64LE(payload, cursor + 8, endian.uint64FromInt(table.rowCount))
    endian.writeU64LE(payload, cursor + 16, endian.uint64FromInt(table.pageCount))
    endian.writeU16LE(payload, cursor + 24, len(table.columns))
    endian.writeU16LE(payload, cursor + 26, 0)
    endian.writeU32LE(payload, cursor + 28, table.sampleCount)
    cursor = cursor + TABLE_HEADER_BYTES
    for each column in table.columns
      if column is not ColumnStatistics then return fail(INVALID_ARGUMENT, "encode", "invalid column statistics") end if
      if typeof(column.columnIndex) != "int" or column.columnIndex < 0 or column.columnIndex > 65535 then return fail(INVALID_ARGUMENT, "encode", "columnIndex must fit U16") end if
      validateNative(column.nullCount, "encode", "nullCount")
      validateNative(column.distinctCount, "encode", "distinctCount")
      if column.nullCount > table.rowCount or column.distinctCount > table.rowCount - column.nullCount then return fail(INVALID_ARGUMENT, "encode", "column counts exceed table population") end if
      if typeof(column.averageWidth) != "int" or column.averageWidth < 0 or column.averageWidth > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "encode", "averageWidth must fit U32") end if
      if typeof(column.hasIntegralBounds) != "bool" then return fail(INVALID_ARGUMENT, "encode", "hasIntegralBounds must be bool") end if
      if column.hasIntegralBounds and (typeof(column.minimumIntegral) != "int" or typeof(column.maximumIntegral) != "int" or column.minimumIntegral < endian.MIN_I32 or column.maximumIntegral > endian.MAX_I32 or column.minimumIntegral > column.maximumIntegral) then return fail(INVALID_ARGUMENT, "encode", "invalid integral bounds") end if
      endian.writeU16LE(payload, cursor, column.columnIndex)
      flags = 0
      if column.hasIntegralBounds then flags = COLUMN_FLAG_INTEGRAL_BOUNDS end if
      endian.writeU16LE(payload, cursor + 2, flags)
      endian.writeU64LE(payload, cursor + 4, endian.uint64FromInt(column.nullCount))
      endian.writeU64LE(payload, cursor + 12, endian.uint64FromInt(column.distinctCount))
      endian.writeU32LE(payload, cursor + 20, column.averageWidth)
      if column.hasIntegralBounds then
        endian.writeI32LE(payload, cursor + 24, column.minimumIntegral)
        endian.writeI32LE(payload, cursor + 28, column.maximumIntegral)
      else
        endian.writeU32LE(payload, cursor + 24, 0)
        endian.writeU32LE(payload, cursor + 28, 0)
      end if
      cursor = cursor + COLUMN_BYTES
    end for
  end for
  return checksum.encodeEnvelope(magic(), FORMAT_VERSION, RECORD_KIND, 0, payload)
end function

// Decodes the native.
// Inputs: `words`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeNative(words, operation, name)
  if words.high > endian.MAX_SCALAR_HIGH then return fail(UNSUPPORTED_FORMAT, operation, name + " exceeds native range") end if
  return endian.uint64ToInt(words)
end function

// Decodes the catalog.
// Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeCatalog(encoded)
  if typeof(encoded) != "bytes" or len(encoded) < 32 then return fail(CORRUPT_DATA, "decode", "encoded statistics are truncated") end if
  encodedVersion = endian.readU16LE(encoded, 8)
  if encodedVersion != LEGACY_FORMAT_VERSION and encodedVersion != SAMPLED_FORMAT_VERSION and encodedVersion != FORMAT_VERSION then return fail(UNSUPPORTED_FORMAT, "decode", "unsupported statistics version") end if
  envelope = checksum.decodeEnvelope(encoded, magic(), encodedVersion, RECORD_KIND)
  payload = envelope.payload
  if len(payload) < 32 then return fail(CORRUPT_DATA, "decode", "payload size is invalid") end if
  if endian.readU32LE(payload, 28) != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "reserved header is non-zero") end if
  state = StatisticsCatalog(slice(payload, 0, 16), decodeNative(endian.readU64LE(payload, 16), "decode", "generation"), [])
  tableCount = endian.readU32LE(payload, 24)
  state.tables = array(tableCount)
  cursor = 32
  if tableCount > 0 then
    for tableIndex = 0 to tableCount - 1
      if cursor > len(payload) - TABLE_HEADER_BYTES then return fail(CORRUPT_DATA, "decode", "table header is truncated") end if
    tableId = decodeNative(endian.readU64LE(payload, cursor), "decode", "tableId")
    rowCount = decodeNative(endian.readU64LE(payload, cursor + 8), "decode", "rowCount")
    pageCount = decodeNative(endian.readU64LE(payload, cursor + 16), "decode", "pageCount")
    columnCount = endian.readU16LE(payload, cursor + 24)
    if endian.readU16LE(payload, cursor + 26) != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "reserved table fields are non-zero") end if
    sampleCount = rowCount
    if sampleCount > endian.MAX_U32 then sampleCount = endian.MAX_U32 end if
    if encodedVersion >= SAMPLED_FORMAT_VERSION then
      sampleCount = endian.readU32LE(payload, cursor + 28)
      if sampleCount > rowCount then return fail(CORRUPT_DATA, "decode", "sampleCount exceeds rowCount") end if
    else if endian.readU32LE(payload, cursor + 28) != 0 then
      return fail(UNSUPPORTED_FORMAT, "decode", "legacy reserved table field is non-zero")
    end if
    cursor = cursor + TABLE_HEADER_BYTES
      columns = array(columnCount)
      if columnCount > 0 then
        for columnNumber = 0 to columnCount - 1
          if cursor > len(payload) - COLUMN_BYTES then return fail(CORRUPT_DATA, "decode", "column record is truncated") end if
          columnFlags = endian.readU16LE(payload, cursor + 2)
          if encodedVersion < FORMAT_VERSION and (columnFlags != 0 or endian.readU32LE(payload, cursor + 24) != 0 or endian.readU32LE(payload, cursor + 28) != 0) then return fail(UNSUPPORTED_FORMAT, "decode", "legacy reserved column fields are non-zero") end if
          if encodedVersion == FORMAT_VERSION and (columnFlags & ~COLUMN_FLAG_INTEGRAL_BOUNDS) != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "unknown column statistic flags") end if
          hasIntegralBounds = encodedVersion == FORMAT_VERSION and (columnFlags & COLUMN_FLAG_INTEGRAL_BOUNDS) != 0
          minimumIntegral = 0
          maximumIntegral = 0
          if hasIntegralBounds then
            minimumIntegral = endian.readI32LE(payload, cursor + 24)
            maximumIntegral = endian.readI32LE(payload, cursor + 28)
            if minimumIntegral > maximumIntegral then return fail(CORRUPT_DATA, "decode", "integral bounds are inverted") end if
          else if encodedVersion == FORMAT_VERSION and (endian.readU32LE(payload, cursor + 24) != 0 or endian.readU32LE(payload, cursor + 28) != 0) then
            return fail(UNSUPPORTED_FORMAT, "decode", "unflagged integral bounds are non-zero")
          end if
          decodedNullCount = decodeNative(endian.readU64LE(payload, cursor + 4), "decode", "nullCount")
          decodedDistinctCount = decodeNative(endian.readU64LE(payload, cursor + 12), "decode", "distinctCount")
          if decodedNullCount > rowCount or decodedDistinctCount > rowCount - decodedNullCount then return fail(CORRUPT_DATA, "decode", "column counts exceed table population") end if
          columns[columnNumber] = ColumnStatistics(
            endian.readU16LE(payload, cursor),
            decodedNullCount,
            decodedDistinctCount,
            endian.readU32LE(payload, cursor + 20),
            hasIntegralBounds,
            minimumIntegral,
            maximumIntegral
          )
          cursor = cursor + COLUMN_BYTES
        end for
      end if
      state.tables[tableIndex] = TableStatistics(tableId, rowCount, pageCount, sampleCount, columns)
    end for
  end if
  if cursor != len(payload) then return fail(CORRUPT_DATA, "decode", "trailing statistics bytes") end if
  return state
end function

// Keep the qualified public API statistics.decode(...), while every internal
// call uses an unambiguous helper. MiniLang also exposes decode(bytes) as a
// builtin, so an unqualified internal decode(...) call may otherwise bind to
// UTF-8 decoding instead of the statistics catalog decoder.
// Decodes the requested value.
// Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decode(encoded)
  return decodeCatalog(encoded)
end function

// Reads the whole.
// Inputs: `filePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readWhole(filePath)
  handle = file_api.openRead(filePath)
  size = file_api.size(handle)
  output = bytes(size, 0)
  if size > 0 then file_api.readExactAt(handle, 0, output, 0, size) end if
  file_api.close(handle)
  return output
end function

// Writes the atomic.
// Inputs: `filePath`, `encoded`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeAtomic(filePath, encoded)
  if typeof(encoded) != "bytes" then return fail(INVALID_ARGUMENT, "writeAtomic", "encoded must be bytes") end if
  temporary = filePath + ".new"
  if file_api.pathExists(temporary) then file_api.deletePath(temporary) end if
  handle = file_api.createNewDurable(temporary)
  writeResult = try(file_api.writeAt(handle, 0, encoded, 0, len(encoded)))
  if typeof(writeResult) == "error" then file_api.close(handle); file_api.deletePath(temporary); return writeResult end if
  flushResult = try(file_api.flush(handle))
  closeResult = try(file_api.close(handle))
  if typeof(flushResult) == "error" then file_api.deletePath(temporary); return flushResult end if
  if typeof(closeResult) == "error" then file_api.deletePath(temporary); return closeResult end if
  file_api.movePath(temporary, filePath, true)
  return true
end function

// Persists the requested value.
// Inputs: `databasePath`, `state`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function save(databasePath, state)
  if state is not StatisticsCatalog then return fail(INVALID_ARGUMENT, "save", "state must be StatisticsCatalog") end if
  previous = state.generation
  state.generation = previous + 1
  encoded = try(encode(state))
  if typeof(encoded) == "error" then state.generation = previous; return encoded end if
  written = try(writeAtomic(path(databasePath), encoded))
  if typeof(written) == "error" then state.generation = previous; return written end if
  return state.generation
end function

// Loads the or create.
// Inputs: `databasePath`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function loadOrCreate(databasePath, databaseId)
  filePath = path(databasePath)
  if not file_api.fileExists(filePath) then return create(databaseId) end if
  state = decodeCatalog(readWhole(filePath))
  if state is not StatisticsCatalog then return fail(CORRUPT_DATA, "loadOrCreate", "decoded statistics are not a StatisticsCatalog") end if
  if not bytesEqual(state.databaseId, databaseId) then return fail(CORRUPT_DATA, "loadOrCreate", "statistics belong to another database") end if
  return state
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "catalog.statistics"
end function

// Returns the milestone in which this component became available.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M17"
end function

// Reports whether this component is implemented.
// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
