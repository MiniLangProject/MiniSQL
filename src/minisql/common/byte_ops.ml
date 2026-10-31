//! Provides allocation-free byte hashing and comparison primitives.

package minisql.common.byte_ops

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

/// Small byte sequences remain faster in generated MiniLang than across the
/// inline-assembly operand boundary.
const INLINE_ASM_HASH_MIN_BYTES = 16

/// Returns the stable module-catalog component name.
function componentName()
  return "common.byte_ops"
end function

/// Returns the first milestone whose byte-processing contracts this module extends.
function targetMilestone()
  return "M2"
end function

/// Confirms that the cataloged byte primitives are available.
function isImplemented()
  return true
end function

/// Hashes a byte sequence with MiniSQL's stable 31-bit FNV-1a variant.
/// The caller supplies the initial state so composite SQL values can preserve
/// their existing serialized hash contract. The unsafe load is bounded by the
/// loop condition before every access and the input remains rooted by asm.
/// @param input Byte sequence to hash without allocating a copy.
/// @param seed Initial FNV state; only its low 31 bits participate.
function inline fnv1a31(input, seed)
  count = len(input)
  return asm unsafe x64(in input as bytes, in seed as int, in count as int, scratch index as int, scratch byteValue as int) returns int
    mov result, seed
    and result, 2147483647
    mov index, 0
    label scan
    cmp index, count
    jge done
    movzx byteValue, byte [input.data + index]
    xor result, byteValue
    imul result, 16777619
    and result, 2147483647
    add index, 1
    jmp scan
    label done
  end asm
end function

/// Hashes bytes through the fastest measured implementation for their length.
/// Generated MiniLang wins below 16 bytes because it avoids assembly operand
/// setup; the bounded assembly scanner wins for longer SQL text/binary values.
/// @param input Byte sequence to hash without allocating a copy.
/// @param seed Initial FNV state; only its low 31 bits participate.
function inline fnv1a31Adaptive(input, seed)
  if len(input) < INLINE_ASM_HASH_MIN_BYTES then
    result = seed & 2147483647
    if len(input) > 0 then
      for index = 0 to len(input) - 1
        result = ((result ^ input[index]) * 16777619) & 2147483647
      end for
    end if
    return result
  end if
  return fnv1a31(input, seed)
end function

/// Compares two byte sequences in unsigned lexicographic order.
/// The assembly loop only reads indices below the shorter input length; length
/// ordering is resolved in MiniLang after equal prefixes have been exhausted.
/// @param left Left byte sequence.
/// @param right Right byte sequence.
function inline compareLexicographic(left, right)
  shared = len(left)
  if len(right) < shared then shared = len(right) end if
  result = asm unsafe x64(in left as bytes, in right as bytes, in shared as int, scratch index as int, scratch leftByte as int, scratch rightByte as int) returns int
    mov result, 0
    mov index, 0
    label scan
    cmp index, shared
    jge done
    movzx leftByte, byte [left.data + index]
    movzx rightByte, byte [right.data + index]
    cmp leftByte, rightByte
    jl less
    cmp leftByte, rightByte
    jg greater
    add index, 1
    jmp scan
    label less
    mov result, -1
    jmp done
    label greater
    mov result, 1
    label done
  end asm
  if result != 0 then return result end if
  if len(left) < len(right) then return -1 end if
  if len(left) > len(right) then return 1 end if
  return 0
end function
