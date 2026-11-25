package minisql.executor.routine_state

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.sql.ast as ast
import minisql.sql.types as types
import minisql.sql.values as values
import std.string as string_api

/// One typed lexical variable, or an untyped session variable when typeInfo is void.
struct Variable
  /// Case-folded identifier, including @ for session variables.
  name
  /// Declared SQL type, or void for a session variable.
  typeInfo
  /// Current SqlValue, including a typed SQL NULL.
  value
end struct

/// A forward-only cursor owns its materialized snapshot until close or scope exit.
struct Cursor
  /// Lexical cursor name.
  name
  /// Unsubstituted SELECT syntax tree evaluated by OPEN.
  query
  /// Snapshot rows captured by OPEN.
  rows
  /// Snapshot column metadata.
  columns
  /// Index of the next row to fetch.
  index
  /// Whether OPEN has succeeded without a corresponding CLOSE.
  opened
  /// Declaration-time scope references; values remain live, shadowing cannot rebind them.
  lexicalScopes
end struct

/// A handler is registered in one lexical scope and never catches its own errors.
struct Handler
  /// CONTINUE or EXIT.
  action
  /// Resolved [SQLSTATE|ERRNO|CLASS, value] pairs.
  conditions
  /// One statement or compound block.
  body
end struct

/// One lexical scope; resources become unreachable on every exit path.
struct Scope
  /// Monotonic session identity used by EXIT handler unwinding.
  id
  /// Optional block label, or an empty string.
  label
  /// Ordered Variable records; duplicate names are rejected.
  variables
  /// Named condition definitions [name, kind, value].
  conditions
  /// Declared Cursor records.
  cursors
  /// Declared Handler records.
  handlers
  /// Suppresses this scope's handlers while one of them is active.
  handling
  /// OLD/NEW fields resolve only through their qualifier, never as bare locals.
  qualifiedOnly
end struct

/// Each invocation owns independent scopes and output collection.
struct Frame
  /// Canonical routine name for recursive call accounting.
  name
  /// Active lexical scopes, outermost first.
  scopes
  /// Ordered QueryResult values emitted by SELECT or nested CALL.
  results
  /// Last statement's affected row count, normalized for CALL completion.
  affectedRows
  /// Default schema inherited from the procedure's qualified name.
  schema
  /// CTE declarations visible while rewriting one query and its nested subqueries.
  visibleCtes
end struct

/// SQL diagnostics remain available after handlers and top-level statements.
struct Diagnostic
  /// Five-character SQLSTATE.
  sqlstate
  /// MySQL-compatible routine error number.
  errno
  /// Human-readable condition text.
  message
  /// Optional condition information [name, SqlValue] pairs.
  items
  /// Affected row count for statement diagnostics.
  rowCount
  /// Number of conditions in this diagnostics area.
  number
  /// Distinguishes explicit NOT FOUND signals from normal exhaustion.
  signaled
  /// Original structured MiniSQL error, retained when one caused this condition.
  nativeError
  /// Earlier conditions in the same area, in GET DIAGNOSTICS ordinal order.
  preceding
  /// Statement instruction identity used to distinguish newly raised identical conditions.
  serial
end struct

/// Session state is never shared between authenticated engines.
struct Session
  /// User variables persist until the engine closes.
  variables
  /// Active calls, with caller frames hidden from callee lexical lookup.
  frames
  /// Current diagnostics area.
  diagnostic
  /// Diagnostics saved by active handlers, oldest first.
  stacked
  /// Marks an explicitly raised condition awaiting interception.
  pending
  /// MySQL-style recursion limit; zero disables recursive procedure calls.
  maxRecursionDepth
  /// Allocator for lexical scope identities.
  nextScopeId
  /// Cooperative instruction count used for deadline polling.
  steps
  /// The last failed public statement deliberately raised its numeric error code.
  outgoingSignal
  /// Results completed before an unhandled error, retained for ordered network delivery.
  failedResults
  /// Bounded conditions from the last public statement, in encounter order.
  warnings
  /// Total conditions, including those beyond maxErrorCount.
  warningCount
  /// Total error-class conditions in the last public statement.
  errorCount
  /// Maximum retained condition records; totals remain exact when zero.
  maxErrorCount
  /// SQL mode captured by CREATE and temporarily restored for each invocation.
  sqlMode
  /// Connection character set recorded in stored routine metadata.
  characterSetClient
  /// Supported binary comparison collation recorded at creation.
  collationConnection
  /// Database default used for unqualified routine character declarations.
  databaseCollation
  /// Controls automatic EXECUTE/ALTER ROUTINE grants to a routine creator.
  automaticSpPrivileges
  /// Bounded cache of parsed routine definitions; entries own no invocation state.
  definitionCache
  /// Counts actual stored-definition parses for cache observability and tests.
  definitionParses
  /// Synchronous result consumer installed only for the current public statement.
  sink
  /// Opaque caller-owned context passed to the streaming consumer.
  sinkContext
  /// A failed transport consumer cannot be caught by a SQL condition handler.
  streamFailure
  /// Successful outer CALL output snapshots [ordinal, name, SqlValue].
  outputParameters
  /// True while a statically verified read-only CALL owns the shared gate.
  readOnlyExecution
  /// Active triggering table identities, used to reject self-modification.
  triggerTables
  /// A CALL has begun evaluation, so automatic whole-statement retries are unsafe.
  callStarted
  /// Prevents executor and wire decoration from counting the same terminal error twice.
  publicErrorRecorded
end struct

/// A cache entry is keyed by durable identity, full definition and metadata bytes.
struct CachedDefinition
  /// Stable procedure object identity, never reused after DROP.
  id
  /// Exact canonical SQL text, including the entire body.
  sql
  /// Exact persisted metadata representation, including captured context.
  metadata
  /// Parsed immutable CreateProcedureStatement.
  definition
end struct

/// Explicit control flow keeps cleanup independent of MiniLang error propagation.
struct Flow
  /// NORMAL, LEAVE, ITERATE, EXIT, or ERROR.
  kind
  /// Label, scope identity, or Diagnostic, depending on kind.
  target
end struct

/// Creates an empty diagnostics area after a successful statement.
function clearDiagnostic(rowCount)
  return Diagnostic("00000", 0, "", [], rowCount, 0, false, void, [], 0)
end function

/// Allocates isolated state for one engine connection.
function create()
  return Session([], [], clearDiagnostic(0), [], false, 0, 1, 0, false, [], [], 0, 0, 64, "STRICT_TRANS_TABLES", "utf8mb4", "utf8mb4_bin", "utf8mb4_bin", true, [], 0, void, void, false, [], false, [], false, false)
end function

/// Returns the currently executing procedure, or void outside a CALL.
function currentFrame(session)
  if len(session.frames) == 0 then return void end if
  return session.frames[len(session.frames) - 1]
end function

/// Returns a fresh lexical scope with a stable EXIT destination.
function scope(session, label)
  result = Scope(session.nextScopeId, label, [], [], [], [], false, false)
  session.nextScopeId = session.nextScopeId + 1
  return result
end function

/// Copies the first count array elements without sharing a mutable array container.
function prefix(items, count)
  output = []
  if count > 0 then
    for index = 0 to count - 1
      output = output + [items[index]]
    end for
  end if
  return output
end function

/// Looks up a local variable using lexical shadowing and optional block qualification.
function findLocal(frame, name, qualifier)
  if frame is void then return void end if
  index = len(frame.scopes) - 1
  while index >= 0
    currentScope = frame.scopes[index]
    if (qualifier is void and not currentScope.qualifiedOnly) or qualifier == currentScope.label then
      for each variable in currentScope.variables
        if variable.name == name then return variable end if
      end for
    end if
    index = index - 1
  end while
  return void
end function

/// Looks up a session variable without creating it.
function findSessionVariable(session, name)
  for each variable in session.variables
    if variable.name == name then return variable end if
  end for
  return void
end function

/// Identifies user and system variable spellings produced by the SQL lexer.
function isSessionName(name)
  return typeof(name) == "string" and len(bytes(name)) > 0 and bytes(name)[0] == 64
end function

/// Resolves the supported system recursion setting in all accepted spellings.
function isRecursionName(name)
  return name == "max_sp_recursion_depth" or name == "@@max_sp_recursion_depth" or name == "@@session.max_sp_recursion_depth"
end function

/// Normalizes supported unqualified and @@session/global system-variable names.
function systemName(name)
  if typeof(name) != "string" then return "" end if
  value = name
  if string_api.startsWith(value, "@@session.") then value = decode(slice(bytes(value), 10, len(bytes(value)) - 10))
  else if string_api.startsWith(value, "@@global.") then value = decode(slice(bytes(value), 9, len(bytes(value)) - 9))
  else if string_api.startsWith(value, "@@") then value = decode(slice(bytes(value), 2, len(bytes(value)) - 2))
  end if
  if value == "max_sp_recursion_depth" or value == "warning_count" or value == "error_count" or value == "max_error_count" or value == "sql_mode" or value == "character_set_client" or value == "collation_connection" or value == "database_collation" or value == "automatic_sp_privileges" then return value end if
  return ""
end function

/// Retains conditions without allowing an unbounded warning-producing loop.
function rememberCondition(session, diagnostic)
  session.warningCount = session.warningCount + 1
  className = decode(slice(bytes(diagnostic.sqlstate), 0, 2))
  if className != "00" and className != "01" and className != "02" then session.errorCount = session.errorCount + 1 end if
  if len(session.warnings) < session.maxErrorCount then session.warnings = session.warnings + [diagnostic] end if
  return true
end function

/// Counts Unicode scalar encodings, not UTF-8 bytes, for SQL character limits.
function characterLength(textValue)
  count = 0
  for each code in bytes(textValue)
    if code < 128 or code >= 192 then count = count + 1 end if
  end for
  return count
end function

/// Takes a valid UTF-8 prefix without cutting through a multibyte character.
function characterPrefix(textValue, count)
  raw = bytes(textValue)
  characters = 0
  position = 0
  while position < len(raw)
    if raw[position] < 128 or raw[position] >= 192 then
      if characters >= count then break end if
      characters = characters + 1
    end if
    position = position + 1
  end while
  return decode(slice(raw, 0, position))
end function

/// Finds a cursor in its closest enclosing scope.
function findCursor(frame, name)
  if frame is void then return void end if
  index = len(frame.scopes) - 1
  while index >= 0
    for each cursor in frame.scopes[index].cursors
      if cursor.name == name then return cursor end if
    end for
    index = index - 1
  end while
  return void
end function

/// Resolves a named condition without leaking caller scopes.
function findCondition(frame, name)
  if frame is void then return void end if
  index = len(frame.scopes) - 1
  while index >= 0
    for each condition in frame.scopes[index].conditions
      if condition[0] == name then return [condition[1], condition[2]] end if
    end for
    index = index - 1
  end while
  return void
end function

/// Gives errno handlers priority over SQLSTATE and class within one scope.
function matchPriority(condition, diagnostic)
  kind = condition[0]
  expected = condition[1]
  if kind == "ERRNO" and toNumber(expected) == diagnostic.errno then return 3 end if
  if kind == "SQLSTATE" and expected == diagnostic.sqlstate then return 2 end if
  if kind != "CLASS" then return 0 end if
  className = decode(slice(bytes(diagnostic.sqlstate), 0, 2))
  if expected == "SQLWARNING" and className == "01" then return 1 end if
  if expected == "NOT FOUND" and className == "02" then return 1 end if
  if expected == "SQLEXCEPTION" and className != "00" and className != "01" and className != "02" then return 1 end if
  return 0
end function

/// Returns a routine characteristic, applying the caller's explicit default.
function characteristic(characteristics, key, fallback)
  for each item in characteristics
    if item[0] == key then return item[1] end if
  end for
  return fallback
end function

/// Replaces one characteristic while preserving the remaining declaration order.
function putCharacteristic(characteristics, key, value)
  output = []
  found = false
  for each item in characteristics
    if item[0] == key then
      output = output + [[key, value]]
      found = true
    else
      output = output + [item]
    end if
  end for
  if not found then output = output + [[key, value]] end if
  return output
end function

/// Converts a native engine error to a routine condition without guessing success.
function fromError(nativeError)
  code = nativeError.code
  sqlstate = "HY000"
  mysqlCode = code
  if code == 1115 or code == 1253 then sqlstate = "42000" end if
  if code == 9019 then sqlstate = "42000"; mysqlCode = 1064 end if
  if code == 9020 then
    sqlstate = "42S22"; mysqlCode = 1054
    if string_api.contains(nativeError.message, "unknown table") then sqlstate = "42S02"; mysqlCode = 1146 end if
    if string_api.contains(nativeError.message, "ambiguous") then sqlstate = "23000"; mysqlCode = 1052 end if
  end if
  if code == 9017 then
    sqlstate = "22003"; mysqlCode = 1264
    if string_api.contains(nativeError.message, "length") then sqlstate = "22001"; mysqlCode = 1406 end if
    if string_api.contains(nativeError.message, "requires") or string_api.contains(nativeError.message, "invalid") then sqlstate = "22007"; mysqlCode = 1366 end if
    if string_api.contains(nativeError.message, "division") or string_api.contains(nativeError.message, "zero") then sqlstate = "22012"; mysqlCode = 1365 end if
  end if
  if code == 9022 then sqlstate = "23000"; mysqlCode = 1062 end if
  if code == 9014 then
    sqlstate = "42S02"; mysqlCode = 1146
    if string_api.contains(nativeError.message, "unknown column") or string_api.contains(nativeError.message, "unknown qualified column") or string_api.contains(nativeError.message, "column not found") then sqlstate = "42S22"; mysqlCode = 1054 end if
    if string_api.contains(nativeError.message, "index not found") then sqlstate = "42000"; mysqlCode = 1091 end if
  end if
  if code == 9021 then
    sqlstate = "23000"
    mysqlCode = 1062
    if string_api.contains(nativeError.message, "NULL") or string_api.contains(nativeError.message, "null") then mysqlCode = 1048 end if
    if string_api.contains(nativeError.message, "foreign") or string_api.contains(nativeError.message, "FOREIGN") then mysqlCode = 1452 end if
    if string_api.contains(nativeError.message, "CHECK") then sqlstate = "HY000"; mysqlCode = 3819 end if
  end if
  if code == 9029 then sqlstate = "42000"; mysqlCode = 1142 end if
  if code == 9007 or code == 9032 then sqlstate = "HY000"; mysqlCode = 1205 end if
  if code == 9031 and string_api.contains(nativeError.message, "transaction.lock_manager.") then sqlstate = "40001"; mysqlCode = 1213 end if
  if code == 9011 then sqlstate = "25000" end if
  if code == 9012 then sqlstate = "25006"; mysqlCode = 1792 end if
  if code == 9013 then sqlstate = "42S01"; mysqlCode = 1050 end if
  if code == 9025 then sqlstate = "0A000"; mysqlCode = 1235 end if
  if code == 9027 or code == 9028 then sqlstate = "28000"; mysqlCode = 1045 end if
  if code == 9026 or code == 9034 then sqlstate = "08S01" end if
  if code == 9037 then sqlstate = "HY001" end if
  if code == 9035 then sqlstate = "70100"; mysqlCode = 1317 end if
  if code == 9036 then sqlstate = "HY000"; mysqlCode = 3024 end if
  return Diagnostic(sqlstate, mysqlCode, nativeError.message, [], -1, 1, false, nativeError, [], 0)
end function

/// Raises one explicit SQL condition; the interpreter consumes pending exactly once.
function raise(session, sqlstate, errno, message, signaled)
  rowCount = -1
  className = decode(slice(bytes(sqlstate), 0, 2))
  if className == "01" or className == "02" then rowCount = 0 end if
  session.diagnostic = Diagnostic(sqlstate, errno, message, [], rowCount, 1, signaled, void, [], session.steps)
  session.pending = true
  return error(errno, "SQLSTATE " + sqlstate + ": " + message)
end function

/// Exposes standard condition information without returning MiniLang void as SQL NULL.
function diagnosticValue(diagnostic, name)
  if name == "RETURNED_SQLSTATE" then return values.text(diagnostic.sqlstate) end if
  if name == "MYSQL_ERRNO" then return values.integer(diagnostic.errno) end if
  if name == "MESSAGE_TEXT" then return values.text(diagnostic.message) end if
  if name == "NUMBER" then return values.integer(diagnostic.number) end if
  if name == "ROW_COUNT" then return values.integer(diagnostic.rowCount) end if
  for each item in diagnostic.items
    if item[0] == name then return item[1] end if
  end for
  if name == "CLASS_ORIGIN" or name == "SUBCLASS_ORIGIN" then
    code = bytes(diagnostic.sqlstate)[0]
    if code >= 48 and code <= 52 then return values.text("ISO 9075") end if
    if code >= 65 and code <= 72 then return values.text("ISO 9075") end if
    return values.text("MySQL")
  end if
  return values.text("")
end function

/// Checks lexical declarations and jump destinations before any definition is persisted.
function validateNode(statement, frame, labels)
  if not ast.isRoutineStatement(statement) then
    if ast.isCreateProcedureStatement(statement) then return error(1303, "Cannot create a procedure from a stored procedure") end if
    return true
  end if
  kind = statement.kind
  if kind == "BLOCK" then
    if statement.name != "" then
      if len(bytes(statement.name)) > 16 then return error(1059, "Label is longer than 16 characters") end if
      for each label in labels
        if label[0] == statement.name then return error(1309, "Redefining label " + statement.name) end if
      end for
      labels = labels + [[statement.name, "BLOCK"]]
    end if
    frame.scopes = frame.scopes + [Scope(0, statement.name, [], [], [], [], false, false)]
    for each child in statement.body
      validateNode(child, frame, labels)
    end for
    frame.scopes = prefix(frame.scopes, len(frame.scopes) - 1)
    return true
  end if
  if kind == "WHILE" or kind == "REPEAT" or kind == "LOOP" then
    if statement.name != "" then
      if len(bytes(statement.name)) > 16 then return error(1059, "Label is longer than 16 characters") end if
      for each label in labels
        if label[0] == statement.name then return error(1309, "Redefining label " + statement.name) end if
      end for
      labels = labels + [[statement.name, "LOOP"]]
    end if
    for each child in statement.body
      validateNode(child, frame, labels)
    end for
    return true
  end if
  if kind == "LEAVE" or kind == "ITERATE" then
    for each label in labels
      if label[0] == statement.name and (kind == "LEAVE" or label[1] == "LOOP") then return true end if
    end for
    return error(1308, kind + " with no matching label " + statement.name)
  end if
  if kind == "IF" or kind == "CASE" then
    for each child in statement.body
      validateNode(child, frame, labels)
    end for
    for each child in statement.alternate
      validateNode(child, frame, labels)
    end for
    return true
  end if
  owner = frame.scopes[len(frame.scopes) - 1]
  if kind == "DECLARE" then
    typeInfo = types.fromTypeName(statement.options[0], true)
    for each name in statement.names
      for each existing in owner.variables
        if existing.name == name then return error(1331, "Duplicate variable " + name) end if
      end for
      owner.variables = owner.variables + [Variable(name, typeInfo, values.nullValue(typeInfo.kind))]
    end for
  else if kind == "CONDITION" then
    for each existing in owner.conditions
      if existing[0] == statement.name then return error(1332, "Duplicate condition " + statement.name) end if
    end for
    owner.conditions = owner.conditions + [[statement.name, statement.options[0], statement.options[1]]]
  else if kind == "CURSOR" then
    for each existing in owner.cursors
      if existing.name == statement.name then return error(1333, "Duplicate cursor " + statement.name) end if
    end for
    owner.cursors = owner.cursors + [Cursor(statement.name, statement.body[0], [], [], 0, false, [])]
  else if kind == "HANDLER" then
    resolved = []
    for each condition in statement.options
      value = condition
      if condition[0] == "NAME" then
        value = findCondition(frame, condition[1])
        if value is void then return error(1319, "Undefined condition " + condition[1]) end if
      end if
      for each old in owner.handlers
        for each oldCondition in old.conditions
          if oldCondition[0] == value[0] and oldCondition[1] == value[1] then return error(1413, "Duplicate handler") end if
        end for
      end for
      for each oldCondition in resolved
        if oldCondition[0] == value[0] and oldCondition[1] == value[1] then return error(1413, "Duplicate handler condition") end if
      end for
      resolved = resolved + [value]
    end for
    owner.handlers = owner.handlers + [Handler(statement.name, resolved, statement.body[0])]
    validateNode(statement.body[0], frame, [])
  else if kind == "OPEN" or kind == "FETCH" or kind == "CLOSE" then
    if findCursor(frame, statement.name) is void then return error(1324, "Undefined cursor " + statement.name) end if
  else if kind == "SIGNAL" or kind == "RESIGNAL" then
    if len(statement.options) > 0 and statement.options[0] == "NAME" then
      condition = findCondition(frame, statement.options[1])
      if condition is void then return error(1319, "Undefined condition " + statement.options[1]) end if
      if condition[0] != "SQLSTATE" then return error(1646, "SIGNAL requires a SQLSTATE condition") end if
    end if
  end if
  if kind == "SET" or kind == "FETCH" or kind == "SELECT_INTO" or kind == "GET_DIAGNOSTICS" then
    for each name in statement.names
      if not isSessionName(name) and systemName(name) == "" and findQualifiedLocal(frame, name) is void then return error(1327, "Undeclared variable " + name) end if
    end for
  end if
  return true
end function

/// Validates parameter types and the complete lexical structure without executing defaults or SQL.
function validateDefinition(definition)
  parameterScope = Scope(0, definition.name, [], [], [], [], false, false)
  for each parameter in definition.parameters
    for each existing in parameterScope.variables
      if existing.name == parameter.name then return error(1330, "Duplicate parameter " + parameter.name) end if
    end for
    typeInfo = types.fromTypeName(parameter.typeName, true)
    parameterScope.variables = parameterScope.variables + [Variable(parameter.name, typeInfo, values.nullValue(typeInfo.kind))]
  end for
  frame = Frame(definition.name, [parameterScope], [], 0, "public", [])
  return validateNode(definition.body, frame, [])
end function

/// Resolves assignment targets with the same label qualification as expression references.
function findQualifiedLocal(frame, name)
  parts = string_api.split(name, ".")
  if len(parts) == 2 then return findLocal(frame, parts[1], parts[0]) end if
  return findLocal(frame, name, void)
end function

/// Returns the stable identity used by the repository's module inventory.
function componentName()
  return "executor.routine_state"
end function

/// Associates procedure execution state with the stored-program milestone.
function targetMilestone()
  return "M45"
end function

/// Indicates that this module contains an implemented runtime contract.
function isImplemented()
  return true
end function

/// Restores a stacked area and appends genuinely new handler conditions in ordinal order.
function mergeDiagnostics(original, current)
  if current.number == 0 or current.serial == original.serial then return original end if
  if original.number == 0 then return current end if
  preceding = original.preceding + [original] + current.preceding
  return Diagnostic(current.sqlstate, current.errno, current.message, current.items, original.rowCount, len(preceding) + 1, current.signaled, current.nativeError, preceding, current.serial)
end function
