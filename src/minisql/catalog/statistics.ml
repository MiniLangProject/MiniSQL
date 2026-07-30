package minisql.catalog.statistics

import minisql.catalog.catalog as catalog
import minisql.common.endian as endian
import minisql.platform.file as file_api
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

const FORMAT_VERSION = 1
const RECORD_KIND = 50
const MAX_STATISTICS_BYTES = 1048576
const TABLE_HEADER_BYTES = 32
const COLUMN_BYTES = 32

struct ColumnStatistics
  columnIndex
  nullCount
  distinctCount
  averageWidth
end struct

struct TableStatistics
  tableId
  rowCount
  pageCount
  columns
end struct

struct StatisticsCatalog
  databaseId
  generation
  tables
end struct

function fail(code, operation, message)
  return error(code, "catalog.statistics." + operation + ": " + message)
end function

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

function magic()
  return bytes("MSSTAT01")
end function

function isColumnStatistics(value)
  return value is ColumnStatistics
end function

function isTableStatistics(value)
  return value is TableStatistics
end function

function isStatisticsCatalog(value)
  return value is StatisticsCatalog
end function

function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

function create(databaseId)
  if typeof(databaseId) != "bytes" or len(databaseId) != 16 then return fail(INVALID_ARGUMENT, "create", "databaseId must be 16 bytes") end if
  return StatisticsCatalog(bytes(databaseId), 0, [])
end function

function path(databasePath)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "path", "databasePath must be non-empty") end if
  return catalog.joinPath(catalog.joinPath(databasePath, "catalog"), "statistics.tbl")
end function

function findTable(state, tableId)
  if state is not StatisticsCatalog or typeof(tableId) != "int" or tableId < 0 then return fail(INVALID_ARGUMENT, "findTable", "invalid arguments") end if
  for each table in state.tables
    if table.tableId == tableId then return table end if
  end for
  return void
end function

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

function valueWidth(value)
  if not values.isSqlValue(value) or value.isNull then return 0 end if
  if typeof(value.value) == "string" then return len(bytes(value.value)) end if
  if typeof(value.value) == "bytes" then return len(value.value) end if
  return 8
end function

function sameValue(left, right)
  if left.isNull or right.isNull then return left.isNull and right.isNull end if
  return values.compareNonNull(left, right) == 0
end function

function distinctCount(columnIndex, rows)
  distinct = []
  for each row in rows
    candidate = row.values[columnIndex]
    if not candidate.isNull then
      duplicate = false
      for each existing in distinct
        if sameValue(candidate, existing) then duplicate = true; break end if
      end for
      if not duplicate then distinct = distinct + [candidate] end if
    end if
  end for
  return len(distinct)
end function

function analyzeTable(table, rows, pageCount)
  if typeof(table) != "struct" or typeof(rows) != "array" or typeof(pageCount) != "int" or pageCount < 0 then return fail(INVALID_ARGUMENT, "analyzeTable", "invalid arguments") end if
  columns = []
  if len(table.columns) > 0 then
    for columnIndex = 0 to len(table.columns) - 1
      nullCount = 0
      width = 0
      nonNull = 0
      for each row in rows
        if typeof(row) != "struct" or typeof(row.values) != "array" or len(row.values) != len(table.columns) then return fail(INVALID_ARGUMENT, "analyzeTable", "row shape mismatch") end if
        value = row.values[columnIndex]
        if value.isNull then
          nullCount = nullCount + 1
        else
          nonNull = nonNull + 1
          width = width + valueWidth(value)
        end if
      end for
      averageWidth = 0
      if nonNull > 0 then averageWidth = integerDivide(width, nonNull) end if
      columns = columns + [ColumnStatistics(columnIndex, nullCount, distinctCount(columnIndex, rows), averageWidth)]
    end for
  end if
  return TableStatistics(table.tableId, len(rows), pageCount, columns)
end function

function encodedSize(state)
  size = 32
  for each table in state.tables
    size = size + TABLE_HEADER_BYTES + len(table.columns) * COLUMN_BYTES
  end for
  return size
end function

function validateNative(value, operation, name)
  if typeof(value) != "int" or value < 0 or value > endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, operation, name + " must be non-negative native int") end if
  return true
end function

function encode(state)
  if state is not StatisticsCatalog then return fail(INVALID_ARGUMENT, "encode", "state must be StatisticsCatalog") end if
  if typeof(state.databaseId) != "bytes" or len(state.databaseId) != 16 then return fail(INVALID_ARGUMENT, "encode", "databaseId must be 16 bytes") end if
  validateNative(state.generation, "encode", "generation")
  if len(state.tables) > 65535 then return fail(INVALID_ARGUMENT, "encode", "too many tables") end if
  size = encodedSize(state)
  if size > MAX_STATISTICS_BYTES then return fail(INVALID_ARGUMENT, "encode", "statistics exceed size limit") end if
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
    if len(table.columns) > 65535 then return fail(INVALID_ARGUMENT, "encode", "too many column statistics") end if
    endian.writeU64LE(payload, cursor, endian.uint64FromInt(table.tableId))
    endian.writeU64LE(payload, cursor + 8, endian.uint64FromInt(table.rowCount))
    endian.writeU64LE(payload, cursor + 16, endian.uint64FromInt(table.pageCount))
    endian.writeU16LE(payload, cursor + 24, len(table.columns))
    endian.writeU16LE(payload, cursor + 26, 0)
    endian.writeU32LE(payload, cursor + 28, 0)
    cursor = cursor + TABLE_HEADER_BYTES
    for each column in table.columns
      if column is not ColumnStatistics then return fail(INVALID_ARGUMENT, "encode", "invalid column statistics") end if
      if typeof(column.columnIndex) != "int" or column.columnIndex < 0 or column.columnIndex > 65535 then return fail(INVALID_ARGUMENT, "encode", "columnIndex must fit U16") end if
      validateNative(column.nullCount, "encode", "nullCount")
      validateNative(column.distinctCount, "encode", "distinctCount")
      if typeof(column.averageWidth) != "int" or column.averageWidth < 0 or column.averageWidth > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "encode", "averageWidth must fit U32") end if
      endian.writeU16LE(payload, cursor, column.columnIndex)
      endian.writeU16LE(payload, cursor + 2, 0)
      endian.writeU64LE(payload, cursor + 4, endian.uint64FromInt(column.nullCount))
      endian.writeU64LE(payload, cursor + 12, endian.uint64FromInt(column.distinctCount))
      endian.writeU32LE(payload, cursor + 20, column.averageWidth)
      endian.writeU32LE(payload, cursor + 24, 0)
      endian.writeU32LE(payload, cursor + 28, 0)
      cursor = cursor + COLUMN_BYTES
    end for
  end for
  return checksum.encodeEnvelope(magic(), FORMAT_VERSION, RECORD_KIND, 0, payload)
end function

function decodeNative(words, operation, name)
  if words.high > endian.MAX_SCALAR_HIGH then return fail(UNSUPPORTED_FORMAT, operation, name + " exceeds native range") end if
  return endian.uint64ToInt(words)
end function

function decodeCatalog(encoded)
  envelope = checksum.decodeEnvelope(encoded, magic(), FORMAT_VERSION, RECORD_KIND)
  payload = envelope.payload
  if len(payload) < 32 or len(payload) > MAX_STATISTICS_BYTES then return fail(CORRUPT_DATA, "decode", "payload size is invalid") end if
  if endian.readU32LE(payload, 28) != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "reserved header is non-zero") end if
  state = StatisticsCatalog(slice(payload, 0, 16), decodeNative(endian.readU64LE(payload, 16), "decode", "generation"), [])
  tableCount = endian.readU32LE(payload, 24)
  cursor = 32
  if tableCount > 0 then
    for tableIndex = 0 to tableCount - 1
      if cursor > len(payload) - TABLE_HEADER_BYTES then return fail(CORRUPT_DATA, "decode", "table header is truncated") end if
    tableId = decodeNative(endian.readU64LE(payload, cursor), "decode", "tableId")
    rowCount = decodeNative(endian.readU64LE(payload, cursor + 8), "decode", "rowCount")
    pageCount = decodeNative(endian.readU64LE(payload, cursor + 16), "decode", "pageCount")
    columnCount = endian.readU16LE(payload, cursor + 24)
    if endian.readU16LE(payload, cursor + 26) != 0 or endian.readU32LE(payload, cursor + 28) != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "reserved table fields are non-zero") end if
    cursor = cursor + TABLE_HEADER_BYTES
      columns = []
      if columnCount > 0 then
        for columnNumber = 0 to columnCount - 1
          if cursor > len(payload) - COLUMN_BYTES then return fail(CORRUPT_DATA, "decode", "column record is truncated") end if
          if endian.readU16LE(payload, cursor + 2) != 0 or endian.readU32LE(payload, cursor + 24) != 0 or endian.readU32LE(payload, cursor + 28) != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "reserved column fields are non-zero") end if
          columns = columns + [ColumnStatistics(
            endian.readU16LE(payload, cursor),
            decodeNative(endian.readU64LE(payload, cursor + 4), "decode", "nullCount"),
            decodeNative(endian.readU64LE(payload, cursor + 12), "decode", "distinctCount"),
            endian.readU32LE(payload, cursor + 20)
          )]
          cursor = cursor + COLUMN_BYTES
        end for
      end if
      state.tables = state.tables + [TableStatistics(tableId, rowCount, pageCount, columns)]
    end for
  end if
  if cursor != len(payload) then return fail(CORRUPT_DATA, "decode", "trailing statistics bytes") end if
  return state
end function

// Keep the qualified public API statistics.decode(...), while every internal
// call uses an unambiguous helper. MiniLang also exposes decode(bytes) as a
// builtin, so an unqualified internal decode(...) call may otherwise bind to
// UTF-8 decoding instead of the statistics catalog decoder.
function decode(encoded)
  return decodeCatalog(encoded)
end function

function readWhole(filePath)
  handle = file_api.openRead(filePath)
  size = file_api.size(handle)
  if size > MAX_STATISTICS_BYTES + 128 then file_api.close(handle); return fail(CORRUPT_DATA, "readWhole", "statistics file exceeds size limit") end if
  output = bytes(size, 0)
  if size > 0 then file_api.readExactAt(handle, 0, output, 0, size) end if
  file_api.close(handle)
  return output
end function

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

function loadOrCreate(databasePath, databaseId)
  filePath = path(databasePath)
  if not file_api.fileExists(filePath) then return create(databaseId) end if
  state = decodeCatalog(readWhole(filePath))
  if state is not StatisticsCatalog then return fail(CORRUPT_DATA, "loadOrCreate", "decoded statistics are not a StatisticsCatalog") end if
  if not bytesEqual(state.databaseId, databaseId) then return fail(CORRUPT_DATA, "loadOrCreate", "statistics belong to another database") end if
  return state
end function

function componentName()
  return "catalog.statistics"
end function

function targetMilestone()
  return "M17"
end function

function isImplemented()
  return true
end function
