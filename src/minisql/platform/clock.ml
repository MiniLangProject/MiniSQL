package minisql.platform.clock
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import std.time as time_api

// Monotonic timing and bounded sleeping used by lock waits and server polling.
// Durations are expressed in milliseconds and wall-clock adjustments cannot
// move the monotonic counter backwards.

const INVALID_ARGUMENT = 9001

// Performs the monotonic milliseconds operation for this module.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function monotonicMilliseconds()
  return time_api.ticks()
end function

// Performs the sleep milliseconds operation for this module.
// Inputs: `milliseconds`. Returns the produced value or propagates a structured error from validation or delegated operations.
function sleepMilliseconds(milliseconds)
  if typeof(milliseconds) != "int" or milliseconds < 0 or milliseconds > 4294967295 then
    return error(INVALID_ARGUMENT, "platform.clock.sleepMilliseconds: milliseconds must fit U32")
  end if
  time_api.sleep(milliseconds)
  return true
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "platform.clock"
end function

// Returns the milestone in which this component became available.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M3"
end function

// Reports whether this component is implemented.
// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
