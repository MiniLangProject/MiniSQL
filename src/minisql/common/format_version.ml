//! Defines the incompatible storage generation independently of the wire protocol.

package minisql.common.format_version
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

/// Database generation requiring binary floats, aligned rows and table metadata pages.
const DATABASE = 2
/// User-table format with a mandatory identity page at logical page zero.
const TABLE = 2
/// Index format with typed, little-endian numeric keys and semantic comparison.
const INDEX = 2
/// Row encoding with aligned values and little-endian IEEE-754 binary64 floats.
const ROW = 2
/// Overflow encoding with a U32 value length and an independent pointer checksum.
const OVERFLOW = 2
/// The existing WAL framing is unchanged; its page images carry storage generation two.
const WAL = 1
/// The common logical page header remains byte-compatible with its original layout.
const PAGE = 1
/// The fixed redundant superblock layout remains unchanged.
const SUPERBLOCK = 1

/// Returns this module's stable component identity.
function componentName()
  return "common.format_version"
end function

/// Identifies the storage-generation work that introduced this module.
function targetMilestone()
  return "StorageV2"
end function

/// Reports that the version registry is implemented.
function isImplemented()
  return true
end function
