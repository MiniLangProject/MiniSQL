package minisql.executor.executor

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.catalog.schema_history as schema_history
import minisql.catalog.statistics as statistics
import minisql.common.diagnostics as diagnostics
import minisql.executor.aggregate as aggregate
import minisql.executor.dml as dml
import minisql.executor.filter as filter
import minisql.executor.join as join
import minisql.executor.projection as projection
import minisql.executor.scan as scan
import minisql.executor.sort as sort
import minisql.planner.logical_plan as logical_plan
import minisql.planner.optimizer as optimizer
import minisql.planner.physical_plan as physical_plan
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.sql.ast as ast
import minisql.sql.binder as binder
import minisql.sql.expressions as expressions
import minisql.sql.parser as parser
import minisql.sql.types as types
import minisql.sql.values as values
import minisql.storage.paged_file as paged_file
import minisql.transaction.transaction as transaction

// SQL execution facade. M16 extends the accepted M15 scan/filter/projection
// pipeline with joins, grouping, aggregates, set operations and explicit logical
// and physical plan descriptions. Later milestones add statistics, protocol
// sessions and savepoints without changing this public execution contract.

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004
const CLOSED_HANDLE = 9008
const TRANSACTION_STATE = 9011
const BINDING_ERROR = 9020
const CONSTRAINT_VIOLATION = 9021
const SORT_SPILL_THRESHOLD = 128
const DDL_STATE = 9023
const UNSUPPORTED_SQL = 9025
const AUTHENTICATION_REQUIRED = 9028
const PERMISSION_DENIED = 9029

const MODE_NONE = 0
const MODE_DML = 1
const MODE_DDL = 2

const RESULT_COMMAND = 1
const RESULT_ROWS = 2

// Identifies the flattened, versioned parameter metadata stored with procedures.
const PROCEDURE_PARAMETER_METADATA_V1 = "__minisql_parameter_metadata_v1__"

// Groups the query result state and preserves the field relationships documented below.
struct QueryResult
  // Stores the kind associated with this value.
  kind
  // Stores the command associated with this value.
  command
  // Contains the ordered columns collection.
  columns
  // Contains the ordered rows collection.
  rows
  // Stores the affected rows associated with this value.
  affectedRows
  // Stores the message associated with this value.
  message
end struct

// Groups the prepared statement state state and preserves the field relationships documented below.
struct PreparedStatementState
  // Stores the name associated with this value.
  name
  // Stores the statement associated with this value.
  statement
  // Tracks the parameter count numeric value.
  parameterCount
  // Stores the schema generation associated with this value.
  schemaGeneration
end struct

// Groups the sequence session value state and preserves the field relationships documented below.
struct SequenceSessionValue
  // Stores the name associated with this value.
  name
  // Stores the value associated with this value.
  value
end struct

// Stores one active recursive CTE working table on the session-local evaluation stack.
struct RecursiveCteFrame
  // Stores the CTE name used by bound self-reference sources.
  name
  // Contains the current iteration's delta rows.
  rows
end struct

// Groups the engine state and preserves the field relationships documented below.
struct Engine
  // Stores the database associated with this value.
  database
  // Stores the owns database associated with this value.
  ownsDatabase
  // Stores the explicit transaction associated with this value.
  explicitTransaction
  // Stores the transaction mode associated with this value.
  transactionMode
  // Stores the page transaction associated with this value.
  pageTransaction
  // Stores the DDL transaction associated with this value.
  ddlTransaction
  // Stores the failed associated with this value.
  failed
  // Indicates whether the closed condition is active.
  closed
  // Stores the trusted associated with this value.
  trusted
  // Identifies the principal identifier.
  principalId
  // Stores the prepared statements associated with this value.
  preparedStatements
  // Identifies the session identifier.
  sessionId
  // Stores the sequence values associated with this value.
  sequenceValues
  // Tracks the trigger depth numeric value.
  triggerDepth
  // Contains nested recursive-CTE working tables for this isolated session.
  recursiveCteFrames
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "executor.executor." + operation + ": " + message)
end function

// Returns whether the supplied value satisfies the query result condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isQueryResult(value)
  return value is QueryResult
end function

// Returns whether the supplied value satisfies the engine condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isEngine(value)
  return value is Engine
end function

// Implements command result for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function commandResult(command, affectedRows, message)
  return QueryResult(RESULT_COMMAND, command, [], [], affectedRows, message)
end function

// Implements row result for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function rowResult(columns, rows)
  return QueryResult(RESULT_ROWS, "SELECT", columns, rows, len(rows), "")
end function

// Performs the index readiness pass once for an opened database. Clean marker
// state needs only derived-file existence checks; a dirty marker or missing
// file performs the expensive rebuild/verification path. A double check inside
// the exclusive gate lets concurrent connection accepts share either result.
function prepareDatabase(database)
  if not database_manager.isManagedDatabase(database) then return fail(INVALID_ARGUMENT, "prepareDatabase", "database must be ManagedDatabase") end if
  if database_manager.indexesReady(database) then return true end if
  entered = try(database_manager.enterExecution(database))
  result = true
  if not database_manager.indexesReady(database) then
    result = try(dml.ensureIndexes(database))
    if typeof(result) != "error" then result = try(database_manager.markIndexesReady(database)) end if
  end if
  released = try(database_manager.leaveExecution(database))
  if typeof(released) == "error" then return released end if
  return result
end function

// Implements attach for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function attach(database)
  if not database_manager.isManagedDatabase(database) then return fail(INVALID_ARGUMENT, "attach", "database must be ManagedDatabase") end if
  prepared = try(prepareDatabase(database))
  if typeof(prepared) == "error" then return prepared end if
  return Engine(database, false, false, MODE_NONE, void, void, false, false, true, metadata.PRINCIPAL_ADMIN_ID, [], database_manager.allocateSessionId(database), [], 0, [])
end function

// Opens open using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function open(databasePath)
  database = database_manager.open(databasePath)
  prepared = try(prepareDatabase(database))
  if typeof(prepared) == "error" then database_manager.close(database); return prepared end if
  return Engine(database, true, false, MODE_NONE, void, void, false, false, true, metadata.PRINCIPAL_ADMIN_ID, [], database_manager.allocateSessionId(database), [], 0, [])
end function

// Implements set principal for this module.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function setPrincipal(engine, principalId)
  validateOpen(engine, "setPrincipal")
  principal = catalog.findPrincipalByIdInState(engine.database.catalogHandle.security, principalId)
  if principal is void or not principal.enabled or not principal.canLogin or principal.principalKind != metadata.PRINCIPAL_USER then return fail(AUTHENTICATION_REQUIRED, "setPrincipal", "principal is unavailable") end if
  engine.trusted = false
  engine.principalId = principalId
  return true
end function

// Implements principal for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function principal(engine)
  validateOpen(engine, "principal")
  return catalog.findPrincipalByIdInState(engine.database.catalogHandle.security, engine.principalId)
end function

// Validates open using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function validateOpen(engine, operation)
  if engine is not Engine then return fail(INVALID_ARGUMENT, operation, "engine must be Engine") end if
  if engine.closed then return fail(CLOSED_HANDLE, operation, "engine is closed") end if
  return true
end function

// Returns whether the supplied value satisfies the prepared statement state condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isPreparedStatementState(value)
  return value is PreparedStatementState
end function

// Returns whether the supplied value satisfies the sequence session value condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isSequenceSessionValue(value)
  return value is SequenceSessionValue
end function

// Implements sequence argument name for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function sequenceArgumentName(expression, operation)
  if ast.isLiteralExpression(expression) and expression.literalKind == ast.LITERAL_STRING then return expression.value end if
  if ast.isTypedLiteralExpression(expression) and values.isSqlValue(expression.value) and not expression.value.isNull and typeof(expression.value.value) == "string" then return expression.value.value end if
  return fail(BINDING_ERROR, operation, "sequence name must be a string literal")
end function

// Implements remember sequence value for this module.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function rememberSequenceValue(engine, name, value)
  if len(engine.sequenceValues) > 0 then
    for index = 0 to len(engine.sequenceValues) - 1
      if engine.sequenceValues[index].name == name then engine.sequenceValues[index].value = value; return true end if
    end for
  end if
  engine.sequenceValues = engine.sequenceValues + [SequenceSessionValue(name, value)]
  return true
end function

// Implements current sequence value for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function currentSequenceValue(engine, name)
  for each current in engine.sequenceValues
    if current.name == name then return current.value end if
  end for
  return fail(BINDING_ERROR, "currval", "CURRVAL is not defined in this session for sequence " + name)
end function

// Implements current schema generation for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function currentSchemaGeneration(engine)
  state = schema_history.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
  return state.generation
end function

// Finds prepared index using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function findPreparedIndex(engine, name)
  if typeof(name) != "string" then return fail(INVALID_ARGUMENT, "findPreparedIndex", "name must be string") end if
  if len(engine.preparedStatements) > 0 then
    for index = 0 to len(engine.preparedStatements) - 1
      if engine.preparedStatements[index].name == name then return index end if
    end for
  end if
  return -1
end function

// Implements constant parameter expression for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function constantParameterExpression(expression)
  if ast.isLiteralExpression(expression) then return true end if
  if ast.isUnaryExpression(expression) then return constantParameterExpression(expression.operand) end if
  if ast.isBinaryExpression(expression) then return constantParameterExpression(expression.left) and constantParameterExpression(expression.right) end if
  if ast.isIsNullExpression(expression) then return constantParameterExpression(expression.operand) end if
  if ast.isCastExpression(expression) then return constantParameterExpression(expression.operand) end if
  if ast.isCaseExpression(expression) then
    for each branch in expression.branches
      if not constantParameterExpression(branch.condition) or not constantParameterExpression(branch.result) then return false end if
    end for
    return expression.elseExpression is void or constantParameterExpression(expression.elseExpression)
  end if
  if ast.isFunctionExpression(expression) then
    if expression.name != "COALESCE" and expression.name != "NULLIF" then return false end if
    for each argument in expression.arguments
      if not constantParameterExpression(argument) then return false end if
    end for
    return true
  end if
  if ast.isInExpression(expression) then
    if not constantParameterExpression(expression.operand) then return false end if
    for each candidate in expression.values
      if not constantParameterExpression(candidate) then return false end if
    end for
    return true
  end if
  if ast.isBetweenExpression(expression) then return constantParameterExpression(expression.operand) and constantParameterExpression(expression.lower) and constantParameterExpression(expression.upper) end if
  if ast.isTruthTestExpression(expression) then return constantParameterExpression(expression.operand) end if
  return false
end function

// Implements substitute expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function substituteExpression(expression, parameters)
  if ast.isParameterExpression(expression) then
    if expression.index < 0 or expression.index >= len(parameters) then return fail(BINDING_ERROR, "substituteExpression", "parameter index is outside EXECUTE arguments") end if
    return parameters[expression.index]
  end if
  if ast.isLiteralExpression(expression) or ast.isTypedLiteralExpression(expression) or ast.isColumnExpression(expression) or ast.isStarExpression(expression) then return expression end if
  if ast.isUnaryExpression(expression) then return ast.unaryExpression(expression.operator, substituteExpression(expression.operand, parameters)) end if
  if ast.isBinaryExpression(expression) then return ast.binaryExpression(expression.operator, substituteExpression(expression.left, parameters), substituteExpression(expression.right, parameters)) end if
  if ast.isIsNullExpression(expression) then return ast.isNullExpression(substituteExpression(expression.operand, parameters), expression.negated) end if
  if ast.isCaseExpression(expression) then
    branches = []
    for each branch in expression.branches
      branches = branches + [ast.caseBranch(substituteExpression(branch.condition, parameters), substituteExpression(branch.result, parameters))]
    end for
    elseExpression = void
    if expression.elseExpression is not void then elseExpression = substituteExpression(expression.elseExpression, parameters) end if
    return ast.caseExpression(branches, elseExpression)
  end if
  if ast.isCastExpression(expression) then return ast.castExpression(substituteExpression(expression.operand, parameters), expression.targetType) end if
  if ast.isInExpression(expression) then
    candidates = []
    for each candidate in expression.values
      candidates = candidates + [substituteExpression(candidate, parameters)]
    end for
    return ast.inExpression(substituteExpression(expression.operand, parameters), candidates, expression.negated)
  end if
  if ast.isBetweenExpression(expression) then return ast.betweenExpression(substituteExpression(expression.operand, parameters), substituteExpression(expression.lower, parameters), substituteExpression(expression.upper, parameters), expression.negated) end if
  if ast.isTruthTestExpression(expression) then return ast.truthTestExpression(substituteExpression(expression.operand, parameters), expression.expected, expression.negated) end if
  if ast.isFunctionExpression(expression) then
    arguments = []
    for each argument in expression.arguments
      arguments = arguments + [substituteExpression(argument, parameters)]
    end for
    return ast.functionExpression(expression.name, arguments, expression.distinct)
  end if
  if ast.isSubqueryExpression(expression) then return ast.subqueryExpression(substituteSelect(expression.query, parameters)) end if
  if ast.isExistsExpression(expression) then return ast.existsExpression(substituteSelect(expression.query, parameters)) end if
  if ast.isInSubqueryExpression(expression) then return ast.inSubqueryExpression(substituteExpression(expression.operand, parameters), substituteSelect(expression.query, parameters), expression.negated) end if
  if ast.isWindowExpression(expression) then
    arguments = []
    partitions = []
    orders = []
    for each argument in expression.arguments
      arguments = arguments + [substituteExpression(argument, parameters)]
    end for
    for each value in expression.partitionBy
      partitions = partitions + [substituteExpression(value, parameters)]
    end for
    for each value in expression.orderBy
      orders = orders + [ast.OrderItem(substituteExpression(value.expression, parameters), value.descending, value.nullsFirst, value.nullsSpecified)]
    end for
    return ast.windowExpression(expression.name, arguments, partitions, orders)
  end if
  return fail(BINDING_ERROR, "substituteExpression", "unsupported prepared expression")
end function

// Implements substitute select for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function substituteSelect(statement, parameters)
  items = []
  for each item in statement.items
    items = items + [ast.SelectItem(substituteExpression(item.expression, parameters), item.alias)]
  end for
  joins = []
  for each value in statement.joins
    condition = void
    if value.condition is not void then condition = substituteExpression(value.condition, parameters) end if
    joins = joins + [ast.JoinClause(value.joinType, value.tableName, value.tableAlias, condition)]
  end for
  whereExpression = void
  if statement.whereExpression is not void then whereExpression = substituteExpression(statement.whereExpression, parameters) end if
  groups = []
  for each value in statement.groupBy
    groups = groups + [substituteExpression(value, parameters)]
  end for
  havingExpression = void
  if statement.havingExpression is not void then havingExpression = substituteExpression(statement.havingExpression, parameters) end if
  setOperations = []
  for each value in statement.setOperations
    setOperations = setOperations + [ast.SetOperation(value.operator, value.all, substituteSelect(value.query, parameters))]
  end for
  orderBy = []
  for each value in statement.orderBy
    orderBy = orderBy + [ast.OrderItem(substituteExpression(value.expression, parameters), value.descending, value.nullsFirst, value.nullsSpecified)]
  end for
  ctes = []
  for each cte in statement.ctes
    ctes = ctes + [ast.CommonTableExpression(cte.name, substituteSelect(cte.query, parameters), cte.columnNames, cte.recursive)]
  end for
  return ast.SelectStatement(statement.distinct, items, statement.tableName, statement.tableAlias, joins, whereExpression, groups, havingExpression, setOperations, orderBy, statement.limit, statement.offset, ctes)
end function

// Implements substitute returning for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function substituteReturning(items, parameters)
  output = []
  for each item in items
    output = output + [ast.SelectItem(substituteExpression(item.expression, parameters), item.alias)]
  end for
  return output
end function

// Implements substitute statement for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function substituteStatement(statement, parameters)
  if ast.isSelectStatement(statement) then return substituteSelect(statement, parameters) end if
  if ast.isInsertStatement(statement) then
    rows = []
    for each sourceRow in statement.rows
      row = []
      for each expression in sourceRow
        row = row + [substituteExpression(expression, parameters)]
      end for
      rows = rows + [row]
    end for
    sourceQuery = void
    if statement.sourceQuery is not void then sourceQuery = substituteSelect(statement.sourceQuery, parameters) end if
    conflictAssignments = []
    for each assignment in statement.conflictAssignments
      conflictAssignments = conflictAssignments + [ast.Assignment(assignment.column, substituteExpression(assignment.expression, parameters))]
    end for
    conflictWhere = void
    if statement.conflictWhere is not void then conflictWhere = substituteExpression(statement.conflictWhere, parameters) end if
    return ast.InsertStatement(statement.tableName, statement.columns, rows, sourceQuery, statement.conflictTarget, statement.conflictAction, conflictAssignments, conflictWhere, substituteReturning(statement.returning, parameters))
  end if
  if ast.isUpdateStatement(statement) then
    assignments = []
    for each assignment in statement.assignments
      assignments = assignments + [ast.Assignment(assignment.column, substituteExpression(assignment.expression, parameters))]
    end for
    whereExpression = void
    if statement.whereExpression is not void then whereExpression = substituteExpression(statement.whereExpression, parameters) end if
    return ast.UpdateStatement(statement.tableName, assignments, whereExpression, substituteReturning(statement.returning, parameters))
  end if
  if ast.isDeleteStatement(statement) then
    whereExpression = void
    if statement.whereExpression is not void then whereExpression = substituteExpression(statement.whereExpression, parameters) end if
    return ast.DeleteStatement(statement.tableName, whereExpression, substituteReturning(statement.returning, parameters))
  end if
  return fail(UNSUPPORTED_SQL, "substituteStatement", "prepared statement type is unsupported")
end function

// Implements materialize expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function materializeExpression(engine, expression, pageTransaction, deferSubqueries)
  if ast.isLiteralExpression(expression) or ast.isTypedLiteralExpression(expression) or ast.isColumnExpression(expression) or ast.isStarExpression(expression) or ast.isParameterExpression(expression) then return expression end if
  if ast.isUnaryExpression(expression) then return ast.unaryExpression(expression.operator, materializeExpression(engine, expression.operand, pageTransaction, deferSubqueries)) end if
  if ast.isBinaryExpression(expression) then return ast.binaryExpression(expression.operator, materializeExpression(engine, expression.left, pageTransaction, deferSubqueries), materializeExpression(engine, expression.right, pageTransaction, deferSubqueries)) end if
  if ast.isIsNullExpression(expression) then return ast.isNullExpression(materializeExpression(engine, expression.operand, pageTransaction, deferSubqueries), expression.negated) end if
  if ast.isCaseExpression(expression) then
    branches = []
    for each branch in expression.branches
      branches = branches + [ast.caseBranch(materializeExpression(engine, branch.condition, pageTransaction, deferSubqueries), materializeExpression(engine, branch.result, pageTransaction, deferSubqueries))]
    end for
    elseExpression = void
    if expression.elseExpression is not void then elseExpression = materializeExpression(engine, expression.elseExpression, pageTransaction, deferSubqueries) end if
    return ast.caseExpression(branches, elseExpression)
  end if
  if ast.isCastExpression(expression) then return ast.castExpression(materializeExpression(engine, expression.operand, pageTransaction, deferSubqueries), expression.targetType) end if
  if ast.isInExpression(expression) then
    candidates = []
    for each candidate in expression.values
      candidates = candidates + [materializeExpression(engine, candidate, pageTransaction, deferSubqueries)]
    end for
    return ast.inExpression(materializeExpression(engine, expression.operand, pageTransaction, deferSubqueries), candidates, expression.negated)
  end if
  if ast.isBetweenExpression(expression) then return ast.betweenExpression(materializeExpression(engine, expression.operand, pageTransaction, deferSubqueries), materializeExpression(engine, expression.lower, pageTransaction, deferSubqueries), materializeExpression(engine, expression.upper, pageTransaction, deferSubqueries), expression.negated) end if
  if ast.isTruthTestExpression(expression) then return ast.truthTestExpression(materializeExpression(engine, expression.operand, pageTransaction, deferSubqueries), expression.expected, expression.negated) end if
  if ast.isFunctionExpression(expression) then
    if expression.name == "NEXTVAL" or expression.name == "CURRVAL" then
      if len(expression.arguments) != 1 then return fail(BINDING_ERROR, "materializeExpression", expression.name + " requires one sequence-name argument") end if
      sequenceName = sequenceArgumentName(expression.arguments[0], "materializeExpression")
      sequenceParts = splitObjectName(sequenceName)
      if sequenceParts[0] == "public" then sequenceName = sequenceParts[1] end if
      sequenceValue = void
      if expression.name == "NEXTVAL" then
        sequenceValue = schema_history.nextSequence(engine.database.path, engine.database.catalogHandle.metadata.databaseId, sequenceName)
        rememberSequenceValue(engine, sequenceName, sequenceValue)
      else
        sequenceValue = currentSequenceValue(engine, sequenceName)
      end if
      return ast.typedLiteralExpression(values.of(types.SqlTypeKind.BigInt, sequenceValue))
    end if
    arguments = []
    for each argument in expression.arguments
      arguments = arguments + [materializeExpression(engine, argument, pageTransaction, deferSubqueries)]
    end for
    return ast.functionExpression(expression.name, arguments, expression.distinct)
  end if
  if ast.isWindowExpression(expression) then
    arguments = []
    partitions = []
    orders = []
    for each argument in expression.arguments
      arguments = arguments + [materializeExpression(engine, argument, pageTransaction, deferSubqueries)]
    end for
    for each value in expression.partitionBy
      partitions = partitions + [materializeExpression(engine, value, pageTransaction, deferSubqueries)]
    end for
    for each value in expression.orderBy
      orders = orders + [ast.OrderItem(materializeExpression(engine, value.expression, pageTransaction, deferSubqueries), value.descending, value.nullsFirst, value.nullsSpecified)]
    end for
    return ast.windowExpression(expression.name, arguments, partitions, orders)
  end if
  if ast.isSubqueryExpression(expression) or ast.isExistsExpression(expression) or ast.isInSubqueryExpression(expression) then
    query = expression.query
    query = materializeSelectStatement(engine, query, pageTransaction)
    if deferSubqueries and selectHasPotentialOuterReferences(query) then
      if ast.isSubqueryExpression(expression) then return ast.subqueryExpression(query) end if
      if ast.isExistsExpression(expression) then return ast.existsExpression(query) end if
      return ast.inSubqueryExpression(materializeExpression(engine, expression.operand, pageTransaction, true), query, expression.negated)
    end if
    bound = binder.bindSelect(query, engine.database.catalogHandle)
    result = selectRows(engine, bound, pageTransaction)
    if ast.isExistsExpression(expression) then return ast.typedLiteralExpression(values.boolean(len(result.rows) > 0)) end if
    if ast.isSubqueryExpression(expression) then
      if len(bound.items) != 1 then return fail(BINDING_ERROR, "materializeExpression", "scalar subquery must return exactly one column") end if
      if len(result.rows) > 1 then return fail(BINDING_ERROR, "materializeExpression", "scalar subquery returned more than one row") end if
      if len(result.rows) == 0 then return ast.typedLiteralExpression(values.nullValue(bound.items[0].typeInfo.kind)) end if
      return ast.typedLiteralExpression(result.rows[0][0])
    end if
    operand = materializeExpression(engine, expression.operand, pageTransaction, false)
    if len(bound.items) != 1 then return fail(BINDING_ERROR, "materializeExpression", "IN subquery must return exactly one column") end if
    if len(result.rows) == 0 then return ast.typedLiteralExpression(values.boolean(expression.negated)) end if
    candidates = []
    for each row in result.rows
      candidates = candidates + [ast.typedLiteralExpression(row[0])]
    end for
    return ast.inExpression(operand, candidates, expression.negated)
  end if
  return fail(BINDING_ERROR, "materializeExpression", "unsupported expression")
end function

// Implements materialize select statement for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function materializeSelectStatement(engine, statement, pageTransaction)
  items = []
  for each item in statement.items
    items = items + [ast.SelectItem(materializeExpression(engine, item.expression, pageTransaction, true), item.alias)]
  end for
  joins = []
  for each value in statement.joins
    condition = void
    if value.condition is not void then condition = materializeExpression(engine, value.condition, pageTransaction, true) end if
    joins = joins + [ast.JoinClause(value.joinType, value.tableName, value.tableAlias, condition)]
  end for
  whereExpression = void
  if statement.whereExpression is not void then whereExpression = materializeExpression(engine, statement.whereExpression, pageTransaction, true) end if
  groups = []
  for each value in statement.groupBy
    groups = groups + [materializeExpression(engine, value, pageTransaction, true)]
  end for
  havingExpression = void
  if statement.havingExpression is not void then havingExpression = materializeExpression(engine, statement.havingExpression, pageTransaction, true) end if
  setOperations = []
  for each value in statement.setOperations
    setOperations = setOperations + [ast.SetOperation(value.operator, value.all, materializeSelectStatement(engine, value.query, pageTransaction))]
  end for
  orderBy = []
  for each value in statement.orderBy
    orderBy = orderBy + [ast.OrderItem(materializeExpression(engine, value.expression, pageTransaction, true), value.descending, value.nullsFirst, value.nullsSpecified)]
  end for
  ctes = []
  for each cte in statement.ctes
    ctes = ctes + [ast.CommonTableExpression(cte.name, materializeSelectStatement(engine, cte.query, pageTransaction), cte.columnNames, cte.recursive)]
  end for
  return ast.SelectStatement(statement.distinct, items, statement.tableName, statement.tableAlias, joins, whereExpression, groups, havingExpression, setOperations, orderBy, statement.limit, statement.offset, ctes)
end function

// Returns true when a nested SELECT declares a qualifier that shadows an outer source.
function nestedSelectDeclaresQualifier(statement, qualifier)
  if statement.tableName is not void then
    tableParts = splitObjectName(statement.tableName)
    if statement.tableName == qualifier or tableParts[1] == qualifier or statement.tableAlias == qualifier then return true end if
  end if
  for each joinClause in statement.joins
    joinParts = splitObjectName(joinClause.tableName)
    if joinClause.tableName == qualifier or joinParts[1] == qualifier or joinClause.tableAlias == qualifier then return true end if
  end for
  for each cte in statement.ctes
    if cte.name == qualifier then return true end if
  end for
  return false
end function

// Detects a qualified column whose source is not declared by its immediate SELECT.
function expressionHasPotentialOuterReference(expression, statement)
  if ast.isColumnExpression(expression) then return expression.qualifier is not void and not nestedSelectDeclaresQualifier(statement, expression.qualifier) end if
  if ast.isLiteralExpression(expression) or ast.isTypedLiteralExpression(expression) or ast.isStarExpression(expression) or ast.isParameterExpression(expression) then return false end if
  if ast.isUnaryExpression(expression) or ast.isIsNullExpression(expression) then return expressionHasPotentialOuterReference(expression.operand, statement) end if
  if ast.isBinaryExpression(expression) then return expressionHasPotentialOuterReference(expression.left, statement) or expressionHasPotentialOuterReference(expression.right, statement) end if
  if ast.isCaseExpression(expression) then
    for each branch in expression.branches
      if expressionHasPotentialOuterReference(branch.condition, statement) or expressionHasPotentialOuterReference(branch.result, statement) then return true end if
    end for
    return expression.elseExpression is not void and expressionHasPotentialOuterReference(expression.elseExpression, statement)
  end if
  if ast.isCastExpression(expression) then return expressionHasPotentialOuterReference(expression.operand, statement) end if
  if ast.isInExpression(expression) then
    if expressionHasPotentialOuterReference(expression.operand, statement) then return true end if
    for each candidate in expression.values
      if expressionHasPotentialOuterReference(candidate, statement) then return true end if
    end for
    return false
  end if
  if ast.isBetweenExpression(expression) then return expressionHasPotentialOuterReference(expression.operand, statement) or expressionHasPotentialOuterReference(expression.lower, statement) or expressionHasPotentialOuterReference(expression.upper, statement) end if
  if ast.isTruthTestExpression(expression) then return expressionHasPotentialOuterReference(expression.operand, statement) end if
  if ast.isFunctionExpression(expression) or ast.isWindowExpression(expression) then
    for each argument in expression.arguments
      if expressionHasPotentialOuterReference(argument, statement) then return true end if
    end for
    if ast.isWindowExpression(expression) then
      for each value in expression.partitionBy
        if expressionHasPotentialOuterReference(value, statement) then return true end if
      end for
      for each value in expression.orderBy
        if expressionHasPotentialOuterReference(value.expression, statement) then return true end if
      end for
    end if
    return false
  end if
  if ast.isSubqueryExpression(expression) or ast.isExistsExpression(expression) or ast.isInSubqueryExpression(expression) then
    if ast.isInSubqueryExpression(expression) and expressionHasPotentialOuterReference(expression.operand, statement) then return true end if
    return selectHasPotentialOuterReferences(expression.query)
  end if
  return false
end function

// Returns whether any expression in a SELECT may need a concrete outer row.
function selectHasPotentialOuterReferences(statement)
  for each item in statement.items
    if expressionHasPotentialOuterReference(item.expression, statement) then return true end if
  end for
  for each joinClause in statement.joins
    if joinClause.condition is not void and expressionHasPotentialOuterReference(joinClause.condition, statement) then return true end if
  end for
  if statement.whereExpression is not void and expressionHasPotentialOuterReference(statement.whereExpression, statement) then return true end if
  for each value in statement.groupBy
    if expressionHasPotentialOuterReference(value, statement) then return true end if
  end for
  if statement.havingExpression is not void and expressionHasPotentialOuterReference(statement.havingExpression, statement) then return true end if
  for each value in statement.orderBy
    if expressionHasPotentialOuterReference(value.expression, statement) then return true end if
  end for
  for each operation in statement.setOperations
    if selectHasPotentialOuterReferences(operation.query) then return true end if
  end for
  for each cte in statement.ctes
    if selectHasPotentialOuterReferences(cte.query) then return true end if
  end for
  return false
end function

// Resolves a qualified outer reference against the current joined source row.
function substituteOuterColumn(expression, sources, rowValues, statement)
  if expression.qualifier is void or nestedSelectDeclaresQualifier(statement, expression.qualifier) then return expression end if
  for each source in sources
    visibleName = source.alias
    if visibleName is void then
      sourceParts = splitObjectName(source.table.name)
      visibleName = sourceParts[1]
    end if
    if expression.qualifier == visibleName or expression.qualifier == source.table.name then
      if len(source.table.columns) > 0 then
        for index = 0 to len(source.table.columns) - 1
          if source.table.columns[index].name == expression.name then return ast.typedLiteralExpression(rowValues[source.offset + index]) end if
        end for
      end if
      return fail(BINDING_ERROR, "correlatedSubquery", "unknown outer column " + expression.qualifier + "." + expression.name)
    end if
  end for
  return expression
end function

// Substitutes outer-row values throughout an expression while preserving inner shadowing.
function substituteOuterExpression(expression, sources, rowValues, statement)
  if ast.isColumnExpression(expression) then return substituteOuterColumn(expression, sources, rowValues, statement) end if
  if ast.isLiteralExpression(expression) or ast.isTypedLiteralExpression(expression) or ast.isStarExpression(expression) or ast.isParameterExpression(expression) then return expression end if
  if ast.isUnaryExpression(expression) then return ast.unaryExpression(expression.operator, substituteOuterExpression(expression.operand, sources, rowValues, statement)) end if
  if ast.isBinaryExpression(expression) then return ast.binaryExpression(expression.operator, substituteOuterExpression(expression.left, sources, rowValues, statement), substituteOuterExpression(expression.right, sources, rowValues, statement)) end if
  if ast.isIsNullExpression(expression) then return ast.isNullExpression(substituteOuterExpression(expression.operand, sources, rowValues, statement), expression.negated) end if
  if ast.isCaseExpression(expression) then
    branches = []
    for each branch in expression.branches
      branches = branches + [ast.caseBranch(substituteOuterExpression(branch.condition, sources, rowValues, statement), substituteOuterExpression(branch.result, sources, rowValues, statement))]
    end for
    elseExpression = void
    if expression.elseExpression is not void then elseExpression = substituteOuterExpression(expression.elseExpression, sources, rowValues, statement) end if
    return ast.caseExpression(branches, elseExpression)
  end if
  if ast.isCastExpression(expression) then return ast.castExpression(substituteOuterExpression(expression.operand, sources, rowValues, statement), expression.targetType) end if
  if ast.isInExpression(expression) then
    candidates = []
    for each candidate in expression.values
      candidates = candidates + [substituteOuterExpression(candidate, sources, rowValues, statement)]
    end for
    return ast.inExpression(substituteOuterExpression(expression.operand, sources, rowValues, statement), candidates, expression.negated)
  end if
  if ast.isBetweenExpression(expression) then return ast.betweenExpression(substituteOuterExpression(expression.operand, sources, rowValues, statement), substituteOuterExpression(expression.lower, sources, rowValues, statement), substituteOuterExpression(expression.upper, sources, rowValues, statement), expression.negated) end if
  if ast.isTruthTestExpression(expression) then return ast.truthTestExpression(substituteOuterExpression(expression.operand, sources, rowValues, statement), expression.expected, expression.negated) end if
  if ast.isFunctionExpression(expression) then
    arguments = []
    for each argument in expression.arguments
      arguments = arguments + [substituteOuterExpression(argument, sources, rowValues, statement)]
    end for
    return ast.functionExpression(expression.name, arguments, expression.distinct)
  end if
  if ast.isSubqueryExpression(expression) then return ast.subqueryExpression(substituteOuterSelect(expression.query, sources, rowValues)) end if
  if ast.isExistsExpression(expression) then return ast.existsExpression(substituteOuterSelect(expression.query, sources, rowValues)) end if
  if ast.isInSubqueryExpression(expression) then return ast.inSubqueryExpression(substituteOuterExpression(expression.operand, sources, rowValues, statement), substituteOuterSelect(expression.query, sources, rowValues), expression.negated) end if
  if ast.isWindowExpression(expression) then
    arguments = []
    partitions = []
    orders = []
    for each argument in expression.arguments
      arguments = arguments + [substituteOuterExpression(argument, sources, rowValues, statement)]
    end for
    for each value in expression.partitionBy
      partitions = partitions + [substituteOuterExpression(value, sources, rowValues, statement)]
    end for
    for each value in expression.orderBy
      orders = orders + [ast.OrderItem(substituteOuterExpression(value.expression, sources, rowValues, statement), value.descending, value.nullsFirst, value.nullsSpecified)]
    end for
    return ast.windowExpression(expression.name, arguments, partitions, orders)
  end if
  return fail(BINDING_ERROR, "correlatedSubquery", "unsupported nested expression")
end function

// Copies a nested SELECT with every non-shadowed outer reference replaced by a row literal.
function substituteOuterSelect(statement, sources, rowValues)
  items = []
  for each item in statement.items
    items = items + [ast.SelectItem(substituteOuterExpression(item.expression, sources, rowValues, statement), item.alias)]
  end for
  joins = []
  for each value in statement.joins
    condition = void
    if value.condition is not void then condition = substituteOuterExpression(value.condition, sources, rowValues, statement) end if
    joins = joins + [ast.JoinClause(value.joinType, value.tableName, value.tableAlias, condition)]
  end for
  whereExpression = void
  if statement.whereExpression is not void then whereExpression = substituteOuterExpression(statement.whereExpression, sources, rowValues, statement) end if
  groups = []
  for each value in statement.groupBy
    groups = groups + [substituteOuterExpression(value, sources, rowValues, statement)]
  end for
  havingExpression = void
  if statement.havingExpression is not void then havingExpression = substituteOuterExpression(statement.havingExpression, sources, rowValues, statement) end if
  setOperations = []
  for each value in statement.setOperations
    setOperations = setOperations + [ast.SetOperation(value.operator, value.all, substituteOuterSelect(value.query, sources, rowValues))]
  end for
  orderBy = []
  for each value in statement.orderBy
    orderBy = orderBy + [ast.OrderItem(substituteOuterExpression(value.expression, sources, rowValues, statement), value.descending, value.nullsFirst, value.nullsSpecified)]
  end for
  ctes = []
  for each cte in statement.ctes
    ctes = ctes + [ast.CommonTableExpression(cte.name, substituteOuterSelect(cte.query, sources, rowValues), cte.columnNames, cte.recursive)]
  end for
  return ast.SelectStatement(statement.distinct, items, statement.tableName, statement.tableAlias, joins, whereExpression, groups, havingExpression, setOperations, orderBy, statement.limit, statement.offset, ctes)
end function

// Implements materialize DML statement for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function materializeDmlStatement(engine, statement, pageTransaction)
  if ast.isInsertStatement(statement) then
    rows = []
    for each sourceRow in statement.rows
      row = []
      for each expression in sourceRow
        row = row + [materializeExpression(engine, expression, pageTransaction, false)]
      end for
      rows = rows + [row]
    end for
    sourceQuery = void
    if statement.sourceQuery is not void then sourceQuery = materializeSelectStatement(engine, statement.sourceQuery, pageTransaction) end if
    assignments = []
    for each assignment in statement.conflictAssignments
      assignments = assignments + [ast.Assignment(assignment.column, materializeExpression(engine, assignment.expression, pageTransaction, false))]
    end for
    conflictWhere = void
    if statement.conflictWhere is not void then conflictWhere = materializeExpression(engine, statement.conflictWhere, pageTransaction, false) end if
    returning = []
    for each item in statement.returning
      returning = returning + [ast.SelectItem(materializeExpression(engine, item.expression, pageTransaction, false), item.alias)]
    end for
    return ast.InsertStatement(statement.tableName, statement.columns, rows, sourceQuery, statement.conflictTarget, statement.conflictAction, assignments, conflictWhere, returning)
  end if
  if ast.isUpdateStatement(statement) then
    assignments = []
    for each assignment in statement.assignments
      assignments = assignments + [ast.Assignment(assignment.column, materializeExpression(engine, assignment.expression, pageTransaction, false))]
    end for
    whereExpression = void
    if statement.whereExpression is not void then whereExpression = materializeExpression(engine, statement.whereExpression, pageTransaction, false) end if
    returning = []
    for each item in statement.returning
      returning = returning + [ast.SelectItem(materializeExpression(engine, item.expression, pageTransaction, false), item.alias)]
    end for
    return ast.UpdateStatement(statement.tableName, assignments, whereExpression, returning)
  end if
  if ast.isDeleteStatement(statement) then
    whereExpression = void
    if statement.whereExpression is not void then whereExpression = materializeExpression(engine, statement.whereExpression, pageTransaction, false) end if
    returning = []
    for each item in statement.returning
      returning = returning + [ast.SelectItem(materializeExpression(engine, item.expression, pageTransaction, false), item.alias)]
    end for
    return ast.DeleteStatement(statement.tableName, whereExpression, returning)
  end if
  return statement
end function

// Executes prepare using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function executePrepare(engine, statement)
  if findPreparedIndex(engine, statement.name) >= 0 then return fail(BINDING_ERROR, "prepare", "prepared statement already exists: " + statement.name) end if
  engine.preparedStatements = engine.preparedStatements + [PreparedStatementState(statement.name, statement.statement, statement.parameterCount, currentSchemaGeneration(engine))]
  return commandResult("PREPARE", 0, statement.name + " parameters=" + statement.parameterCount)
end function

// Executes prepared using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function executePrepared(engine, statement)
  index = findPreparedIndex(engine, statement.name)
  if index < 0 then return fail(BINDING_ERROR, "executePrepared", "prepared statement not found: " + statement.name) end if
  prepared = engine.preparedStatements[index]
  if len(statement.arguments) != prepared.parameterCount then return fail(BINDING_ERROR, "executePrepared", "expected " + prepared.parameterCount + " parameters, got " + len(statement.arguments)) end if
  for each argument in statement.arguments
    if not constantParameterExpression(argument) then return fail(BINDING_ERROR, "executePrepared", "USING arguments must be constant expressions") end if
  end for
  generation = currentSchemaGeneration(engine)
  if generation != prepared.schemaGeneration then
    prepared.schemaGeneration = generation
    engine.preparedStatements[index] = prepared
  end if
  expanded = substituteStatement(prepared.statement, statement.arguments)
  // EXECUTE itself already owns the execution gate selected for the prepared
  // AST. Re-entering the public wrapper would deadlock a writer semaphore.
  return executeStatementCore(engine, expanded)
end function

// Executes deallocate using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function executeDeallocate(engine, statement)
  index = findPreparedIndex(engine, statement.name)
  if index < 0 then return fail(BINDING_ERROR, "deallocate", "prepared statement not found: " + statement.name) end if
  output = []
  if len(engine.preparedStatements) > 1 then
    for i = 0 to len(engine.preparedStatements) - 1
      if i != index then output = output + [engine.preparedStatements[i]] end if
    end for
  end if
  engine.preparedStatements = output
  return commandResult("DEALLOCATE", 0, statement.name)
end function

// Resets transaction using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function resetTransaction(engine)
  engine.explicitTransaction = false
  engine.transactionMode = MODE_NONE
  engine.pageTransaction = void
  engine.ddlTransaction = void
  engine.failed = false
  return true
end function

// Implements isolation value for this module.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isolationValue(name)
  if name == "READ COMMITTED" then return transaction.ISOLATION_READ_COMMITTED end if
  return transaction.ISOLATION_SERIALIZABLE
end function

// Implements begin explicit for this module.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function beginExplicit(engine, statement)
  validateOpen(engine, "begin")
  if engine.explicitTransaction then return fail(TRANSACTION_STATE, "begin", "transaction already active") end if
  engine.explicitTransaction = true
  engine.transactionMode = MODE_NONE
  engine.pageTransaction = void
  engine.ddlTransaction = void
  engine.failed = false
  // Store requested options by opening the page transaction lazily only when
  // DML is first executed. A read-only transaction with SELECT-only workload
  // therefore performs no WAL or object-ID allocation.
  engine.pageTransaction = [isolationValue(statement.isolationLevel), statement.readOnly]
  return commandResult("BEGIN", 0, "transaction started")
end function

// Ensures explicit DML using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function ensureExplicitDml(engine)
  if engine.transactionMode == MODE_DDL then return fail(UNSUPPORTED_SQL, "ensureExplicitDml", "mixing DDL and DML in one M15 transaction is not supported") end if
  if engine.transactionMode == MODE_NONE then
    options = engine.pageTransaction
    engine.pageTransaction = database_manager.begin(engine.database, options[0], options[1])
    engine.transactionMode = MODE_DML
  end if
  return engine.pageTransaction
end function

// Ensures explicit DDL using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function ensureExplicitDdl(engine)
  if engine.transactionMode == MODE_DML then return fail(UNSUPPORTED_SQL, "ensureExplicitDdl", "mixing DML and DDL in one M15 transaction is not supported") end if
  if engine.transactionMode == MODE_NONE then
    options = engine.pageTransaction
    if options[1] then return fail(DDL_STATE, "ensureExplicitDdl", "read-only transaction cannot execute DDL") end if
    engine.pageTransaction = void
    engine.ddlTransaction = schema_history.begin(engine.database.catalogHandle)
    engine.transactionMode = MODE_DDL
  end if
  return engine.ddlTransaction
end function

// Binds bind using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function bind(statement, engine)
  return binder.bindStatement(statement, engine.database.catalogHandle)
end function

// Implements stage DDL for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function stageDdl(ddlTransaction, bound)
  if binder.isBoundCreateTable(bound) then schema_history.stageCreateTable(ddlTransaction, bound); return "CREATE TABLE" end if
  if binder.isBoundCreateIndex(bound) then schema_history.stageCreateIndex(ddlTransaction, bound); return "CREATE INDEX" end if
  if binder.isBoundDropTable(bound) then schema_history.stageDropTable(ddlTransaction, bound); return "DROP TABLE" end if
  if binder.isBoundAlterTable(bound) then schema_history.stageAlterTable(ddlTransaction, bound); return bound.command end if
  return fail(BINDING_ERROR, "stageDdl", "unsupported bound DDL statement")
end function

// Validates ALTER TABLE operations whose safety depends on currently stored rows.
// DROP COLUMN deliberately starts with empty tables so the versioned row codec
// never has to reinterpret a wider historical row as a shorter layout.
function validateAlterTableRows(engine, bound)
  if not binder.isBoundAlterTable(bound) or bound.table is void then return true end if
  action = bound.statement.action
  if action != ast.ALTER_TABLE_DROP_COLUMN and action != ast.ALTER_TABLE_SET_NOT_NULL then return true end if
  rows = scan.scanTable(engine.database.path, bound.table, void)
  if action == ast.ALTER_TABLE_DROP_COLUMN then
    if len(rows) > 0 then return fail(UNSUPPORTED_SQL, "validateAlterTableRows", "DROP COLUMN currently requires an empty table to avoid an implicit physical rewrite") end if
    return true
  end if
  columnIndex = binder.findColumnIndex(bound.table, bound.statement.oldName)
  for each row in rows
    if row.values[columnIndex].isNull then return fail(CONSTRAINT_VIOLATION, "validateAlterTableRows", "column contains NULL values: " + bound.statement.oldName) end if
  end for
  return true
end function

// Verifies that the namespace of a qualified object exists before object DDL.
function requireObjectSchema(engine, objectName, operation)
  parts = splitObjectName(objectName)
  state = schema_history.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
  if not schema_history.schemaExists(state, parts[0]) then return fail(BINDING_ERROR, operation, "schema does not exist: " + parts[0]) end if
  return true
end function

// Executes durable CREATE/DROP SCHEMA operations outside user transactions.
function executeSchemaDdl(engine, statement)
  if engine.explicitTransaction then return fail(UNSUPPORTED_SQL, "executeSchemaDdl", "schema DDL is autocommit-only") end if
  databaseId = engine.database.catalogHandle.metadata.databaseId
  if ast.isCreateSchemaStatement(statement) then
    created = schema_history.putSchema(engine.database.path, databaseId, statement.name, statement.ifNotExists)
    count = 0
    if created then count = 1 end if
    return commandResult("CREATE SCHEMA", count, statement.name)
  end if
  if ast.isDropSchemaStatement(statement) then
    for each table in engine.database.catalogHandle.catalog.tables
      if schema_history.objectInSchema(table.name, statement.name) then return fail(CONSTRAINT_VIOLATION, "executeSchemaDdl", "schema is not empty: " + statement.name) end if
    end for
    dropped = schema_history.dropSchema(engine.database.path, databaseId, statement.name, statement.ifExists)
    count = 0
    if dropped then count = 1 end if
    return commandResult("DROP SCHEMA", count, statement.name)
  end if
  return fail(BINDING_ERROR, "executeSchemaDdl", "unsupported schema DDL")
end function

// Executes view DDL using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeViewDdl(engine, statement)
  if engine.explicitTransaction then return fail(UNSUPPORTED_SQL, "executeViewDdl", "view DDL is autocommit-only in M43") end if
  database = engine.database.catalogHandle
  databaseId = database.metadata.databaseId
  if schema_history.isInternalExtensionViewName(statement.name) then return fail(BINDING_ERROR, "executeViewDdl", "view name is reserved for internal metadata") end if
  if ast.isCreateViewStatement(statement) then
    requireObjectSchema(engine, statement.name, "executeViewDdl")
    if catalog.findTable(database, statement.name) is not void then return fail(BINDING_ERROR, "executeViewDdl", "table already exists with name " + statement.name) end if
    bound = binder.bindSelect(statement.query, database)
    saved = schema_history.putView(engine.database.path, databaseId, statement.name, ast.formatSelect(statement.query), bound.itemNames, statement.replace)
    return commandResult("CREATE VIEW", 0, saved.name)
  end if
  if ast.isDropViewStatement(statement) then
    removed = schema_history.dropView(engine.database.path, databaseId, statement.name, statement.ifExists)
    count = 0
    if removed then count = 1 end if
    return commandResult("DROP VIEW", count, statement.name)
  end if
  return fail(BINDING_ERROR, "executeViewDdl", "unsupported view DDL")
end function

// Implements trigger event code for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function triggerEventCode(bound)
  if binder.isBoundInsert(bound) then return schema_history.TRIGGER_INSERT end if
  if binder.isBoundUpdate(bound) then return schema_history.TRIGGER_UPDATE end if
  if binder.isBoundDelete(bound) then return schema_history.TRIGGER_DELETE end if
  return 0
end function

// Implements trigger column value for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function triggerColumnValue(table, row, qualifier, columnName)
  if row is void then return fail(BINDING_ERROR, "triggerColumnValue", qualifier + "." + columnName + " is not available for this trigger event") end if
  columnIndex = binder.findColumnIndex(table, columnName)
  if columnIndex < 0 then return fail(BINDING_ERROR, "triggerColumnValue", "unknown trigger column " + columnName) end if
  return ast.typedLiteralExpression(row[columnIndex])
end function

// Implements replace trigger expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function replaceTriggerExpression(expression, table, oldRow, newRow)
  if ast.isColumnExpression(expression) then
    if expression.qualifier == "old" or expression.qualifier == "OLD" then return triggerColumnValue(table, oldRow, "OLD", expression.name) end if
    if expression.qualifier == "new" or expression.qualifier == "NEW" then return triggerColumnValue(table, newRow, "NEW", expression.name) end if
    return expression
  end if
  if ast.isLiteralExpression(expression) or ast.isTypedLiteralExpression(expression) or ast.isStarExpression(expression) or ast.isParameterExpression(expression) then return expression end if
  if ast.isUnaryExpression(expression) then return ast.unaryExpression(expression.operator, replaceTriggerExpression(expression.operand, table, oldRow, newRow)) end if
  if ast.isBinaryExpression(expression) then return ast.binaryExpression(expression.operator, replaceTriggerExpression(expression.left, table, oldRow, newRow), replaceTriggerExpression(expression.right, table, oldRow, newRow)) end if
  if ast.isIsNullExpression(expression) then return ast.isNullExpression(replaceTriggerExpression(expression.operand, table, oldRow, newRow), expression.negated) end if
  if ast.isCaseExpression(expression) then
    branches = []
    for each branch in expression.branches
      branches = branches + [ast.caseBranch(replaceTriggerExpression(branch.condition, table, oldRow, newRow), replaceTriggerExpression(branch.result, table, oldRow, newRow))]
    end for
    elseExpression = void
    if expression.elseExpression is not void then elseExpression = replaceTriggerExpression(expression.elseExpression, table, oldRow, newRow) end if
    return ast.caseExpression(branches, elseExpression)
  end if
  if ast.isCastExpression(expression) then return ast.castExpression(replaceTriggerExpression(expression.operand, table, oldRow, newRow), expression.targetType) end if
  if ast.isInExpression(expression) then
    candidates = []
    for each candidate in expression.values
      candidates = candidates + [replaceTriggerExpression(candidate, table, oldRow, newRow)]
    end for
    return ast.inExpression(replaceTriggerExpression(expression.operand, table, oldRow, newRow), candidates, expression.negated)
  end if
  if ast.isBetweenExpression(expression) then return ast.betweenExpression(replaceTriggerExpression(expression.operand, table, oldRow, newRow), replaceTriggerExpression(expression.lower, table, oldRow, newRow), replaceTriggerExpression(expression.upper, table, oldRow, newRow), expression.negated) end if
  if ast.isTruthTestExpression(expression) then return ast.truthTestExpression(replaceTriggerExpression(expression.operand, table, oldRow, newRow), expression.expected, expression.negated) end if
  if ast.isFunctionExpression(expression) then
    arguments = []
    for each argument in expression.arguments
      arguments = arguments + [replaceTriggerExpression(argument, table, oldRow, newRow)]
    end for
    return ast.functionExpression(expression.name, arguments, expression.distinct)
  end if
  if ast.isSubqueryExpression(expression) or ast.isExistsExpression(expression) or ast.isInSubqueryExpression(expression) or ast.isWindowExpression(expression) then return fail(UNSUPPORTED_SQL, "replaceTriggerExpression", "subqueries and windows are not supported inside M45 trigger bodies") end if
  return fail(BINDING_ERROR, "replaceTriggerExpression", "unsupported trigger expression")
end function

// Implements replace trigger returning for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function replaceTriggerReturning(items, table, oldRow, newRow)
  output = []
  for each item in items
    output = output + [ast.SelectItem(replaceTriggerExpression(item.expression, table, oldRow, newRow), item.alias)]
  end for
  return output
end function

// Implements replace trigger statement for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function replaceTriggerStatement(statement, table, oldRow, newRow)
  if ast.isInsertStatement(statement) then
    rows = []
    for each sourceRow in statement.rows
      row = []
      for each expression in sourceRow
        row = row + [replaceTriggerExpression(expression, table, oldRow, newRow)]
      end for
      rows = rows + [row]
    end for
    if statement.sourceQuery is not void then return fail(UNSUPPORTED_SQL, "replaceTriggerStatement", "INSERT SELECT is not supported inside M45 trigger bodies") end if
    assignments = []
    for each assignment in statement.conflictAssignments
      assignments = assignments + [ast.Assignment(assignment.column, replaceTriggerExpression(assignment.expression, table, oldRow, newRow))]
    end for
    conflictWhere = void
    if statement.conflictWhere is not void then conflictWhere = replaceTriggerExpression(statement.conflictWhere, table, oldRow, newRow) end if
    return ast.InsertStatement(statement.tableName, statement.columns, rows, void, statement.conflictTarget, statement.conflictAction, assignments, conflictWhere, replaceTriggerReturning(statement.returning, table, oldRow, newRow))
  end if
  if ast.isUpdateStatement(statement) then
    assignments = []
    for each assignment in statement.assignments
      assignments = assignments + [ast.Assignment(assignment.column, replaceTriggerExpression(assignment.expression, table, oldRow, newRow))]
    end for
    whereExpression = void
    if statement.whereExpression is not void then whereExpression = replaceTriggerExpression(statement.whereExpression, table, oldRow, newRow) end if
    return ast.UpdateStatement(statement.tableName, assignments, whereExpression, replaceTriggerReturning(statement.returning, table, oldRow, newRow))
  end if
  if ast.isDeleteStatement(statement) then
    whereExpression = void
    if statement.whereExpression is not void then whereExpression = replaceTriggerExpression(statement.whereExpression, table, oldRow, newRow) end if
    return ast.DeleteStatement(statement.tableName, whereExpression, replaceTriggerReturning(statement.returning, table, oldRow, newRow))
  end if
  return fail(UNSUPPORTED_SQL, "replaceTriggerStatement", "trigger body must be INSERT, UPDATE or DELETE")
end function

// Resolves one qualified MERGE source/target column for a concrete source row.
function replaceMergeColumn(expression, statement, sourceTable, sourceRow)
  sourceName = statement.sourceAlias
  if sourceName is void then sourceName = splitObjectName(statement.sourceTable)[1] end if
  targetName = statement.targetAlias
  if targetName is void then targetName = splitObjectName(statement.targetTable)[1] end if
  if expression.qualifier == sourceName or expression.qualifier == statement.sourceTable then
    columnIndex = binder.findColumnIndex(sourceTable, expression.name)
    if columnIndex < 0 then return fail(BINDING_ERROR, "merge", "unknown source column " + expression.name) end if
    return ast.typedLiteralExpression(sourceRow[columnIndex])
  end if
  if expression.qualifier == targetName or expression.qualifier == statement.targetTable then return ast.columnExpression(void, expression.name) end if
  if expression.qualifier is void then return expression end if
  return fail(BINDING_ERROR, "merge", "unknown MERGE qualifier " + expression.qualifier)
end function

// Rewrites a MERGE expression for one source row while leaving target columns bindable.
function replaceMergeExpression(expression, statement, sourceTable, sourceRow)
  if ast.isColumnExpression(expression) then return replaceMergeColumn(expression, statement, sourceTable, sourceRow) end if
  if ast.isLiteralExpression(expression) or ast.isTypedLiteralExpression(expression) or ast.isParameterExpression(expression) then return expression end if
  if ast.isUnaryExpression(expression) then return ast.unaryExpression(expression.operator, replaceMergeExpression(expression.operand, statement, sourceTable, sourceRow)) end if
  if ast.isBinaryExpression(expression) then return ast.binaryExpression(expression.operator, replaceMergeExpression(expression.left, statement, sourceTable, sourceRow), replaceMergeExpression(expression.right, statement, sourceTable, sourceRow)) end if
  if ast.isIsNullExpression(expression) then return ast.isNullExpression(replaceMergeExpression(expression.operand, statement, sourceTable, sourceRow), expression.negated) end if
  if ast.isCaseExpression(expression) then
    branches = []
    for each branch in expression.branches
      branches = branches + [ast.caseBranch(replaceMergeExpression(branch.condition, statement, sourceTable, sourceRow), replaceMergeExpression(branch.result, statement, sourceTable, sourceRow))]
    end for
    elseExpression = void
    if expression.elseExpression is not void then elseExpression = replaceMergeExpression(expression.elseExpression, statement, sourceTable, sourceRow) end if
    return ast.caseExpression(branches, elseExpression)
  end if
  if ast.isCastExpression(expression) then return ast.castExpression(replaceMergeExpression(expression.operand, statement, sourceTable, sourceRow), expression.targetType) end if
  if ast.isInExpression(expression) then
    candidates = []
    for each candidate in expression.values
      candidates = candidates + [replaceMergeExpression(candidate, statement, sourceTable, sourceRow)]
    end for
    return ast.inExpression(replaceMergeExpression(expression.operand, statement, sourceTable, sourceRow), candidates, expression.negated)
  end if
  if ast.isBetweenExpression(expression) then return ast.betweenExpression(replaceMergeExpression(expression.operand, statement, sourceTable, sourceRow), replaceMergeExpression(expression.lower, statement, sourceTable, sourceRow), replaceMergeExpression(expression.upper, statement, sourceTable, sourceRow), expression.negated) end if
  if ast.isTruthTestExpression(expression) then return ast.truthTestExpression(replaceMergeExpression(expression.operand, statement, sourceTable, sourceRow), expression.expected, expression.negated) end if
  if ast.isFunctionExpression(expression) then
    arguments = []
    for each argument in expression.arguments
      arguments = arguments + [replaceMergeExpression(argument, statement, sourceTable, sourceRow)]
    end for
    return ast.functionExpression(expression.name, arguments, expression.distinct)
  end if
  return fail(UNSUPPORTED_SQL, "merge", "MERGE actions do not support stars, subqueries, or windows")
end function

// Replaces an unqualified procedure parameter reference with its invocation value.
function replaceProcedureParameter(expression, parameterNames, parameterValues)
  if expression.qualifier is not void then return expression end if
  if len(parameterNames) > 0 then
    for index = 0 to len(parameterNames) - 1
      if parameterNames[index] == expression.name then return ast.typedLiteralExpression(parameterValues[index]) end if
    end for
  end if
  return expression
end function

// Substitutes named procedure inputs throughout a supported DML expression.
function replaceProcedureExpression(expression, parameterNames, parameterValues)
  if ast.isColumnExpression(expression) then return replaceProcedureParameter(expression, parameterNames, parameterValues) end if
  if ast.isLiteralExpression(expression) or ast.isTypedLiteralExpression(expression) or ast.isStarExpression(expression) or ast.isParameterExpression(expression) then return expression end if
  if ast.isUnaryExpression(expression) then return ast.unaryExpression(expression.operator, replaceProcedureExpression(expression.operand, parameterNames, parameterValues)) end if
  if ast.isBinaryExpression(expression) then return ast.binaryExpression(expression.operator, replaceProcedureExpression(expression.left, parameterNames, parameterValues), replaceProcedureExpression(expression.right, parameterNames, parameterValues)) end if
  if ast.isIsNullExpression(expression) then return ast.isNullExpression(replaceProcedureExpression(expression.operand, parameterNames, parameterValues), expression.negated) end if
  if ast.isCaseExpression(expression) then
    branches = []
    for each branch in expression.branches
      branches = branches + [ast.caseBranch(replaceProcedureExpression(branch.condition, parameterNames, parameterValues), replaceProcedureExpression(branch.result, parameterNames, parameterValues))]
    end for
    elseExpression = void
    if expression.elseExpression is not void then elseExpression = replaceProcedureExpression(expression.elseExpression, parameterNames, parameterValues) end if
    return ast.caseExpression(branches, elseExpression)
  end if
  if ast.isCastExpression(expression) then return ast.castExpression(replaceProcedureExpression(expression.operand, parameterNames, parameterValues), expression.targetType) end if
  if ast.isInExpression(expression) then
    candidates = []
    for each candidate in expression.values
      candidates = candidates + [replaceProcedureExpression(candidate, parameterNames, parameterValues)]
    end for
    return ast.inExpression(replaceProcedureExpression(expression.operand, parameterNames, parameterValues), candidates, expression.negated)
  end if
  if ast.isBetweenExpression(expression) then return ast.betweenExpression(replaceProcedureExpression(expression.operand, parameterNames, parameterValues), replaceProcedureExpression(expression.lower, parameterNames, parameterValues), replaceProcedureExpression(expression.upper, parameterNames, parameterValues), expression.negated) end if
  if ast.isTruthTestExpression(expression) then return ast.truthTestExpression(replaceProcedureExpression(expression.operand, parameterNames, parameterValues), expression.expected, expression.negated) end if
  if ast.isFunctionExpression(expression) then
    arguments = []
    for each argument in expression.arguments
      arguments = arguments + [replaceProcedureExpression(argument, parameterNames, parameterValues)]
    end for
    return ast.functionExpression(expression.name, arguments, expression.distinct)
  end if
  return fail(UNSUPPORTED_SQL, "procedure", "procedure parameters are not supported inside subqueries or windows")
end function

// Substitutes procedure parameters in one persisted INSERT, UPDATE, or DELETE body.
function replaceProcedureStatement(statement, parameterNames, parameterValues)
  if ast.isInsertStatement(statement) then
    rows = []
    for each sourceRow in statement.rows
      row = []
      for each expression in sourceRow
        row = row + [replaceProcedureExpression(expression, parameterNames, parameterValues)]
      end for
      rows = rows + [row]
    end for
    return ast.InsertStatement(statement.tableName, statement.columns, rows, void, statement.conflictTarget, statement.conflictAction, [], void, [])
  end if
  if ast.isUpdateStatement(statement) then
    assignments = []
    for each assignment in statement.assignments
      assignments = assignments + [ast.Assignment(assignment.column, replaceProcedureExpression(assignment.expression, parameterNames, parameterValues))]
    end for
    whereExpression = void
    if statement.whereExpression is not void then whereExpression = replaceProcedureExpression(statement.whereExpression, parameterNames, parameterValues) end if
    return ast.UpdateStatement(statement.tableName, assignments, whereExpression, [])
  end if
  if ast.isDeleteStatement(statement) then
    whereExpression = void
    if statement.whereExpression is not void then whereExpression = replaceProcedureExpression(statement.whereExpression, parameterNames, parameterValues) end if
    return ast.DeleteStatement(statement.tableName, whereExpression, [])
  end if
  return fail(CORRUPT_DATA, "procedure", "stored procedure body is not supported DML")
end function

// Implements update touches trigger column for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function updateTouchesTriggerColumn(bound, trigger)
  if trigger.targetColumn == "" then return true end if
  targetIndex = binder.findColumnIndex(bound.table, trigger.targetColumn)
  if targetIndex < 0 then return false end if
  for each assignment in bound.assignments
    if assignment.columnIndex == targetIndex then return true end if
  end for
  return false
end function

// Executes trigger body using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// May mutate supplied state as documented by the operation name.
function executeTriggerBody(engine, trigger, sourceTable, oldRow, newRow, pageTransaction)
  if engine.triggerDepth >= 8 then return fail(CONSTRAINT_VIOLATION, "executeTriggerBody", "maximum trigger recursion depth exceeded") end if
  parsed = parser.parseSql(trigger.expressionSql)
  if len(parsed) != 1 then return fail(CORRUPT_DATA, "executeTriggerBody", "trigger body must contain exactly one statement") end if
  replaced = replaceTriggerStatement(parsed[0], sourceTable, oldRow, newRow)
  authorized = authorizeStatement(engine, replaced)
  materialized = materializeDmlStatement(engine, replaced, pageTransaction)
  bound = bind(materialized, engine)
  materializeInsertSelect(engine, bound, pageTransaction)
  engine.triggerDepth = engine.triggerDepth + 1
  result = try(runBoundDml(engine, bound, pageTransaction))
  if typeof(result) != "error" then result = try(fireTriggers(engine, bound, result, pageTransaction)) end if
  engine.triggerDepth = engine.triggerDepth - 1
  return result
end function

// Implements fire triggers for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function fireTriggers(engine, bound, result, pageTransaction)
  eventType = triggerEventCode(bound)
  if eventType == 0 or not dml.isDmlResult(result) then return result end if
  state = schema_history.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
  triggerList = schema_history.triggersForTable(state, bound.table.tableId, eventType)
  if len(triggerList) == 0 then return result end if
  for each timing in [schema_history.TRIGGER_BEFORE, schema_history.TRIGGER_AFTER]
    for each trigger in triggerList
      if trigger.timing != timing then continue end if
      if eventType == schema_history.TRIGGER_UPDATE and not updateTouchesTriggerColumn(bound, trigger) then continue end if
      if eventType == schema_history.TRIGGER_INSERT then
        for each newRow in result.newRows
          triggerResult = try(executeTriggerBody(engine, trigger, bound.table, void, newRow, pageTransaction))
          if typeof(triggerResult) == "error" then return triggerResult end if
        end for
      else if eventType == schema_history.TRIGGER_DELETE then
        for each oldRow in result.oldRows
          triggerResult = try(executeTriggerBody(engine, trigger, bound.table, oldRow, void, pageTransaction))
          if typeof(triggerResult) == "error" then return triggerResult end if
        end for
      else
        count = len(result.newRows)
        if len(result.oldRows) < count then count = len(result.oldRows) end if
        if count > 0 then
          for index = 0 to count - 1
            triggerResult = try(executeTriggerBody(engine, trigger, bound.table, result.oldRows[index], result.newRows[index], pageTransaction))
            if typeof(triggerResult) == "error" then return triggerResult end if
          end for
        end if
      end if
    end for
  end for
  return result
end function

// Returns whether the persisted statement formatter preserves the entire DML body.
function persistedProgramBodySupported(statement)
  if ast.isInsertStatement(statement) then
    return statement.sourceQuery is void and statement.conflictAction == ast.CONFLICT_NONE and len(statement.returning) == 0
  end if
  if ast.isUpdateStatement(statement) or ast.isDeleteStatement(statement) then return len(statement.returning) == 0 end if
  return false
end function

// Executes trigger DDL using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeTriggerDdl(engine, statement)
  if engine.explicitTransaction then return fail(UNSUPPORTED_SQL, "executeTriggerDdl", "trigger DDL is autocommit-only in M45") end if
  database = engine.database.catalogHandle
  databaseId = database.metadata.databaseId
  if ast.isCreateTriggerStatement(statement) then
    requireObjectSchema(engine, statement.name, "executeTriggerDdl")
    if not persistedProgramBodySupported(statement.body) then return fail(UNSUPPORTED_SQL, "executeTriggerDdl", "trigger body must be one VALUES INSERT, UPDATE, or DELETE without RETURNING or ON CONFLICT") end if
    table = catalog.findTable(database, statement.tableName)
    if table is void then return fail(BINDING_ERROR, "executeTriggerDdl", "unknown trigger table " + statement.tableName) end if
    eventType = schema_history.TRIGGER_INSERT
    if statement.eventType == "UPDATE" then eventType = schema_history.TRIGGER_UPDATE else if statement.eventType == "DELETE" then eventType = schema_history.TRIGGER_DELETE end if
    if statement.targetColumn != "" and binder.findColumnIndex(table, statement.targetColumn) < 0 then return fail(BINDING_ERROR, "executeTriggerDdl", "unknown trigger target column " + statement.targetColumn) end if
    // Parse/bind the body once at CREATE time. OLD/NEW references are replaced
    // by typed literals at execution time and therefore intentionally remain
    // unresolved here; the target statement itself is validated after a sample
    // replacement in the acceptance suite.
    timing = schema_history.TRIGGER_AFTER
    if statement.timing == "BEFORE" then timing = schema_history.TRIGGER_BEFORE end if
    created = schema_history.putTrigger(engine.database.path, databaseId, statement.name, table.tableId, timing, eventType, statement.targetColumn, ast.formatStatement(statement.body), statement.ifNotExists)
    return commandResult("CREATE TRIGGER", 0, created.name)
  end if
  if ast.isDropTriggerStatement(statement) then
    dropped = schema_history.dropTrigger(engine.database.path, databaseId, statement.name, statement.ifExists)
    count = 0
    if dropped then count = 1 end if
    return commandResult("DROP TRIGGER", count, statement.name)
  end if
  if ast.isAlterTriggerStatement(statement) then
    schema_history.setTriggerEnabled(engine.database.path, databaseId, statement.name, statement.enabled)
    command = "DISABLE TRIGGER"
    if statement.enabled then command = "ENABLE TRIGGER" end if
    return commandResult(command, 0, statement.name)
  end if
  return fail(BINDING_ERROR, "executeTriggerDdl", "unsupported trigger DDL")
end function

// Executes sequence DDL using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeSequenceDdl(engine, statement)
  if engine.explicitTransaction then return fail(UNSUPPORTED_SQL, "executeSequenceDdl", "sequence DDL is autocommit-only in M45") end if
  database = engine.database.catalogHandle
  databaseId = database.metadata.databaseId
  if ast.isCreateSequenceStatement(statement) then
    requireObjectSchema(engine, statement.name, "executeSequenceDdl")
    created = schema_history.putSequence(engine.database.path, databaseId, statement.name, statement.startValue, statement.incrementValue, statement.minimumValue, statement.maximumValue, statement.cycle, statement.ifNotExists)
    return commandResult("CREATE SEQUENCE", 0, created.name)
  end if
  if ast.isDropSequenceStatement(statement) then
    dropped = schema_history.dropSequence(engine.database.path, databaseId, statement.name, statement.ifExists)
    count = 0
    if dropped then count = 1 end if
    return commandResult("DROP SEQUENCE", count, statement.name)
  end if
  return fail(BINDING_ERROR, "executeSequenceDdl", "unsupported sequence DDL")
end function

// Flattens named procedure inputs and their exact SQL types into durable metadata.
function encodeProcedureParameters(parameters)
  encoded = [PROCEDURE_PARAMETER_METADATA_V1]
  names = []
  for each parameter in parameters
    for each existing in names
      if existing == parameter.name then return fail(BINDING_ERROR, "procedureParameters", "duplicate procedure parameter " + parameter.name) end if
    end for
    typeInfo = types.fromTypeName(parameter.typeName, true)
    names = names + [parameter.name]
    encoded = encoded + [parameter.name, parameter.typeName.name, "" + parameter.typeName.length, "" + parameter.typeName.precision, "" + parameter.typeName.scale]
  end for
  return encoded
end function

// Decodes ordered parameter names while accepting the pre-metadata representation.
function decodeProcedureParameterNames(encoded)
  if len(encoded) == 0 or encoded[0] != PROCEDURE_PARAMETER_METADATA_V1 then return encoded end if
  if (len(encoded) - 1) % 5 != 0 then return fail(CORRUPT_DATA, "procedureParameters", "stored procedure parameter metadata is malformed") end if
  names = []
  index = 1
  while index < len(encoded)
    names = names + [encoded[index]]
    index = index + 5
  end while
  return names
end function

// Reconstructs one declared SQL parameter type from flattened durable metadata.
function decodeProcedureParameterType(encoded, parameterIndex)
  if len(encoded) == 0 or encoded[0] != PROCEDURE_PARAMETER_METADATA_V1 then return void end if
  offset = 1 + parameterIndex * 5
  if offset + 4 >= len(encoded) then return fail(CORRUPT_DATA, "procedureParameters", "stored procedure parameter index is invalid") end if
  lengthValue = toNumber(encoded[offset + 2])
  precisionValue = toNumber(encoded[offset + 3])
  scaleValue = toNumber(encoded[offset + 4])
  if typeof(lengthValue) != "int" or typeof(precisionValue) != "int" or typeof(scaleValue) != "int" then return fail(CORRUPT_DATA, "procedureParameters", "stored procedure parameter type is malformed") end if
  return types.fromTypeName(ast.typeName(encoded[offset + 1], lengthValue, precisionValue, scaleValue), true)
end function

// Creates, replaces, or drops a durable single-statement stored procedure.
function executeProcedureDdl(engine, statement)
  if engine.explicitTransaction then return fail(UNSUPPORTED_SQL, "executeProcedureDdl", "procedure DDL is autocommit-only") end if
  databaseId = engine.database.catalogHandle.metadata.databaseId
  if ast.isCreateProcedureStatement(statement) then
    requireObjectSchema(engine, statement.name, "executeProcedureDdl")
    if not persistedProgramBodySupported(statement.body) then return fail(UNSUPPORTED_SQL, "executeProcedureDdl", "procedure body must be one VALUES INSERT, UPDATE, or DELETE without RETURNING or ON CONFLICT") end if
    parameterMetadata = encodeProcedureParameters(statement.parameters)
    saved = schema_history.putProcedure(engine.database.path, databaseId, statement.name, ast.formatStatement(statement.body), parameterMetadata, statement.replace)
    return commandResult("CREATE PROCEDURE", 0, statement.name)
  end if
  if ast.isDropProcedureStatement(statement) then
    dropped = schema_history.dropProcedure(engine.database.path, databaseId, statement.name, statement.ifExists)
    count = 0
    if dropped then count = 1 end if
    return commandResult("DROP PROCEDURE", count, statement.name)
  end if
  return fail(BINDING_ERROR, "executeProcedureDdl", "unsupported procedure DDL")
end function

// Evaluates CALL arguments, substitutes named inputs, and executes the persisted DML body.
function executeCall(engine, statement)
  state = schema_history.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
  procedure = schema_history.findProcedure(state, statement.name)
  if procedure is void then return fail(BINDING_ERROR, "call", "procedure not found: " + statement.name) end if
  parameterNames = decodeProcedureParameterNames(procedure.columnNames)
  if len(statement.arguments) != len(parameterNames) then return fail(BINDING_ERROR, "call", "procedure argument count mismatch") end if
  parameterValues = []
  if len(statement.arguments) > 0 then
    for argumentIndex = 0 to len(statement.arguments) - 1
      argument = statement.arguments[argumentIndex]
      materialized = materializeExpression(engine, argument, void, false)
      boundArgument = binder.bindExpression(materialized, void, void)
      argumentValue = expressions.evaluate(boundArgument, expressions.rowContext([]))
      parameterType = decodeProcedureParameterType(procedure.columnNames, argumentIndex)
      if parameterType is not void then argumentValue = values.convert(argumentValue, parameterType) end if
      parameterValues = parameterValues + [argumentValue]
    end for
  end if
  parsed = parser.parseSql(procedure.sqlText)
  if len(parsed) != 1 then return fail(CORRUPT_DATA, "call", "procedure body is not one statement") end if
  body = replaceProcedureStatement(parsed[0], parameterNames, parameterValues)
  authorizeStatement(engine, body)
  result = executeStatementInner(engine, body)
  result.command = "CALL"
  result.message = statement.name
  return result
end function

// Rebuilds only indexes whose table schema changed in one autocommit DDL.
// Unrelated tables remain byte-for-byte untouched; the durable dirty marker
// still triggers the conservative all-index repair after a rebuild failure.
function rebuildIndexesForDdl(engine, bound, statement)
  target = void
  if ast.isCreateTableStatement(statement) then
    target = catalog.findTable(engine.database.catalogHandle, statement.name)
  else if ast.isCreateIndexStatement(statement) or ast.isAlterTableStatement(statement) then
    if bound.table is not void then target = catalog.findTableById(engine.database.catalogHandle, bound.table.tableId) end if
  end if
  if target is void then return 0 end if
  return dml.rebuildIndexesForTable(engine.database, target)
end function

// Executes DDL using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function executeDdl(engine, statement)
  if ast.isCreateTableStatement(statement) then
    requireObjectSchema(engine, statement.name, "executeDdl")
    state = schema_history.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
    if schema_history.findView(state, statement.name) is not void then return fail(BINDING_ERROR, "executeDdl", "view already exists with name " + statement.name) end if
  end if
  if ast.isCreateIndexStatement(statement) then requireObjectSchema(engine, statement.name, "executeDdl") end if
  bound = bind(statement, engine)
  if binder.isBoundAlterTable(bound) and bound.table is void then return commandResult(bound.command, 0, "object did not exist") end if
  validateAlterTableRows(engine, bound)
  if binder.isBoundAlterTable(bound) then dml.validateExistingConstraint(engine.database, bound) end if
  if engine.explicitTransaction then
    if not engine.trusted then return fail(UNSUPPORTED_SQL, "executeDdl", "authenticated DDL is autocommit-only in M21") end if
    ddlTransaction = ensureExplicitDdl(engine)
    command = stageDdl(ddlTransaction, bound)
    return commandResult(command, 0, "DDL staged")
  end if
  droppedTable = void
  if ast.isDropTableStatement(statement) then droppedTable = catalog.findTable(engine.database.catalogHandle, statement.name) end if
  ddlTransaction = schema_history.begin(engine.database.catalogHandle)
  staged = try(stageDdl(ddlTransaction, bound))
  if typeof(staged) == "error" then schema_history.rollback(ddlTransaction); return staged end if
  dml.markIndexesDirty(engine.database)
  committed = try(schema_history.commit(ddlTransaction))
  if typeof(committed) == "error" then return committed end if
  rebuilt = try(rebuildIndexesForDdl(engine, bound, statement))
  if typeof(rebuilt) != "error" then dml.clearIndexesDirty(engine.database) end if
  if not engine.trusted and ast.isCreateTableStatement(statement) then
    createdTable = catalog.findTable(engine.database.catalogHandle, statement.name)
    if createdTable is not void then catalog.grantTableOwner(engine.database.catalogHandle, createdTable.tableId, engine.principalId) end if
  end if
  if ast.isDropTableStatement(statement) and droppedTable is not void then
    ignoredSecurityCleanup = try(catalog.removeTablePrivileges(engine.database.catalogHandle, droppedTable.tableId))
  end if
  return commandResult(staged, 0, "DDL committed")
end function

// Runs bound DML using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function runBoundDml(engine, bound, pageTransaction)
  if binder.isBoundInsert(bound) then return dml.insert(engine.database, bound, pageTransaction) end if
  if binder.isBoundUpdate(bound) then return dml.update(engine.database, bound, pageTransaction) end if
  if binder.isBoundDelete(bound) then return dml.delete(engine.database, bound, pageTransaction) end if
  if binder.isBoundTruncate(bound) then return dml.truncate(engine.database, bound, pageTransaction) end if
  return fail(BINDING_ERROR, "runBoundDml", "unsupported bound DML statement")
end function

// Implements DML command for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function dmlCommand(bound)
  if binder.isBoundInsert(bound) then return "INSERT" end if
  if binder.isBoundUpdate(bound) then return "UPDATE" end if
  if binder.isBoundDelete(bound) then return "DELETE" end if
  if binder.isBoundTruncate(bound) then return "TRUNCATE" end if
  return "DML"
end function

// Implements commit page transaction for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function commitPageTransaction(engine, pageTransaction, deltaBound, deltaResult)
  changedIds = []
  if transaction.stagedPageCount(pageTransaction) > 0 then dml.markIndexesDirty(engine.database) end if
  commitLsn = transaction.commit(pageTransaction)
  for each change in transaction.committedPages(pageTransaction)
    found = false
    for each existing in changedIds
      if existing == change.fileId then found = true end if
    end for
    if not found then changedIds = changedIds + [change.fileId] end if
  end for
  dml.publishCommitted(engine.database, pageTransaction, commitLsn)
  rebuildError = void
  insertDelta = deltaBound is not void and binder.isBoundInsert(deltaBound) and dml.isDmlResult(deltaResult) and len(changedIds) == 1
  if insertDelta then
    applied = try(dml.applyInsertedIndexes(engine.database, deltaBound.table, deltaResult))
    if typeof(applied) == "error" then rebuildError = applied end if
  else
    for each tableId in changedIds
      table = catalog.findTableById(engine.database.catalogHandle, tableId)
      if table is not void and rebuildError is void then
        rebuilt = try(dml.rebuildIndexesForTable(engine.database, table))
        if typeof(rebuilt) == "error" then rebuildError = rebuilt end if
      end if
    end for
  end if
  if rebuildError is void then dml.clearIndexesDirty(engine.database) end if
  // The heap/WAL commit is already durable. A failed derived-index rebuild leaves
  // the durable dirty marker in place and is repaired before the next index use.
  return commitLsn
end function

// Implements materialize insert select for this module.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function materializeInsertSelect(engine, bound, pageTransaction)
  if not binder.isBoundInsert(bound) or bound.sourceQuery is void then return true end if
  sourceResult = selectRows(engine, bound.sourceQuery, pageTransaction)
  if not isQueryResult(sourceResult) then return fail(INVALID_ARGUMENT, "materializeInsertSelect", "source SELECT must return QueryResult") end if
  sourceRows = sourceResult.rows
  // Build an eager, fixed-size literal snapshot before the target heap changes.
  // This keeps self INSERT SELECT finite and avoids quadratic array growth.
  materialized = array(len(sourceRows))
  if len(sourceRows) > 0 then
    for rowIndex = 0 to len(sourceRows) - 1
      sourceRow = sourceRows[rowIndex]
      boundRow = array(len(sourceRow))
      if len(sourceRow) > 0 then
        for columnIndex = 0 to len(sourceRow) - 1
          boundRow[columnIndex] = expressions.literal(sourceRow[columnIndex], bound.sourceQuery.items[columnIndex].typeInfo)
        end for
      end if
      materialized[rowIndex] = boundRow
    end for
  end if
  bound.rows = materialized
  return true
end function

// Implements returning result for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function returningResult(bound, result)
  if not dml.isDmlResult(result) then return fail(INVALID_ARGUMENT, "returningResult", "result must be DmlResult") end if
  returning = []
  if binder.isBoundInsert(bound) or binder.isBoundUpdate(bound) or binder.isBoundDelete(bound) then returning = bound.returning end if
  if len(returning) == 0 then return commandResult(dmlCommand(bound), result.affectedRows, "DML completed") end if
  columns = []
  for each item in returning
    columns = columns + [item.name]
  end for
  return QueryResult(RESULT_ROWS, dmlCommand(bound), columns, result.rows, result.affectedRows, "")
end function

// Executes DML using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function executeDml(engine, statement)
  if engine.explicitTransaction then
    pageTransaction = ensureExplicitDml(engine)
    materializedStatement = materializeDmlStatement(engine, statement, pageTransaction)
    bound = bind(materializedStatement, engine)
    materializeInsertSelect(engine, bound, pageTransaction)
    result = runBoundDml(engine, bound, pageTransaction)
    fireTriggers(engine, bound, result, pageTransaction)
    if (binder.isBoundInsert(bound) or binder.isBoundUpdate(bound) or binder.isBoundDelete(bound)) and len(bound.returning) > 0 then return returningResult(bound, result) end if
    return commandResult(dmlCommand(bound), result.affectedRows, "DML staged")
  end if
  pageTransaction = database_manager.begin(engine.database, transaction.ISOLATION_SERIALIZABLE, false)
  materializedStatement = try(materializeDmlStatement(engine, statement, pageTransaction))
  if typeof(materializedStatement) == "error" then transaction.rollback(pageTransaction); return materializedStatement end if
  bound = try(bind(materializedStatement, engine))
  if typeof(bound) == "error" then transaction.rollback(pageTransaction); return bound end if
  materialized = try(materializeInsertSelect(engine, bound, pageTransaction))
  if typeof(materialized) == "error" then transaction.rollback(pageTransaction); return materialized end if
  result = try(runBoundDml(engine, bound, pageTransaction))
  if typeof(result) == "error" then transaction.rollback(pageTransaction); return result end if
  triggered = try(fireTriggers(engine, bound, result, pageTransaction))
  if typeof(triggered) == "error" then transaction.rollback(pageTransaction); return triggered end if
  committed = try(commitPageTransaction(engine, pageTransaction, bound, result))
  if typeof(committed) == "error" then return committed end if
  if (binder.isBoundInsert(bound) or binder.isBoundUpdate(bound) or binder.isBoundDelete(bound)) and len(bound.returning) > 0 then return returningResult(bound, result) end if
  return commandResult(dmlCommand(bound), result.affectedRows, "DML committed")
end function

// Executes every MERGE source row against the same transactional target snapshot.
function runMerge(engine, statement, pageTransaction)
  sourceTable = catalog.findTable(engine.database.catalogHandle, statement.sourceTable)
  targetTable = catalog.findTable(engine.database.catalogHandle, statement.targetTable)
  if sourceTable is void then return fail(BINDING_ERROR, "merge", "unknown source table " + statement.sourceTable) end if
  if targetTable is void then return fail(BINDING_ERROR, "merge", "unknown target table " + statement.targetTable) end if
  sourceQuery = ast.SelectStatement(false, [ast.SelectItem(ast.starExpression(void), void)], statement.sourceTable, statement.sourceAlias, [], void, [], void, [], [], -1, 0, [])
  sourceBound = try(binder.bindSelect(materializeSelectStatement(engine, sourceQuery, pageTransaction), engine.database.catalogHandle))
  if typeof(sourceBound) == "error" then return sourceBound end if
  sourceResult = try(selectRows(engine, sourceBound, pageTransaction))
  if typeof(sourceResult) == "error" then return sourceResult end if
  affected = 0
  for each sourceRow in sourceResult.rows
    predicate = replaceMergeExpression(statement.condition, statement, sourceTable, sourceRow)
    matchQuery = ast.SelectStatement(false, [ast.SelectItem(ast.integerLiteral("1"), void)], statement.targetTable, void, [], predicate, [], void, [], [], -1, 0, [])
    matchBound = try(binder.bindSelect(materializeSelectStatement(engine, matchQuery, pageTransaction), engine.database.catalogHandle))
    if typeof(matchBound) == "error" then return matchBound end if
    matches = try(selectRows(engine, matchBound, pageTransaction))
    if typeof(matches) == "error" then return matches end if
    if len(matches.rows) > 0 then
      action = void
      if statement.matchedDelete then
        action = ast.DeleteStatement(statement.targetTable, predicate, [])
      else if len(statement.matchedAssignments) > 0 then
        assignments = []
        for each assignment in statement.matchedAssignments
          assignments = assignments + [ast.Assignment(assignment.column, replaceMergeExpression(assignment.expression, statement, sourceTable, sourceRow))]
        end for
        action = ast.UpdateStatement(statement.targetTable, assignments, predicate, [])
      end if
      if action is not void then
        boundAction = try(bind(materializeDmlStatement(engine, action, pageTransaction), engine))
        if typeof(boundAction) == "error" then return boundAction end if
        actionResult = try(runBoundDml(engine, boundAction, pageTransaction))
        if typeof(actionResult) == "error" then return actionResult end if
        triggered = try(fireTriggers(engine, boundAction, actionResult, pageTransaction))
        if typeof(triggered) == "error" then return triggered end if
        affected = affected + actionResult.affectedRows
      end if
    else if len(statement.insertValues) > 0 then
      row = []
      for each expression in statement.insertValues
        row = row + [replaceMergeExpression(expression, statement, sourceTable, sourceRow)]
      end for
      action = ast.InsertStatement(statement.targetTable, statement.insertColumns, [row], void, [], ast.CONFLICT_NONE, [], void, [])
      boundAction = try(bind(materializeDmlStatement(engine, action, pageTransaction), engine))
      if typeof(boundAction) == "error" then return boundAction end if
      actionResult = try(runBoundDml(engine, boundAction, pageTransaction))
      if typeof(actionResult) == "error" then return actionResult end if
      triggered = try(fireTriggers(engine, boundAction, actionResult, pageTransaction))
      if typeof(triggered) == "error" then return triggered end if
      affected = affected + actionResult.affectedRows
    end if
  end for
  return affected
end function

// Runs MERGE in an existing explicit transaction or creates one atomic implicit transaction.
function executeMerge(engine, statement)
  if engine.explicitTransaction then
    pageTransaction = ensureExplicitDml(engine)
    // MERGE can execute many physical DML actions. Keep those actions atomic
    // even inside a longer user transaction by restoring its exact pre-MERGE
    // page set when any action, constraint, or trigger reports an error. The
    // dollar sign makes this implementation savepoint inaccessible to SQL
    // identifiers, so it cannot collide with a user-managed savepoint.
    statementSavepoint = "__minisql$merge_statement"
    saved = try(transaction.savepoint(pageTransaction, statementSavepoint))
    if typeof(saved) == "error" then return saved end if
    affected = try(runMerge(engine, statement, pageTransaction))
    if typeof(affected) == "error" then
      restored = try(transaction.rollbackToSavepoint(pageTransaction, statementSavepoint))
      if typeof(restored) == "error" then return restored end if
      releasedAfterFailure = try(transaction.releaseSavepoint(pageTransaction, statementSavepoint))
      if typeof(releasedAfterFailure) == "error" then return releasedAfterFailure end if
      return affected
    end if
    released = try(transaction.releaseSavepoint(pageTransaction, statementSavepoint))
    if typeof(released) == "error" then return released end if
    return commandResult("MERGE", affected, "MERGE staged")
  end if
  pageTransaction = database_manager.begin(engine.database, transaction.ISOLATION_SERIALIZABLE, false)
  affected = try(runMerge(engine, statement, pageTransaction))
  if typeof(affected) == "error" then transaction.rollback(pageTransaction); return affected end if
  committed = try(commitPageTransaction(engine, pageTransaction, void, void))
  if typeof(committed) == "error" then return committed end if
  return commandResult("MERGE", affected, "MERGE committed")
end function

// Returns true when a recursive result row is already present by SQL value equality.
function recursiveRowsContain(rows, candidate)
  for each row in rows
    if projection.sameValues(row, candidate) then return true end if
  end for
  return false
end function

// Returns the innermost active delta for a recursive self-reference.
function recursiveWorkingRows(engine, name)
  found = void
  for each frame in engine.recursiveCteFrames
    if frame.name == name then found = frame.rows end if
  end for
  if found is void then return fail(BINDING_ERROR, "recursiveCte", "recursive reference has no active working table: " + name) end if
  return found
end function

// Evaluates anchor rows followed by semi-naive delta iterations until a fixpoint.
// UNION removes rows already seen; UNION ALL preserves bags and therefore relies
// on an empty recursive result to terminate. The depth guard diagnoses runaway SQL.
function evaluateRecursiveQuery(engine, query, pageTransaction)
  anchorResult = selectRows(engine, query.anchor, pageTransaction)
  output = anchorResult.rows
  delta = anchorResult.rows
  iteration = 0
  while len(delta) > 0 and iteration < 10000
    engine.recursiveCteFrames = engine.recursiveCteFrames + [RecursiveCteFrame(query.name, delta)]
    recursiveResult = try(selectRows(engine, query.recursiveTerm, pageTransaction))
    if len(engine.recursiveCteFrames) <= 1 then
      engine.recursiveCteFrames = []
    else
      engine.recursiveCteFrames = slice(engine.recursiveCteFrames, 0, len(engine.recursiveCteFrames) - 1)
    end if
    if typeof(recursiveResult) == "error" then return recursiveResult end if
    nextDelta = []
    for each candidate in recursiveResult.rows
      converted = []
      if len(candidate) != len(query.anchor.items) then return fail(BINDING_ERROR, "recursiveCte", "recursive term output width changed during execution") end if
      if len(candidate) > 0 then
        for index = 0 to len(candidate) - 1
          converted = converted + [values.convert(candidate[index], query.anchor.items[index].typeInfo)]
        end for
      end if
      if query.unionAll or (not recursiveRowsContain(output, converted) and not recursiveRowsContain(nextDelta, converted)) then nextDelta = nextDelta + [converted] end if
    end for
    output = output + nextDelta
    delta = nextDelta
    iteration = iteration + 1
  end while
  if len(delta) > 0 then return fail(UNSUPPORTED_SQL, "recursiveCte", "recursive CTE exceeded 10000 iterations") end if
  return output
end function

// Splits a canonical object name into schema and local name, defaulting to public.
function splitObjectName(name)
  raw = bytes(name)
  dot = -1
  if len(raw) > 0 then
    for index = 0 to len(raw) - 1
      if raw[index] == 46 and dot < 0 then dot = index end if
    end for
  end if
  if dot < 0 then return ["public", name] end if
  return [decode(slice(raw, 0, dot)), decode(slice(raw, dot + 1, len(raw) - dot - 1))]
end function

// Materializes a supported INFORMATION_SCHEMA relation from the live catalog snapshot.
function informationSchemaRows(engine, relationKind)
  rows = []
  state = schema_history.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
  if relationKind == binder.INFORMATION_SCHEMATA then
    for each name in schema_history.schemaNames(state)
      rows = rows + [[values.text(name)]]
    end for
    return rows
  end if
  if relationKind == binder.INFORMATION_TABLES or relationKind == binder.INFORMATION_COLUMNS or relationKind == binder.INFORMATION_TABLE_CONSTRAINTS then
    for each table in engine.database.catalogHandle.catalog.tables
      parts = splitObjectName(table.name)
      if relationKind == binder.INFORMATION_TABLES then
        rows = rows + [[values.text(parts[0]), values.text(parts[1]), values.text("BASE TABLE")]]
      else if relationKind == binder.INFORMATION_COLUMNS then
        if len(table.columns) > 0 then
          for index = 0 to len(table.columns) - 1
            column = table.columns[index]
            nullable = "NO"
            if column.nullable then nullable = "YES" end if
            rows = rows + [[values.text(parts[0]), values.text(parts[1]), values.text(column.name), values.integer(index + 1), values.text(types.kindName(column.typeCode)), values.text(nullable)]]
          end for
        end if
      else
        tableSchema = schema_history.findTableSchema(state, table.tableId)
        if tableSchema is not void then
          for each constraint in tableSchema.constraints
            rows = rows + [[values.text(parts[0]), values.text(parts[1]), values.text(constraint.name), values.text(constraintKindName(constraint.kind))]]
          end for
        end if
      end if
    end for
    if relationKind == binder.INFORMATION_TABLES then
      for each view in state.views
        if not schema_history.isInternalExtensionViewName(view.name) then
          parts = splitObjectName(view.name)
          rows = rows + [[values.text(parts[0]), values.text(parts[1]), values.text("VIEW")]]
        end if
      end for
    end if
    return rows
  end if
  if relationKind == binder.INFORMATION_VIEWS then
    for each view in state.views
      if not schema_history.isInternalExtensionViewName(view.name) then
        parts = splitObjectName(view.name)
        rows = rows + [[values.text(parts[0]), values.text(parts[1]), values.text(view.sqlText)]]
      end if
    end for
    return rows
  end if
  if relationKind == binder.INFORMATION_ROUTINES then
    for each procedure in state.views
      if schema_history.isProcedureMarkerName(procedure.name) then
        parts = splitObjectName(schema_history.procedureObjectName(procedure.name))
        rows = rows + [[values.text(parts[0]), values.text(parts[1]), values.text("PROCEDURE"), values.text(procedure.sqlText)]]
      end if
    end for
    return rows
  end if
  return fail(BINDING_ERROR, "informationSchema", "unsupported metadata relation")
end function

// Scans a catalog table, named query, recursive fixpoint, or recursive delta source.
function scanBoundSource(engine, source, pageTransaction, offset, limit, requiredColumns)
  if source.query is void then return scan.scanTableRangeColumnsCached(engine.database.path, source.table, pageTransaction, offset, limit, requiredColumns, engine.database.readCache) end if
  if binder.isBoundInformationSchemaSource(source.query) then
    metadataRows = informationSchemaRows(engine, source.query.relationKind)
    metadataOutput = []
    for each row in metadataRows
      metadataOutput = metadataOutput + [scan.ScannedRow(void, row)]
    end for
    return metadataOutput
  end if
  if binder.isBoundRecursiveReference(source.query) then
    workingRows = recursiveWorkingRows(engine, source.query.name)
    workingOutput = []
    for each row in workingRows
      workingOutput = workingOutput + [scan.ScannedRow(void, row)]
    end for
    return workingOutput
  end if
  if binder.isBoundRecursiveQuery(source.query) then
    recursiveRows = evaluateRecursiveQuery(engine, source.query, pageTransaction)
    recursiveOutput = []
    for each row in recursiveRows
      recursiveOutput = recursiveOutput + [scan.ScannedRow(void, row)]
    end for
    return recursiveOutput
  end if
  result = selectRows(engine, source.query, pageTransaction)
  output = []
  for each row in result.rows
    output = output + [scan.ScannedRow(void, row)]
  end for
  return output
end function

// Implements joined source for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function joinedSource(engine, bound, pageTransaction, sourceOffset, sourceLimit, requiredColumns)
  if len(bound.sources) == 0 then return [scan.ScannedRow(void, [])] end if
  output = dml.indexRowsForBound(engine.database, bound, pageTransaction)
  if output is void then output = scanBoundSource(engine, bound.sources[0], pageTransaction, sourceOffset, sourceLimit, requiredColumns) end if
  for each boundJoin in bound.joins
    // RIGHT and FULL joins must see every row on the right so unmatched rows can
    // be emitted. Equality-index shortcuts are therefore reserved for inner and
    // left joins until the index executor can also enumerate the complement.
    outerRight = boundJoin.joinType == ast.JOIN_RIGHT or boundJoin.joinType == ast.JOIN_FULL
    usedIndex = false
    joinedRows = []
    if not outerRight then
      for each leftRow in output
        matches = dml.joinIndexRows(engine.database, boundJoin.source, boundJoin.condition, leftRow, pageTransaction)
        if matches is void then
          usedIndex = false
          break
        end if
        usedIndex = true
        joinedRows = joinedRows + join.apply([leftRow], matches, boundJoin)
      end for
    end if
    if usedIndex and not outerRight then
      output = joinedRows
    else
      right = scanBoundSource(engine, boundJoin.source, pageTransaction, 0, -1, void)
      if join.canHash(boundJoin) then
        output = join.applyHash(output, right, boundJoin)
      else
        output = join.apply(output, right, boundJoin)
      end if
    end if
  end for
  return output
end function

// Implements item index for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function itemIndex(bound, expression)
  if len(bound.items) == 0 then return -1 end if
  for index = 0 to len(bound.items) - 1
    if expressions.sameBinding(bound.items[index], expression) then return index end if
  end for
  return -1
end function

// Normalizes compound order using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function normalizeCompoundOrder(rows, bound)
  if len(bound.setOperations) == 0 or len(bound.orderExpressions) == 0 then return rows end if
  output = []
  for each row in rows
    orderValues = []
    for each expression in bound.orderExpressions
      index = itemIndex(bound, expression)
      if index < 0 then return fail(BINDING_ERROR, "normalizeCompoundOrder", "compound ORDER BY must reference an output column") end if
      orderValues = orderValues + [row.values[index]]
    end for
    output = output + [projection.ProjectedRow(row.source, row.values, orderValues)]
  end for
  return output
end function

// Executes a validated scalar, EXISTS, or IN subquery for one outer source row.
function materializeBoundSubquery(engine, expression, bound, row, pageTransaction)
  query = substituteOuterSelect(expression.query, bound.sources, row.values)
  query = materializeSelectStatement(engine, query, pageTransaction)
  nested = binder.bindSelect(query, engine.database.catalogHandle)
  result = selectRows(engine, nested, pageTransaction)
  if expression.subqueryKind == expressions.SUBQUERY_EXISTS then return expressions.literal(values.boolean(len(result.rows) > 0), expression.typeInfo) end if
  if len(nested.items) != 1 then return fail(BINDING_ERROR, "correlatedSubquery", "subquery must return exactly one column") end if
  if expression.subqueryKind == expressions.SUBQUERY_SCALAR then
    if len(result.rows) > 1 then return fail(BINDING_ERROR, "correlatedSubquery", "scalar subquery returned more than one row") end if
    if len(result.rows) == 0 then return expressions.literal(values.nullValue(expression.typeInfo.kind), expression.typeInfo) end if
    return expressions.literal(result.rows[0][0], expression.typeInfo)
  end if
  operand = materializeBoundExpression(engine, expression.operand, bound, row, pageTransaction)
  if len(result.rows) == 0 then return expressions.literal(values.boolean(expression.negated), expression.typeInfo) end if
  candidates = []
  for each resultRow in result.rows
    candidates = candidates + [expressions.literal(resultRow[0], nested.items[0].typeInfo)]
  end for
  predicate = expressions.inPredicate(operand, candidates, expression.negated)
  return expressions.literal(expressions.evaluate(predicate, expressions.rowContext(row.values)), expression.typeInfo)
end function

// Rebuilds a bound expression with every deferred subquery replaced by a literal.
// Reusing the ordinary expression evaluator keeps SQL NULL and boolean semantics centralized.
function materializeBoundExpression(engine, expression, bound, row, pageTransaction)
  if expressions.isBoundSubquery(expression) then return materializeBoundSubquery(engine, expression, bound, row, pageTransaction) end if
  if expressions.isBaseBoundExpression(expression) then
    if expression.kind == expressions.BOUND_LITERAL or expression.kind == expressions.BOUND_COLUMN then return expression end if
    if expression.kind == expressions.BOUND_UNARY then return expressions.unary(expression.operator, materializeBoundExpression(engine, expression.left, bound, row, pageTransaction), expression.typeInfo) end if
    if expression.kind == expressions.BOUND_IS_NULL then return expressions.isNull(materializeBoundExpression(engine, expression.left, bound, row, pageTransaction), expression.operator == "IS NOT NULL") end if
    if expression.kind == expressions.BOUND_BINARY then return expressions.binary(expression.operator, materializeBoundExpression(engine, expression.left, bound, row, pageTransaction), materializeBoundExpression(engine, expression.right, bound, row, pageTransaction), expression.typeInfo) end if
  end if
  if expressions.isBoundCase(expression) then
    branches = []
    for each branch in expression.branches
      branches = branches + [expressions.caseBranch(materializeBoundExpression(engine, branch.condition, bound, row, pageTransaction), materializeBoundExpression(engine, branch.result, bound, row, pageTransaction))]
    end for
    elseExpression = void
    if expression.elseExpression is not void then elseExpression = materializeBoundExpression(engine, expression.elseExpression, bound, row, pageTransaction) end if
    return expressions.caseExpression(branches, elseExpression, expression.typeInfo)
  end if
  if expressions.isBoundCast(expression) then return expressions.castExpression(materializeBoundExpression(engine, expression.operand, bound, row, pageTransaction), expression.targetType) end if
  if expressions.isBoundScalar(expression) then
    arguments = []
    for each argument in expression.arguments
      arguments = arguments + [materializeBoundExpression(engine, argument, bound, row, pageTransaction)]
    end for
    return expressions.scalar(expression.name, arguments, expression.typeInfo)
  end if
  if expressions.isBoundIn(expression) then
    candidates = []
    for each candidate in expression.candidates
      candidates = candidates + [materializeBoundExpression(engine, candidate, bound, row, pageTransaction)]
    end for
    return expressions.inPredicate(materializeBoundExpression(engine, expression.operand, bound, row, pageTransaction), candidates, expression.negated)
  end if
  if expressions.isBoundBetween(expression) then return expressions.betweenPredicate(materializeBoundExpression(engine, expression.operand, bound, row, pageTransaction), materializeBoundExpression(engine, expression.lower, bound, row, pageTransaction), materializeBoundExpression(engine, expression.upper, bound, row, pageTransaction), expression.negated) end if
  if expressions.isBoundTruthTest(expression) then return expressions.truthTest(materializeBoundExpression(engine, expression.operand, bound, row, pageTransaction), expression.expected, expression.negated) end if
  return fail(BINDING_ERROR, "correlatedSubquery", "unsupported outer expression shape")
end function

// Filters and projects a non-grouped row set whose expressions contain subqueries.
function projectSubqueryRows(engine, bound, source, pageTransaction)
  output = []
  for each row in source
    context = expressions.rowContext(row.values)
    passes = true
    if bound.whereExpression is not void then
      predicate = materializeBoundExpression(engine, bound.whereExpression, bound, row, pageTransaction)
      passes = expressions.predicatePasses(predicate, context)
    end if
    if passes then
      selected = []
      for each item in bound.items
        selected = selected + [expressions.evaluate(materializeBoundExpression(engine, item, bound, row, pageTransaction), context)]
      end for
      ordered = []
      for each item in bound.orderExpressions
        ordered = ordered + [expressions.evaluate(materializeBoundExpression(engine, item, bound, row, pageTransaction), context)]
      end for
      output = output + [projection.ProjectedRow(row, selected, ordered)]
    end if
  end for
  return output
end function

// Marks every base-table column referenced by an expression tree. Returning
// false disables projection pushdown for shapes whose dependencies cannot be
// proven locally (notably correlated subqueries).
function collectRequiredColumns(expression, requiredColumns)
  if expression is void then return true end if
  if expressions.isBoundSubquery(expression) then return false end if
  if expressions.isBaseBoundExpression(expression) then
    if expression.kind == expressions.BOUND_LITERAL then return true end if
    if expression.kind == expressions.BOUND_COLUMN then
      if expression.columnIndex < 0 or expression.columnIndex >= len(requiredColumns) then return false end if
      requiredColumns[expression.columnIndex] = true
      return true
    end if
    if expression.kind == expressions.BOUND_UNARY or expression.kind == expressions.BOUND_IS_NULL then return collectRequiredColumns(expression.left, requiredColumns) end if
    if expression.kind == expressions.BOUND_BINARY then return collectRequiredColumns(expression.left, requiredColumns) and collectRequiredColumns(expression.right, requiredColumns) end if
    return false
  end if
  if expressions.isBoundAggregate(expression) then
    if expression.countStar then return true end if
    if not collectRequiredColumns(expression.argument, requiredColumns) then return false end if
    return collectRequiredColumns(expression.separator, requiredColumns)
  end if
  if expressions.isBoundCase(expression) then
    for each branch in expression.branches
      if not collectRequiredColumns(branch.condition, requiredColumns) or not collectRequiredColumns(branch.result, requiredColumns) then return false end if
    end for
    return collectRequiredColumns(expression.elseExpression, requiredColumns)
  end if
  if expressions.isBoundCast(expression) then return collectRequiredColumns(expression.operand, requiredColumns) end if
  if expressions.isBoundScalar(expression) then
    for each argument in expression.arguments
      if not collectRequiredColumns(argument, requiredColumns) then return false end if
    end for
    return true
  end if
  if expressions.isBoundIn(expression) then
    if not collectRequiredColumns(expression.operand, requiredColumns) then return false end if
    for each candidate in expression.candidates
      if not collectRequiredColumns(candidate, requiredColumns) then return false end if
    end for
    return true
  end if
  if expressions.isBoundBetween(expression) then return collectRequiredColumns(expression.operand, requiredColumns) and collectRequiredColumns(expression.lower, requiredColumns) and collectRequiredColumns(expression.upper, requiredColumns) end if
  if expressions.isBoundTruthTest(expression) then return collectRequiredColumns(expression.operand, requiredColumns) end if
  if expressions.isBoundWindow(expression) then
    for each argument in expression.arguments
      if not collectRequiredColumns(argument, requiredColumns) then return false end if
    end for
    for each item in expression.partitionBy
      if not collectRequiredColumns(item, requiredColumns) then return false end if
    end for
    for each item in expression.orderBy
      if not collectRequiredColumns(item, requiredColumns) then return false end if
    end for
    return true
  end if
  return false
end function

// Computes a stable source-column mask for a one-table SELECT. Join column
// indexes span multiple sources, and nested queries own separate bindings, so
// those query forms deliberately retain complete row materialization.
function selectRequiredColumns(bound)
  if len(bound.sources) != 1 or len(bound.joins) != 0 or bound.sources[0].query is not void or len(bound.setOperations) != 0 then return void end if
  requiredColumns = array(len(bound.sources[0].table.columns))
  if len(requiredColumns) > 0 then
    for index = 0 to len(requiredColumns) - 1
      requiredColumns[index] = false
    end for
  end if
  for each item in bound.items
    if not collectRequiredColumns(item, requiredColumns) then return void end if
  end for
  if not collectRequiredColumns(bound.whereExpression, requiredColumns) then return void end if
  for each item in bound.groupExpressions
    if not collectRequiredColumns(item, requiredColumns) then return void end if
  end for
  if not collectRequiredColumns(bound.havingExpression, requiredColumns) then return void end if
  for each item in bound.orderExpressions
    if not collectRequiredColumns(item, requiredColumns) then return void end if
  end for
  return requiredColumns
end function

// Implements select projected for this module.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function selectProjected(engine, bound, pageTransaction)
  // A single unordered, unfiltered source preserves physical row order. Apply
  // LIMIT/OFFSET while scanning that source so rows outside the requested page
  // are neither decoded nor retained. Complex queries keep the full pipeline
  // because joins, predicates, grouping, DISTINCT and ordering can change which
  // source rows belong to the final page.
  sourceOffset = 0
  sourceLimit = -1
  resultOffset = bound.statement.offset
  rangeEligible = len(bound.sources) == 1 and len(bound.joins) == 0 and bound.sources[0].query is void
  rangeEligible = rangeEligible and bound.whereExpression is void and not bound.aggregateQuery and not bound.windowQuery
  rangeEligible = rangeEligible and not bound.statement.distinct and len(bound.setOperations) == 0 and len(bound.statement.orderBy) == 0
  if rangeEligible and (bound.statement.offset > 0 or bound.statement.limit >= 0) then
    sourceOffset = bound.statement.offset
    sourceLimit = bound.statement.limit
    resultOffset = 0
  end if
  requiredColumns = selectRequiredColumns(bound)
  source = joinedSource(engine, bound, pageTransaction, sourceOffset, sourceLimit, requiredColumns)
  projected = []
  hasSubqueries = expressions.containsSubqueryList(bound.items) or expressions.containsSubquery(bound.whereExpression) or expressions.containsSubqueryList(bound.orderExpressions)
  if hasSubqueries then
    projected = projectSubqueryRows(engine, bound, source, pageTransaction)
  else if bound.aggregateQuery then
    filtered = filter.apply(source, bound.whereExpression)
    projected = aggregate.project(filtered, bound.items, bound.groupExpressions, bound.havingExpression, bound.orderExpressions)
  else if bound.windowQuery then
    filtered = filter.apply(source, bound.whereExpression)
    projected = projection.applyWindows(filtered, bound.items, bound.orderExpressions)
  else
    filtered = filter.apply(source, bound.whereExpression)
    projected = projection.apply(filtered, bound.items, bound.orderExpressions)
  end if
  if bound.statement.distinct then projected = projection.distinct(projected) end if
  for each operation in bound.setOperations
    right = selectProjected(engine, operation.query, pageTransaction)
    projected = aggregate.setOperation(projected, right, operation.operator, operation.all)
  end for
  projected = normalizeCompoundOrder(projected, bound)
  temporaryRoot = file_api.joinPath(engine.database.path, "tmp")
  projected = sort.sortProjectedWithSpill(projected, bound.statement.orderBy, temporaryRoot, SORT_SPILL_THRESHOLD)
  projected = projection.sliceRows(projected, resultOffset, bound.statement.limit)
  return projected
end function

// Implements select rows for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function selectRows(engine, bound, pageTransaction)
  projected = selectProjected(engine, bound, pageTransaction)
  rows = array(len(projected))
  if len(projected) > 0 then
    for index = 0 to len(projected) - 1
      rows[index] = projected[index].values
    end for
  end if
  return rowResult(bound.itemNames, rows)
end function

// Loads statistics using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function loadStatistics(engine)
  return statistics.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
end function

// Implements analyze table for this module.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function analyzeTable(engine, state, table)
  rows = scan.scanTable(engine.database.path, table, void)
  tableFile = paged_file.open(catalog.tableFilePath(engine.database.path, table.tableId))
  pageCount = tableFile.pageCount
  paged_file.close(tableFile)
  return statistics.replaceTable(state, statistics.analyzeTable(table, rows, pageCount))
end function

// Executes analyze using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeAnalyze(engine, statement)
  if engine.explicitTransaction then return fail(UNSUPPORTED_SQL, "analyze", "ANALYZE is an autocommit maintenance command") end if
  state = loadStatistics(engine)
  analyzed = 0
  if statement.tableName is void then
    for each table in engine.database.catalogHandle.catalog.tables
      analyzeTable(engine, state, table)
      analyzed = analyzed + 1
    end for
  else
    table = catalog.findTable(engine.database.catalogHandle, statement.tableName)
    if table is void then return fail(BINDING_ERROR, "analyze", "unknown table " + statement.tableName) end if
    analyzeTable(engine, state, table)
    analyzed = 1
  end if
  statistics.save(engine.database.path, state)
  return commandResult("ANALYZE", analyzed, "statistics generation " + state.generation)
end function

// Implements explain bound for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function explainBound(bound)
  logical = logical_plan.build(bound)
  physical = physical_plan.fromLogical(logical)
  return physical_plan.render(physical)
end function

// Executes explain using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function executeExplain(engine, statement)
  if not ast.isSelectStatement(statement.statement) then return fail(UNSUPPORTED_SQL, "explain", "M17 EXPLAIN supports SELECT") end if
  if engine.explicitTransaction and engine.transactionMode == MODE_DDL then return fail(UNSUPPORTED_SQL, "explain", "EXPLAIN after staged DDL is not supported") end if
  pageTransaction = void
  if engine.explicitTransaction and engine.transactionMode == MODE_DML then pageTransaction = engine.pageTransaction end if
  materializedStatement = materializeSelectStatement(engine, statement.statement, pageTransaction)
  bound = binder.bindSelect(materializedStatement, engine.database.catalogHandle)
  state = loadStatistics(engine)
  lines = optimizer.explain(bound, state)
  access = try(dml.indexAccessDescription(engine.database, bound))
  if typeof(access) != "error" and access is not void then lines = [access] + lines end if
  if statement.analyze then
    actual = selectRows(engine, bound, pageTransaction)
    lines = lines + ["actual rows=" + len(actual.rows)]
  end if
  rows = []
  for each line in lines
    rows = rows + [[values.text(line)]]
  end for
  return rowResult(["QUERY PLAN"], rows)
end function

// Executes select using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeSelect(engine, statement)
  if engine.explicitTransaction and engine.failed then return fail(TRANSACTION_STATE, "select", "transaction is failed; ROLLBACK required") end if
  if engine.explicitTransaction and engine.transactionMode == MODE_DDL then return fail(UNSUPPORTED_SQL, "select", "SELECT after staged DDL is not supported in M15") end if
  pageTransaction = void
  if engine.explicitTransaction and engine.transactionMode == MODE_DML then pageTransaction = engine.pageTransaction end if
  materialized = materializeSelectStatement(engine, statement, pageTransaction)
  bound = binder.bindSelect(materialized, engine.database.catalogHandle)
  return selectRows(engine, bound, pageTransaction)
end function

// Implements commit explicit for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function commitExplicit(engine)
  if not engine.explicitTransaction then return fail(TRANSACTION_STATE, "commit", "no explicit transaction") end if
  if engine.failed then return fail(TRANSACTION_STATE, "commit", "transaction is failed; ROLLBACK required") end if
  if engine.transactionMode == MODE_DML then
    commitPageTransaction(engine, engine.pageTransaction, void, void)
  else if engine.transactionMode == MODE_DDL then
    dml.markIndexesDirty(engine.database)
    schema_history.commit(engine.ddlTransaction)
    rebuilt = try(dml.rebuildAllIndexes(engine.database))
    if typeof(rebuilt) != "error" then dml.clearIndexesDirty(engine.database) end if
  end if
  database_manager.releaseLocks(engine.database, engine.sessionId)
  resetTransaction(engine)
  return commandResult("COMMIT", 0, "transaction committed")
end function

// Implements rollback explicit for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function rollbackExplicit(engine)
  if not engine.explicitTransaction then return fail(TRANSACTION_STATE, "rollback", "no explicit transaction") end if
  if engine.transactionMode == MODE_DML then transaction.rollback(engine.pageTransaction) end if
  if engine.transactionMode == MODE_DDL then schema_history.rollback(engine.ddlTransaction) end if
  database_manager.releaseLocks(engine.database, engine.sessionId)
  resetTransaction(engine)
  return commandResult("ROLLBACK", 0, "transaction rolled back")
end function

// Executes savepoint using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeSavepoint(engine, statement)
  if not engine.explicitTransaction then return fail(TRANSACTION_STATE, "savepoint", "SAVEPOINT requires an explicit transaction") end if
  if engine.transactionMode == MODE_DDL then return fail(UNSUPPORTED_SQL, "savepoint", "DDL savepoints are not supported") end if
  pageTransaction = ensureExplicitDml(engine)
  transaction.savepoint(pageTransaction, statement.name)
  return commandResult("SAVEPOINT", 0, statement.name)
end function

// Executes rollback to using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function executeRollbackTo(engine, statement)
  if not engine.explicitTransaction or engine.transactionMode != MODE_DML then return fail(TRANSACTION_STATE, "rollbackTo", "ROLLBACK TO requires a DML savepoint") end if
  transaction.rollbackToSavepoint(engine.pageTransaction, statement.name)
  engine.failed = false
  return commandResult("ROLLBACK TO", 0, statement.name)
end function

// Executes release savepoint using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeReleaseSavepoint(engine, statement)
  if not engine.explicitTransaction or engine.transactionMode != MODE_DML then return fail(TRANSACTION_STATE, "releaseSavepoint", "RELEASE requires a DML savepoint") end if
  transaction.releaseSavepoint(engine.pageTransaction, statement.name)
  return commandResult("RELEASE", 0, statement.name)
end function

// ---------------------------------------------------------------------------
// M21 authorization and DCL
// ---------------------------------------------------------------------------

// Implements permission failure for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function permissionFailure(operation, detail)
  return fail(PERMISSION_DENIED, operation, "permission denied: " + detail)
end function

// Implements database handle for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function databaseHandle(engine)
  return engine.database.catalogHandle
end function

// Returns whether the supplied value satisfies the database admin condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function hasDatabaseAdmin(engine)
  if engine.trusted then return true end if
  return catalog.hasPrivilege(databaseHandle(engine), engine.principalId, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_ADMIN, false)
end function

// Implements require privilege for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function requirePrivilege(engine, objectType, objectId, privilege, operation)
  if engine.trusted then return true end if
  if catalog.hasPrivilege(databaseHandle(engine), engine.principalId, objectType, objectId, privilege, false) then return true end if
  return permissionFailure(operation, "required privilege " + privilege + " on object " + objectId)
end function

// Implements require grant option for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function requireGrantOption(engine, objectType, objectId, privilege, operation)
  if engine.trusted or hasDatabaseAdmin(engine) then return true end if
  if catalog.hasPrivilege(databaseHandle(engine), engine.principalId, objectType, objectId, privilege, true) then return true end if
  return permissionFailure(operation, "grant option is required")
end function

// Implements require table privilege by name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function requireTablePrivilegeByName(engine, tableName, privilege, operation)
  table = catalog.findTable(databaseHandle(engine), tableName)
  if table is void then return fail(BINDING_ERROR, operation, "unknown table " + tableName) end if
  requirePrivilege(engine, metadata.OBJECT_TABLE, table.tableId, privilege, operation)
  return table
end function

// Implements name in list for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function nameInList(names, name)
  for each existing in names
    if existing == name then return true end if
  end for
  return false
end function

// Implements authorize expression queries internal for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function authorizeExpressionQueriesInternal(engine, expression, viewStack, cteNames)
  if expression is void then return true end if
  if ast.isSubqueryExpression(expression) or ast.isExistsExpression(expression) then
    authorizeSelectInternal(engine, expression.query, viewStack, cteNames)
    return true
  end if
  if ast.isInSubqueryExpression(expression) then
    authorizeExpressionQueriesInternal(engine, expression.operand, viewStack, cteNames)
    authorizeSelectInternal(engine, expression.query, viewStack, cteNames)
    return true
  end if
  if ast.isUnaryExpression(expression) or ast.isIsNullExpression(expression) or ast.isCastExpression(expression) or ast.isTruthTestExpression(expression) then
    return authorizeExpressionQueriesInternal(engine, expression.operand, viewStack, cteNames)
  end if
  if ast.isBinaryExpression(expression) then
    authorizeExpressionQueriesInternal(engine, expression.left, viewStack, cteNames)
    authorizeExpressionQueriesInternal(engine, expression.right, viewStack, cteNames)
    return true
  end if
  if ast.isFunctionExpression(expression) then
    for each argument in expression.arguments
      authorizeExpressionQueriesInternal(engine, argument, viewStack, cteNames)
    end for
    return true
  end if
  if ast.isCaseExpression(expression) then
    for each branch in expression.branches
      authorizeExpressionQueriesInternal(engine, branch.condition, viewStack, cteNames)
      authorizeExpressionQueriesInternal(engine, branch.result, viewStack, cteNames)
    end for
    authorizeExpressionQueriesInternal(engine, expression.elseExpression, viewStack, cteNames)
    return true
  end if
  if ast.isInExpression(expression) then
    authorizeExpressionQueriesInternal(engine, expression.operand, viewStack, cteNames)
    for each candidate in expression.values
      authorizeExpressionQueriesInternal(engine, candidate, viewStack, cteNames)
    end for
    return true
  end if
  if ast.isBetweenExpression(expression) then
    authorizeExpressionQueriesInternal(engine, expression.operand, viewStack, cteNames)
    authorizeExpressionQueriesInternal(engine, expression.lower, viewStack, cteNames)
    authorizeExpressionQueriesInternal(engine, expression.upper, viewStack, cteNames)
    return true
  end if
  if ast.isWindowExpression(expression) then
    for each argument in expression.arguments
      authorizeExpressionQueriesInternal(engine, argument, viewStack, cteNames)
    end for
    for each partition in expression.partitionBy
      authorizeExpressionQueriesInternal(engine, partition, viewStack, cteNames)
    end for
    for each orderItem in expression.orderBy
      authorizeExpressionQueriesInternal(engine, orderItem.expression, viewStack, cteNames)
    end for
  end if
  return true
end function

// Implements authorize named source for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function authorizeNamedSource(engine, state, name, viewStack)
  parts = splitObjectName(name)
  if parts[0] == "information_schema" then return true end if
  table = catalog.findTable(databaseHandle(engine), name)
  if table is not void then
    requirePrivilege(engine, metadata.OBJECT_TABLE, table.tableId, metadata.PRIVILEGE_SELECT, "authorizeSelect")
    return true
  end if
  view = schema_history.findView(state, name)
  if view is not void and schema_history.isInternalExtensionViewName(view.name) then view = void end if
  if view is void then return fail(BINDING_ERROR, "authorizeSelect", "unknown table or view " + name) end if
  if nameInList(viewStack, name) then return fail(BINDING_ERROR, "authorizeSelect", "cyclic view dependency involving " + name) end if
  parsed = parser.parseSql(view.sqlText)
  if len(parsed) != 1 or not ast.isSelectStatement(parsed[0]) then return fail(CORRUPT_DATA, "authorizeSelect", "stored view is not a single SELECT") end if
  // A persisted view is bound in its own query scope. CTE names from the caller
  // must not leak into the stored definition.
  return authorizeSelectInternal(engine, parsed[0], viewStack + [name], [])
end function

// Implements authorize select internal for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function authorizeSelectInternal(engine, statement, viewStack, inheritedCteNames)
  state = schema_history.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
  availableCtes = inheritedCteNames
  // Nonrecursive CTEs are visible in declaration order and remain visible to
  // the main query and nested subqueries. Each CTE is authorized against only
  // the definitions that precede it.
  for each cte in statement.ctes
    cteScope = availableCtes
    if cte.recursive then cteScope = cteScope + [cte.name] end if
    authorizeSelectInternal(engine, cte.query, viewStack, cteScope)
    availableCtes = availableCtes + [cte.name]
  end for
  if statement.tableName is not void and not nameInList(availableCtes, statement.tableName) then authorizeNamedSource(engine, state, statement.tableName, viewStack) end if
  for each joinClause in statement.joins
    if not nameInList(availableCtes, joinClause.tableName) then authorizeNamedSource(engine, state, joinClause.tableName, viewStack) end if
    authorizeExpressionQueriesInternal(engine, joinClause.condition, viewStack, availableCtes)
  end for
  for each item in statement.items
    authorizeExpressionQueriesInternal(engine, item.expression, viewStack, availableCtes)
  end for
  authorizeExpressionQueriesInternal(engine, statement.whereExpression, viewStack, availableCtes)
  for each expression in statement.groupBy
    authorizeExpressionQueriesInternal(engine, expression, viewStack, availableCtes)
  end for
  authorizeExpressionQueriesInternal(engine, statement.havingExpression, viewStack, availableCtes)
  for each orderItem in statement.orderBy
    authorizeExpressionQueriesInternal(engine, orderItem.expression, viewStack, availableCtes)
  end for
  for each setOperation in statement.setOperations
    authorizeSelectInternal(engine, setOperation.query, viewStack, availableCtes)
  end for
  return true
end function

// Implements authorize select for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function authorizeSelect(engine, statement)
  return authorizeSelectInternal(engine, statement, [], [])
end function

// Implements authorize select items for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function authorizeSelectItems(engine, items)
  for each item in items
    authorizeExpressionQueriesInternal(engine, item.expression, [], [])
  end for
  return true
end function

// Implements authorize statement for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function authorizeStatement(engine, statement)
  if engine.trusted then return true end if
  if ast.isDclStatement(statement) then return true end if
  if ast.isPrepareStatement(statement) or ast.isExecutePreparedStatement(statement) or ast.isDeallocateStatement(statement) then return true end if
  if ast.isBeginStatement(statement) or ast.isCommitStatement(statement) or ast.isRollbackStatement(statement) or ast.isSavepointStatement(statement) or ast.isRollbackToStatement(statement) or ast.isReleaseSavepointStatement(statement) then return true end if
  if ast.isShowTablesStatement(statement) then return true end if
  if ast.isDescribeTableStatement(statement) or ast.isShowIndexesStatement(statement) then requireTablePrivilegeByName(engine, statement.tableName, metadata.PRIVILEGE_SELECT, "authorizeMetadata"); return true end if
  if ast.isSelectStatement(statement) then return authorizeSelect(engine, statement) end if
  if ast.isInsertStatement(statement) then
    requireTablePrivilegeByName(engine, statement.tableName, metadata.PRIVILEGE_INSERT, "authorizeInsert")
    if statement.sourceQuery is not void then authorizeSelect(engine, statement.sourceQuery) end if
    for each row in statement.rows
      for each expression in row
        authorizeExpressionQueriesInternal(engine, expression, [], [])
      end for
    end for
    for each assignment in statement.conflictAssignments
      authorizeExpressionQueriesInternal(engine, assignment.expression, [], [])
    end for
    authorizeExpressionQueriesInternal(engine, statement.conflictWhere, [], [])
    authorizeSelectItems(engine, statement.returning)
    return true
  end if
  if ast.isUpdateStatement(statement) then
    requireTablePrivilegeByName(engine, statement.tableName, metadata.PRIVILEGE_UPDATE, "authorizeUpdate")
    for each assignment in statement.assignments
      authorizeExpressionQueriesInternal(engine, assignment.expression, [], [])
    end for
    authorizeExpressionQueriesInternal(engine, statement.whereExpression, [], [])
    authorizeSelectItems(engine, statement.returning)
    return true
  end if
  if ast.isDeleteStatement(statement) then
    requireTablePrivilegeByName(engine, statement.tableName, metadata.PRIVILEGE_DELETE, "authorizeDelete")
    authorizeExpressionQueriesInternal(engine, statement.whereExpression, [], [])
    authorizeSelectItems(engine, statement.returning)
    return true
  end if
  if ast.isMergeStatement(statement) then
    requireTablePrivilegeByName(engine, statement.sourceTable, metadata.PRIVILEGE_SELECT, "authorizeMergeSource")
    if len(statement.matchedAssignments) > 0 then requireTablePrivilegeByName(engine, statement.targetTable, metadata.PRIVILEGE_UPDATE, "authorizeMergeUpdate") end if
    if statement.matchedDelete then requireTablePrivilegeByName(engine, statement.targetTable, metadata.PRIVILEGE_DELETE, "authorizeMergeDelete") end if
    if len(statement.insertValues) > 0 then requireTablePrivilegeByName(engine, statement.targetTable, metadata.PRIVILEGE_INSERT, "authorizeMergeInsert") end if
    return true
  end if
  if ast.isTruncateStatement(statement) then requireTablePrivilegeByName(engine, statement.tableName, metadata.PRIVILEGE_DELETE, "authorizeTruncate"); return true end if
  if ast.isCreateSchemaStatement(statement) or ast.isDropSchemaStatement(statement) then return requirePrivilege(engine, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CREATE, "authorizeSchemaDdl") end if
  if ast.isCreateProcedureStatement(statement) or ast.isDropProcedureStatement(statement) then return requirePrivilege(engine, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CREATE, "authorizeProcedureDdl") end if
  if ast.isCallStatement(statement) then return true end if
  if ast.isCreateTableStatement(statement) then return requirePrivilege(engine, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CREATE, "authorizeCreateTable") end if
  if ast.isCreateViewStatement(statement) then
    requirePrivilege(engine, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CREATE, "authorizeViewDdl")
    authorizeSelect(engine, statement.query)
    return true
  end if
  if ast.isDropViewStatement(statement) then return requirePrivilege(engine, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CREATE, "authorizeViewDdl") end if
  if ast.isCreateSequenceStatement(statement) or ast.isDropSequenceStatement(statement) then return requirePrivilege(engine, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CREATE, "authorizeSequenceDdl") end if
  if ast.isCreateTriggerStatement(statement) then
    requireTablePrivilegeByName(engine, statement.tableName, metadata.PRIVILEGE_ALTER, "authorizeCreateTrigger")
    authorizeStatement(engine, statement.body)
    return true
  end if
  if ast.isDropTriggerStatement(statement) or ast.isAlterTriggerStatement(statement) then return requirePrivilege(engine, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CREATE, "authorizeTriggerDdl") end if
  if ast.isCreateIndexStatement(statement) then requireTablePrivilegeByName(engine, statement.tableName, metadata.PRIVILEGE_INDEX, "authorizeCreateIndex"); return true end if
  if ast.isDropIndexStatement(statement) then
    boundIndex = binder.bindStatement(statement, engine.database.catalogHandle)
    if boundIndex.table is void then return requirePrivilege(engine, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CREATE, "authorizeDropIndex") end if
    requireTablePrivilegeByName(engine, boundIndex.table.name, metadata.PRIVILEGE_INDEX, "authorizeDropIndex")
    return true
  end if
  if ast.isDropTableStatement(statement) then requireTablePrivilegeByName(engine, statement.name, metadata.PRIVILEGE_DROP, "authorizeDropTable"); return true end if
  if ast.isAlterTableStatement(statement) then requireTablePrivilegeByName(engine, statement.tableName, metadata.PRIVILEGE_ALTER, "authorizeAlterTable"); return true end if
  if ast.isAnalyzeStatement(statement) then return requirePrivilege(engine, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_MAINTAIN, "authorizeAnalyze") end if
  if ast.isVacuumStatement(statement) or ast.isReindexStatement(statement) then return requirePrivilege(engine, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_MAINTAIN, "authorizeMaintenance") end if
  if ast.isExplainStatement(statement) then return authorizeStatement(engine, statement.statement) end if
  return permissionFailure("authorizeStatement", "statement is not authorized")
end function

// Implements privilege code for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function privilegeCode(name, objectType)
  if objectType == metadata.OBJECT_DATABASE then
    if name == "CONNECT" then return metadata.PRIVILEGE_CONNECT end if
    if name == "CREATE" then return metadata.PRIVILEGE_CREATE end if
    if name == "MAINTAIN" then return metadata.PRIVILEGE_MAINTAIN end if
    if name == "ADMIN" then return metadata.PRIVILEGE_ADMIN end if
    return fail(INVALID_ARGUMENT, "privilegeCode", "invalid database privilege " + name)
  end if
  if name == "SELECT" then return metadata.PRIVILEGE_SELECT end if
  if name == "INSERT" then return metadata.PRIVILEGE_INSERT end if
  if name == "UPDATE" then return metadata.PRIVILEGE_UPDATE end if
  if name == "DELETE" then return metadata.PRIVILEGE_DELETE end if
  if name == "REFERENCES" then return metadata.PRIVILEGE_REFERENCES end if
  if name == "INDEX" then return metadata.PRIVILEGE_INDEX end if
  if name == "ALTER" then return metadata.PRIVILEGE_ALTER end if
  if name == "DROP" then return metadata.PRIVILEGE_DROP end if
  return fail(INVALID_ARGUMENT, "privilegeCode", "invalid table privilege " + name)
end function

// Implements all privilege codes for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function allPrivilegeCodes(objectType)
  if objectType == metadata.OBJECT_DATABASE then return [metadata.PRIVILEGE_CONNECT, metadata.PRIVILEGE_CREATE, metadata.PRIVILEGE_MAINTAIN, metadata.PRIVILEGE_ADMIN] end if
  return [metadata.PRIVILEGE_SELECT, metadata.PRIVILEGE_INSERT, metadata.PRIVILEGE_UPDATE, metadata.PRIVILEGE_DELETE, metadata.PRIVILEGE_REFERENCES, metadata.PRIVILEGE_INDEX, metadata.PRIVILEGE_ALTER, metadata.PRIVILEGE_DROP]
end function

// Implements privilege codes for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function privilegeCodes(names, objectType)
  if typeof(names) != "array" or len(names) == 0 then return fail(INVALID_ARGUMENT, "privilegeCodes", "privilege list is empty") end if
  if len(names) == 1 and names[0] == "ALL" then return allPrivilegeCodes(objectType) end if
  output = []
  for each name in names
    code = privilegeCode(name, objectType)
    duplicate = false
    for each existing in output
      if existing == code then duplicate = true end if
    end for
    if not duplicate then output = output + [code] end if
  end for
  return output
end function

// Implements dcl target for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function dclTarget(engine, objectType, objectName)
  if objectType == ast.DCL_OBJECT_DATABASE then return [metadata.OBJECT_DATABASE, 0] end if
  table = catalog.findTable(databaseHandle(engine), objectName)
  if table is void then return fail(BINDING_ERROR, "dclTarget", "unknown table " + objectName) end if
  return [metadata.OBJECT_TABLE, table.tableId]
end function

// Implements require security admin for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function requireSecurityAdmin(engine, operation)
  if engine.trusted or hasDatabaseAdmin(engine) then return true end if
  return permissionFailure(operation, "database ADMIN privilege is required")
end function

// Executes create principal using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeCreatePrincipal(engine, statement)
  requireSecurityAdmin(engine, "createPrincipal")
  if statement.principalKind == ast.PRINCIPAL_USER then
    catalog.createUser(databaseHandle(engine), statement.name, statement.password)
    return commandResult("CREATE USER", 0, statement.name)
  end if
  catalog.createRole(databaseHandle(engine), statement.name)
  return commandResult("CREATE ROLE", 0, statement.name)
end function

// Executes alter user using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeAlterUser(engine, statement)
  target = catalog.requirePrincipal(databaseHandle(engine), statement.name, "alterUser")
  selfPassword = statement.action == ast.ALTER_USER_PASSWORD and target.principalId == engine.principalId
  if not engine.trusted and not selfPassword then requireSecurityAdmin(engine, "alterUser") end if
  if statement.action == ast.ALTER_USER_PASSWORD then
    catalog.setUserPassword(databaseHandle(engine), statement.name, statement.password)
    return commandResult("ALTER USER", 0, "password changed")
  end if
  requireSecurityAdmin(engine, "alterUser")
  enabled = statement.action == ast.ALTER_USER_ENABLE
  catalog.setUserEnabled(databaseHandle(engine), statement.name, enabled)
  return commandResult("ALTER USER", 0, statement.name)
end function

// Executes drop principal using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeDropPrincipal(engine, statement)
  requireSecurityAdmin(engine, "dropPrincipal")
  expected = metadata.PRINCIPAL_USER
  command = "DROP USER"
  if statement.principalKind == ast.PRINCIPAL_ROLE then expected = metadata.PRINCIPAL_ROLE; command = "DROP ROLE" end if
  removed = catalog.dropPrincipal(databaseHandle(engine), statement.name, expected, statement.ifExists)
  affected = 0
  if removed then affected = 1 end if
  return commandResult(command, affected, statement.name)
end function

// Executes grant role using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeGrantRole(engine, statement)
  role = catalog.requirePrincipal(databaseHandle(engine), statement.roleName, "grantRole")
  if not engine.trusted and not hasDatabaseAdmin(engine) and not catalog.hasRoleAdminOption(databaseHandle(engine), engine.principalId, role.principalId) then return permissionFailure("grantRole", "ADMIN OPTION for role is required") end if
  catalog.grantRole(databaseHandle(engine), statement.roleName, statement.memberName, engine.principalId, statement.adminOption)
  return commandResult("GRANT ROLE", 0, statement.roleName + " TO " + statement.memberName)
end function

// Executes revoke role using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeRevokeRole(engine, statement)
  role = catalog.requirePrincipal(databaseHandle(engine), statement.roleName, "revokeRole")
  if not engine.trusted and not hasDatabaseAdmin(engine) and not catalog.hasRoleAdminOption(databaseHandle(engine), engine.principalId, role.principalId) then return permissionFailure("revokeRole", "ADMIN OPTION for role is required") end if
  catalog.revokeRoleWithBehavior(databaseHandle(engine), statement.roleName, statement.memberName, statement.cascade)
  return commandResult("REVOKE ROLE", 0, statement.roleName + " FROM " + statement.memberName)
end function

// Executes grant privilege using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeGrantPrivilege(engine, statement)
  target = dclTarget(engine, statement.objectType, statement.objectName)
  codes = privilegeCodes(statement.privileges, target[0])
  for each code in codes
    requireGrantOption(engine, target[0], target[1], code, "grantPrivilege")
  end for
  catalog.grantPrivileges(databaseHandle(engine), statement.granteeName, engine.principalId, target[0], target[1], codes, statement.grantOption)
  return commandResult("GRANT", len(codes), statement.granteeName)
end function

// Executes revoke privilege using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeRevokePrivilege(engine, statement)
  target = dclTarget(engine, statement.objectType, statement.objectName)
  codes = privilegeCodes(statement.privileges, target[0])
  for each code in codes
    requireGrantOption(engine, target[0], target[1], code, "revokePrivilege")
  end for
  catalog.revokePrivilegesWithBehavior(databaseHandle(engine), statement.granteeName, target[0], target[1], codes, statement.cascade)
  return commandResult("REVOKE", len(codes), statement.granteeName)
end function

// Executes dcl using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeDcl(engine, statement)
  if engine.explicitTransaction then return fail(UNSUPPORTED_SQL, "executeDcl", "DCL is autocommit-only in M21") end if
  if ast.isCreatePrincipalStatement(statement) then return executeCreatePrincipal(engine, statement) end if
  if ast.isAlterUserStatement(statement) then return executeAlterUser(engine, statement) end if
  if ast.isDropPrincipalStatement(statement) then return executeDropPrincipal(engine, statement) end if
  if ast.isGrantRoleStatement(statement) then return executeGrantRole(engine, statement) end if
  if ast.isRevokeRoleStatement(statement) then return executeRevokeRole(engine, statement) end if
  if ast.isGrantPrivilegeStatement(statement) then return executeGrantPrivilege(engine, statement) end if
  if ast.isRevokePrivilegeStatement(statement) then return executeRevokePrivilege(engine, statement) end if
  return fail(UNSUPPORTED_SQL, "executeDcl", "unsupported DCL statement")
end function

// Executes vacuum using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeVacuum(engine, statement)
  if engine.explicitTransaction then return fail(UNSUPPORTED_SQL, "vacuum", "VACUUM is autocommit-only") end if
  affected = dml.vacuum(engine.database, statement.tableName)
  state = loadStatistics(engine)
  if statement.tableName is void then
    for each table in engine.database.catalogHandle.catalog.tables
      analyzeTable(engine, state, table)
    end for
  else
    table = catalog.findTable(engine.database.catalogHandle, statement.tableName)
    if table is void then return fail(BINDING_ERROR, "vacuum", "unknown table " + statement.tableName) end if
    analyzeTable(engine, state, table)
  end if
  statistics.save(engine.database.path, state)
  return commandResult("VACUUM", affected, "storage rewritten, indexes rebuilt, and statistics refreshed")
end function

// Executes reindex using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeReindex(engine, statement)
  if engine.explicitTransaction then return fail(UNSUPPORTED_SQL, "reindex", "REINDEX is autocommit-only") end if
  rebuilt = dml.reindex(engine.database, statement.name)
  return commandResult("REINDEX", rebuilt, "indexes rebuilt")
end function

// Implements type description for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function typeDescription(column)
  name = types.kindName(column.typeCode)
  if column.typeCode == types.SqlTypeKind.Char or column.typeCode == types.SqlTypeKind.VarChar or column.typeCode == types.SqlTypeKind.Binary or column.typeCode == types.SqlTypeKind.VarBinary then return name + "(" + column.maxLength + ")" end if
  if column.typeCode == types.SqlTypeKind.Decimal then return name + "(" + column.precision + "," + column.scale + ")" end if
  if column.typeCode == types.SqlTypeKind.Time or column.typeCode == types.SqlTypeKind.Timestamp then return name + "(" + column.precision + ")" end if
  return name
end function

// Finds column rule using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function findColumnRule(tableSchema, columnName)
  if tableSchema is void then return void end if
  for each rule in tableSchema.columnRules
    if rule.columnName == columnName then return rule end if
  end for
  return void
end function

// Implements constraint kind name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function constraintKindName(kind)
  if kind == schema_history.CONSTRAINT_PRIMARY_KEY then return "PRIMARY KEY" end if
  if kind == schema_history.CONSTRAINT_UNIQUE then return "UNIQUE" end if
  if kind == schema_history.CONSTRAINT_INDEX then return "INDEX" end if
  if kind == schema_history.CONSTRAINT_FOREIGN_KEY then return "FOREIGN KEY" end if
  if kind == schema_history.CONSTRAINT_CHECK then return "CHECK" end if
  return "UNKNOWN"
end function

// Implements join names for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function joinNames(names)
  output = ""
  for each name in names
    if len(output) > 0 then output = output + ", " end if
    output = output + name
  end for
  return output
end function

// Executes show tables using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeShowTables(engine)
  rows = []
  for each table in engine.database.catalogHandle.catalog.tables
    rows = rows + [[values.text(table.name), values.integer(len(table.columns)), values.integer(table.schemaVersion)]]
  end for
  return rowResult(["table_name", "column_count", "schema_version"], rows)
end function

// Executes describe table using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeDescribeTable(engine, statement)
  table = catalog.findTable(engine.database.catalogHandle, statement.tableName)
  if table is void then return fail(BINDING_ERROR, "describe", "unknown table " + statement.tableName) end if
  state = schema_history.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
  tableSchema = schema_history.findTableSchema(state, table.tableId)
  rows = []
  if len(table.columns) > 0 then
    for index = 0 to len(table.columns) - 1
      column = table.columns[index]
      rule = findColumnRule(tableSchema, column.name)
      defaultSql = values.nullValue(types.SqlTypeKind.Text)
      identity = false
      if rule is not void then
        if rule.defaultSql is not void and len(rule.defaultSql) > 0 then defaultSql = values.text(rule.defaultSql) end if
        identity = rule.identity
      end if
      rows = rows + [[values.integer(index + 1), values.text(column.name), values.text(typeDescription(column)), values.boolean(column.nullable), defaultSql, values.boolean(identity)]]
    end for
  end if
  return rowResult(["ordinal", "column_name", "data_type", "nullable", "default_sql", "identity"], rows)
end function

// Executes show indexes using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeShowIndexes(engine, statement)
  table = catalog.findTable(engine.database.catalogHandle, statement.tableName)
  if table is void then return fail(BINDING_ERROR, "showIndexes", "unknown table " + statement.tableName) end if
  state = schema_history.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
  tableSchema = schema_history.findTableSchema(state, table.tableId)
  rows = []
  if tableSchema is not void then
    for each constraint in tableSchema.constraints
      if constraint.indexId > 0 then
        unique = constraint.kind == schema_history.CONSTRAINT_PRIMARY_KEY or constraint.kind == schema_history.CONSTRAINT_UNIQUE
        rows = rows + [[values.text(constraint.indexName), values.text(constraintKindName(constraint.kind)), values.boolean(unique), values.text(joinNames(constraint.columns))]]
      end if
    end for
  end if
  return rowResult(["index_name", "index_kind", "unique", "columns"], rows)
end function

// Executes statement inner using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeStatementInner(engine, statement)
  if ast.isDclStatement(statement) then return executeDcl(engine, statement) end if
  if ast.isBeginStatement(statement) then return beginExplicit(engine, statement) end if
  if ast.isCommitStatement(statement) then return commitExplicit(engine) end if
  if ast.isRollbackStatement(statement) then return rollbackExplicit(engine) end if
  if ast.isRollbackToStatement(statement) then return executeRollbackTo(engine, statement) end if
  if engine.explicitTransaction and engine.failed then return fail(TRANSACTION_STATE, "execute", "transaction is failed; ROLLBACK or ROLLBACK TO is required") end if
  if ast.isPrepareStatement(statement) then return executePrepare(engine, statement) end if
  if ast.isExecutePreparedStatement(statement) then return executePrepared(engine, statement) end if
  if ast.isDeallocateStatement(statement) then return executeDeallocate(engine, statement) end if
  if ast.isSavepointStatement(statement) then return executeSavepoint(engine, statement) end if
  if ast.isReleaseSavepointStatement(statement) then return executeReleaseSavepoint(engine, statement) end if
  if ast.isShowTablesStatement(statement) then return executeShowTables(engine) end if
  if ast.isDescribeTableStatement(statement) then return executeDescribeTable(engine, statement) end if
  if ast.isShowIndexesStatement(statement) then return executeShowIndexes(engine, statement) end if
  if ast.isCreateSchemaStatement(statement) or ast.isDropSchemaStatement(statement) then return executeSchemaDdl(engine, statement) end if
  if ast.isCreateProcedureStatement(statement) or ast.isDropProcedureStatement(statement) then return executeProcedureDdl(engine, statement) end if
  if ast.isCallStatement(statement) then return executeCall(engine, statement) end if
  if ast.isCreateViewStatement(statement) or ast.isDropViewStatement(statement) then return executeViewDdl(engine, statement) end if
  if ast.isCreateSequenceStatement(statement) or ast.isDropSequenceStatement(statement) then return executeSequenceDdl(engine, statement) end if
  if ast.isCreateTriggerStatement(statement) or ast.isDropTriggerStatement(statement) or ast.isAlterTriggerStatement(statement) then return executeTriggerDdl(engine, statement) end if
  if ast.isCreateTableStatement(statement) or ast.isCreateIndexStatement(statement) or ast.isDropIndexStatement(statement) or ast.isDropTableStatement(statement) or ast.isAlterTableStatement(statement) then return executeDdl(engine, statement) end if
  if ast.isVacuumStatement(statement) then return executeVacuum(engine, statement) end if
  if ast.isReindexStatement(statement) then return executeReindex(engine, statement) end if
  if ast.isInsertStatement(statement) or ast.isUpdateStatement(statement) or ast.isDeleteStatement(statement) or ast.isTruncateStatement(statement) then return executeDml(engine, statement) end if
  if ast.isMergeStatement(statement) then return executeMerge(engine, statement) end if
  if ast.isSelectStatement(statement) then return executeSelect(engine, statement) end if
  if ast.isAnalyzeStatement(statement) then return executeAnalyze(engine, statement) end if
  if ast.isExplainStatement(statement) then return executeExplain(engine, statement) end if
  return fail(UNSUPPORTED_SQL, "execute", "unsupported statement")
end function

// Recursively detects NEXTVAL in every expression container, including CASE,
// window clauses, and subqueries. NEXTVAL mutates sequence/session state and is
// therefore the key exception to classifying SELECT as a shared read.
function expressionUsesNextval(expression)
  if expression is void then return false end if
  if ast.isFunctionExpression(expression) then
    if expression.name == "NEXTVAL" then return true end if
    for each argument in expression.arguments
      if expressionUsesNextval(argument) then return true end if
    end for
    return false
  end if
  if ast.isUnaryExpression(expression) or ast.isIsNullExpression(expression) or ast.isCastExpression(expression) or ast.isTruthTestExpression(expression) then return expressionUsesNextval(expression.operand) end if
  if ast.isBinaryExpression(expression) then return expressionUsesNextval(expression.left) or expressionUsesNextval(expression.right) end if
  if ast.isCaseExpression(expression) then
    for each branch in expression.branches
      if expressionUsesNextval(branch.condition) or expressionUsesNextval(branch.result) then return true end if
    end for
    return expression.elseExpression is not void and expressionUsesNextval(expression.elseExpression)
  end if
  if ast.isInExpression(expression) then
    if expressionUsesNextval(expression.operand) then return true end if
    for each candidate in expression.values
      if expressionUsesNextval(candidate) then return true end if
    end for
    return false
  end if
  if ast.isBetweenExpression(expression) then return expressionUsesNextval(expression.operand) or expressionUsesNextval(expression.lower) or expressionUsesNextval(expression.upper) end if
  if ast.isWindowExpression(expression) then
    for each argument in expression.arguments
      if expressionUsesNextval(argument) then return true end if
    end for
    for each value in expression.partitionBy
      if expressionUsesNextval(value) then return true end if
    end for
    for each value in expression.orderBy
      if expressionUsesNextval(value.expression) then return true end if
    end for
    return false
  end if
  if ast.isSubqueryExpression(expression) or ast.isExistsExpression(expression) then return selectUsesNextval(expression.query) end if
  if ast.isInSubqueryExpression(expression) then return expressionUsesNextval(expression.operand) or selectUsesNextval(expression.query) end if
  return false
end function

// Walks all SELECT clauses, CTEs, joins, and set-operation branches for NEXTVAL.
// Returns true as soon as any nested expression advances a sequence.
function selectUsesNextval(statement)
  for each item in statement.items
    if expressionUsesNextval(item.expression) then return true end if
  end for
  if expressionUsesNextval(statement.whereExpression) or expressionUsesNextval(statement.havingExpression) then return true end if
  for each value in statement.groupBy
    if expressionUsesNextval(value) then return true end if
  end for
  for each value in statement.orderBy
    if expressionUsesNextval(value.expression) then return true end if
  end for
  for each joinClause in statement.joins
    if expressionUsesNextval(joinClause.condition) then return true end if
  end for
  for each cte in statement.ctes
    if selectUsesNextval(cte.query) then return true end if
  end for
  for each operation in statement.setOperations
    if selectUsesNextval(operation.query) then return true end if
  end for
  return false
end function

// Classifies statements that may share physical database execution.
// Pure SELECT, pure EXPLAIN, and metadata inspection are reads; a SELECT tree
// containing NEXTVAL is deliberately excluded because it changes sequence state.
function statementUsesReadLock(statement)
  if ast.isSelectStatement(statement) then return not selectUsesNextval(statement) end if
  if ast.isExplainStatement(statement) then return not selectUsesNextval(statement.statement) end if
  if ast.isMetadataStatement(statement) then return true end if
  return false
end function

// Classifies statements that require exclusive physical database execution.
// This includes DML, DDL, DCL, maintenance, and SELECT statements containing
// NEXTVAL. Transaction-control/session-only statements are handled separately.
function statementUsesWriteLock(statement)
  if ast.isSelectStatement(statement) and selectUsesNextval(statement) then return true end if
  if ast.isCallStatement(statement) then return true end if
  if ast.isInsertStatement(statement) or ast.isUpdateStatement(statement) or ast.isDeleteStatement(statement) or ast.isMergeStatement(statement) or ast.isTruncateStatement(statement) then return true end if
  if ast.isCreateTableStatement(statement) or ast.isCreateIndexStatement(statement) or ast.isDropIndexStatement(statement) or ast.isDropTableStatement(statement) or ast.isAlterTableStatement(statement) or ast.isCreateSchemaStatement(statement) or ast.isDropSchemaStatement(statement) or ast.isCreateProcedureStatement(statement) or ast.isDropProcedureStatement(statement) or ast.isCreateViewStatement(statement) or ast.isDropViewStatement(statement) or ast.isCreateSequenceStatement(statement) or ast.isDropSequenceStatement(statement) or ast.isCreateTriggerStatement(statement) or ast.isDropTriggerStatement(statement) or ast.isAlterTriggerStatement(statement) then return true end if
  if ast.isDclStatement(statement) or ast.isAnalyzeStatement(statement) or ast.isVacuumStatement(statement) or ast.isReindexStatement(statement) then return true end if
  return false
end function

// Implements statement isolation for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function statementIsolation(engine)
  if not engine.explicitTransaction then return transaction.ISOLATION_READ_COMMITTED end if
  if engine.transactionMode == MODE_DML and engine.pageTransaction is not void and typeof(engine.pageTransaction) != "array" then return engine.pageTransaction.isolationLevel end if
  if engine.transactionMode == MODE_NONE and typeof(engine.pageTransaction) == "array" then return engine.pageTransaction[0] end if
  return transaction.ISOLATION_SERIALIZABLE
end function

// Implements mark explicit failure for this module.
// Returns its result or propagates a structured error from validation or a dependency.
// May mutate supplied state as documented by the operation name.
function markExplicitFailure(engine)
  if not engine.explicitTransaction then return true end if
  engine.failed = true
  if engine.transactionMode == MODE_DML then
    ignored = try(transaction.markFailed(engine.pageTransaction))
  end if
  return true
end function

// Implements audit action for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function auditAction(statement)
  if ast.isSelectStatement(statement) then return "SELECT" end if
  if ast.isInsertStatement(statement) then return "INSERT" end if
  if ast.isUpdateStatement(statement) then return "UPDATE" end if
  if ast.isDeleteStatement(statement) then return "DELETE" end if
  if ast.isMergeStatement(statement) then return "MERGE" end if
  if ast.isCallStatement(statement) then return "CALL" end if
  if ast.isTruncateStatement(statement) then return "TRUNCATE" end if
  if ast.isCreateTableStatement(statement) then return "CREATE TABLE" end if
  if ast.isCreateIndexStatement(statement) then return "CREATE INDEX" end if
  if ast.isDropIndexStatement(statement) then return "DROP INDEX" end if
  if ast.isDropTableStatement(statement) then return "DROP TABLE" end if
  if ast.isAlterTableStatement(statement) then return "ALTER TABLE" end if
  if ast.isCreateSchemaStatement(statement) then return "CREATE SCHEMA" end if
  if ast.isDropSchemaStatement(statement) then return "DROP SCHEMA" end if
  if ast.isCreateProcedureStatement(statement) then return "CREATE PROCEDURE" end if
  if ast.isDropProcedureStatement(statement) then return "DROP PROCEDURE" end if
  if ast.isCreateViewStatement(statement) then return "CREATE VIEW" end if
  if ast.isDropViewStatement(statement) then return "DROP VIEW" end if
  if ast.isCreateSequenceStatement(statement) then return "CREATE SEQUENCE" end if
  if ast.isDropSequenceStatement(statement) then return "DROP SEQUENCE" end if
  if ast.isCreateTriggerStatement(statement) then return "CREATE TRIGGER" end if
  if ast.isDropTriggerStatement(statement) then return "DROP TRIGGER" end if
  if ast.isAlterTriggerStatement(statement) then return "ALTER TRIGGER" end if
  if ast.isAnalyzeStatement(statement) then return "ANALYZE" end if
  if ast.isExplainStatement(statement) then return "EXPLAIN" end if
  if ast.isVacuumStatement(statement) then return "VACUUM" end if
  if ast.isReindexStatement(statement) then return "REINDEX" end if
  if ast.isBeginStatement(statement) then return "BEGIN" end if
  if ast.isCommitStatement(statement) then return "COMMIT" end if
  if ast.isRollbackStatement(statement) then return "ROLLBACK" end if
  if ast.isSavepointStatement(statement) then return "SAVEPOINT" end if
  if ast.isRollbackToStatement(statement) then return "ROLLBACK TO" end if
  if ast.isReleaseSavepointStatement(statement) then return "RELEASE SAVEPOINT" end if
  if ast.isCreatePrincipalStatement(statement) then return "CREATE PRINCIPAL" end if
  if ast.isAlterUserStatement(statement) then return "ALTER USER" end if
  if ast.isDropPrincipalStatement(statement) then return "DROP PRINCIPAL" end if
  if ast.isGrantRoleStatement(statement) then return "GRANT ROLE" end if
  if ast.isRevokeRoleStatement(statement) then return "REVOKE ROLE" end if
  if ast.isGrantPrivilegeStatement(statement) then return "GRANT PRIVILEGE" end if
  if ast.isRevokePrivilegeStatement(statement) then return "REVOKE PRIVILEGE" end if
  if ast.isPrepareStatement(statement) then return "PREPARE" end if
  if ast.isExecutePreparedStatement(statement) then return "EXECUTE" end if
  if ast.isDeallocateStatement(statement) then return "DEALLOCATE" end if
  if ast.isShowTablesStatement(statement) then return "SHOW TABLES" end if
  if ast.isDescribeTableStatement(statement) then return "DESCRIBE" end if
  if ast.isShowIndexesStatement(statement) then return "SHOW INDEXES" end if
  return "STATEMENT"
end function

// Implements audit event type for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function auditEventType(statement)
  if ast.isDclStatement(statement) then return diagnostics.AUDIT_DCL end if
  if ast.isCreateTableStatement(statement) or ast.isCreateIndexStatement(statement) or ast.isDropIndexStatement(statement) or ast.isDropTableStatement(statement) or ast.isAlterTableStatement(statement) or ast.isCreateSchemaStatement(statement) or ast.isDropSchemaStatement(statement) or ast.isCreateProcedureStatement(statement) or ast.isDropProcedureStatement(statement) or ast.isCreateViewStatement(statement) or ast.isDropViewStatement(statement) or ast.isCreateSequenceStatement(statement) or ast.isDropSequenceStatement(statement) or ast.isCreateTriggerStatement(statement) or ast.isDropTriggerStatement(statement) or ast.isAlterTriggerStatement(statement) or ast.isTruncateStatement(statement) then return diagnostics.AUDIT_DDL end if
  if ast.isAnalyzeStatement(statement) or ast.isVacuumStatement(statement) or ast.isReindexStatement(statement) then return diagnostics.AUDIT_MAINTENANCE end if
  return 0
end function

// Appends audit outcome using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function appendAuditOutcome(engine, statement, success, detail)
  // Never record raw SQL or literal values: password-bearing DCL therefore cannot
  // leak secrets into the audit stream. Ordinary SELECT and DML statements stay
  // out of the security audit stream. Audit I/O is best-effort after execution
  // because masking an already durable commit would invite an unsafe retry.
  eventType = auditEventType(statement)
  if eventType == 0 then return true end if
  outcome = diagnostics.AUDIT_FAILURE
  if success then outcome = diagnostics.AUDIT_SUCCESS end if
  written = try(database_manager.audit(engine.database, eventType, outcome, engine.sessionId, engine.principalId, auditAction(statement) + ": " + detail))
  return typeof(written) != "error"
end function

// Authorizes and executes one statement while managing logical transaction locks.
// Statement read leases end after execution; implicit write leases are released
// on every outcome. Errors mark explicit transactions failed and are audited.
function executeStatementCore(engine, statement)
  validateOpen(engine, "executeStatement")
  if not ast.isStatement(statement) then return fail(INVALID_ARGUMENT, "executeStatement", "statement must be SQL AST") end if
  if database_manager.isStandby(engine.database) and statementUsesWriteLock(statement) then
    return fail(database_manager.STANDBY_NOT_PROMOTED, "executeStatement", "standby is read-only until promotion")
  end if
  authorized = try(authorizeStatement(engine, statement))
  if typeof(authorized) == "error" then
    ignoredAudit = appendAuditOutcome(engine, statement, false, "authorization error " + authorized.code)
    return authorized
  end if

  readLease = void
  writeLease = false
  if statementUsesReadLock(statement) then
    readLease = try(database_manager.acquireStatementRead(engine.database, engine.sessionId, statementIsolation(engine)))
    if typeof(readLease) == "error" then
      ignoredAudit = appendAuditOutcome(engine, statement, false, "read lock error " + readLease.code)
      return readLease
    end if
  else if statementUsesWriteLock(statement) then
    acquired = try(database_manager.acquireWrite(engine.database, engine.sessionId))
    if typeof(acquired) == "error" then
      ignoredAudit = appendAuditOutcome(engine, statement, false, "write lock error " + acquired.code)
      return acquired
    end if
    writeLease = true
  end if

  result = try(executeStatementInner(engine, statement))
  if readLease is not void then
    finishedRead = try(database_manager.finishStatement(engine.database, readLease))
    if typeof(finishedRead) == "error" and typeof(result) != "error" then result = finishedRead end if
  end if
  if writeLease and not engine.explicitTransaction then
    releasedWrite = try(database_manager.releaseLocks(engine.database, engine.sessionId))
    if typeof(releasedWrite) == "error" and typeof(result) != "error" then result = releasedWrite end if
  end if
  if typeof(result) == "error" then
    if writeLease and not engine.explicitTransaction then ignoredRelease = try(database_manager.releaseLocks(engine.database, engine.sessionId)) end if
    if not ast.isRollbackStatement(statement) then markExplicitFailure(engine) end if
    ignoredAudit = appendAuditOutcome(engine, statement, false, "execution error " + result.code)
    return result
  end if
  ignoredAudit = appendAuditOutcome(engine, statement, true, result.command)
  return result
end function

// All callers, including the embedded API, pass through the same physical
// execution gate. Pure reads share the database; mutations and session-state
// statements run exclusively. The logical transaction lock manager remains
// responsible for conflicts that live longer than one statement.
// Executes one AST under the database's physical readers/writer gate.
// Prepared statements are classified from their stored AST. A dirty-index marker
// triggers an atomic read-to-write escalation before repair, with every gate path
// released before returning the result or a propagated error.
function executeStatement(engine, statement)
  validateOpen(engine, "executeStatement")
  if not ast.isStatement(statement) then return fail(INVALID_ARGUMENT, "executeStatement", "statement must be SQL AST") end if
  readExecution = statementUsesReadLock(statement)
  if ast.isExecutePreparedStatement(statement) then
    preparedIndex = findPreparedIndex(engine, statement.name)
    if preparedIndex >= 0 then readExecution = statementUsesReadLock(engine.preparedStatements[preparedIndex].statement) end if
  end if
  repairIndexes = false
  if readExecution then
    entered = try(database_manager.enterReadExecution(engine.database))
    // A failed writer can leave the durable dirty marker behind. Recheck only
    // after entering the read gate so a writer cannot publish it between the
    // check and the plan. Repair is an explicit read-to-write escalation.
    dirtyIndexes = try(dml.indexesNeedRepair(engine.database))
    if typeof(dirtyIndexes) == "error" then
      ignoredReadRelease = try(database_manager.leaveReadExecution(engine.database))
      return dirtyIndexes
    end if
    if dirtyIndexes then
      leftRead = try(database_manager.leaveReadExecution(engine.database))
      if typeof(leftRead) == "error" then return leftRead end if
      enteredWriter = try(database_manager.enterExecution(engine.database))
      readExecution = false
      repairIndexes = true
    end if
  else
    entered = try(database_manager.enterExecution(engine.database))
  end if
  result = void
  if repairIndexes then
    repaired = try(dml.ensureIndexes(engine.database))
    if typeof(repaired) == "error" then result = repaired end if
  end if
  if typeof(result) != "error" then result = try(executeStatementCore(engine, statement)) end if
  if not readExecution and typeof(result) != "error" then
    // Mutations publish through separate write handles. Clearing the immutable
    // base-page cache while the exclusive gate is held prevents a later reader
    // from observing a pre-commit page image.
    ignoredCacheInvalidation = database_manager.invalidateReadCache(engine.database)
    // The exclusive physical gate is still held here, so no publisher can race
    // automatic WAL reset. Post-commit maintenance logs its own failure and
    // never turns a durable SQL success into an unsafe retry invitation.
    ignoredCheckpoint = database_manager.checkpointAfterStatement(engine.database)
  end if
  released = void
  if readExecution then
    released = try(database_manager.leaveReadExecution(engine.database))
  else
    released = try(database_manager.leaveExecution(engine.database))
  end if
  if typeof(released) == "error" then return released end if
  return result
end function

// Executes SQL using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function executeSql(engine, sqlText)
  validateOpen(engine, "executeSql")
  statements = parser.parseSql(sqlText)
  results = []
  for each statement in statements
    results = results + [executeStatement(engine, statement)]
  end for
  return results
end function


// Implements abort for concurrency for this module.
// Returns its result or propagates a structured error from validation or a dependency.
// May mutate supplied state as documented by the operation name.
function abortForConcurrency(engine)
  validateOpen(engine, "abortForConcurrency")
  if engine.explicitTransaction then
    ignored = try(rollbackExplicit(engine))
  else
    ignored = try(database_manager.releaseLocks(engine.database, engine.sessionId))
  end if
  engine.failed = false
  return true
end function

// Implements session identifier for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function sessionIdentifier(engine)
  validateOpen(engine, "sessionIdentifier")
  return engine.sessionId
end function

// Closes close using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// May mutate supplied state as documented by the operation name.
function close(engine)
  validateOpen(engine, "close")
  if engine.explicitTransaction then
    ignored = try(rollbackExplicit(engine))
  end if
  ignoredLocks = try(database_manager.releaseLocks(engine.database, engine.sessionId))
  if engine.ownsDatabase then database_manager.close(engine.database) end if
  engine.preparedStatements = []
  engine.sequenceValues = []
  engine.closed = true
  return true
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "executor.executor"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M15"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
