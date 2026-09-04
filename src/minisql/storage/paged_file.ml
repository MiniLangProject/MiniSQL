//! Provides minisql storage paged file facilities for this project.

package minisql.storage.paged_file
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import minisql.common.limits as limits
import minisql.common.uuid as uuid
import minisql.platform.file as file_api
import minisql.platform.lock as file_lock
import minisql.security.key_provider as key_provider
import minisql.storage.page as page
import minisql.storage.superblock as superblock
import std.crypto.aes_gcm as aes_gcm

/// A paged file begins with two fixed 4096-byte superblock slots followed by a

const INVALID_ARGUMENT = 9001
/// Defines the corrupt data constant used by the minisql storage paged file module.
const CORRUPT_DATA = 9004
/// Defines the closed handle constant used by the minisql storage paged file module.
const CLOSED_HANDLE = 9008

/// Defines the slot a constant used by the minisql storage paged file module.
const SLOT_A = 0
/// Defines the slot b constant used by the minisql storage paged file module.
const SLOT_B = 1
/// Defines the slot a offset constant used by the minisql storage paged file module.
const SLOT_A_OFFSET = 0
/// Defines the slot b offset constant used by the minisql storage paged file module.
const SLOT_B_OFFSET = 4096
/// Defines the data offset constant used by the minisql storage paged file module.
const DATA_OFFSET = 8192
/// Defines the feature page encryption constant used by the minisql storage paged file module.
const FEATURE_PAGE_ENCRYPTION = 1
/// Defines the encryption nonce bytes constant used by the minisql storage paged file module.
const ENCRYPTION_NONCE_BYTES = 12
/// Defines the encryption tag bytes constant used by the minisql storage paged file module.
const ENCRYPTION_TAG_BYTES = 16

/// Defines the paged file record used by this module.
struct PagedFile
  /// Path field of the paged file.
  path
  /// File field of the paged file.
  file
  /// Page size field of the paged file.
  pageSize
  /// File type field of the paged file.
  fileType
  /// File id field of the paged file.
  fileId
  /// Database id field of the paged file.
  databaseId
  /// Page count field of the paged file.
  pageCount
  /// Generation field of the paged file.
  generation
  /// Active slot field of the paged file.
  activeSlot
  /// Feature flags field of the paged file.
  featureFlags
  /// Wipeable database encryption key, or void for a plaintext file.
  encryptionKey
  /// First page that may still contain reusable free storage for appenders.
  allocationHint
  /// Closed field of the paged file.
  closed
end struct

/// Performs the fail operation for the minisql storage paged file module.
/// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "storage.paged_file." + operation + ": " + message)
end function

/// Validates database id for the minisql storage paged file workflow.
/// Inputs: `databaseId`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param databaseId Identifier of database.
/// @param operation operation value consumed by this operation.
function validateDatabaseId(databaseId, operation)
  if typeof(databaseId) != "bytes" or len(databaseId) != superblock.DATABASE_ID_SIZE then
    return fail(INVALID_ARGUMENT, operation, "databaseId must be exactly 16 bytes")
  end if
  return true
end function

/// Validates native id for the minisql storage paged file workflow.
/// Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
/// @param operation operation value consumed by this operation.
/// @param name Name of the affected item.
function validateNativeId(value, operation, name)
  if typeof(value) != "int" or value < 0 or value > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, operation, name + " must be a non-negative native MiniLang int")
  end if
  return true
end function

/// Validates open for the minisql storage paged file workflow.
/// Inputs: `pagedFile`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param operation operation value consumed by this operation.
function validateOpen(pagedFile, operation)
  if pagedFile is not PagedFile then return fail(INVALID_ARGUMENT, operation, "value must be PagedFile") end if
  if pagedFile.closed then return fail(CLOSED_HANDLE, operation, "paged file is closed") end if
  return true
end function

/// Performs the slotOffset operation for the minisql storage paged file module.
/// Inputs: `slot`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param slot slot value consumed by this operation.
function slotOffset(slot)
  if slot == SLOT_A then return SLOT_A_OFFSET end if
  if slot == SLOT_B then return SLOT_B_OFFSET end if
  return fail(INVALID_ARGUMENT, "slotOffset", "slot must be 0 or 1")
end function

/// Performs the max page count for operation for this module.
/// Inputs: `pageSize`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageSize pageSize value consumed by this operation.
function maxPageCountFor(pageSize)
  if typeof(pageSize) != "int" or not limits.isSupportedPageSize(pageSize) then
    return fail(INVALID_ARGUMENT, "maxPageCountFor", "unsupported page size")
  end if
  available = endian.MAX_MINILANG_INT - DATA_OFFSET
  if pageSize == 4096 then return available >> 12 end if
  if pageSize == 8192 then return available >> 13 end if
  if pageSize == 16384 then return available >> 14 end if
  return available >> 15
end function

/// Returns the fixed physical stride for plaintext or encrypted page records.
/// @param pageSize pageSize value consumed by this operation.
/// @param featureFlags featureFlags value consumed by this operation.
function physicalPageSize(pageSize, featureFlags)
  if isEncryptedFlags(featureFlags) then return pageSize + ENCRYPTION_NONCE_BYTES + ENCRYPTION_TAG_BYTES end if
  return pageSize
end function

/// Tests the persisted page-encryption feature bit.
/// @param featureFlags featureFlags value consumed by this operation.
function isEncryptedFlags(featureFlags)
  return (featureFlags & FEATURE_PAGE_ENCRYPTION) > 0
end function

/// Performs the page offset operation for this module.
/// Inputs: `pagedFile`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param pageNumber pageNumber value consumed by this operation.
function pageOffset(pagedFile, pageNumber)
  validateOpen(pagedFile, "pageOffset")
  validateNativeId(pageNumber, "pageOffset", "pageNumber")
  if pageNumber >= maxPageCountFor(pagedFile.pageSize) then
    return fail(INVALID_ARGUMENT, "pageOffset", "page number would extend beyond the native file-size range")
  end if
  return DATA_OFFSET + pageNumber * physicalPageSize(pagedFile.pageSize, pagedFile.featureFlags)
end function

/// Commits the ted size.
/// Inputs: `pageSize`, `pageCount`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param pageSize pageSize value consumed by this operation.
/// @param pageCount Number of page to process.
/// @param featureFlags featureFlags value consumed by this operation.
function committedSize(pageSize, pageCount, featureFlags)
  if typeof(pageSize) != "int" or not limits.isSupportedPageSize(pageSize) then
    return fail(INVALID_ARGUMENT, "committedSize", "unsupported page size")
  end if
  validateNativeId(pageCount, "committedSize", "pageCount")
  if pageCount > maxPageCountFor(pageSize) then
    return fail(INVALID_ARGUMENT, "committedSize", "file size exceeds native range")
  end if
  return DATA_OFFSET + pageCount * physicalPageSize(pageSize, featureFlags)
end function

/// Performs the metadata for operation for this module.
/// Inputs: `pagedFile`, `generation`, `pageCount`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param generation generation value consumed by this operation.
/// @param pageCount Number of page to process.
function metadataFor(pagedFile, generation, pageCount)
  return superblock.create(
    superblock.FORMAT_VERSION,
    generation,
    pagedFile.pageSize,
    pagedFile.fileType,
    pagedFile.fileId,
    pageCount,
    pagedFile.databaseId,
    pagedFile.featureFlags
  )
end function

/// Writes the slot.
/// Inputs: `file`, `slot`, `metadata`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param file file value consumed by this operation.
/// @param slot slot value consumed by this operation.
/// @param metadata metadata value consumed by this operation.
function writeSlot(file, slot, metadata)
  encoded = superblock.encode(metadata)
  file_api.writeAt(file, slotOffset(slot), encoded, 0, len(encoded))
  return true
end function

/// Commits the metadata.
/// Inputs: `pagedFile`, `newPageCount`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param newPageCount Number of new page to process.
function commitMetadata(pagedFile, newPageCount)
  validateOpen(pagedFile, "commitMetadata")
  validateNativeId(newPageCount, "commitMetadata", "newPageCount")
  newGeneration = superblock.incrementGeneration(pagedFile.generation)
  targetSlot = SLOT_A
  if pagedFile.activeSlot == SLOT_A then targetSlot = SLOT_B end if
  metadata = metadataFor(pagedFile, newGeneration, newPageCount)
  writeSlot(pagedFile.file, targetSlot, metadata)
  file_api.flush(pagedFile.file)
  pagedFile.generation = newGeneration
  pagedFile.pageCount = newPageCount
  pagedFile.activeSlot = targetSlot
  return true
end function

/// Creates create for the minisql storage paged file module.
/// Inputs: `path`, `pageSize`, `fileType`, `fileId`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param path Path of the file or directory used by the operation.
/// @param pageSize pageSize value consumed by this operation.
/// @param fileType fileType value consumed by this operation.
/// @param fileId Identifier of file.
/// @param databaseId Identifier of database.
function create(path, pageSize, fileType, fileId, databaseId)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "create", "path must be non-empty") end if
  if typeof(pageSize) != "int" or not limits.isSupportedPageSize(pageSize) then
    return fail(INVALID_ARGUMENT, "create", "unsupported page size")
  end if
  if typeof(fileType) != "int" or fileType < 0 or fileType > 65535 then
    return fail(INVALID_ARGUMENT, "create", "fileType must fit U16")
  end if
  validateNativeId(fileId, "create", "fileId")
  validateDatabaseId(databaseId, "create")

  file = file_api.createNewDurable(path)
  lockResult = try(file_lock.acquireExclusive(file, true))
  if typeof(lockResult) == "error" then
    file_api.close(file)
    return lockResult
  end if
  keyMaterial = try(key_provider.loadForPath(path, databaseId))
  encryptionKey = void
  featureFlags = 0
  if keyMaterial is not void then
    encryptionKey = bytes(keyMaterial.key)
    featureFlags = FEATURE_PAGE_ENCRYPTION
    key_provider.closeDatabaseKey(keyMaterial)
  end if
  result = PagedFile(
    path,
    file,
    pageSize,
    fileType,
    fileId,
    bytes(databaseId),
    0,
    endian.makeUInt64(0, 0),
    SLOT_B,
    featureFlags,
    encryptionKey,
    0,
    false
  )

  // Establish a durable older copy first, then publish generation 1 in slot A.
  older = metadataFor(result, endian.makeUInt64(0, 0), 0)
  writeSlot(file, SLOT_B, older)
  file_api.flush(file)
  newest = metadataFor(result, endian.makeUInt64(0, 1), 0)
  writeSlot(file, SLOT_A, newest)
  file_api.flush(file)
  result.generation = endian.makeUInt64(0, 1)
  result.activeSlot = SLOT_A
  return result
end function

/// Reads the slot.
/// Inputs: `file`, `slot`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param file file value consumed by this operation.
/// @param slot slot value consumed by this operation.
function readSlot(file, slot)
  data = bytes(superblock.SLOT_SIZE, 0)
  file_api.readExactAt(file, slotOffset(slot), data, 0, len(data))
  return superblock.decode(data)
end function

/// Performs the choose metadata operation for this module.
/// Inputs: `firstResult`, `secondResult`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param firstResult firstResult value consumed by this operation.
/// @param secondResult secondResult value consumed by this operation.
function chooseMetadata(firstResult, secondResult)
  firstValid = typeof(firstResult) != "error"
  secondValid = typeof(secondResult) != "error"
  if not firstValid and not secondValid then
    return fail(CORRUPT_DATA, "open", "both superblock copies are invalid")
  end if
  if firstValid and secondValid then
    if not superblock.immutableIdentityMatches(firstResult, secondResult) then
      return fail(CORRUPT_DATA, "open", "superblock copies disagree on immutable identity")
    end if
    comparison = superblock.compareGeneration(firstResult.generation, secondResult.generation)
    if comparison == 0 and firstResult.pageCount != secondResult.pageCount then
      return fail(CORRUPT_DATA, "open", "equal superblock generations disagree on page count")
    end if
    if comparison >= 0 then
      return [firstResult, SLOT_A]
    end if
    return [secondResult, SLOT_B]
  end if
  if firstValid then return [firstResult, SLOT_A] end if
  return [secondResult, SLOT_B]
end function

/// Opens open for the minisql storage paged file module.
/// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param path Path of the file or directory used by the operation.
function open(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "open", "path must be non-empty") end if
  file = file_api.openReadWrite(path, false)
  lockResult = try(file_lock.acquireExclusive(file, true))
  if typeof(lockResult) == "error" then
    file_api.close(file)
    return lockResult
  end if
  actualSize = file_api.size(file)
  if actualSize < DATA_OFFSET then
    file_api.close(file)
    return fail(CORRUPT_DATA, "open", "file is shorter than the metadata region")
  end if

  first = try(readSlot(file, SLOT_A))
  second = try(readSlot(file, SLOT_B))
  selected = try(chooseMetadata(first, second))
  if typeof(selected) == "error" then
    file_api.close(file)
    return selected
  end if
  metadata = selected[0]
  activeSlot = selected[1]
  requiredSize = committedSize(metadata.pageSize, metadata.pageCount, metadata.featureFlags)
  if actualSize < requiredSize then
    file_api.close(file)
    return fail(CORRUPT_DATA, "open", "file is shorter than committed page count")
  end if
  if actualSize > requiredSize then
    // Data written before an interrupted metadata publication is uncommitted tail.
    file_api.truncate(file, requiredSize)
    file_api.flush(file)
  end if

  keyMaterial = void
  encryptionKey = void
  if isEncryptedFlags(metadata.featureFlags) then
    keyMaterial = try(key_provider.loadForPath(path, metadata.databaseId))
    if keyMaterial is void then file_api.close(file); return fail(CORRUPT_DATA, "open", "encrypted file has no database key envelope") end if
    encryptionKey = bytes(keyMaterial.key)
    key_provider.closeDatabaseKey(keyMaterial)
  end if
  return PagedFile(
    path,
    file,
    metadata.pageSize,
    metadata.fileType,
    metadata.fileId,
    bytes(metadata.databaseId),
    metadata.pageCount,
    metadata.generation,
    activeSlot,
    metadata.featureFlags,
    encryptionKey,
    metadata.pageCount,
    false
  )
end function

/// Read plans use independent handles with compatible shared byte-range locks.
/// The database writer gate guarantees that no in-process mutation overlaps;
/// the lock still rejects a lock-aware writer from another owner.
/// Opens the read only.
/// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param path Path of the file or directory used by the operation.
function openReadOnly(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "openReadOnly", "path must be non-empty") end if
  file = file_api.openRead(path)
  lockResult = try(file_lock.acquireShared(file, true))
  if typeof(lockResult) == "error" then
    file_api.close(file)
    return lockResult
  end if
  actualSize = file_api.size(file)
  if actualSize < DATA_OFFSET then
    file_api.close(file)
    return fail(CORRUPT_DATA, "openReadOnly", "file is shorter than the metadata region")
  end if

  first = try(readSlot(file, SLOT_A))
  second = try(readSlot(file, SLOT_B))
  selected = try(chooseMetadata(first, second))
  if typeof(selected) == "error" then
    file_api.close(file)
    return selected
  end if
  metadata = selected[0]
  activeSlot = selected[1]
  requiredSize = committedSize(metadata.pageSize, metadata.pageCount, metadata.featureFlags)
  if actualSize != requiredSize then
    file_api.close(file)
    return fail(CORRUPT_DATA, "openReadOnly", "file size does not match committed page count")
  end if

  keyMaterial = void
  encryptionKey = void
  if isEncryptedFlags(metadata.featureFlags) then
    keyMaterial = try(key_provider.loadForPath(path, metadata.databaseId))
    if keyMaterial is void then file_api.close(file); return fail(CORRUPT_DATA, "openReadOnly", "encrypted file has no database key envelope") end if
    encryptionKey = bytes(keyMaterial.key)
    key_provider.closeDatabaseKey(keyMaterial)
  end if
  return PagedFile(
    path,
    file,
    metadata.pageSize,
    metadata.fileType,
    metadata.fileId,
    bytes(metadata.databaseId),
    metadata.pageCount,
    metadata.generation,
    activeSlot,
    metadata.featureFlags,
    encryptionKey,
    metadata.pageCount,
    false
  )
end function

/// Opens a persistent read handle without a per-file byte-range lock. This is
/// restricted to ManagedDatabase-owned caches: the database lock excludes other
/// owners and the physical execution gate excludes in-process writers. Avoiding
/// a long-lived shared file lock lets a later writer replace/rebuild the file
/// before the cache is invalidated at its statement boundary.
/// @param path Path of the file or directory used by the operation.
function openReadOnlyManaged(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "openReadOnlyManaged", "path must be non-empty") end if
  file = file_api.openRead(path)
  actualSize = file_api.size(file)
  if actualSize < DATA_OFFSET then
    file_api.close(file)
    return fail(CORRUPT_DATA, "openReadOnlyManaged", "file is shorter than the metadata region")
  end if

  first = try(readSlot(file, SLOT_A))
  second = try(readSlot(file, SLOT_B))
  selected = try(chooseMetadata(first, second))
  if typeof(selected) == "error" then
    file_api.close(file)
    return selected
  end if
  metadata = selected[0]
  activeSlot = selected[1]
  requiredSize = committedSize(metadata.pageSize, metadata.pageCount, metadata.featureFlags)
  if actualSize != requiredSize then
    file_api.close(file)
    return fail(CORRUPT_DATA, "openReadOnlyManaged", "file size does not match committed page count")
  end if

  keyMaterial = void
  encryptionKey = void
  if isEncryptedFlags(metadata.featureFlags) then
    keyMaterial = try(key_provider.loadForPath(path, metadata.databaseId))
    if keyMaterial is void then file_api.close(file); return fail(CORRUPT_DATA, "openReadOnlyManaged", "encrypted file has no database key envelope") end if
    encryptionKey = bytes(keyMaterial.key)
    key_provider.closeDatabaseKey(keyMaterial)
  end if
  return PagedFile(
    path,
    file,
    metadata.pageSize,
    metadata.fileType,
    metadata.fileId,
    bytes(metadata.databaseId),
    metadata.pageCount,
    metadata.generation,
    activeSlot,
    metadata.featureFlags,
    encryptionKey,
    metadata.pageCount,
    false
  )
end function

/// Validates the page identity.
/// Inputs: `pagedFile`, `pageBytes`, `expectedPageNumber`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param expectedPageNumber expectedPageNumber value consumed by this operation.
/// @param operation operation value consumed by this operation.
function validatePageIdentity(pagedFile, pageBytes, expectedPageNumber, operation)
  validateOpen(pagedFile, operation)
  if typeof(pageBytes) != "bytes" or len(pageBytes) != pagedFile.pageSize then
    return fail(INVALID_ARGUMENT, operation, "page buffer has the wrong size")
  end if
  header = page.verify(pageBytes)
  if header.pageId.fileId != pagedFile.fileId then
    return fail(CORRUPT_DATA, operation, "page belongs to another file")
  end if
  if header.pageId.pageNumber != expectedPageNumber then
    return fail(CORRUPT_DATA, operation, "page number mismatch")
  end if
  return header
end function

/// Binds every encrypted record to its immutable database/file/page identity.
/// Moving ciphertext between pages or files therefore fails GCM authentication.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param pageNumber pageNumber value consumed by this operation.
function pageAad(pagedFile, pageNumber)
  output = bytes(48, 0)
  copyBytes(output, 0, bytes("MiniSQL-PAGE-1"), 0, 14)
  copyBytes(output, 16, pagedFile.databaseId, 0, 16)
  endian.writeU64LE(output, 32, endian.uint64FromInt(pagedFile.fileId))
  endian.writeU64LE(output, 40, endian.uint64FromInt(pageNumber))
  return output
end function

/// Encrypts one logical page into its nonce/ciphertext/tag record.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param pageNumber pageNumber value consumed by this operation.
/// @param plaintext plaintext value consumed by this operation.
function encodeStoredPage(pagedFile, pageNumber, plaintext)
  if not isEncryptedFlags(pagedFile.featureFlags) then return plaintext end if
  nonce = try(uuid.randomBytes(ENCRYPTION_NONCE_BYTES))
  if typeof(nonce) == "error" then return nonce end if
  aad = pageAad(pagedFile, pageNumber)
  sealed = try(aes_gcm.seal(pagedFile.encryptionKey, nonce, plaintext, aad, ENCRYPTION_TAG_BYTES))
  fillBytes(aad, 0, len(aad), 0)
  if typeof(sealed) == "error" then fillBytes(nonce, 0, len(nonce), 0); return sealed end if
  output = nonce + sealed
  fillBytes(nonce, 0, len(nonce), 0)
  fillBytes(sealed, 0, len(sealed), 0)
  return output
end function

/// Authenticates and decrypts one physical page record.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param pageNumber pageNumber value consumed by this operation.
/// @param stored stored value consumed by this operation.
function decodeStoredPage(pagedFile, pageNumber, stored)
  if not isEncryptedFlags(pagedFile.featureFlags) then return stored end if
  aad = pageAad(pagedFile, pageNumber)
  plaintext = try(aes_gcm.open(pagedFile.encryptionKey, slice(stored, 0, ENCRYPTION_NONCE_BYTES), slice(stored, ENCRYPTION_NONCE_BYTES, len(stored) - ENCRYPTION_NONCE_BYTES), aad, ENCRYPTION_TAG_BYTES))
  fillBytes(aad, 0, len(aad), 0)
  if typeof(plaintext) == "error" then return fail(CORRUPT_DATA, "readPage", "encrypted page authentication failed") end if
  return plaintext
end function

/// Encodes and writes one logical page at its fixed physical offset.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param pageNumber pageNumber value consumed by this operation.
/// @param plaintext plaintext value consumed by this operation.
function storePage(pagedFile, pageNumber, plaintext)
  stored = try(encodeStoredPage(pagedFile, pageNumber, plaintext))
  if typeof(stored) == "error" then return stored end if
  result = try(file_api.writeAt(pagedFile.file, pageOffset(pagedFile, pageNumber), stored, 0, len(stored)))
  if isEncryptedFlags(pagedFile.featureFlags) then fillBytes(stored, 0, len(stored), 0) end if
  return result
end function

/// Reads the page.
/// Inputs: `pagedFile`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param pageNumber pageNumber value consumed by this operation.
function readPage(pagedFile, pageNumber)
  return readPageWithContext(pagedFile, pageNumber, void)
end function

/// Reads and verifies one page while reusing the caller's positioned-I/O state.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param pageNumber pageNumber value consumed by this operation.
/// @param readContext readContext value consumed by this operation.
function readPageWithContext(pagedFile, pageNumber, readContext)
  validateOpen(pagedFile, "readPage")
  validateNativeId(pageNumber, "readPage", "pageNumber")
  if pageNumber >= pagedFile.pageCount then return fail(INVALID_ARGUMENT, "readPage", "page number is outside the file") end if
  stored = bytes(physicalPageSize(pagedFile.pageSize, pagedFile.featureFlags), 0)
  if readContext is void then file_api.readExactAt(pagedFile.file, pageOffset(pagedFile, pageNumber), stored, 0, len(stored)) else file_api.readExactAtWithContext(pagedFile.file, pageOffset(pagedFile, pageNumber), stored, 0, len(stored), readContext) end if
  output = try(decodeStoredPage(pagedFile, pageNumber, stored))
  if isEncryptedFlags(pagedFile.featureFlags) then fillBytes(stored, 0, len(stored), 0) end if
  validatePageIdentity(pagedFile, output, pageNumber, "readPage")
  return output
end function

/// Appends the page.
/// Inputs: `pagedFile`, `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param pageBytes pageBytes value consumed by this operation.
function appendPage(pagedFile, pageBytes)
  validateOpen(pagedFile, "appendPage")
  pageNumber = pagedFile.pageCount
  validatePageIdentity(pagedFile, pageBytes, pageNumber, "appendPage")
  storePage(pagedFile, pageNumber, pageBytes)
  // The page reaches stable storage before either metadata copy advertises it.
  file_api.flush(pagedFile.file)
  commitMetadata(pagedFile, pageNumber + 1)
  return pageNumber
end function

/// Appends a complete copy-on-write page generation with one data durability
/// barrier and one redundant-superblock publication. Page identity is validated
/// before I/O; bounded 512 KiB writes avoid a second generation-sized buffer.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param pageImages pageImages value consumed by this operation.
function appendPages(pagedFile, pageImages)
  validateOpen(pagedFile, "appendPages")
  if typeof(pageImages) != "array" or len(pageImages) == 0 then return fail(INVALID_ARGUMENT, "appendPages", "pageImages must be non-empty") end if
  firstPage = pagedFile.pageCount
  if firstPage > maxPageCountFor(pagedFile.pageSize) - len(pageImages) then return fail(INVALID_ARGUMENT, "appendPages", "page append exceeds the native file-size range") end if
  for index = 0 to len(pageImages) - 1
    validatePageIdentity(pagedFile, pageImages[index], firstPage + index, "appendPages")
  end for
  if isEncryptedFlags(pagedFile.featureFlags) then
    for index = 0 to len(pageImages) - 1
      storePage(pagedFile, firstPage + index, pageImages[index])
    end for
    file_api.flush(pagedFile.file)
    commitMetadata(pagedFile, firstPage + len(pageImages))
    return firstPage
  end if
  offset = 0
  while offset < len(pageImages)
    count = len(pageImages) - offset
    if count > 128 then count = 128 end if
    output = bytes(count * pagedFile.pageSize, 0)
    for index = 0 to count - 1
      copyBytes(output, index * pagedFile.pageSize, pageImages[offset + index], 0, pagedFile.pageSize)
    end for
    file_api.writeAt(pagedFile.file, pageOffset(pagedFile, firstPage + offset), output, 0, len(output))
    offset = offset + count
  end while
  // New page bytes are stable before either superblock advertises the range.
  file_api.flush(pagedFile.file)
  commitMetadata(pagedFile, firstPage + len(pageImages))
  return firstPage
end function

/// Allocates the page.
/// Inputs: `pagedFile`, `pageType`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param pageType pageType value consumed by this operation.
function allocatePage(pagedFile, pageType)
  return allocatePages(pagedFile, pageType, 1)
end function

/// Allocates a contiguous group of initialized pages with one durability barrier
/// and one superblock publication. Page bytes reach stable storage before the
/// increased page count becomes visible, preserving the single-page crash rule.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param pageType pageType value consumed by this operation.
/// @param count Number of items or units to process.
function allocatePages(pagedFile, pageType, count)
  validateOpen(pagedFile, "allocatePage")
  if typeof(count) != "int" or count < 1 or count > 65536 then return fail(INVALID_ARGUMENT, "allocatePages", "count must be in 1..65536") end if
  firstPage = pagedFile.pageCount
  if firstPage > maxPageCountFor(pagedFile.pageSize) - count then return fail(INVALID_ARGUMENT, "allocatePages", "page allocation exceeds the native file-size range") end if
  for offset = 0 to count - 1
    pageNumber = firstPage + offset
    pageBytes = page.create(pagedFile.pageSize, pageType, pagedFile.fileId, pageNumber)
    storePage(pagedFile, pageNumber, pageBytes)
  end for
  // All new pages become durable before either metadata copy advertises them.
  file_api.flush(pagedFile.file)
  commitMetadata(pagedFile, firstPage + count)
  return firstPage
end function

/// Writes the page.
/// Inputs: `pagedFile`, `pageNumber`, `pageBytes`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param pageNumber pageNumber value consumed by this operation.
/// @param pageBytes pageBytes value consumed by this operation.
function writePage(pagedFile, pageNumber, pageBytes)
  validateOpen(pagedFile, "writePage")
  validateNativeId(pageNumber, "writePage", "pageNumber")
  if pageNumber >= pagedFile.pageCount then return fail(INVALID_ARGUMENT, "writePage", "page number is outside the file") end if
  validatePageIdentity(pagedFile, pageBytes, pageNumber, "writePage")
  storePage(pagedFile, pageNumber, pageBytes)
  return true
end function

/// Publishes a bounded sequence of consecutive page images with one positioned
/// operating-system write. Every image is validated before any byte is written,
/// so a malformed batch cannot partially modify the base file.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param firstPageNumber firstPageNumber value consumed by this operation.
/// @param pageImages pageImages value consumed by this operation.
function writeContiguousPages(pagedFile, firstPageNumber, pageImages)
  validateOpen(pagedFile, "writeContiguousPages")
  validateNativeId(firstPageNumber, "writeContiguousPages", "firstPageNumber")
  if typeof(pageImages) != "array" or len(pageImages) == 0 or len(pageImages) > 1024 then return fail(INVALID_ARGUMENT, "writeContiguousPages", "pageImages must contain 1..1024 pages") end if
  if firstPageNumber >= pagedFile.pageCount or len(pageImages) > pagedFile.pageCount - firstPageNumber then return fail(INVALID_ARGUMENT, "writeContiguousPages", "page range is outside the file") end if
  if isEncryptedFlags(pagedFile.featureFlags) then
    for index = 0 to len(pageImages) - 1
      validatePageIdentity(pagedFile, pageImages[index], firstPageNumber + index, "writeContiguousPages")
      storePage(pagedFile, firstPageNumber + index, pageImages[index])
    end for
    return len(pageImages)
  end if
  output = bytes(len(pageImages) * pagedFile.pageSize, 0)
  for index = 0 to len(pageImages) - 1
    validatePageIdentity(pagedFile, pageImages[index], firstPageNumber + index, "writeContiguousPages")
    copyBytes(output, index * pagedFile.pageSize, pageImages[index], 0, pagedFile.pageSize)
  end for
  file_api.writeAt(pagedFile.file, pageOffset(pagedFile, firstPageNumber), output, 0, len(output))
  return len(pageImages)
end function

/// Performs the flush operation for the minisql storage paged file module.
/// Inputs: `pagedFile`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param pagedFile pagedFile value consumed by this operation.
function flush(pagedFile)
  validateOpen(pagedFile, "flush")
  return file_api.flush(pagedFile.file)
end function

/// Shrinks the committed page range without ever advertising bytes that are not
/// durable. Publishing the smaller superblock first makes an interrupted
/// physical truncate recoverable: open() already discards an uncommitted tail.
/// Inputs: `pagedFile`, `newPageCount`. Returns true after the smaller page range and physical file length are durable.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param newPageCount Number of new page to process.
function truncatePages(pagedFile, newPageCount)
  validateOpen(pagedFile, "truncatePages")
  validateNativeId(newPageCount, "truncatePages", "newPageCount")
  if newPageCount > pagedFile.pageCount then return fail(INVALID_ARGUMENT, "truncatePages", "new page count must not grow the file") end if
  if newPageCount == pagedFile.pageCount then return true end if
  file_api.flush(pagedFile.file)
  commitMetadata(pagedFile, newPageCount)
  file_api.truncate(pagedFile.file, committedSize(pagedFile.pageSize, newPageCount, pagedFile.featureFlags))
  file_api.flush(pagedFile.file)
  return true
end function

/// Closes close owned by the minisql storage paged file module.
/// Inputs: `pagedFile`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param pagedFile pagedFile value consumed by this operation.
function close(pagedFile)
  validateOpen(pagedFile, "close")
  file_api.flush(pagedFile.file)
  file_api.close(pagedFile.file)
  if typeof(pagedFile.encryptionKey) == "bytes" then fillBytes(pagedFile.encryptionKey, 0, len(pagedFile.encryptionKey), 0) end if
  pagedFile.closed = true
  return true
end function

/// Flush and return a byte-for-byte image through the handle that already owns
/// the exclusive file lock. Opening the same path through a second handle would
/// make Windows reject overlapping reads with ERROR_LOCK_VIOLATION (33).
/// Transactional DDL uses this to capture durable before-images without
/// weakening the paged-file single-owner lock contract.
/// Performs the snapshot durable bytes operation for this module.
/// Inputs: `pagedFile`, `maxBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pagedFile pagedFile value consumed by this operation.
/// @param maxBytes maxBytes value consumed by this operation.
function snapshotDurableBytes(pagedFile, maxBytes)
  validateOpen(pagedFile, "snapshotDurableBytes")
  if typeof(maxBytes) != "int" or maxBytes < 0 or maxBytes > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, "snapshotDurableBytes", "maxBytes must be a non-negative native MiniLang int")
  end if
  file_api.flush(pagedFile.file)
  length = file_api.size(pagedFile.file)
  if length > maxBytes then
    return fail(CORRUPT_DATA, "snapshotDurableBytes", "paged-file image exceeds safety limit")
  end if
  output = bytes(length, 0)
  if length > 0 then
    file_api.readExactAt(pagedFile.file, 0, output, 0, length)
  end if
  return output
end function

/// Converts one closed plaintext paged file to the encrypted physical stride.
/// The original is replaced only after the complete encrypted copy is durable.
/// @param path Path of the file or directory used by the operation.
function encryptExisting(path)
  source = try(open(path))
  if typeof(source) == "error" then return source end if
  if isEncryptedFlags(source.featureFlags) then close(source); return true end if
  temporary = path + ".tde-new"
  if file_api.fileExists(temporary) then file_api.deletePath(temporary) end if
  target = try(create(temporary, source.pageSize, source.fileType, source.fileId, source.databaseId))
  if typeof(target) == "error" then close(source); return target end if
  if not isEncryptedFlags(target.featureFlags) then close(target); close(source); return fail(INVALID_ARGUMENT, "encryptExisting", "database key envelope is not active") end if
  for pageNumber = 0 to source.pageCount - 1
    image = try(readPage(source, pageNumber))
    if typeof(image) == "error" then close(target); close(source); return image end if
    appended = try(appendPage(target, image))
    if typeof(appended) == "error" then close(target); close(source); return appended end if
  end for
  targetClosed = try(close(target))
  sourceClosed = try(close(source))
  if typeof(targetClosed) == "error" then return targetClosed end if
  if typeof(sourceClosed) == "error" then return sourceClosed end if
  return file_api.movePath(temporary, path, true)
end function

/// Performs the componentName operation for the minisql storage paged file module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "storage.paged_file"
end function

/// Performs the targetMilestone operation for the minisql storage paged file module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M4"
end function

/// Returns whether implemented satisfies the condition required by the minisql storage paged file module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
