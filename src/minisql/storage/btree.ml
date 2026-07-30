package minisql.storage.btree

import minisql.common.endian as endian
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.superblock as superblock

// Persistent B+ tree v1.
//
// Updates use append-only copy-on-write generations: a complete new tree is
// appended first and one of two fixed metadata pages is published only after
// every node is durable. The previous metadata generation remains a valid
// fallback if publication is interrupted. Reclamation of unreachable historic
// generations is intentionally deferred to a later VACUUM/rebuild operation.

const INVALID_ARGUMENT = 9001
const UNSUPPORTED_FORMAT = 9003
const CORRUPT_DATA = 9004
const CLOSED_HANDLE = 9008
const OBJECT_EXISTS = 9013
const OBJECT_NOT_FOUND = 9014

const FORMAT_VERSION = 1
const META_PAGE_A = 0
const META_PAGE_B = 1
const META_DATA_OFFSET = 64
const META_DATA_SIZE = 64
const LEAF_DATA_OFFSET = 96
const INTERNAL_DATA_OFFSET = 88
const MAX_KEY_BYTES = 256
const MAX_VALUE_BYTES = 64
const MAX_LEAF_ENTRIES = 10
const MAX_INTERNAL_CHILDREN = 12
const FLAG_UNIQUE = 1
const FLAG_META = 32768

struct BTreeEntry
  key
  value
end struct

struct BTreeMeta
  generation
  unique
  rootPage
  firstLeaf
  lastLeaf
  height
  entryCount
end struct

struct BTreeLeaf
  pageNumber
  previousPage
  nextPage
  entries
end struct

struct BTreeInternal
  pageNumber
  level
  children
  separators
end struct

struct NodeDescriptor
  pageNumber
  firstKey
  level
end struct

struct BTreeAudit
  firstKey
  lastKey
  entryCount
  leafCount
end struct

struct VisitState
  pages
end struct

struct BTree
  pagedFile
  meta
  activeMetaPage
  closed
end struct

function fail(code, operation, message)
  return error(code, "storage.btree." + operation + ": " + message)
end function

function metaMagic()
  return bytes("MSBM")
end function

function leafMagic()
  return bytes("MSBL")
end function

function internalMagic()
  return bytes("MSBI")
end function

function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

function compareKeys(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" then return fail(INVALID_ARGUMENT, "compareKeys", "keys must be bytes") end if
  shared = len(left)
  if len(right) < shared then shared = len(right) end if
  if shared > 0 then
    for index = 0 to shared - 1
      if left[index] < right[index] then return -1 end if
      if left[index] > right[index] then return 1 end if
    end for
  end if
  if len(left) < len(right) then return -1 end if
  if len(left) > len(right) then return 1 end if
  return 0
end function

function compareEntries(left, right)
  if left is not BTreeEntry or right is not BTreeEntry then return fail(INVALID_ARGUMENT, "compareEntries", "values must be BTreeEntry") end if
  keyResult = compareKeys(left.key, right.key)
  if keyResult != 0 then return keyResult end if
  return compareKeys(left.value, right.value)
end function

function entry(key, value)
  if typeof(key) != "bytes" or len(key) == 0 or len(key) > MAX_KEY_BYTES then return fail(INVALID_ARGUMENT, "entry", "key must contain 1..256 bytes") end if
  if typeof(value) != "bytes" or len(value) == 0 or len(value) > MAX_VALUE_BYTES then return fail(INVALID_ARGUMENT, "entry", "value must contain 1..64 bytes") end if
  return BTreeEntry(bytes(key), bytes(value))
end function

function copyEntry(value)
  if value is not BTreeEntry then return fail(INVALID_ARGUMENT, "copyEntry", "value must be BTreeEntry") end if
  return entry(value.key, value.value)
end function

function mergeSorted(left, right)
  result = []
  leftIndex = 0
  rightIndex = 0
  while leftIndex < len(left) and rightIndex < len(right)
    if compareEntries(left[leftIndex], right[rightIndex]) <= 0 then
      result = result + [left[leftIndex]]
      leftIndex = leftIndex + 1
    else
      result = result + [right[rightIndex]]
      rightIndex = rightIndex + 1
    end if
  end while
  while leftIndex < len(left)
    result = result + [left[leftIndex]]
    leftIndex = leftIndex + 1
  end while
  while rightIndex < len(right)
    result = result + [right[rightIndex]]
    rightIndex = rightIndex + 1
  end while
  return result
end function

function sortEntries(values)
  if typeof(values) != "array" then return fail(INVALID_ARGUMENT, "sortEntries", "values must be array") end if
  if len(values) <= 1 then
    result = []
    for each value in values
      result = result + [copyEntry(value)]
    end for
    return result
  end if
  middle = len(values) >> 1
  left = []
  right = []
  for index = 0 to len(values) - 1
    if index < middle then left = left + [values[index]] else right = right + [values[index]] end if
  end for
  return mergeSorted(sortEntries(left), sortEntries(right))
end function

function validateSorted(values, unique, operation)
  if typeof(values) != "array" then return fail(INVALID_ARGUMENT, operation, "entries must be array") end if
  if typeof(unique) != "bool" then return fail(INVALID_ARGUMENT, operation, "unique must be bool") end if
  previous = void
  for each value in values
    checked = copyEntry(value)
    if previous is not void then
      order = compareEntries(previous, checked)
      if order > 0 then return fail(INVALID_ARGUMENT, operation, "entries are not sorted") end if
      if unique and compareKeys(previous.key, checked.key) == 0 then return fail(OBJECT_EXISTS, operation, "duplicate key in unique index") end if
    end if
    previous = checked
  end for
  return true
end function

function encodeMetaPage(treeFile, pageNumber, generation, unique, rootPage, firstLeaf, lastLeaf, height, entryCount)
  if typeof(generation) != "int" or generation < 0 then return fail(INVALID_ARGUMENT, "encodeMetaPage", "generation must be non-negative") end if
  if typeof(unique) != "bool" then return fail(INVALID_ARGUMENT, "encodeMetaPage", "unique must be bool") end if
  if typeof(rootPage) != "int" or rootPage < 0 or typeof(firstLeaf) != "int" or firstLeaf < 0 or typeof(lastLeaf) != "int" or lastLeaf < 0 then return fail(INVALID_ARGUMENT, "encodeMetaPage", "page references must be non-negative") end if
  if typeof(height) != "int" or height < 0 or height > 65535 then return fail(INVALID_ARGUMENT, "encodeMetaPage", "height must fit U16") end if
  if typeof(entryCount) != "int" or entryCount < 0 or entryCount > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "encodeMetaPage", "entryCount must fit U32") end if
  output = page.create(treeFile.pageSize, page.TYPE_BTREE_INTERNAL, treeFile.fileId, pageNumber)
  copyBytes(output, META_DATA_OFFSET, metaMagic(), 0, 4)
  endian.writeU16LE(output, META_DATA_OFFSET + 4, FORMAT_VERSION)
  flags = 0
  if unique then flags = FLAG_UNIQUE end if
  endian.writeU16LE(output, META_DATA_OFFSET + 6, flags)
  endian.writeU64LE(output, META_DATA_OFFSET + 8, endian.uint64FromInt(generation))
  endian.writeU64LE(output, META_DATA_OFFSET + 16, endian.uint64FromInt(rootPage))
  endian.writeU64LE(output, META_DATA_OFFSET + 24, endian.uint64FromInt(firstLeaf))
  endian.writeU64LE(output, META_DATA_OFFSET + 32, endian.uint64FromInt(lastLeaf))
  endian.writeU32LE(output, META_DATA_OFFSET + 40, entryCount)
  endian.writeU16LE(output, META_DATA_OFFSET + 44, height)
  endian.writeU16LE(output, META_DATA_OFFSET + 46, 0)
  endian.writeU64LE(output, META_DATA_OFFSET + 48, endian.makeUInt64(0, 0))
  endian.writeU64LE(output, META_DATA_OFFSET + 56, endian.makeUInt64(0, 0))
  header = page.decodePageHeader(output)
  header.flags = FLAG_META
  header.generation = endian.uint64FromInt(generation)
  // Metadata entryCount is U32; page-header itemCount is not used for meta pages.
  header.itemCount = 0
  header.freeStart = META_DATA_OFFSET + META_DATA_SIZE
  header.freeEnd = treeFile.pageSize
  page.seal(output, header)
  return output
end function

function decodeNative(words, operation, name)
  endian.validateUInt64Words(words, "storage.btree." + operation + "." + name)
  if words.high > endian.MAX_SCALAR_HIGH then return fail(UNSUPPORTED_FORMAT, operation, name + " exceeds native range") end if
  return endian.uint64ToInt(words)
end function

function decodeMetaPage(treeFile, pageNumber)
  encoded = paged_file.readPage(treeFile, pageNumber)
  header = page.verify(encoded)
  if header.pageType != page.TYPE_BTREE_INTERNAL or header.flags != FLAG_META then return fail(CORRUPT_DATA, "decodeMetaPage", "metadata page has wrong type or flags") end if
  if not bytesEqual(slice(encoded, META_DATA_OFFSET, 4), metaMagic()) then return fail(UNSUPPORTED_FORMAT, "decodeMetaPage", "metadata magic mismatch") end if
  if endian.readU16LE(encoded, META_DATA_OFFSET + 4) != FORMAT_VERSION then return fail(UNSUPPORTED_FORMAT, "decodeMetaPage", "metadata format mismatch") end if
  flags = endian.readU16LE(encoded, META_DATA_OFFSET + 6)
  if flags != 0 and flags != FLAG_UNIQUE then return fail(UNSUPPORTED_FORMAT, "decodeMetaPage", "unknown metadata flags") end if
  generation = decodeNative(endian.readU64LE(encoded, META_DATA_OFFSET + 8), "decodeMetaPage", "generation")
  rootPage = decodeNative(endian.readU64LE(encoded, META_DATA_OFFSET + 16), "decodeMetaPage", "rootPage")
  firstLeaf = decodeNative(endian.readU64LE(encoded, META_DATA_OFFSET + 24), "decodeMetaPage", "firstLeaf")
  lastLeaf = decodeNative(endian.readU64LE(encoded, META_DATA_OFFSET + 32), "decodeMetaPage", "lastLeaf")
  entryCount = endian.readU32LE(encoded, META_DATA_OFFSET + 40)
  height = endian.readU16LE(encoded, META_DATA_OFFSET + 44)
  if endian.readU16LE(encoded, META_DATA_OFFSET + 46) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeMetaPage", "reserved metadata field is non-zero") end if
  if endian.readU64LE(encoded, META_DATA_OFFSET + 48).high != 0 or endian.readU64LE(encoded, META_DATA_OFFSET + 48).low != 0 or endian.readU64LE(encoded, META_DATA_OFFSET + 56).high != 0 or endian.readU64LE(encoded, META_DATA_OFFSET + 56).low != 0 then return fail(UNSUPPORTED_FORMAT, "decodeMetaPage", "reserved metadata words are non-zero") end if
  if entryCount == 0 then
    if height != 0 or rootPage != 0 or firstLeaf != 0 or lastLeaf != 0 then return fail(CORRUPT_DATA, "decodeMetaPage", "empty tree metadata is inconsistent") end if
  else
    if height <= 0 or rootPage < 2 or firstLeaf < 2 or lastLeaf < 2 then return fail(CORRUPT_DATA, "decodeMetaPage", "non-empty tree metadata is inconsistent") end if
    if rootPage >= treeFile.pageCount or firstLeaf >= treeFile.pageCount or lastLeaf >= treeFile.pageCount then return fail(CORRUPT_DATA, "decodeMetaPage", "metadata references page outside file") end if
  end if
  return BTreeMeta(generation, flags == FLAG_UNIQUE, rootPage, firstLeaf, lastLeaf, height, entryCount)
end function

function chooseMeta(first, second)
  firstValid = typeof(first) != "error"
  secondValid = typeof(second) != "error"
  if not firstValid and not secondValid then return fail(CORRUPT_DATA, "chooseMeta", "both metadata pages are invalid") end if
  if firstValid and secondValid then
    if first.unique != second.unique then return fail(CORRUPT_DATA, "chooseMeta", "metadata copies disagree on uniqueness") end if
    if first.generation == second.generation then
      if first.rootPage != second.rootPage or first.firstLeaf != second.firstLeaf or first.lastLeaf != second.lastLeaf or first.height != second.height or first.entryCount != second.entryCount then return fail(CORRUPT_DATA, "chooseMeta", "equal metadata generations disagree") end if
      return [first, META_PAGE_A]
    end if
    if first.generation > second.generation then return [first, META_PAGE_A] end if
    return [second, META_PAGE_B]
  end if
  if firstValid then return [first, META_PAGE_A] end if
  return [second, META_PAGE_B]
end function

function create(path, pageSize, fileId, databaseId, unique)
  if typeof(unique) != "bool" then return fail(INVALID_ARGUMENT, "create", "unique must be bool") end if
  treeFile = paged_file.create(path, pageSize, superblock.FILE_TYPE_INDEX, fileId, databaseId)
  first = encodeMetaPage(treeFile, META_PAGE_A, 1, unique, 0, 0, 0, 0, 0)
  second = encodeMetaPage(treeFile, META_PAGE_B, 0, unique, 0, 0, 0, 0, 0)
  paged_file.appendPage(treeFile, first)
  paged_file.appendPage(treeFile, second)
  return BTree(treeFile, BTreeMeta(1, unique, 0, 0, 0, 0, 0), META_PAGE_A, false)
end function

function open(path)
  treeFile = paged_file.open(path)
  if treeFile.fileType != superblock.FILE_TYPE_INDEX then paged_file.close(treeFile); return fail(CORRUPT_DATA, "open", "file is not an index") end if
  if treeFile.pageCount < 2 then paged_file.close(treeFile); return fail(CORRUPT_DATA, "open", "index is shorter than metadata pair") end if
  first = try(decodeMetaPage(treeFile, META_PAGE_A))
  second = try(decodeMetaPage(treeFile, META_PAGE_B))
  selected = try(chooseMeta(first, second))
  if typeof(selected) == "error" then paged_file.close(treeFile); return selected end if
  tree = BTree(treeFile, selected[0], selected[1], false)
  verified = try(verify(tree))
  if typeof(verified) != "error" then return tree end if

  // A valid metadata page can still reference a torn/corrupt newly appended
  // generation. Try the older independently valid metadata generation before
  // declaring the complete index unreadable.
  fallback = void
  fallbackPage = -1
  if selected[1] == META_PAGE_A and typeof(second) != "error" and second.generation < selected[0].generation then fallback = second; fallbackPage = META_PAGE_B end if
  if selected[1] == META_PAGE_B and typeof(first) != "error" and first.generation < selected[0].generation then fallback = first; fallbackPage = META_PAGE_A end if
  if fallback is not void then
    tree.meta = fallback
    tree.activeMetaPage = fallbackPage
    fallbackVerified = try(verify(tree))
    if typeof(fallbackVerified) != "error" then return tree end if
  end if
  paged_file.close(treeFile)
  return verified
end function

function validateOpen(tree, operation)
  if tree is not BTree then return fail(INVALID_ARGUMENT, operation, "tree must be BTree") end if
  if tree.closed then return fail(CLOSED_HANDLE, operation, "tree is closed") end if
  paged_file.validateOpen(tree.pagedFile, "btree." + operation)
  return true
end function

function encodeLeaf(tree, pageNumber, previousPage, nextPage, values)
  if typeof(values) != "array" or len(values) == 0 or len(values) > MAX_LEAF_ENTRIES then return fail(INVALID_ARGUMENT, "encodeLeaf", "leaf must contain 1..10 entries") end if
  output = page.create(tree.pagedFile.pageSize, page.TYPE_BTREE_LEAF, tree.pagedFile.fileId, pageNumber)
  copyBytes(output, 64, leafMagic(), 0, 4)
  endian.writeU16LE(output, 68, FORMAT_VERSION)
  endian.writeU16LE(output, 70, 0)
  endian.writeU16LE(output, 72, len(values))
  endian.writeU16LE(output, 74, 0)
  endian.writeU64LE(output, 76, endian.uint64FromInt(previousPage))
  endian.writeU64LE(output, 84, endian.uint64FromInt(nextPage))
  endian.writeU32LE(output, 92, 0)
  cursor = LEAF_DATA_OFFSET
  previous = void
  for each value in values
    checked = copyEntry(value)
    if previous is not void and compareEntries(previous, checked) > 0 then return fail(INVALID_ARGUMENT, "encodeLeaf", "leaf entries are not sorted") end if
    required = 4 + len(checked.key) + len(checked.value)
    if cursor > tree.pagedFile.pageSize - required then return fail(INVALID_ARGUMENT, "encodeLeaf", "leaf entries exceed page") end if
    endian.writeU16LE(output, cursor, len(checked.key))
    endian.writeU16LE(output, cursor + 2, len(checked.value))
    copyBytes(output, cursor + 4, checked.key, 0, len(checked.key))
    copyBytes(output, cursor + 4 + len(checked.key), checked.value, 0, len(checked.value))
    cursor = cursor + required
    previous = checked
  end for
  header = page.decodePageHeader(output)
  header.itemCount = len(values)
  header.freeStart = cursor
  header.freeEnd = tree.pagedFile.pageSize
  header.generation = endian.uint64FromInt(tree.meta.generation + 1)
  page.seal(output, header)
  return output
end function

function decodeLeaf(tree, pageNumber)
  encoded = paged_file.readPage(tree.pagedFile, pageNumber)
  header = page.verify(encoded)
  if header.pageType != page.TYPE_BTREE_LEAF or header.flags != 0 then return fail(CORRUPT_DATA, "decodeLeaf", "leaf page type or flags are invalid") end if
  if not bytesEqual(slice(encoded, 64, 4), leafMagic()) or endian.readU16LE(encoded, 68) != FORMAT_VERSION or endian.readU16LE(encoded, 70) != 0 or endian.readU16LE(encoded, 74) != 0 or endian.readU32LE(encoded, 92) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeLeaf", "leaf header is unsupported") end if
  count = endian.readU16LE(encoded, 72)
  if count == 0 or count > MAX_LEAF_ENTRIES or header.itemCount != count then return fail(CORRUPT_DATA, "decodeLeaf", "leaf item count is invalid") end if
  previousPage = decodeNative(endian.readU64LE(encoded, 76), "decodeLeaf", "previousPage")
  nextPage = decodeNative(endian.readU64LE(encoded, 84), "decodeLeaf", "nextPage")
  if previousPage >= tree.pagedFile.pageCount or nextPage >= tree.pagedFile.pageCount then return fail(CORRUPT_DATA, "decodeLeaf", "leaf link points outside file") end if
  cursor = LEAF_DATA_OFFSET
  values = []
  previous = void
  for index = 0 to count - 1
    if cursor > len(encoded) - 4 then return fail(CORRUPT_DATA, "decodeLeaf", "leaf entry prefix is truncated") end if
    keyLength = endian.readU16LE(encoded, cursor)
    valueLength = endian.readU16LE(encoded, cursor + 2)
    if keyLength == 0 or keyLength > MAX_KEY_BYTES or valueLength == 0 or valueLength > MAX_VALUE_BYTES then return fail(CORRUPT_DATA, "decodeLeaf", "leaf entry length is invalid") end if
    required = 4 + keyLength + valueLength
    if cursor > len(encoded) - required then return fail(CORRUPT_DATA, "decodeLeaf", "leaf entry is truncated") end if
    current = entry(slice(encoded, cursor + 4, keyLength), slice(encoded, cursor + 4 + keyLength, valueLength))
    if previous is not void and compareEntries(previous, current) > 0 then return fail(CORRUPT_DATA, "decodeLeaf", "leaf entries are not sorted") end if
    values = values + [current]
    previous = current
    cursor = cursor + required
  end for
  if header.freeStart != cursor or header.freeEnd != tree.pagedFile.pageSize then return fail(CORRUPT_DATA, "decodeLeaf", "leaf free-space header is inconsistent") end if
  return BTreeLeaf(pageNumber, previousPage, nextPage, values)
end function

function encodeInternal(tree, pageNumber, level, descriptors)
  if typeof(level) != "int" or level <= 0 or level > 65535 then return fail(INVALID_ARGUMENT, "encodeInternal", "level must be positive U16") end if
  if typeof(descriptors) != "array" or len(descriptors) < 2 or len(descriptors) > MAX_INTERNAL_CHILDREN then return fail(INVALID_ARGUMENT, "encodeInternal", "internal node must contain 2..12 children") end if
  output = page.create(tree.pagedFile.pageSize, page.TYPE_BTREE_INTERNAL, tree.pagedFile.fileId, pageNumber)
  copyBytes(output, 64, internalMagic(), 0, 4)
  endian.writeU16LE(output, 68, FORMAT_VERSION)
  endian.writeU16LE(output, 70, level)
  endian.writeU16LE(output, 72, len(descriptors) - 1)
  endian.writeU16LE(output, 74, 0)
  endian.writeU64LE(output, 76, endian.uint64FromInt(descriptors[0].pageNumber))
  endian.writeU32LE(output, 84, 0)
  cursor = INTERNAL_DATA_OFFSET
  for index = 1 to len(descriptors) - 1
    descriptor = descriptors[index]
    if descriptor is not NodeDescriptor or typeof(descriptor.firstKey) != "bytes" or len(descriptor.firstKey) == 0 or len(descriptor.firstKey) > MAX_KEY_BYTES then return fail(INVALID_ARGUMENT, "encodeInternal", "invalid child descriptor") end if
    required = 12 + len(descriptor.firstKey)
    if cursor > tree.pagedFile.pageSize - required then return fail(INVALID_ARGUMENT, "encodeInternal", "internal entries exceed page") end if
    endian.writeU16LE(output, cursor, len(descriptor.firstKey))
    endian.writeU16LE(output, cursor + 2, 0)
    endian.writeU64LE(output, cursor + 4, endian.uint64FromInt(descriptor.pageNumber))
    copyBytes(output, cursor + 12, descriptor.firstKey, 0, len(descriptor.firstKey))
    cursor = cursor + required
  end for
  header = page.decodePageHeader(output)
  header.itemCount = len(descriptors) - 1
  header.freeStart = cursor
  header.freeEnd = tree.pagedFile.pageSize
  header.generation = endian.uint64FromInt(tree.meta.generation + 1)
  page.seal(output, header)
  return output
end function

function decodeInternal(tree, pageNumber)
  encoded = paged_file.readPage(tree.pagedFile, pageNumber)
  header = page.verify(encoded)
  if header.pageType != page.TYPE_BTREE_INTERNAL or header.flags != 0 then return fail(CORRUPT_DATA, "decodeInternal", "internal page type or flags are invalid") end if
  if not bytesEqual(slice(encoded, 64, 4), internalMagic()) or endian.readU16LE(encoded, 68) != FORMAT_VERSION or endian.readU16LE(encoded, 74) != 0 or endian.readU32LE(encoded, 84) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeInternal", "internal header is unsupported") end if
  level = endian.readU16LE(encoded, 70)
  keyCount = endian.readU16LE(encoded, 72)
  if level == 0 or keyCount == 0 or keyCount >= MAX_INTERNAL_CHILDREN or header.itemCount != keyCount then return fail(CORRUPT_DATA, "decodeInternal", "internal shape is invalid") end if
  firstChild = decodeNative(endian.readU64LE(encoded, 76), "decodeInternal", "firstChild")
  if firstChild < 2 or firstChild >= tree.pagedFile.pageCount then return fail(CORRUPT_DATA, "decodeInternal", "first child is outside file") end if
  children = [firstChild]
  separators = []
  cursor = INTERNAL_DATA_OFFSET
  previous = void
  for index = 0 to keyCount - 1
    if cursor > len(encoded) - 12 then return fail(CORRUPT_DATA, "decodeInternal", "internal entry prefix is truncated") end if
    keyLength = endian.readU16LE(encoded, cursor)
    if keyLength == 0 or keyLength > MAX_KEY_BYTES or endian.readU16LE(encoded, cursor + 2) != 0 then return fail(CORRUPT_DATA, "decodeInternal", "internal key is invalid") end if
    child = decodeNative(endian.readU64LE(encoded, cursor + 4), "decodeInternal", "child")
    if child < 2 or child >= tree.pagedFile.pageCount then return fail(CORRUPT_DATA, "decodeInternal", "child is outside file") end if
    if cursor > len(encoded) - 12 - keyLength then return fail(CORRUPT_DATA, "decodeInternal", "internal key is truncated") end if
    key = slice(encoded, cursor + 12, keyLength)
    if previous is not void and compareKeys(previous, key) >= 0 then return fail(CORRUPT_DATA, "decodeInternal", "separator keys are not strictly increasing") end if
    separators = separators + [key]
    children = children + [child]
    previous = key
    cursor = cursor + 12 + keyLength
  end for
  if header.freeStart != cursor or header.freeEnd != tree.pagedFile.pageSize then return fail(CORRUPT_DATA, "decodeInternal", "internal free-space header is inconsistent") end if
  return BTreeInternal(pageNumber, level, children, separators)
end function

function chunkEntries(values, pageSize)
  chunks = []
  current = []
  currentBytes = LEAF_DATA_OFFSET
  for each value in values
    required = 4 + len(value.key) + len(value.value)
    if len(current) > 0 and (len(current) >= MAX_LEAF_ENTRIES or currentBytes > pageSize - required) then
      chunks = chunks + [current]
      current = []
      currentBytes = LEAF_DATA_OFFSET
    end if
    current = current + [value]
    currentBytes = currentBytes + required
  end for
  if len(current) > 0 then chunks = chunks + [current] end if
  return chunks
end function

function sliceArray(values, offset, count)
  result = []
  if count <= 0 then return result end if
  for index = offset to offset + count - 1
    result = result + [values[index]]
  end for
  return result
end function

function publish(tree, rootPage, firstLeaf, lastLeaf, height, entryCount)
  newGeneration = tree.meta.generation + 1
  target = META_PAGE_A
  if tree.activeMetaPage == META_PAGE_A then target = META_PAGE_B end if
  encoded = encodeMetaPage(tree.pagedFile, target, newGeneration, tree.meta.unique, rootPage, firstLeaf, lastLeaf, height, entryCount)
  paged_file.writePage(tree.pagedFile, target, encoded)
  paged_file.flush(tree.pagedFile)
  tree.meta = BTreeMeta(newGeneration, tree.meta.unique, rootPage, firstLeaf, lastLeaf, height, entryCount)
  tree.activeMetaPage = target
  return true
end function

function commitSorted(tree, values)
  validateOpen(tree, "commitSorted")
  validateSorted(values, tree.meta.unique, "commitSorted")
  if len(values) == 0 then
    publish(tree, 0, 0, 0, 0, 0)
    return true
  end if

  chunks = chunkEntries(values, tree.pagedFile.pageSize)
  leafStart = tree.pagedFile.pageCount
  descriptors = []
  for index = 0 to len(chunks) - 1
    pageNumber = leafStart + index
    previousPage = 0
    nextPage = 0
    if index > 0 then previousPage = pageNumber - 1 end if
    if index < len(chunks) - 1 then nextPage = pageNumber + 1 end if
    encoded = encodeLeaf(tree, pageNumber, previousPage, nextPage, chunks[index])
    paged_file.appendPage(tree.pagedFile, encoded)
    descriptors = descriptors + [NodeDescriptor(pageNumber, bytes(chunks[index][0].key), 0)]
  end for

  level = 1
  while len(descriptors) > 1
    nextLevel = []
    offset = 0
    while offset < len(descriptors)
      remaining = len(descriptors) - offset
      take = remaining
      if take > MAX_INTERNAL_CHILDREN then take = MAX_INTERNAL_CHILDREN end if
      if remaining - take == 1 and take > 2 then take = take - 1 end if
      group = sliceArray(descriptors, offset, take)
      pageNumber = tree.pagedFile.pageCount
      encoded = encodeInternal(tree, pageNumber, level, group)
      paged_file.appendPage(tree.pagedFile, encoded)
      nextLevel = nextLevel + [NodeDescriptor(pageNumber, bytes(group[0].firstKey), level)]
      offset = offset + take
    end while
    descriptors = nextLevel
    level = level + 1
  end while

  root = descriptors[0]
  publish(tree, root.pageNumber, leafStart, leafStart + len(chunks) - 1, root.level + 1, len(values))
  return true
end function

function bulkLoad(tree, values)
  validateOpen(tree, "bulkLoad")
  sorted = sortEntries(values)
  commitSorted(tree, sorted)
  return len(sorted)
end function

function allEntries(tree)
  validateOpen(tree, "allEntries")
  if tree.meta.entryCount == 0 then return [] end if
  result = []
  currentPage = tree.meta.firstLeaf
  previousPage = 0
  visited = []
  while currentPage != 0
    for each seen in visited
      if seen == currentPage then return fail(CORRUPT_DATA, "allEntries", "leaf chain contains a cycle") end if
    end for
    visited = visited + [currentPage]
    leaf = decodeLeaf(tree, currentPage)
    if leaf.previousPage != previousPage then return fail(CORRUPT_DATA, "allEntries", "leaf backward link mismatch") end if
    for each value in leaf.entries
      if len(result) > 0 and compareEntries(result[len(result) - 1], value) > 0 then return fail(CORRUPT_DATA, "allEntries", "global leaf order is invalid") end if
      result = result + [value]
    end for
    previousPage = currentPage
    currentPage = leaf.nextPage
  end while
  if previousPage != tree.meta.lastLeaf or len(result) != tree.meta.entryCount then return fail(CORRUPT_DATA, "allEntries", "leaf chain does not match metadata") end if
  return result
end function

function insert(tree, key, value)
  validateOpen(tree, "insert")
  candidate = entry(key, value)
  values = allEntries(tree)
  result = []
  inserted = false
  for each current in values
    keyOrder = compareKeys(current.key, candidate.key)
    if tree.meta.unique and keyOrder == 0 then return fail(OBJECT_EXISTS, "insert", "duplicate key in unique index") end if
    if not inserted and compareEntries(candidate, current) < 0 then
      result = result + [candidate]
      inserted = true
    end if
    result = result + [current]
  end for
  if not inserted then result = result + [candidate] end if
  commitSorted(tree, result)
  return true
end function

function remove(tree, key, value)
  validateOpen(tree, "remove")
  candidate = entry(key, value)
  values = allEntries(tree)
  result = []
  removed = false
  for each current in values
    if not removed and compareEntries(current, candidate) == 0 then
      removed = true
    else
      result = result + [current]
    end if
  end for
  if not removed then return fail(OBJECT_NOT_FOUND, "remove", "key/value pair not found") end if
  commitSorted(tree, result)
  return true
end function

function find(tree, key)
  validateOpen(tree, "find")
  if typeof(key) != "bytes" or len(key) == 0 or len(key) > MAX_KEY_BYTES then return fail(INVALID_ARGUMENT, "find", "key must contain 1..256 bytes") end if
  result = []
  for each current in allEntries(tree)
    comparison = compareKeys(current.key, key)
    if comparison == 0 then result = result + [bytes(current.value)] end if
    if comparison > 0 then return result end if
  end for
  return result
end function

function range(tree, lower, lowerInclusive, upper, upperInclusive, maximum)
  validateOpen(tree, "range")
  if lower is not void and typeof(lower) != "bytes" then return fail(INVALID_ARGUMENT, "range", "lower must be bytes or void") end if
  if upper is not void and typeof(upper) != "bytes" then return fail(INVALID_ARGUMENT, "range", "upper must be bytes or void") end if
  if typeof(lowerInclusive) != "bool" or typeof(upperInclusive) != "bool" then return fail(INVALID_ARGUMENT, "range", "inclusive flags must be bool") end if
  if typeof(maximum) != "int" or maximum < 0 then return fail(INVALID_ARGUMENT, "range", "maximum must be non-negative") end if
  result = []
  for each current in allEntries(tree)
    accepted = true
    if lower is not void then
      comparison = compareKeys(current.key, lower)
      if comparison < 0 or (comparison == 0 and not lowerInclusive) then accepted = false end if
    end if
    if upper is not void then
      comparison = compareKeys(current.key, upper)
      if comparison > 0 or (comparison == 0 and not upperInclusive) then accepted = false end if
    end if
    if accepted then
      result = result + [copyEntry(current)]
      if maximum > 0 and len(result) >= maximum then return result end if
    end if
  end for
  return result
end function

function visitContains(state, pageNumber)
  for each existing in state.pages
    if existing == pageNumber then return true end if
  end for
  return false
end function

function auditNode(tree, pageNumber, expectedLevel, state)
  if visitContains(state, pageNumber) then return fail(CORRUPT_DATA, "auditNode", "node graph contains a cycle or duplicate child") end if
  state.pages = state.pages + [pageNumber]
  if expectedLevel == 0 then
    leaf = decodeLeaf(tree, pageNumber)
    return BTreeAudit(bytes(leaf.entries[0].key), bytes(leaf.entries[len(leaf.entries) - 1].key), len(leaf.entries), 1)
  end if
  node = decodeInternal(tree, pageNumber)
  if node.level != expectedLevel then return fail(CORRUPT_DATA, "auditNode", "internal level mismatch") end if
  totalEntries = 0
  totalLeaves = 0
  firstKey = void
  lastKey = void
  previousLast = void
  for index = 0 to len(node.children) - 1
    child = auditNode(tree, node.children[index], expectedLevel - 1, state)
    if firstKey is void then firstKey = bytes(child.firstKey) end if
    if previousLast is not void and compareKeys(previousLast, child.firstKey) >= 0 then return fail(CORRUPT_DATA, "auditNode", "child key ranges overlap") end if
    if index > 0 and compareKeys(node.separators[index - 1], child.firstKey) != 0 then return fail(CORRUPT_DATA, "auditNode", "separator does not equal right-child first key") end if
    previousLast = bytes(child.lastKey)
    lastKey = bytes(child.lastKey)
    totalEntries = totalEntries + child.entryCount
    totalLeaves = totalLeaves + child.leafCount
  end for
  return BTreeAudit(firstKey, lastKey, totalEntries, totalLeaves)
end function

function verify(tree)
  validateOpen(tree, "verify")
  values = allEntries(tree)
  if len(values) != tree.meta.entryCount then return fail(CORRUPT_DATA, "verify", "entry count mismatch") end if
  if tree.meta.entryCount == 0 then return true end if
  state = VisitState([])
  audit = auditNode(tree, tree.meta.rootPage, tree.meta.height - 1, state)
  if audit.entryCount != tree.meta.entryCount then return fail(CORRUPT_DATA, "verify", "node graph count mismatch") end if
  if not bytesEqual(audit.firstKey, values[0].key) or not bytesEqual(audit.lastKey, values[len(values) - 1].key) then return fail(CORRUPT_DATA, "verify", "node graph boundary mismatch") end if
  return true
end function

function count(tree)
  validateOpen(tree, "count")
  return tree.meta.entryCount
end function

function height(tree)
  validateOpen(tree, "height")
  return tree.meta.height
end function

function isUnique(tree)
  validateOpen(tree, "isUnique")
  return tree.meta.unique
end function

function close(tree)
  validateOpen(tree, "close")
  paged_file.close(tree.pagedFile)
  tree.closed = true
  return true
end function

function componentName()
  return "storage.btree"
end function

function targetMilestone()
  return "M11"
end function

function isImplemented()
  return true
end function
