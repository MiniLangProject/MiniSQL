package minisql.sql.ast

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

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
const ALTER_TABLE_DROP_COLUMN = 6
const ALTER_TABLE_SET_DEFAULT = 7
const ALTER_TABLE_DROP_DEFAULT = 8
const ALTER_TABLE_SET_NOT_NULL = 9
const ALTER_TABLE_DROP_NOT_NULL = 10

// Groups the identifier state and preserves the field relationships documented below.
struct Identifier
  // Stores the name associated with this value.
  name
  // Indicates whether the quoted condition is active.
  quoted
end struct

// Groups the type name state and preserves the field relationships documented below.
struct TypeName
  // Stores the name associated with this value.
  name
  // Tracks the length numeric value.
  length
  // Stores the precision associated with this value.
  precision
  // Stores the scale associated with this value.
  scale
end struct

// Groups the literal expression state and preserves the field relationships documented below.
struct LiteralExpression
  // Stores the kind associated with this value.
  kind
  // Stores the literal kind associated with this value.
  literalKind
  // Stores the value associated with this value.
  value
end struct

// Groups the column expression state and preserves the field relationships documented below.
struct ColumnExpression
  // Stores the kind associated with this value.
  kind
  // Stores the qualifier associated with this value.
  qualifier
  // Stores the name associated with this value.
  name
end struct

// Groups the star expression state and preserves the field relationships documented below.
struct StarExpression
  // Stores the kind associated with this value.
  kind
  // Stores the qualifier associated with this value.
  qualifier
end struct

// Groups the unary expression state and preserves the field relationships documented below.
struct UnaryExpression
  // Stores the kind associated with this value.
  kind
  // Stores the operator associated with this value.
  operator
  // Stores the operand associated with this value.
  operand
end struct

// Groups the binary expression state and preserves the field relationships documented below.
struct BinaryExpression
  // Stores the kind associated with this value.
  kind
  // Stores the operator associated with this value.
  operator
  // Stores the left associated with this value.
  left
  // Stores the right associated with this value.
  right
end struct

// Groups the is null expression state and preserves the field relationships documented below.
struct IsNullExpression
  // Stores the kind associated with this value.
  kind
  // Stores the operand associated with this value.
  operand
  // Indicates whether the negated condition is active.
  negated
end struct

// Groups the function expression state and preserves the field relationships documented below.
struct FunctionExpression
  // Stores the kind associated with this value.
  kind
  // Stores the name associated with this value.
  name
  // Contains the ordered arguments collection.
  arguments
  // Indicates whether the distinct condition is active.
  distinct
end struct

// Groups the parameter expression state and preserves the field relationships documented below.
struct ParameterExpression
  // Stores the kind associated with this value.
  kind
  // Tracks the index numeric value.
  index
end struct

// Groups the case branch state and preserves the field relationships documented below.
struct CaseBranch
  // Stores the condition associated with this value.
  condition
  // Stores the result associated with this value.
  result
end struct

// Groups the case expression state and preserves the field relationships documented below.
struct CaseExpression
  // Stores the kind associated with this value.
  kind
  // Contains the ordered branches collection.
  branches
  // Stores the else expression associated with this value.
  elseExpression
end struct

// Groups the cast expression state and preserves the field relationships documented below.
struct CastExpression
  // Stores the kind associated with this value.
  kind
  // Stores the operand associated with this value.
  operand
  // Stores the target type associated with this value.
  targetType
end struct

// Groups the in expression state and preserves the field relationships documented below.
struct InExpression
  // Stores the kind associated with this value.
  kind
  // Stores the operand associated with this value.
  operand
  // Contains the ordered values collection.
  values
  // Indicates whether the negated condition is active.
  negated
end struct

// Groups the between expression state and preserves the field relationships documented below.
struct BetweenExpression
  // Stores the kind associated with this value.
  kind
  // Stores the operand associated with this value.
  operand
  // Stores the lower associated with this value.
  lower
  // Stores the upper associated with this value.
  upper
  // Indicates whether the negated condition is active.
  negated
end struct

// Groups the truth test expression state and preserves the field relationships documented below.
struct TruthTestExpression
  // Stores the kind associated with this value.
  kind
  // Stores the operand associated with this value.
  operand
  // Stores the expected associated with this value.
  expected
  // Indicates whether the negated condition is active.
  negated
end struct

// Internal typed literals preserve a fully decoded SqlValue while the executor
// materializes non-correlated subqueries and sequence calls before binding.
// Groups the typed literal expression state and preserves the field relationships documented below.
struct TypedLiteralExpression
  // Stores the kind associated with this value.
  kind
  // Stores the value associated with this value.
  value
end struct

// Groups the subquery expression state and preserves the field relationships documented below.
struct SubqueryExpression
  // Stores the kind associated with this value.
  kind
  // Stores the query associated with this value.
  query
end struct

// Groups the exists expression state and preserves the field relationships documented below.
struct ExistsExpression
  // Stores the kind associated with this value.
  kind
  // Stores the query associated with this value.
  query
end struct

// Groups the in subquery expression state and preserves the field relationships documented below.
struct InSubqueryExpression
  // Stores the kind associated with this value.
  kind
  // Stores the operand associated with this value.
  operand
  // Stores the query associated with this value.
  query
  // Indicates whether the negated condition is active.
  negated
end struct

// Groups the window expression state and preserves the field relationships documented below.
struct WindowExpression
  // Stores the kind associated with this value.
  kind
  // Stores the name associated with this value.
  name
  // Contains the ordered arguments collection.
  arguments
  // Stores the partition by associated with this value.
  partitionBy
  // Contains the ordered order by collection.
  orderBy
end struct

// Groups the column definition state and preserves the field relationships documented below.
struct ColumnDefinition
  // Stores the name associated with this value.
  name
  // Stores the type name associated with this value.
  typeName
  // Indicates whether the nullable condition is active.
  nullable
  // Indicates whether the nullable specified condition is active.
  nullableSpecified
  // Indicates whether the primary key condition is active.
  primaryKey
  // Indicates whether the unique condition is active.
  unique
  // Stores the default expression associated with this value.
  defaultExpression
  // Stores the check expression associated with this value.
  checkExpression
  // Stores the references table associated with this value.
  referencesTable
  // Stores the references columns associated with this value.
  referencesColumns
  // Stores the on delete associated with this value.
  onDelete
  // Stores the on update associated with this value.
  onUpdate
  // Stores the identity associated with this value.
  identity
  // Stores the generated expression associated with this value.
  generatedExpression
  // Stores the generated stored associated with this value.
  generatedStored
end struct

// Groups the table constraint state and preserves the field relationships documented below.
struct TableConstraint
  // Stores the kind associated with this value.
  kind
  // Stores the name associated with this value.
  name
  // Contains the ordered columns collection.
  columns
  // Stores the expression associated with this value.
  expression
  // Stores the references table associated with this value.
  referencesTable
  // Stores the references columns associated with this value.
  referencesColumns
  // Stores the on delete associated with this value.
  onDelete
  // Stores the on update associated with this value.
  onUpdate
end struct

// Groups the select item state and preserves the field relationships documented below.
struct SelectItem
  // Stores the expression associated with this value.
  expression
  // Stores the alias associated with this value.
  alias
end struct

// Groups the order item state and preserves the field relationships documented below.
struct OrderItem
  // Stores the expression associated with this value.
  expression
  // Stores the descending associated with this value.
  descending
  // Stores the nulls first associated with this value.
  nullsFirst
  // Stores the nulls specified associated with this value.
  nullsSpecified
end struct

// Groups the join clause state and preserves the field relationships documented below.
struct JoinClause
  // Stores the join type associated with this value.
  joinType
  // Stores the table name associated with this value.
  tableName
  // Stores the table alias associated with this value.
  tableAlias
  // Stores the condition associated with this value.
  condition
end struct

// Groups the set operation state and preserves the field relationships documented below.
struct SetOperation
  // Stores the operator associated with this value.
  operator
  // Stores the all associated with this value.
  all
  // Stores the query associated with this value.
  query
end struct

// Groups the assignment state and preserves the field relationships documented below.
struct Assignment
  // Stores the column associated with this value.
  column
  // Stores the expression associated with this value.
  expression
end struct

// Groups the create table statement state and preserves the field relationships documented below.
struct CreateTableStatement
  // Stores the name associated with this value.
  name
  // Contains the ordered columns collection.
  columns
  // Contains the ordered constraints collection.
  constraints
  // Stores the if not exists associated with this value.
  ifNotExists
end struct

// Groups the create index statement state and preserves the field relationships documented below.
struct CreateIndexStatement
  // Stores the name associated with this value.
  name
  // Stores the table name associated with this value.
  tableName
  // Contains the ordered columns collection.
  columns
  // Indicates whether the unique condition is active.
  unique
  // Stores the if not exists associated with this value.
  ifNotExists
end struct

// Represents removal of one explicitly-created index by its database-wide name.
struct DropIndexStatement
  // Stores the index name selected for removal.
  name
  // Allows the command to succeed without mutation when the index is absent.
  ifExists
end struct

// Groups the drop table statement state and preserves the field relationships documented below.
struct DropTableStatement
  // Stores the name associated with this value.
  name
  // Stores the if exists associated with this value.
  ifExists
end struct

// Represents creation of a durable SQL object namespace.
struct CreateSchemaStatement
  // Stores the schema name.
  name
  // Indicates whether an existing schema is accepted.
  ifNotExists
end struct

// Represents removal of an empty SQL object namespace.
struct DropSchemaStatement
  // Stores the schema name.
  name
  // Indicates whether a missing schema is accepted.
  ifExists
end struct

// Groups the create view statement state and preserves the field relationships documented below.
struct CreateViewStatement
  // Stores the name associated with this value.
  name
  // Stores the query associated with this value.
  query
  // Stores the replace associated with this value.
  replace
end struct

// Groups the drop view statement state and preserves the field relationships documented below.
struct DropViewStatement
  // Stores the name associated with this value.
  name
  // Stores the if exists associated with this value.
  ifExists
end struct

// Groups the create sequence statement state and preserves the field relationships documented below.
struct CreateSequenceStatement
  // Stores the name associated with this value.
  name
  // Stores the start value associated with this value.
  startValue
  // Stores the increment value associated with this value.
  incrementValue
  // Tracks the minimum value numeric value.
  minimumValue
  // Tracks the maximum value numeric value.
  maximumValue
  // Stores the cycle associated with this value.
  cycle
  // Stores the if not exists associated with this value.
  ifNotExists
end struct

// Groups the drop sequence statement state and preserves the field relationships documented below.
struct DropSequenceStatement
  // Stores the name associated with this value.
  name
  // Stores the if exists associated with this value.
  ifExists
end struct

// Groups the create trigger statement state and preserves the field relationships documented below.
struct CreateTriggerStatement
  // Stores the name associated with this value.
  name
  // Stores the timing associated with this value.
  timing
  // Stores the event type associated with this value.
  eventType
  // Stores the table name associated with this value.
  tableName
  // Stores the target column associated with this value.
  targetColumn
  // Stores the body associated with this value.
  body
  // Stores the if not exists associated with this value.
  ifNotExists
end struct

// Groups the drop trigger statement state and preserves the field relationships documented below.
struct DropTriggerStatement
  // Stores the name associated with this value.
  name
  // Stores the if exists associated with this value.
  ifExists
end struct

// Represents persistent activation changes for an existing trigger.
struct AlterTriggerStatement
  // Stores the trigger name.
  name
  // Indicates whether the trigger becomes enabled.
  enabled
end struct

// Defines one named stored-procedure input parameter.
struct ProcedureParameter
  // Stores the parameter name used in the procedure body.
  name
  // Stores its declared SQL type.
  typeName
end struct

// Represents a persisted single-statement stored procedure.
struct CreateProcedureStatement
  // Stores the qualified procedure name.
  name
  // Contains ordered input parameters.
  parameters
  // Stores the procedure's DML body.
  body
  // Indicates CREATE OR REPLACE behavior.
  replace
end struct

// Represents removal of a stored procedure.
struct DropProcedureStatement
  // Stores the qualified procedure name.
  name
  // Indicates whether a missing procedure is accepted.
  ifExists
end struct

// Represents invocation of a stored procedure with positional arguments.
struct CallStatement
  // Stores the qualified procedure name.
  name
  // Contains ordered argument expressions.
  arguments
end struct

// Groups the alter table statement state and preserves the field relationships documented below.
struct AlterTableStatement
  // Stores the table name associated with this value.
  tableName
  // Stores the action associated with this value.
  action
  // Stores the column definition associated with this value.
  columnDefinition
  // Stores the old name associated with this value.
  oldName
  // Stores the new name associated with this value.
  newName
  // Stores the constraint associated with this value.
  constraint
  // Stores the constraint name associated with this value.
  constraintName
end struct

// Groups the insert statement state and preserves the field relationships documented below.
struct InsertStatement
  // Stores the table name associated with this value.
  tableName
  // Contains the ordered columns collection.
  columns
  // Contains the ordered rows collection.
  rows
  // Stores the source query associated with this value.
  sourceQuery
  // Stores the conflict target associated with this value.
  conflictTarget
  // Stores the conflict action associated with this value.
  conflictAction
  // Stores the conflict assignments associated with this value.
  conflictAssignments
  // Stores the conflict where associated with this value.
  conflictWhere
  // Stores the returning associated with this value.
  returning
end struct

// Groups the update statement state and preserves the field relationships documented below.
struct UpdateStatement
  // Stores the table name associated with this value.
  tableName
  // Contains the ordered assignments collection.
  assignments
  // Stores the where expression associated with this value.
  whereExpression
  // Stores the returning associated with this value.
  returning
end struct

// Groups the delete statement state and preserves the field relationships documented below.
struct DeleteStatement
  // Stores the table name associated with this value.
  tableName
  // Stores the where expression associated with this value.
  whereExpression
  // Stores the returning associated with this value.
  returning
end struct

// Represents a source-driven conditional INSERT/UPDATE/DELETE operation.
struct MergeStatement
  // Stores the target table name.
  targetTable
  // Stores the optional target alias.
  targetAlias
  // Stores the source table name.
  sourceTable
  // Stores the optional source alias.
  sourceAlias
  // Stores the target/source match predicate.
  condition
  // Contains assignments for WHEN MATCHED UPDATE.
  matchedAssignments
  // Indicates WHEN MATCHED DELETE semantics.
  matchedDelete
  // Contains target columns for WHEN NOT MATCHED INSERT.
  insertColumns
  // Contains source expressions for WHEN NOT MATCHED INSERT.
  insertValues
end struct

// Groups the truncate statement state and preserves the field relationships documented below.
struct TruncateStatement
  // Stores the table name associated with this value.
  tableName
  // Stores the restart identity associated with this value.
  restartIdentity
end struct

// Groups the common table expression state and preserves the field relationships documented below.
struct CommonTableExpression
  // Stores the name associated with this value.
  name
  // Stores the query associated with this value.
  query
  // Stores the column names associated with this value.
  columnNames
  // Indicates whether this CTE may reference its own working table.
  recursive
end struct

// Groups the select statement state and preserves the field relationships documented below.
struct SelectStatement
  // Indicates whether the distinct condition is active.
  distinct
  // Tracks the items numeric value.
  items
  // Stores the table name associated with this value.
  tableName
  // Stores the table alias associated with this value.
  tableAlias
  // Contains the ordered joins collection.
  joins
  // Stores the where expression associated with this value.
  whereExpression
  // Stores the group by associated with this value.
  groupBy
  // Stores the having expression associated with this value.
  havingExpression
  // Stores the set operations associated with this value.
  setOperations
  // Contains the ordered order by collection.
  orderBy
  // Tracks the limit numeric value.
  limit
  // Tracks the offset numeric value.
  offset
  // Stores the ctes associated with this value.
  ctes
end struct

// Groups the begin statement state and preserves the field relationships documented below.
struct BeginStatement
  // Stores the read only associated with this value.
  readOnly
  // Indicates whether the isolation level condition is active.
  isolationLevel
end struct

// Groups the commit statement state and preserves the field relationships documented below.
struct CommitStatement
  // Stores the marker associated with this value.
  marker
end struct

// Groups the rollback statement state and preserves the field relationships documented below.
struct RollbackStatement
  // Stores the marker associated with this value.
  marker
end struct

// Groups the savepoint statement state and preserves the field relationships documented below.
struct SavepointStatement
  // Stores the name associated with this value.
  name
end struct

// Groups the rollback to statement state and preserves the field relationships documented below.
struct RollbackToStatement
  // Stores the name associated with this value.
  name
end struct

// Groups the release savepoint statement state and preserves the field relationships documented below.
struct ReleaseSavepointStatement
  // Stores the name associated with this value.
  name
end struct

// Groups the create principal statement state and preserves the field relationships documented below.
struct CreatePrincipalStatement
  // Stores the principal kind associated with this value.
  principalKind
  // Stores the name associated with this value.
  name
  // Stores the password associated with this value.
  password
end struct

// Groups the alter user statement state and preserves the field relationships documented below.
struct AlterUserStatement
  // Stores the name associated with this value.
  name
  // Stores the action associated with this value.
  action
  // Stores the password associated with this value.
  password
end struct

// Groups the drop principal statement state and preserves the field relationships documented below.
struct DropPrincipalStatement
  // Stores the principal kind associated with this value.
  principalKind
  // Stores the name associated with this value.
  name
  // Stores the if exists associated with this value.
  ifExists
end struct

// Groups the grant role statement state and preserves the field relationships documented below.
struct GrantRoleStatement
  // Stores the role name associated with this value.
  roleName
  // Stores the member name associated with this value.
  memberName
  // Stores the admin option associated with this value.
  adminOption
end struct

// Groups the revoke role statement state and preserves the field relationships documented below.
struct RevokeRoleStatement
  // Stores the role name associated with this value.
  roleName
  // Stores the member name associated with this value.
  memberName
  // Stores the cascade associated with this value.
  cascade
end struct

// Groups the grant privilege statement state and preserves the field relationships documented below.
struct GrantPrivilegeStatement
  // Contains the ordered privileges collection.
  privileges
  // Stores the object type associated with this value.
  objectType
  // Stores the object name associated with this value.
  objectName
  // Stores the grantee name associated with this value.
  granteeName
  // Stores the grant option associated with this value.
  grantOption
end struct

// Groups the revoke privilege statement state and preserves the field relationships documented below.
struct RevokePrivilegeStatement
  // Contains the ordered privileges collection.
  privileges
  // Stores the object type associated with this value.
  objectType
  // Stores the object name associated with this value.
  objectName
  // Stores the grantee name associated with this value.
  granteeName
  // Stores the cascade associated with this value.
  cascade
end struct

// Groups the analyze statement state and preserves the field relationships documented below.
struct AnalyzeStatement
  // Stores the table name associated with this value.
  tableName
end struct

// Groups the explain statement state and preserves the field relationships documented below.
struct ExplainStatement
  // Stores the analyze associated with this value.
  analyze
  // Stores the statement associated with this value.
  statement
end struct

// Groups the prepare statement state and preserves the field relationships documented below.
struct PrepareStatement
  // Stores the name associated with this value.
  name
  // Stores the statement associated with this value.
  statement
  // Tracks the parameter count numeric value.
  parameterCount
end struct

// Groups the execute prepared statement state and preserves the field relationships documented below.
struct ExecutePreparedStatement
  // Stores the name associated with this value.
  name
  // Contains the ordered arguments collection.
  arguments
end struct

// Groups the deallocate statement state and preserves the field relationships documented below.
struct DeallocateStatement
  // Stores the name associated with this value.
  name
end struct

// Groups the vacuum statement state and preserves the field relationships documented below.
struct VacuumStatement
  // Stores the table name associated with this value.
  tableName
end struct

// Groups the reindex statement state and preserves the field relationships documented below.
struct ReindexStatement
  // Stores the name associated with this value.
  name
end struct

// Groups the show tables statement state and preserves the field relationships documented below.
struct ShowTablesStatement
  // Stores the marker associated with this value.
  marker
end struct

// Groups the describe table statement state and preserves the field relationships documented below.
struct DescribeTableStatement
  // Stores the table name associated with this value.
  tableName
end struct

// Groups the show indexes statement state and preserves the field relationships documented below.
struct ShowIndexesStatement
  // Stores the table name associated with this value.
  tableName
end struct

// Implements identifier for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function identifier(name, quoted)
  if typeof(name) != "string" or len(name) == 0 or typeof(quoted) != "bool" then return error(9001, "sql.ast.identifier: invalid identifier") end if
  return Identifier(name, quoted)
end function

// Implements type name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function typeName(name, length, precision, scale)
  return TypeName(name, length, precision, scale)
end function

// Implements null literal for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function nullLiteral()
  return LiteralExpression(EXPR_LITERAL, LITERAL_NULL, void)
end function

// Implements boolean literal for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function booleanLiteral(value)
  return LiteralExpression(EXPR_LITERAL, LITERAL_BOOLEAN, value)
end function

// Implements integer literal for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function integerLiteral(value)
  return LiteralExpression(EXPR_LITERAL, LITERAL_INTEGER, value)
end function

// Implements float literal for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function floatLiteral(value)
  return LiteralExpression(EXPR_LITERAL, LITERAL_FLOAT, value)
end function

// Implements string literal for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function stringLiteral(value)
  return LiteralExpression(EXPR_LITERAL, LITERAL_STRING, value)
end function

// Implements current timestamp literal for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function currentTimestampLiteral()
  return LiteralExpression(EXPR_LITERAL, LITERAL_CURRENT_TIMESTAMP, void)
end function

// Implements column expression for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function columnExpression(qualifier, name)
  return ColumnExpression(EXPR_COLUMN, qualifier, name)
end function

// Implements star expression for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function starExpression(qualifier)
  return StarExpression(EXPR_STAR, qualifier)
end function

// Implements unary expression for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function unaryExpression(operator, operand)
  return UnaryExpression(EXPR_UNARY, operator, operand)
end function

// Implements binary expression for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function binaryExpression(operator, left, right)
  return BinaryExpression(EXPR_BINARY, operator, left, right)
end function

// Returns whether the supplied value satisfies the null expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isNullExpression(operand, negated)
  return IsNullExpression(EXPR_IS_NULL, operand, negated)
end function

// Implements function expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function functionExpression(name, arguments, distinct)
  if typeof(name) != "string" or len(name) == 0 or typeof(arguments) != "array" or typeof(distinct) != "bool" then return error(9001, "sql.ast.functionExpression: invalid function") end if
  return FunctionExpression(EXPR_FUNCTION, name, arguments, distinct)
end function

// Implements parameter expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function parameterExpression(index)
  if typeof(index) != "int" or index < 0 then return error(9001, "sql.ast.parameterExpression: invalid index") end if
  return ParameterExpression(EXPR_PARAMETER, index)
end function

// Implements case branch for this module.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function caseBranch(condition, result)
  if not isExpression(condition) or not isExpression(result) then return error(9001, "sql.ast.caseBranch: invalid branch") end if
  return CaseBranch(condition, result)
end function

// Implements case expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function caseExpression(branches, elseExpression)
  if typeof(branches) != "array" or len(branches) == 0 then return error(9001, "sql.ast.caseExpression: branches must be non-empty") end if
  for each branch in branches
    if branch is not CaseBranch then return error(9001, "sql.ast.caseExpression: invalid branch") end if
  end for
  if elseExpression is not void and not isExpression(elseExpression) then return error(9001, "sql.ast.caseExpression: invalid ELSE expression") end if
  return CaseExpression(EXPR_CASE, branches, elseExpression)
end function

// Casts expression using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function castExpression(operand, targetType)
  if not isExpression(operand) or targetType is not TypeName then return error(9001, "sql.ast.castExpression: invalid CAST") end if
  return CastExpression(EXPR_CAST, operand, targetType)
end function

// Implements in expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function inExpression(operand, candidates, negated)
  if not isExpression(operand) or typeof(candidates) != "array" or len(candidates) == 0 or typeof(negated) != "bool" then return error(9001, "sql.ast.inExpression: invalid IN predicate") end if
  for each candidate in candidates
    if not isExpression(candidate) then return error(9001, "sql.ast.inExpression: candidate is not expression") end if
  end for
  return InExpression(EXPR_IN, operand, candidates, negated)
end function

// Implements between expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function betweenExpression(operand, lower, upper, negated)
  if not isExpression(operand) or not isExpression(lower) or not isExpression(upper) or typeof(negated) != "bool" then return error(9001, "sql.ast.betweenExpression: invalid BETWEEN predicate") end if
  return BetweenExpression(EXPR_BETWEEN, operand, lower, upper, negated)
end function

// Implements truth test expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function truthTestExpression(operand, expected, negated)
  if not isExpression(operand) or typeof(expected) != "string" or typeof(negated) != "bool" then return error(9001, "sql.ast.truthTestExpression: invalid truth test") end if
  return TruthTestExpression(EXPR_TRUTH_TEST, operand, expected, negated)
end function

// Implements typed literal expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function typedLiteralExpression(value)
  if typeof(value) != "struct" then return error(9001, "sql.ast.typedLiteralExpression: value must be SqlValue") end if
  return TypedLiteralExpression(EXPR_TYPED_LITERAL, value)
end function

// Implements subquery expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function subqueryExpression(query)
  if query is not SelectStatement then return error(9001, "sql.ast.subqueryExpression: query must be SELECT") end if
  return SubqueryExpression(EXPR_SUBQUERY, query)
end function

// Implements exists expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function existsExpression(query)
  if query is not SelectStatement then return error(9001, "sql.ast.existsExpression: query must be SELECT") end if
  return ExistsExpression(EXPR_EXISTS, query)
end function

// Implements in subquery expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function inSubqueryExpression(operand, query, negated)
  if not isExpression(operand) or query is not SelectStatement or typeof(negated) != "bool" then return error(9001, "sql.ast.inSubqueryExpression: invalid IN subquery") end if
  return InSubqueryExpression(EXPR_IN_SUBQUERY, operand, query, negated)
end function

// Implements window expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function windowExpression(name, arguments, partitionBy, orderBy)
  if typeof(name) != "string" or len(name) == 0 or typeof(arguments) != "array" or typeof(partitionBy) != "array" or typeof(orderBy) != "array" then return error(9001, "sql.ast.windowExpression: invalid window expression") end if
  return WindowExpression(EXPR_WINDOW, name, arguments, partitionBy, orderBy)
end function

// Returns whether the supplied value satisfies the column expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isColumnExpression(value)
  return value is ColumnExpression
end function

// Returns whether the supplied value satisfies the star expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isStarExpression(value)
  return value is StarExpression
end function

// Returns whether the supplied value satisfies the unary expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isUnaryExpression(value)
  return value is UnaryExpression
end function

// Returns whether the supplied value satisfies the binary expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isBinaryExpression(value)
  return value is BinaryExpression
end function

// Returns whether the supplied value satisfies the is null expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isIsNullExpression(value)
  return value is IsNullExpression
end function

// Returns whether the supplied value satisfies the function expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isFunctionExpression(value)
  return value is FunctionExpression
end function

// Returns whether the supplied value satisfies the parameter expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isParameterExpression(value)
  return value is ParameterExpression
end function

// Returns whether the supplied value satisfies the case expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isCaseExpression(value)
  return value is CaseExpression
end function

// Returns whether the supplied value satisfies the cast expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isCastExpression(value)
  return value is CastExpression
end function

// Returns whether the supplied value satisfies the in expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isInExpression(value)
  return value is InExpression
end function

// Returns whether the supplied value satisfies the between expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isBetweenExpression(value)
  return value is BetweenExpression
end function

// Returns whether the supplied value satisfies the truth test expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isTruthTestExpression(value)
  return value is TruthTestExpression
end function

// Returns whether the supplied value satisfies the typed literal expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isTypedLiteralExpression(value)
  return value is TypedLiteralExpression
end function

// Returns whether the supplied value satisfies the subquery expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isSubqueryExpression(value)
  return value is SubqueryExpression
end function

// Returns whether the supplied value satisfies the exists expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isExistsExpression(value)
  return value is ExistsExpression
end function

// Returns whether the supplied value satisfies the in subquery expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isInSubqueryExpression(value)
  return value is InSubqueryExpression
end function

// Returns whether the supplied value satisfies the window expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isWindowExpression(value)
  return value is WindowExpression
end function

// Returns whether the supplied value satisfies the literal expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isLiteralExpression(value)
  return value is LiteralExpression
end function

// Returns whether the supplied value satisfies the type name condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isTypeName(value)
  return value is TypeName
end function

// Returns whether the supplied value satisfies the expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isExpression(value)
  return value is LiteralExpression or value is ColumnExpression or value is StarExpression or value is UnaryExpression or value is BinaryExpression or value is IsNullExpression or value is FunctionExpression or value is ParameterExpression or value is CaseExpression or value is CastExpression or value is InExpression or value is BetweenExpression or value is TruthTestExpression or value is TypedLiteralExpression or value is SubqueryExpression or value is ExistsExpression or value is InSubqueryExpression or value is WindowExpression
end function

// Returns whether the supplied value satisfies the create table statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isCreateTableStatement(value)
  return value is CreateTableStatement
end function

// Returns whether the supplied value satisfies the create index statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isCreateIndexStatement(value)
  return value is CreateIndexStatement
end function

// Returns whether the supplied value is a DROP INDEX statement.
function isDropIndexStatement(value)
  return value is DropIndexStatement
end function

// Returns whether the supplied value satisfies the drop table statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isDropTableStatement(value)
  return value is DropTableStatement
end function

// Returns whether the supplied statement creates a schema namespace.
function isCreateSchemaStatement(value)
  return value is CreateSchemaStatement
end function

// Returns whether the supplied statement drops a schema namespace.
function isDropSchemaStatement(value)
  return value is DropSchemaStatement
end function

// Returns whether the supplied value satisfies the create view statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isCreateViewStatement(value)
  return value is CreateViewStatement
end function

// Returns whether the supplied value satisfies the drop view statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isDropViewStatement(value)
  return value is DropViewStatement
end function

// Returns whether the supplied value satisfies the create sequence statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isCreateSequenceStatement(value)
  return value is CreateSequenceStatement
end function

// Returns whether the supplied value satisfies the drop sequence statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isDropSequenceStatement(value)
  return value is DropSequenceStatement
end function

// Returns whether the supplied value satisfies the create trigger statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isCreateTriggerStatement(value)
  return value is CreateTriggerStatement
end function

// Returns whether the supplied value satisfies the drop trigger statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isDropTriggerStatement(value)
  return value is DropTriggerStatement
end function

// Returns whether the supplied statement changes trigger activation.
function isAlterTriggerStatement(value)
  return value is AlterTriggerStatement
end function

// Returns whether the supplied statement creates a stored procedure.
function isCreateProcedureStatement(value)
  return value is CreateProcedureStatement
end function

// Returns whether the supplied statement drops a stored procedure.
function isDropProcedureStatement(value)
  return value is DropProcedureStatement
end function

// Returns whether the supplied statement invokes a stored procedure.
function isCallStatement(value)
  return value is CallStatement
end function

// Returns whether the supplied value satisfies the alter table statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isAlterTableStatement(value)
  return value is AlterTableStatement
end function

// Returns whether the supplied value satisfies the insert statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isInsertStatement(value)
  return value is InsertStatement
end function

// Returns whether the supplied value satisfies the update statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isUpdateStatement(value)
  return value is UpdateStatement
end function

// Returns whether the supplied value satisfies the delete statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isDeleteStatement(value)
  return value is DeleteStatement
end function

// Returns whether the supplied statement is a MERGE operation.
function isMergeStatement(value)
  return value is MergeStatement
end function

// Returns whether the supplied value satisfies the truncate statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isTruncateStatement(value)
  return value is TruncateStatement
end function

// Returns whether the supplied value satisfies the select statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isSelectStatement(value)
  return value is SelectStatement
end function

// Returns whether the supplied value satisfies the begin statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isBeginStatement(value)
  return value is BeginStatement
end function

// Returns whether the supplied value satisfies the commit statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isCommitStatement(value)
  return value is CommitStatement
end function

// Returns whether the supplied value satisfies the rollback statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isRollbackStatement(value)
  return value is RollbackStatement
end function

// Returns whether the supplied value satisfies the savepoint statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isSavepointStatement(value)
  return value is SavepointStatement
end function

// Returns whether the supplied value satisfies the rollback to statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isRollbackToStatement(value)
  return value is RollbackToStatement
end function

// Returns whether the supplied value satisfies the release savepoint statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isReleaseSavepointStatement(value)
  return value is ReleaseSavepointStatement
end function

// Returns whether the supplied value satisfies the create principal statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isCreatePrincipalStatement(value)
  return value is CreatePrincipalStatement
end function

// Returns whether the supplied value satisfies the alter user statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isAlterUserStatement(value)
  return value is AlterUserStatement
end function

// Returns whether the supplied value satisfies the drop principal statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isDropPrincipalStatement(value)
  return value is DropPrincipalStatement
end function

// Returns whether the supplied value satisfies the grant role statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isGrantRoleStatement(value)
  return value is GrantRoleStatement
end function

// Returns whether the supplied value satisfies the revoke role statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isRevokeRoleStatement(value)
  return value is RevokeRoleStatement
end function

// Returns whether the supplied value satisfies the grant privilege statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isGrantPrivilegeStatement(value)
  return value is GrantPrivilegeStatement
end function

// Returns whether the supplied value satisfies the revoke privilege statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isRevokePrivilegeStatement(value)
  return value is RevokePrivilegeStatement
end function

// Returns whether the supplied value satisfies the dcl statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isDclStatement(value)
  return value is CreatePrincipalStatement or value is AlterUserStatement or value is DropPrincipalStatement or value is GrantRoleStatement or value is RevokeRoleStatement or value is GrantPrivilegeStatement or value is RevokePrivilegeStatement
end function

// Returns whether the supplied value satisfies the analyze statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isAnalyzeStatement(value)
  return value is AnalyzeStatement
end function

// Returns whether the supplied value satisfies the explain statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isExplainStatement(value)
  return value is ExplainStatement
end function

// Returns whether the supplied value satisfies the prepare statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isPrepareStatement(value)
  return value is PrepareStatement
end function

// Returns whether the supplied value satisfies the execute prepared statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isExecutePreparedStatement(value)
  return value is ExecutePreparedStatement
end function

// Returns whether the supplied value satisfies the deallocate statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isDeallocateStatement(value)
  return value is DeallocateStatement
end function

// Returns whether the supplied value satisfies the vacuum statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isVacuumStatement(value)
  return value is VacuumStatement
end function

// Returns whether the supplied value satisfies the reindex statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isReindexStatement(value)
  return value is ReindexStatement
end function

// Returns whether the supplied value satisfies the show tables statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isShowTablesStatement(value)
  return value is ShowTablesStatement
end function

// Returns whether the supplied value satisfies the describe table statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isDescribeTableStatement(value)
  return value is DescribeTableStatement
end function

// Returns whether the supplied value satisfies the show indexes statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isShowIndexesStatement(value)
  return value is ShowIndexesStatement
end function

// Returns whether the supplied value satisfies the metadata statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isMetadataStatement(value)
  return value is ShowTablesStatement or value is DescribeTableStatement or value is ShowIndexesStatement
end function

// Returns whether the supplied value satisfies the statement condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isStatement(value)
  return value is CreateTableStatement or value is CreateIndexStatement or value is DropIndexStatement or value is DropTableStatement or value is CreateSchemaStatement or value is DropSchemaStatement or value is CreateViewStatement or value is DropViewStatement or value is CreateSequenceStatement or value is DropSequenceStatement or value is CreateTriggerStatement or value is DropTriggerStatement or value is AlterTriggerStatement or value is CreateProcedureStatement or value is DropProcedureStatement or value is CallStatement or value is AlterTableStatement or value is InsertStatement or value is UpdateStatement or value is DeleteStatement or value is MergeStatement or value is TruncateStatement or value is SelectStatement or value is BeginStatement or value is CommitStatement or value is RollbackStatement or value is SavepointStatement or value is RollbackToStatement or value is ReleaseSavepointStatement or value is AnalyzeStatement or value is ExplainStatement or value is PrepareStatement or value is ExecutePreparedStatement or value is DeallocateStatement or value is VacuumStatement or value is ReindexStatement or isMetadataStatement(value) or isDclStatement(value)
end function

// Implements expression kind for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function expressionKind(value)
  if not isExpression(value) then return 0 end if
  return value.kind
end function

// Implements quote string for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Formats type name using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Formats function using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Formats expression using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Formats select item using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function formatSelectItem(item)
  output = formatExpression(item.expression)
  if item.alias is not void then output = output + " AS " + item.alias end if
  return output
end function

// Formats order item using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function formatOrderItem(item)
  output = formatExpression(item.expression)
  if item.descending then output = output + " DESC" else output = output + " ASC" end if
  if item.nullsSpecified then
    if item.nullsFirst then output = output + " NULLS FIRST" else output = output + " NULLS LAST" end if
  end if
  return output
end function

// Formats select using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function formatSelect(statement)
  if statement is not SelectStatement then return error(9001, "sql.ast.formatSelect: statement must be SELECT") end if
  output = ""
  if len(statement.ctes) > 0 then
    output = "WITH "
    recursive = false
    for each cte in statement.ctes
      if cte.recursive then recursive = true end if
    end for
    if recursive then output = output + "RECURSIVE " end if
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

// Formats statement using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function formatStatement(statement)
  if statement is SelectStatement then return formatSelect(statement) end if
  if statement is CreateSchemaStatement then
    output = "CREATE SCHEMA "
    if statement.ifNotExists then output = output + "IF NOT EXISTS " end if
    return output + statement.name
  end if
  if statement is DropSchemaStatement then
    output = "DROP SCHEMA "
    if statement.ifExists then output = output + "IF EXISTS " end if
    return output + statement.name
  end if
  if statement is DropIndexStatement then
    output = "DROP INDEX "
    if statement.ifExists then output = output + "IF EXISTS " end if
    return output + statement.name
  end if
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
    return output
  end if
  if statement is UpdateStatement then
    output = "UPDATE " + statement.tableName + " SET "
    for index = 0 to len(statement.assignments) - 1
      if index > 0 then output = output + ", " end if
      output = output + statement.assignments[index].column + " = " + formatExpression(statement.assignments[index].expression)
    end for
    if statement.whereExpression is not void then output = output + " WHERE " + formatExpression(statement.whereExpression) end if
    return output
  end if
  if statement is DeleteStatement then
    output = "DELETE FROM " + statement.tableName
    if statement.whereExpression is not void then output = output + " WHERE " + formatExpression(statement.whereExpression) end if
    return output
  end if
  if statement is MergeStatement then return "MERGE INTO " + statement.targetTable + " USING " + statement.sourceTable + " ON " + formatExpression(statement.condition) end if
  return error(9001, "sql.ast.formatStatement: unsupported statement")
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "sql.ast"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M12"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
