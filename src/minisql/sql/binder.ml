package minisql.sql.binder

import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.catalog.schema_history as schema_history
import minisql.common.endian as endian
import minisql.sql.ast as ast
import minisql.sql.expressions as expressions
import minisql.sql.parser as parser
import minisql.sql.types as types
import minisql.sql.values as values

const INVALID_ARGUMENT = 9001
const OBJECT_NOT_FOUND = 9014
const TYPE_MISMATCH = 9017
const BINDING_ERROR = 9020
const CONSTRAINT_VIOLATION = 9021
const UNSUPPORTED_SQL = 9025

struct BoundSource
  table
  alias
  offset
  query
end struct

struct BoundNamedQuery
  name
  query
  table
end struct

struct BoundJoin
  joinType
  source
  condition
  leftTypes
end struct

struct BoundSetOperation
  operator
  all
  query
end struct

struct BoundSelect
  statement
  table
  sources
  joins
  items
  itemNames
  whereExpression
  groupExpressions
  havingExpression
  orderExpressions
  setOperations
  aggregateQuery
  windowQuery
end struct

struct BoundReturningItem
  expression
  name
end struct

struct BoundInsert
  statement
  table
  columnIndexes
  rows
  sourceQuery
  conflictConstraint
  conflictAssignments
  conflictWhere
  returning
end struct

struct BoundAssignment
  columnIndex
  expression
end struct

struct BoundUpdate
  statement
  table
  assignments
  whereExpression
  returning
  orderExpressions
end struct

struct BoundDelete
  statement
  table
  whereExpression
  returning
  orderExpressions
end struct

struct BoundTruncate
  statement
  table
end struct

struct BoundCreateTable
  statement
  columnTypes
end struct

struct BoundCreateIndex
  statement
  table
end struct

struct BoundDropIndex
  statement
  table
end struct

struct BoundDropTable
  statement
  table
end struct

struct BoundAlterTable
  statement
  table
  columnType
end struct

function fail(code, operation, message)
  return error(code, "sql.binder." + operation + ": " + message)
end function

function isBoundSource(value)
  return value is BoundSource
end function

function isBoundNamedQuery(value)
  return value is BoundNamedQuery
end function

function isBoundJoin(value)
  return value is BoundJoin
end function

function isBoundSetOperation(value)
  return value is BoundSetOperation
end function

function isBoundSelect(value)
  return value is BoundSelect
end function

function isBoundReturningItem(value)
  return value is BoundReturningItem
end function

function isBoundInsert(value)
  return value is BoundInsert
end function

function isBoundUpdate(value)
  return value is BoundUpdate
end function

function isBoundDelete(value)
  return value is BoundDelete
end function

function isBoundTruncate(value)
  return value is BoundTruncate
end function

function isBoundCreateTable(value)
  return value is BoundCreateTable
end function

function isBoundCreateIndex(value)
  return value is BoundCreateIndex
end function

function isBoundDropIndex(value)
  return value is BoundDropIndex
end function

function isBoundDropTable(value)
  return value is BoundDropTable
end function

function isBoundAlterTable(value)
  return value is BoundAlterTable
end function

function findColumnIndex(table, name)
  if table is void then return -1 end if
  if not metadata.isTableMetadata(table) then return fail(INVALID_ARGUMENT, "findColumnIndex", "table must be TableMetadata") end if
  if typeof(name) != "string" then return fail(INVALID_ARGUMENT, "findColumnIndex", "name must be string") end if
  if len(table.columns) > 0 then
    for index = 0 to len(table.columns) - 1
      if table.columns[index].name == name then return index end if
    end for
  end if
  return -1
end function

function findColumn(table, name)
  index = findColumnIndex(table, name)
  if index < 0 then return void end if
  return table.columns[index]
end function

function literalType(value)
  nullable = value.isNull
  if value.typeKind == types.SqlTypeKind.Unknown then return types.create(types.SqlTypeKind.Integer, 0, 0, 0, true) end if
  if value.typeKind == types.SqlTypeKind.Text then return types.create(types.SqlTypeKind.Text, 0, 0, 0, nullable) end if
  return types.create(value.typeKind, 0, 0, 0, nullable)
end function

function bindLiteral(expression)
  if expression.literalKind == ast.LITERAL_CURRENT_TIMESTAMP then
    typeInfo = types.create(types.SqlTypeKind.Timestamp, 0, 6, 0, false)
    return expressions.literal(values.of(types.SqlTypeKind.Timestamp, endian.int64FromInt(0)), typeInfo)
  end if
  value = values.fromLiteral(expression)
  return expressions.literal(value, literalType(value))
end function

function sourceVisibleName(source)
  if source.alias is not void then return source.alias end if
  return source.table.name
end function

function sourceWidth(sources)
  width = 0
  for each source in sources
    width = width + len(source.table.columns)
  end for
  return width
end function

function appendSource(sources, table, alias)
  if not metadata.isTableMetadata(table) then return fail(INVALID_ARGUMENT, "appendSource", "table must be TableMetadata") end if
  visible = table.name
  if alias is not void then visible = alias end if
  for each existing in sources
    if sourceVisibleName(existing) == visible then return fail(BINDING_ERROR, "appendSource", "duplicate table name or alias " + visible) end if
  end for
  return sources + [BoundSource(table, alias, sourceWidth(sources), void)]
end function

function namedQueryIndex(availableQueries, name)
  if typeof(availableQueries) != "array" or typeof(name) != "string" then return -1 end if
  if len(availableQueries) > 0 then
    for index = 0 to len(availableQueries) - 1
      if availableQueries[index].name == name then return index end if
    end for
  end if
  return -1
end function

function namesContain(names, value)
  for each name in names
    if name == value then return true end if
  end for
  return false
end function

function tableForQuery(name, bound, explicitNames)
  if typeof(name) != "string" or not isBoundSelect(bound) or typeof(explicitNames) != "array" then return fail(INVALID_ARGUMENT, "tableForQuery", "invalid query source") end if
  if len(explicitNames) > 0 and len(explicitNames) != len(bound.items) then return fail(BINDING_ERROR, "tableForQuery", "query column alias count mismatch for " + name) end if
  columns = []
  usedNames = []
  if len(bound.items) > 0 then
    for index = 0 to len(bound.items) - 1
      columnName = bound.itemNames[index]
      if len(explicitNames) > 0 then columnName = explicitNames[index] end if
      if typeof(columnName) != "string" or len(columnName) == 0 then columnName = "column" + (index + 1) end if
      if namesContain(usedNames, columnName) then return fail(BINDING_ERROR, "tableForQuery", "duplicate output column " + columnName + " in " + name) end if
      typeInfo = bound.items[index].typeInfo
      columns = columns + [metadata.createColumn(index + 1, columnName, typeInfo.kind, typeInfo.nullable, typeInfo.length, typeInfo.precision, typeInfo.scale)]
      usedNames = usedNames + [columnName]
    end for
  end if
  return metadata.createTable(0, name, 1, columns)
end function

function appendNamedSource(sources, named, alias)
  if not isBoundNamedQuery(named) then return fail(INVALID_ARGUMENT, "appendNamedSource", "named must be BoundNamedQuery") end if
  visible = named.name
  if alias is not void then visible = alias end if
  for each existing in sources
    if sourceVisibleName(existing) == visible then return fail(BINDING_ERROR, "appendNamedSource", "duplicate table name or alias " + visible) end if
  end for
  return sources + [BoundSource(named.table, alias, sourceWidth(sources), named.query)]
end function

function parseSingleSelect(sqlText, operation)
  statements = parser.parseSql(sqlText)
  if len(statements) != 1 or not ast.isSelectStatement(statements[0]) then return fail(BINDING_ERROR, operation, "stored view SQL must contain exactly one SELECT") end if
  return statements[0]
end function

function resolveNamedQuery(database, name, availableQueries, viewStack)
  index = namedQueryIndex(availableQueries, name)
  if index >= 0 then return availableQueries[index] end if
  state = schema_history.loadOrCreate(database.path, database.metadata.databaseId)
  view = schema_history.findView(state, name)
  if view is void then return void end if
  if namesContain(viewStack, name) then return fail(BINDING_ERROR, "resolveNamedQuery", "cyclic view dependency involving " + name) end if
  statement = parseSingleSelect(view.sqlText, "resolveNamedQuery")
  bound = bindSelectInternal(statement, database, availableQueries, viewStack + [name])
  return BoundNamedQuery(name, bound, tableForQuery(name, bound, view.columnNames))
end function

function appendResolvedSource(sources, database, name, alias, availableQueries, viewStack)
  table = catalog.findTable(database, name)
  if table is not void then return appendSource(sources, table, alias) end if
  named = resolveNamedQuery(database, name, availableQueries, viewStack)
  if named is void then return fail(OBJECT_NOT_FOUND, "appendResolvedSource", "table or view not found: " + name) end if
  return appendNamedSource(sources, named, alias)
end function

function findBoundColumn(sources, expression)
  if typeof(sources) != "array" or not ast.isColumnExpression(expression) then return fail(INVALID_ARGUMENT, "findBoundColumn", "invalid arguments") end if
  matchSource = void
  matchIndex = -1
  for each source in sources
    qualifierMatches = true
    if expression.qualifier is not void then
      qualifierMatches = expression.qualifier == sourceVisibleName(source) or expression.qualifier == source.table.name
    end if
    if qualifierMatches then
      localIndex = findColumnIndex(source.table, expression.name)
      if localIndex >= 0 then
        if matchSource is not void then return fail(BINDING_ERROR, "findBoundColumn", "ambiguous column " + expression.name) end if
        matchSource = source
        matchIndex = localIndex
      end if
    end if
  end for
  if matchSource is void then
    if expression.qualifier is not void then return fail(OBJECT_NOT_FOUND, "findBoundColumn", "unknown qualified column " + expression.qualifier + "." + expression.name) end if
    return fail(OBJECT_NOT_FOUND, "findBoundColumn", "unknown column " + expression.name)
  end if
  return [matchSource.offset + matchIndex, matchSource.table.columns[matchIndex]]
end function

function bindColumnSources(expression, sources)
  located = findBoundColumn(sources, expression)
  return expressions.column(located[0], types.fromColumn(located[1]))
end function

function ensureBoolean(expression, operation)
  if not expressions.isBoundExpression(expression) then return fail(INVALID_ARGUMENT, operation, "expression must be bound") end if
  if expression.typeInfo.kind != types.SqlTypeKind.Boolean then return fail(TYPE_MISMATCH, operation, "expression must be BOOLEAN") end if
  return expression
end function

function isNullBoundLiteral(expression)
  return expressions.isBoundLiteral(expression) and expression.literal is not void and expression.literal.isNull
end function

function isAggregateName(name)
  return name == "COUNT" or name == "SUM" or name == "AVG" or name == "MIN" or name == "MAX"
end function

function resultTypeWithNullability(typeInfo, nullable)
  return types.create(typeInfo.kind, typeInfo.length, typeInfo.precision, typeInfo.scale, nullable)
end function

function mergeConcreteTypes(left, right)
  if types.isNumeric(left) and types.isNumeric(right) then return types.commonNumeric(left, right) end if
  if types.isTextKind(left.kind) and types.isTextKind(right.kind) then return types.create(types.SqlTypeKind.Text, 0, 0, 0, left.nullable or right.nullable) end if
  if types.isBinaryKind(left.kind) and types.isBinaryKind(right.kind) then return types.create(types.SqlTypeKind.Blob, 0, 0, 0, left.nullable or right.nullable) end if
  if left.kind == right.kind then
    length = left.length
    if right.length > length then length = right.length end if
    precision = left.precision
    if right.precision > precision then precision = right.precision end if
    scale = left.scale
    if right.scale > scale then scale = right.scale end if
    return types.create(left.kind, length, precision, scale, left.nullable or right.nullable)
  end if
  return fail(TYPE_MISMATCH, "mergeConcreteTypes", "CASE/COALESCE result types are incompatible")
end function

function mergeResultType(currentType, hasConcrete, nextExpression)
  if isNullBoundLiteral(nextExpression) then
    if currentType is void then currentType = types.create(types.SqlTypeKind.Integer, 0, 0, 0, true) else currentType = resultTypeWithNullability(currentType, true) end if
    return [currentType, hasConcrete]
  end if
  if not hasConcrete then
    nullable = nextExpression.typeInfo.nullable
    if currentType is not void and currentType.nullable then nullable = true end if
    return [resultTypeWithNullability(nextExpression.typeInfo, nullable), true]
  end if
  return [mergeConcreteTypes(currentType, nextExpression.typeInfo), true]
end function

function bindScalarFunction(expression, sources, allowAggregates)
  name = expression.name
  if name == "COALESCE" or name == "IFNULL" then
    if name == "COALESCE" and len(expression.arguments) < 1 then return fail(BINDING_ERROR, "bindScalarFunction", "COALESCE requires at least one argument") end if
    if name == "IFNULL" and len(expression.arguments) != 2 then return fail(BINDING_ERROR, "bindScalarFunction", "IFNULL requires exactly two arguments") end if
    arguments = []
    resultType = void
    hasConcrete = false
    for each argumentAst in expression.arguments
      argument = bindExpressionInternal(argumentAst, sources, allowAggregates)
      merged = mergeResultType(resultType, hasConcrete, argument)
      resultType = merged[0]
      hasConcrete = merged[1]
      arguments = arguments + [argument]
    end for
    if resultType is void then resultType = types.create(types.SqlTypeKind.Integer, 0, 0, 0, true) end if
    nullable = true
    for each argument in arguments
      if not argument.typeInfo.nullable and not isNullBoundLiteral(argument) then nullable = false end if
    end for
    resultType = resultTypeWithNullability(resultType, nullable)
    return expressions.scalar(name, arguments, resultType)
  end if
  if name == "NOW" then
    if len(expression.arguments) != 0 then return fail(BINDING_ERROR, "bindScalarFunction", "NOW takes no arguments") end if
    return expressions.scalar(name, [], types.create(types.SqlTypeKind.Timestamp, 0, 6, 0, false))
  end if
  if name == "NULLIF" then
    if len(expression.arguments) != 2 then return fail(BINDING_ERROR, "bindScalarFunction", "NULLIF requires exactly two arguments") end if
    left = bindExpressionInternal(expression.arguments[0], sources, allowAggregates)
    right = bindExpressionInternal(expression.arguments[1], sources, allowAggregates)
    if not isNullBoundLiteral(left) and not isNullBoundLiteral(right) and not types.comparable(left.typeInfo, right.typeInfo) then return fail(TYPE_MISMATCH, "bindScalarFunction", "NULLIF arguments are incompatible") end if
    return expressions.scalar(name, [left, right], resultTypeWithNullability(left.typeInfo, true))
  end if
  return fail(BINDING_ERROR, "bindScalarFunction", "unsupported scalar function " + name)
end function

function bindAggregate(expression, sources)
  name = expression.name
  if name != "COUNT" and name != "SUM" and name != "AVG" and name != "MIN" and name != "MAX" then return fail(BINDING_ERROR, "bindAggregate", "unsupported aggregate " + name) end if
  if len(expression.arguments) != 1 then return fail(BINDING_ERROR, "bindAggregate", name + " requires exactly one argument") end if
  argumentAst = expression.arguments[0]
  countStar = name == "COUNT" and ast.isStarExpression(argumentAst)
  if ast.isStarExpression(argumentAst) and not countStar then return fail(BINDING_ERROR, "bindAggregate", "only COUNT accepts *") end if
  if countStar and expression.distinct then return fail(BINDING_ERROR, "bindAggregate", "COUNT(DISTINCT *) is invalid") end if
  if countStar then return expressions.aggregate(name, void, false, types.create(types.SqlTypeKind.BigInt, 0, 0, 0, false), true) end if
  argument = bindExpressionInternal(argumentAst, sources, false)
  if expressions.containsAggregate(argument) then return fail(BINDING_ERROR, "bindAggregate", "nested aggregates are not supported") end if
  resultType = argument.typeInfo
  if name == "COUNT" then
    resultType = types.create(types.SqlTypeKind.BigInt, 0, 0, 0, false)
  else if name == "SUM" then
    if not types.isNumeric(argument.typeInfo) then return fail(TYPE_MISMATCH, "bindAggregate", "SUM requires a numeric argument") end if
    if types.isIntegralKind(argument.typeInfo.kind) then resultType = types.create(types.SqlTypeKind.BigInt, 0, 0, 0, true) end if
  else if name == "AVG" then
    if not types.isNumeric(argument.typeInfo) then return fail(TYPE_MISMATCH, "bindAggregate", "AVG requires a numeric argument") end if
    resultType = types.create(types.SqlTypeKind.Double, 0, 0, 0, true)
  else
    resultType = types.withNullable(argument.typeInfo, true)
  end if
  return expressions.aggregate(name, argument, expression.distinct, resultType, false)
end function

function bindExpressionInternal(expression, sources, allowAggregates)
  if ast.isTypedLiteralExpression(expression) then return expressions.literal(expression.value, literalType(expression.value)) end if
  if ast.isLiteralExpression(expression) then return bindLiteral(expression) end if
  if ast.isColumnExpression(expression) then return bindColumnSources(expression, sources) end if
  if ast.isStarExpression(expression) then return fail(BINDING_ERROR, "bindExpression", "'*' is valid only as a SELECT item or COUNT(*)") end if
  if ast.isWindowExpression(expression) then
    name = expression.name
    supported = name == "ROW_NUMBER" or name == "RANK" or name == "DENSE_RANK" or isAggregateName(name)
    if not supported then return fail(BINDING_ERROR, "bindExpression", "unsupported window function " + name) end if
    arguments = []
    countStar = name == "COUNT" and len(expression.arguments) == 1 and ast.isStarExpression(expression.arguments[0])
    if not countStar then
      for each argumentAst in expression.arguments
        arguments = arguments + [bindExpressionInternal(argumentAst, sources, false)]
      end for
    end if
    if (name == "ROW_NUMBER" or name == "RANK" or name == "DENSE_RANK") and len(arguments) != 0 then return fail(BINDING_ERROR, "bindExpression", name + " takes no arguments") end if
    if isAggregateName(name) and not countStar and len(arguments) != 1 then return fail(BINDING_ERROR, "bindExpression", name + " window requires one argument") end if
    partitions = []
    for each partitionAst in expression.partitionBy
      partitions = partitions + [bindExpressionInternal(partitionAst, sources, false)]
    end for
    orders = []
    descending = []
    nullsFirst = []
    nullsSpecified = []
    for each orderItem in expression.orderBy
      orders = orders + [bindExpressionInternal(orderItem.expression, sources, false)]
      descending = descending + [orderItem.descending]
      nullsFirst = nullsFirst + [orderItem.nullsFirst]
      nullsSpecified = nullsSpecified + [orderItem.nullsSpecified]
    end for
    resultType = types.create(types.SqlTypeKind.BigInt, 0, 0, 0, false)
    if isAggregateName(name) then
      pseudo = ast.functionExpression(name, expression.arguments, false)
      aggregateValue = bindAggregate(pseudo, sources)
      resultType = aggregateValue.typeInfo
    end if
    return expressions.window(name, arguments, partitions, orders, descending, nullsFirst, nullsSpecified, resultType)
  end if
  if ast.isFunctionExpression(expression) then
    if expression.name == "COALESCE" or expression.name == "IFNULL" or expression.name == "NOW" or expression.name == "NULLIF" then return bindScalarFunction(expression, sources, allowAggregates) end if
    if not allowAggregates then return fail(BINDING_ERROR, "bindExpression", "aggregate is not allowed in this clause") end if
    return bindAggregate(expression, sources)
  end if
  if ast.isCaseExpression(expression) then
    branches = []
    resultType = void
    hasConcrete = false
    for each branchAst in expression.branches
      condition = ensureBoolean(bindExpressionInternal(branchAst.condition, sources, allowAggregates), "bindExpression.CASE")
      result = bindExpressionInternal(branchAst.result, sources, allowAggregates)
      merged = mergeResultType(resultType, hasConcrete, result)
      resultType = merged[0]
      hasConcrete = merged[1]
      branches = branches + [expressions.caseBranch(condition, result)]
    end for
    elseExpression = void
    if expression.elseExpression is not void then
      elseExpression = bindExpressionInternal(expression.elseExpression, sources, allowAggregates)
      merged = mergeResultType(resultType, hasConcrete, elseExpression)
      resultType = merged[0]
      hasConcrete = merged[1]
    else
      resultType = resultTypeWithNullability(resultType, true)
    end if
    return expressions.caseExpression(branches, elseExpression, resultType)
  end if
  if ast.isCastExpression(expression) then
    operand = bindExpressionInternal(expression.operand, sources, allowAggregates)
    targetType = types.fromTypeName(expression.targetType, operand.typeInfo.nullable or isNullBoundLiteral(operand))
    return expressions.castExpression(operand, targetType)
  end if
  if ast.isInExpression(expression) then
    operand = bindExpressionInternal(expression.operand, sources, allowAggregates)
    candidates = []
    for each candidateAst in expression.values
      candidate = bindExpressionInternal(candidateAst, sources, allowAggregates)
      if not isNullBoundLiteral(operand) and not isNullBoundLiteral(candidate) and not types.comparable(operand.typeInfo, candidate.typeInfo) then return fail(TYPE_MISMATCH, "bindExpression", "IN candidate is incompatible with operand") end if
      candidates = candidates + [candidate]
    end for
    return expressions.inPredicate(operand, candidates, expression.negated)
  end if
  if ast.isBetweenExpression(expression) then
    operand = bindExpressionInternal(expression.operand, sources, allowAggregates)
    lower = bindExpressionInternal(expression.lower, sources, allowAggregates)
    upper = bindExpressionInternal(expression.upper, sources, allowAggregates)
    if not isNullBoundLiteral(operand) and not isNullBoundLiteral(lower) and not types.comparable(operand.typeInfo, lower.typeInfo) then return fail(TYPE_MISMATCH, "bindExpression", "BETWEEN lower bound is incompatible") end if
    if not isNullBoundLiteral(operand) and not isNullBoundLiteral(upper) and not types.comparable(operand.typeInfo, upper.typeInfo) then return fail(TYPE_MISMATCH, "bindExpression", "BETWEEN upper bound is incompatible") end if
    return expressions.betweenPredicate(operand, lower, upper, expression.negated)
  end if
  if ast.isTruthTestExpression(expression) then
    operand = ensureBoolean(bindExpressionInternal(expression.operand, sources, allowAggregates), "bindExpression.truthTest")
    return expressions.truthTest(operand, expression.expected, expression.negated)
  end if
  if ast.isIsNullExpression(expression) then return expressions.isNull(bindExpressionInternal(expression.operand, sources, allowAggregates), expression.negated) end if
  if ast.isUnaryExpression(expression) then
    if expression.operator == "-" and ast.isLiteralExpression(expression.operand) and expression.operand.literalKind == ast.LITERAL_INTEGER and typeof(expression.operand.value) == "string" then
      signedValue = values.literalInteger("-" + expression.operand.value)
      return expressions.literal(signedValue, literalType(signedValue))
    end if
    operand = bindExpressionInternal(expression.operand, sources, allowAggregates)
    if expression.operator == "NOT" then
      ensureBoolean(operand, "bindExpression.NOT")
      return expressions.unary("NOT", operand, types.create(types.SqlTypeKind.Boolean, 0, 0, 0, operand.typeInfo.nullable))
    end if
    if expression.operator == "+" or expression.operator == "-" then
      if not types.isNumeric(operand.typeInfo) then return fail(TYPE_MISMATCH, "bindExpression", "unary numeric operator requires number") end if
      return expressions.unary(expression.operator, operand, operand.typeInfo)
    end if
    return fail(BINDING_ERROR, "bindExpression", "unsupported unary operator " + expression.operator)
  end if
  if ast.isBinaryExpression(expression) then
    left = bindExpressionInternal(expression.left, sources, allowAggregates)
    right = bindExpressionInternal(expression.right, sources, allowAggregates)
    operator = expression.operator
    if operator == "AND" or operator == "OR" then
      ensureBoolean(left, "bindExpression.logical.left")
      ensureBoolean(right, "bindExpression.logical.right")
      return expressions.binary(operator, left, right, types.create(types.SqlTypeKind.Boolean, 0, 0, 0, left.typeInfo.nullable or right.typeInfo.nullable))
    end if
    if operator == "+" or operator == "-" or operator == "*" or operator == "/" or operator == "%" then
      if not types.isNumeric(left.typeInfo) or not types.isNumeric(right.typeInfo) then return fail(TYPE_MISMATCH, "bindExpression", "arithmetic requires numeric operands") end if
      resultType = types.commonNumeric(left.typeInfo, right.typeInfo)
      if operator == "/" then resultType = types.create(types.SqlTypeKind.Double, 0, 0, 0, resultType.nullable) end if
      return expressions.binary(operator, left, right, resultType)
    end if
    if operator == "||" then
      if not types.isTextKind(left.typeInfo.kind) or not types.isTextKind(right.typeInfo.kind) then return fail(TYPE_MISMATCH, "bindExpression", "|| requires text operands") end if
      return expressions.binary(operator, left, right, types.create(types.SqlTypeKind.Text, 0, 0, 0, left.typeInfo.nullable or right.typeInfo.nullable))
    end if
    if operator == "LIKE" or operator == "NOT LIKE" then
      if not types.isTextKind(left.typeInfo.kind) or not types.isTextKind(right.typeInfo.kind) then return fail(TYPE_MISMATCH, "bindExpression", "LIKE requires text operands") end if
      return expressions.binary(operator, left, right, types.create(types.SqlTypeKind.Boolean, 0, 0, 0, left.typeInfo.nullable or right.typeInfo.nullable))
    end if
    if operator == "=" or operator == "<>" or operator == "!=" or operator == "<" or operator == "<=" or operator == ">" or operator == ">=" then
      comparable = false
      if isNullBoundLiteral(left) or isNullBoundLiteral(right) then comparable = true else comparable = types.comparable(left.typeInfo, right.typeInfo) end if
      if not comparable then return fail(TYPE_MISMATCH, "bindExpression", "comparison operands are incompatible") end if
      return expressions.binary(operator, left, right, types.create(types.SqlTypeKind.Boolean, 0, 0, 0, left.typeInfo.nullable or right.typeInfo.nullable))
    end if
    return fail(BINDING_ERROR, "bindExpression", "unsupported binary operator " + operator)
  end if
  return fail(INVALID_ARGUMENT, "bindExpression", "value is not an AST expression")
end function

function bindExpression(expression, table, alias)
  sources = []
  if table is not void then sources = appendSource(sources, table, alias) end if
  return bindExpressionInternal(expression, sources, false)
end function

function bindWhere(expression, table, alias)
  if expression is void then return void end if
  return ensureBoolean(bindExpression(expression, table, alias), "bindWhere")
end function

function bindWhereSources(expression, sources, operation)
  if expression is void then return void end if
  return ensureBoolean(bindExpressionInternal(expression, sources, false), operation)
end function

function groupedExpressionSafe(expression, groups)
  for each group in groups
    if expressions.sameBinding(expression, group) then return true end if
  end for
  if expressions.isBoundAggregate(expression) then return true end if
  if not expressions.isBoundExpression(expression) then return false end if
  if expressions.isBaseBoundExpression(expression) then
    if expression.kind == expressions.BOUND_LITERAL then return true end if
    if expression.kind == expressions.BOUND_COLUMN then return false end if
    if expression.kind == expressions.BOUND_UNARY or expression.kind == expressions.BOUND_IS_NULL then return groupedExpressionSafe(expression.left, groups) end if
    if expression.kind == expressions.BOUND_BINARY then return groupedExpressionSafe(expression.left, groups) and groupedExpressionSafe(expression.right, groups) end if
  end if
  if expressions.isBoundCase(expression) then
    for each branch in expression.branches
      if not groupedExpressionSafe(branch.condition, groups) or not groupedExpressionSafe(branch.result, groups) then return false end if
    end for
    if expression.elseExpression is not void and not groupedExpressionSafe(expression.elseExpression, groups) then return false end if
    return true
  end if
  if expressions.isBoundCast(expression) then return groupedExpressionSafe(expression.operand, groups) end if
  if expressions.isBoundScalar(expression) then
    for each argument in expression.arguments
      if not groupedExpressionSafe(argument, groups) then return false end if
    end for
    return true
  end if
  if expressions.isBoundIn(expression) then
    if not groupedExpressionSafe(expression.operand, groups) then return false end if
    for each candidate in expression.candidates
      if not groupedExpressionSafe(candidate, groups) then return false end if
    end for
    return true
  end if
  if expressions.isBoundBetween(expression) then return groupedExpressionSafe(expression.operand, groups) and groupedExpressionSafe(expression.lower, groups) and groupedExpressionSafe(expression.upper, groups) end if
  if expressions.isBoundTruthTest(expression) then return groupedExpressionSafe(expression.operand, groups) end if
  return false
end function

function windowTopLevelSafe(expression)
  if expressions.isBoundWindow(expression) then return true end if
  return not expressions.containsWindow(expression)
end function

function containsAggregateList(items)
  for each item in items
    if expressions.containsAggregate(item) then return true end if
  end for
  return false
end function


function boundItemIndex(items, expression)
  if len(items) == 0 then return -1 end if
  for index = 0 to len(items) - 1
    if expressions.sameBinding(items[index], expression) then return index end if
  end for
  return -1
end function

function sourceTypes(sources)
  output = []
  for each source in sources
    for each column in source.table.columns
      output = output + [types.fromColumn(column)]
    end for
  end for
  return output
end function

function bindSelectInternal(statement, database, inheritedQueries, viewStack)
  availableQueries = []
  for each inherited in inheritedQueries
    availableQueries = availableQueries + [inherited]
  end for
  for each cte in statement.ctes
    if namedQueryIndex(availableQueries, cte.name) >= 0 or catalog.findTable(database, cte.name) is not void then return fail(BINDING_ERROR, "bindSelect", "duplicate or shadowed CTE name " + cte.name) end if
    cteBound = bindSelectInternal(cte.query, database, availableQueries, viewStack)
    availableQueries = availableQueries + [BoundNamedQuery(cte.name, cteBound, tableForQuery(cte.name, cteBound, cte.columnNames))]
  end for

  table = void
  sources = []
  joins = []
  if statement.tableName is not void then
    sources = appendResolvedSource(sources, database, statement.tableName, statement.tableAlias, availableQueries, viewStack)
    table = sources[0].table
    for each joinClause in statement.joins
      leftTypes = sourceTypes(sources)
      sources = appendResolvedSource(sources, database, joinClause.tableName, joinClause.tableAlias, availableQueries, viewStack)
      source = sources[len(sources) - 1]
      condition = void
      if joinClause.joinType != ast.JOIN_CROSS then condition = ensureBoolean(bindExpressionInternal(joinClause.condition, sources, false), "bindSelect.join") end if
      joins = joins + [BoundJoin(joinClause.joinType, source, condition, leftTypes)]
    end for
  else if len(statement.joins) > 0 then
    return fail(BINDING_ERROR, "bindSelect", "JOIN requires a FROM source")
  end if

  items = []
  names = []
  for each item in statement.items
    if ast.isStarExpression(item.expression) then
      if len(sources) == 0 then return fail(BINDING_ERROR, "bindSelect", "SELECT * requires FROM source") end if
      matched = false
      for each source in sources
        qualifierMatches = item.expression.qualifier is void or item.expression.qualifier == sourceVisibleName(source) or item.expression.qualifier == source.table.name
        if qualifierMatches then
          matched = true
          if len(source.table.columns) > 0 then
            for index = 0 to len(source.table.columns) - 1
              items = items + [expressions.column(source.offset + index, types.fromColumn(source.table.columns[index]))]
              names = names + [source.table.columns[index].name]
            end for
          end if
        end if
      end for
      if not matched then return fail(BINDING_ERROR, "bindSelect", "unknown star qualifier") end if
    else
      boundItem = bindExpressionInternal(item.expression, sources, true)
      items = items + [boundItem]
      name = item.alias
      if name is void then
        if ast.isColumnExpression(item.expression) then name = item.expression.name else name = ast.formatExpression(item.expression) end if
      end if
      names = names + [name]
    end if
  end for

  whereExpression = bindWhereSources(statement.whereExpression, sources, "bindSelect.where")
  groupExpressions = []
  for each groupExpression in statement.groupBy
    boundGroup = bindExpressionInternal(groupExpression, sources, false)
    if expressions.containsAggregate(boundGroup) or expressions.containsWindow(boundGroup) then return fail(BINDING_ERROR, "bindSelect", "GROUP BY cannot contain aggregates or windows") end if
    groupExpressions = groupExpressions + [boundGroup]
  end for
  havingExpression = void
  if statement.havingExpression is not void then havingExpression = ensureBoolean(bindExpressionInternal(statement.havingExpression, sources, true), "bindSelect.having") end if

  orderExpressions = []
  for each orderItem in statement.orderBy
    resolved = void
    if ast.isColumnExpression(orderItem.expression) and orderItem.expression.qualifier is void then
      matchIndex = -1
      if len(names) > 0 then
        for index = 0 to len(names) - 1
          if names[index] == orderItem.expression.name then
            if matchIndex >= 0 then return fail(BINDING_ERROR, "bindSelect", "ambiguous ORDER BY alias " + orderItem.expression.name) end if
            matchIndex = index
          end if
        end for
      end if
      if matchIndex >= 0 then resolved = items[matchIndex] end if
    end if
    if resolved is void then resolved = bindExpressionInternal(orderItem.expression, sources, true) end if
    orderExpressions = orderExpressions + [resolved]
  end for

  windowQuery = expressions.containsWindowList(items) or expressions.containsWindowList(orderExpressions)
  for each item in items
    if not windowTopLevelSafe(item) then return fail(UNSUPPORTED_SQL, "bindSelect", "window functions must be top-level select expressions in M44") end if
  end for
  for each item in orderExpressions
    if not windowTopLevelSafe(item) then return fail(UNSUPPORTED_SQL, "bindSelect", "window functions must be top-level ORDER BY expressions in M44") end if
  end for
  if expressions.containsWindow(whereExpression) or expressions.containsWindow(havingExpression) then return fail(BINDING_ERROR, "bindSelect", "window functions are not allowed in WHERE or HAVING") end if
  aggregateQuery = len(groupExpressions) > 0 or containsAggregateList(items) or expressions.containsAggregate(havingExpression) or containsAggregateList(orderExpressions)
  if windowQuery and aggregateQuery then return fail(UNSUPPORTED_SQL, "bindSelect", "mixing grouped aggregates and window functions is deferred") end if
  if statement.havingExpression is not void and not aggregateQuery then return fail(BINDING_ERROR, "bindSelect", "HAVING requires grouping or an aggregate") end if
  if aggregateQuery then
    for each item in items
      if not groupedExpressionSafe(item, groupExpressions) then return fail(BINDING_ERROR, "bindSelect", "selected expression must be grouped or aggregated") end if
    end for
    if havingExpression is not void and not groupedExpressionSafe(havingExpression, groupExpressions) then return fail(BINDING_ERROR, "bindSelect", "HAVING expression must be grouped or aggregated") end if
    for each item in orderExpressions
      if not groupedExpressionSafe(item, groupExpressions) then return fail(BINDING_ERROR, "bindSelect", "ORDER BY expression must be grouped or aggregated") end if
    end for
  end if

  preliminary = BoundSelect(statement, table, sources, joins, items, names, whereExpression, groupExpressions, havingExpression, orderExpressions, [], aggregateQuery, windowQuery)
  setOperations = []
  for each operation in statement.setOperations
    right = bindSelectInternal(operation.query, database, availableQueries, viewStack)
    if len(right.items) != len(items) then return fail(BINDING_ERROR, "bindSelect", "set-operation column count mismatch") end if
    if len(items) > 0 then
      for index = 0 to len(items) - 1
        if not types.comparable(items[index].typeInfo, right.items[index].typeInfo) then return fail(TYPE_MISMATCH, "bindSelect", "set-operation column types are incompatible") end if
      end for
    end if
    setOperations = setOperations + [BoundSetOperation(operation.operator, operation.all, right)]
  end for
  preliminary.setOperations = setOperations
  if len(setOperations) > 0 then
    for each orderExpression in orderExpressions
      if boundItemIndex(items, orderExpression) < 0 then return fail(BINDING_ERROR, "bindSelect", "compound ORDER BY must reference an output expression") end if
    end for
  end if
  return preliminary
end function

function bindSelect(statement, database)
  return bindSelectInternal(statement, database, [], [])
end function

function bindReturning(items, table)
  if typeof(items) != "array" or not metadata.isTableMetadata(table) then return fail(INVALID_ARGUMENT, "bindReturning", "invalid arguments") end if
  output = []
  sources = appendSource([], table, void)
  for each item in items
    if ast.isStarExpression(item.expression) then
      if item.expression.qualifier is not void and item.expression.qualifier != table.name then return fail(BINDING_ERROR, "bindReturning", "unknown star qualifier " + item.expression.qualifier) end if
      if item.alias is not void then return fail(BINDING_ERROR, "bindReturning", "RETURNING * cannot have an alias") end if
      if len(table.columns) > 0 then
        for index = 0 to len(table.columns) - 1
          output = output + [BoundReturningItem(expressions.column(index, types.fromColumn(table.columns[index])), table.columns[index].name)]
        end for
      end if
    else
      bound = bindExpressionInternal(item.expression, sources, false)
      if expressions.containsAggregate(bound) then return fail(BINDING_ERROR, "bindReturning", "RETURNING cannot contain aggregates") end if
      name = item.alias
      if name is void then
        if ast.isColumnExpression(item.expression) then name = item.expression.name else name = ast.formatExpression(item.expression) end if
      end if
      output = output + [BoundReturningItem(bound, name)]
    end if
  end for
  return output
end function

function sameNameArray(left, right)
  if typeof(left) != "array" or typeof(right) != "array" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

function conflictConstraint(database, table, target)
  if typeof(target) != "array" then return fail(INVALID_ARGUMENT, "conflictConstraint", "target must be array") end if
  if len(target) == 0 then return void end if
  checked = []
  for each name in target
    if findColumnIndex(table, name) < 0 then return fail(OBJECT_NOT_FOUND, "conflictConstraint", "unknown conflict column " + name) end if
    for each oldName in checked
      if oldName == name then return fail(BINDING_ERROR, "conflictConstraint", "duplicate conflict column " + name) end if
    end for
    checked = checked + [name]
  end for
  state = schema_history.loadOrCreate(database.path, database.metadata.databaseId)
  tableSchema = schema_history.findTableSchema(state, table.tableId)
  if tableSchema is void then return fail(BINDING_ERROR, "conflictConstraint", "table has no persisted constraints") end if
  for each constraint in tableSchema.constraints
    unique = constraint.kind == schema_history.CONSTRAINT_PRIMARY_KEY or constraint.kind == schema_history.CONSTRAINT_UNIQUE
    if unique and sameNameArray(constraint.columns, target) then return constraint end if
  end for
  return fail(BINDING_ERROR, "conflictConstraint", "conflict target does not match a PRIMARY KEY or UNIQUE constraint")
end function

function rewriteConflictExpression(expression, targetName)
  if ast.isLiteralExpression(expression) or ast.isParameterExpression(expression) or ast.isStarExpression(expression) then return expression end if
  if ast.isColumnExpression(expression) then
    qualifier = expression.qualifier
    if qualifier is void then qualifier = targetName end if
    return ast.columnExpression(qualifier, expression.name)
  end if
  if ast.isUnaryExpression(expression) then return ast.unaryExpression(expression.operator, rewriteConflictExpression(expression.operand, targetName)) end if
  if ast.isBinaryExpression(expression) then return ast.binaryExpression(expression.operator, rewriteConflictExpression(expression.left, targetName), rewriteConflictExpression(expression.right, targetName)) end if
  if ast.isIsNullExpression(expression) then return ast.isNullExpression(rewriteConflictExpression(expression.operand, targetName), expression.negated) end if
  if ast.isFunctionExpression(expression) then
    arguments = []
    for each argument in expression.arguments
      arguments = arguments + [rewriteConflictExpression(argument, targetName)]
    end for
    return ast.functionExpression(expression.name, arguments, expression.distinct)
  end if
  if ast.isCaseExpression(expression) then
    branches = []
    for each branch in expression.branches
      branches = branches + [ast.caseBranch(rewriteConflictExpression(branch.condition, targetName), rewriteConflictExpression(branch.result, targetName))]
    end for
    elseExpression = void
    if expression.elseExpression is not void then elseExpression = rewriteConflictExpression(expression.elseExpression, targetName) end if
    return ast.caseExpression(branches, elseExpression)
  end if
  if ast.isCastExpression(expression) then return ast.castExpression(rewriteConflictExpression(expression.operand, targetName), expression.targetType) end if
  if ast.isInExpression(expression) then
    candidates = []
    for each candidate in expression.values
      candidates = candidates + [rewriteConflictExpression(candidate, targetName)]
    end for
    return ast.inExpression(rewriteConflictExpression(expression.operand, targetName), candidates, expression.negated)
  end if
  if ast.isBetweenExpression(expression) then return ast.betweenExpression(rewriteConflictExpression(expression.operand, targetName), rewriteConflictExpression(expression.lower, targetName), rewriteConflictExpression(expression.upper, targetName), expression.negated) end if
  if ast.isTruthTestExpression(expression) then return ast.truthTestExpression(rewriteConflictExpression(expression.operand, targetName), expression.expected, expression.negated) end if
  return fail(BINDING_ERROR, "rewriteConflictExpression", "unsupported conflict expression")
end function

function conflictBindingSources(table)
  // The synthetic EXCLUDED source must not retain the target table name.
  // findBoundColumn intentionally accepts both a visible alias and the base
  // table name, so reusing the same TableMetadata instance would make
  // target_table.column ambiguous between target and EXCLUDED.
  excludedTable = metadata.TableMetadata(table.tableId, "excluded", table.schemaVersion, table.columns)
  sources = appendSource([], table, table.name)
  return appendSource(sources, excludedTable, "excluded")
end function

function bindConflictExpression(expression, table, sources)
  return bindExpressionInternal(rewriteConflictExpression(expression, table.name), sources, false)
end function

function bindConflictAssignments(statement, table, sources)
  output = []
  indexes = []
  for each assignment in statement.conflictAssignments
    index = findColumnIndex(table, assignment.column)
    if index < 0 then return fail(OBJECT_NOT_FOUND, "bindConflictAssignments", "unknown column " + assignment.column) end if
    for each oldIndex in indexes
      if oldIndex == index then return fail(BINDING_ERROR, "bindConflictAssignments", "column assigned more than once: " + assignment.column) end if
    end for
    bound = bindConflictExpression(assignment.expression, table, sources)
    targetType = types.fromColumn(table.columns[index])
    if bound.typeInfo.kind != types.SqlTypeKind.Unknown and not types.canAssign(bound.typeInfo, targetType) then return fail(TYPE_MISMATCH, "bindConflictAssignments", "assignment is incompatible with column " + assignment.column) end if
    output = output + [BoundAssignment(index, bound)]
    indexes = indexes + [index]
  end for
  return output
end function

function resolveInsertColumns(statement, table)
  indexes = []
  if len(statement.columns) == 0 then
    if len(table.columns) > 0 then
      for index = 0 to len(table.columns) - 1
        indexes = indexes + [index]
      end for
    end if
    return indexes
  end if
  for each name in statement.columns
    index = findColumnIndex(table, name)
    if index < 0 then return fail(OBJECT_NOT_FOUND, "resolveInsertColumns", "unknown column " + name) end if
    for each existing in indexes
      if existing == index then return fail(BINDING_ERROR, "resolveInsertColumns", "duplicate insert column " + name) end if
    end for
    indexes = indexes + [index]
  end for
  return indexes
end function

function decimalLiteralText(expression)
  if ast.isLiteralExpression(expression) then
    if expression.literalKind == ast.LITERAL_INTEGER or expression.literalKind == ast.LITERAL_FLOAT then
      if typeof(expression.value) == "string" then return expression.value end if
      if typeof(expression.value) == "int" or typeof(expression.value) == "float" then return "" + expression.value end if
    end if
    return void
  end if
  if ast.isUnaryExpression(expression) and (expression.operator == "+" or expression.operator == "-") then
    operandText = decimalLiteralText(expression.operand)
    if operandText is not void then return expression.operator + operandText end if
  end if
  return void
end function

function bindInsertValue(expression, targetType)
  if not types.isSqlType(targetType) then return fail(INVALID_ARGUMENT, "bindInsertValue", "targetType must be SqlType") end if
  literalText = decimalLiteralText(expression)
  if targetType.kind == types.SqlTypeKind.Decimal and literalText is not void then
    decimalValue = values.decimalLiteral(literalText, targetType.precision, targetType.scale)
    return expressions.literal(decimalValue, targetType)
  end if
  // SQL approximate-number literals are initially represented as DOUBLE. For
  // an INSERT target of REAL or DOUBLE, bind the literal directly to the target
  // type instead of rejecting the harmless target-directed conversion.
  if (targetType.kind == types.SqlTypeKind.Real or targetType.kind == types.SqlTypeKind.Double) and literalText is not void then
    floatingValue = values.convert(values.literalFloat(literalText), targetType)
    return expressions.literal(floatingValue, targetType)
  end if
  return bindExpression(expression, void, void)
end function

function bindInsert(statement, database)
  table = catalog.findTable(database, statement.tableName)
  if table is void then return fail(OBJECT_NOT_FOUND, "bindInsert", "table not found: " + statement.tableName) end if
  indexes = resolveInsertColumns(statement, table)
  rows = []
  for each sourceRow in statement.rows
    if len(sourceRow) != len(indexes) then return fail(BINDING_ERROR, "bindInsert", "VALUES count does not match target columns") end if
    boundRow = []
    if len(sourceRow) > 0 then
      for index = 0 to len(sourceRow) - 1
        targetType = types.fromColumn(table.columns[indexes[index]])
        bound = bindInsertValue(sourceRow[index], targetType)
        if not isNullBoundLiteral(bound) and not types.canAssign(bound.typeInfo, targetType) then
          if bound.typeInfo.kind != types.SqlTypeKind.Unknown then return fail(TYPE_MISMATCH, "bindInsert", "value is incompatible with column " + table.columns[indexes[index]].name) end if
        end if
        boundRow = boundRow + [bound]
      end for
    end if
    rows = rows + [boundRow]
  end for

  sourceQuery = void
  if statement.sourceQuery is not void then
    sourceQuery = bindSelect(statement.sourceQuery, database)
    if len(sourceQuery.items) != len(indexes) then return fail(BINDING_ERROR, "bindInsert", "SELECT column count does not match target columns") end if
    if len(indexes) > 0 then
      for index = 0 to len(indexes) - 1
        sourceType = sourceQuery.items[index].typeInfo
        targetType = types.fromColumn(table.columns[indexes[index]])
        if sourceType.kind != types.SqlTypeKind.Unknown and not types.canAssign(sourceType, targetType) then return fail(TYPE_MISMATCH, "bindInsert", "SELECT value is incompatible with column " + table.columns[indexes[index]].name) end if
      end for
    end if
  end if

  selectedConstraint = void
  conflictAssignments = []
  conflictWhere = void
  if statement.conflictAction != ast.CONFLICT_NONE then
    selectedConstraint = conflictConstraint(database, table, statement.conflictTarget)
    if statement.conflictAction == ast.CONFLICT_DO_UPDATE then
      if selectedConstraint is void and not statement.mysqlDuplicateKeyUpdate then return fail(BINDING_ERROR, "bindInsert", "ON CONFLICT DO UPDATE requires a PRIMARY KEY or UNIQUE conflict target") end if
      sources = conflictBindingSources(table)
      conflictAssignments = bindConflictAssignments(statement, table, sources)
      if len(conflictAssignments) == 0 then return fail(BINDING_ERROR, "bindInsert", "ON CONFLICT DO UPDATE requires at least one assignment") end if
      if statement.conflictWhere is not void then conflictWhere = ensureBoolean(bindConflictExpression(statement.conflictWhere, table, sources), "bindInsert.conflictWhere") end if
    end if
  end if
  return BoundInsert(statement, table, indexes, rows, sourceQuery, selectedConstraint, conflictAssignments, conflictWhere, bindReturning(statement.returning, table))
end function

function bindUpdate(statement, database)
  table = catalog.findTable(database, statement.tableName)
  if table is void then return fail(OBJECT_NOT_FOUND, "bindUpdate", "table not found: " + statement.tableName) end if
  assignments = []
  indexes = []
  for each assignment in statement.assignments
    index = findColumnIndex(table, assignment.column)
    if index < 0 then return fail(OBJECT_NOT_FOUND, "bindUpdate", "unknown column " + assignment.column) end if
    for each oldIndex in indexes
      if oldIndex == index then return fail(BINDING_ERROR, "bindUpdate", "column assigned more than once: " + assignment.column) end if
    end for
    bound = bindExpression(assignment.expression, table, void)
    targetType = types.fromColumn(table.columns[index])
    if bound.typeInfo.kind != types.SqlTypeKind.Unknown and not types.canAssign(bound.typeInfo, targetType) then return fail(TYPE_MISMATCH, "bindUpdate", "assignment is incompatible with column " + assignment.column) end if
    assignments = assignments + [BoundAssignment(index, bound)]
    indexes = indexes + [index]
  end for
  orderExpressions = []
  for each item in statement.orderBy
    orderExpressions = orderExpressions + [bindExpression(item.expression, table, void)]
  end for
  return BoundUpdate(statement, table, assignments, bindWhere(statement.whereExpression, table, void), bindReturning(statement.returning, table), orderExpressions)
end function

function bindDelete(statement, database)
  table = catalog.findTable(database, statement.tableName)
  if table is void then return fail(OBJECT_NOT_FOUND, "bindDelete", "table not found: " + statement.tableName) end if
  orderExpressions = []
  for each item in statement.orderBy
    orderExpressions = orderExpressions + [bindExpression(item.expression, table, void)]
  end for
  return BoundDelete(statement, table, bindWhere(statement.whereExpression, table, void), bindReturning(statement.returning, table), orderExpressions)
end function

function bindTruncate(statement, database)
  table = catalog.findTable(database, statement.tableName)
  if table is void then return fail(OBJECT_NOT_FOUND, "bindTruncate", "table not found: " + statement.tableName) end if
  if not statement.restartIdentity then return fail(UNSUPPORTED_SQL, "bindTruncate", "CONTINUE IDENTITY requires persistent sequences and is not supported before M45") end if
  return BoundTruncate(statement, table)
end function

function bindCreateTable(statement, database)
  existing = catalog.findTable(database, statement.name)
  if existing is not void and not statement.ifNotExists then return fail(BINDING_ERROR, "bindCreateTable", "table already exists: " + statement.name) end if
  columnTypes = []
  names = []
  identityCount = 0
  for each column in statement.columns
    for each oldName in names
      if oldName == column.name then return fail(BINDING_ERROR, "bindCreateTable", "duplicate column " + column.name) end if
    end for
    nullable = column.nullable
    if column.primaryKey or column.identity then nullable = false end if
    columnType = types.fromTypeName(column.typeName, nullable)
    if column.identity then
      identityCount = identityCount + 1
      if identityCount > 1 then return fail(BINDING_ERROR, "bindCreateTable", "a table may contain only one IDENTITY or AUTO_INCREMENT column") end if
      if not types.isIntegralKind(columnType.kind) then return fail(TYPE_MISMATCH, "bindCreateTable", "IDENTITY or AUTO_INCREMENT requires SMALLINT, INTEGER or BIGINT") end if
      if column.defaultExpression is not void then return fail(BINDING_ERROR, "bindCreateTable", "IDENTITY or AUTO_INCREMENT cannot also have DEFAULT") end if
    end if
    columnTypes = columnTypes + [columnType]
    names = names + [column.name]
  end for
  temporaryColumns = []
  if len(statement.columns) > 0 then
    for index = 0 to len(statement.columns) - 1
      typeInfo = columnTypes[index]
      temporaryColumns = temporaryColumns + [metadata.createColumn(index + 1, statement.columns[index].name, typeInfo.kind, typeInfo.nullable, typeInfo.length, typeInfo.precision, typeInfo.scale)]
    end for
  end if
  temporaryTable = metadata.createTable(0, statement.name, 1, temporaryColumns)
  if len(statement.columns) > 0 then
    for index = 0 to len(statement.columns) - 1
      definition = statement.columns[index]
      if definition.generatedExpression is not void then
        if definition.defaultExpression is not void or definition.identity then return fail(BINDING_ERROR, "bindCreateTable", "generated column cannot also have DEFAULT or IDENTITY") end if
        generated = bindExpression(definition.generatedExpression, temporaryTable, void)
        if expressions.containsAggregate(generated) or expressions.containsWindow(generated) then return fail(BINDING_ERROR, "bindCreateTable", "generated column cannot contain aggregate or window functions") end if
        if expressions.referencesColumnAtOrAfter(generated, index) then return fail(BINDING_ERROR, "bindCreateTable", "generated column may reference only earlier ordinary columns") end if
        if not types.canAssign(generated.typeInfo, columnTypes[index]) then return fail(TYPE_MISMATCH, "bindCreateTable", "generated expression is incompatible with column " + definition.name) end if
      end if
    end for
  end if
  for each constraint in statement.constraints
    for each columnName in constraint.columns
      found = false
      for each name in names
        if name == columnName then found = true end if
      end for
      if not found then return fail(BINDING_ERROR, "bindCreateTable", "constraint references unknown column " + columnName) end if
    end for
  end for
  return BoundCreateTable(statement, columnTypes)
end function

function bindCreateIndex(statement, database)
  table = catalog.findTable(database, statement.tableName)
  if table is void then return fail(OBJECT_NOT_FOUND, "bindCreateIndex", "table not found: " + statement.tableName) end if
  for each columnName in statement.columns
    if findColumnIndex(table, columnName) < 0 then return fail(OBJECT_NOT_FOUND, "bindCreateIndex", "unknown index column " + columnName) end if
  end for
  return BoundCreateIndex(statement, table)
end function

function bindDropIndex(statement, database)
  table = catalog.findTable(database, statement.tableName)
  if table is void and not statement.ifExists then return fail(OBJECT_NOT_FOUND, "bindDropIndex", "table not found: " + statement.tableName) end if
  return BoundDropIndex(statement, table)
end function

function bindDropTable(statement, database)
  table = catalog.findTable(database, statement.name)
  if table is void and not statement.ifExists then return fail(OBJECT_NOT_FOUND, "bindDropTable", "table not found: " + statement.name) end if
  return BoundDropTable(statement, table)
end function

function constantSchemaExpression(expression)
  if ast.isLiteralExpression(expression) then return expression.literalKind != ast.LITERAL_CURRENT_TIMESTAMP end if
  if ast.isUnaryExpression(expression) then return constantSchemaExpression(expression.operand) end if
  if ast.isBinaryExpression(expression) then return constantSchemaExpression(expression.left) and constantSchemaExpression(expression.right) end if
  if ast.isIsNullExpression(expression) then return constantSchemaExpression(expression.operand) end if
  if ast.isCastExpression(expression) then return constantSchemaExpression(expression.operand) end if
  if ast.isCaseExpression(expression) then
    for each branch in expression.branches
      if not constantSchemaExpression(branch.condition) or not constantSchemaExpression(branch.result) then return false end if
    end for
    return expression.elseExpression is void or constantSchemaExpression(expression.elseExpression)
  end if
  if ast.isFunctionExpression(expression) then
    if expression.name != "COALESCE" and expression.name != "NULLIF" then return false end if
    for each argument in expression.arguments
      if not constantSchemaExpression(argument) then return false end if
    end for
    return true
  end if
  if ast.isInExpression(expression) then
    if not constantSchemaExpression(expression.operand) then return false end if
    for each candidate in expression.values
      if not constantSchemaExpression(candidate) then return false end if
    end for
    return true
  end if
  if ast.isBetweenExpression(expression) then return constantSchemaExpression(expression.operand) and constantSchemaExpression(expression.lower) and constantSchemaExpression(expression.upper) end if
  if ast.isTruthTestExpression(expression) then return constantSchemaExpression(expression.operand) end if
  return false
end function

function bindAlterTable(statement, database)
  table = catalog.findTable(database, statement.tableName)
  if table is void then return fail(OBJECT_NOT_FOUND, "bindAlterTable", "table not found: " + statement.tableName) end if
  columnType = void
  if statement.action == ast.ALTER_TABLE_ADD_COLUMN then
    definition = statement.columnDefinition
    if findColumnIndex(table, definition.name) >= 0 then return fail(BINDING_ERROR, "bindAlterTable", "column already exists: " + definition.name) end if
    columnType = types.fromTypeName(definition.typeName, definition.nullable)
    if definition.identity then return fail(UNSUPPORTED_SQL, "bindAlterTable", "adding an identity column requires an offline table rewrite") end if
    if not columnType.nullable and definition.defaultExpression is void then return fail(CONSTRAINT_VIOLATION, "bindAlterTable", "NOT NULL ADD COLUMN requires a DEFAULT for existing rows") end if
    if definition.generatedExpression is not void then
      if definition.defaultExpression is not void or definition.identity then return fail(BINDING_ERROR, "bindAlterTable", "generated column cannot also have DEFAULT or IDENTITY") end if
      generated = bindExpression(definition.generatedExpression, table, void)
      if expressions.containsAggregate(generated) or expressions.containsWindow(generated) then return fail(BINDING_ERROR, "bindAlterTable", "generated column cannot contain aggregate or window functions") end if
      if not types.canAssign(generated.typeInfo, columnType) then return fail(TYPE_MISMATCH, "bindAlterTable", "generated expression is incompatible with new column") end if
    else if definition.defaultExpression is not void then
      if not constantSchemaExpression(definition.defaultExpression) then return fail(UNSUPPORTED_SQL, "bindAlterTable", "metadata-only ADD COLUMN requires a deterministic constant DEFAULT") end if
      defaultBound = bindExpression(definition.defaultExpression, void, void)
      if defaultBound.typeInfo.kind != types.SqlTypeKind.Unknown and not types.canAssign(defaultBound.typeInfo, columnType) then return fail(TYPE_MISMATCH, "bindAlterTable", "DEFAULT is incompatible with new column") end if
    end if
    if definition.checkExpression is not void or definition.referencesTable is not void or definition.primaryKey or definition.unique then
      return fail(UNSUPPORTED_SQL, "bindAlterTable", "inline ADD COLUMN constraints must be added with ALTER TABLE ADD CONSTRAINT")
    end if
  else if statement.action == ast.ALTER_TABLE_RENAME_COLUMN then
    if findColumnIndex(table, statement.oldName) < 0 then return fail(OBJECT_NOT_FOUND, "bindAlterTable", "column not found: " + statement.oldName) end if
    if findColumnIndex(table, statement.newName) >= 0 then return fail(BINDING_ERROR, "bindAlterTable", "column already exists: " + statement.newName) end if
  else if statement.action == ast.ALTER_TABLE_RENAME_TABLE then
    existing = catalog.findTable(database, statement.newName)
    if existing is not void then return fail(BINDING_ERROR, "bindAlterTable", "table already exists: " + statement.newName) end if
  else if statement.action == ast.ALTER_TABLE_ADD_CONSTRAINT then
    constraint = statement.constraint
    for each columnName in constraint.columns
      if findColumnIndex(table, columnName) < 0 then return fail(OBJECT_NOT_FOUND, "bindAlterTable", "constraint references unknown column " + columnName) end if
    end for
    if constraint.kind == ast.CONSTRAINT_CHECK then
      checked = bindExpression(constraint.expression, table, void)
      ensureBoolean(checked, "bindAlterTable")
    end if
    if constraint.kind == ast.CONSTRAINT_FOREIGN_KEY then
      reference = catalog.findTable(database, constraint.referencesTable)
      if reference is void then return fail(OBJECT_NOT_FOUND, "bindAlterTable", "referenced table not found: " + constraint.referencesTable) end if
      if len(constraint.columns) != len(constraint.referencesColumns) then return fail(BINDING_ERROR, "bindAlterTable", "foreign-key column counts differ") end if
      for each columnName in constraint.referencesColumns
        if findColumnIndex(reference, columnName) < 0 then return fail(OBJECT_NOT_FOUND, "bindAlterTable", "referenced column not found: " + columnName) end if
      end for
    end if
  else if statement.action == ast.ALTER_TABLE_DROP_CONSTRAINT then
    if typeof(statement.constraintName) != "string" or len(statement.constraintName) == 0 then return fail(BINDING_ERROR, "bindAlterTable", "constraint name is required") end if
  else
    return fail(UNSUPPORTED_SQL, "bindAlterTable", "unsupported ALTER TABLE action")
  end if
  return BoundAlterTable(statement, table, columnType)
end function

function bindStatement(statement, database)
  if ast.isSelectStatement(statement) then return bindSelect(statement, database) end if
  if ast.isInsertStatement(statement) then return bindInsert(statement, database) end if
  if ast.isUpdateStatement(statement) then return bindUpdate(statement, database) end if
  if ast.isDeleteStatement(statement) then return bindDelete(statement, database) end if
  if ast.isTruncateStatement(statement) then return bindTruncate(statement, database) end if
  if ast.isCreateTableStatement(statement) then return bindCreateTable(statement, database) end if
  if ast.isCreateIndexStatement(statement) then return bindCreateIndex(statement, database) end if
  if ast.isDropIndexStatement(statement) then return bindDropIndex(statement, database) end if
  if ast.isDropTableStatement(statement) then return bindDropTable(statement, database) end if
  if ast.isAlterTableStatement(statement) then return bindAlterTable(statement, database) end if
  return fail(BINDING_ERROR, "bindStatement", "statement does not require or support binding")
end function

function componentName()
  return "sql.binder"
end function

function targetMilestone()
  return "M13"
end function

function isImplemented()
  return true
end function
