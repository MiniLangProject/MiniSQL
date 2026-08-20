package tests.support.testkit

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

// Mutable assertion accounting shared by the lightweight test helpers.
struct TestState
  // Number of assertions executed, including successful assertions.
  checks
  // Number of assertions that emitted a failure diagnostic.
  failures
end struct

// Creates an empty test state with zero recorded checks and failures.
function create()
  return TestState(0, 0)
end function

// Records a labeled Boolean assertion, increments the check count, and emits a diagnostic when false.
function record(state, condition, label)
  state.checks = state.checks + 1
  if not condition then
    state.failures = state.failures + 1
    print "FAIL: " + label
  end if
end function


// Converts supported test values into stable diagnostic text without dereferencing unknown runtime shapes.
function renderValue(value)
  kind = typeof(value)
  if kind == "string" then return "\"" + value + "\"" end if
  if kind == "int" or kind == "float" then return "" + value end if
  if kind == "bool" then
    if value then return "true" end if
    return "false"
  end if
  if kind == "void" then return "<void>" end if
  if kind == "error" then return "<error code=" + value.code + ">" end if
  if kind == "struct" or kind == "enum" then return "<" + typeName(value) + ">" end if
  if kind == "array" or kind == "bytes" then return "<" + kind + " length=" + len(value) + ">" end if
  return "<" + kind + ">"
end function

// Records an equality assertion and emits rendered expected and actual values when it fails.
function equal(state, actual, expected, label)
  state.checks = state.checks + 1
  if actual != expected then
    state.failures = state.failures + 1
    print "FAIL: " + label + " expected=" + renderValue(expected) + " actual=" + renderValue(actual)
  end if
end function

// Records that an operation failed with the exact expected error code, distinguishing missing errors from wrong errors.
function errorCode(state, actual, expectedCode, label)
  state.checks = state.checks + 1
  if typeof(actual) != "error" then
    state.failures = state.failures + 1
    print "FAIL: " + label + " expected error but got " + typeof(actual)
    return
  end if
  if actual.code != expectedCode then
    state.failures = state.failures + 1
    print "FAIL: " + label + " expected error code=" + expectedCode + " actual=" + actual.code
  end if
end function

// Adds a failure when the executed assertion count differs from the test's declared coverage contract.
function verifyChecks(state, expected, label)
  if state.checks != expected then
    state.failures = state.failures + 1
    print "FAIL: " + label + " expected checks=" + expected + " actual=" + state.checks
  end if
end function

// Prints the suite success marker and returns zero when no checks failed; otherwise prints a failure summary and returns one.
function finish(state, successLine, failurePrefix)
  if state.failures != 0 then
    print failurePrefix + " (checks=" + state.checks + ", failures=" + state.failures + ")"
    return 1
  end if
  print successLine
  return 0
end function
