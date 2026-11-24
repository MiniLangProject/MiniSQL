//! Validates the immutable page-zero identity of format-v2 heap tables.

package minisql.storage.table_header
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import minisql.common.format_version as format_version
import minisql.storage.checksum as checksum
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.superblock as superblock

/// Invalid caller input.
const INVALID_ARGUMENT = 9001
/// A legacy or unknown physical table format cannot be opened.
const UNSUPPORTED_FORMAT = 9003
/// Persisted identity or checksum does not match the table file.
const CORRUPT_DATA = 9004
/// Bytes occupied by the general page header and table-specific metadata.
const HEADER_BYTES = 128
/// First physical page that can hold heap records or overflow data.
const FIRST_DATA_PAGE = 1

/// Creates a structured table-header error.
/// @param code Stable MiniSQL error code.
/// @param operation Name of the failed operation.
/// @param message Details of the violated invariant.
function fail(code, operation, message)
  return error(code, "storage.table_header." + operation + ": " + message)
end function

/// Returns the four-byte table-header magic.
function magicBytes()
  return bytes("MSTB")
end function

/// Creates the immutable page-zero image for a newly created empty table.
/// Creation generation is recorded once; subsequent data-page allocations do
/// not rewrite page zero or publish potentially stale allocation hints.
/// @param file Open newly created user-table paged file.
function encode(file)
  paged_file.validateOpen(file, "table_header.encode")
  if file.fileType != superblock.FILE_TYPE_TABLE or file.pageCount != 0 then return fail(INVALID_ARGUMENT, "encode", "table header requires a newly created empty table file") end if
  if file.generation.high == 0 and file.generation.low == 0 then return fail(INVALID_ARGUMENT, "encode", "creation generation must be non-zero") end if
  output = page.create(file.pageSize, page.TYPE_TABLE_META, file.fileId, 0)
  header = page.decodePageHeader(output)
  copyBytes(output, 64, magicBytes(), 0, 4)
  endian.writeU16LE(output, 68, format_version.TABLE)
  endian.writeU16LE(output, 70, HEADER_BYTES)
  copyBytes(output, 72, file.databaseId, 0, 16)
  endian.writeU64LE(output, 88, endian.uint64FromInt(file.fileId))
  endian.writeU32LE(output, 96, file.pageSize)
  endian.writeU16LE(output, 100, checksum.ALGORITHM_CRC32C)
  endian.writeU16LE(output, 102, format_version.ROW)
  endian.writeU64LE(output, 104, file.generation)
  endian.writeU64LE(output, 112, endian.uint64FromInt(FIRST_DATA_PAGE))
  endian.writeU64LE(output, 120, endian.makeUInt64(0, 0))
  header.generation = file.generation
  header.freeStart = HEADER_BYTES
  page.seal(output, header)
  return output
end function

/// Checks table identity, versions and reserved bytes after both page CRCs have
/// been verified. The redundant identity must agree with the file superblock.
/// @param file Open user-table paged file.
/// @param encoded Complete logical page-zero image.
function validatePage(file, encoded)
  paged_file.validateOpen(file, "table_header.validatePage")
  if file.fileType != superblock.FILE_TYPE_TABLE then return fail(CORRUPT_DATA, "validatePage", "file is not a user table") end if
  if typeof(encoded) != "bytes" or len(encoded) != file.pageSize then return fail(CORRUPT_DATA, "validatePage", "table header has the wrong page size") end if
  header = page.verify(encoded)
  if header.pageType != page.TYPE_TABLE_META or slice(encoded, 64, 4) != magicBytes() then return fail(UNSUPPORTED_FORMAT, "validatePage", "format-v2 table header is missing") end if
  if endian.readU16LE(encoded, 68) != format_version.TABLE or endian.readU16LE(encoded, 70) != HEADER_BYTES or endian.readU16LE(encoded, 102) != format_version.ROW then return fail(UNSUPPORTED_FORMAT, "validatePage", "unsupported table or row format") end if
  if header.pageId.fileId != file.fileId or header.pageId.pageNumber != 0 then return fail(CORRUPT_DATA, "validatePage", "table header page identity mismatch") end if
  storedId = endian.readU64LE(encoded, 88)
  if storedId.high > endian.MAX_SCALAR_HIGH or endian.uint64ToInt(storedId) != file.fileId or slice(encoded, 72, 16) != file.databaseId then return fail(CORRUPT_DATA, "validatePage", "table header belongs to another table or database") end if
  if endian.readU32LE(encoded, 96) != file.pageSize then return fail(CORRUPT_DATA, "validatePage", "table header page size disagrees with the superblock") end if
  if endian.readU16LE(encoded, 100) != checksum.ALGORITHM_CRC32C then return fail(UNSUPPORTED_FORMAT, "validatePage", "unsupported table checksum algorithm") end if
  creationGeneration = endian.readU64LE(encoded, 104)
  if creationGeneration.high == 0 and creationGeneration.low == 0 then return fail(CORRUPT_DATA, "validatePage", "creation generation is zero") end if
  if superblock.compareGeneration(creationGeneration, header.generation) != 0 or superblock.compareGeneration(creationGeneration, file.generation) > 0 then return fail(CORRUPT_DATA, "validatePage", "table creation generation is inconsistent") end if
  firstDataPage = endian.readU64LE(encoded, 112)
  if firstDataPage.high != 0 or firstDataPage.low != FIRST_DATA_PAGE then return fail(UNSUPPORTED_FORMAT, "validatePage", "unsupported table data-page boundary") end if
  if header.flags != 0 or header.itemCount != 0 or header.freeStart != HEADER_BYTES or header.freeEnd != file.pageSize or header.pageLsn.high != 0 or header.pageLsn.low != 0 then return fail(CORRUPT_DATA, "validatePage", "table header page fields are invalid") end if
  for offset = 120 to len(encoded) - 1
    if encoded[offset] != 0 then return fail(UNSUPPORTED_FORMAT, "validatePage", "reserved table header bytes are non-zero") end if
  end for
  return true
end function

/// Validates an open table, including read-only handles. Empty legacy table
/// files and legacy tables with heap data on page zero are rejected.
/// @param file Open user-table paged file.
function validate(file)
  paged_file.validateOpen(file, "table_header.validate")
  if file.fileType != superblock.FILE_TYPE_TABLE then return fail(CORRUPT_DATA, "validate", "file is not a table") end if
  if file.pageCount < FIRST_DATA_PAGE then return fail(UNSUPPORTED_FORMAT, "validate", "format-v2 table header is missing") end if
  return validatePage(file, paged_file.readPage(file, 0))
end function

/// Durably reserves page zero before any heap or overflow allocation.
/// @param file Newly created empty user-table paged file.
function initialize(file)
  encoded = encode(file)
  paged_file.appendPage(file, encoded)
  return true
end function

/// Creates a physical user table with its required immutable header page.
/// Catalog and security paged files intentionally use their own page formats.
/// @param path Destination table path.
/// @param pageSize Database page size.
/// @param fileId Table object identifier.
/// @param databaseId Sixteen-byte database identifier.
function create(path, pageSize, fileId, databaseId)
  file = paged_file.create(path, pageSize, superblock.FILE_TYPE_TABLE, fileId, databaseId)
  initialized = try(initialize(file))
  if typeof(initialized) == "error" then ignoredClose = try(paged_file.close(file)); return initialized end if
  return file
end function

/// Validates an acquired table handle and releases it on every failure path.
/// @param file Open paged file returned by the selected access mode.
function checkedOpen(file)
  checked = try(validate(file))
  if typeof(checked) == "error" then ignoredClose = try(paged_file.close(file)); return checked end if
  return file
end function

/// Opens and validates a writable user table.
/// @param path Existing table path.
function open(path)
  return checkedOpen(paged_file.open(path))
end function

/// Opens and validates a shared read-only user table.
/// @param path Existing table path.
function openReadOnly(path)
  return checkedOpen(paged_file.openReadOnly(path))
end function

/// Opens and validates a database-managed read-only user table.
/// @param path Existing table path protected by the database manager.
function openReadOnlyManaged(path)
  return checkedOpen(paged_file.openReadOnlyManaged(path))
end function

/// Returns the component identifier used by documentation tooling.
function componentName()
  return "storage.table_header"
end function

/// Returns the storage-format milestone owned by this component.
function targetMilestone()
  return "StorageV2"
end function

/// Reports that the table-header codec is implemented.
function isImplemented()
  return true
end function
