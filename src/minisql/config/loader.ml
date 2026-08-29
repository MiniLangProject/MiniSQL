package minisql.config.loader

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.config.model as model
import minisql.config.validation as validation
import minisql.platform.file as file_api

const INVALID_CONFIGURATION = 9002
const MAX_CONFIG_BYTES = 1048576

const JSON_NULL = 0
const JSON_BOOL = 1
const JSON_INT = 2
const JSON_STRING = 3
const JSON_OBJECT = 4
const JSON_ARRAY = 5

// Groups the JSON value state and preserves the field relationships documented below.
struct JsonValue
  // Stores the kind associated with this value.
  kind
  // Stores the scalar associated with this value.
  scalar
  // Tracks the items numeric value.
  items
end struct

// Groups the JSON pair state and preserves the field relationships documented below.
struct JsonPair
  // Stores the key associated with this value.
  key
  // Stores the value associated with this value.
  value
end struct

// Groups the parser state and preserves the field relationships documented below.
struct Parser
  // Stores the data associated with this value.
  data
  // Tracks the position numeric value.
  position
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(operation, message)
  return error(INVALID_CONFIGURATION, "config.loader." + operation + ": " + message)
end function

// Implements skip whitespace for this module.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function skipWhitespace(parser)
  while parser.position < len(parser.data)
    value = parser.data[parser.position]
    if value == 32 or value == 9 or value == 10 or value == 13 then
      parser.position = parser.position + 1
    else
      break
    end if
  end while
  return true
end function

// Implements peek for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function peek(parser)
  skipWhitespace(parser)
  if parser.position >= len(parser.data) then return -1 end if
  return parser.data[parser.position]
end function

// Implements expect for this module.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function expect(parser, expected, operation)
  skipWhitespace(parser)
  if parser.position >= len(parser.data) or parser.data[parser.position] != expected then
    return fail(operation, "unexpected JSON token at byte " + parser.position)
  end if
  parser.position = parser.position + 1
  return true
end function

// Parses string using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function parseString(parser)
  expect(parser, 34, "parseString")
  values = []
  while parser.position < len(parser.data)
    value = parser.data[parser.position]
    parser.position = parser.position + 1
    if value == 34 then return decode(bytes(values)) end if
    if value == 92 then
      if parser.position >= len(parser.data) then return fail("parseString", "truncated escape") end if
      escaped = parser.data[parser.position]
      parser.position = parser.position + 1
      if escaped == 34 or escaped == 92 or escaped == 47 then
        values = values + [escaped]
      else if escaped == 98 then
        values = values + [8]
      else if escaped == 102 then
        values = values + [12]
      else if escaped == 110 then
        values = values + [10]
      else if escaped == 114 then
        values = values + [13]
      else if escaped == 116 then
        values = values + [9]
      else
        return fail("parseString", "unsupported JSON escape")
      end if
    else
      if value < 32 then return fail("parseString", "control byte in string") end if
      values = values + [value]
    end if
  end while
  return fail("parseString", "unterminated string")
end function

// Returns whether the supplied value satisfies the digit condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isDigit(value)
  return value >= 48 and value <= 57
end function

// Parses integer using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function parseInteger(parser)
  skipWhitespace(parser)
  start = parser.position
  if parser.position < len(parser.data) and parser.data[parser.position] == 45 then parser.position = parser.position + 1 end if
  digitStart = parser.position
  digits = 0
  while parser.position < len(parser.data) and isDigit(parser.data[parser.position])
    parser.position = parser.position + 1
    digits = digits + 1
  end while
  if digits == 0 then return fail("parseInteger", "expected integer") end if
  if parser.data[digitStart] == 48 and digits > 1 then return fail("parseInteger", "leading zero is not valid JSON") end if
  if parser.position < len(parser.data) then
    next = parser.data[parser.position]
    if next == 46 or next == 69 or next == 101 then return fail("parseInteger", "floating JSON numbers are not allowed in configuration") end if
  end if
  text = decode(slice(parser.data, start, parser.position - start))
  value = toNumber(text)
  if typeof(value) != "int" then return fail("parseInteger", "integer is outside the MiniLang range") end if
  return value
end function

// Implements match literal for this module.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function matchLiteral(parser, text)
  encoded = bytes(text)
  if parser.position > len(parser.data) - len(encoded) then return false end if
  if len(encoded) > 0 then
    for index = 0 to len(encoded) - 1
      if parser.data[parser.position + index] != encoded[index] then return false end if
    end for
  end if
  parser.position = parser.position + len(encoded)
  return true
end function

// Parses array using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function parseArray(parser)
  expect(parser, 91, "parseArray")
  values = []
  if peek(parser) == 93 then parser.position = parser.position + 1; return JsonValue(JSON_ARRAY, void, values) end if
  while true
    values = values + [parseValue(parser)]
    next = peek(parser)
    if next == 44 then
      parser.position = parser.position + 1
    else if next == 93 then
      parser.position = parser.position + 1
      break
    else
      return fail("parseArray", "expected comma or closing bracket")
    end if
  end while
  return JsonValue(JSON_ARRAY, void, values)
end function

// Parses object using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function parseObject(parser)
  expect(parser, 123, "parseObject")
  pairs = []
  if peek(parser) == 125 then parser.position = parser.position + 1; return JsonValue(JSON_OBJECT, void, pairs) end if
  while true
    if peek(parser) != 34 then return fail("parseObject", "object key must be string") end if
    key = parseString(parser)
    for each existing in pairs
      if existing.key == key then return fail("parseObject", "duplicate object key " + key) end if
    end for
    expect(parser, 58, "parseObject")
    value = parseValue(parser)
    pairs = pairs + [JsonPair(key, value)]
    next = peek(parser)
    if next == 44 then
      parser.position = parser.position + 1
    else if next == 125 then
      parser.position = parser.position + 1
      break
    else
      return fail("parseObject", "expected comma or closing brace")
    end if
  end while
  return JsonValue(JSON_OBJECT, void, pairs)
end function

// Parses value using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function parseValue(parser)
  token = peek(parser)
  if token == 34 then return JsonValue(JSON_STRING, parseString(parser), []) end if
  if token == 123 then return parseObject(parser) end if
  if token == 91 then return parseArray(parser) end if
  if token == 45 or isDigit(token) then return JsonValue(JSON_INT, parseInteger(parser), []) end if
  if matchLiteral(parser, "true") then return JsonValue(JSON_BOOL, true, []) end if
  if matchLiteral(parser, "false") then return JsonValue(JSON_BOOL, false, []) end if
  if matchLiteral(parser, "null") then return JsonValue(JSON_NULL, void, []) end if
  return fail("parseValue", "unexpected JSON value at byte " + parser.position)
end function

// Parses parse using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function parse(text)
  if typeof(text) != "string" then return fail("parse", "text must be string") end if
  parser = Parser(bytes(text), 0)
  value = parseValue(parser)
  skipWhitespace(parser)
  if parser.position != len(parser.data) then return fail("parse", "trailing bytes after JSON document") end if
  return value
end function

// Implements member for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function member(object, key)
  if object is not JsonValue or object.kind != JSON_OBJECT then return fail("member", "value must be JSON object") end if
  for each pair in object.items
    if pair.key == key then return pair.value end if
  end for
  return fail("member", "missing configuration key " + key)
end function

// Looks up an optional object member without weakening strict unknown-key validation.
// Inputs: `object`, `key`. Returns the JSON value or void when the key is absent.
function optionalMember(object, key)
  if object is not JsonValue or object.kind != JSON_OBJECT then return fail("optionalMember", "value must be JSON object") end if
  for each pair in object.items
    if pair.key == key then return pair.value end if
  end for
  return void
end function

// Implements object member for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function objectMember(object, key)
  value = member(object, key)
  if value.kind != JSON_OBJECT then return fail("objectMember", key + " must be object") end if
  return value
end function

// Implements string member for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function stringMember(object, key)
  value = member(object, key)
  if value.kind != JSON_STRING then return fail("stringMember", key + " must be string") end if
  return value.scalar
end function

// Implements int member for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function intMember(object, key)
  value = member(object, key)
  if value.kind != JSON_INT then return fail("intMember", key + " must be integer") end if
  return value.scalar
end function

// Implements bool member for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function boolMember(object, key)
  value = member(object, key)
  if value.kind != JSON_BOOL then return fail("boolMember", key + " must be boolean") end if
  return value.scalar
end function

// Reads an optional integer while preserving backwards-compatible defaults.
function optionalIntMember(object, key, defaultValue)
  value = optionalMember(object, key)
  if value is void then return defaultValue end if
  if value.kind != JSON_INT then return fail("optionalIntMember", key + " must be integer") end if
  return value.scalar
end function


// Ensures only keys using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function ensureOnlyKeys(object, allowedKeys, context)
  if object is not JsonValue or object.kind != JSON_OBJECT then return fail("ensureOnlyKeys", context + " must be object") end if
  for each pair in object.items
    allowed = false
    for each key in allowedKeys
      if pair.key == key then allowed = true end if
    end for
    if not allowed then return fail("ensureOnlyKeys", "unknown configuration key " + context + "." + pair.key) end if
  end for
  return true
end function

// Implements to config for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function toConfig(root)
  if root.kind != JSON_OBJECT then return fail("toConfig", "root must be object") end if
  paths = objectMember(root, "paths")
  server = objectMember(root, "server")
  runtime = objectMember(root, "runtime")
  loggingValue = optionalMember(root, "logging")
  binlogValue = optionalMember(root, "binlog")
  tlsValue = optionalMember(root, "tls")
  defaults = objectMember(root, "databaseDefaults")
  safety = objectMember(root, "safety")

  ensureOnlyKeys(root, ["configVersion", "paths", "server", "runtime", "logging", "binlog", "tls", "databaseDefaults", "safety"], "root")
  ensureOnlyKeys(paths, ["dataRoot", "temporaryRoot", "logDirectory"], "paths")
  ensureOnlyKeys(server, ["bindAddress", "port", "maxConnections", "maxStatementBytes", "maxFrameBytes", "maxResultRows", "idleTimeoutMs"], "server")
  ensureOnlyKeys(runtime, ["bufferPoolBytes", "queryTimeoutMs", "checkpointWalBytes", "temporaryMemoryBytes", "logLevel"], "runtime")
  logging = model.LoggingConfig(true, true, "minisql.log", 24)
  if loggingValue is not void then
    if loggingValue.kind != JSON_OBJECT then return fail("toConfig", "logging must be object") end if
    ensureOnlyKeys(loggingValue, ["stdoutEnabled", "fileEnabled", "fileName", "rotationHours"], "logging")
    logging = model.LoggingConfig(boolMember(loggingValue, "stdoutEnabled"), boolMember(loggingValue, "fileEnabled"), stringMember(loggingValue, "fileName"), intMember(loggingValue, "rotationHours"))
  end if
  binlog = model.BinlogConfig(false, "minisql-bin.log")
  if binlogValue is not void then
    if binlogValue.kind != JSON_OBJECT then return fail("toConfig", "binlog must be object") end if
    ensureOnlyKeys(binlogValue, ["enabled", "fileName"], "binlog")
    binlog = model.BinlogConfig(boolMember(binlogValue, "enabled"), stringMember(binlogValue, "fileName"))
  end if
  tls = model.TlsConfig(false, "store:", "MINISQL_TLS_PFX_PASSWORD", "TLS_AES_256_GCM_SHA384", "X25519", "TLS1.3")
  if tlsValue is not void then
    if tlsValue.kind != JSON_OBJECT then return fail("toConfig", "tls must be object") end if
    ensureOnlyKeys(tlsValue, ["enabled", "certificateReference", "pfxPasswordEnvironment", "cipherSuite", "namedGroup", "protocolVersion"], "tls")
    tls = model.TlsConfig(boolMember(tlsValue, "enabled"), stringMember(tlsValue, "certificateReference"), stringMember(tlsValue, "pfxPasswordEnvironment"), stringMember(tlsValue, "cipherSuite"), stringMember(tlsValue, "namedGroup"), stringMember(tlsValue, "protocolVersion"))
  end if
  ensureOnlyKeys(defaults, ["pageSize", "checksumAlgorithm", "walSegmentBytes", "textEncoding", "defaultCollation", "databaseFormatVersion", "tableFileFormatVersion", "indexFileFormatVersion", "walFormatVersion", "rowFormatVersion"], "databaseDefaults")
  ensureOnlyKeys(safety, ["allowRemoteWithoutAuthentication", "durability", "allowUnknownFormatFeatures"], "safety")

  result = model.MiniSqlConfig(
    intMember(root, "configVersion"),
    model.PathsConfig(stringMember(paths, "dataRoot"), stringMember(paths, "temporaryRoot"), stringMember(paths, "logDirectory")),
    model.ServerConfig(
      stringMember(server, "bindAddress"),
      intMember(server, "port"),
      intMember(server, "maxConnections"),
      intMember(server, "maxStatementBytes"),
      intMember(server, "maxFrameBytes"),
      optionalIntMember(server, "maxResultRows", 1000000),
      optionalIntMember(server, "idleTimeoutMs", 300000)
    ),
    model.RuntimeConfig(
      intMember(runtime, "bufferPoolBytes"),
      intMember(runtime, "queryTimeoutMs"),
      intMember(runtime, "checkpointWalBytes"),
      intMember(runtime, "temporaryMemoryBytes"),
      stringMember(runtime, "logLevel")
    ),
    logging,
    binlog,
    tls,
    model.DatabaseDefaults(
      intMember(defaults, "pageSize"),
      stringMember(defaults, "checksumAlgorithm"),
      intMember(defaults, "walSegmentBytes"),
      stringMember(defaults, "textEncoding"),
      stringMember(defaults, "defaultCollation"),
      intMember(defaults, "databaseFormatVersion"),
      intMember(defaults, "tableFileFormatVersion"),
      intMember(defaults, "indexFileFormatVersion"),
      intMember(defaults, "walFormatVersion"),
      intMember(defaults, "rowFormatVersion")
    ),
    model.SafetyConfig(
      boolMember(safety, "allowRemoteWithoutAuthentication"),
      stringMember(safety, "durability"),
      boolMember(safety, "allowUnknownFormatFeatures")
    )
  )
  validation.validate(result)
  return result
end function

// Loads load using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function load(path)
  if typeof(path) != "string" or len(path) == 0 then return fail("load", "path must be non-empty") end if
  handle = file_api.openRead(path)
  length = file_api.size(handle)
  if length > MAX_CONFIG_BYTES then file_api.close(handle); return fail("load", "configuration exceeds 1 MiB safety limit") end if
  data = bytes(length, 0)
  if length > 0 then file_api.readExactAt(handle, 0, data, 0, length) end if
  file_api.close(handle)
  text = ""
  if length > 0 then
    text = decode(data)
    if typeof(text) != "string" then return fail("load", "configuration is not valid UTF-8") end if
  end if
  return toConfig(parse(text))
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "config.loader"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M8"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
