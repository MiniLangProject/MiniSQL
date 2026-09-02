package minisql.common.version
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

// Central product, wire-protocol, and database-format identity. Persisted and
// negotiated versions change independently of the human-readable product
// version so compatibility checks remain explicit.

const PRODUCT_NAME = "MiniSQL"
const PRODUCT_VERSION = "1.1.0"
const MILESTONE = "M50"
const REVISION = "M48-M50R3"
const WIRE_PROTOCOL_VERSION = 1
const DATABASE_FORMAT_VERSION = 1

// Performs the product name operation for this module.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function productName()
  return PRODUCT_NAME
end function

// Performs the product version operation for this module.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function productVersion()
  return PRODUCT_VERSION
end function

// Performs the milestone operation for this module.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function milestone()
  return MILESTONE
end function

// Performs the version line operation for this module.
// Inputs: `component`. Returns the produced value or propagates a structured error from validation or delegated operations.
function versionLine(component)
  return PRODUCT_NAME + " " + PRODUCT_VERSION + " " + component
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "common.version"
end function

// Returns the milestone in which this component became available.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M0"
end function

// Reports whether this component is implemented.
// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
