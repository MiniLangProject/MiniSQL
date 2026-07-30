package minisql.executor.executor

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

struct QueryResult
  kind
  command
  columns
  rows
  affectedRows
  message
end struct

struct PreparedStatementState
  name
  statement
  parameterCount
  schemaGeneration
end struct

struct SequenceSessionValue
  name
  value
end struct

struct Engine
  database
  ownsDatabase
  explicitTransaction
  transactionMode
  pageTransaction
  ddlTransaction
  failed
  closed
  trusted
  principalId
  preparedStatements
  sessionId
  sequenceValues
  triggerDepth
end struct

function fail(code, operation, message)
  return error(code, "executor.executor." + operation + ": " + message)
end function

function isQueryResult(value)
  return value is QueryResult
end function

function isEngine(value)
  return value is Engine
end function

function commandResult(command, affectedRows, message)
  return QueryResult(RESULT_COMMAND, command, [], [], affectedRows, message)
end function

function rowResult(columns, rows)
  return QueryResult(RESULT_ROWS, "SELECT", columns, rows, len(rows), "")
end function

function attach(database)
  if not database_manager.isManagedDatabase(database) then return fail(INVALID_ARGUMENT, "attach", "database must be ManagedDatabase") end if
  engine = Engine(database, false, false, MODE_NONE, void, void, false, false, true, metadata.PRINCIPAL_ADMIN_ID, [], database_manager.allocateSessionId(database), [], 0)
  dml.ensureIndexes(database)
  return engine
end function

function open(databasePath)
  database = database_manager.open(databasePath)
  engine = Engine(database, true, false, MODE_NONE, void, void, false, false, true, metadata.PRINCIPAL_ADMIN_ID, [], database_manager.allocateSessionId(database), [], 0)
  indexed = try(dml.ensureIndexes(database))
  if typeof(indexed) == "error" then database_manager.close(database); return indexed end if
  return engine
end function

function setPrincipal(engine, principalId)
  validateOpen(engine, "setPrincipal")
  principal = catalog.findPrincipalByIdInState(engine.database.catalogHandle.security, principalId)
  if principal is void or not principal.enabled or not principal.canLogin or principal.principalKind != metadata.PRINCIPAL_USER then return fail(AUTHENTICATION_REQUIRED, "setPrincipal", "principal is unavailable") end if
  engine.trusted = false
  engine.principalId = principalId
  return true
end function

function principal(engine)
  validateOpen(engine, "principal")
  return catalog.findPrincipalByIdInState(engine.database.catalogHandle.security, engine.principalId)
end function

function validateOpen(engine, operation)
  if engine is not Engine then return fail(INVALID_ARGUMENT, operation, "engine must be Engine") end if
  if engine.closed then return fail(CLOSED_HANDLE, operation, "engine is closed") end if
  return true
end function

function isPreparedStatementState(value)
  return value is PreparedStatementState
end function

function isSequenceSessionValue(value)
  return value is SequenceSessionValue
end function

function sequenceArgumentName(expression, operation)
  if ast.isLiteralExpression(expression) and expression.literalKind == ast.LITERAL_STRING then return expression.value end if
  if ast.isTypedLiteralExpression(expression) and values.isSqlValue(expression.value) and not expression.value.isNull and typeof(expression.value.value) == "string" then return expression.value.value end if
  return fail(BINDING_ERROR, operation, "sequence name must be a string literal")
end function

function rememberSequenceValue(engine, name, value)
  if len(engine.sequenceValues) > 0 then
    for index = 0 to len(engine.sequenceValues) - 1
      if engine.sequenceValues[index].name == name then engine.sequenceValues[index].value = value; return true end if
    end for
  end if
  engine.sequenceValues = engine.sequenceValues + [SequenceSessionValue(name, value)]
  return true
end function

function currentSequenceValue(engine, name)
  for each current in engine.sequenceValues
    if current.name == name then return current.value end if
  end for
  return fail(BINDING_ERROR, "currval", "CURRVAL is not defined in this session for sequence " + name)
end function

function currentSchemaGeneration(engine)
  state = schema_history.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
  return state.generation
end function

function findPreparedIndex(engine, name)
  if typeof(name) != "string" then return fail(INVALID_ARGUMENT, "findPreparedIndex", "name must be string") end if
  if len(engine.preparedStatements) > 0 then
    for index = 0 to len(engine.preparedStatements) - 1
      if engine.preparedStatements[index].name == name then return index end if
    end for
  end if
  return -1
end function

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
    ctes = ctes + [ast.CommonTableExpression(cte.name, substituteSelect(cte.query, parameters), cte.columnNames)]
  end for
  return ast.SelectStatement(statement.distinct, items, statement.tableName, statement.tableAlias, joins, whereExpression, groups, havingExpression, setOperations, orderBy, statement.limit, statement.offset, ctes)
end function

function substituteReturning(items, parameters)
  output = []
  for each item in items
    output = output + [ast.SelectItem(substituteExpression(item.expression, parameters), item.alias)]
  end for
  return output
end function

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

function materializeExpression(engine, expression, pageTransaction)
  if ast.isLiteralExpression(expression) or ast.isTypedLiteralExpression(expression) or ast.isColumnExpression(expression) or ast.isStarExpression(expression) or ast.isParameterExpression(expression) then return expression end if
  if ast.isUnaryExpression(expression) then return ast.unaryExpression(expression.operator, materializeExpression(engine, expression.operand, pageTransaction)) end if
  if ast.isBinaryExpression(expression) then return ast.binaryExpression(expression.operator, materializeExpression(engine, expression.left, pageTransaction), materializeExpression(engine, expression.right, pageTransaction)) end if
  if ast.isIsNullExpression(expression) then return ast.isNullExpression(materializeExpression(engine, expression.operand, pageTransaction), expression.negated) end if
  if ast.isCaseExpression(expression) then
    branches = []
    for each branch in expression.branches
      branches = branches + [ast.caseBranch(materializeExpression(engine, branch.condition, pageTransaction), materializeExpression(engine, branch.result, pageTransaction))]
    end for
    elseExpression = void
    if expression.elseExpression is not void then elseExpression = materializeExpression(engine, expression.elseExpression, pageTransaction) end if
    return ast.caseExpression(branches, elseExpression)
  end if
  if ast.isCastExpression(expression) then return ast.castExpression(materializeExpression(engine, expression.operand, pageTransaction), expression.targetType) end if
  if ast.isInExpression(expression) then
    candidates = []
    for each candidate in expression.values
      candidates = candidates + [materializeExpression(engine, candidate, pageTransaction)]
    end for
    return ast.inExpression(materializeExpression(engine, expression.operand, pageTransaction), candidates, expression.negated)
  end if
  if ast.isBetweenExpression(expression) then return ast.betweenExpression(materializeExpression(engine, expression.operand, pageTransaction), materializeExpression(engine, expression.lower, pageTransaction), materializeExpression(engine, expression.upper, pageTransaction), expression.negated) end if
  if ast.isTruthTestExpression(expression) then return ast.truthTestExpression(materializeExpression(engine, expression.operand, pageTransaction), expression.expected, expression.negated) end if
  if ast.isFunctionExpression(expression) then
    if expression.name == "NEXTVAL" or expression.name == "CURRVAL" then
      if len(expression.arguments) != 1 then return fail(BINDING_ERROR, "materializeExpression", expression.name + " requires one sequence-name argument") end if
      sequenceName = sequenceArgumentName(expression.arguments[0], "materializeExpression")
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
      arguments = arguments + [materializeExpression(engine, argument, pageTransaction)]
    end for
    return ast.functionExpression(expression.name, arguments, expression.distinct)
  end if
  if ast.isWindowExpression(expression) then
    arguments = []
    partitions = []
    orders = []
    for each argument in expression.arguments
      arguments = arguments + [materializeExpression(engine, argument, pageTransaction)]
    end for
    for each value in expression.partitionBy
      partitions = partitions + [materializeExpression(engine, value, pageTransaction)]
    end for
    for each value in expression.orderBy
      orders = orders + [ast.OrderItem(materializeExpression(engine, value.expression, pageTransaction), value.descending, value.nullsFirst, value.nullsSpecified)]
    end for
    return ast.windowExpression(expression.name, arguments, partitions, orders)
  end if
  if ast.isSubqueryExpression(expression) or ast.isExistsExpression(expression) or ast.isInSubqueryExpression(expression) then
    query = expression.query
    query = materializeSelectStatement(engine, query, pageTransaction)
    bound = binder.bindSelect(query, engine.database.catalogHandle)
    result = selectRows(engine, bound, pageTransaction)
    if ast.isExistsExpression(expression) then return ast.typedLiteralExpression(values.boolean(len(result.rows) > 0)) end if
    if ast.isSubqueryExpression(expression) then
      if len(bound.items) != 1 then return fail(BINDING_ERROR, "materializeExpression", "scalar subquery must return exactly one column") end if
      if len(result.rows) > 1 then return fail(BINDING_ERROR, "materializeExpression", "scalar subquery returned more than one row") end if
      if len(result.rows) == 0 then return ast.typedLiteralExpression(values.nullValue(bound.items[0].typeInfo.kind)) end if
      return ast.typedLiteralExpression(result.rows[0][0])
    end if
    operand = materializeExpression(engine, expression.operand, pageTransaction)
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

function materializeSelectStatement(engine, statement, pageTransaction)
  items = []
  for each item in statement.items
    items = items + [ast.SelectItem(materializeExpression(engine, item.expression, pageTransaction), item.alias)]
  end for
  joins = []
  for each value in statement.joins
    condition = void
    if value.condition is not void then condition = materializeExpression(engine, value.condition, pageTransaction) end if
    joins = joins + [ast.JoinClause(value.joinType, value.tableName, value.tableAlias, condition)]
  end for
  whereExpression = void
  if statement.whereExpression is not void then whereExpression = materializeExpression(engine, statement.whereExpression, pageTransaction) end if
  groups = []
  for each value in statement.groupBy
    groups = groups + [materializeExpression(engine, value, pageTransaction)]
  end for
  havingExpression = void
  if statement.havingExpression is not void then havingExpression = materializeExpression(engine, statement.havingExpression, pageTransaction) end if
  setOperations = []
  for each value in statement.setOperations
    setOperations = setOperations + [ast.SetOperation(value.operator, value.all, materializeSelectStatement(engine, value.query, pageTransaction))]
  end for
  orderBy = []
  for each value in statement.orderBy
    orderBy = orderBy + [ast.OrderItem(materializeExpression(engine, value.expression, pageTransaction), value.descending, value.nullsFirst, value.nullsSpecified)]
  end for
  ctes = []
  for each cte in statement.ctes
    ctes = ctes + [ast.CommonTableExpression(cte.name, materializeSelectStatement(engine, cte.query, pageTransaction), cte.columnNames)]
  end for
  return ast.SelectStatement(statement.distinct, items, statement.tableName, statement.tableAlias, joins, whereExpression, groups, havingExpression, setOperations, orderBy, statement.limit, statement.offset, ctes)
end function

function materializeDmlStatement(engine, statement, pageTransaction)
  if ast.isInsertStatement(statement) then
    rows = []
    for each sourceRow in statement.rows
      row = []
      for each expression in sourceRow
        row = row + [materializeExpression(engine, expression, pageTransaction)]
      end for
      rows = rows + [row]
    end for
    sourceQuery = void
    if statement.sourceQuery is not void then sourceQuery = materializeSelectStatement(engine, statement.sourceQuery, pageTransaction) end if
    assignments = []
    for each assignment in statement.conflictAssignments
      assignments = assignments + [ast.Assignment(assignment.column, materializeExpression(engine, assignment.expression, pageTransaction))]
    end for
    conflictWhere = void
    if statement.conflictWhere is not void then conflictWhere = materializeExpression(engine, statement.conflictWhere, pageTransaction) end if
    returning = []
    for each item in statement.returning
      returning = returning + [ast.SelectItem(materializeExpression(engine, item.expression, pageTransaction), item.alias)]
    end for
    return ast.InsertStatement(statement.tableName, statement.columns, rows, sourceQuery, statement.conflictTarget, statement.conflictAction, assignments, conflictWhere, returning)
  end if
  if ast.isUpdateStatement(statement) then
    assignments = []
    for each assignment in statement.assignments
      assignments = assignments + [ast.Assignment(assignment.column, materializeExpression(engine, assignment.expression, pageTransaction))]
    end for
    whereExpression = void
    if statement.whereExpression is not void then whereExpression = materializeExpression(engine, statement.whereExpression, pageTransaction) end if
    returning = []
    for each item in statement.returning
      returning = returning + [ast.SelectItem(materializeExpression(engine, item.expression, pageTransaction), item.alias)]
    end for
    return ast.UpdateStatement(statement.tableName, assignments, whereExpression, returning)
  end if
  if ast.isDeleteStatement(statement) then
    whereExpression = void
    if statement.whereExpression is not void then whereExpression = materializeExpression(engine, statement.whereExpression, pageTransaction) end if
    returning = []
    for each item in statement.returning
      returning = returning + [ast.SelectItem(materializeExpression(engine, item.expression, pageTransaction), item.alias)]
    end for
    return ast.DeleteStatement(statement.tableName, whereExpression, returning)
  end if
  return statement
end function

function executePrepare(engine, statement)
  if findPreparedIndex(engine, statement.name) >= 0 then return fail(BINDING_ERROR, "prepare", "prepared statement already exists: " + statement.name) end if
  engine.preparedStatements = engine.preparedStatements + [PreparedStatementState(statement.name, statement.statement, statement.parameterCount, currentSchemaGeneration(engine))]
  return commandResult("PREPARE", 0, statement.name + " parameters=" + statement.parameterCount)
end function

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
  return executeStatement(engine, expanded)
end function

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

function resetTransaction(engine)
  engine.explicitTransaction = false
  engine.transactionMode = MODE_NONE
  engine.pageTransaction = void
  engine.ddlTransaction = void
  engine.failed = false
  return true
end function

function isolationValue(name)
  if name == "READ COMMITTED" then return transaction.ISOLATION_READ_COMMITTED end if
  return transaction.ISOLATION_SERIALIZABLE
end function

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

function ensureExplicitDml(engine)
  if engine.transactionMode == MODE_DDL then return fail(UNSUPPORTED_SQL, "ensureExplicitDml", "mixing DDL and DML in one M15 transaction is not supported") end if
  if engine.transactionMode == MODE_NONE then
    options = engine.pageTransaction
    engine.pageTransaction = database_manager.begin(engine.database, options[0], options[1])
    engine.transactionMode = MODE_DML
  end if
  return engine.pageTransaction
end function

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

function bind(statement, engine)
  return binder.bindStatement(statement, engine.database.catalogHandle)
end function

function stageDdl(ddlTransaction, bound)
  if binder.isBoundCreateTable(bound) then schema_history.stageCreateTable(ddlTransaction, bound); return "CREATE TABLE" end if
  if binder.isBoundCreateIndex(bound) then schema_history.stageCreateIndex(ddlTransaction, bound); return "CREATE INDEX" end if
  if binder.isBoundDropTable(bound) then schema_history.stageDropTable(ddlTransaction, bound); return "DROP TABLE" end if
  if binder.isBoundAlterTable(bound) then schema_history.stageAlterTable(ddlTransaction, bound); return "ALTER TABLE" end if
  return fail(BINDING_ERROR, "stageDdl", "unsupported bound DDL statement")
end function

function executeViewDdl(engine, statement)
  if engine.explicitTransaction then return fail(UNSUPPORTED_SQL, "executeViewDdl", "view DDL is autocommit-only in M43") end if
  database = engine.database.catalogHandle
  databaseId = database.metadata.databaseId
  if ast.isCreateViewStatement(statement) then
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

function triggerEventCode(bound)
  if binder.isBoundInsert(bound) then return schema_history.TRIGGER_INSERT end if
  if binder.isBoundUpdate(bound) then return schema_history.TRIGGER_UPDATE end if
  if binder.isBoundDelete(bound) then return schema_history.TRIGGER_DELETE end if
  return 0
end function

function triggerColumnValue(table, row, qualifier, columnName)
  if row is void then return fail(BINDING_ERROR, "triggerColumnValue", qualifier + "." + columnName + " is not available for this trigger event") end if
  columnIndex = binder.findColumnIndex(table, columnName)
  if columnIndex < 0 then return fail(BINDING_ERROR, "triggerColumnValue", "unknown trigger column " + columnName) end if
  return ast.typedLiteralExpression(row[columnIndex])
end function

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

function replaceTriggerReturning(items, table, oldRow, newRow)
  output = []
  for each item in items
    output = output + [ast.SelectItem(replaceTriggerExpression(item.expression, table, oldRow, newRow), item.alias)]
  end for
  return output
end function

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

function updateTouchesTriggerColumn(bound, trigger)
  if trigger.targetColumn == "" then return true end if
  targetIndex = binder.findColumnIndex(bound.table, trigger.targetColumn)
  if targetIndex < 0 then return false end if
  for each assignment in bound.assignments
    if assignment.columnIndex == targetIndex then return true end if
  end for
  return false
end function

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

function fireTriggers(engine, bound, result, pageTransaction)
  eventType = triggerEventCode(bound)
  if eventType == 0 or not dml.isDmlResult(result) then return result end if
  state = schema_history.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
  triggerList = schema_history.triggersForTable(state, bound.table.tableId, eventType)
  if len(triggerList) == 0 then return result end if
  for each trigger in triggerList
    if trigger.timing != schema_history.TRIGGER_AFTER then continue end if
    if eventType == schema_history.TRIGGER_UPDATE and not updateTouchesTriggerColumn(bound, trigger) then continue end if
    if eventType == schema_history.TRIGGER_INSERT then
      for each newRow in result.newRows
        executeTriggerBody(engine, trigger, bound.table, void, newRow, pageTransaction)
      end for
    else if eventType == schema_history.TRIGGER_DELETE then
      for each oldRow in result.oldRows
        executeTriggerBody(engine, trigger, bound.table, oldRow, void, pageTransaction)
      end for
    else
      count = len(result.newRows)
      if len(result.oldRows) < count then count = len(result.oldRows) end if
      if count > 0 then
        for index = 0 to count - 1
          executeTriggerBody(engine, trigger, bound.table, result.oldRows[index], result.newRows[index], pageTransaction)
        end for
      end if
    end if
  end for
  return result
end function

function executeTriggerDdl(engine, statement)
  if engine.explicitTransaction then return fail(UNSUPPORTED_SQL, "executeTriggerDdl", "trigger DDL is autocommit-only in M45") end if
  database = engine.database.catalogHandle
  databaseId = database.metadata.databaseId
  if ast.isCreateTriggerStatement(statement) then
    if statement.timing != "AFTER" then return fail(UNSUPPORTED_SQL, "executeTriggerDdl", "M45 supports AFTER triggers only") end if
    table = catalog.findTable(database, statement.tableName)
    if table is void then return fail(BINDING_ERROR, "executeTriggerDdl", "unknown trigger table " + statement.tableName) end if
    eventType = schema_history.TRIGGER_INSERT
    if statement.eventType == "UPDATE" then eventType = schema_history.TRIGGER_UPDATE else if statement.eventType == "DELETE" then eventType = schema_history.TRIGGER_DELETE end if
    if statement.targetColumn != "" and binder.findColumnIndex(table, statement.targetColumn) < 0 then return fail(BINDING_ERROR, "executeTriggerDdl", "unknown trigger target column " + statement.targetColumn) end if
    // Parse/bind the body once at CREATE time. OLD/NEW references are replaced
    // by typed literals at execution time and therefore intentionally remain
    // unresolved here; the target statement itself is validated after a sample
    // replacement in the acceptance suite.
    created = schema_history.putTrigger(engine.database.path, databaseId, statement.name, table.tableId, schema_history.TRIGGER_AFTER, eventType, statement.targetColumn, ast.formatStatement(statement.body), statement.ifNotExists)
    return commandResult("CREATE TRIGGER", 0, created.name)
  end if
  if ast.isDropTriggerStatement(statement) then
    dropped = schema_history.dropTrigger(engine.database.path, databaseId, statement.name, statement.ifExists)
    count = 0
    if dropped then count = 1 end if
    return commandResult("DROP TRIGGER", count, statement.name)
  end if
  return fail(BINDING_ERROR, "executeTriggerDdl", "unsupported trigger DDL")
end function

function executeSequenceDdl(engine, statement)
  if engine.explicitTransaction then return fail(UNSUPPORTED_SQL, "executeSequenceDdl", "sequence DDL is autocommit-only in M45") end if
  database = engine.database.catalogHandle
  databaseId = database.metadata.databaseId
  if ast.isCreateSequenceStatement(statement) then
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

function executeDdl(engine, statement)
  if ast.isCreateTableStatement(statement) then
    state = schema_history.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
    if schema_history.findView(state, statement.name) is not void then return fail(BINDING_ERROR, "executeDdl", "view already exists with name " + statement.name) end if
  end if
  bound = bind(statement, engine)
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
  rebuilt = try(dml.rebuildAllIndexes(engine.database))
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

function runBoundDml(engine, bound, pageTransaction)
  if binder.isBoundInsert(bound) then return dml.insert(engine.database, bound, pageTransaction) end if
  if binder.isBoundUpdate(bound) then return dml.update(engine.database, bound, pageTransaction) end if
  if binder.isBoundDelete(bound) then return dml.delete(engine.database, bound, pageTransaction) end if
  if binder.isBoundTruncate(bound) then return dml.truncate(engine.database, bound, pageTransaction) end if
  return fail(BINDING_ERROR, "runBoundDml", "unsupported bound DML statement")
end function

function dmlCommand(bound)
  if binder.isBoundInsert(bound) then return "INSERT" end if
  if binder.isBoundUpdate(bound) then return "UPDATE" end if
  if binder.isBoundDelete(bound) then return "DELETE" end if
  if binder.isBoundTruncate(bound) then return "TRUNCATE" end if
  return "DML"
end function

function commitPageTransaction(engine, pageTransaction)
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
  for each tableId in changedIds
    table = catalog.findTableById(engine.database.catalogHandle, tableId)
    if table is not void and rebuildError is void then
      rebuilt = try(dml.rebuildIndexesForTable(engine.database, table))
      if typeof(rebuilt) == "error" then rebuildError = rebuilt end if
    end if
  end for
  if rebuildError is void then dml.clearIndexesDirty(engine.database) end if
  // The heap/WAL commit is already durable. A failed derived-index rebuild leaves
  // the durable dirty marker in place and is repaired before the next index use.
  return commitLsn
end function

function materializeInsertSelect(engine, bound, pageTransaction)
  if not binder.isBoundInsert(bound) or bound.sourceQuery is void then return true end if
  sourceResult = selectRows(engine, bound.sourceQuery, pageTransaction)
  if not isQueryResult(sourceResult) then return fail(INVALID_ARGUMENT, "materializeInsertSelect", "source SELECT must return QueryResult") end if
  sourceRows = sourceResult.rows
  materialized = []
  for each sourceRow in sourceRows
    boundRow = []
    if len(sourceRow) > 0 then
      for index = 0 to len(sourceRow) - 1
        boundRow = boundRow + [expressions.literal(sourceRow[index], bound.sourceQuery.items[index].typeInfo)]
      end for
    end if
    materialized = materialized + [boundRow]
  end for
  bound.rows = materialized
  return true
end function

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
  committed = try(commitPageTransaction(engine, pageTransaction))
  if typeof(committed) == "error" then return committed end if
  if (binder.isBoundInsert(bound) or binder.isBoundUpdate(bound) or binder.isBoundDelete(bound)) and len(bound.returning) > 0 then return returningResult(bound, result) end if
  return commandResult(dmlCommand(bound), result.affectedRows, "DML committed")
end function

function scanBoundSource(engine, source, pageTransaction)
  if source.query is void then return scan.scanTable(engine.database.path, source.table, pageTransaction) end if
  result = selectRows(engine, source.query, pageTransaction)
  output = []
  for each row in result.rows
    output = output + [scan.ScannedRow(void, row)]
  end for
  return output
end function

function joinedSource(engine, bound, pageTransaction)
  if len(bound.sources) == 0 then return [scan.ScannedRow(void, [])] end if
  output = dml.indexRowsForBound(engine.database, bound, pageTransaction)
  if output is void then output = scanBoundSource(engine, bound.sources[0], pageTransaction) end if
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
      right = scanBoundSource(engine, boundJoin.source, pageTransaction)
      if join.canHash(boundJoin) then
        output = join.applyHash(output, right, boundJoin)
      else
        output = join.apply(output, right, boundJoin)
      end if
    end if
  end for
  return output
end function

function itemIndex(bound, expression)
  if len(bound.items) == 0 then return -1 end if
  for index = 0 to len(bound.items) - 1
    if expressions.sameBinding(bound.items[index], expression) then return index end if
  end for
  return -1
end function

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

function selectProjected(engine, bound, pageTransaction)
  source = joinedSource(engine, bound, pageTransaction)
  filtered = filter.apply(source, bound.whereExpression)
  projected = []
  if bound.aggregateQuery then
    projected = aggregate.project(filtered, bound.items, bound.groupExpressions, bound.havingExpression, bound.orderExpressions)
  else if bound.windowQuery then
    projected = projection.applyWindows(filtered, bound.items, bound.orderExpressions)
  else
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
  projected = projection.sliceRows(projected, bound.statement.offset, bound.statement.limit)
  return projected
end function

function selectRows(engine, bound, pageTransaction)
  projected = selectProjected(engine, bound, pageTransaction)
  rows = []
  for each value in projected
    rows = rows + [value.values]
  end for
  return rowResult(bound.itemNames, rows)
end function

function loadStatistics(engine)
  return statistics.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
end function

function analyzeTable(engine, state, table)
  rows = scan.scanTable(engine.database.path, table, void)
  tableFile = paged_file.open(catalog.tableFilePath(engine.database.path, table.tableId))
  pageCount = tableFile.pageCount
  paged_file.close(tableFile)
  return statistics.replaceTable(state, statistics.analyzeTable(table, rows, pageCount))
end function

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

function explainBound(bound)
  logical = logical_plan.build(bound)
  physical = physical_plan.fromLogical(logical)
  return physical_plan.render(physical)
end function

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

function executeSelect(engine, statement)
  if engine.explicitTransaction and engine.failed then return fail(TRANSACTION_STATE, "select", "transaction is failed; ROLLBACK required") end if
  if engine.transactionMode != MODE_DML then dml.ensureIndexes(engine.database) end if
  if engine.explicitTransaction and engine.transactionMode == MODE_DDL then return fail(UNSUPPORTED_SQL, "select", "SELECT after staged DDL is not supported in M15") end if
  pageTransaction = void
  if engine.explicitTransaction and engine.transactionMode == MODE_DML then pageTransaction = engine.pageTransaction end if
  materialized = materializeSelectStatement(engine, statement, pageTransaction)
  bound = binder.bindSelect(materialized, engine.database.catalogHandle)
  return selectRows(engine, bound, pageTransaction)
end function

function commitExplicit(engine)
  if not engine.explicitTransaction then return fail(TRANSACTION_STATE, "commit", "no explicit transaction") end if
  if engine.failed then return fail(TRANSACTION_STATE, "commit", "transaction is failed; ROLLBACK required") end if
  if engine.transactionMode == MODE_DML then
    commitPageTransaction(engine, engine.pageTransaction)
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

function rollbackExplicit(engine)
  if not engine.explicitTransaction then return fail(TRANSACTION_STATE, "rollback", "no explicit transaction") end if
  if engine.transactionMode == MODE_DML then transaction.rollback(engine.pageTransaction) end if
  if engine.transactionMode == MODE_DDL then schema_history.rollback(engine.ddlTransaction) end if
  database_manager.releaseLocks(engine.database, engine.sessionId)
  resetTransaction(engine)
  return commandResult("ROLLBACK", 0, "transaction rolled back")
end function

function executeSavepoint(engine, statement)
  if not engine.explicitTransaction then return fail(TRANSACTION_STATE, "savepoint", "SAVEPOINT requires an explicit transaction") end if
  if engine.transactionMode == MODE_DDL then return fail(UNSUPPORTED_SQL, "savepoint", "DDL savepoints are not supported") end if
  pageTransaction = ensureExplicitDml(engine)
  transaction.savepoint(pageTransaction, statement.name)
  return commandResult("SAVEPOINT", 0, statement.name)
end function

function executeRollbackTo(engine, statement)
  if not engine.explicitTransaction or engine.transactionMode != MODE_DML then return fail(TRANSACTION_STATE, "rollbackTo", "ROLLBACK TO requires a DML savepoint") end if
  transaction.rollbackToSavepoint(engine.pageTransaction, statement.name)
  engine.failed = false
  return commandResult("ROLLBACK TO", 0, statement.name)
end function

function executeReleaseSavepoint(engine, statement)
  if not engine.explicitTransaction or engine.transactionMode != MODE_DML then return fail(TRANSACTION_STATE, "releaseSavepoint", "RELEASE requires a DML savepoint") end if
  transaction.releaseSavepoint(engine.pageTransaction, statement.name)
  return commandResult("RELEASE", 0, statement.name)
end function

// ---------------------------------------------------------------------------
// M21 authorization and DCL
// ---------------------------------------------------------------------------

function permissionFailure(operation, detail)
  return fail(PERMISSION_DENIED, operation, "permission denied: " + detail)
end function

function databaseHandle(engine)
  return engine.database.catalogHandle
end function

function hasDatabaseAdmin(engine)
  if engine.trusted then return true end if
  return catalog.hasPrivilege(databaseHandle(engine), engine.principalId, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_ADMIN, false)
end function

function requirePrivilege(engine, objectType, objectId, privilege, operation)
  if engine.trusted then return true end if
  if catalog.hasPrivilege(databaseHandle(engine), engine.principalId, objectType, objectId, privilege, false) then return true end if
  return permissionFailure(operation, "required privilege " + privilege + " on object " + objectId)
end function

function requireGrantOption(engine, objectType, objectId, privilege, operation)
  if engine.trusted or hasDatabaseAdmin(engine) then return true end if
  if catalog.hasPrivilege(databaseHandle(engine), engine.principalId, objectType, objectId, privilege, true) then return true end if
  return permissionFailure(operation, "grant option is required")
end function

function requireTablePrivilegeByName(engine, tableName, privilege, operation)
  table = catalog.findTable(databaseHandle(engine), tableName)
  if table is void then return fail(BINDING_ERROR, operation, "unknown table " + tableName) end if
  requirePrivilege(engine, metadata.OBJECT_TABLE, table.tableId, privilege, operation)
  return table
end function

function nameInList(names, name)
  for each existing in names
    if existing == name then return true end if
  end for
  return false
end function

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

function authorizeNamedSource(engine, state, name, viewStack)
  table = catalog.findTable(databaseHandle(engine), name)
  if table is not void then
    requirePrivilege(engine, metadata.OBJECT_TABLE, table.tableId, metadata.PRIVILEGE_SELECT, "authorizeSelect")
    return true
  end if
  view = schema_history.findView(state, name)
  if view is void then return fail(BINDING_ERROR, "authorizeSelect", "unknown table or view " + name) end if
  if nameInList(viewStack, name) then return fail(BINDING_ERROR, "authorizeSelect", "cyclic view dependency involving " + name) end if
  parsed = parser.parseSql(view.sqlText)
  if len(parsed) != 1 or not ast.isSelectStatement(parsed[0]) then return fail(CORRUPT_DATA, "authorizeSelect", "stored view is not a single SELECT") end if
  // A persisted view is bound in its own query scope. CTE names from the caller
  // must not leak into the stored definition.
  return authorizeSelectInternal(engine, parsed[0], viewStack + [name], [])
end function

function authorizeSelectInternal(engine, statement, viewStack, inheritedCteNames)
  state = schema_history.loadOrCreate(engine.database.path, engine.database.catalogHandle.metadata.databaseId)
  availableCtes = inheritedCteNames
  // Nonrecursive CTEs are visible in declaration order and remain visible to
  // the main query and nested subqueries. Each CTE is authorized against only
  // the definitions that precede it.
  for each cte in statement.ctes
    authorizeSelectInternal(engine, cte.query, viewStack, availableCtes)
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

function authorizeSelect(engine, statement)
  return authorizeSelectInternal(engine, statement, [], [])
end function

function authorizeSelectItems(engine, items)
  for each item in items
    authorizeExpressionQueriesInternal(engine, item.expression, [], [])
  end for
  return true
end function

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
  if ast.isTruncateStatement(statement) then requireTablePrivilegeByName(engine, statement.tableName, metadata.PRIVILEGE_DELETE, "authorizeTruncate"); return true end if
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
  if ast.isDropTriggerStatement(statement) then return requirePrivilege(engine, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CREATE, "authorizeDropTrigger") end if
  if ast.isCreateIndexStatement(statement) then requireTablePrivilegeByName(engine, statement.tableName, metadata.PRIVILEGE_INDEX, "authorizeCreateIndex"); return true end if
  if ast.isDropTableStatement(statement) then requireTablePrivilegeByName(engine, statement.name, metadata.PRIVILEGE_DROP, "authorizeDropTable"); return true end if
  if ast.isAlterTableStatement(statement) then requireTablePrivilegeByName(engine, statement.tableName, metadata.PRIVILEGE_ALTER, "authorizeAlterTable"); return true end if
  if ast.isAnalyzeStatement(statement) then return requirePrivilege(engine, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_MAINTAIN, "authorizeAnalyze") end if
  if ast.isVacuumStatement(statement) or ast.isReindexStatement(statement) then return requirePrivilege(engine, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_MAINTAIN, "authorizeMaintenance") end if
  if ast.isExplainStatement(statement) then return authorizeStatement(engine, statement.statement) end if
  return permissionFailure("authorizeStatement", "statement is not authorized")
end function

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

function allPrivilegeCodes(objectType)
  if objectType == metadata.OBJECT_DATABASE then return [metadata.PRIVILEGE_CONNECT, metadata.PRIVILEGE_CREATE, metadata.PRIVILEGE_MAINTAIN, metadata.PRIVILEGE_ADMIN] end if
  return [metadata.PRIVILEGE_SELECT, metadata.PRIVILEGE_INSERT, metadata.PRIVILEGE_UPDATE, metadata.PRIVILEGE_DELETE, metadata.PRIVILEGE_REFERENCES, metadata.PRIVILEGE_INDEX, metadata.PRIVILEGE_ALTER, metadata.PRIVILEGE_DROP]
end function

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

function dclTarget(engine, objectType, objectName)
  if objectType == ast.DCL_OBJECT_DATABASE then return [metadata.OBJECT_DATABASE, 0] end if
  table = catalog.findTable(databaseHandle(engine), objectName)
  if table is void then return fail(BINDING_ERROR, "dclTarget", "unknown table " + objectName) end if
  return [metadata.OBJECT_TABLE, table.tableId]
end function

function requireSecurityAdmin(engine, operation)
  if engine.trusted or hasDatabaseAdmin(engine) then return true end if
  return permissionFailure(operation, "database ADMIN privilege is required")
end function

function executeCreatePrincipal(engine, statement)
  requireSecurityAdmin(engine, "createPrincipal")
  if statement.principalKind == ast.PRINCIPAL_USER then
    catalog.createUser(databaseHandle(engine), statement.name, statement.password)
    return commandResult("CREATE USER", 0, statement.name)
  end if
  catalog.createRole(databaseHandle(engine), statement.name)
  return commandResult("CREATE ROLE", 0, statement.name)
end function

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

function executeGrantRole(engine, statement)
  role = catalog.requirePrincipal(databaseHandle(engine), statement.roleName, "grantRole")
  if not engine.trusted and not hasDatabaseAdmin(engine) and not catalog.hasRoleAdminOption(databaseHandle(engine), engine.principalId, role.principalId) then return permissionFailure("grantRole", "ADMIN OPTION for role is required") end if
  catalog.grantRole(databaseHandle(engine), statement.roleName, statement.memberName, engine.principalId, statement.adminOption)
  return commandResult("GRANT ROLE", 0, statement.roleName + " TO " + statement.memberName)
end function

function executeRevokeRole(engine, statement)
  role = catalog.requirePrincipal(databaseHandle(engine), statement.roleName, "revokeRole")
  if not engine.trusted and not hasDatabaseAdmin(engine) and not catalog.hasRoleAdminOption(databaseHandle(engine), engine.principalId, role.principalId) then return permissionFailure("revokeRole", "ADMIN OPTION for role is required") end if
  catalog.revokeRoleWithBehavior(databaseHandle(engine), statement.roleName, statement.memberName, statement.cascade)
  return commandResult("REVOKE ROLE", 0, statement.roleName + " FROM " + statement.memberName)
end function

function executeGrantPrivilege(engine, statement)
  target = dclTarget(engine, statement.objectType, statement.objectName)
  codes = privilegeCodes(statement.privileges, target[0])
  for each code in codes
    requireGrantOption(engine, target[0], target[1], code, "grantPrivilege")
  end for
  catalog.grantPrivileges(databaseHandle(engine), statement.granteeName, engine.principalId, target[0], target[1], codes, statement.grantOption)
  return commandResult("GRANT", len(codes), statement.granteeName)
end function

function executeRevokePrivilege(engine, statement)
  target = dclTarget(engine, statement.objectType, statement.objectName)
  codes = privilegeCodes(statement.privileges, target[0])
  for each code in codes
    requireGrantOption(engine, target[0], target[1], code, "revokePrivilege")
  end for
  catalog.revokePrivilegesWithBehavior(databaseHandle(engine), statement.granteeName, target[0], target[1], codes, statement.cascade)
  return commandResult("REVOKE", len(codes), statement.granteeName)
end function

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

function executeReindex(engine, statement)
  if engine.explicitTransaction then return fail(UNSUPPORTED_SQL, "reindex", "REINDEX is autocommit-only") end if
  rebuilt = dml.reindex(engine.database, statement.name)
  return commandResult("REINDEX", rebuilt, "indexes rebuilt")
end function

function typeDescription(column)
  name = types.kindName(column.typeCode)
  if column.typeCode == types.SqlTypeKind.Char or column.typeCode == types.SqlTypeKind.VarChar or column.typeCode == types.SqlTypeKind.Binary or column.typeCode == types.SqlTypeKind.VarBinary then return name + "(" + column.maxLength + ")" end if
  if column.typeCode == types.SqlTypeKind.Decimal then return name + "(" + column.precision + "," + column.scale + ")" end if
  if column.typeCode == types.SqlTypeKind.Time or column.typeCode == types.SqlTypeKind.Timestamp then return name + "(" + column.precision + ")" end if
  return name
end function

function findColumnRule(tableSchema, columnName)
  if tableSchema is void then return void end if
  for each rule in tableSchema.columnRules
    if rule.columnName == columnName then return rule end if
  end for
  return void
end function

function constraintKindName(kind)
  if kind == schema_history.CONSTRAINT_PRIMARY_KEY then return "PRIMARY KEY" end if
  if kind == schema_history.CONSTRAINT_UNIQUE then return "UNIQUE" end if
  if kind == schema_history.CONSTRAINT_INDEX then return "INDEX" end if
  if kind == schema_history.CONSTRAINT_FOREIGN_KEY then return "FOREIGN KEY" end if
  if kind == schema_history.CONSTRAINT_CHECK then return "CHECK" end if
  return "UNKNOWN"
end function

function joinNames(names)
  output = ""
  for each name in names
    if len(output) > 0 then output = output + ", " end if
    output = output + name
  end for
  return output
end function

function executeShowTables(engine)
  rows = []
  for each table in engine.database.catalogHandle.catalog.tables
    rows = rows + [[values.text(table.name), values.integer(len(table.columns)), values.integer(table.schemaVersion)]]
  end for
  return rowResult(["table_name", "column_count", "schema_version"], rows)
end function

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
  if ast.isCreateViewStatement(statement) or ast.isDropViewStatement(statement) then return executeViewDdl(engine, statement) end if
  if ast.isCreateSequenceStatement(statement) or ast.isDropSequenceStatement(statement) then return executeSequenceDdl(engine, statement) end if
  if ast.isCreateTriggerStatement(statement) or ast.isDropTriggerStatement(statement) then return executeTriggerDdl(engine, statement) end if
  if ast.isCreateTableStatement(statement) or ast.isCreateIndexStatement(statement) or ast.isDropTableStatement(statement) or ast.isAlterTableStatement(statement) then return executeDdl(engine, statement) end if
  if ast.isVacuumStatement(statement) then return executeVacuum(engine, statement) end if
  if ast.isReindexStatement(statement) then return executeReindex(engine, statement) end if
  if ast.isInsertStatement(statement) or ast.isUpdateStatement(statement) or ast.isDeleteStatement(statement) or ast.isTruncateStatement(statement) then return executeDml(engine, statement) end if
  if ast.isSelectStatement(statement) then return executeSelect(engine, statement) end if
  if ast.isAnalyzeStatement(statement) then return executeAnalyze(engine, statement) end if
  if ast.isExplainStatement(statement) then return executeExplain(engine, statement) end if
  return fail(UNSUPPORTED_SQL, "execute", "unsupported statement")
end function

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

function statementUsesReadLock(statement)
  if ast.isSelectStatement(statement) then return not selectUsesNextval(statement) end if
  if ast.isExplainStatement(statement) or ast.isMetadataStatement(statement) then return true end if
  return false
end function

function statementUsesWriteLock(statement)
  if ast.isSelectStatement(statement) and selectUsesNextval(statement) then return true end if
  if ast.isInsertStatement(statement) or ast.isUpdateStatement(statement) or ast.isDeleteStatement(statement) or ast.isTruncateStatement(statement) then return true end if
  if ast.isCreateTableStatement(statement) or ast.isCreateIndexStatement(statement) or ast.isDropTableStatement(statement) or ast.isAlterTableStatement(statement) or ast.isCreateViewStatement(statement) or ast.isDropViewStatement(statement) or ast.isCreateSequenceStatement(statement) or ast.isDropSequenceStatement(statement) or ast.isCreateTriggerStatement(statement) or ast.isDropTriggerStatement(statement) then return true end if
  if ast.isDclStatement(statement) or ast.isAnalyzeStatement(statement) or ast.isVacuumStatement(statement) or ast.isReindexStatement(statement) then return true end if
  return false
end function

function statementIsolation(engine)
  if not engine.explicitTransaction then return transaction.ISOLATION_READ_COMMITTED end if
  if engine.transactionMode == MODE_DML and engine.pageTransaction is not void and typeof(engine.pageTransaction) != "array" then return engine.pageTransaction.isolationLevel end if
  if engine.transactionMode == MODE_NONE and typeof(engine.pageTransaction) == "array" then return engine.pageTransaction[0] end if
  return transaction.ISOLATION_SERIALIZABLE
end function

function markExplicitFailure(engine)
  if not engine.explicitTransaction then return true end if
  engine.failed = true
  if engine.transactionMode == MODE_DML then
    ignored = try(transaction.markFailed(engine.pageTransaction))
  end if
  return true
end function

function auditAction(statement)
  if ast.isSelectStatement(statement) then return "SELECT" end if
  if ast.isInsertStatement(statement) then return "INSERT" end if
  if ast.isUpdateStatement(statement) then return "UPDATE" end if
  if ast.isDeleteStatement(statement) then return "DELETE" end if
  if ast.isTruncateStatement(statement) then return "TRUNCATE" end if
  if ast.isCreateTableStatement(statement) then return "CREATE TABLE" end if
  if ast.isCreateIndexStatement(statement) then return "CREATE INDEX" end if
  if ast.isDropTableStatement(statement) then return "DROP TABLE" end if
  if ast.isAlterTableStatement(statement) then return "ALTER TABLE" end if
  if ast.isCreateViewStatement(statement) then return "CREATE VIEW" end if
  if ast.isDropViewStatement(statement) then return "DROP VIEW" end if
  if ast.isCreateSequenceStatement(statement) then return "CREATE SEQUENCE" end if
  if ast.isDropSequenceStatement(statement) then return "DROP SEQUENCE" end if
  if ast.isCreateTriggerStatement(statement) then return "CREATE TRIGGER" end if
  if ast.isDropTriggerStatement(statement) then return "DROP TRIGGER" end if
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

function auditEventType(statement)
  if ast.isDclStatement(statement) then return diagnostics.AUDIT_DCL end if
  if ast.isCreateTableStatement(statement) or ast.isCreateIndexStatement(statement) or ast.isDropTableStatement(statement) or ast.isAlterTableStatement(statement) or ast.isCreateViewStatement(statement) or ast.isDropViewStatement(statement) or ast.isCreateSequenceStatement(statement) or ast.isDropSequenceStatement(statement) or ast.isCreateTriggerStatement(statement) or ast.isDropTriggerStatement(statement) or ast.isTruncateStatement(statement) then return diagnostics.AUDIT_DDL end if
  if ast.isAnalyzeStatement(statement) or ast.isVacuumStatement(statement) or ast.isReindexStatement(statement) then return diagnostics.AUDIT_MAINTENANCE end if
  return 0
end function

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

function executeStatement(engine, statement)
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

function executeSql(engine, sqlText)
  validateOpen(engine, "executeSql")
  statements = parser.parseSql(sqlText)
  results = []
  for each statement in statements
    results = results + [executeStatement(engine, statement)]
  end for
  return results
end function


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

function sessionIdentifier(engine)
  validateOpen(engine, "sessionIdentifier")
  return engine.sessionId
end function

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

function componentName()
  return "executor.executor"
end function

function targetMilestone()
  return "M15"
end function

function isImplemented()
  return true
end function
