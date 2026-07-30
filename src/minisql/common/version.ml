package minisql.common.version

const PRODUCT_NAME = "MiniSQL"
const PRODUCT_VERSION = "1.0.0"
const MILESTONE = "M50"
const REVISION = "M48-M50R3"
const WIRE_PROTOCOL_VERSION = 1
const DATABASE_FORMAT_VERSION = 1

function productName()
  return PRODUCT_NAME
end function

function productVersion()
  return PRODUCT_VERSION
end function

function milestone()
  return MILESTONE
end function

function versionLine(component)
  return PRODUCT_NAME + " " + PRODUCT_VERSION + " " + component
end function

function componentName()
  return "common.version"
end function

function targetMilestone()
  return "M0"
end function

function isImplemented()
  return true
end function
