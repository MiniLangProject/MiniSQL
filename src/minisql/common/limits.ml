package minisql.common.limits

const DEFAULT_PORT = 7432
const DEFAULT_PAGE_SIZE = 4096
const MIN_PAGE_SIZE = 4096
const MAX_PAGE_SIZE = 32768
const MAX_IDENTIFIER_BYTES = 128
const MAX_SQL_NESTING = 64
const MAX_DECIMAL_PRECISION = 18
const MAX_TIME_PRECISION = 6

function isSupportedPageSize(pageSize)
  return pageSize == 4096 or pageSize == 8192 or pageSize == 16384 or pageSize == 32768
end function

function componentName()
  return "common.limits"
end function

function targetMilestone()
  return "M0"
end function

function isImplemented()
  return true
end function
