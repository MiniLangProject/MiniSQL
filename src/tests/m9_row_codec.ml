import minisql.common.endian as endian
import minisql.storage.row_codec as rows
import tests.support.testkit as testkit

function main(args)
  state = testkit.create()
  schema = rows.schema(7, [
    rows.column(rows.TYPE_BOOLEAN, false, 0, 0, 0),
    rows.column(rows.TYPE_SMALLINT, false, 0, 0, 0),
    rows.column(rows.TYPE_INTEGER, false, 0, 0, 0),
    rows.column(rows.TYPE_BIGINT, false, 0, 0, 0),
    rows.column(rows.TYPE_DOUBLE, false, 0, 0, 0),
    rows.column(rows.TYPE_DECIMAL, false, 0, 18, 2),
    rows.column(rows.TYPE_VARCHAR, false, 64, 0, 0),
    rows.column(rows.TYPE_TEXT, true, 512, 0, 0),
    rows.column(rows.TYPE_VARBINARY, false, 64, 0, 0),
    rows.column(rows.TYPE_DATE, false, 0, 0, 0),
    rows.column(rows.TYPE_TIME, false, 0, 0, 0),
    rows.column(rows.TYPE_TIMESTAMP, false, 0, 0, 0)
  ])
  testkit.record(state, endian.isInt64Words(endian.minInt64()), "I64 exact type predicate")
  testkit.record(state, not endian.isInt64Words([]), "non-I64 rejected by exact type predicate")
  values = [
    true,
    -32768,
    2147483647,
    endian.minInt64(),
    3.5,
    endian.makeInt64(0, 123456),
    "Grüße aus MiniSQL",
    rows.nullValue(),
    fromHex("001122aabbcc"),
    -12345,
    endian.makeInt64(0, 987654),
    endian.makeInt64(0xFFFFFFFF, 0xFFFFFFFE)
  ]
  encoded = rows.encode(schema, values)
  decoded = rows.decodeRow(schema, encoded)
  testkit.equal(state, decoded.schemaVersion, 7, "schema version")
  testkit.equal(state, decoded.values[0], true, "boolean roundtrip")
  testkit.equal(state, decoded.values[1], -32768, "smallint roundtrip")
  testkit.equal(state, decoded.values[2], 2147483647, "integer roundtrip")
  testkit.record(state, endian.int64Equals(decoded.values[3], endian.minInt64()), "bigint minimum roundtrip")
  testkit.equal(state, decoded.values[4], 3.5, "double roundtrip")
  testkit.record(state, endian.int64Equals(decoded.values[5], values[5]), "decimal roundtrip")
  testkit.equal(state, decoded.values[6], "Grüße aus MiniSQL", "UTF-8 roundtrip")
  testkit.record(state, rows.isNull(decoded.values[7]), "SQL NULL roundtrip")
  testkit.equal(state, hex(decoded.values[8]), "001122aabbcc", "binary roundtrip")
  testkit.equal(state, decoded.values[9], -12345, "date roundtrip")
  testkit.record(state, endian.int64Equals(decoded.values[10], values[10]), "time roundtrip")
  testkit.record(state, endian.int64Equals(decoded.values[11], values[11]), "timestamp negative roundtrip")

  notNull = rows.schema(1, [rows.column(rows.TYPE_INTEGER, false, 0, 0, 0)])
  testkit.errorCode(state, try(rows.encode(notNull, [rows.nullValue()])), rows.TYPE_MISMATCH, "NULL rejected for NOT NULL")
  testkit.errorCode(state, try(rows.encode(rows.schema(1, [rows.column(rows.TYPE_INTEGER, true, 0, 0, 0)]), [void])), rows.TYPE_MISMATCH, "MiniLang void is not SQL NULL")
  limited = rows.schema(1, [rows.column(rows.TYPE_VARCHAR, false, 3, 0, 0)])
  testkit.errorCode(state, try(rows.encode(limited, ["four"])), rows.TYPE_MISMATCH, "length constraint")
  testkit.errorCode(state, try(rows.encode(notNull, ["wrong"])), rows.TYPE_MISMATCH, "type mismatch")

  corrupt = bytes(encoded)
  corrupt[0] = 0
  testkit.errorCode(state, try(rows.decodeRow(schema, corrupt)), rows.UNSUPPORTED_FORMAT, "bad row magic")
  corrupt = bytes(encoded)
  corrupt[14] = 1
  testkit.errorCode(state, try(rows.decodeRow(schema, corrupt)), rows.UNSUPPORTED_FORMAT, "reserved row field")
  corrupt = bytes(encoded)
  corrupt[rows.HEADER_SIZE] = corrupt[rows.HEADER_SIZE] ^ 0x80
  testkit.errorCode(state, try(rows.decodeRow(schema, corrupt)), rows.CORRUPT_DATA, "NULL bitmap mismatch")

  fixedSchema = rows.schema(1, [
    rows.column(rows.TYPE_CHAR, false, 5, 0, 0),
    rows.column(rows.TYPE_BINARY, false, 4, 0, 0)
  ])
  fixedDecoded = rows.decodeRow(fixedSchema, rows.encode(fixedSchema, ["ab", fromHex("00112233")]))
  testkit.equal(state, fixedDecoded.values[0], "ab   ", "CHAR padding")
  testkit.equal(state, hex(fixedDecoded.values[1]), "00112233", "BINARY exact roundtrip")
  testkit.errorCode(state, try(rows.encode(fixedSchema, ["abcdef", fromHex("00112233")])), rows.TYPE_MISMATCH, "CHAR overflow")
  testkit.errorCode(state, try(rows.encode(fixedSchema, ["ab", fromHex("001122")])), rows.TYPE_MISMATCH, "BINARY exact length")

  pointer = rows.external(fromHex("010203040506"))
  lobSchema = rows.schema(1, [rows.column(rows.TYPE_BLOB, false, 0, 0, 0)])
  externalEncoded = rows.encode(lobSchema, [pointer])
  externalDecoded = rows.decodeRow(lobSchema, externalEncoded)
  testkit.record(state, rows.isExternalValue(externalDecoded.values[0]), "external LOB marker")
  testkit.equal(state, hex(externalDecoded.values[0].encodedPointer), "010203040506", "external pointer bytes")

  return testkit.finish(state, "MiniSQL M9 row-codec tests: SUCCESS", "MiniSQL M9 row-codec tests: FAIL")
end function
