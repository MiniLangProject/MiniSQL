package tests.support.testkit

struct TestState
  checks
  failures
end struct

function create()
  return TestState(0, 0)
end function

function record(state, condition, label)
  state.checks = state.checks + 1
  if not condition then
    state.failures = state.failures + 1
    print "FAIL: " + label
  end if
end function


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

function equal(state, actual, expected, label)
  state.checks = state.checks + 1
  if actual != expected then
    state.failures = state.failures + 1
    print "FAIL: " + label + " expected=" + renderValue(expected) + " actual=" + renderValue(actual)
  end if
end function

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

function verifyChecks(state, expected, label)
  if state.checks != expected then
    state.failures = state.failures + 1
    print "FAIL: " + label + " expected checks=" + expected + " actual=" + state.checks
  end if
end function

function finish(state, successLine, failurePrefix)
  if state.failures != 0 then
    print failurePrefix + " (checks=" + state.checks + ", failures=" + state.failures + ")"
    return 1
  end if
  print successLine
  return 0
end function
