package minisql.common.crc32c

// CRC-32C (Castagnoli), reflected polynomial 0x82F63B78.

const INVALID_ARGUMENT = 9001
const POLYNOMIAL = 0x82F63B78
const INITIAL = 0xFFFFFFFF
const XOR_OUT = 0xFFFFFFFF
const MAX_U32 = 0xFFFFFFFF

function invalid(operation, message)
  return error(INVALID_ARGUMENT, "common.crc32c." + operation + ": " + message)
end function

function validateRange(buffer, offset, length, operation)
  if typeof(buffer) != "bytes" then
    return invalid(operation, "buffer must be bytes")
  end if
  if typeof(offset) != "int" or typeof(length) != "int" then
    return invalid(operation, "offset and length must be int")
  end if
  if offset < 0 or length < 0 or offset > len(buffer) or length > len(buffer) - offset then
    return invalid(operation, "range exceeds buffer bounds")
  end if
  return true
end function

function update(previous, buffer, offset, length)
  if typeof(previous) != "int" or previous < 0 or previous > MAX_U32 then
    return invalid("update", "previous checksum must fit U32")
  end if
  validateRange(buffer, offset, length, "update")
  if length == 0 then return previous end if
  crc = previous ^ XOR_OUT
  for index = offset to offset + length - 1
    crc = crc ^ buffer[index]
    for bit = 0 to 7
      if (crc & 1) != 0 then
        crc = (crc >> 1) ^ POLYNOMIAL
      else
        crc = crc >> 1
      end if
    end for
  end for
  return (crc ^ XOR_OUT) & MAX_U32
end function

function computeRange(buffer, offset, length)
  return update(0, buffer, offset, length)
end function

function compute(buffer)
  if typeof(buffer) != "bytes" then
    return invalid("compute", "buffer must be bytes")
  end if
  return computeRange(buffer, 0, len(buffer))
end function

function verifyRange(buffer, offset, length, expected)
  if typeof(expected) != "int" or expected < 0 or expected > MAX_U32 then
    return invalid("verifyRange", "expected checksum must fit U32")
  end if
  return computeRange(buffer, offset, length) == expected
end function

function componentName()
  return "common.crc32c"
end function

function targetMilestone()
  return "M2"
end function

function isImplemented()
  return true
end function
