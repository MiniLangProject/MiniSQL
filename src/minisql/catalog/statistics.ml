//! Provides minisql catalog statistics facilities for this project.

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

/// Persistent table/column statistics used by the M17 cost model. Statistics are

const INVALID_ARGUMENT = 9001
/// Defines the unsupported format constant used by the minisql catalog statistics module.
const UNSUPPORTED_FORMAT = 9003
/// Defines the corrupt data constant used by the minisql catalog statistics module.
const CORRUPT_DATA = 9004
/// Defines the io failure constant used by the minisql catalog statistics module.
const IO_FAILURE = 9005

/// Defines the format version constant used by the minisql catalog statistics module.
const FORMAT_VERSION = 5
/// Defines the distribution format version constant used by the minisql catalog statistics module.
const DISTRIBUTION_FORMAT_VERSION = 4
/// Defines the bounds format version constant used by the minisql catalog statistics module.
const BOUNDS_FORMAT_VERSION = 3
/// Defines the sampled format version constant used by the minisql catalog statistics module.
const SAMPLED_FORMAT_VERSION = 2
/// Defines the legacy format version constant used by the minisql catalog statistics module.
const LEGACY_FORMAT_VERSION = 1
/// Defines the record kind constant used by the minisql catalog statistics module.
const RECORD_KIND = 50
/// Defines the table header bytes constant used by the minisql catalog statistics module.
const TABLE_HEADER_BYTES = 32
/// Defines the legacy column bytes constant used by the minisql catalog statistics module.
const LEGACY_COLUMN_BYTES = 32
/// Defines the column bytes constant used by the minisql catalog statistics module.
const COLUMN_BYTES = 232
/// Defines the legacy column group bytes constant used by the minisql catalog statistics module.
const LEGACY_COLUMN_GROUP_BYTES = 32
/// Defines the column group bytes constant used by the minisql catalog statistics module.
const COLUMN_GROUP_BYTES = 128
/// Defines the distinct bucket count constant used by the minisql catalog statistics module.
const DISTINCT_BUCKET_COUNT = 257
/// Defines the hash mask constant used by the minisql catalog statistics module.
const HASH_MASK = 2147483647
/// Defines the column flag integral bounds constant used by the minisql catalog statistics module.
const COLUMN_FLAG_INTEGRAL_BOUNDS = 1
/// Defines the column flag hashed mcv constant used by the minisql catalog statistics module.
const COLUMN_FLAG_HASHED_MCV = 2
/// Defines the histogram bucket count constant used by the minisql catalog statistics module.
const HISTOGRAM_BUCKET_COUNT = 8
/// Defines the most common value count constant used by the minisql catalog statistics module.
const MOST_COMMON_VALUE_COUNT = 8
/// Defines the max column group width constant used by the minisql catalog statistics module.
const MAX_COLUMN_GROUP_WIDTH = 8

/// Defines the column statistics record used by this module.
struct ColumnStatistics
  /// Column index field of the column statistics.
  columnIndex
  /// Null count field of the column statistics.
  nullCount
  /// Distinct count field of the column statistics.
  distinctCount
  /// Average width field of the column statistics.
  averageWidth
  /// True when the sample supplied a comparable signed 32-bit minimum/maximum.
  hasIntegralBounds
  /// Smallest sampled SMALLINT, INTEGER, or DATE representation.
  minimumIntegral
  /// Largest sampled SMALLINT, INTEGER, or DATE representation.
  maximumIntegral
  /// Inclusive upper bound of each equi-width integral histogram bucket.
  histogramBounds
  /// Estimated cumulative non-NULL population at each histogram bound.
  histogramCounts
  /// Most frequent sampled integral values, ordered by descending frequency.
  mostCommonValues
  /// Estimated table-population frequency paired with mostCommonValues.
  mostCommonCounts
  /// True when mostCommonValues contains stable value hashes rather than values.
  mostCommonHashed
end struct

/// Captures joint distinctness for columns that form a composite index key.
/// These statistics prevent the optimizer from assuming that correlated key
/// columns are independent when estimating complete equality probes.
struct ColumnGroupStatistics
  /// Ordered table-local column indexes in the analyzed key prefix.
  columnIndexes
  /// Estimated number of distinct non-NULL tuples in the table population.
  distinctCount
  /// Stable hashes for the most frequent complete tuples.
  mostCommonHashes
  /// Population-scaled frequencies paired with mostCommonHashes.
  mostCommonCounts
end struct

/// Defines the table statistics record used by this module.
struct TableStatistics
  /// Table id field of the table statistics.
  tableId
  /// Row count field of the table statistics.
  rowCount
  /// Page count field of the table statistics.
  pageCount
  /// Number of decoded rows contributing column distribution statistics.
  sampleCount
  /// Columns field of the table statistics.
  columns
  /// Joint statistics for bounded-width composite index keys.
  columnGroups
end struct

/// Defines the statistics catalog record used by this module.
struct StatisticsCatalog
  /// Database id field of the statistics catalog.
  databaseId
  /// Generation field of the statistics catalog.
  generation
  /// Tables field of the statistics catalog.
  tables
end struct

/// Performs the fail operation for the minisql catalog statistics module.
/// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "catalog.statistics." + operation + ": " + message)
end function

/// Performs the integer divide operation for this module.
/// Inputs: `numerator`, `denominator`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param numerator numerator value consumed by this operation.
/// @param denominator denominator value consumed by this operation.
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

/// Returns a fresh copy of the on-disk format magic bytes.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function magic()
  return bytes("MSSTAT01")
end function

/// Evaluates whether the supplied input satisfies the column statistics predicate.
/// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
function isColumnStatistics(value)
  return value is ColumnStatistics
end function

/// Reports whether a value is a persisted joint-column statistic.
/// @param value Value consumed or transformed by the operation.
function isColumnGroupStatistics(value)
  return value is ColumnGroupStatistics
end function

/// Evaluates whether the supplied input satisfies the table statistics predicate.
/// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
function isTableStatistics(value)
  return value is TableStatistics
end function

/// Evaluates whether the supplied input satisfies the statistics catalog predicate.
/// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
function isStatisticsCatalog(value)
  return value is StatisticsCatalog
end function

/// Performs the bytesEqual operation for the minisql catalog statistics module.
/// Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

/// Creates create for the minisql catalog statistics module.
/// Inputs: `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param databaseId Identifier of database.
function create(databaseId)
  if typeof(databaseId) != "bytes" or len(databaseId) != 16 then return fail(INVALID_ARGUMENT, "create", "databaseId must be 16 bytes") end if
  return StatisticsCatalog(bytes(databaseId), 0, [])
end function

/// Performs the path operation for this module.
/// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param databasePath Path associated with database.
function path(databasePath)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "path", "databasePath must be non-empty") end if
  return catalog.joinPath(catalog.joinPath(databasePath, "catalog"), "statistics.tbl")
end function

/// Finds the table.
/// Inputs: `state`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param state Mutable state inspected or updated by the operation.
/// @param tableId Identifier of table.
function findTable(state, tableId)
  if state is not StatisticsCatalog or typeof(tableId) != "int" or tableId < 0 then return fail(INVALID_ARGUMENT, "findTable", "invalid arguments") end if
  for each table in state.tables
    if table.tableId == tableId then return table end if
  end for
  return void
end function

/// Replaces the table.
/// Inputs: `state`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param state Mutable state inspected or updated by the operation.
/// @param value Value consumed or transformed by the operation.
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

/// Performs the value width operation for this module.
/// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param value Value consumed or transformed by the operation.
function valueWidth(value)
  if not values.isSqlValue(value) or value.isNull then return 0 end if
  if typeof(value.value) == "string" then return len(bytes(value.value)) end if
  if typeof(value.value) == "bytes" then return len(value.value) end if
  return 8
end function

/// Compares the value.
/// Inputs: `left`, `right`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function sameValue(left, right)
  if left.isNull or right.isNull then return left.isNull and right.isNull end if
  return values.compareNonNull(left, right) == 0
end function

/// Hashes SQL values into deterministic collision buckets. Full SQL comparison
/// below remains authoritative, so hash collisions can only affect performance.
/// @param input input value consumed by this operation.
/// @param seed seed value consumed by this operation.
function hashBytes(input, seed)
  result = seed & HASH_MASK
  if len(input) > 0 then
    for index = 0 to len(input) - 1
      result = ((result ^ input[index]) * 16777619) & HASH_MASK
    end for
  end if
  return result
end function

/// Hashes one non-NULL SQL payload consistently with sameValue comparison.
/// @param value Value consumed or transformed by the operation.
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

/// Performs the distinct count operation for this module.
/// Inputs: `columnIndex`, `rows`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param columnIndex Zero-based index of column.
/// @param rows rows value consumed by this operation.
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

/// Reports whether a catalog column has an ordered numeric representation that
/// can use compact signed-32-bit quantile bounds when its sampled values fit.
/// @param column column value consumed by this operation.
function supportsIntegralBounds(column)
  return column.typeCode == types.SqlTypeKind.SmallInt or column.typeCode == types.SqlTypeKind.Integer or column.typeCode == types.SqlTypeKind.Date or column.typeCode == types.SqlTypeKind.Decimal
end function

/// Converts one ordered SQL value to the compact histogram scalar when possible.
/// @param candidate candidate value consumed by this operation.
function compactStatisticScalar(candidate)
  if typeof(candidate.value) == "int" then return candidate.value end if
  if endian.isInt64Words(candidate.value) then
    native = try(endian.int64ToInt(candidate.value))
    if typeof(native) != "error" then return native end if
  end if
  return void
end function

/// Finds sampled minimum and maximum values for a compact integral column. The
/// boolean prefix distinguishes an all-NULL sample from a legitimate [0, 0]
/// domain and keeps older statistics versions unambiguous.
/// @param columnIndex Zero-based index of column.
/// @param rows rows value consumed by this operation.
function integralBounds(columnIndex, rows)
  found = false
  minimum = 0
  maximum = 0
  for each row in rows
    candidate = row.values[columnIndex]
    if not candidate.isNull then
      scalar = compactStatisticScalar(candidate)
      if scalar is void or scalar < endian.MIN_I32 or scalar > endian.MAX_I32 then return [false, 0, 0] end if
      if not found or scalar < minimum then minimum = scalar end if
      if not found or scalar > maximum then maximum = scalar end if
      found = true
    end if
  end for
  return [found, minimum, maximum]
end function

/// In-place quicksort for the bounded ANALYZE scalar sample.
/// @param items Items consumed or updated by the operation.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function sortStatisticScalars(items, left, right)
  if left >= right then return items end if
  low = left
  high = right
  pivot = items[left + integerDivide(right - left, 2)]
  while low <= high
    while items[low] < pivot
      low = low + 1
    end while
    while items[high] > pivot
      high = high - 1
    end while
    if low <= high then
      temporary = items[low]
      items[low] = items[high]
      items[high] = temporary
      low = low + 1
      high = high - 1
    end if
  end while
  if left < high then sortStatisticScalars(items, left, high) end if
  if low < right then sortStatisticScalars(items, low, right) end if
  return items
end function

/// Builds an equi-depth cumulative histogram and an exact top-frequency list
/// from the bounded ANALYZE sample. Population frequencies are scaled once here,
/// allowing the optimizer hot path to use only small fixed arrays.
/// @param columnIndex Zero-based index of column.
/// @param rows rows value consumed by this operation.
/// @param populationRows populationRows value consumed by this operation.
/// @param bounds bounds value consumed by this operation.
function integralDistribution(columnIndex, rows, populationRows, bounds)
  if not bounds[0] or len(rows) == 0 then return [[], [], [], []] end if
  minimum = bounds[1]
  maximum = bounds[2]
  sorted = []
  for each row in rows
    candidate = row.values[columnIndex]
    if not candidate.isNull then sorted = sorted + [compactStatisticScalar(candidate)] end if
  end for
  if len(sorted) == 0 then return [[], [], [], []] end if
  sortStatisticScalars(sorted, 0, len(sorted) - 1)
  histogramBounds = []
  histogramCounts = []
  for bucketIndex = 0 to HISTOGRAM_BUCKET_COUNT - 1
    quantileIndex = integerDivide((len(sorted) - 1) * (bucketIndex + 1), HISTOGRAM_BUCKET_COUNT)
    upper = sorted[quantileIndex]
    if bucketIndex == HISTOGRAM_BUCKET_COUNT - 1 then upper = maximum end if
    cumulative = 0
    for each scalar in sorted
      if scalar <= upper then cumulative = cumulative + 1 end if
    end for
    histogramBounds = histogramBounds + [upper]
    histogramCounts = histogramCounts + [scaleSampleCount(cumulative, populationRows, len(rows))]
  end for

  frequencyBuckets = array(DISTINCT_BUCKET_COUNT, void)
  for each row in rows
    candidate = row.values[columnIndex]
    if not candidate.isNull then
      scalar = compactStatisticScalar(candidate)
      bucketIndex = (scalar & HASH_MASK) % DISTINCT_BUCKET_COUNT
      bucket = frequencyBuckets[bucketIndex]
      if bucket is void then bucket = [] end if
      found = false
      if len(bucket) > 0 then
        for entryIndex = 0 to len(bucket) - 1
          entry = bucket[entryIndex]
          if entry[0] == scalar then entry[1] = entry[1] + 1; bucket[entryIndex] = entry; found = true; break end if
        end for
      end if
      if not found then bucket = bucket + [[scalar, 1]] end if
      frequencyBuckets[bucketIndex] = bucket
    end if
  end for
  mostCommonValues = []
  mostCommonSampleCounts = []
  for each bucket in frequencyBuckets
    if bucket is not void then
      for each entry in bucket
        insertAt = len(mostCommonValues)
        if len(mostCommonSampleCounts) > 0 then
          for index = 0 to len(mostCommonSampleCounts) - 1
            if entry[1] > mostCommonSampleCounts[index] or (entry[1] == mostCommonSampleCounts[index] and entry[0] < mostCommonValues[index]) then insertAt = index; break end if
          end for
        end if
        if insertAt < MOST_COMMON_VALUE_COUNT then
          nextValues = []
          nextCounts = []
          outputIndex = 0
          inserted = false
          while outputIndex < len(mostCommonValues) or not inserted
            if not inserted and len(nextValues) == insertAt then
              nextValues = nextValues + [entry[0]]
              nextCounts = nextCounts + [entry[1]]
              inserted = true
            else
              if outputIndex >= len(mostCommonValues) then break end if
              nextValues = nextValues + [mostCommonValues[outputIndex]]
              nextCounts = nextCounts + [mostCommonSampleCounts[outputIndex]]
              outputIndex = outputIndex + 1
            end if
            if len(nextValues) >= MOST_COMMON_VALUE_COUNT then break end if
          end while
          mostCommonValues = nextValues
          mostCommonSampleCounts = nextCounts
        end if
      end for
    end if
  end for
  mostCommonCounts = []
  for each sampleFrequency in mostCommonSampleCounts
    mostCommonCounts = mostCommonCounts + [scaleSampleCount(sampleFrequency, populationRows, len(rows))]
  end for
  return [histogramBounds, histogramCounts, mostCommonValues, mostCommonCounts]
end function

/// Selects the eight most frequent stable hashes from a bounded sample.
/// @param hashes hashes value consumed by this operation.
/// @param populationRows populationRows value consumed by this operation.
/// @param sampleRows sampleRows value consumed by this operation.
function topHashFrequencies(hashes, populationRows, sampleRows)
  buckets = array(DISTINCT_BUCKET_COUNT, void)
  for each currentHash in hashes
    bucketIndex = currentHash % DISTINCT_BUCKET_COUNT
    bucket = buckets[bucketIndex]
    if bucket is void then bucket = [] end if
    matched = false
    if len(bucket) > 0 then
      for index = 0 to len(bucket) - 1
        if bucket[index][0] == currentHash then bucket[index][1] = bucket[index][1] + 1; matched = true; break end if
      end for
    end if
    if not matched then bucket = bucket + [[currentHash, 1]] end if
    buckets[bucketIndex] = bucket
  end for
  selected = []
  for each bucket in buckets
    if bucket is not void then
      for each entry in bucket
        insertAt = len(selected)
        if len(selected) > 0 then
          for index = 0 to len(selected) - 1
            if entry[1] > selected[index][1] or (entry[1] == selected[index][1] and entry[0] < selected[index][0]) then insertAt = index; break end if
          end for
        end if
        if insertAt < MOST_COMMON_VALUE_COUNT then
          next = []
          inserted = false
          outputIndex = 0
          while len(next) < MOST_COMMON_VALUE_COUNT and (outputIndex < len(selected) or not inserted)
            if not inserted and len(next) == insertAt then next = next + [entry]; inserted = true else next = next + [selected[outputIndex]]; outputIndex = outputIndex + 1 end if
          end while
          selected = next
        end if
      end for
    end if
  end for
  outputHashes = []
  outputCounts = []
  for each entry in selected
    outputHashes = outputHashes + [entry[0]]
    outputCounts = outputCounts + [scaleSampleCount(entry[1], populationRows, sampleRows)]
  end for
  return [outputHashes, outputCounts]
end function

/// Builds hash-based equality MCVs for text, binary, and wide decimal values.
/// @param columnIndex Zero-based index of column.
/// @param rows rows value consumed by this operation.
/// @param populationRows populationRows value consumed by this operation.
function hashedDistribution(columnIndex, rows, populationRows)
  hashes = []
  for each row in rows
    candidate = row.values[columnIndex]
    if not candidate.isNull then hashes = hashes + [hashValue(candidate)] end if
  end for
  return topHashFrequencies(hashes, populationRows, len(rows))
end function

/// Computes the stable hash shared by group ANALYZE and optimizer probes.
/// @param columnIndexes columnIndexes value consumed by this operation.
/// @param sqlValues sqlValues value consumed by this operation.
function tupleHash(columnIndexes, sqlValues)
  result = 2166136261 & HASH_MASK
  for each columnIndex in columnIndexes
    candidate = sqlValues[columnIndex]
    if candidate.isNull then return void end if
    result = ((result ^ hashValue(candidate)) * 16777619) & HASH_MASK
  end for
  return result
end function

/// Builds a bounded most-common tuple list for one analyzed column group.
/// @param columnIndexes columnIndexes value consumed by this operation.
/// @param rows rows value consumed by this operation.
/// @param populationRows populationRows value consumed by this operation.
function groupDistribution(columnIndexes, rows, populationRows)
  hashes = []
  for each row in rows
    currentHash = tupleHash(columnIndexes, row.values)
    if currentHash is not void then hashes = hashes + [currentHash] end if
  end for
  return topHashFrequencies(hashes, populationRows, len(rows))
end function

/// Counts distinct non-NULL tuples for one bounded-width column group. A hash
/// bucket narrows comparisons, while complete SQL value comparison remains the
/// authority and therefore makes collisions harmless.
/// @param columnIndexes columnIndexes value consumed by this operation.
/// @param rows rows value consumed by this operation.
function groupDistinctCount(columnIndexes, rows)
  buckets = array(DISTINCT_BUCKET_COUNT, void)
  count = 0
  for each row in rows
    tuple = []
      tupleHashValue = 2166136261 & HASH_MASK
    complete = true
    for each columnIndex in columnIndexes
      candidate = row.values[columnIndex]
      if candidate.isNull then complete = false; break end if
      tuple = tuple + [candidate]
      tupleHashValue = ((tupleHashValue ^ hashValue(candidate)) * 16777619) & HASH_MASK
    end for
    if complete then
      bucketIndex = tupleHashValue % DISTINCT_BUCKET_COUNT
      bucket = buckets[bucketIndex]
      if bucket is void then bucket = [] end if
      duplicate = false
      for each existing in bucket
        same = len(existing) == len(tuple)
        if same and len(tuple) > 0 then
          for index = 0 to len(tuple) - 1
            if not sameValue(existing[index], tuple[index]) then same = false; break end if
          end for
        end if
        if same then duplicate = true; break end if
      end for
      if not duplicate then bucket = bucket + [tuple]; buckets[bucketIndex] = bucket; count = count + 1 end if
    end if
  end for
  return count
end function

/// Scales a sample count without overflowing MiniLang's native integer range.
/// @param sampleValue sampleValue value consumed by this operation.
/// @param populationRows populationRows value consumed by this operation.
/// @param sampleRows sampleRows value consumed by this operation.
function scaleSampleCount(sampleValue, populationRows, sampleRows)
  if sampleRows == 0 then return 0 end if
  quotient = integerDivide(populationRows, sampleRows)
  remainder = populationRows - quotient * sampleRows
  return quotient * sampleValue + integerDivide(remainder * sampleValue, sampleRows)
end function

/// Builds bounded-memory statistics from a uniformly spaced sample. Small
/// tables, whose sample contains every row, remain exact. Low-cardinality values
/// seen repeatedly are treated as saturated; high-cardinality samples are scaled
/// conservatively and capped by the estimated non-NULL population.
/// @param table table value consumed by this operation.
/// @param populationRows populationRows value consumed by this operation.
/// @param rows rows value consumed by this operation.
/// @param pageCount Number of page to process.
/// @param columnGroups columnGroups value consumed by this operation.
function analyzeSampleWithGroups(table, populationRows, rows, pageCount, columnGroups)
  if typeof(table) != "struct" or typeof(populationRows) != "int" or populationRows < 0 or typeof(rows) != "array" or typeof(pageCount) != "int" or pageCount < 0 or typeof(columnGroups) != "array" then return fail(INVALID_ARGUMENT, "analyzeSampleWithGroups", "invalid arguments") end if
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
      distribution = integralDistribution(columnIndex, rows, populationRows, bounds)
      mostCommonHashed = false
      supportsHashed = types.isTextKind(table.columns[columnIndex].typeCode) or types.isBinaryKind(table.columns[columnIndex].typeCode) or table.columns[columnIndex].typeCode == types.SqlTypeKind.Decimal
      if not bounds[0] and supportsHashed then
        hashed = hashedDistribution(columnIndex, rows, populationRows)
        distribution = [[], [], hashed[0], hashed[1]]
        mostCommonHashed = true
      end if
      columns = columns + [ColumnStatistics(columnIndex, nullCount, distinctEstimate, averageWidth, bounds[0], bounds[1], bounds[2], distribution[0], distribution[1], distribution[2], distribution[3], mostCommonHashed)]
    end for
  end if
  groups = []
  for each columnIndexes in columnGroups
    if typeof(columnIndexes) != "array" or len(columnIndexes) < 2 or len(columnIndexes) > MAX_COLUMN_GROUP_WIDTH then return fail(INVALID_ARGUMENT, "analyzeSampleWithGroups", "column group width must be between two and eight") end if
    for each columnIndex in columnIndexes
      if typeof(columnIndex) != "int" or columnIndex < 0 or columnIndex >= len(table.columns) then return fail(INVALID_ARGUMENT, "analyzeSampleWithGroups", "column group index is out of range") end if
    end for
    sampledDistinct = groupDistinctCount(columnIndexes, rows)
    distinctEstimate = sampledDistinct
    if sampleCount < populationRows and sampleCount > 0 and sampledDistinct * 10 > sampleCount then distinctEstimate = scaleSampleCount(sampledDistinct, populationRows, sampleCount) end if
    if distinctEstimate > populationRows then distinctEstimate = populationRows end if
    groupMcv = groupDistribution(columnIndexes, rows, populationRows)
    groups = groups + [ColumnGroupStatistics(columnIndexes, distinctEstimate, groupMcv[0], groupMcv[1])]
  end for
  return TableStatistics(table.tableId, populationRows, pageCount, sampleCount, columns, groups)
end function

/// Retains the public single-column ANALYZE API used by older callers.
/// @param table table value consumed by this operation.
/// @param populationRows populationRows value consumed by this operation.
/// @param rows rows value consumed by this operation.
/// @param pageCount Number of page to process.
function analyzeSample(table, populationRows, rows, pageCount)
  return analyzeSampleWithGroups(table, populationRows, rows, pageCount, [])
end function

/// Performs the analyze table operation for this module.
/// Inputs: `table`, `rows`, `pageCount`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param table table value consumed by this operation.
/// @param rows rows value consumed by this operation.
/// @param pageCount Number of page to process.
function analyzeTable(table, rows, pageCount)
  return analyzeSample(table, len(rows), rows, pageCount)
end function

/// Encodes the d size.
/// Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param state Mutable state inspected or updated by the operation.
function encodedSize(state)
  size = 32
  for each table in state.tables
    size = size + TABLE_HEADER_BYTES + len(table.columns) * COLUMN_BYTES + len(table.columnGroups) * COLUMN_GROUP_BYTES
  end for
  return size
end function

/// Validates native for the minisql catalog statistics workflow.
/// Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
/// @param operation operation value consumed by this operation.
/// @param name Name of the affected item.
function validateNative(value, operation, name)
  if typeof(value) != "int" or value < 0 or value > endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, operation, name + " must be non-negative native int") end if
  return true
end function

/// Validates and encodes one fixed-width column-statistics record.
/// @param payload Mutable catalog payload receiving the record.
/// @param cursor Byte offset at which the record begins.
/// @param column Column statistics to validate and encode.
/// @param rowCount Owning table population used for range checks.
function encodeColumnRecord(payload, cursor, column, rowCount)
  if column is not ColumnStatistics then return fail(INVALID_ARGUMENT, "encode", "invalid column statistics") end if
  if typeof(column.columnIndex) != "int" or column.columnIndex < 0 or column.columnIndex > 65535 then return fail(INVALID_ARGUMENT, "encode", "columnIndex must fit U16") end if
  validateNative(column.nullCount, "encode", "nullCount")
  validateNative(column.distinctCount, "encode", "distinctCount")
  if column.nullCount > rowCount or column.distinctCount > rowCount - column.nullCount then return fail(INVALID_ARGUMENT, "encode", "column counts exceed table population") end if
  if typeof(column.averageWidth) != "int" or column.averageWidth < 0 or column.averageWidth > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "encode", "averageWidth must fit U32") end if
  if typeof(column.hasIntegralBounds) != "bool" then return fail(INVALID_ARGUMENT, "encode", "hasIntegralBounds must be bool") end if
  if column.hasIntegralBounds and (typeof(column.minimumIntegral) != "int" or typeof(column.maximumIntegral) != "int" or column.minimumIntegral < endian.MIN_I32 or column.maximumIntegral > endian.MAX_I32 or column.minimumIntegral > column.maximumIntegral) then return fail(INVALID_ARGUMENT, "encode", "invalid integral bounds") end if
  if typeof(column.histogramBounds) != "array" or typeof(column.histogramCounts) != "array" or len(column.histogramBounds) != len(column.histogramCounts) or len(column.histogramBounds) > HISTOGRAM_BUCKET_COUNT then return fail(INVALID_ARGUMENT, "encode", "invalid integral histogram") end if
  if typeof(column.mostCommonValues) != "array" or typeof(column.mostCommonCounts) != "array" or len(column.mostCommonValues) != len(column.mostCommonCounts) or len(column.mostCommonValues) > MOST_COMMON_VALUE_COUNT then return fail(INVALID_ARGUMENT, "encode", "invalid most-common-values list") end if
  if typeof(column.mostCommonHashed) != "bool" then return fail(INVALID_ARGUMENT, "encode", "mostCommonHashed must be bool") end if
  if len(column.histogramBounds) > 0 and not column.hasIntegralBounds then return fail(INVALID_ARGUMENT, "encode", "histograms require bounds") end if
  if len(column.mostCommonValues) > 0 and not column.hasIntegralBounds and not column.mostCommonHashed then return fail(INVALID_ARGUMENT, "encode", "unhashed most-common values require bounds") end if
  endian.writeU16LE(payload, cursor, column.columnIndex)
  flags = 0
  if column.hasIntegralBounds then flags = COLUMN_FLAG_INTEGRAL_BOUNDS end if
  if column.mostCommonHashed then flags = flags | COLUMN_FLAG_HASHED_MCV end if
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
  payload[cursor + 32] = len(column.histogramBounds)
  payload[cursor + 33] = len(column.mostCommonValues)
  endian.writeU16LE(payload, cursor + 34, 0)
  previousBound = endian.MIN_I32
  previousCount = 0
  if len(column.histogramBounds) > 0 then
    for index = 0 to len(column.histogramBounds) - 1
      currentBound = column.histogramBounds[index]
      currentCount = column.histogramCounts[index]
      if typeof(currentBound) != "int" or currentBound < previousBound or currentBound < column.minimumIntegral or currentBound > column.maximumIntegral then return fail(INVALID_ARGUMENT, "encode", "histogram bounds are not ordered") end if
      validateNative(currentCount, "encode", "histogram count")
      if currentCount < previousCount or currentCount > rowCount - column.nullCount then return fail(INVALID_ARGUMENT, "encode", "histogram counts are not cumulative population counts") end if
      endian.writeI32LE(payload, cursor + 36 + index * 12, currentBound)
      endian.writeU64LE(payload, cursor + 40 + index * 12, endian.uint64FromInt(currentCount))
      previousBound = currentBound
      previousCount = currentCount
    end for
  end if
  if len(column.mostCommonValues) > 0 then
    for index = 0 to len(column.mostCommonValues) - 1
      commonValue = column.mostCommonValues[index]
      commonCount = column.mostCommonCounts[index]
      if typeof(commonValue) != "int" then return fail(INVALID_ARGUMENT, "encode", "most-common value must be an integer representation") end if
      if column.mostCommonHashed and (commonValue < 0 or commonValue > HASH_MASK) then return fail(INVALID_ARGUMENT, "encode", "most-common hash is outside range") end if
      if not column.mostCommonHashed and (commonValue < column.minimumIntegral or commonValue > column.maximumIntegral) then return fail(INVALID_ARGUMENT, "encode", "most-common value is outside bounds") end if
      validateNative(commonCount, "encode", "most-common count")
      if commonCount > rowCount - column.nullCount then return fail(INVALID_ARGUMENT, "encode", "most-common count exceeds population") end if
      endian.writeI32LE(payload, cursor + 132 + index * 12, commonValue)
      endian.writeU64LE(payload, cursor + 136 + index * 12, endian.uint64FromInt(commonCount))
    end for
  end if
  endian.writeU32LE(payload, cursor + 228, 0)
  return cursor + COLUMN_BYTES
end function

/// Validates and encodes one fixed-width multi-column statistics record.
/// @param payload Mutable catalog payload receiving the record.
/// @param cursor Byte offset at which the record begins.
/// @param group Multi-column statistics to validate and encode.
/// @param rowCount Owning table population used for range checks.
function encodeColumnGroupRecord(payload, cursor, group, rowCount)
  if group is not ColumnGroupStatistics or typeof(group.columnIndexes) != "array" or len(group.columnIndexes) < 2 or len(group.columnIndexes) > MAX_COLUMN_GROUP_WIDTH then return fail(INVALID_ARGUMENT, "encode", "invalid column-group statistics") end if
  if typeof(group.mostCommonHashes) != "array" or typeof(group.mostCommonCounts) != "array" or len(group.mostCommonHashes) != len(group.mostCommonCounts) or len(group.mostCommonHashes) > MOST_COMMON_VALUE_COUNT then return fail(INVALID_ARGUMENT, "encode", "invalid column-group MCV list") end if
  validateNative(group.distinctCount, "encode", "column-group distinctCount")
  if group.distinctCount > rowCount then return fail(INVALID_ARGUMENT, "encode", "column-group distinctCount exceeds table population") end if
  payload[cursor] = len(group.columnIndexes)
  payload[cursor + 1] = 0
  endian.writeU16LE(payload, cursor + 2, 0)
  for index = 0 to len(group.columnIndexes) - 1
    columnIndex = group.columnIndexes[index]
    if typeof(columnIndex) != "int" or columnIndex < 0 or columnIndex > 65535 then return fail(INVALID_ARGUMENT, "encode", "column-group index must fit U16") end if
    endian.writeU16LE(payload, cursor + 4 + index * 2, columnIndex)
  end for
  endian.writeU64LE(payload, cursor + 20, endian.uint64FromInt(group.distinctCount))
  payload[cursor + 28] = len(group.mostCommonHashes)
  payload[cursor + 29] = 0
  endian.writeU16LE(payload, cursor + 30, 0)
  if len(group.mostCommonHashes) > 0 then
    for index = 0 to len(group.mostCommonHashes) - 1
      currentHash = group.mostCommonHashes[index]
      currentCount = group.mostCommonCounts[index]
      if typeof(currentHash) != "int" or currentHash < 0 or currentHash > HASH_MASK then return fail(INVALID_ARGUMENT, "encode", "column-group MCV hash is outside range") end if
      validateNative(currentCount, "encode", "column-group MCV count")
      if currentCount > rowCount then return fail(INVALID_ARGUMENT, "encode", "column-group MCV count exceeds population") end if
      endian.writeU32LE(payload, cursor + 32 + index * 12, currentHash)
      endian.writeU64LE(payload, cursor + 36 + index * 12, endian.uint64FromInt(currentCount))
    end for
  end if
  return cursor + COLUMN_GROUP_BYTES
end function

/// Encodes one table header followed by all of its column and group records.
/// @param payload Mutable catalog payload receiving the table record.
/// @param cursor Byte offset at which the table header begins.
/// @param table Table statistics and nested records to encode.
function encodeTableRecord(payload, cursor, table)
  if table is not TableStatistics then return fail(INVALID_ARGUMENT, "encode", "invalid table statistics") end if
  validateNative(table.tableId, "encode", "tableId")
  validateNative(table.rowCount, "encode", "rowCount")
  validateNative(table.pageCount, "encode", "pageCount")
  validateNative(table.sampleCount, "encode", "sampleCount")
  if table.sampleCount > table.rowCount then return fail(INVALID_ARGUMENT, "encode", "sampleCount cannot exceed rowCount") end if
  if table.sampleCount > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "encode", "sampleCount must fit U32") end if
  if len(table.columns) > 65535 then return fail(INVALID_ARGUMENT, "encode", "too many column statistics") end if
  if typeof(table.columnGroups) != "array" or len(table.columnGroups) > 65535 then return fail(INVALID_ARGUMENT, "encode", "too many column-group statistics") end if
  endian.writeU64LE(payload, cursor, endian.uint64FromInt(table.tableId))
  endian.writeU64LE(payload, cursor + 8, endian.uint64FromInt(table.rowCount))
  endian.writeU64LE(payload, cursor + 16, endian.uint64FromInt(table.pageCount))
  endian.writeU16LE(payload, cursor + 24, len(table.columns))
  endian.writeU16LE(payload, cursor + 26, len(table.columnGroups))
  endian.writeU32LE(payload, cursor + 28, table.sampleCount)
  cursor = cursor + TABLE_HEADER_BYTES
  for each column in table.columns
    cursor = encodeColumnRecord(payload, cursor, column, table.rowCount)
  end for
  for each group in table.columnGroups
    cursor = encodeColumnGroupRecord(payload, cursor, group, table.rowCount)
  end for
  return cursor
end function

/// Encodes encode for the minisql catalog statistics workflow.
/// Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param state Mutable state inspected or updated by the operation.
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
    cursor = encodeTableRecord(payload, cursor, table)
  end for
  return checksum.encodeEnvelope(magic(), FORMAT_VERSION, RECORD_KIND, 0, payload)
end function

/// Decodes native for the minisql catalog statistics workflow.
/// Inputs: `words`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param words words value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param name Name of the affected item.
function decodeNative(words, operation, name)
  if words.high > endian.MAX_SCALAR_HIGH then return fail(UNSUPPORTED_FORMAT, operation, name + " exceeds native range") end if
  return endian.uint64ToInt(words)
end function

/// Decodes one column record directly into its preallocated destination slot.
/// @param payload Validated statistics payload being decoded.
/// @param cursor Byte offset at which the column record begins.
/// @param encodedVersion On-disk statistics format version.
/// @param rowCount Owning table population used for validation.
/// @param destination Preallocated column-statistics array.
/// @param destinationIndex Slot receiving the decoded record.
function decodeColumnRecord(payload, cursor, encodedVersion, rowCount, destination, destinationIndex)
  columnBytes = LEGACY_COLUMN_BYTES
  if encodedVersion >= DISTRIBUTION_FORMAT_VERSION then columnBytes = COLUMN_BYTES end if
  if cursor > len(payload) - columnBytes then return fail(CORRUPT_DATA, "decode", "column record is truncated") end if
  columnFlags = endian.readU16LE(payload, cursor + 2)
  if encodedVersion < BOUNDS_FORMAT_VERSION and (columnFlags != 0 or endian.readU32LE(payload, cursor + 24) != 0 or endian.readU32LE(payload, cursor + 28) != 0) then return fail(UNSUPPORTED_FORMAT, "decode", "legacy reserved column fields are non-zero") end if
  allowedFlags = COLUMN_FLAG_INTEGRAL_BOUNDS
  if encodedVersion >= FORMAT_VERSION then allowedFlags = allowedFlags | COLUMN_FLAG_HASHED_MCV end if
  if encodedVersion >= BOUNDS_FORMAT_VERSION and (columnFlags & ~allowedFlags) != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "unknown column statistic flags") end if
  hasIntegralBounds = encodedVersion >= BOUNDS_FORMAT_VERSION and (columnFlags & COLUMN_FLAG_INTEGRAL_BOUNDS) != 0
  mostCommonHashed = encodedVersion >= FORMAT_VERSION and (columnFlags & COLUMN_FLAG_HASHED_MCV) != 0
  minimumIntegral = 0
  maximumIntegral = 0
  if hasIntegralBounds then
    minimumIntegral = endian.readI32LE(payload, cursor + 24)
    maximumIntegral = endian.readI32LE(payload, cursor + 28)
    if minimumIntegral > maximumIntegral then return fail(CORRUPT_DATA, "decode", "integral bounds are inverted") end if
  else if encodedVersion >= BOUNDS_FORMAT_VERSION and (endian.readU32LE(payload, cursor + 24) != 0 or endian.readU32LE(payload, cursor + 28) != 0) then
    return fail(UNSUPPORTED_FORMAT, "decode", "unflagged integral bounds are non-zero")
  end if
  histogramBounds = []
  histogramCounts = []
  mostCommonValues = []
  mostCommonCounts = []
  if encodedVersion >= DISTRIBUTION_FORMAT_VERSION then
    histogramCount = payload[cursor + 32]
    mostCommonCount = payload[cursor + 33]
    if histogramCount > HISTOGRAM_BUCKET_COUNT or mostCommonCount > MOST_COMMON_VALUE_COUNT or endian.readU16LE(payload, cursor + 34) != 0 or endian.readU32LE(payload, cursor + 228) != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "invalid distribution header") end if
    previousBound = endian.MIN_I32
    previousCount = 0
    if histogramCount > 0 then
      if not hasIntegralBounds then return fail(CORRUPT_DATA, "decode", "histogram lacks integral bounds") end if
      for index = 0 to histogramCount - 1
        currentBound = endian.readI32LE(payload, cursor + 36 + index * 12)
        currentCount = decodeNative(endian.readU64LE(payload, cursor + 40 + index * 12), "decode", "histogram count")
        if currentBound < previousBound or currentBound < minimumIntegral or currentBound > maximumIntegral or currentCount < previousCount then return fail(CORRUPT_DATA, "decode", "histogram is not cumulative and ordered") end if
        histogramBounds = histogramBounds + [currentBound]
        histogramCounts = histogramCounts + [currentCount]
        previousBound = currentBound
        previousCount = currentCount
      end for
    end if
    if mostCommonCount > 0 then
      if not hasIntegralBounds and not mostCommonHashed then return fail(CORRUPT_DATA, "decode", "most-common values lack a representation flag") end if
      for index = 0 to mostCommonCount - 1
        commonValue = endian.readI32LE(payload, cursor + 132 + index * 12)
        commonCount = decodeNative(endian.readU64LE(payload, cursor + 136 + index * 12), "decode", "most-common count")
        if mostCommonHashed and (commonValue < 0 or commonValue > HASH_MASK) then return fail(CORRUPT_DATA, "decode", "most-common hash is outside range") end if
        if not mostCommonHashed and (commonValue < minimumIntegral or commonValue > maximumIntegral) then return fail(CORRUPT_DATA, "decode", "most-common value is outside bounds") end if
        mostCommonValues = mostCommonValues + [commonValue]
        mostCommonCounts = mostCommonCounts + [commonCount]
      end for
    end if
  end if
  decodedNullCount = decodeNative(endian.readU64LE(payload, cursor + 4), "decode", "nullCount")
  decodedDistinctCount = decodeNative(endian.readU64LE(payload, cursor + 12), "decode", "distinctCount")
  if decodedNullCount > rowCount or decodedDistinctCount > rowCount - decodedNullCount then return fail(CORRUPT_DATA, "decode", "column counts exceed table population") end if
  for each distributionCount in histogramCounts
    if distributionCount > rowCount - decodedNullCount then return fail(CORRUPT_DATA, "decode", "histogram count exceeds non-NULL population") end if
  end for
  for each commonCount in mostCommonCounts
    if commonCount > rowCount - decodedNullCount then return fail(CORRUPT_DATA, "decode", "most-common count exceeds non-NULL population") end if
  end for
  destination[destinationIndex] = ColumnStatistics(endian.readU16LE(payload, cursor), decodedNullCount, decodedDistinctCount, endian.readU32LE(payload, cursor + 20), hasIntegralBounds, minimumIntegral, maximumIntegral, histogramBounds, histogramCounts, mostCommonValues, mostCommonCounts, mostCommonHashed)
  return cursor + columnBytes
end function

/// Decodes one column-group record directly into its preallocated destination.
/// @param payload Validated statistics payload being decoded.
/// @param cursor Byte offset at which the group record begins.
/// @param encodedVersion On-disk statistics format version.
/// @param rowCount Owning table population used for validation.
/// @param destination Preallocated column-group statistics array.
/// @param destinationIndex Slot receiving the decoded record.
function decodeColumnGroupRecord(payload, cursor, encodedVersion, rowCount, destination, destinationIndex)
  groupBytes = LEGACY_COLUMN_GROUP_BYTES
  if encodedVersion >= FORMAT_VERSION then groupBytes = COLUMN_GROUP_BYTES end if
  if cursor > len(payload) - groupBytes then return fail(CORRUPT_DATA, "decode", "column-group record is truncated") end if
  groupWidth = payload[cursor]
  if groupWidth < 2 or groupWidth > MAX_COLUMN_GROUP_WIDTH or payload[cursor + 1] != 0 or endian.readU16LE(payload, cursor + 2) != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "invalid column-group header") end if
  columnIndexes = []
  for index = 0 to groupWidth - 1
    columnIndexes = columnIndexes + [endian.readU16LE(payload, cursor + 4 + index * 2)]
  end for
  groupDistinct = decodeNative(endian.readU64LE(payload, cursor + 20), "decode", "column-group distinctCount")
  if groupDistinct > rowCount then return fail(CORRUPT_DATA, "decode", "column-group distinctCount exceeds population") end if
  groupHashes = []
  groupCounts = []
  if encodedVersion >= FORMAT_VERSION then
    mcvCount = payload[cursor + 28]
    if mcvCount > MOST_COMMON_VALUE_COUNT or payload[cursor + 29] != 0 or endian.readU16LE(payload, cursor + 30) != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "invalid column-group MCV header") end if
    if mcvCount > 0 then
      for index = 0 to mcvCount - 1
        currentHash = endian.readU32LE(payload, cursor + 32 + index * 12)
        currentCount = decodeNative(endian.readU64LE(payload, cursor + 36 + index * 12), "decode", "column-group MCV count")
        if currentHash > HASH_MASK or currentCount > rowCount then return fail(CORRUPT_DATA, "decode", "column-group MCV value is invalid") end if
        groupHashes = groupHashes + [currentHash]
        groupCounts = groupCounts + [currentCount]
      end for
    end if
  else if endian.readU32LE(payload, cursor + 28) != 0 then
    return fail(UNSUPPORTED_FORMAT, "decode", "legacy column-group reserved field is non-zero")
  end if
  destination[destinationIndex] = ColumnGroupStatistics(columnIndexes, groupDistinct, groupHashes, groupCounts)
  return cursor + groupBytes
end function

/// Decodes the catalog.
/// Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param encoded encoded value consumed by this operation.
function decodeCatalog(encoded)
  if typeof(encoded) != "bytes" or len(encoded) < 32 then return fail(CORRUPT_DATA, "decode", "encoded statistics are truncated") end if
  encodedVersion = endian.readU16LE(encoded, 8)
  if encodedVersion != LEGACY_FORMAT_VERSION and encodedVersion != SAMPLED_FORMAT_VERSION and encodedVersion != BOUNDS_FORMAT_VERSION and encodedVersion != DISTRIBUTION_FORMAT_VERSION and encodedVersion != FORMAT_VERSION then return fail(UNSUPPORTED_FORMAT, "decode", "unsupported statistics version") end if
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
    columnGroupCount = 0
    if encodedVersion >= DISTRIBUTION_FORMAT_VERSION then
      columnGroupCount = endian.readU16LE(payload, cursor + 26)
    else if endian.readU16LE(payload, cursor + 26) != 0 then
      return fail(UNSUPPORTED_FORMAT, "decode", "reserved table fields are non-zero")
    end if
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
          cursor = decodeColumnRecord(payload, cursor, encodedVersion, rowCount, columns, columnNumber)
        end for
      end if
      columnGroups = []
      if columnGroupCount > 0 then
        columnGroups = array(columnGroupCount)
        for groupIndex = 0 to columnGroupCount - 1
          cursor = decodeColumnGroupRecord(payload, cursor, encodedVersion, rowCount, columnGroups, groupIndex)
        end for
      end if
      state.tables[tableIndex] = TableStatistics(tableId, rowCount, pageCount, sampleCount, columns, columnGroups)
    end for
  end if
  if cursor != len(payload) then return fail(CORRUPT_DATA, "decode", "trailing statistics bytes") end if
  return state
end function

/// Keep the qualified public API statistics.decode(...), while every internal
/// call uses an unambiguous helper. MiniLang also exposes decode(bytes) as a
/// builtin, so an unqualified internal decode(...) call may otherwise bind to
/// UTF-8 decoding instead of the statistics catalog decoder.
/// Decodes the requested value.
/// Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param encoded encoded value consumed by this operation.
function decode(encoded)
  return decodeCatalog(encoded)
end function

/// Reads whole for the minisql catalog statistics workflow.
/// Inputs: `filePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param filePath Path associated with file.
function readWhole(filePath)
  handle = file_api.openRead(filePath)
  size = file_api.size(handle)
  output = bytes(size, 0)
  if size > 0 then file_api.readExactAt(handle, 0, output, 0, size) end if
  file_api.close(handle)
  return output
end function

/// Writes the atomic.
/// Inputs: `filePath`, `encoded`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param filePath Path associated with file.
/// @param encoded encoded value consumed by this operation.
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

/// Persists the requested value.
/// Inputs: `databasePath`, `state`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param databasePath Path associated with database.
/// @param state Mutable state inspected or updated by the operation.
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

/// Loads the or create.
/// Inputs: `databasePath`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param databasePath Path associated with database.
/// @param databaseId Identifier of database.
function loadOrCreate(databasePath, databaseId)
  filePath = path(databasePath)
  if not file_api.fileExists(filePath) then return create(databaseId) end if
  state = decodeCatalog(readWhole(filePath))
  if state is not StatisticsCatalog then return fail(CORRUPT_DATA, "loadOrCreate", "decoded statistics are not a StatisticsCatalog") end if
  if not bytesEqual(state.databaseId, databaseId) then return fail(CORRUPT_DATA, "loadOrCreate", "statistics belong to another database") end if
  return state
end function

/// Performs the componentName operation for the minisql catalog statistics module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "catalog.statistics"
end function

/// Performs the targetMilestone operation for the minisql catalog statistics module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M17"
end function

/// Returns whether implemented satisfies the condition required by the minisql catalog statistics module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
