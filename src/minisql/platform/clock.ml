//! Provides minisql platform clock facilities for this project.

package minisql.platform.clock
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import std.time as time_api

/// Monotonic timing and bounded sleeping used by lock waits and server polling.

const INVALID_ARGUMENT = 9001

/// Performs the monotonic milliseconds operation for this module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function monotonicMilliseconds()
  return time_api.ticks()
end function

/// Performs the sleep milliseconds operation for this module.
/// Inputs: `milliseconds`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param milliseconds milliseconds value consumed by this operation.
function sleepMilliseconds(milliseconds)
  if typeof(milliseconds) != "int" or milliseconds < 0 or milliseconds > 4294967295 then
    return error(INVALID_ARGUMENT, "platform.clock.sleepMilliseconds: milliseconds must fit U32")
  end if
  time_api.sleep(milliseconds)
  return true
end function

/// Performs the componentName operation for the minisql platform clock module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "platform.clock"
end function

/// Performs the targetMilestone operation for the minisql platform clock module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M3"
end function

/// Returns whether implemented satisfies the condition required by the minisql platform clock module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
