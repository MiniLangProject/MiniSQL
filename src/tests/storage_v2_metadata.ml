// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.catalog.metadata as metadata
import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.storage.checksum as checksum
import tests.support.testkit as testkit

// Checks persisted version identities independently of configuration defaults.
function main(args)
  state = testkit.create()
  defaults = config_model.defaultDatabaseSettings(4096)
  testkit.equal(state, defaults.databaseFormatVersion, 2, "new database defaults use v2")
  value = metadata.createDatabase("v2", bytes(16, 7), 4096, 67108864, 2, 2, 2, 1, 2)
  encoded = metadata.encodeDatabase(value)
  testkit.equal(state, hex(slice(encoded, 0, 12)), "4d5344424d30303102000100", "db.meta magic, envelope version and kind golden")
  envelope = checksum.decodeEnvelope(encoded, metadata.databaseMagic(), 2, metadata.DATABASE_KIND)
  testkit.equal(state, hex(slice(envelope.payload, 8, 10)), "02000200020001000200", "persisted version tuple golden")
  restored = metadata.decodeDatabase(encoded)
  testkit.equal(state, restored.name, "v2", "metadata name roundtrip")
  testkit.equal(state, restored.databaseFormatVersion, 2, "metadata format roundtrip")
  testkit.equal(state, restored.pageSize, 4096, "persisted page size roundtrip")

  legacy = checksum.encodeEnvelope(metadata.databaseMagic(), 1, metadata.DATABASE_KIND, 0, envelope.payload)
  testkit.errorCode(state, try(metadata.decodeDatabase(legacy)), metadata.UNSUPPORTED_FORMAT, "legacy envelope rejected")
  for each fieldOffset in [8, 10, 12, 16]
    payload = bytes(envelope.payload)
    endian.writeU16LE(payload, fieldOffset, 1)
    mixed = checksum.encodeEnvelope(metadata.databaseMagic(), 2, metadata.DATABASE_KIND, 0, payload)
    testkit.errorCode(state, try(metadata.decodeDatabase(mixed)), metadata.UNSUPPORTED_FORMAT, "mixed v1 payload rejected")
  end for
  payload = bytes(envelope.payload)
  endian.writeU16LE(payload, 14, 2)
  futureWal = checksum.encodeEnvelope(metadata.databaseMagic(), 2, metadata.DATABASE_KIND, 0, payload)
  testkit.errorCode(state, try(metadata.decodeDatabase(futureWal)), metadata.UNSUPPORTED_FORMAT, "unsupported WAL framing rejected")
  flagged = checksum.encodeEnvelope(metadata.databaseMagic(), 2, metadata.DATABASE_KIND, 1, envelope.payload)
  testkit.errorCode(state, try(metadata.decodeDatabase(flagged)), metadata.UNSUPPORTED_FORMAT, "unknown envelope flags rejected")
  for each reservedOffset in [64, 68, 72, 76]
    payload = bytes(envelope.payload)
    endian.writeU32LE(payload, reservedOffset, 1)
    reserved = checksum.encodeEnvelope(metadata.databaseMagic(), 2, metadata.DATABASE_KIND, 0, payload)
    testkit.errorCode(state, try(metadata.decodeDatabase(reserved)), metadata.UNSUPPORTED_FORMAT, "reserved payload bytes rejected")
  end for
  return testkit.finish(state, "MiniSQL storage v2 metadata tests: SUCCESS", "MiniSQL storage v2 metadata tests: FAIL")
end function
