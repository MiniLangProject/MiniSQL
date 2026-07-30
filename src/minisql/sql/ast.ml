package minisql.sql.ast

// Syntax tree for the MiniSQL SQL front end. The AST contains no catalog
// references and can therefore be produced without opening a database. Binding,
// type checking and planning are separate operations.

const EXPR_LITERAL = 1
const EXPR_COLUMN = 2
const EXPR_STAR = 3
const EXPR_UNARY = 4
const EXPR_BINARY = 5
const EXPR_IS_NULL = 6
const EXPR_FUNCTION = 7
const EXPR_PARAMETER = 8
const EXPR_CASE = 9
const EXPR_CAST = 10
const EXPR_IN = 11
const EXPR_BETWEEN = 12
const EXPR_TRUTH_TEST = 13
const EXPR_TYPED_LITERAL = 14
const EXPR_SUBQUERY = 15
const EXPR_EXISTS = 16
const EXPR_IN_SUBQUERY = 17
const EXPR_WINDOW = 18

const LITERAL_NULL = 0
const LITERAL_BOOLEAN = 1
const LITERAL_INTEGER = 2
const LITERAL_FLOAT = 3
const LITERAL_STRING = 4
const LITERAL_CURRENT_TIMESTAMP = 5

const CONSTRAINT_PRIMARY_KEY = 1
const CONSTRAINT_UNIQUE = 2
const CONSTRAINT_CHECK = 3
const CONSTRAINT_FOREIGN_KEY = 4
const CONSTRAINT_INDEX = 5

const JOIN_INNER = 1
const JOIN_LEFT = 2
const JOIN_CROSS = 3
const JOIN_RIGHT = 4
const JOIN_FULL = 5

const SET_UNION = 1
const SET_INTERSECT = 2
const SET_EXCEPT = 3

const CONFLICT_NONE = 0
const CONFLICT_DO_NOTHING = 1
const CONFLICT_DO_UPDATE = 2

const PRINCIPAL_USER = 1
const PRINCIPAL_ROLE = 2
const ALTER_USER_PASSWORD = 1
const ALTER_USER_ENABLE = 2
const ALTER_USER_DISABLE = 3
const DCL_OBJECT_DATABASE = 1
const DCL_OBJECT_TABLE = 2

const ALTER_TABLE_ADD_COLUMN = 1
const ALTER_TABLE_RENAME_COLUMN = 2
const ALTER_TABLE_RENAME_TABLE = 3
const ALTER_TABLE_ADD_CONSTRAINT = 4
const ALTER_TABLE_DROP_CONSTRAINT = 5

struct Identifier
  name
  quoted
end struct

struct TypeName
  name
  length
  precision
  scale
end struct

struct LiteralExpression
  kind
  literalKind
  value
end struct

struct ColumnExpression
  kind
  qualifier
  name
end struct

struct StarExpression
  kind
  qualifier
end struct

struct UnaryExpression
  kind
  operator
  operand
end struct

struct BinaryExpression
  kind
  operator
  left
  right
end struct

struct IsNullExpression
  kind
  operand
  negated
end struct

struct FunctionExpression
  kind
  name
  arguments
  distinct
end struct

struct ParameterExpression
  kind
  index
end struct

struct CaseBranch
  condition
  result
end struct

struct CaseExpression
  kind
  branches
  elseExpression
end struct

struct CastExpression
  kind
  operand
  targetType
end struct

struct InExpression
  kind
  operand
  values
  negated
end struct

struct BetweenExpression
  kind
  operand
  lower
  upper
  negated
end struct

struct TruthTestExpression
  kind
  operand
  expected
  negated
end struct

// Internal typed literals preserve a fully decoded SqlValue while the executor
// materializes non-correlated subqueries and sequence calls before binding.
struct TypedLiteralExpression
  kind
  value
end struct

struct SubqueryExpression
  kind
  query
end struct

struct ExistsExpression
  kind
  query
end struct

struct InSubqueryExpression
  kind
  operand
  query
  negated
end struct

struct WindowExpression
  kind
  name
  arguments
  partitionBy
  orderBy
end struct

struct ColumnDefinition
  name
  typeName
  nullable
  nullableSpecified
  primaryKey
  unique
  defaultExpression
  checkExpression
  referencesTable
  referencesColumns
  onDelete
  onUpdate
  identity
  generatedExpression
  generatedStored
end struct

struct TableConstraint
  kind
  name
  columns
  expression
  referencesTable
  referencesColumns
  onDelete
  onUpdate
end struct

struct SelectItem
  expression
  alias
end struct

struct OrderItem
  expression
  descending
  nullsFirst
  nullsSpecified
end struct

struct JoinClause
  joinType
  tableName
  tableAlias
  condition
end struct

struct SetOperation
  operator
  all
  query
end struct

struct Assignment
  column
  expression
end struct

struct CreateTableStatement
  name
  columns
  constraints
  ifNotExists
end struct

struct CreateIndexStatement
  name
  tableName
  columns
  unique
  ifNotExists
end struct

struct DropIndexStatement
  name
  tableName
  ifExists
end struct

struct DropTableStatement
  name
  ifExists
end struct

struct CreateViewStatement
  name
  query
  replace
end struct

struct DropViewStatement
  name
  ifExists
end struct

struct CreateSequenceStatement
  name
  startValue
  incrementValue
  minimumValue
  maximumValue
  cycle
  ifNotExists
end struct

struct DropSequenceStatement
  name
  ifExists
end struct

struct CreateTriggerStatement
  name
  timing
  eventType
  tableName
  targetColumn
  body
  ifNotExists
end struct

struct DropTriggerStatement
  name
  ifExists
end struct

struct AlterTableStatement
  tableName
  action
  columnDefinition
  oldName
  newName
  constraint
  constraintName
end struct

struct InsertStatement
  tableName
  columns
  rows
  sourceQuery
  conflictTarget
  conflictAction
  conflictAssignments
  conflictWhere
  returning
  mysqlDuplicateKeyUpdate
end struct

struct UpdateStatement
  tableName
  assignments
  whereExpression
  orderBy
  limit
  returning
end struct

struct DeleteStatement
  tableName
  whereExpression
  orderBy
  limit
  returning
end struct

struct TruncateStatement
  tableName
  restartIdentity
end struct

struct CommonTableExpression
  name
  query
  columnNames
end struct

struct SelectStatement
  distinct
  items
  tableName
  tableAlias
  joins
  whereExpression
  groupBy
  havingExpression
  setOperations
  orderBy
  limit
  offset
  ctes
end struct

struct BeginStatement
  readOnly
  isolationLevel
end struct

struct CommitStatement
  marker
end struct

struct RollbackStatement
  marker
end struct

struct SavepointStatement
  name
end struct

struct RollbackToStatement
  name
end struct

struct ReleaseSavepointStatement
  name
end struct

struct CreatePrincipalStatement
  principalKind
  name
  password
end struct

struct AlterUserStatement
  name
  action
  password
end struct

struct DropPrincipalStatement
  principalKind
  name
  ifExists
end struct

struct GrantRoleStatement
  roleName
  memberName
  adminOption
end struct

struct RevokeRoleStatement
  roleName
  memberName
  cascade
end struct

struct GrantPrivilegeStatement
  privileges
  objectType
  objectName
  granteeName
  grantOption
end struct

struct RevokePrivilegeStatement
  privileges
  objectType
  objectName
  granteeName
  cascade
end struct

struct AnalyzeStatement
  tableName
end struct

struct ExplainStatement
  analyze
  statement
end struct

struct PrepareStatement
  name
  statement
  parameterCount
end struct

struct ExecutePreparedStatement
  name
  arguments
end struct

struct DeallocateStatement
  name
end struct

struct VacuumStatement
  tableName
end struct

struct ReindexStatement
  name
end struct

struct ShowTablesStatement
  marker
end struct

struct DescribeTableStatement
  tableName
end struct

struct ShowIndexesStatement
  tableName
end struct

function identifier(name, quoted)
  if typeof(name) != "string" or len(name) == 0 or typeof(quoted) != "bool" then return error(9001, "sql.ast.identifier: invalid identifier") end if
  return Identifier(name, quoted)
end function

function typeName(name, length, precision, scale)
  return TypeName(name, length, precision, scale)
end function

function nullLiteral()
  return LiteralExpression(EXPR_LITERAL, LITERAL_NULL, void)
end function

function booleanLiteral(value)
  return LiteralExpression(EXPR_LITERAL, LITERAL_BOOLEAN, value)
end function

function integerLiteral(value)
  return LiteralExpression(EXPR_LITERAL, LITERAL_INTEGER, value)
end function

function floatLiteral(value)
  return LiteralExpression(EXPR_LITERAL, LITERAL_FLOAT, value)
end function

function stringLiteral(value)
  return LiteralExpression(EXPR_LITERAL, LITERAL_STRING, value)
end function

function currentTimestampLiteral()
  return LiteralExpression(EXPR_LITERAL, LITERAL_CURRENT_TIMESTAMP, void)
end function

function columnExpression(qualifier, name)
  return ColumnExpression(EXPR_COLUMN, qualifier, name)
end function

function starExpression(qualifier)
  return StarExpression(EXPR_STAR, qualifier)
end function

function unaryExpression(operator, operand)
  return UnaryExpression(EXPR_UNARY, operator, operand)
end function

function binaryExpression(operator, left, right)
  return BinaryExpression(EXPR_BINARY, operator, left, right)
end function

function isNullExpression(operand, negated)
  return IsNullExpression(EXPR_IS_NULL, operand, negated)
end function

function functionExpression(name, arguments, distinct)
  if typeof(name) != "string" or len(name) == 0 or typeof(arguments) != "array" or typeof(distinct) != "bool" then return error(9001, "sql.ast.functionExpression: invalid function") end if
  return FunctionExpression(EXPR_FUNCTION, name, arguments, distinct)
end function

function parameterExpression(index)
  if typeof(index) != "int" or index < 0 then return error(9001, "sql.ast.parameterExpression: invalid index") end if
  return ParameterExpression(EXPR_PARAMETER, index)
end function

function caseBranch(condition, result)
  if not isExpression(condition) or not isExpression(result) then return error(9001, "sql.ast.caseBranch: invalid branch") end if
  return CaseBranch(condition, result)
end function

function caseExpression(branches, elseExpression)
  if typeof(branches) != "array" or len(branches) == 0 then return error(9001, "sql.ast.caseExpression: branches must be non-empty") end if
  for each branch in branches
    if branch is not CaseBranch then return error(9001, "sql.ast.caseExpression: invalid branch") end if
  end for
  if elseExpression is not void and not isExpression(elseExpression) then return error(9001, "sql.ast.caseExpression: invalid ELSE expression") end if
  return CaseExpression(EXPR_CASE, branches, elseExpression)
end function

function castExpression(operand, targetType)
  if not isExpression(operand) or targetType is not TypeName then return error(9001, "sql.ast.castExpression: invalid CAST") end if
  return CastExpression(EXPR_CAST, operand, targetType)
end function

function inExpression(operand, candidates, negated)
  if not isExpression(operand) or typeof(candidates) != "array" or len(candidates) == 0 or typeof(negated) != "bool" then return error(9001, "sql.ast.inExpression: invalid IN predicate") end if
  for each candidate in candidates
    if not isExpression(candidate) then return error(9001, "sql.ast.inExpression: candidate is not expression") end if
  end for
  return InExpression(EXPR_IN, operand, candidates, negated)
end function

function betweenExpression(operand, lower, upper, negated)
  if not isExpression(operand) or not isExpression(lower) or not isExpression(upper) or typeof(negated) != "bool" then return error(9001, "sql.ast.betweenExpression: invalid BETWEEN predicate") end if
  return BetweenExpression(EXPR_BETWEEN, operand, lower, upper, negated)
end function

function truthTestExpression(operand, expected, negated)
  if not isExpression(operand) or typeof(expected) != "string" or typeof(negated) != "bool" then return error(9001, "sql.ast.truthTestExpression: invalid truth test") end if
  return TruthTestExpression(EXPR_TRUTH_TEST, operand, expected, negated)
end function

function typedLiteralExpression(value)
  if typeof(value) != "struct" then return error(9001, "sql.ast.typedLiteralExpression: value must be SqlValue") end if
  return TypedLiteralExpression(EXPR_TYPED_LITERAL, value)
end function

function subqueryExpression(query)
  if query is not SelectStatement then return error(9001, "sql.ast.subqueryExpression: query must be SELECT") end if
  return SubqueryExpression(EXPR_SUBQUERY, query)
end function

function existsExpression(query)
  if query is not SelectStatement then return error(9001, "sql.ast.existsExpression: query must be SELECT") end if
  return ExistsExpression(EXPR_EXISTS, query)
end function

function inSubqueryExpression(operand, query, negated)
  if not isExpression(operand) or query is not SelectStatement or typeof(negated) != "bool" then return error(9001, "sql.ast.inSubqueryExpression: invalid IN subquery") end if
  return InSubqueryExpression(EXPR_IN_SUBQUERY, operand, query, negated)
end function

function windowExpression(name, arguments, partitionBy, orderBy)
  if typeof(name) != "string" or len(name) == 0 or typeof(arguments) != "array" or typeof(partitionBy) != "array" or typeof(orderBy) != "array" then return error(9001, "sql.ast.windowExpression: invalid window expression") end if
  return WindowExpression(EXPR_WINDOW, name, arguments, partitionBy, orderBy)
end function

function isColumnExpression(value)
  return value is ColumnExpression
end function

function isStarExpression(value)
  return value is StarExpression
end function

function isUnaryExpression(value)
  return value is UnaryExpression
end function

function isBinaryExpression(value)
  return value is BinaryExpression
end function

function isIsNullExpression(value)
  return value is IsNullExpression
end function

function isFunctionExpression(value)
  return value is FunctionExpression
end function

function isParameterExpression(value)
  return value is ParameterExpression
end function

function isCaseExpression(value)
  return value is CaseExpression
end function

function isCastExpression(value)
  return value is CastExpression
end function

function isInExpression(value)
  return value is InExpression
end function

function isBetweenExpression(value)
  return value is BetweenExpression
end function

function isTruthTestExpression(value)
  return value is TruthTestExpression
end function

function isTypedLiteralExpression(value)
  return value is TypedLiteralExpression
end function

function isSubqueryExpression(value)
  return value is SubqueryExpression
end function

function isExistsExpression(value)
  return value is ExistsExpression
end function

function isInSubqueryExpression(value)
  return value is InSubqueryExpression
end function

function isWindowExpression(value)
  return value is WindowExpression
end function

function isLiteralExpression(value)
  return value is LiteralExpression
end function

function isTypeName(value)
  return value is TypeName
end function

function isExpression(value)
  return value is LiteralExpression or value is ColumnExpression or value is StarExpression or value is UnaryExpression or value is BinaryExpression or value is IsNullExpression or value is FunctionExpression or value is ParameterExpression or value is CaseExpression or value is CastExpression or value is InExpression or value is BetweenExpression or value is TruthTestExpression or value is TypedLiteralExpression or value is SubqueryExpression or value is ExistsExpression or value is InSubqueryExpression or value is WindowExpression
end function

function isCreateTableStatement(value)
  return value is CreateTableStatement
end function

function isCreateIndexStatement(value)
  return value is CreateIndexStatement
end function

function isDropIndexStatement(value)
  return value is DropIndexStatement
end function

function isDropTableStatement(value)
  return value is DropTableStatement
end function

function isCreateViewStatement(value)
  return value is CreateViewStatement
end function

function isDropViewStatement(value)
  return value is DropViewStatement
end function

function isCreateSequenceStatement(value)
  return value is CreateSequenceStatement
end function

function isDropSequenceStatement(value)
  return value is DropSequenceStatement
end function

function isCreateTriggerStatement(value)
  return value is CreateTriggerStatement
end function

function isDropTriggerStatement(value)
  return value is DropTriggerStatement
end function

function isAlterTableStatement(value)
  return value is AlterTableStatement
end function

function isInsertStatement(value)
  return value is InsertStatement
end function

function isUpdateStatement(value)
  return value is UpdateStatement
end function

function isDeleteStatement(value)
  return value is DeleteStatement
end function

function isTruncateStatement(value)
  return value is TruncateStatement
end function

function isSelectStatement(value)
  return value is SelectStatement
end function

function isBeginStatement(value)
  return value is BeginStatement
end function

function isCommitStatement(value)
  return value is CommitStatement
end function

function isRollbackStatement(value)
  return value is RollbackStatement
end function

function isSavepointStatement(value)
  return value is SavepointStatement
end function

function isRollbackToStatement(value)
  return value is RollbackToStatement
end function

function isReleaseSavepointStatement(value)
  return value is ReleaseSavepointStatement
end function

function isCreatePrincipalStatement(value)
  return value is CreatePrincipalStatement
end function

function isAlterUserStatement(value)
  return value is AlterUserStatement
end function

function isDropPrincipalStatement(value)
  return value is DropPrincipalStatement
end function

function isGrantRoleStatement(value)
  return value is GrantRoleStatement
end function

function isRevokeRoleStatement(value)
  return value is RevokeRoleStatement
end function

function isGrantPrivilegeStatement(value)
  return value is GrantPrivilegeStatement
end function

function isRevokePrivilegeStatement(value)
  return value is RevokePrivilegeStatement
end function

function isDclStatement(value)
  return value is CreatePrincipalStatement or value is AlterUserStatement or value is DropPrincipalStatement or value is GrantRoleStatement or value is RevokeRoleStatement or value is GrantPrivilegeStatement or value is RevokePrivilegeStatement
end function

function isAnalyzeStatement(value)
  return value is AnalyzeStatement
end function

function isExplainStatement(value)
  return value is ExplainStatement
end function

function isPrepareStatement(value)
  return value is PrepareStatement
end function

function isExecutePreparedStatement(value)
  return value is ExecutePreparedStatement
end function

function isDeallocateStatement(value)
  return value is DeallocateStatement
end function

function isVacuumStatement(value)
  return value is VacuumStatement
end function

function isReindexStatement(value)
  return value is ReindexStatement
end function

function isShowTablesStatement(value)
  return value is ShowTablesStatement
end function

function isDescribeTableStatement(value)
  return value is DescribeTableStatement
end function

function isShowIndexesStatement(value)
  return value is ShowIndexesStatement
end function

function isMetadataStatement(value)
  return value is ShowTablesStatement or value is DescribeTableStatement or value is ShowIndexesStatement
end function

function isStatement(value)
  return value is CreateTableStatement or value is CreateIndexStatement or value is DropIndexStatement or value is DropTableStatement or value is CreateViewStatement or value is DropViewStatement or value is CreateSequenceStatement or value is DropSequenceStatement or value is CreateTriggerStatement or value is DropTriggerStatement or value is AlterTableStatement or value is InsertStatement or value is UpdateStatement or value is DeleteStatement or value is TruncateStatement or value is SelectStatement or value is BeginStatement or value is CommitStatement or value is RollbackStatement or value is SavepointStatement or value is RollbackToStatement or value is ReleaseSavepointStatement or value is AnalyzeStatement or value is ExplainStatement or value is PrepareStatement or value is ExecutePreparedStatement or value is DeallocateStatement or value is VacuumStatement or value is ReindexStatement or isMetadataStatement(value) or isDclStatement(value)
end function

function expressionKind(value)
  if not isExpression(value) then return 0 end if
  return value.kind
end function

function quoteString(value)
  raw = bytes(value)
  output = "'"
  if len(raw) > 0 then
    for index = 0 to len(raw) - 1
      character = decode(slice(raw, index, 1))
      if raw[index] == 39 then
        output = output + "''"
      else
        output = output + character
      end if
    end for
  end if
  return output + "'"
end function

function formatTypeName(value)
  if value is not TypeName then return error(9001, "sql.ast.formatTypeName: value must be TypeName") end if
  output = value.name
  if value.name == "DECIMAL" or value.name == "NUMERIC" then
    if value.precision > 0 then return output + "(" + value.precision + ", " + value.scale + ")" end if
    return output
  end if
  if value.length > 0 then return output + "(" + value.length + ")" end if
  if (value.name == "TIME" or value.name == "TIMESTAMP") and value.precision > 0 then return output + "(" + value.precision + ")" end if
  return output
end function

function formatFunction(expression)
  output = expression.name + "("
  if expression.distinct then output = output + "DISTINCT " end if
  if len(expression.arguments) > 0 then
    for index = 0 to len(expression.arguments) - 1
      if index > 0 then output = output + ", " end if
      output = output + formatExpression(expression.arguments[index])
    end for
  end if
  return output + ")"
end function

function formatExpression(expression)
  if expression is LiteralExpression then
    if expression.literalKind == LITERAL_NULL then return "NULL" end if
    if expression.literalKind == LITERAL_BOOLEAN then
      if expression.value then return "TRUE" else return "FALSE" end if
    end if
    if expression.literalKind == LITERAL_STRING then return quoteString(expression.value) end if
    if expression.literalKind == LITERAL_CURRENT_TIMESTAMP then return "CURRENT_TIMESTAMP" end if
    return "" + expression.value
  end if
  if expression is ColumnExpression then
    if expression.qualifier is void or len(expression.qualifier) == 0 then return expression.name end if
    return expression.qualifier + "." + expression.name
  end if
  if expression is StarExpression then
    if expression.qualifier is void or len(expression.qualifier) == 0 then return "*" end if
    return expression.qualifier + ".*"
  end if
  if expression is FunctionExpression then return formatFunction(expression) end if
  if expression is ParameterExpression then return "?" end if
  if expression is UnaryExpression then return expression.operator + " (" + formatExpression(expression.operand) + ")" end if
  if expression is BinaryExpression then return "(" + formatExpression(expression.left) + " " + expression.operator + " " + formatExpression(expression.right) + ")" end if
  if expression is IsNullExpression then
    suffix = " IS NULL"
    if expression.negated then suffix = " IS NOT NULL" end if
    return "(" + formatExpression(expression.operand) + suffix + ")"
  end if
  if expression is CaseExpression then
    output = "CASE"
    for each branch in expression.branches
      output = output + " WHEN " + formatExpression(branch.condition) + " THEN " + formatExpression(branch.result)
    end for
    if expression.elseExpression is not void then output = output + " ELSE " + formatExpression(expression.elseExpression) end if
    return output + " END"
  end if
  if expression is CastExpression then return "CAST(" + formatExpression(expression.operand) + " AS " + formatTypeName(expression.targetType) + ")" end if
  if expression is InExpression then
    output = "(" + formatExpression(expression.operand)
    if expression.negated then output = output + " NOT" end if
    output = output + " IN ("
    for index = 0 to len(expression.values) - 1
      if index > 0 then output = output + ", " end if
      output = output + formatExpression(expression.values[index])
    end for
    return output + "))"
  end if
  if expression is BetweenExpression then
    output = "(" + formatExpression(expression.operand)
    if expression.negated then output = output + " NOT" end if
    return output + " BETWEEN " + formatExpression(expression.lower) + " AND " + formatExpression(expression.upper) + ")"
  end if
  if expression is TruthTestExpression then
    output = "(" + formatExpression(expression.operand) + " IS "
    if expression.negated then output = output + "NOT " end if
    return output + expression.expected + ")"
  end if
  if expression is SubqueryExpression then return "(" + formatSelect(expression.query) + ")" end if
  if expression is ExistsExpression then return "EXISTS (" + formatSelect(expression.query) + ")" end if
  if expression is InSubqueryExpression then
    output = "(" + formatExpression(expression.operand)
    if expression.negated then output = output + " NOT" end if
    return output + " IN (" + formatSelect(expression.query) + "))"
  end if
  if expression is WindowExpression then
    output = expression.name + "("
    if len(expression.arguments) > 0 then
      for index = 0 to len(expression.arguments) - 1
        if index > 0 then output = output + ", " end if
        output = output + formatExpression(expression.arguments[index])
      end for
    end if
    output = output + ") OVER ("
    if len(expression.partitionBy) > 0 then
      output = output + "PARTITION BY "
      for index = 0 to len(expression.partitionBy) - 1
        if index > 0 then output = output + ", " end if
        output = output + formatExpression(expression.partitionBy[index])
      end for
    end if
    if len(expression.orderBy) > 0 then
      if len(expression.partitionBy) > 0 then output = output + " " end if
      output = output + "ORDER BY "
      for index = 0 to len(expression.orderBy) - 1
        if index > 0 then output = output + ", " end if
        output = output + formatExpression(expression.orderBy[index].expression)
        if expression.orderBy[index].descending then output = output + " DESC" else output = output + " ASC" end if
      end for
    end if
    return output + ")"
  end if
  if expression is TypedLiteralExpression then return "<typed-literal>" end if
  return error(9001, "sql.ast.formatExpression: value is not an expression")
end function

function formatSelectItem(item)
  output = formatExpression(item.expression)
  if item.alias is not void then output = output + " AS " + item.alias end if
  return output
end function

function formatOrderItem(item)
  output = formatExpression(item.expression)
  if item.descending then output = output + " DESC" else output = output + " ASC" end if
  if item.nullsSpecified then
    if item.nullsFirst then output = output + " NULLS FIRST" else output = output + " NULLS LAST" end if
  end if
  return output
end function

function formatSelect(statement)
  if statement is not SelectStatement then return error(9001, "sql.ast.formatSelect: statement must be SELECT") end if
  output = ""
  if len(statement.ctes) > 0 then
    output = "WITH "
    for index = 0 to len(statement.ctes) - 1
      if index > 0 then output = output + ", " end if
      cte = statement.ctes[index]
      output = output + cte.name
      if len(cte.columnNames) > 0 then
        output = output + " ("
        for columnIndex = 0 to len(cte.columnNames) - 1
          if columnIndex > 0 then output = output + ", " end if
          output = output + cte.columnNames[columnIndex]
        end for
        output = output + ")"
      end if
      output = output + " AS (" + formatSelect(cte.query) + ")"
    end for
    output = output + " "
  end if
  output = output + "SELECT "
  if statement.distinct then output = output + "DISTINCT " end if
  for index = 0 to len(statement.items) - 1
    if index > 0 then output = output + ", " end if
    output = output + formatSelectItem(statement.items[index])
  end for
  if statement.tableName is not void then
    output = output + " FROM " + statement.tableName
    if statement.tableAlias is not void then output = output + " AS " + statement.tableAlias end if
    for each join in statement.joins
      if join.joinType == JOIN_LEFT then output = output + " LEFT JOIN " else if join.joinType == JOIN_RIGHT then output = output + " RIGHT JOIN " else if join.joinType == JOIN_FULL then output = output + " FULL JOIN " else if join.joinType == JOIN_CROSS then output = output + " CROSS JOIN " else output = output + " INNER JOIN " end if
      output = output + join.tableName
      if join.tableAlias is not void then output = output + " AS " + join.tableAlias end if
      if join.condition is not void then output = output + " ON " + formatExpression(join.condition) end if
    end for
  end if
  if statement.whereExpression is not void then output = output + " WHERE " + formatExpression(statement.whereExpression) end if
  if len(statement.groupBy) > 0 then
    output = output + " GROUP BY "
    for index = 0 to len(statement.groupBy) - 1
      if index > 0 then output = output + ", " end if
      output = output + formatExpression(statement.groupBy[index])
    end for
  end if
  if statement.havingExpression is not void then output = output + " HAVING " + formatExpression(statement.havingExpression) end if
  for each operation in statement.setOperations
    if operation.operator == SET_INTERSECT then output = output + " INTERSECT" else if operation.operator == SET_EXCEPT then output = output + " EXCEPT" else output = output + " UNION" end if
    if operation.all then output = output + " ALL" end if
    output = output + " " + formatSelect(operation.query)
  end for
  if len(statement.orderBy) > 0 then
    output = output + " ORDER BY "
    for index = 0 to len(statement.orderBy) - 1
      if index > 0 then output = output + ", " end if
      output = output + formatOrderItem(statement.orderBy[index])
    end for
  end if
  if statement.limit >= 0 then output = output + " LIMIT " + statement.limit end if
  if statement.offset > 0 then output = output + " OFFSET " + statement.offset end if
  return output
end function

function formatStatement(statement)
  if statement is SelectStatement then return formatSelect(statement) end if
  if statement is InsertStatement then
    output = "INSERT INTO " + statement.tableName
    if len(statement.columns) > 0 then
      output = output + " ("
      for index = 0 to len(statement.columns) - 1
        if index > 0 then output = output + ", " end if
        output = output + statement.columns[index]
      end for
      output = output + ")"
    end if
    if statement.sourceQuery is not void then
      return output + " " + formatSelect(statement.sourceQuery)
    end if
    output = output + " VALUES "
    for rowIndex = 0 to len(statement.rows) - 1
      if rowIndex > 0 then output = output + ", " end if
      output = output + "("
      for index = 0 to len(statement.rows[rowIndex]) - 1
        if index > 0 then output = output + ", " end if
        output = output + formatExpression(statement.rows[rowIndex][index])
      end for
      output = output + ")"
    end for
    if statement.conflictAction == CONFLICT_DO_NOTHING then output = output + " ON CONFLICT DO NOTHING" end if
    if statement.conflictAction == CONFLICT_DO_UPDATE then
      output = output + " ON CONFLICT"
      if len(statement.conflictTarget) > 0 then
        output = output + " ("
        for index = 0 to len(statement.conflictTarget) - 1
          if index > 0 then output = output + ", " end if
          output = output + statement.conflictTarget[index]
        end for
        output = output + ")"
      end if
      output = output + " DO UPDATE SET "
      for index = 0 to len(statement.conflictAssignments) - 1
        if index > 0 then output = output + ", " end if
        output = output + statement.conflictAssignments[index].column + " = " + formatExpression(statement.conflictAssignments[index].expression)
      end for
    end if
    return output
  end if
  if statement is UpdateStatement then
    output = "UPDATE " + statement.tableName + " SET "
    for index = 0 to len(statement.assignments) - 1
      if index > 0 then output = output + ", " end if
      output = output + statement.assignments[index].column + " = " + formatExpression(statement.assignments[index].expression)
    end for
    if statement.whereExpression is not void then output = output + " WHERE " + formatExpression(statement.whereExpression) end if
    if len(statement.orderBy) > 0 then
      output = output + " ORDER BY "
      for index = 0 to len(statement.orderBy) - 1
        if index > 0 then output = output + ", " end if
        output = output + formatOrderItem(statement.orderBy[index])
      end for
    end if
    if statement.limit >= 0 then output = output + " LIMIT " + statement.limit end if
    return output
  end if
  if statement is DeleteStatement then
    output = "DELETE FROM " + statement.tableName
    if statement.whereExpression is not void then output = output + " WHERE " + formatExpression(statement.whereExpression) end if
    if len(statement.orderBy) > 0 then
      output = output + " ORDER BY "
      for index = 0 to len(statement.orderBy) - 1
        if index > 0 then output = output + ", " end if
        output = output + formatOrderItem(statement.orderBy[index])
      end for
    end if
    if statement.limit >= 0 then output = output + " LIMIT " + statement.limit end if
    return output
  end if
  return error(9001, "sql.ast.formatStatement: unsupported statement")
end function

function componentName()
  return "sql.ast"
end function

function targetMilestone()
  return "M12"
end function

function isImplemented()
  return true
end function
