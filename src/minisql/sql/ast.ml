//! Provides minisql sql ast facilities for this project.

package minisql.sql.ast

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.sql.dialect as dialect

/// Syntax tree for the MiniSQL SQL front end. The AST contains no catalog

const EXPR_LITERAL = 1
/// Defines the expr column constant used by the minisql sql ast module.
const EXPR_COLUMN = 2
/// Defines the expr star constant used by the minisql sql ast module.
const EXPR_STAR = 3
/// Defines the expr unary constant used by the minisql sql ast module.
const EXPR_UNARY = 4
/// Defines the expr binary constant used by the minisql sql ast module.
const EXPR_BINARY = 5
/// Defines the expr is null constant used by the minisql sql ast module.
const EXPR_IS_NULL = 6
/// Defines the expr function constant used by the minisql sql ast module.
const EXPR_FUNCTION = 7
/// Defines the expr parameter constant used by the minisql sql ast module.
const EXPR_PARAMETER = 8
/// Defines the expr case constant used by the minisql sql ast module.
const EXPR_CASE = 9
/// Defines the expr cast constant used by the minisql sql ast module.
const EXPR_CAST = 10
/// Defines the expr in constant used by the minisql sql ast module.
const EXPR_IN = 11
/// Defines the expr between constant used by the minisql sql ast module.
const EXPR_BETWEEN = 12
/// Defines the expr truth test constant used by the minisql sql ast module.
const EXPR_TRUTH_TEST = 13
/// Defines the expr typed literal constant used by the minisql sql ast module.
const EXPR_TYPED_LITERAL = 14
/// Defines the expr subquery constant used by the minisql sql ast module.
const EXPR_SUBQUERY = 15
/// Defines the expr exists constant used by the minisql sql ast module.
const EXPR_EXISTS = 16
/// Defines the expr in subquery constant used by the minisql sql ast module.
const EXPR_IN_SUBQUERY = 17
/// Defines the expr window constant used by the minisql sql ast module.
const EXPR_WINDOW = 18

/// Defines the literal null constant used by the minisql sql ast module.
const LITERAL_NULL = 0
/// Defines the literal boolean constant used by the minisql sql ast module.
const LITERAL_BOOLEAN = 1
/// Defines the literal integer constant used by the minisql sql ast module.
const LITERAL_INTEGER = 2
/// Defines the literal float constant used by the minisql sql ast module.
const LITERAL_FLOAT = 3
/// Defines the literal string constant used by the minisql sql ast module.
const LITERAL_STRING = 4
/// Defines the literal current timestamp constant used by the minisql sql ast module.
const LITERAL_CURRENT_TIMESTAMP = 5

/// Defines the constraint primary key constant used by the minisql sql ast module.
const CONSTRAINT_PRIMARY_KEY = 1
/// Defines the constraint unique constant used by the minisql sql ast module.
const CONSTRAINT_UNIQUE = 2
/// Defines the constraint check constant used by the minisql sql ast module.
const CONSTRAINT_CHECK = 3
/// Defines the constraint foreign key constant used by the minisql sql ast module.
const CONSTRAINT_FOREIGN_KEY = 4

/// Defines the join inner constant used by the minisql sql ast module.
const JOIN_INNER = 1
/// Defines the join left constant used by the minisql sql ast module.
const JOIN_LEFT = 2
/// Defines the join cross constant used by the minisql sql ast module.
const JOIN_CROSS = 3
/// Defines the join right constant used by the minisql sql ast module.
const JOIN_RIGHT = 4
/// Defines the join full constant used by the minisql sql ast module.
const JOIN_FULL = 5

/// Defines the set union constant used by the minisql sql ast module.
const SET_UNION = 1
/// Defines the set intersect constant used by the minisql sql ast module.
const SET_INTERSECT = 2
/// Defines the set except constant used by the minisql sql ast module.
const SET_EXCEPT = 3

/// Defines the conflict none constant used by the minisql sql ast module.
const CONFLICT_NONE = 0
/// Defines the conflict do nothing constant used by the minisql sql ast module.
const CONFLICT_DO_NOTHING = 1
/// Defines the conflict do update constant used by the minisql sql ast module.
const CONFLICT_DO_UPDATE = 2

/// Defines the principal user constant used by the minisql sql ast module.
const PRINCIPAL_USER = 1
/// Defines the principal role constant used by the minisql sql ast module.
const PRINCIPAL_ROLE = 2
/// Defines the alter user password constant used by the minisql sql ast module.
const ALTER_USER_PASSWORD = 1
/// Defines the alter user enable constant used by the minisql sql ast module.
const ALTER_USER_ENABLE = 2
/// Defines the alter user disable constant used by the minisql sql ast module.
const ALTER_USER_DISABLE = 3
/// Defines the dcl object database constant used by the minisql sql ast module.
const DCL_OBJECT_DATABASE = 1
/// Defines the dcl object table constant used by the minisql sql ast module.
const DCL_OBJECT_TABLE = 2
/// Identifies a durable stored procedure privilege target.
const DCL_OBJECT_PROCEDURE = 3

/// Defines the alter table add column constant used by the minisql sql ast module.
const ALTER_TABLE_ADD_COLUMN = 1
/// Defines the alter table rename column constant used by the minisql sql ast module.
const ALTER_TABLE_RENAME_COLUMN = 2
/// Defines the alter table rename table constant used by the minisql sql ast module.
const ALTER_TABLE_RENAME_TABLE = 3
/// Defines the alter table add constraint constant used by the minisql sql ast module.
const ALTER_TABLE_ADD_CONSTRAINT = 4
/// Defines the alter table drop constraint constant used by the minisql sql ast module.
const ALTER_TABLE_DROP_CONSTRAINT = 5
/// Defines the alter table drop column constant used by the minisql sql ast module.
const ALTER_TABLE_DROP_COLUMN = 6
/// Defines the alter table set default constant used by the minisql sql ast module.
const ALTER_TABLE_SET_DEFAULT = 7
/// Defines the alter table drop default constant used by the minisql sql ast module.
const ALTER_TABLE_DROP_DEFAULT = 8
/// Defines the alter table set not null constant used by the minisql sql ast module.
const ALTER_TABLE_SET_NOT_NULL = 9
/// Defines the alter table drop not null constant used by the minisql sql ast module.
const ALTER_TABLE_DROP_NOT_NULL = 10

/// Groups the identifier state and preserves the field relationships documented below.
struct Identifier
  /// Stores the name associated with this value.
  name
  /// Indicates whether the quoted condition is active.
  quoted
end struct

/// Groups the type name state and preserves the field relationships documented below.
struct TypeName
  /// Stores the name associated with this value.
  name
  /// Tracks the length numeric value.
  length
  /// Stores the precision associated with this value.
  precision
  /// Stores the scale associated with this value.
  scale
end struct

/// Groups the literal expression state and preserves the field relationships documented below.
struct LiteralExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the literal kind associated with this value.
  literalKind
  /// Stores the value associated with this value.
  value
end struct

/// Groups the column expression state and preserves the field relationships documented below.
struct ColumnExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the qualifier associated with this value.
  qualifier
  /// Stores the name associated with this value.
  name
end struct

/// Groups the star expression state and preserves the field relationships documented below.
struct StarExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the qualifier associated with this value.
  qualifier
end struct

/// Groups the unary expression state and preserves the field relationships documented below.
struct UnaryExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the operator associated with this value.
  operatorValue
  /// Stores the operand associated with this value.
  operand
end struct

/// Groups the binary expression state and preserves the field relationships documented below.
struct BinaryExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the operator associated with this value.
  operatorValue
  /// Stores the left associated with this value.
  left
  /// Stores the right associated with this value.
  right
end struct

/// Groups the is null expression state and preserves the field relationships documented below.
struct IsNullExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the operand associated with this value.
  operand
  /// Indicates whether the negated condition is active.
  negated
end struct

/// Groups the function expression state and preserves the field relationships documented below.
struct FunctionExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the name associated with this value.
  name
  /// Contains the ordered arguments collection.
  arguments
  /// Indicates whether the distinct condition is active.
  distinct
end struct

/// Groups the parameter expression state and preserves the field relationships documented below.
struct ParameterExpression
  /// Stores the kind associated with this value.
  kind
  /// Tracks the index numeric value.
  index
end struct

/// Groups the case branch state and preserves the field relationships documented below.
struct CaseBranch
  /// Stores the condition associated with this value.
  condition
  /// Stores the result associated with this value.
  result
end struct

/// Groups the case expression state and preserves the field relationships documented below.
struct CaseExpression
  /// Stores the kind associated with this value.
  kind
  /// Contains the ordered branches collection.
  branches
  /// Stores the else expression associated with this value.
  elseExpression
end struct

/// Groups the cast expression state and preserves the field relationships documented below.
struct CastExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the operand associated with this value.
  operand
  /// Stores the target type associated with this value.
  targetType
end struct

/// Groups the in expression state and preserves the field relationships documented below.
struct InExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the operand associated with this value.
  operand
  /// Contains the ordered values collection.
  values
  /// Indicates whether the negated condition is active.
  negated
end struct

/// Groups the between expression state and preserves the field relationships documented below.
struct BetweenExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the operand associated with this value.
  operand
  /// Stores the lower associated with this value.
  lower
  /// Stores the upper associated with this value.
  upper
  /// Indicates whether the negated condition is active.
  negated
end struct

/// Groups the truth test expression state and preserves the field relationships documented below.
struct TruthTestExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the operand associated with this value.
  operand
  /// Stores the expected associated with this value.
  expected
  /// Indicates whether the negated condition is active.
  negated
end struct

/// Internal typed literals preserve a fully decoded SqlValue while the executor
/// materializes non-correlated subqueries and sequence calls before binding.
/// Groups the typed literal expression state and preserves the field relationships documented below.
struct TypedLiteralExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the value associated with this value.
  value
end struct

/// Groups the subquery expression state and preserves the field relationships documented below.
struct SubqueryExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the query associated with this value.
  query
end struct

/// Groups the exists expression state and preserves the field relationships documented below.
struct ExistsExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the query associated with this value.
  query
end struct

/// Groups the in subquery expression state and preserves the field relationships documented below.
struct InSubqueryExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the operand associated with this value.
  operand
  /// Stores the query associated with this value.
  query
  /// Indicates whether the negated condition is active.
  negated
end struct

/// Groups the window expression state and preserves the field relationships documented below.
struct WindowExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the name associated with this value.
  name
  /// Contains the ordered arguments collection.
  arguments
  /// Stores the partition by associated with this value.
  partitionBy
  /// Contains the ordered order by collection.
  orderBy
end struct

/// Groups the column definition state and preserves the field relationships documented below.
struct ColumnDefinition
  /// Stores the name associated with this value.
  name
  /// Stores the type name associated with this value.
  typeName
  /// Indicates whether the nullable condition is active.
  nullable
  /// Indicates whether the nullable specified condition is active.
  nullableSpecified
  /// Indicates whether the primary key condition is active.
  primaryKey
  /// Indicates whether the unique condition is active.
  unique
  /// Stores the default expression associated with this value.
  defaultExpression
  /// Stores the check expression associated with this value.
  checkExpression
  /// Stores the references table associated with this value.
  referencesTable
  /// Stores the references columns associated with this value.
  referencesColumns
  /// Stores the on delete associated with this value.
  onDelete
  /// Stores the on update associated with this value.
  onUpdate
  /// Stores the identity associated with this value.
  identity
  /// Stores the generated expression associated with this value.
  generatedExpression
  /// Stores the generated stored associated with this value.
  generatedStored
end struct

/// Groups the table constraint state and preserves the field relationships documented below.
struct TableConstraint
  /// Stores the kind associated with this value.
  kind
  /// Stores the name associated with this value.
  name
  /// Contains the ordered columns collection.
  columns
  /// Stores the expression associated with this value.
  expression
  /// Stores the references table associated with this value.
  referencesTable
  /// Stores the references columns associated with this value.
  referencesColumns
  /// Stores the on delete associated with this value.
  onDelete
  /// Stores the on update associated with this value.
  onUpdate
end struct

/// Groups the select item state and preserves the field relationships documented below.
struct SelectItem
  /// Stores the expression associated with this value.
  expression
  /// Stores the alias associated with this value.
  alias
end struct

/// Groups the order item state and preserves the field relationships documented below.
struct OrderItem
  /// Stores the expression associated with this value.
  expression
  /// Stores the descending associated with this value.
  descending
  /// Stores the nulls first associated with this value.
  nullsFirst
  /// Stores the nulls specified associated with this value.
  nullsSpecified
end struct

/// Groups the join clause state and preserves the field relationships documented below.
struct JoinClause
  /// Stores the join type associated with this value.
  joinType
  /// Stores the table name associated with this value.
  tableName
  /// Stores the table alias associated with this value.
  tableAlias
  /// Stores the condition associated with this value.
  condition
end struct

/// Groups the set operation state and preserves the field relationships documented below.
struct SetOperation
  /// Stores the operator associated with this value.
  operatorValue
  /// Stores the all associated with this value.
  all
  /// Stores the query associated with this value.
  query
end struct

/// Groups the assignment state and preserves the field relationships documented below.
struct Assignment
  /// Stores the column associated with this value.
  column
  /// Stores the expression associated with this value.
  expression
end struct

/// Groups the create table statement state and preserves the field relationships documented below.
struct CreateTableStatement
  /// Stores the name associated with this value.
  name
  /// Contains the ordered columns collection.
  columns
  /// Contains the ordered constraints collection.
  constraints
  /// Stores the if not exists associated with this value.
  ifNotExists
end struct

/// Groups the create index statement state and preserves the field relationships documented below.
struct CreateIndexStatement
  /// Stores the name associated with this value.
  name
  /// Stores the table name associated with this value.
  tableName
  /// Contains ordered column or deterministic expression key AST nodes.
  columns
  /// Ordered non-key columns persisted in each leaf entry for covering scans.
  includeColumns
  /// Optional deterministic predicate selecting rows stored by a partial index.
  whereExpression
  /// Indicates whether the unique condition is active.
  unique
  /// Stores the if not exists associated with this value.
  ifNotExists
end struct

/// Represents removal of one explicitly-created index by its database-wide name.
struct DropIndexStatement
  /// Stores the index name selected for removal.
  name
  /// Allows the command to succeed without mutation when the index is absent.
  ifExists
end struct

/// Groups the drop table statement state and preserves the field relationships documented below.
struct DropTableStatement
  /// Stores the name associated with this value.
  name
  /// Stores the if exists associated with this value.
  ifExists
end struct

/// Represents creation of a durable SQL object namespace.
struct CreateSchemaStatement
  /// Stores the schema name.
  name
  /// Indicates whether an existing schema is accepted.
  ifNotExists
end struct

/// Represents removal of an empty SQL object namespace.
struct DropSchemaStatement
  /// Stores the schema name.
  name
  /// Indicates whether a missing schema is accepted.
  ifExists
end struct

/// Groups the create view statement state and preserves the field relationships documented below.
struct CreateViewStatement
  /// Stores the name associated with this value.
  name
  /// Stores the query associated with this value.
  query
  /// Stores the replace associated with this value.
  replace
end struct

/// Groups the drop view statement state and preserves the field relationships documented below.
struct DropViewStatement
  /// Stores the name associated with this value.
  name
  /// Stores the if exists associated with this value.
  ifExists
end struct

/// Groups the create sequence statement state and preserves the field relationships documented below.
struct CreateSequenceStatement
  /// Stores the name associated with this value.
  name
  /// Stores the start value associated with this value.
  startValue
  /// Stores the increment value associated with this value.
  incrementValue
  /// Tracks the minimum value numeric value.
  minimumValue
  /// Tracks the maximum value numeric value.
  maximumValue
  /// Stores the cycle associated with this value.
  cycle
  /// Stores the if not exists associated with this value.
  ifNotExists
end struct

/// Groups the drop sequence statement state and preserves the field relationships documented below.
struct DropSequenceStatement
  /// Stores the name associated with this value.
  name
  /// Stores the if exists associated with this value.
  ifExists
end struct

/// Groups the create trigger statement state and preserves the field relationships documented below.
struct CreateTriggerStatement
  /// Stores the name associated with this value.
  name
  /// Stores the timing associated with this value.
  timing
  /// Stores the event type associated with this value.
  eventType
  /// Stores the table name associated with this value.
  tableName
  /// Stores the target column associated with this value.
  targetColumn
  /// Stores the body associated with this value.
  body
  /// Stores the if not exists associated with this value.
  ifNotExists
end struct

/// Groups the drop trigger statement state and preserves the field relationships documented below.
struct DropTriggerStatement
  /// Stores the name associated with this value.
  name
  /// Stores the if exists associated with this value.
  ifExists
end struct

/// Represents persistent activation changes for an existing trigger.
struct AlterTriggerStatement
  /// Stores the trigger name.
  name
  /// Indicates whether the trigger becomes enabled.
  enabled
end struct

/// Represents one procedural statement without weakening ordinary SQL AST types.
/// The kind determines the contracts of its remaining fields; nested statements
/// always live in body/alternate and expressions remain ordinary SQL AST nodes.
struct RoutineStatement
  /// Uppercase procedural operation (BLOCK, DECLARE, IF, SET, and so on).
  kind
  /// Label, cursor, condition, procedure name, or handler action when applicable.
  name
  /// Ordered variable targets or diagnostic item names.
  names
  /// Ordered SQL expression operands.
  expressions
  /// Ordered nested statements or branch BLOCK nodes.
  body
  /// ELSE branch statements, when present.
  alternate
  /// Kind-specific type, condition, or characteristic metadata.
  options
end struct

/// Defines one named stored-procedure parameter and its passing direction.
struct ProcedureParameter
  /// Stores the parameter name used in the procedure body.
  name
  /// Stores its declared SQL type.
  typeName
  /// IN, OUT, or INOUT; omitted SQL directions become IN.
  mode
end struct

/// Represents a persisted procedure with a single SQL or compound body.
struct CreateProcedureStatement
  /// Stores the qualified procedure name.
  name
  /// Contains ordered input parameters.
  parameters
  /// Stores the procedure's SQL or procedural body.
  body
  /// Indicates CREATE OR REPLACE behavior.
  replace
  /// Ordered [name, value] characteristic pairs explicitly supplied by the user.
  characteristics
  /// Allows creation to succeed when the procedure already exists.
  ifNotExists
end struct

/// Represents removal of a stored procedure.
struct DropProcedureStatement
  /// Stores the qualified procedure name.
  name
  /// Indicates whether a missing procedure is accepted.
  ifExists
end struct

/// Represents invocation of a stored procedure with positional arguments.
struct CallStatement
  /// Stores the qualified procedure name.
  name
  /// Contains ordered argument expressions.
  arguments
end struct

/// Groups the alter table statement state and preserves the field relationships documented below.
struct AlterTableStatement
  /// Stores the table name associated with this value.
  tableName
  /// Stores the action associated with this value.
  action
  /// Stores the column definition associated with this value.
  columnDefinition
  /// Stores the old name associated with this value.
  oldName
  /// Stores the new name associated with this value.
  newName
  /// Stores the constraint associated with this value.
  constraint
  /// Stores the constraint name associated with this value.
  constraintName
end struct

/// Groups the insert statement state and preserves the field relationships documented below.
struct InsertStatement
  /// Stores the table name associated with this value.
  tableName
  /// Contains the ordered columns collection.
  columns
  /// Contains the ordered rows collection.
  rows
  /// Stores the source query associated with this value.
  sourceQuery
  /// Stores the conflict target associated with this value.
  conflictTarget
  /// Stores the conflict action associated with this value.
  conflictAction
  /// Stores the conflict assignments associated with this value.
  conflictAssignments
  /// Stores the conflict where associated with this value.
  conflictWhere
  /// Stores the returning associated with this value.
  returning
end struct

/// Groups the update statement state and preserves the field relationships documented below.
struct UpdateStatement
  /// Stores the table name associated with this value.
  tableName
  /// Contains the ordered assignments collection.
  assignments
  /// Stores the where expression associated with this value.
  whereExpression
  /// Stores the returning associated with this value.
  returning
end struct

/// Groups the delete statement state and preserves the field relationships documented below.
struct DeleteStatement
  /// Stores the table name associated with this value.
  tableName
  /// Stores the where expression associated with this value.
  whereExpression
  /// Stores the returning associated with this value.
  returning
end struct

/// Represents a source-driven conditional INSERT/UPDATE/DELETE operation.
struct MergeStatement
  /// Stores the target table name.
  targetTable
  /// Stores the optional target alias.
  targetAlias
  /// Stores the source table name.
  sourceTable
  /// Stores the optional source alias.
  sourceAlias
  /// Stores the target/source match predicate.
  condition
  /// Contains assignments for WHEN MATCHED UPDATE.
  matchedAssignments
  /// Indicates WHEN MATCHED DELETE semantics.
  matchedDelete
  /// Contains target columns for WHEN NOT MATCHED INSERT.
  insertColumns
  /// Contains source expressions for WHEN NOT MATCHED INSERT.
  insertValues
end struct

/// Groups the truncate statement state and preserves the field relationships documented below.
struct TruncateStatement
  /// Stores the table name associated with this value.
  tableName
  /// Stores the restart identity associated with this value.
  restartIdentity
end struct

/// Groups the common table expression state and preserves the field relationships documented below.
struct CommonTableExpression
  /// Stores the name associated with this value.
  name
  /// Stores the query associated with this value.
  query
  /// Stores the column names associated with this value.
  columnNames
  /// Indicates whether this CTE may reference its own working table.
  recursive
end struct

/// Groups the select statement state and preserves the field relationships documented below.
struct SelectStatement
  /// Indicates whether the distinct condition is active.
  distinct
  /// Tracks the items numeric value.
  items
  /// Stores the table name associated with this value.
  tableName
  /// Stores the table alias associated with this value.
  tableAlias
  /// Contains the ordered joins collection.
  joins
  /// Stores the where expression associated with this value.
  whereExpression
  /// Stores the group by associated with this value.
  groupBy
  /// Stores the having expression associated with this value.
  havingExpression
  /// Stores the set operations associated with this value.
  setOperations
  /// Contains the ordered order by collection.
  orderBy
  /// Tracks the limit numeric value.
  limit
  /// Tracks the offset numeric value.
  offset
  /// Stores the ctes associated with this value.
  ctes
end struct

/// Groups the begin statement state and preserves the field relationships documented below.
struct BeginStatement
  /// Stores the read only associated with this value.
  readOnly
  /// Indicates whether the isolation level condition is active.
  isolationLevel
end struct

/// Groups the commit statement state and preserves the field relationships documented below.
struct CommitStatement
  /// Stores the marker associated with this value.
  marker
end struct

/// Groups the rollback statement state and preserves the field relationships documented below.
struct RollbackStatement
  /// Stores the marker associated with this value.
  marker
end struct

/// Groups the savepoint statement state and preserves the field relationships documented below.
struct SavepointStatement
  /// Stores the name associated with this value.
  name
end struct

/// Groups the rollback to statement state and preserves the field relationships documented below.
struct RollbackToStatement
  /// Stores the name associated with this value.
  name
end struct

/// Groups the release savepoint statement state and preserves the field relationships documented below.
struct ReleaseSavepointStatement
  /// Stores the name associated with this value.
  name
end struct

/// Groups the create principal statement state and preserves the field relationships documented below.
struct CreatePrincipalStatement
  /// Stores the principal kind associated with this value.
  principalKind
  /// Stores the name associated with this value.
  name
  /// Stores the password associated with this value.
  password
end struct

/// Groups the alter user statement state and preserves the field relationships documented below.
struct AlterUserStatement
  /// Stores the name associated with this value.
  name
  /// Stores the action associated with this value.
  action
  /// Stores the password associated with this value.
  password
end struct

/// Groups the drop principal statement state and preserves the field relationships documented below.
struct DropPrincipalStatement
  /// Stores the principal kind associated with this value.
  principalKind
  /// Stores the name associated with this value.
  name
  /// Stores the if exists associated with this value.
  ifExists
end struct

/// Groups the grant role statement state and preserves the field relationships documented below.
struct GrantRoleStatement
  /// Stores the role name associated with this value.
  roleName
  /// Stores the member name associated with this value.
  memberName
  /// Stores the admin option associated with this value.
  adminOption
end struct

/// Groups the revoke role statement state and preserves the field relationships documented below.
struct RevokeRoleStatement
  /// Stores the role name associated with this value.
  roleName
  /// Stores the member name associated with this value.
  memberName
  /// Stores the cascade associated with this value.
  cascade
end struct

/// Groups the grant privilege statement state and preserves the field relationships documented below.
struct GrantPrivilegeStatement
  /// Contains the ordered privileges collection.
  privileges
  /// Stores the object type associated with this value.
  objectType
  /// Stores the object name associated with this value.
  objectName
  /// Stores the grantee name associated with this value.
  granteeName
  /// Stores the grant option associated with this value.
  grantOption
end struct

/// Groups the revoke privilege statement state and preserves the field relationships documented below.
struct RevokePrivilegeStatement
  /// Contains the ordered privileges collection.
  privileges
  /// Stores the object type associated with this value.
  objectType
  /// Stores the object name associated with this value.
  objectName
  /// Stores the grantee name associated with this value.
  granteeName
  /// Stores the cascade associated with this value.
  cascade
end struct

/// Groups the analyze statement state and preserves the field relationships documented below.
struct AnalyzeStatement
  /// Stores the table name associated with this value.
  tableName
end struct

/// Groups the explain statement state and preserves the field relationships documented below.
struct ExplainStatement
  /// Stores the analyze associated with this value.
  analyze
  /// Stores the statement associated with this value.
  statement
end struct

/// Groups the prepare statement state and preserves the field relationships documented below.
struct PrepareStatement
  /// Stores the name associated with this value.
  name
  /// Stores the statement associated with this value.
  statement
  /// Tracks the parameter count numeric value.
  parameterCount
end struct

/// Groups the execute prepared statement state and preserves the field relationships documented below.
struct ExecutePreparedStatement
  /// Stores the name associated with this value.
  name
  /// Contains the ordered arguments collection.
  arguments
end struct

/// Groups the deallocate statement state and preserves the field relationships documented below.
struct DeallocateStatement
  /// Stores the name associated with this value.
  name
end struct

/// Groups the vacuum statement state and preserves the field relationships documented below.
struct VacuumStatement
  /// Stores the table name associated with this value.
  tableName
end struct

/// Groups the reindex statement state and preserves the field relationships documented below.
struct ReindexStatement
  /// Stores the name associated with this value.
  name
end struct

/// Groups the show tables statement state and preserves the field relationships documented below.
struct ShowTablesStatement
  /// Stores the marker associated with this value.
  marker
end struct

/// Requests a snapshot of process-local server counters and resource limits.
struct ShowStatusStatement
  /// Keeps the statement non-empty without attaching mutable execution state.
  marker
end struct

/// Requests the active session registry for operational diagnosis.
struct ShowProcesslistStatement
  /// Keeps the statement non-empty without attaching mutable execution state.
  marker
end struct

/// Requests a cooperative, draining shutdown of the database listener.
struct ShutdownStatement
  /// Keeps the statement non-empty without attaching mutable execution state.
  marker
end struct

/// Groups the describe table statement state and preserves the field relationships documented below.
struct DescribeTableStatement
  /// Stores the table name associated with this value.
  tableName
end struct

/// Groups the show indexes statement state and preserves the field relationships documented below.
struct ShowIndexesStatement
  /// Stores the table name associated with this value.
  tableName
end struct

/// Implements identifier for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param name Name of the affected item.
/// @param quoted quoted value consumed by this operation.
function identifier(name, quoted)
  if typeof(name) != "string" or len(name) == 0 or typeof(quoted) != "bool" then return error(9001, "sql.ast.identifier: invalid identifier") end if
  return Identifier(name, quoted)
end function

/// Implements type name for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param name Name of the affected item.
/// @param length length value consumed by this operation.
/// @param precision precision value consumed by this operation.
/// @param scale scale value consumed by this operation.
function typeName(name, length, precision, scale)
  return TypeName(name, length, precision, scale)
end function

/// Implements null literal for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function nullLiteral()
  return LiteralExpression(EXPR_LITERAL, LITERAL_NULL, void)
end function

/// Implements boolean literal for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
function booleanLiteral(value)
  return LiteralExpression(EXPR_LITERAL, LITERAL_BOOLEAN, value)
end function

/// Implements integer literal for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
function integerLiteral(value)
  return LiteralExpression(EXPR_LITERAL, LITERAL_INTEGER, value)
end function

/// Implements float literal for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
function floatLiteral(value)
  return LiteralExpression(EXPR_LITERAL, LITERAL_FLOAT, value)
end function

/// Implements string literal for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
function stringLiteral(value)
  return LiteralExpression(EXPR_LITERAL, LITERAL_STRING, value)
end function

/// Implements current timestamp literal for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function currentTimestampLiteral()
  return LiteralExpression(EXPR_LITERAL, LITERAL_CURRENT_TIMESTAMP, void)
end function

/// Implements column expression for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param qualifier qualifier value consumed by this operation.
/// @param name Name of the affected item.
function columnExpression(qualifier, name)
  return ColumnExpression(EXPR_COLUMN, qualifier, name)
end function

/// Implements star expression for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param qualifier qualifier value consumed by this operation.
function starExpression(qualifier)
  return StarExpression(EXPR_STAR, qualifier)
end function

/// Implements unary expression for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operatorValue operator value consumed by this operation.
/// @param operand operand value consumed by this operation.
function unaryExpression(operatorValue, operand)
  return UnaryExpression(EXPR_UNARY, operatorValue, operand)
end function

/// Implements binary expression for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operatorValue operator value consumed by this operation.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function binaryExpression(operatorValue, left, right)
  return BinaryExpression(EXPR_BINARY, operatorValue, left, right)
end function

/// Returns whether the supplied value satisfies the null expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param operand operand value consumed by this operation.
/// @param negated negated value consumed by this operation.
function isNullExpression(operand, negated)
  return IsNullExpression(EXPR_IS_NULL, operand, negated)
end function

/// Implements function expression for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param name Name of the affected item.
/// @param arguments arguments value consumed by this operation.
/// @param distinct distinct value consumed by this operation.
function functionExpression(name, arguments, distinct)
  if typeof(name) != "string" or len(name) == 0 or typeof(arguments) != "array" or typeof(distinct) != "bool" then return error(9001, "sql.ast.functionExpression: invalid function") end if
  return FunctionExpression(EXPR_FUNCTION, name, arguments, distinct)
end function

/// Implements parameter expression for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param index Zero-based index of the affected item.
function parameterExpression(index)
  if typeof(index) != "int" or index < 0 then return error(9001, "sql.ast.parameterExpression: invalid index") end if
  return ParameterExpression(EXPR_PARAMETER, index)
end function

/// Implements case branch for this module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param condition condition value consumed by this operation.
/// @param result Result object populated or inspected by the operation.
function caseBranch(condition, result)
  if not isExpression(condition) or not isExpression(result) then return error(9001, "sql.ast.caseBranch: invalid branch") end if
  return CaseBranch(condition, result)
end function

/// Implements case expression for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param branches branches value consumed by this operation.
/// @param elseExpression elseExpression value consumed by this operation.
function caseExpression(branches, elseExpression)
  if typeof(branches) != "array" or len(branches) == 0 then return error(9001, "sql.ast.caseExpression: branches must be non-empty") end if
  for each branch in branches
    if branch is not CaseBranch then return error(9001, "sql.ast.caseExpression: invalid branch") end if
  end for
  if elseExpression is not void and not isExpression(elseExpression) then return error(9001, "sql.ast.caseExpression: invalid ELSE expression") end if
  return CaseExpression(EXPR_CASE, branches, elseExpression)
end function

/// Casts expression using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operand operand value consumed by this operation.
/// @param targetType targetType value consumed by this operation.
function castExpression(operand, targetType)
  if not isExpression(operand) or targetType is not TypeName then return error(9001, "sql.ast.castExpression: invalid CAST") end if
  return CastExpression(EXPR_CAST, operand, targetType)
end function

/// Implements in expression for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operand operand value consumed by this operation.
/// @param candidates candidates value consumed by this operation.
/// @param negated negated value consumed by this operation.
function inExpression(operand, candidates, negated)
  if not isExpression(operand) or typeof(candidates) != "array" or len(candidates) == 0 or typeof(negated) != "bool" then return error(9001, "sql.ast.inExpression: invalid IN predicate") end if
  for each candidate in candidates
    if not isExpression(candidate) then return error(9001, "sql.ast.inExpression: candidate is not expression") end if
  end for
  return InExpression(EXPR_IN, operand, candidates, negated)
end function

/// Implements between expression for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operand operand value consumed by this operation.
/// @param lower lower value consumed by this operation.
/// @param upper upper value consumed by this operation.
/// @param negated negated value consumed by this operation.
function betweenExpression(operand, lower, upper, negated)
  if not isExpression(operand) or not isExpression(lower) or not isExpression(upper) or typeof(negated) != "bool" then return error(9001, "sql.ast.betweenExpression: invalid BETWEEN predicate") end if
  return BetweenExpression(EXPR_BETWEEN, operand, lower, upper, negated)
end function

/// Implements truth test expression for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operand operand value consumed by this operation.
/// @param expected expected value consumed by this operation.
/// @param negated negated value consumed by this operation.
function truthTestExpression(operand, expected, negated)
  if not isExpression(operand) or typeof(expected) != "string" or typeof(negated) != "bool" then return error(9001, "sql.ast.truthTestExpression: invalid truth test") end if
  return TruthTestExpression(EXPR_TRUTH_TEST, operand, expected, negated)
end function

/// Implements typed literal expression for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
function typedLiteralExpression(value)
  if typeof(value) != "struct" then return error(9001, "sql.ast.typedLiteralExpression: value must be SqlValue") end if
  return TypedLiteralExpression(EXPR_TYPED_LITERAL, value)
end function

/// Implements subquery expression for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param query query value consumed by this operation.
function subqueryExpression(query)
  if query is not SelectStatement then return error(9001, "sql.ast.subqueryExpression: query must be SELECT") end if
  return SubqueryExpression(EXPR_SUBQUERY, query)
end function

/// Implements exists expression for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param query query value consumed by this operation.
function existsExpression(query)
  if query is not SelectStatement then return error(9001, "sql.ast.existsExpression: query must be SELECT") end if
  return ExistsExpression(EXPR_EXISTS, query)
end function

/// Implements in subquery expression for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operand operand value consumed by this operation.
/// @param query query value consumed by this operation.
/// @param negated negated value consumed by this operation.
function inSubqueryExpression(operand, query, negated)
  if not isExpression(operand) or query is not SelectStatement or typeof(negated) != "bool" then return error(9001, "sql.ast.inSubqueryExpression: invalid IN subquery") end if
  return InSubqueryExpression(EXPR_IN_SUBQUERY, operand, query, negated)
end function

/// Implements window expression for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param name Name of the affected item.
/// @param arguments arguments value consumed by this operation.
/// @param partitionBy partitionBy value consumed by this operation.
/// @param orderBy orderBy value consumed by this operation.
function windowExpression(name, arguments, partitionBy, orderBy)
  if typeof(name) != "string" or len(name) == 0 or typeof(arguments) != "array" or typeof(partitionBy) != "array" or typeof(orderBy) != "array" then return error(9001, "sql.ast.windowExpression: invalid window expression") end if
  return WindowExpression(EXPR_WINDOW, name, arguments, partitionBy, orderBy)
end function

/// Returns whether the supplied value satisfies the column expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isColumnExpression(value)
  return value is ColumnExpression
end function

/// Returns whether the supplied value satisfies the star expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isStarExpression(value)
  return value is StarExpression
end function

/// Returns whether the supplied value satisfies the unary expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isUnaryExpression(value)
  return value is UnaryExpression
end function

/// Returns whether the supplied value satisfies the binary expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isBinaryExpression(value)
  return value is BinaryExpression
end function

/// Returns whether the supplied value satisfies the is null expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isIsNullExpression(value)
  return value is IsNullExpression
end function

/// Returns whether the supplied value satisfies the function expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isFunctionExpression(value)
  return value is FunctionExpression
end function

/// Returns whether the supplied value satisfies the parameter expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isParameterExpression(value)
  return value is ParameterExpression
end function

/// Returns whether the supplied value satisfies the case expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isCaseExpression(value)
  return value is CaseExpression
end function

/// Returns whether the supplied value satisfies the cast expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isCastExpression(value)
  return value is CastExpression
end function

/// Returns whether the supplied value satisfies the in expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isInExpression(value)
  return value is InExpression
end function

/// Returns whether the supplied value satisfies the between expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isBetweenExpression(value)
  return value is BetweenExpression
end function

/// Returns whether the supplied value satisfies the truth test expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isTruthTestExpression(value)
  return value is TruthTestExpression
end function

/// Returns whether the supplied value satisfies the typed literal expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isTypedLiteralExpression(value)
  return value is TypedLiteralExpression
end function

/// Returns whether the supplied value satisfies the subquery expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isSubqueryExpression(value)
  return value is SubqueryExpression
end function

/// Returns whether the supplied value satisfies the exists expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isExistsExpression(value)
  return value is ExistsExpression
end function

/// Returns whether the supplied value satisfies the in subquery expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isInSubqueryExpression(value)
  return value is InSubqueryExpression
end function

/// Returns whether the supplied value satisfies the window expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isWindowExpression(value)
  return value is WindowExpression
end function

/// Returns whether the supplied value satisfies the literal expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isLiteralExpression(value)
  return value is LiteralExpression
end function

/// Returns whether the supplied value satisfies the type name condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isTypeName(value)
  return value is TypeName
end function

/// Returns whether the supplied value satisfies the expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isExpression(value)
  return value is LiteralExpression or value is ColumnExpression or value is StarExpression or value is UnaryExpression or value is BinaryExpression or value is IsNullExpression or value is FunctionExpression or value is ParameterExpression or value is CaseExpression or value is CastExpression or value is InExpression or value is BetweenExpression or value is TruthTestExpression or value is TypedLiteralExpression or value is SubqueryExpression or value is ExistsExpression or value is InSubqueryExpression or value is WindowExpression
end function

/// Returns whether the supplied value satisfies the create table statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isCreateTableStatement(value)
  return value is CreateTableStatement
end function

/// Returns whether the supplied value satisfies the create index statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isCreateIndexStatement(value)
  return value is CreateIndexStatement
end function

/// Returns whether the supplied value is a DROP INDEX statement.
/// @param value Value consumed or transformed by the operation.
function isDropIndexStatement(value)
  return value is DropIndexStatement
end function

/// Returns whether the supplied value satisfies the drop table statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isDropTableStatement(value)
  return value is DropTableStatement
end function

/// Returns whether the supplied statement creates a schema namespace.
/// @param value Value consumed or transformed by the operation.
function isCreateSchemaStatement(value)
  return value is CreateSchemaStatement
end function

/// Returns whether the supplied statement drops a schema namespace.
/// @param value Value consumed or transformed by the operation.
function isDropSchemaStatement(value)
  return value is DropSchemaStatement
end function

/// Returns whether the supplied value satisfies the create view statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isCreateViewStatement(value)
  return value is CreateViewStatement
end function

/// Returns whether the supplied value satisfies the drop view statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isDropViewStatement(value)
  return value is DropViewStatement
end function

/// Returns whether the supplied value satisfies the create sequence statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isCreateSequenceStatement(value)
  return value is CreateSequenceStatement
end function

/// Returns whether the supplied value satisfies the drop sequence statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isDropSequenceStatement(value)
  return value is DropSequenceStatement
end function

/// Returns whether the supplied value satisfies the create trigger statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isCreateTriggerStatement(value)
  return value is CreateTriggerStatement
end function

/// Returns whether the supplied value satisfies the drop trigger statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isDropTriggerStatement(value)
  return value is DropTriggerStatement
end function

/// Returns whether the supplied statement changes trigger activation.
/// @param value Value consumed or transformed by the operation.
function isAlterTriggerStatement(value)
  return value is AlterTriggerStatement
end function

/// Returns whether the supplied statement creates a stored procedure.
/// @param value Value consumed or transformed by the operation.
function isRoutineStatement(value)
  return value is RoutineStatement
end function

/// Returns whether this statement creates a durable stored procedure.
function isCreateProcedureStatement(value)
  return value is CreateProcedureStatement
end function

/// Returns whether the supplied statement drops a stored procedure.
/// @param value Value consumed or transformed by the operation.
function isDropProcedureStatement(value)
  return value is DropProcedureStatement
end function

/// Returns whether the supplied statement invokes a stored procedure.
/// @param value Value consumed or transformed by the operation.
function isCallStatement(value)
  return value is CallStatement
end function

/// Returns whether the supplied value satisfies the alter table statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isAlterTableStatement(value)
  return value is AlterTableStatement
end function

/// Returns whether the supplied value satisfies the insert statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isInsertStatement(value)
  return value is InsertStatement
end function

/// Returns whether the supplied value satisfies the update statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isUpdateStatement(value)
  return value is UpdateStatement
end function

/// Returns whether the supplied value satisfies the delete statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isDeleteStatement(value)
  return value is DeleteStatement
end function

/// Returns whether the supplied statement is a MERGE operation.
/// @param value Value consumed or transformed by the operation.
function isMergeStatement(value)
  return value is MergeStatement
end function

/// Returns whether the supplied value satisfies the truncate statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isTruncateStatement(value)
  return value is TruncateStatement
end function

/// Returns whether the supplied value satisfies the select statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isSelectStatement(value)
  return value is SelectStatement
end function

/// Returns whether the supplied value satisfies the begin statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isBeginStatement(value)
  return value is BeginStatement
end function

/// Returns whether the supplied value satisfies the commit statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isCommitStatement(value)
  return value is CommitStatement
end function

/// Returns whether the supplied value satisfies the rollback statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isRollbackStatement(value)
  return value is RollbackStatement
end function

/// Returns whether the supplied value satisfies the savepoint statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isSavepointStatement(value)
  return value is SavepointStatement
end function

/// Returns whether the supplied value satisfies the rollback to statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isRollbackToStatement(value)
  return value is RollbackToStatement
end function

/// Returns whether the supplied value satisfies the release savepoint statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isReleaseSavepointStatement(value)
  return value is ReleaseSavepointStatement
end function

/// Returns whether the supplied value satisfies the create principal statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isCreatePrincipalStatement(value)
  return value is CreatePrincipalStatement
end function

/// Returns whether the supplied value satisfies the alter user statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isAlterUserStatement(value)
  return value is AlterUserStatement
end function

/// Returns whether the supplied value satisfies the drop principal statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isDropPrincipalStatement(value)
  return value is DropPrincipalStatement
end function

/// Returns whether the supplied value satisfies the grant role statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isGrantRoleStatement(value)
  return value is GrantRoleStatement
end function

/// Returns whether the supplied value satisfies the revoke role statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isRevokeRoleStatement(value)
  return value is RevokeRoleStatement
end function

/// Returns whether the supplied value satisfies the grant privilege statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isGrantPrivilegeStatement(value)
  return value is GrantPrivilegeStatement
end function

/// Returns whether the supplied value satisfies the revoke privilege statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isRevokePrivilegeStatement(value)
  return value is RevokePrivilegeStatement
end function

/// Returns whether the supplied value satisfies the dcl statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isDclStatement(value)
  return value is CreatePrincipalStatement or value is AlterUserStatement or value is DropPrincipalStatement or value is GrantRoleStatement or value is RevokeRoleStatement or value is GrantPrivilegeStatement or value is RevokePrivilegeStatement
end function

/// Returns whether the supplied value satisfies the analyze statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isAnalyzeStatement(value)
  return value is AnalyzeStatement
end function

/// Returns whether the supplied value satisfies the explain statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isExplainStatement(value)
  return value is ExplainStatement
end function

/// Returns whether the supplied value satisfies the prepare statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isPrepareStatement(value)
  return value is PrepareStatement
end function

/// Returns whether the supplied value satisfies the execute prepared statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isExecutePreparedStatement(value)
  return value is ExecutePreparedStatement
end function

/// Returns whether the supplied value satisfies the deallocate statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isDeallocateStatement(value)
  return value is DeallocateStatement
end function

/// Returns whether the supplied value satisfies the vacuum statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isVacuumStatement(value)
  return value is VacuumStatement
end function

/// Returns whether the supplied value satisfies the reindex statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isReindexStatement(value)
  return value is ReindexStatement
end function

/// Returns whether the supplied value satisfies the show tables statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isShowTablesStatement(value)
  return value is ShowTablesStatement
end function

/// Returns whether the value is a SHOW STATUS statement.
/// @param value Value consumed or transformed by the operation.
function isShowStatusStatement(value)
  return value is ShowStatusStatement
end function

/// Returns whether the value is a SHOW PROCESSLIST statement.
/// @param value Value consumed or transformed by the operation.
function isShowProcesslistStatement(value)
  return value is ShowProcesslistStatement
end function

/// Returns whether the value is a cooperative SHUTDOWN statement.
/// @param value Value consumed or transformed by the operation.
function isShutdownStatement(value)
  return value is ShutdownStatement
end function

/// Returns whether the supplied value satisfies the describe table statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isDescribeTableStatement(value)
  return value is DescribeTableStatement
end function

/// Returns whether the supplied value satisfies the show indexes statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isShowIndexesStatement(value)
  return value is ShowIndexesStatement
end function

/// Returns whether the supplied value satisfies the metadata statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isMetadataStatement(value)
  return value is ShowTablesStatement or value is ShowStatusStatement or value is ShowProcesslistStatement or value is DescribeTableStatement or value is ShowIndexesStatement
end function

/// Returns whether the supplied value satisfies the statement condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isStatement(value)
  return value is RoutineStatement or value is CreateTableStatement or value is CreateIndexStatement or value is DropIndexStatement or value is DropTableStatement or value is CreateSchemaStatement or value is DropSchemaStatement or value is CreateViewStatement or value is DropViewStatement or value is CreateSequenceStatement or value is DropSequenceStatement or value is CreateTriggerStatement or value is DropTriggerStatement or value is AlterTriggerStatement or value is CreateProcedureStatement or value is DropProcedureStatement or value is CallStatement or value is AlterTableStatement or value is InsertStatement or value is UpdateStatement or value is DeleteStatement or value is MergeStatement or value is TruncateStatement or value is SelectStatement or value is BeginStatement or value is CommitStatement or value is RollbackStatement or value is SavepointStatement or value is RollbackToStatement or value is ReleaseSavepointStatement or value is AnalyzeStatement or value is ExplainStatement or value is PrepareStatement or value is ExecutePreparedStatement or value is DeallocateStatement or value is VacuumStatement or value is ReindexStatement or value is ShutdownStatement or isMetadataStatement(value) or isDclStatement(value)
end function

/// Implements expression kind for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
function expressionKind(value)
  if not isExpression(value) then return 0 end if
  return value.kind
end function

/// Implements quote string for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
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

/// Quotes identifiers only when needed to preserve their spelling or grammar.
function formatIdentifier(name)
  raw = bytes(name)
  if len(raw) > 0 and raw[0] == 64 then return name end if
  safe = len(raw) > 0 and name == dialect.asciiLower(name)
  if dialect.isKeyword(name) and not dialect.isNonReservedIdentifierKeyword(name) then safe = false end if
  for each item in raw
    if not ((item >= 97 and item <= 122) or (item >= 48 and item <= 57) or item == 95 or item == 36) then safe = false end if
  end for
  if len(raw) > 0 and raw[0] >= 48 and raw[0] <= 57 then safe = false end if
  if safe then return name end if
  output = "\""
  for each item in raw
    if item == 34 then output = output + "\"\"" else output = output + decode(bytes([item])) end if
  end for
  return output + "\""
end function

/// Serializes the canonical dotted representation of a qualified object/variable.
function formatObjectName(name)
  raw = bytes(name)
  if len(raw) == 0 then return formatIdentifier(name) end if
  if len(raw) > 0 and raw[0] == 64 then return name end if
  for index = 0 to len(raw) - 1
    if raw[index] == 46 then return formatIdentifier(decode(slice(raw, 0, index))) + "." + formatIdentifier(decode(slice(raw, index + 1, len(raw) - index - 1))) end if
  end for
  return formatIdentifier(name)
end function

/// Formats comma-separated identifiers, preserving quoted variable/object names.
function formatIdentifierList(names)
  output = ""
  first = true
  for each name in names
    if not first then output = output + ", " end if
    output = output + formatObjectName(name)
    first = false
  end for
  return output
end function

/// Formats type name using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
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

/// Formats function using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param expression expression value consumed by this operation.
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

/// Reports whether an expression tree embeds an executor-created typed literal.
/// These values intentionally format opaquely and therefore cannot participate
/// in a value-sensitive physical-plan cache key.
/// @param expression expression value consumed by this operation.
function containsTypedLiteral(expression)
  if expression is TypedLiteralExpression then return true end if
  if expression is LiteralExpression or expression is ColumnExpression or expression is StarExpression or expression is ParameterExpression then return false end if
  if expression is UnaryExpression or expression is IsNullExpression or expression is CastExpression then return containsTypedLiteral(expression.operand) end if
  if expression is BinaryExpression then return containsTypedLiteral(expression.left) or containsTypedLiteral(expression.right) end if
  if expression is CaseExpression then
    for each branch in expression.branches
      if containsTypedLiteral(branch.condition) or containsTypedLiteral(branch.result) then return true end if
    end for
    return expression.elseExpression is not void and containsTypedLiteral(expression.elseExpression)
  end if
  if expression is InExpression then
    if containsTypedLiteral(expression.operand) then return true end if
    for each candidate in expression.values
      if containsTypedLiteral(candidate) then return true end if
    end for
    return false
  end if
  if expression is BetweenExpression then return containsTypedLiteral(expression.operand) or containsTypedLiteral(expression.lower) or containsTypedLiteral(expression.upper) end if
  if expression is TruthTestExpression then return containsTypedLiteral(expression.operand) end if
  if expression is FunctionExpression then
    for each argument in expression.arguments
      if containsTypedLiteral(argument) then return true end if
    end for
    return false
  end if
  if expression is SubqueryExpression or expression is ExistsExpression then return selectContainsTypedLiteral(expression.query) end if
  if expression is InSubqueryExpression then return containsTypedLiteral(expression.operand) or selectContainsTypedLiteral(expression.query) end if
  if expression is WindowExpression then
    for each argument in expression.arguments
      if containsTypedLiteral(argument) then return true end if
    end for
    for each partition in expression.partitionBy
      if containsTypedLiteral(partition) then return true end if
    end for
    for each order in expression.orderBy
      if containsTypedLiteral(order.expression) then return true end if
    end for
    return false
  end if
  return false
end function

/// Reports whether any clause of a SELECT embeds a typed literal.
/// @param statement statement value consumed by this operation.
function selectContainsTypedLiteral(statement)
  if statement is not SelectStatement then return false end if
  for each item in statement.items
    if containsTypedLiteral(item.expression) then return true end if
  end for
  for each join in statement.joins
    if join.condition is not void and containsTypedLiteral(join.condition) then return true end if
  end for
  if statement.whereExpression is not void and containsTypedLiteral(statement.whereExpression) then return true end if
  for each expression in statement.groupBy
    if containsTypedLiteral(expression) then return true end if
  end for
  if statement.havingExpression is not void and containsTypedLiteral(statement.havingExpression) then return true end if
  for each operation in statement.setOperations
    if selectContainsTypedLiteral(operation.query) then return true end if
  end for
  for each order in statement.orderBy
    if containsTypedLiteral(order.expression) then return true end if
  end for
  for each cte in statement.ctes
    if selectContainsTypedLiteral(cte.query) then return true end if
  end for
  return false
end function

/// Formats expression using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param expression expression value consumed by this operation.
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
    if expression.qualifier == "old" or expression.qualifier == "new" then return expression.qualifier + "." + formatIdentifier(expression.name) end if
    return formatIdentifier(expression.qualifier) + "." + formatIdentifier(expression.name)
  end if
  if expression is StarExpression then
    if expression.qualifier is void or len(expression.qualifier) == 0 then return "*" end if
    return formatIdentifier(expression.qualifier) + ".*"
  end if
  if expression is FunctionExpression then return formatFunction(expression) end if
  if expression is ParameterExpression then return "?" end if
  if expression is UnaryExpression then return expression.operatorValue + " (" + formatExpression(expression.operand) + ")" end if
  if expression is BinaryExpression then return "(" + formatExpression(expression.left) + " " + expression.operatorValue + " " + formatExpression(expression.right) + ")" end if
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

/// Formats select item using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param item item value consumed by this operation.
function formatSelectItem(item)
  output = formatExpression(item.expression)
  if item.alias is not void then output = output + " AS " + formatIdentifier(item.alias) end if
  return output
end function

/// Formats order item using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param item item value consumed by this operation.
function formatOrderItem(item)
  output = formatExpression(item.expression)
  if item.descending then output = output + " DESC" else output = output + " ASC" end if
  if item.nullsSpecified then
    if item.nullsFirst then output = output + " NULLS FIRST" else output = output + " NULLS LAST" end if
  end if
  return output
end function

/// Formats select using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param statement statement value consumed by this operation.
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
      output = output + formatObjectName(cte.name)
      if len(cte.columnNames) > 0 then
        output = output + " ("
        for columnIndex = 0 to len(cte.columnNames) - 1
          if columnIndex > 0 then output = output + ", " end if
          output = output + formatObjectName(cte.columnNames[columnIndex])
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
    output = output + " FROM " + formatObjectName(statement.tableName)
    if statement.tableAlias is not void then output = output + " AS " + formatObjectName(statement.tableAlias) end if
    for each join in statement.joins
      if join.joinType == JOIN_LEFT then output = output + " LEFT JOIN " else if join.joinType == JOIN_RIGHT then output = output + " RIGHT JOIN " else if join.joinType == JOIN_FULL then output = output + " FULL JOIN " else if join.joinType == JOIN_CROSS then output = output + " CROSS JOIN " else output = output + " INNER JOIN " end if
      output = output + formatObjectName(join.tableName)
      if join.tableAlias is not void then output = output + " AS " + formatObjectName(join.tableAlias) end if
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
    if operation.operatorValue == SET_INTERSECT then output = output + " INTERSECT" else if operation.operatorValue == SET_EXCEPT then output = output + " EXCEPT" else output = output + " UNION" end if
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
  if typeof(statement.limit) != "int" then output = output + " LIMIT " + formatExpression(statement.limit) else if statement.limit >= 0 then output = output + " LIMIT " + statement.limit end if
  if typeof(statement.offset) != "int" then output = output + " OFFSET " + formatExpression(statement.offset) else if statement.offset > 0 then output = output + " OFFSET " + statement.offset end if
  return output
end function

/// Joins strings in source order without depending on a host string library.
function joinSqlNames(names)
  output = ""
  if len(names) > 0 then
    for index = 0 to len(names) - 1
      if index > 0 then output = output + ", " end if
      output = output + names[index]
    end for
  end if
  return output
end function

/// Formats ordered expression operands used by CALL, EXECUTE and VALUES.
function formatExpressionList(items)
  output = ""
  if len(items) > 0 then
    for index = 0 to len(items) - 1
      if index > 0 then output = output + ", " end if
      output = output + formatExpression(items[index])
    end for
  end if
  return output
end function

/// Formats a nested statement sequence with its required inner semicolons.
function formatRoutineBody(statements)
  output = ""
  for each statement in statements
    output = output + formatStatement(statement) + "; "
  end for
  return output
end function

/// Reconstructs SQLSTATE, numeric, named, or class condition syntax.
function formatRoutineCondition(condition)
  if condition[0] == "SQLSTATE" then return "SQLSTATE " + quoteString(condition[1]) end if
  if condition[0] == "NAME" then return formatIdentifier(condition[1]) end if
  return condition[1]
end function

/// Serializes persisted routine characteristics, excluding the CREATE prefix definer.
function formatRoutineCharacteristics(characteristics)
  output = ""
  for each item in characteristics
    if item[0] == "COMMENT" then output = output + " COMMENT " + quoteString(item[1])
    else if item[0] == "DETERMINISTIC" then
      if item[1] == "YES" then output = output + " DETERMINISTIC" else output = output + " NOT DETERMINISTIC" end if
    else if item[0] == "SQL DATA ACCESS" then output = output + " " + item[1]
    else if item[0] == "SQL SECURITY" then output = output + " SQL SECURITY " + item[1]
    else if item[0] == "LANGUAGE" then output = output + " LANGUAGE " + item[1]
    end if
  end for
  return output
end function

/// Serializes procedural nodes into SQL that recreates identical control flow.
function formatRoutineStatement(statement)
  kind = statement.kind
  label = ""
  if statement.name != "" then label = formatIdentifier(statement.name) + ": " end if
  if kind == "BLOCK" then return label + "BEGIN " + formatRoutineBody(statement.body) + "END" end if
  if kind == "DECLARE" then
    output = "DECLARE " + formatIdentifierList(statement.names) + " " + formatTypeName(statement.options[0])
    if len(statement.expressions) > 0 then output = output + " DEFAULT " + formatExpression(statement.expressions[0]) end if
    return output
  end if
  if kind == "CONDITION" then return "DECLARE " + formatIdentifier(statement.name) + " CONDITION FOR " + formatRoutineCondition(statement.options) end if
  if kind == "CURSOR" then return "DECLARE " + formatIdentifier(statement.name) + " CURSOR FOR " + formatStatement(statement.body[0]) end if
  if kind == "HANDLER" then
    output = "DECLARE " + statement.name + " HANDLER FOR "
    if len(statement.options) > 0 then
      for index = 0 to len(statement.options) - 1
        if index > 0 then output = output + ", " end if
        output = output + formatRoutineCondition(statement.options[index])
      end for
    end if
    return output + " " + formatStatement(statement.body[0])
  end if
  if kind == "SET" then
    output = "SET "
    if len(statement.names) > 0 then
      for index = 0 to len(statement.names) - 1
        if index > 0 then output = output + ", " end if
        output = output + formatObjectName(statement.names[index]) + " = " + formatExpression(statement.expressions[index])
      end for
    end if
    return output
  end if
  if kind == "IF" then
    output = ""
    if len(statement.expressions) > 0 then
      for index = 0 to len(statement.expressions) - 1
        if index == 0 then output = output + "IF " else output = output + "ELSEIF " end if
        output = output + formatExpression(statement.expressions[index]) + " THEN " + formatRoutineBody(statement.body[index].body)
      end for
    end if
    if len(statement.alternate) > 0 then output = output + "ELSE " + formatRoutineBody(statement.alternate) end if
    return output + "END IF"
  end if
  if kind == "CASE" then
    output = "CASE "
    if statement.options[1] is not void then output = output + formatExpression(statement.options[1]) + " " end if
    if len(statement.expressions) > 0 then
      for index = 0 to len(statement.expressions) - 1
        output = output + "WHEN " + formatExpression(statement.expressions[index]) + " THEN " + formatRoutineBody(statement.body[index].body)
      end for
    end if
    if statement.options[0] then output = output + "ELSE " + formatRoutineBody(statement.alternate) end if
    return output + "END CASE"
  end if
  if kind == "WHILE" then return label + "WHILE " + formatExpression(statement.expressions[0]) + " DO " + formatRoutineBody(statement.body) + "END WHILE" end if
  if kind == "REPEAT" then return label + "REPEAT " + formatRoutineBody(statement.body) + "UNTIL " + formatExpression(statement.expressions[0]) + " END REPEAT" end if
  if kind == "LOOP" then return label + "LOOP " + formatRoutineBody(statement.body) + "END LOOP" end if
  if kind == "LEAVE" or kind == "ITERATE" or kind == "OPEN" or kind == "CLOSE" then return kind + " " + formatIdentifier(statement.name) end if
  if kind == "FETCH" then return "FETCH " + formatIdentifier(statement.name) + " INTO " + formatIdentifierList(statement.names) end if
  if kind == "SELECT_INTO" then return formatStatement(statement.body[0]) + " INTO " + formatIdentifierList(statement.names) end if
  if kind == "SIGNAL" or kind == "RESIGNAL" then
    output = kind
    if len(statement.options) > 0 then output = output + " " + formatRoutineCondition(statement.options) end if
    if len(statement.names) > 0 then output = output + " SET " end if
    if len(statement.names) > 0 then
      for index = 0 to len(statement.names) - 1
        if index > 0 then output = output + ", " end if
        output = output + statement.names[index] + " = " + formatExpression(statement.expressions[index])
      end for
    end if
    return output
  end if
  if kind == "GET_DIAGNOSTICS" then
    output = "GET " + statement.name + " DIAGNOSTICS "
    if len(statement.expressions) > 0 then output = output + "CONDITION " + formatExpression(statement.expressions[0]) + " " end if
    if len(statement.names) > 0 then
      for index = 0 to len(statement.names) - 1
        if index > 0 then output = output + ", " end if
        output = output + formatObjectName(statement.names[index]) + " = " + statement.options[index]
      end for
    end if
    return output
  end if
  if kind == "PREPARE_DYNAMIC" then return "PREPARE " + formatIdentifier(statement.name) + " FROM " + formatExpression(statement.expressions[0]) end if
  if kind == "ALTER_PROCEDURE" then return "ALTER PROCEDURE " + formatObjectName(statement.name) + formatRoutineCharacteristics(statement.options) end if
  if kind == "SHOW_CREATE_PROCEDURE" then return "SHOW CREATE PROCEDURE " + formatObjectName(statement.name) end if
  if kind == "SHOW_PROCEDURE_STATUS" then
    output = "SHOW PROCEDURE STATUS"
    if len(statement.expressions) > 0 then output = output + " " + statement.name + " " + formatExpression(statement.expressions[0]) end if
    return output
  end if
  return error(9001, "sql.ast.formatRoutineStatement: unsupported procedural kind " + kind)
end function

/// Formats UPDATE assignments without dropping any target expression.
function formatAssignments(assignments)
  output = ""
  if len(assignments) > 0 then
    for index = 0 to len(assignments) - 1
      if index > 0 then output = output + ", " end if
      output = output + formatIdentifier(assignments[index].column) + " = " + formatExpression(assignments[index].expression)
    end for
  end if
  return output
end function

/// Preserves a DML RETURNING list in durable procedure definitions.
function formatReturning(items)
  if len(items) == 0 then return "" end if
  output = " RETURNING "
  if len(items) > 0 then
    for index = 0 to len(items) - 1
      if index > 0 then output = output + ", " end if
      output = output + formatSelectItem(items[index])
    end for
  end if
  return output
end function

/// Serializes every supported table-constraint variant for routine DDL bodies.
function formatTableConstraint(constraint)
  output = ""
  if constraint.name is not void then output = "CONSTRAINT " + formatIdentifier(constraint.name) + " " end if
  if constraint.kind == CONSTRAINT_PRIMARY_KEY then return output + "PRIMARY KEY (" + formatIdentifierList(constraint.columns) + ")" end if
  if constraint.kind == CONSTRAINT_UNIQUE then return output + "UNIQUE (" + formatIdentifierList(constraint.columns) + ")" end if
  if constraint.kind == CONSTRAINT_CHECK then return output + "CHECK (" + formatExpression(constraint.expression) + ")" end if
  return output + "FOREIGN KEY (" + formatIdentifierList(constraint.columns) + ") REFERENCES " + formatObjectName(constraint.referencesTable) + " (" + formatIdentifierList(constraint.referencesColumns) + ") ON DELETE " + constraint.onDelete + " ON UPDATE " + constraint.onUpdate
end function

/// Retains type, constraints and generated/default expressions in column DDL.
function formatColumnDefinition(column)
  output = formatIdentifier(column.name) + " " + formatTypeName(column.typeName)
  if column.identity then output = output + " GENERATED ALWAYS AS IDENTITY" end if
  if column.generatedExpression is not void then
    output = output + " GENERATED ALWAYS AS (" + formatExpression(column.generatedExpression) + ")"
    if column.generatedStored then output = output + " STORED" end if
  end if
  if column.nullableSpecified then
    if column.nullable then output = output + " NULL" else output = output + " NOT NULL" end if
  end if
  if column.primaryKey then output = output + " PRIMARY KEY" end if
  if column.unique then output = output + " UNIQUE" end if
  if column.defaultExpression is not void then output = output + " DEFAULT " + formatExpression(column.defaultExpression) end if
  if column.checkExpression is not void then output = output + " CHECK (" + formatExpression(column.checkExpression) + ")" end if
  if column.referencesTable is not void then
    output = output + " REFERENCES " + formatObjectName(column.referencesTable) + " (" + formatIdentifierList(column.referencesColumns) + ") ON DELETE " + column.onDelete + " ON UPDATE " + column.onUpdate
  end if
  return output
end function

/// Serializes database, table and procedure privilege destinations.
function formatPrivilegeTarget(statement)
  if statement.objectType == DCL_OBJECT_DATABASE then return "DATABASE" end if
  if statement.objectType == DCL_OBJECT_PROCEDURE then return "PROCEDURE " + statement.objectName end if
  return "TABLE " + formatObjectName(statement.objectName)
end function

/// Formats complete DCL AST nodes used in persisted procedure bodies.
function formatDclStatement(statement)
  if statement is CreatePrincipalStatement then
    if statement.principalKind == PRINCIPAL_ROLE then return "CREATE ROLE " + statement.name end if
    return "CREATE USER " + statement.name + " WITH PASSWORD " + quoteString(statement.password)
  end if
  if statement is AlterUserStatement then
    output = "ALTER USER " + statement.name
    if statement.action == ALTER_USER_ENABLE then return output + " ENABLE" end if
    if statement.action == ALTER_USER_DISABLE then return output + " DISABLE" end if
    return output + " WITH PASSWORD " + quoteString(statement.password)
  end if
  if statement is DropPrincipalStatement then
    output = "DROP USER "
    if statement.principalKind == PRINCIPAL_ROLE then output = "DROP ROLE " end if
    if statement.ifExists then output = output + "IF EXISTS " end if
    return output + statement.name
  end if
  if statement is GrantRoleStatement then
    output = "GRANT " + statement.roleName + " TO " + statement.memberName
    if statement.adminOption then output = output + " WITH ADMIN OPTION" end if
    return output
  end if
  if statement is RevokeRoleStatement then
    output = "REVOKE " + statement.roleName + " FROM " + statement.memberName
    if statement.cascade then output = output + " CASCADE" end if
    return output
  end if
  if statement is GrantPrivilegeStatement then
    output = "GRANT " + joinSqlNames(statement.privileges) + " ON " + formatPrivilegeTarget(statement) + " TO " + statement.granteeName
    if statement.grantOption then output = output + " WITH GRANT OPTION" end if
    return output
  end if
  if statement is RevokePrivilegeStatement then
    output = "REVOKE " + joinSqlNames(statement.privileges) + " ON " + formatPrivilegeTarget(statement) + " FROM " + statement.granteeName
    if statement.cascade then output = output + " CASCADE" end if
    return output
  end if
  return error(9001, "sql.ast.formatDclStatement: unsupported DCL statement")
end function

/// Formats the table ALTER forms accepted by the parser without losing operands.
function formatAlterTable(statement)
  output = "ALTER TABLE " + formatObjectName(statement.tableName) + " "
  action = statement.action
  if action == ALTER_TABLE_ADD_COLUMN then return output + "ADD COLUMN " + formatColumnDefinition(statement.columnDefinition) end if
  if action == ALTER_TABLE_RENAME_COLUMN then return output + "RENAME COLUMN " + formatObjectName(statement.oldName) + " TO " + formatObjectName(statement.newName) end if
  if action == ALTER_TABLE_RENAME_TABLE then return output + "RENAME TO " + formatObjectName(statement.newName) end if
  if action == ALTER_TABLE_ADD_CONSTRAINT then return output + "ADD " + formatTableConstraint(statement.constraint) end if
  if action == ALTER_TABLE_DROP_CONSTRAINT then return output + "DROP CONSTRAINT " + formatObjectName(statement.constraintName) end if
  if action == ALTER_TABLE_DROP_COLUMN then return output + "DROP COLUMN " + formatObjectName(statement.oldName) end if
  output = output + "ALTER COLUMN " + formatObjectName(statement.oldName)
  if action == ALTER_TABLE_SET_DEFAULT then return output + " SET DEFAULT " + formatExpression(statement.columnDefinition) end if
  if action == ALTER_TABLE_DROP_DEFAULT then return output + " DROP DEFAULT" end if
  if action == ALTER_TABLE_SET_NOT_NULL then return output + " SET NOT NULL" end if
  if action == ALTER_TABLE_DROP_NOT_NULL then return output + " DROP NOT NULL" end if
  return error(9001, "sql.ast.formatAlterTable: unsupported ALTER action")
end function

/// Formats statement using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param statement statement value consumed by this operation.
function formatStatement(statement)
  if statement is RoutineStatement then return formatRoutineStatement(statement) end if
  if statement is CreateProcedureStatement then
    output = "CREATE "
    if statement.replace then output = output + "OR REPLACE " end if
    for each item in statement.characteristics
      if item[0] == "DEFINER" then
        if item[1] == "CURRENT_USER" then output = output + "DEFINER = CURRENT_USER " else output = output + "DEFINER = " + quoteString(item[1]) + " " end if
      end if
    end for
    output = output + "PROCEDURE "
    if statement.ifNotExists then output = output + "IF NOT EXISTS " end if
    output = output + formatObjectName(statement.name) + "("
    if len(statement.parameters) > 0 then
      for index = 0 to len(statement.parameters) - 1
        if index > 0 then output = output + ", " end if
        parameter = statement.parameters[index]
        output = output + parameter.mode + " " + formatObjectName(parameter.name) + " " + formatTypeName(parameter.typeName)
      end for
    end if
    return output + ")" + formatRoutineCharacteristics(statement.characteristics) + " " + formatStatement(statement.body)
  end if
  if statement is DropProcedureStatement then
    output = "DROP PROCEDURE "
    if statement.ifExists then output = output + "IF EXISTS " end if
    return output + formatObjectName(statement.name)
  end if
  if statement is CallStatement then return "CALL " + formatObjectName(statement.name) + "(" + formatExpressionList(statement.arguments) + ")" end if
  if statement is BeginStatement then
    output = "START TRANSACTION ISOLATION LEVEL " + statement.isolationLevel
    if statement.readOnly then return output + " READ ONLY" else return output + " READ WRITE" end if
  end if
  if statement is CommitStatement then return "COMMIT" end if
  if statement is RollbackStatement then return "ROLLBACK" end if
  if statement is SavepointStatement then return "SAVEPOINT " + formatObjectName(statement.name) end if
  if statement is RollbackToStatement then return "ROLLBACK TO SAVEPOINT " + formatObjectName(statement.name) end if
  if statement is ReleaseSavepointStatement then return "RELEASE SAVEPOINT " + formatObjectName(statement.name) end if
  if statement is PrepareStatement then return "PREPARE " + formatObjectName(statement.name) + " AS " + formatStatement(statement.statement) end if
  if statement is ExecutePreparedStatement then
    output = "EXECUTE " + formatObjectName(statement.name)
    if len(statement.arguments) > 0 then output = output + " USING " + formatExpressionList(statement.arguments) end if
    return output
  end if
  if statement is DeallocateStatement then return "DEALLOCATE PREPARE " + formatObjectName(statement.name) end if
  if isDclStatement(statement) then return formatDclStatement(statement) end if
  if statement is CreateTableStatement then
    output = "CREATE TABLE "
    if statement.ifNotExists then output = output + "IF NOT EXISTS " end if
    output = output + formatObjectName(statement.name) + " ("
    if len(statement.columns) > 0 then
      for index = 0 to len(statement.columns) - 1
        if index > 0 then output = output + ", " end if
        output = output + formatColumnDefinition(statement.columns[index])
      end for
    end if
    for each constraint in statement.constraints
      output = output + ", " + formatTableConstraint(constraint)
    end for
    return output + ")"
  end if
  if statement is CreateIndexStatement then
    output = "CREATE "
    if statement.unique then output = output + "UNIQUE " end if
    output = output + "INDEX "
    if statement.ifNotExists then output = output + "IF NOT EXISTS " end if
    output = output + formatObjectName(statement.name) + " ON " + formatObjectName(statement.tableName) + " (" + formatExpressionList(statement.columns) + ")"
    if len(statement.includeColumns) > 0 then output = output + " INCLUDE (" + formatIdentifierList(statement.includeColumns) + ")" end if
    if statement.whereExpression is not void then output = output + " WHERE " + formatExpression(statement.whereExpression) end if
    return output
  end if
  if statement is AlterTableStatement then return formatAlterTable(statement) end if
  if statement is DropTableStatement then
    output = "DROP TABLE "
    if statement.ifExists then output = output + "IF EXISTS " end if
    return output + formatObjectName(statement.name)
  end if
  if statement is CreateViewStatement then
    output = "CREATE "
    if statement.replace then output = output + "OR REPLACE " end if
    return output + "VIEW " + formatObjectName(statement.name) + " AS " + formatSelect(statement.query)
  end if
  if statement is DropViewStatement then
    output = "DROP VIEW "
    if statement.ifExists then output = output + "IF EXISTS " end if
    return output + formatObjectName(statement.name)
  end if
  if statement is CreateSequenceStatement then
    output = "CREATE SEQUENCE "
    if statement.ifNotExists then output = output + "IF NOT EXISTS " end if
    output = output + formatObjectName(statement.name) + " START WITH " + statement.startValue + " INCREMENT BY " + statement.incrementValue + " MINVALUE " + statement.minimumValue + " MAXVALUE " + statement.maximumValue
    if statement.cycle then return output + " CYCLE" else return output + " NO CYCLE" end if
  end if
  if statement is DropSequenceStatement then
    output = "DROP SEQUENCE "
    if statement.ifExists then output = output + "IF EXISTS " end if
    return output + formatObjectName(statement.name)
  end if
  if statement is CreateTriggerStatement then
    output = "CREATE TRIGGER "
    if statement.ifNotExists then output = output + "IF NOT EXISTS " end if
    output = output + formatObjectName(statement.name) + " " + statement.timing + " " + statement.eventType
    if statement.targetColumn != "" then output = output + " OF " + statement.targetColumn end if
    return output + " ON " + formatObjectName(statement.tableName) + " FOR EACH ROW " + formatStatement(statement.body)
  end if
  if statement is DropTriggerStatement then
    output = "DROP TRIGGER "
    if statement.ifExists then output = output + "IF EXISTS " end if
    return output + formatObjectName(statement.name)
  end if
  if statement is AlterTriggerStatement then
    output = "ALTER TRIGGER " + formatObjectName(statement.name)
    if statement.enabled then return output + " ENABLE" else return output + " DISABLE" end if
  end if
  if statement is TruncateStatement then
    output = "TRUNCATE TABLE " + formatObjectName(statement.tableName)
    if statement.restartIdentity then return output + " RESTART IDENTITY" else return output + " CONTINUE IDENTITY" end if
  end if
  if statement is AnalyzeStatement then
    if statement.tableName is void then return "ANALYZE" else return "ANALYZE " + formatObjectName(statement.tableName) end if
  end if
  if statement is VacuumStatement then
    if statement.tableName is void then return "VACUUM" else return "VACUUM " + formatObjectName(statement.tableName) end if
  end if
  if statement is ReindexStatement then
    if statement.name is void then return "REINDEX" else return "REINDEX " + formatObjectName(statement.name) end if
  end if
  if statement is ExplainStatement then
    if statement.analyze then return "EXPLAIN ANALYZE " + formatStatement(statement.statement) else return "EXPLAIN " + formatStatement(statement.statement) end if
  end if
  if statement is ShowTablesStatement then return "SHOW TABLES" end if
  if statement is ShowStatusStatement then return "SHOW STATUS" end if
  if statement is ShowProcesslistStatement then return "SHOW PROCESSLIST" end if
  if statement is DescribeTableStatement then return "DESCRIBE " + formatObjectName(statement.tableName) end if
  if statement is ShowIndexesStatement then return "SHOW INDEXES FROM " + formatObjectName(statement.tableName) end if
  if statement is ShutdownStatement then return "SHUTDOWN" end if
  if statement is SelectStatement then return formatSelect(statement) end if
  if statement is CreateSchemaStatement then
    output = "CREATE SCHEMA "
    if statement.ifNotExists then output = output + "IF NOT EXISTS " end if
    return output + formatObjectName(statement.name)
  end if
  if statement is DropSchemaStatement then
    output = "DROP SCHEMA "
    if statement.ifExists then output = output + "IF EXISTS " end if
    return output + formatObjectName(statement.name)
  end if
  if statement is DropIndexStatement then
    output = "DROP INDEX "
    if statement.ifExists then output = output + "IF EXISTS " end if
    return output + formatObjectName(statement.name)
  end if
  if statement is InsertStatement then
    output = "INSERT INTO " + formatObjectName(statement.tableName)
    if len(statement.columns) > 0 then
      output = output + " ("
      if len(statement.columns) > 0 then
        for index = 0 to len(statement.columns) - 1
          if index > 0 then output = output + ", " end if
          output = output + formatObjectName(statement.columns[index])
        end for
      end if
      output = output + ")"
    end if
    if statement.sourceQuery is not void then
      output = output + " " + formatSelect(statement.sourceQuery)
    else
      output = output + " VALUES "
      for rowIndex = 0 to len(statement.rows) - 1
        if rowIndex > 0 then output = output + ", " end if
        output = output + "("
        if len(statement.rows[rowIndex]) > 0 then
          for index = 0 to len(statement.rows[rowIndex]) - 1
            if index > 0 then output = output + ", " end if
            output = output + formatExpression(statement.rows[rowIndex][index])
          end for
        end if
        output = output + ")"
      end for
    end if
    if statement.conflictAction != CONFLICT_NONE then
      output = output + " ON CONFLICT"
      if len(statement.conflictTarget) > 0 then output = output + " (" + formatIdentifierList(statement.conflictTarget) + ")" end if
      if statement.conflictAction == CONFLICT_DO_NOTHING then output = output + " DO NOTHING" else output = output + " DO UPDATE SET " + formatAssignments(statement.conflictAssignments) end if
      if statement.conflictWhere is not void then output = output + " WHERE " + formatExpression(statement.conflictWhere) end if
    end if
    return output + formatReturning(statement.returning)
  end if
  if statement is UpdateStatement then
    output = "UPDATE " + formatObjectName(statement.tableName) + " SET "
    if len(statement.assignments) > 0 then
      for index = 0 to len(statement.assignments) - 1
        if index > 0 then output = output + ", " end if
        output = output + formatObjectName(statement.assignments[index].column) + " = " + formatExpression(statement.assignments[index].expression)
      end for
    end if
    if statement.whereExpression is not void then output = output + " WHERE " + formatExpression(statement.whereExpression) end if
    return output + formatReturning(statement.returning)
  end if
  if statement is DeleteStatement then
    output = "DELETE FROM " + formatObjectName(statement.tableName)
    if statement.whereExpression is not void then output = output + " WHERE " + formatExpression(statement.whereExpression) end if
    return output + formatReturning(statement.returning)
  end if
  if statement is MergeStatement then
    output = "MERGE INTO " + formatObjectName(statement.targetTable)
    if statement.targetAlias is not void then output = output + " AS " + formatObjectName(statement.targetAlias) end if
    output = output + " USING " + formatObjectName(statement.sourceTable)
    if statement.sourceAlias is not void then output = output + " AS " + formatObjectName(statement.sourceAlias) end if
    output = output + " ON " + formatExpression(statement.condition)
    if statement.matchedDelete then output = output + " WHEN MATCHED THEN DELETE" end if
    if len(statement.matchedAssignments) > 0 then output = output + " WHEN MATCHED THEN UPDATE SET " + formatAssignments(statement.matchedAssignments) end if
    if len(statement.insertValues) > 0 then
      output = output + " WHEN NOT MATCHED THEN INSERT"
      if len(statement.insertColumns) > 0 then output = output + " (" + formatIdentifierList(statement.insertColumns) + ")" end if
      output = output + " VALUES (" + formatExpressionList(statement.insertValues) + ")"
    end if
    return output
  end if
  return error(9001, "sql.ast.formatStatement: unsupported statement")
end function

/// Performs the componentName operation for the minisql sql ast module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "sql.ast"
end function

/// Performs the targetMilestone operation for the minisql sql ast module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M12"
end function

/// Returns whether implemented satisfies the condition required by the minisql sql ast module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
