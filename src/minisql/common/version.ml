//! Provides minisql common version facilities for this project.

package minisql.common.version
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

/// Central product, wire-protocol, and database-format identity. Persisted and

const PRODUCT_NAME = "MiniSQL"
/// Defines the product version constant used by the minisql common version module.
const PRODUCT_VERSION = "1.1.0"
/// Defines the milestone constant used by the minisql common version module.
const MILESTONE = "M50"
/// Defines the revision constant used by the minisql common version module.
const REVISION = "M48-M50R3"
/// Defines the wire protocol version constant used by the minisql common version module.
const WIRE_PROTOCOL_VERSION = 1
/// Defines the database format version constant used by the minisql common version module.
const DATABASE_FORMAT_VERSION = 1

/// Performs the product name operation for this module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function productName()
  return PRODUCT_NAME
end function

/// Performs the product version operation for this module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function productVersion()
  return PRODUCT_VERSION
end function

/// Performs the milestone operation for this module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function milestone()
  return MILESTONE
end function

/// Performs the version line operation for this module.
/// Inputs: `component`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param component component value consumed by this operation.
function versionLine(component)
  return PRODUCT_NAME + " " + PRODUCT_VERSION + " " + component
end function

/// Performs the componentName operation for the minisql common version module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "common.version"
end function

/// Performs the targetMilestone operation for the minisql common version module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M0"
end function

/// Returns whether implemented satisfies the condition required by the minisql common version module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
