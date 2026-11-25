//! Provides minisql sql parser facilities for this project.

package minisql.sql.parser

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.sql.ast as ast
import minisql.sql.dialect as dialect
import minisql.sql.lexer as lexer
import minisql.sql.token as token

/// Defines the invalid argument constant used by the minisql sql parser module.
const INVALID_ARGUMENT = 9001
/// Defines the sql syntax constant used by the minisql sql parser module.
const SQL_SYNTAX = 9019

/// Cursor state for the recursive-descent statement parser and precedence-climbing
/// expression parser. `tokens` always ends with EndOfInput, keeping `index` valid.
struct ParserState
  /// Immutable token stream produced by the lexer.
  tokens
  /// Index of the next token to inspect or consume.
  index
  /// Number assigned to the next positional parameter encountered.
  parameterCount
  /// Monotonic suffix used to give inline derived tables collision-resistant internal CTE names.
  derivedTableCount
end struct

/// Performs the fail operation for the minisql sql parser module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param message Human-readable message associated with the operation.
function fail(state, message)
  currentToken = state.tokens[state.index]
  return error(SQL_SYNTAX, "sql.parser at line " + currentToken.line + ", column " + currentToken.column + ": " + message + "; found " + token.describe(currentToken))
end function

/// Implements current for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function current(state)
  return state.tokens[state.index]
end function

/// Implements previous for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function previous(state)
  if state.index <= 0 then return state.tokens[0] end if
  return state.tokens[state.index - 1]
end function

/// Implements at end for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function atEnd(state)
  return current(state).kind == token.TokenKind.EndOfInput
end function

/// Advances advance using the supplied inputs.
/// Returns the computed value or operation status.
/// May mutate supplied state as documented by the operation name.
/// @param state Mutable state inspected or updated by the operation.
function advance(state)
  value = current(state)
  if not atEnd(state) then state.index = state.index + 1 end if
  return value
end function

/// Checks kind using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param kind kind value consumed by this operation.
function checkKind(state, kind)
  return current(state).kind == kind
end function

/// Checks keyword using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param keyword keyword value consumed by this operation.
function checkKeyword(state, keyword)
  return token.isKeyword(current(state), keyword)
end function

/// Implements next is kind for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param kind kind value consumed by this operation.
function nextIsKind(state, kind)
  position = state.index + 1
  if position >= len(state.tokens) then return false end if
  return state.tokens[position].kind == kind
end function

/// Implements next is keyword for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param keyword keyword value consumed by this operation.
function nextIsKeyword(state, keyword)
  position = state.index + 1
  if position >= len(state.tokens) then return false end if
  return token.isKeyword(state.tokens[position], keyword)
end function

/// Returns whether the supplied value satisfies the identifier token condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isIdentifierToken(value)
  if token.isKind(value, token.TokenKind.Identifier) then return true end if
  if not token.isKind(value, token.TokenKind.Keyword) then return false end if
  return dialect.isNonReservedIdentifierKeyword(value.text)
end function

/// Returns whether the supplied value satisfies the function name token condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isFunctionNameToken(value)
  return isIdentifierToken(value) or token.isKeyword(value, "COALESCE") or token.isKeyword(value, "NULLIF") or token.isKeyword(value, "ROW_NUMBER") or token.isKeyword(value, "RANK") or token.isKeyword(value, "DENSE_RANK") or token.isKeyword(value, "PERCENT_RANK") or token.isKeyword(value, "CUME_DIST") or token.isKeyword(value, "NTILE") or token.isKeyword(value, "LAG") or token.isKeyword(value, "LEAD") or token.isKeyword(value, "FIRST_VALUE") or token.isKeyword(value, "LAST_VALUE") or token.isKeyword(value, "NTH_VALUE") or token.isKeyword(value, "NEXTVAL") or token.isKeyword(value, "CURRVAL")
end function

/// OLD and NEW are reserved pseudo-row qualifiers, not general identifiers.
/// The parser accepts them only in the qualified form OLD.column / NEW.column.
/// Trigger execution replaces those qualified column expressions with typed row
/// literals before the body is bound and executed.
/// Returns whether the supplied value satisfies the trigger row qualifier token condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isTriggerRowQualifierToken(value)
  return token.isKeyword(value, "OLD") or token.isKeyword(value, "NEW")
end function

/// Implements match kind for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param kind kind value consumed by this operation.
function matchKind(state, kind)
  if not checkKind(state, kind) then return false end if
  advance(state)
  return true
end function

/// Implements match keyword for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param keyword keyword value consumed by this operation.
function matchKeyword(state, keyword)
  if not checkKeyword(state, keyword) then return false end if
  advance(state)
  return true
end function

/// Implements expect kind for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param kind kind value consumed by this operation.
/// @param description description value consumed by this operation.
function expectKind(state, kind, description)
  if not checkKind(state, kind) then return fail(state, "expected " + description) end if
  return advance(state)
end function

/// Implements expect keyword for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param keyword keyword value consumed by this operation.
function expectKeyword(state, keyword)
  if not checkKeyword(state, keyword) then return fail(state, "expected keyword " + keyword) end if
  return advance(state)
end function

/// Parses identifier using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param description description value consumed by this operation.
function parseIdentifier(state, description)
  value = current(state)
  if not isIdentifierToken(value) then return fail(state, "expected " + description) end if
  advance(state)
  name = value.text
  if value.kind == token.TokenKind.Keyword then
    name = dialect.canonicalIdentifier(value.text, false)
  end if
  return ast.identifier(name, value.quoted)
end function

/// Parses identifier name using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param description description value consumed by this operation.
function parseIdentifierName(state, description)
  return parseIdentifier(state, description).name
end function

/// Parses an optionally schema-qualified SQL object name into its canonical dotted form.
/// @param state Mutable state inspected or updated by the operation.
/// @param description description value consumed by this operation.
function parseObjectName(state, description)
  first = "public"
  if not matchKeyword(state, "PUBLIC") then first = parseIdentifierName(state, description) end if
  if not matchKind(state, token.TokenKind.Dot) then return first end if
  second = parseIdentifierName(state, description)
  if first == "public" then return second end if
  return first + "." + second
end function

/// Parses principal name using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param description description value consumed by this operation.
function parsePrincipalName(state, description)
  if matchKeyword(state, "PUBLIC") then return "public" end if
  return parseIdentifierName(state, description)
end function

/// Parses password literal using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parsePasswordLiteral(state)
  value = expectKind(state, token.TokenKind.StringLiteral, "password string literal")
  return value.value
end function

/// Parses identifier list using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseIdentifierList(state)
  expectKind(state, token.TokenKind.LeftParen, "'('")
  result = [parseIdentifierName(state, "column name")]
  while matchKind(state, token.TokenKind.Comma)
    result = result + [parseIdentifierName(state, "column name")]
  end while
  expectKind(state, token.TokenKind.RightParen, "')'")
  return result
end function

/// Parses integer value using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param description description value consumed by this operation.
function parseIntegerValue(state, description)
  sign = ""
  if matchKind(state, token.TokenKind.Plus) then sign = "+" else if matchKind(state, token.TokenKind.Minus) then sign = "-" end if
  value = expectKind(state, token.TokenKind.IntegerLiteral, description)
  parsed = toNumber(sign + value.text)
  if parsed is void or typeof(parsed) != "int" then return fail(state, description + " must fit the native MiniLang integer range") end if
  return parsed
end function

/// Parses type name using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseTypeName(state)
  currentToken = current(state)
  if currentToken.kind != token.TokenKind.Keyword and currentToken.kind != token.TokenKind.Identifier then return fail(state, "expected SQL data type") end if
  advance(state)
  name = currentToken.text
  if currentToken.kind == token.TokenKind.Identifier then name = currentToken.text end if
  if name == "DOUBLE" and matchKeyword(state, "PRECISION") then name = "DOUBLE PRECISION" end if
  length = 0
  precision = 0
  scale = 0
  if matchKind(state, token.TokenKind.LeftParen) then
    first = parseIntegerValue(state, "type parameter")
    if matchKind(state, token.TokenKind.Comma) then
      precision = first
      scale = parseIntegerValue(state, "scale")
    else
      length = first
      precision = first
    end if
    expectKind(state, token.TokenKind.RightParen, "')'")
  end if
  return ast.typeName(name, length, precision, scale)
end function

/// Retains explicit character attributes on routine declarations for validation
/// against the stored routine context; ordinary column/CAST grammar stays intact.
function parseRoutineTypeName(state)
  result = parseTypeName(state)
  while checkKeyword(state, "CHARACTER") or checkKeyword(state, "COLLATE")
    if result.name != "CHAR" and result.name != "VARCHAR" and result.name != "TEXT" then return fail(state, "character attributes require a character data type") end if
    if matchKeyword(state, "CHARACTER") then
      expectKeyword(state, "SET")
      if result.characterSet != "" then return fail(state, "duplicate CHARACTER SET attribute") end if
      result.characterSet = dialect.asciiLower(parseIdentifierName(state, "character set name"))
    else
      expectKeyword(state, "COLLATE")
      if result.collation != "" then return fail(state, "duplicate COLLATE attribute") end if
      result.collation = dialect.asciiLower(parseIdentifierName(state, "collation name"))
    end if
  end while
  return result
end function

/// Parses referential action using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseReferentialAction(state)
  if matchKeyword(state, "RESTRICT") then return "RESTRICT" end if
  if matchKeyword(state, "CASCADE") then return "CASCADE" end if
  if matchKeyword(state, "NO") then expectKeyword(state, "ACTION"); return "NO ACTION" end if
  if matchKeyword(state, "SET") then expectKeyword(state, "NULL"); return "SET NULL" end if
  return fail(state, "expected referential action")
end function

/// Parses column definition using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseColumnDefinition(state)
  name = parseIdentifierName(state, "column name")
  dataType = parseTypeName(state)
  nullable = true
  nullableSpecified = false
  primaryKey = false
  unique = false
  defaultExpression = void
  checkExpression = void
  referencesTable = void
  referencesColumns = []
  onDelete = "NO ACTION"
  onUpdate = "NO ACTION"
  identity = false
  generatedExpression = void
  generatedStored = false

  parsing = true
  while parsing
    if matchKeyword(state, "NOT") then
      expectKeyword(state, "NULL")
      nullable = false
      nullableSpecified = true
    else if matchKeyword(state, "NULL") then
      nullable = true
      nullableSpecified = true
    else if matchKeyword(state, "PRIMARY") then
      expectKeyword(state, "KEY")
      primaryKey = true
      unique = true
      nullable = false
      nullableSpecified = true
    else if matchKeyword(state, "UNIQUE") then
      unique = true
    else if matchKeyword(state, "DEFAULT") then
      defaultExpression = parseExpression(state, 0)
    else if matchKeyword(state, "CHECK") then
      expectKind(state, token.TokenKind.LeftParen, "'('")
      checkExpression = parseExpression(state, 0)
      expectKind(state, token.TokenKind.RightParen, "')'")
    else if matchKeyword(state, "REFERENCES") then
      referencesTable = parseObjectName(state, "referenced table")
      referencesColumns = parseIdentifierList(state)
    else if matchKeyword(state, "ON") then
      if matchKeyword(state, "DELETE") then
        onDelete = parseReferentialAction(state)
      else if matchKeyword(state, "UPDATE") then
        onUpdate = parseReferentialAction(state)
      else
        return fail(state, "expected DELETE or UPDATE after ON")
      end if
    else if matchKeyword(state, "GENERATED") then
      ignoredAlways = matchKeyword(state, "ALWAYS")
      expectKeyword(state, "AS")
      if matchKeyword(state, "IDENTITY") then
        identity = true
      else
        expectKind(state, token.TokenKind.LeftParen, "'('")
        generatedExpression = parseExpression(state, 0)
        expectKind(state, token.TokenKind.RightParen, "')'")
        expectKeyword(state, "STORED")
        generatedStored = true
      end if
    else if matchKeyword(state, "AUTO_INCREMENT") then
      identity = true
      nullable = false
      nullableSpecified = true
    else if matchKeyword(state, "AUTOINCREMENT") then
      identity = true
      nullable = false
      nullableSpecified = true
    else
      parsing = false
    end if
  end while
  return ast.ColumnDefinition(name, dataType, nullable, nullableSpecified, primaryKey, unique, defaultExpression, checkExpression, referencesTable, referencesColumns, onDelete, onUpdate, identity, generatedExpression, generatedStored)
end function

/// Parses table constraint using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseTableConstraint(state)
  name = void
  if matchKeyword(state, "CONSTRAINT") then name = parseIdentifierName(state, "constraint name") end if
  if matchKeyword(state, "PRIMARY") then
    expectKeyword(state, "KEY")
    return ast.TableConstraint(ast.CONSTRAINT_PRIMARY_KEY, name, parseIdentifierList(state), void, void, [], "NO ACTION", "NO ACTION")
  end if
  if matchKeyword(state, "UNIQUE") then
    return ast.TableConstraint(ast.CONSTRAINT_UNIQUE, name, parseIdentifierList(state), void, void, [], "NO ACTION", "NO ACTION")
  end if
  if matchKeyword(state, "CHECK") then
    expectKind(state, token.TokenKind.LeftParen, "'('")
    expression = parseExpression(state, 0)
    expectKind(state, token.TokenKind.RightParen, "')'")
    return ast.TableConstraint(ast.CONSTRAINT_CHECK, name, [], expression, void, [], "NO ACTION", "NO ACTION")
  end if
  if matchKeyword(state, "FOREIGN") then
    expectKeyword(state, "KEY")
    columns = parseIdentifierList(state)
    expectKeyword(state, "REFERENCES")
    referenceTable = parseObjectName(state, "referenced table")
    referenceColumns = parseIdentifierList(state)
    onDelete = "NO ACTION"
    onUpdate = "NO ACTION"
    while matchKeyword(state, "ON")
      if matchKeyword(state, "DELETE") then
        onDelete = parseReferentialAction(state)
      else if matchKeyword(state, "UPDATE") then
        onUpdate = parseReferentialAction(state)
      else
        return fail(state, "expected DELETE or UPDATE after ON")
      end if
    end while
    return ast.TableConstraint(ast.CONSTRAINT_FOREIGN_KEY, name, columns, void, referenceTable, referenceColumns, onDelete, onUpdate)
  end if
  return fail(state, "expected PRIMARY KEY, UNIQUE, CHECK or FOREIGN KEY constraint")
end function

/// Implements starts table constraint for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function startsTableConstraint(state)
  return checkKeyword(state, "CONSTRAINT") or checkKeyword(state, "PRIMARY") or checkKeyword(state, "UNIQUE") or checkKeyword(state, "CHECK") or checkKeyword(state, "FOREIGN")
end function

/// Parses create principal using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param principalKind principalKind value consumed by this operation.
function parseCreatePrincipal(state, principalKind)
  name = parsePrincipalName(state, "principal name")
  password = void
  if principalKind == ast.PRINCIPAL_USER then
    expectKeyword(state, "WITH")
    expectKeyword(state, "PASSWORD")
    password = parsePasswordLiteral(state)
  end if
  return ast.CreatePrincipalStatement(principalKind, name, password)
end function

/// Parses alter table using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseAlterTable(state)
  tableName = parseObjectName(state, "table name")
  if matchKeyword(state, "ADD") then
    ignoredColumn = matchKeyword(state, "COLUMN")
    if startsTableConstraint(state) then
      return ast.AlterTableStatement(tableName, ast.ALTER_TABLE_ADD_CONSTRAINT, void, void, void, parseTableConstraint(state), void)
    end if
    return ast.AlterTableStatement(tableName, ast.ALTER_TABLE_ADD_COLUMN, parseColumnDefinition(state), void, void, void, void)
  end if
  if matchKeyword(state, "RENAME") then
    if matchKeyword(state, "COLUMN") then
      oldName = parseIdentifierName(state, "old column name")
      expectKeyword(state, "TO")
      return ast.AlterTableStatement(tableName, ast.ALTER_TABLE_RENAME_COLUMN, void, oldName, parseIdentifierName(state, "new column name"), void, void)
    end if
    expectKeyword(state, "TO")
    return ast.AlterTableStatement(tableName, ast.ALTER_TABLE_RENAME_TABLE, void, void, parseIdentifierName(state, "new table name"), void, void)
  end if
  if matchKeyword(state, "DROP") then
    if matchKeyword(state, "COLUMN") then
      return ast.AlterTableStatement(tableName, ast.ALTER_TABLE_DROP_COLUMN, void, parseIdentifierName(state, "column name"), void, void, void)
    end if
    expectKeyword(state, "CONSTRAINT")
    return ast.AlterTableStatement(tableName, ast.ALTER_TABLE_DROP_CONSTRAINT, void, void, void, void, parseIdentifierName(state, "constraint name"))
  end if
  if matchKeyword(state, "ALTER") then
    ignoredColumn = matchKeyword(state, "COLUMN")
    columnName = parseIdentifierName(state, "column name")
    if matchKeyword(state, "SET") then
      if matchKeyword(state, "DEFAULT") then
        return ast.AlterTableStatement(tableName, ast.ALTER_TABLE_SET_DEFAULT, parseExpression(state, 0), columnName, void, void, void)
      end if
      expectKeyword(state, "NOT")
      expectKeyword(state, "NULL")
      return ast.AlterTableStatement(tableName, ast.ALTER_TABLE_SET_NOT_NULL, void, columnName, void, void, void)
    end if
    expectKeyword(state, "DROP")
    if matchKeyword(state, "DEFAULT") then
      return ast.AlterTableStatement(tableName, ast.ALTER_TABLE_DROP_DEFAULT, void, columnName, void, void, void)
    end if
    expectKeyword(state, "NOT")
    expectKeyword(state, "NULL")
    return ast.AlterTableStatement(tableName, ast.ALTER_TABLE_DROP_NOT_NULL, void, columnName, void, void, void)
  end if
  return fail(state, "expected ADD, RENAME, DROP or ALTER after ALTER TABLE")
end function

/// Parses alter using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseAlter(state)
  if matchKeyword(state, "PROCEDURE") then
    node = routineNode("ALTER_PROCEDURE", parseObjectName(state, "procedure name"))
    node.options = parseRoutineCharacteristics(state)
    if len(node.options) == 0 then return fail(state, "ALTER PROCEDURE requires a characteristic") end if
    return node
  end if
  if matchKeyword(state, "TABLE") then return parseAlterTable(state) end if
  if matchKeyword(state, "TRIGGER") then
    name = parseObjectName(state, "trigger name")
    if matchKeyword(state, "ENABLE") then return ast.AlterTriggerStatement(name, true) end if
    expectKeyword(state, "DISABLE")
    return ast.AlterTriggerStatement(name, false)
  end if
  expectKeyword(state, "USER")
  name = parsePrincipalName(state, "user name")
  if matchKeyword(state, "WITH") then
    expectKeyword(state, "PASSWORD")
    return ast.AlterUserStatement(name, ast.ALTER_USER_PASSWORD, parsePasswordLiteral(state))
  end if
  if matchKeyword(state, "ENABLE") then return ast.AlterUserStatement(name, ast.ALTER_USER_ENABLE, void) end if
  if matchKeyword(state, "DISABLE") then return ast.AlterUserStatement(name, ast.ALTER_USER_DISABLE, void) end if
  return fail(state, "expected WITH PASSWORD, ENABLE or DISABLE after ALTER USER")
end function

/// Implements privilege name for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function privilegeName(state)
  value = current(state)
  if value.kind != token.TokenKind.Keyword then return fail(state, "expected privilege name") end if
  allowed = value.text == "CONNECT" or value.text == "CREATE" or value.text == "MAINTAIN" or value.text == "ADMIN" or value.text == "SELECT" or value.text == "INSERT" or value.text == "UPDATE" or value.text == "DELETE" or value.text == "REFERENCES" or value.text == "INDEX" or value.text == "ALTER" or value.text == "DROP" or value.text == "EXECUTE" or value.text == "SHOW_ROUTINE" or value.text == "SET_ANY_DEFINER"
  if not allowed then return fail(state, "unsupported privilege " + value.text) end if
  advance(state)
  if (value.text == "CREATE" or value.text == "ALTER") and matchKeyword(state, "ROUTINE") then return value.text + " ROUTINE" end if
  return value.text
end function

/// Parses privilege list using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parsePrivilegeList(state)
  if matchKeyword(state, "ALL") then
    ignored = matchKeyword(state, "PRIVILEGES")
    return ["ALL"]
  end if
  privileges = [privilegeName(state)]
  while matchKind(state, token.TokenKind.Comma)
    privileges = privileges + [privilegeName(state)]
  end while
  return privileges
end function

/// Parses grant using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseGrant(state)
  // An identifier in the first position denotes a role grant. Privileges are
  // reserved keywords in the M21 dialect and therefore unambiguous.
  if checkKind(state, token.TokenKind.Identifier) then
    roleName = parsePrincipalName(state, "role name")
    expectKeyword(state, "TO")
    memberName = parsePrincipalName(state, "member name")
    adminOption = false
    if matchKeyword(state, "WITH") then expectKeyword(state, "ADMIN"); expectKeyword(state, "OPTION"); adminOption = true end if
    return ast.GrantRoleStatement(roleName, memberName, adminOption)
  end if
  privileges = parsePrivilegeList(state)
  expectKeyword(state, "ON")
  objectType = ast.DCL_OBJECT_TABLE
  objectName = void
  if matchKeyword(state, "DATABASE") then
    objectType = ast.DCL_OBJECT_DATABASE
  else if matchKeyword(state, "PROCEDURE") then
    objectType = ast.DCL_OBJECT_PROCEDURE
    objectName = parseObjectName(state, "procedure name")
  else
    ignoredTable = matchKeyword(state, "TABLE")
    objectName = parseObjectName(state, "table name")
  end if
  expectKeyword(state, "TO")
  granteeName = parsePrincipalName(state, "grantee name")
  grantOption = false
  if matchKeyword(state, "WITH") then expectKeyword(state, "GRANT"); expectKeyword(state, "OPTION"); grantOption = true end if
  return ast.GrantPrivilegeStatement(privileges, objectType, objectName, granteeName, grantOption)
end function

/// Parses revoke behavior using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseRevokeBehavior(state)
  cascade = false
  if matchKeyword(state, "CASCADE") then return true end if
  if matchKeyword(state, "RESTRICT") then return false end if
  return cascade
end function

/// Parses revoke using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseRevoke(state)
  if checkKind(state, token.TokenKind.Identifier) then
    roleName = parsePrincipalName(state, "role name")
    expectKeyword(state, "FROM")
    memberName = parsePrincipalName(state, "member name")
    cascade = parseRevokeBehavior(state)
    return ast.RevokeRoleStatement(roleName, memberName, cascade)
  end if
  privileges = parsePrivilegeList(state)
  expectKeyword(state, "ON")
  objectType = ast.DCL_OBJECT_TABLE
  objectName = void
  if matchKeyword(state, "DATABASE") then
    objectType = ast.DCL_OBJECT_DATABASE
  else if matchKeyword(state, "PROCEDURE") then
    objectType = ast.DCL_OBJECT_PROCEDURE
    objectName = parseObjectName(state, "procedure name")
  else
    ignoredTable = matchKeyword(state, "TABLE")
    objectName = parseObjectName(state, "table name")
  end if
  expectKeyword(state, "FROM")
  granteeName = parsePrincipalName(state, "grantee name")
  cascade = parseRevokeBehavior(state)
  return ast.RevokePrivilegeStatement(privileges, objectType, objectName, granteeName, cascade)
end function

/// Parses create table using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseCreateTable(state)
  ifNotExists = false
  if matchKeyword(state, "IF") then expectKeyword(state, "NOT"); expectKeyword(state, "EXISTS"); ifNotExists = true end if
  name = parseObjectName(state, "table name")
  expectKind(state, token.TokenKind.LeftParen, "'('")
  columns = []
  constraints = []
  first = true
  while not checkKind(state, token.TokenKind.RightParen)
    if not first then expectKind(state, token.TokenKind.Comma, "','") end if
    if startsTableConstraint(state) then
      constraints = constraints + [parseTableConstraint(state)]
    else
      columns = columns + [parseColumnDefinition(state)]
    end if
    first = false
  end while
  expectKind(state, token.TokenKind.RightParen, "')'")
  if len(columns) == 0 then return fail(state, "CREATE TABLE requires at least one column") end if
  return ast.CreateTableStatement(name, columns, constraints, ifNotExists)
end function

/// Parses CREATE SCHEMA with optional idempotent creation semantics.
/// @param state Mutable state inspected or updated by the operation.
function parseCreateSchema(state)
  ifNotExists = false
  if matchKeyword(state, "IF") then expectKeyword(state, "NOT"); expectKeyword(state, "EXISTS"); ifNotExists = true end if
  return ast.CreateSchemaStatement(parseIdentifierName(state, "schema name"), ifNotExists)
end function

/// Parses the parenthesized expression list used by CREATE INDEX keys.
/// @param state Mutable state inspected or updated by the operation.
function parseIndexKeyList(state)
  expectKind(state, token.TokenKind.LeftParen, "'('")
  keys = [parseExpression(state, 0)]
  while matchKind(state, token.TokenKind.Comma)
    keys = keys + [parseExpression(state, 0)]
  end while
  expectKind(state, token.TokenKind.RightParen, "')'")
  return keys
end function

/// Parses create index using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param unique unique value consumed by this operation.
function parseCreateIndex(state, unique)
  ifNotExists = false
  if matchKeyword(state, "IF") then expectKeyword(state, "NOT"); expectKeyword(state, "EXISTS"); ifNotExists = true end if
  name = parseObjectName(state, "index name")
  expectKeyword(state, "ON")
  tableName = parseObjectName(state, "table name")
  columns = parseIndexKeyList(state)
  includeColumns = []
  if matchKeyword(state, "INCLUDE") then includeColumns = parseIdentifierList(state) end if
  whereExpression = void
  if matchKeyword(state, "WHERE") then whereExpression = parseExpression(state, 0) end if
  return ast.CreateIndexStatement(name, tableName, columns, includeColumns, whereExpression, unique, ifNotExists)
end function

/// Parses create view using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param replace replace value consumed by this operation.
function parseCreateView(state, replace)
  name = parseObjectName(state, "view name")
  expectKeyword(state, "AS")
  query = void
  if matchKeyword(state, "WITH") then
    query = parseWithSelect(state)
  else
    expectKeyword(state, "SELECT")
    query = parseSelect(state)
  end if
  return ast.CreateViewStatement(name, query, replace)
end function

/// Builds a procedural AST node with empty optional collections.
function routineNode(kind, name)
  return ast.RoutineStatement(kind, name, [], [], [], [], [])
end function

/// Returns a canonical variable target, keeping session-variable @ prefixes.
function parseRoutineTarget(state)
  if checkKind(state, token.TokenKind.UserVariable) then return advance(state).text end if
  name = parseIdentifierName(state, "variable name")
  if matchKind(state, token.TokenKind.Dot) then name = name + "." + parseIdentifierName(state, "qualified variable name") end if
  return name
end function

/// Parses a nonempty comma-separated list of writable variable names.
function parseRoutineTargets(state)
  names = [parseRoutineTarget(state)]
  while matchKind(state, token.TokenKind.Comma)
    names = names + [parseRoutineTarget(state)]
  end while
  return names
end function

/// Validates a SQLSTATE and retains its canonical five-character value.
function parseSqlstate(state)
  ignoredValue = matchKeyword(state, "VALUE")
  value = expectKind(state, token.TokenKind.StringLiteral, "five-character SQLSTATE").value
  raw = bytes(value)
  if len(raw) != 5 then return fail(state, "SQLSTATE must contain five characters") end if
  for each item in raw
    if not ((item >= 48 and item <= 57) or (item >= 65 and item <= 90)) then return fail(state, "SQLSTATE must contain uppercase letters or digits") end if
  end for
  if raw[0] == 48 and raw[1] == 48 then return fail(state, "successful SQLSTATE class 00 is not a condition") end if
  return value
end function

/// Parses a handler condition or a named/SQLSTATE signal condition.
function parseRoutineCondition(state, handler)
  if matchKeyword(state, "SQLSTATE") then return ["SQLSTATE", parseSqlstate(state)] end if
  if handler and checkKind(state, token.TokenKind.IntegerLiteral) then
    value = parseIntegerValue(state, "condition error number")
    if value <= 0 or value > 65535 then return fail(state, "condition error number must be 1..65535") end if
    return ["ERRNO", "" + value]
  end if
  if handler and matchKeyword(state, "NOT") then expectKeyword(state, "FOUND"); return ["CLASS", "NOT FOUND"] end if
  if handler and matchKeyword(state, "SQLWARNING") then return ["CLASS", "SQLWARNING"] end if
  if handler and matchKeyword(state, "SQLEXCEPTION") then return ["CLASS", "SQLEXCEPTION"] end if
  return ["NAME", parseIdentifierName(state, "condition name")]
end function

/// Parses a declaration; ordering is checked by its enclosing BEGIN block.
function parseRoutineDeclare(state)
  if checkKeyword(state, "CONTINUE") or checkKeyword(state, "EXIT") then
    action = advance(state).text
    expectKeyword(state, "HANDLER")
    expectKeyword(state, "FOR")
    node = routineNode("HANDLER", action)
    node.options = [parseRoutineCondition(state, true)]
    while matchKind(state, token.TokenKind.Comma)
      node.options = node.options + [parseRoutineCondition(state, true)]
    end while
    node.body = [parseRoutineStatement(state)]
    return node
  end if
  name = parseIdentifierName(state, "declared name")
  if matchKeyword(state, "CONDITION") then
    expectKeyword(state, "FOR")
    node = routineNode("CONDITION", name)
    node.options = parseRoutineCondition(state, true)
    if node.options[0] != "SQLSTATE" and node.options[0] != "ERRNO" then return fail(state, "CONDITION requires an error number or SQLSTATE") end if
    return node
  end if
  if matchKeyword(state, "CURSOR") then
    expectKeyword(state, "FOR")
    node = routineNode("CURSOR", name)
    if matchKeyword(state, "WITH") then node.body = [parseWithSelect(state)] else expectKeyword(state, "SELECT"); node.body = [parseSelect(state)] end if
    return node
  end if
  node = routineNode("DECLARE", "")
  node.names = [name]
  while matchKind(state, token.TokenKind.Comma)
    node.names = node.names + [parseIdentifierName(state, "declared variable name")]
  end while
  node.options = [parseRoutineTypeName(state)]
  if matchKeyword(state, "DEFAULT") then node.expressions = [parseExpression(state, 0)] end if
  return node
end function

/// Parses statements up to a branch/loop terminator, consuming inner semicolons.
function parseRoutineStatements(state)
  statements = []
  while not atEnd(state)
    if checkKeyword(state, "END") or checkKeyword(state, "ELSE") or checkKeyword(state, "ELSEIF") or checkKeyword(state, "WHEN") or checkKeyword(state, "UNTIL") then break end if
    if checkKeyword(state, "DECLARE") then return fail(state, "DECLARE is permitted only at the beginning of BEGIN ... END") end if
    statements = statements + [parseRoutineStatement(state)]
    expectKind(state, token.TokenKind.Semicolon, "';' after routine statement")
  end while
  return statements
end function

/// Validates an optional closing label against the opening label.
function parseRoutineClosingLabel(state, label)
  if isIdentifierToken(current(state)) then
    closing = parseIdentifierName(state, "closing label")
    if label == "" or label != closing then return fail(state, "closing label does not match opening label") end if
  end if
  return true
end function

/// Parses a block with SQL declaration ordering and an optional label.
function parseRoutineBlock(state, label)
  node = routineNode("BLOCK", label)
  declarationPhase = 0
  while matchKeyword(state, "DECLARE")
    declared = parseRoutineDeclare(state)
    phase = 0
    if declared.kind == "CURSOR" then phase = 1 end if
    if declared.kind == "HANDLER" then phase = 2 end if
    if phase < declarationPhase then return fail(state, "declare variables/conditions before cursors and cursors before handlers") end if
    declarationPhase = phase
    node.body = node.body + [declared]
    expectKind(state, token.TokenKind.Semicolon, "';' after declaration")
  end while
  node.body = node.body + parseRoutineStatements(state)
  expectKeyword(state, "END")
  parseRoutineClosingLabel(state, label)
  return node
end function

/// Parses IF and all ELSEIF/ELSE branches into parallel branch arrays.
function parseRoutineIf(state)
  node = routineNode("IF", "")
  node.expressions = [parseExpression(state, 0)]
  expectKeyword(state, "THEN")
  branch = routineNode("BLOCK", "")
  branch.body = parseRoutineStatements(state)
  node.body = [branch]
  while matchKeyword(state, "ELSEIF")
    node.expressions = node.expressions + [parseExpression(state, 0)]
    expectKeyword(state, "THEN")
    branch = routineNode("BLOCK", "")
    branch.body = parseRoutineStatements(state)
    node.body = node.body + [branch]
  end while
  if matchKeyword(state, "ELSE") then node.alternate = parseRoutineStatements(state) end if
  expectKeyword(state, "END")
  expectKeyword(state, "IF")
  return node
end function

/// Preserves a simple CASE selector separately so the runtime evaluates it once.
function parseRoutineCase(state)
  node = routineNode("CASE", "")
  selector = void
  if not checkKeyword(state, "WHEN") then selector = parseExpression(state, 0) end if
  while matchKeyword(state, "WHEN")
    node.expressions = node.expressions + [parseExpression(state, 0)]
    expectKeyword(state, "THEN")
    branch = routineNode("BLOCK", "")
    branch.body = parseRoutineStatements(state)
    node.body = node.body + [branch]
  end while
  if len(node.body) == 0 then return fail(state, "CASE requires at least one WHEN branch") end if
  hasElse = matchKeyword(state, "ELSE")
  if hasElse then node.alternate = parseRoutineStatements(state) end if
  node.options = [hasElse, selector]
  expectKeyword(state, "END")
  expectKeyword(state, "CASE")
  return node
end function

/// Parses a labeled WHILE, REPEAT, or LOOP and matching end marker.
function parseRoutineLoop(state, kind, label)
  node = routineNode(kind, label)
  if kind == "WHILE" then node.expressions = [parseExpression(state, 0)]; expectKeyword(state, "DO") end if
  node.body = parseRoutineStatements(state)
  if kind == "REPEAT" then expectKeyword(state, "UNTIL"); node.expressions = [parseExpression(state, 0)] end if
  expectKeyword(state, "END")
  expectKeyword(state, kind)
  parseRoutineClosingLabel(state, label)
  return node
end function

/// Parses SET's left-to-right assignments, preserving local/session destinations.
function parseRoutineSet(state)
  sessionAssignment = matchKeyword(state, "SESSION")
  node = routineNode("SET", "")
  parsing = true
  while parsing
    target = parseRoutineTarget(state)
    if sessionAssignment then target = "@@session." + target end if
    node.names = node.names + [target]
    if not matchKind(state, token.TokenKind.Assign) then expectKind(state, token.TokenKind.Equal, "'=' or ':='") end if
    node.expressions = node.expressions + [parseExpression(state, 0)]
    if not matchKind(state, token.TokenKind.Comma) then parsing = false end if
  end while
  return node
end function

/// Returns an unquoted diagnostic identifier in canonical uppercase form.
function parseDiagnosticItem(state)
  value = current(state)
  if value.kind != token.TokenKind.Identifier and value.kind != token.TokenKind.Keyword then return fail(state, "expected diagnostic item name") end if
  advance(state)
  return dialect.asciiUpper(value.text)
end function

/// Lists condition information names accepted by SIGNAL and GET DIAGNOSTICS.
function isConditionInformationItem(name)
  return name == "CLASS_ORIGIN" or name == "SUBCLASS_ORIGIN" or name == "CONSTRAINT_CATALOG" or name == "CONSTRAINT_SCHEMA" or name == "CONSTRAINT_NAME" or name == "CATALOG_NAME" or name == "SCHEMA_NAME" or name == "TABLE_NAME" or name == "COLUMN_NAME" or name == "CURSOR_NAME" or name == "MESSAGE_TEXT" or name == "MYSQL_ERRNO"
end function

/// Parses SIGNAL/RESIGNAL with optional condition-information assignments.
function parseRoutineSignal(state, kind)
  node = routineNode(kind, "")
  if kind == "SIGNAL" or (not checkKeyword(state, "SET") and not checkKind(state, token.TokenKind.Semicolon) and not atEnd(state)) then node.options = parseRoutineCondition(state, false) end if
  if matchKeyword(state, "SET") then
    parsing = true
    while parsing
      item = parseDiagnosticItem(state)
      if not isConditionInformationItem(item) then return fail(state, "unsupported SIGNAL information item " + item) end if
      for each existing in node.names
        if existing == item then return fail(state, "duplicate diagnostic item " + item) end if
      end for
      node.names = node.names + [item]
      expectKind(state, token.TokenKind.Equal, "'='")
      node.expressions = node.expressions + [parseExpression(state, 0)]
      if not matchKind(state, token.TokenKind.Comma) then parsing = false end if
    end while
  end if
  return node
end function

/// Parses statement or condition diagnostics into ordered target/item pairs.
function parseRoutineDiagnostics(state)
  area = "CURRENT"
  if matchKeyword(state, "STACKED") then area = "STACKED" else ignoredCurrent = matchKeyword(state, "CURRENT") end if
  expectKeyword(state, "DIAGNOSTICS")
  node = routineNode("GET_DIAGNOSTICS", area)
  if matchKeyword(state, "CONDITION") then node.expressions = [parseExpression(state, 0)] end if
  parsing = true
  while parsing
    node.names = node.names + [parseRoutineTarget(state)]
    expectKind(state, token.TokenKind.Equal, "'='")
    item = parseDiagnosticItem(state)
    if len(node.expressions) == 0 then
      if item != "NUMBER" and item != "ROW_COUNT" then return fail(state, "statement diagnostics require NUMBER or ROW_COUNT") end if
    else
      if item != "RETURNED_SQLSTATE" and not isConditionInformationItem(item) then return fail(state, "unsupported condition diagnostics item " + item) end if
    end if
    node.options = node.options + [item]
    if not matchKind(state, token.TokenKind.Comma) then parsing = false end if
  end while
  return node
end function

/// Parses one stored-program statement, leaving its terminator to its container.
function parseRoutineStatement(state)
  label = ""
  if isIdentifierToken(current(state)) and nextIsKind(state, token.TokenKind.Colon) then
    label = parseIdentifierName(state, "statement label")
    expectKind(state, token.TokenKind.Colon, "':'")
  end if
  if matchKeyword(state, "BEGIN") then return parseRoutineBlock(state, label) end if
  if matchKeyword(state, "WHILE") then return parseRoutineLoop(state, "WHILE", label) end if
  if matchKeyword(state, "REPEAT") then return parseRoutineLoop(state, "REPEAT", label) end if
  if matchKeyword(state, "LOOP") then return parseRoutineLoop(state, "LOOP", label) end if
  if label != "" then return fail(state, "labels are permitted on BEGIN, WHILE, REPEAT or LOOP") end if
  if matchKeyword(state, "IF") then return parseRoutineIf(state) end if
  if matchKeyword(state, "CASE") then return parseRoutineCase(state) end if
  if matchKeyword(state, "SET") then return parseRoutineSet(state) end if
  if matchKeyword(state, "LEAVE") then return routineNode("LEAVE", parseIdentifierName(state, "block or loop label")) end if
  if matchKeyword(state, "ITERATE") then return routineNode("ITERATE", parseIdentifierName(state, "loop label")) end if
  if matchKeyword(state, "OPEN") then return routineNode("OPEN", parseIdentifierName(state, "cursor name")) end if
  if matchKeyword(state, "CLOSE") then return routineNode("CLOSE", parseIdentifierName(state, "cursor name")) end if
  if matchKeyword(state, "FETCH") then
    if matchKeyword(state, "NEXT") then ignoredFrom = matchKeyword(state, "FROM") else ignoredFrom = matchKeyword(state, "FROM") end if
    node = routineNode("FETCH", parseIdentifierName(state, "cursor name"))
    expectKeyword(state, "INTO")
    node.names = parseRoutineTargets(state)
    return node
  end if
  if matchKeyword(state, "SIGNAL") then return parseRoutineSignal(state, "SIGNAL") end if
  if matchKeyword(state, "RESIGNAL") then return parseRoutineSignal(state, "RESIGNAL") end if
  if matchKeyword(state, "GET") then return parseRoutineDiagnostics(state) end if
  if matchKeyword(state, "SELECT") then return parseSelectTargetStatement(state, false) end if
  if matchKeyword(state, "WITH") then return parseSelectTargetStatement(state, true) end if
  return parseStatement(state)
end function

/// Wraps only SELECTs with INTO, leaving ordinary SELECT AST contracts intact.
function parseSelectTargetStatement(state, withClause)
  selected = void
  if withClause then selected = parseWithSelectTargets(state, true) else selected = parseSelectTargets(state, true) end if
  if len(selected[1]) == 0 then return selected[0] end if
  node = routineNode("SELECT_INTO", "")
  node.names = selected[1]
  node.body = [selected[0]]
  return node
end function

/// Parses an account name, preserving host qualification without inventing users.
function parseRoutineDefiner(state)
  expectKind(state, token.TokenKind.Equal, "'=' after DEFINER")
  if matchKeyword(state, "CURRENT_USER") then
    if matchKind(state, token.TokenKind.LeftParen) then expectKind(state, token.TokenKind.RightParen, "')'") end if
    return "CURRENT_USER"
  end if
  name = ""
  if checkKind(state, token.TokenKind.StringLiteral) then name = advance(state).value else name = parsePrincipalName(state, "definer account") end if
  if checkKind(state, token.TokenKind.UserVariable) then return name + advance(state).text end if
  if matchKind(state, token.TokenKind.At) then
    if checkKind(state, token.TokenKind.StringLiteral) then return name + "@" + advance(state).value end if
    return name + "@" + parseIdentifierName(state, "definer host")
  end if
  return name
end function

/// Parses characteristic pairs without conflating unspecified values with defaults.
function parseRoutineCharacteristics(state)
  options = []
  parsing = true
  while parsing
    item = void
    if matchKeyword(state, "LANGUAGE") then expectKeyword(state, "SQL"); item = ["LANGUAGE", "SQL"]
    else if matchKeyword(state, "DETERMINISTIC") then item = ["DETERMINISTIC", "YES"]
    else if checkKeyword(state, "NOT") and nextIsKeyword(state, "DETERMINISTIC") then advance(state); advance(state); item = ["DETERMINISTIC", "NO"]
    else if matchKeyword(state, "CONTAINS") then expectKeyword(state, "SQL"); item = ["SQL DATA ACCESS", "CONTAINS SQL"]
    else if matchKeyword(state, "NO") then expectKeyword(state, "SQL"); item = ["SQL DATA ACCESS", "NO SQL"]
    else if matchKeyword(state, "READS") then expectKeyword(state, "SQL"); expectKeyword(state, "DATA"); item = ["SQL DATA ACCESS", "READS SQL DATA"]
    else if matchKeyword(state, "MODIFIES") then expectKeyword(state, "SQL"); expectKeyword(state, "DATA"); item = ["SQL DATA ACCESS", "MODIFIES SQL DATA"]
    else if matchKeyword(state, "SQL") then
      expectKeyword(state, "SECURITY")
      security = "DEFINER"
      if matchKeyword(state, "INVOKER") then security = "INVOKER" else expectKeyword(state, "DEFINER") end if
      item = ["SQL SECURITY", security]
    else if matchKeyword(state, "COMMENT") then item = ["COMMENT", expectKind(state, token.TokenKind.StringLiteral, "routine comment").value]
    else parsing = false
    end if
    if item is not void then
      for each existing in options
        if existing[0] == item[0] then return fail(state, "duplicate routine characteristic " + item[0]) end if
      end for
      options = options + [item]
    end if
  end while
  return options
end function

/// Parses MySQL parameter directions and a compound or single SQL routine body.
function parseCreateProcedure(state, replace)
  ifNotExists = false
  if matchKeyword(state, "IF") then expectKeyword(state, "NOT"); expectKeyword(state, "EXISTS"); ifNotExists = true end if
  if replace and ifNotExists then return fail(state, "OR REPLACE and IF NOT EXISTS cannot be combined") end if
  name = parseObjectName(state, "procedure name")
  expectKind(state, token.TokenKind.LeftParen, "'('")
  parameters = []
  if not checkKind(state, token.TokenKind.RightParen) then
    parsing = true
    while parsing
      mode = "IN"
      if matchKeyword(state, "OUT") then mode = "OUT" else if matchKeyword(state, "INOUT") then mode = "INOUT" else ignoredIn = matchKeyword(state, "IN") end if
      parameterName = parseIdentifierName(state, "procedure parameter")
      for each existing in parameters
        if existing.name == parameterName then return fail(state, "duplicate procedure parameter " + parameterName) end if
      end for
      parameters = parameters + [ast.ProcedureParameter(parameterName, parseRoutineTypeName(state), mode)]
      if not matchKind(state, token.TokenKind.Comma) then parsing = false end if
    end while
  end if
  expectKind(state, token.TokenKind.RightParen, "')'")
  characteristics = parseRoutineCharacteristics(state)
  legacy = matchKeyword(state, "AS")
  if legacy then
    foundSecurity = false
    for each item in characteristics
      if item[0] == "SQL SECURITY" then foundSecurity = true end if
    end for
    if not foundSecurity then characteristics = characteristics + [["SQL SECURITY", "INVOKER"]] end if
  end if
  body = parseRoutineStatement(state)
  return ast.CreateProcedureStatement(name, parameters, body, replace, characteristics, ifNotExists)
end function

/// Parses create sequence using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseCreateSequence(state)
  ifNotExists = false
  if matchKeyword(state, "IF") then expectKeyword(state, "NOT"); expectKeyword(state, "EXISTS"); ifNotExists = true end if
  name = parseObjectName(state, "sequence name")
  startValue = 1
  incrementValue = 1
  minimumValue = -1152921504606846976
  maximumValue = 1152921504606846975
  cycle = false
  parsing = true
  while parsing
    if matchKeyword(state, "START") then
      ignoredWith = matchKeyword(state, "WITH")
      startValue = parseIntegerValue(state, "sequence start")
    else if matchKeyword(state, "INCREMENT") then
      ignoredBy = matchKeyword(state, "BY")
      incrementValue = parseIntegerValue(state, "sequence increment")
    else if matchKeyword(state, "MINVALUE") then
      minimumValue = parseIntegerValue(state, "sequence minimum")
    else if matchKeyword(state, "MAXVALUE") then
      maximumValue = parseIntegerValue(state, "sequence maximum")
    else if matchKeyword(state, "CYCLE") then
      cycle = true
    else if matchKeyword(state, "NO") then
      expectKeyword(state, "CYCLE")
      cycle = false
    else
      parsing = false
    end if
  end while
  if incrementValue == 0 then return fail(state, "sequence increment must not be zero") end if
  if minimumValue > maximumValue or startValue < minimumValue or startValue > maximumValue then return fail(state, "sequence bounds are invalid") end if
  return ast.CreateSequenceStatement(name, startValue, incrementValue, minimumValue, maximumValue, cycle, ifNotExists)
end function

/// Parses create trigger using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseCreateTrigger(state)
  ifNotExists = false
  if matchKeyword(state, "IF") then expectKeyword(state, "NOT"); expectKeyword(state, "EXISTS"); ifNotExists = true end if
  name = parseObjectName(state, "trigger name")
  timing = "AFTER"
  if matchKeyword(state, "BEFORE") then timing = "BEFORE" else expectKeyword(state, "AFTER") end if
  eventType = ""
  targetColumn = ""
  if matchKeyword(state, "INSERT") then eventType = "INSERT" else if matchKeyword(state, "UPDATE") then
    eventType = "UPDATE"
    if matchKeyword(state, "OF") then targetColumn = parseIdentifierName(state, "trigger target column") end if
  else
    expectKeyword(state, "DELETE")
    eventType = "DELETE"
  end if
  expectKeyword(state, "ON")
  tableName = parseObjectName(state, "trigger table")
  if matchKeyword(state, "FOR") then expectKeyword(state, "EACH"); expectKeyword(state, "ROW") end if
  body = parseRoutineStatement(state)
  if not (ast.isInsertStatement(body) or ast.isUpdateStatement(body) or ast.isDeleteStatement(body) or ast.isCallStatement(body) or ast.isRoutineStatement(body)) then return fail(state, "trigger body must be INSERT, UPDATE, DELETE, CALL or a stored-program statement") end if
  return ast.CreateTriggerStatement(name, timing, eventType, tableName, targetColumn, body, ifNotExists)
end function

/// Parses create using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseCreate(state)
  if matchKeyword(state, "DEFINER") then
    definer = parseRoutineDefiner(state)
    expectKeyword(state, "PROCEDURE")
    statement = parseCreateProcedure(state, false)
    statement.characteristics = [["DEFINER", definer]] + statement.characteristics
    return statement
  end if
  if matchKeyword(state, "USER") then return parseCreatePrincipal(state, ast.PRINCIPAL_USER) end if
  if matchKeyword(state, "ROLE") then return parseCreatePrincipal(state, ast.PRINCIPAL_ROLE) end if
  if matchKeyword(state, "SCHEMA") then return parseCreateSchema(state) end if
  if matchKeyword(state, "PROCEDURE") then return parseCreateProcedure(state, false) end if
  if matchKeyword(state, "TABLE") then return parseCreateTable(state) end if
  if matchKeyword(state, "VIEW") then return parseCreateView(state, false) end if
  if matchKeyword(state, "OR") then
    expectKeyword(state, "REPLACE")
    if matchKeyword(state, "VIEW") then return parseCreateView(state, true) end if
    if matchKeyword(state, "DEFINER") then
      definer = parseRoutineDefiner(state)
      expectKeyword(state, "PROCEDURE")
      statement = parseCreateProcedure(state, true)
      statement.characteristics = [["DEFINER", definer]] + statement.characteristics
      return statement
    end if
    expectKeyword(state, "PROCEDURE")
    return parseCreateProcedure(state, true)
  end if
  if matchKeyword(state, "SEQUENCE") then return parseCreateSequence(state) end if
  if matchKeyword(state, "TRIGGER") then return parseCreateTrigger(state) end if
  unique = matchKeyword(state, "UNIQUE")
  if matchKeyword(state, "INDEX") then return parseCreateIndex(state, unique) end if
  return fail(state, "expected USER, ROLE, SCHEMA, TABLE, VIEW, SEQUENCE, TRIGGER or INDEX after CREATE")
end function

/// Parses drop using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseDrop(state)
  principalKind = 0
  if matchKeyword(state, "USER") then principalKind = ast.PRINCIPAL_USER end if
  if principalKind == 0 and matchKeyword(state, "ROLE") then principalKind = ast.PRINCIPAL_ROLE end if
  if principalKind != 0 then
    ifExists = false
    if matchKeyword(state, "IF") then expectKeyword(state, "EXISTS"); ifExists = true end if
    return ast.DropPrincipalStatement(principalKind, parsePrincipalName(state, "principal name"), ifExists)
  end if
  if matchKeyword(state, "INDEX") then
    ifExists = false
    if matchKeyword(state, "IF") then expectKeyword(state, "EXISTS"); ifExists = true end if
    return ast.DropIndexStatement(parseObjectName(state, "index name"), ifExists)
  end if
  if matchKeyword(state, "SCHEMA") then
    ifExists = false
    if matchKeyword(state, "IF") then expectKeyword(state, "EXISTS"); ifExists = true end if
    name = parseIdentifierName(state, "schema name")
    ignoredRestrict = matchKeyword(state, "RESTRICT")
    return ast.DropSchemaStatement(name, ifExists)
  end if
  if matchKeyword(state, "PROCEDURE") then
    ifExists = false
    if matchKeyword(state, "IF") then expectKeyword(state, "EXISTS"); ifExists = true end if
    return ast.DropProcedureStatement(parseObjectName(state, "procedure name"), ifExists)
  end if
  objectKind = "TABLE"
  if matchKeyword(state, "VIEW") then objectKind = "VIEW" else if matchKeyword(state, "SEQUENCE") then objectKind = "SEQUENCE" else if matchKeyword(state, "TRIGGER") then objectKind = "TRIGGER" else expectKeyword(state, "TABLE") end if
  ifExists = false
  if matchKeyword(state, "IF") then expectKeyword(state, "EXISTS"); ifExists = true end if
  name = parseObjectName(state, "object name")
  if objectKind == "VIEW" then return ast.DropViewStatement(name, ifExists) end if
  if objectKind == "SEQUENCE" then return ast.DropSequenceStatement(name, ifExists) end if
  if objectKind == "TRIGGER" then return ast.DropTriggerStatement(name, ifExists) end if
  return ast.DropTableStatement(name, ifExists)
end function

/// Parses returning using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseReturning(state)
  items = []
  if not matchKeyword(state, "RETURNING") then return items end if
  items = [parseSelectItem(state)]
  while matchKind(state, token.TokenKind.Comma)
    items = items + [parseSelectItem(state)]
  end while
  return items
end function

/// Parses assignments using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseAssignments(state)
  assignments = []
  parsingAssignments = true
  while parsingAssignments
    column = parseIdentifierName(state, "column name")
    expectKind(state, token.TokenKind.Equal, "'='")
    assignments = assignments + [ast.Assignment(column, parseExpression(state, 0))]
    parsingAssignments = matchKind(state, token.TokenKind.Comma)
  end while
  return assignments
end function

/// Parses insert using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseInsert(state)
  expectKeyword(state, "INTO")
  tableName = parseObjectName(state, "table name")
  columns = []
  if checkKind(state, token.TokenKind.LeftParen) then columns = parseIdentifierList(state) end if
  rows = []
  sourceQuery = void
  if matchKeyword(state, "VALUES") then
    parsingRows = true
    while parsingRows
      expectKind(state, token.TokenKind.LeftParen, "'('")
      rowValues = [parseExpression(state, 0)]
      while matchKind(state, token.TokenKind.Comma)
        rowValues = rowValues + [parseExpression(state, 0)]
      end while
      expectKind(state, token.TokenKind.RightParen, "')'")
      rows = rows + [rowValues]
      parsingRows = matchKind(state, token.TokenKind.Comma)
    end while
  else
    expectKeyword(state, "SELECT")
    sourceQuery = parseSelect(state)
  end if

  conflictTarget = []
  conflictAction = ast.CONFLICT_NONE
  conflictAssignments = []
  conflictWhere = void
  if matchKeyword(state, "ON") then
    expectKeyword(state, "CONFLICT")
    if checkKind(state, token.TokenKind.LeftParen) then conflictTarget = parseIdentifierList(state) end if
    expectKeyword(state, "DO")
    if matchKeyword(state, "NOTHING") then
      conflictAction = ast.CONFLICT_DO_NOTHING
    else
      expectKeyword(state, "UPDATE")
      expectKeyword(state, "SET")
      conflictAction = ast.CONFLICT_DO_UPDATE
      conflictAssignments = parseAssignments(state)
      if matchKeyword(state, "WHERE") then conflictWhere = parseExpression(state, 0) end if
    end if
  end if
  return ast.InsertStatement(tableName, columns, rows, sourceQuery, conflictTarget, conflictAction, conflictAssignments, conflictWhere, parseReturning(state))
end function

/// Parses update using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseUpdate(state)
  tableName = parseObjectName(state, "table name")
  expectKeyword(state, "SET")
  assignments = parseAssignments(state)
  whereExpression = void
  if matchKeyword(state, "WHERE") then whereExpression = parseExpression(state, 0) end if
  return ast.UpdateStatement(tableName, assignments, whereExpression, parseReturning(state))
end function

/// Parses delete using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseDelete(state)
  expectKeyword(state, "FROM")
  tableName = parseObjectName(state, "table name")
  whereExpression = void
  if matchKeyword(state, "WHERE") then whereExpression = parseExpression(state, 0) end if
  return ast.DeleteStatement(tableName, whereExpression, parseReturning(state))
end function

/// Parses truncate using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseTruncate(state)
  ignoredTable = matchKeyword(state, "TABLE")
  tableName = parseObjectName(state, "table name")
  restartIdentity = true
  if matchKeyword(state, "RESTART") then
    expectKeyword(state, "IDENTITY")
    restartIdentity = true
  else if matchKeyword(state, "CONTINUE") then
    expectKeyword(state, "IDENTITY")
    restartIdentity = false
  end if
  return ast.TruncateStatement(tableName, restartIdentity)
end function

/// Parses show using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseShow(state)
  countOnly = false
  if matchKeyword(state, "COUNT") then
    expectKind(state, token.TokenKind.LeftParen, "'(' after COUNT")
    expectKind(state, token.TokenKind.Star, "'*' in SHOW COUNT(*)")
    expectKind(state, token.TokenKind.RightParen, "')' after COUNT(*)")
    countOnly = true
  end if
  if checkKeyword(state, "WARNINGS") or checkKeyword(state, "ERRORS") then
    node = routineNode("SHOW_" + advance(state).text, "")
    if countOnly then node.name = "COUNT" end if
    offset = 0
    count = -1
    if matchKeyword(state, "LIMIT") then
      if countOnly then return fail(state, "SHOW COUNT(*) does not allow LIMIT") end if
      count = parseIntegerValue(state, "diagnostic row count")
      if count < 0 then return fail(state, "diagnostic row count must not be negative") end if
      if matchKind(state, token.TokenKind.Comma) then
        offset = count
        count = parseIntegerValue(state, "diagnostic row count")
        if count < 0 then return fail(state, "diagnostic row count must not be negative") end if
      else if matchKeyword(state, "OFFSET") then
        offset = parseIntegerValue(state, "diagnostic offset")
        if offset < 0 then return fail(state, "diagnostic offset must not be negative") end if
      end if
    end if
    node.options = [offset, count]
    return node
  end if
  if countOnly then return fail(state, "SHOW COUNT(*) requires WARNINGS or ERRORS") end if
  if matchKeyword(state, "CREATE") then expectKeyword(state, "PROCEDURE"); return routineNode("SHOW_CREATE_PROCEDURE", parseObjectName(state, "procedure name")) end if
  if matchKeyword(state, "PROCEDURE") then
    expectKeyword(state, "STATUS")
    node = routineNode("SHOW_PROCEDURE_STATUS", "")
    if matchKeyword(state, "LIKE") then
      node.name = "LIKE"
      node.expressions = [parseExpression(state, 0)]
    else if matchKeyword(state, "WHERE") then
      node.name = "WHERE"
      node.expressions = [parseExpression(state, 0)]
    end if
    return node
  end if
  if matchKeyword(state, "TABLES") then return ast.ShowTablesStatement(1) end if
  if matchKeyword(state, "STATUS") then return ast.ShowStatusStatement(1) end if
  if matchKeyword(state, "PROCESSLIST") then return ast.ShowProcesslistStatement(1) end if
  if matchKeyword(state, "INDEXES") then
    if not matchKeyword(state, "FROM") then expectKeyword(state, "ON") end if
    return ast.ShowIndexesStatement(parseObjectName(state, "table name"))
  end if
  return fail(state, "expected TABLES, STATUS, PROCESSLIST, INDEXES, PROCEDURE, WARNINGS or ERRORS after SHOW")
end function

/// Parses describe using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseDescribe(state)
  return ast.DescribeTableStatement(parseObjectName(state, "table name"))
end function

/// Parses select item using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseSelectItem(state)
  expression = parseExpression(state, 0)
  alias = void
  if matchKeyword(state, "AS") then
    alias = parseIdentifierName(state, "select-item alias")
  else if isIdentifierToken(current(state)) then
    alias = parseIdentifierName(state, "select-item alias")
  end if
  return ast.SelectItem(expression, alias)
end function

/// Parses order item using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseOrderItem(state)
  expression = parseExpression(state, 0)
  descending = false
  if matchKeyword(state, "ASC") then
    descending = false
  else if matchKeyword(state, "DESC") then
    descending = true
  end if
  nullsFirst = false
  nullsSpecified = false
  if matchKeyword(state, "NULLS") then
    nullsSpecified = true
    if matchKeyword(state, "FIRST") then nullsFirst = true else expectKeyword(state, "LAST"); nullsFirst = false end if
  end if
  return ast.OrderItem(expression, descending, nullsFirst, nullsSpecified)
end function

/// Parses table alias using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseTableAlias(state)
  alias = void
  if matchKeyword(state, "AS") then
    alias = parseIdentifierName(state, "table alias")
  else if isIdentifierToken(current(state)) then
    alias = parseIdentifierName(state, "table alias")
  end if
  return alias
end function

/// Parses either a catalog/CTE name or a parenthesized SELECT source.
/// Derived tables are represented as private CTEs so the existing named-query
/// binder and executor retain one source abstraction; only the user alias is visible.
/// @param state Mutable state inspected or updated by the operation.
/// @param description description value consumed by this operation.
function parseTableSource(state, description)
  if matchKind(state, token.TokenKind.LeftParen) then
    query = void
    if matchKeyword(state, "WITH") then
      query = parseWithSelect(state)
    else
      expectKeyword(state, "SELECT")
      query = parseSelect(state)
    end if
    expectKind(state, token.TokenKind.RightParen, "')'")
    alias = parseTableAlias(state)
    if alias is void then return fail(state, "derived table requires an alias") end if
    state.derivedTableCount = state.derivedTableCount + 1
    internalName = "__minisql_derived_" + state.derivedTableCount
    return [internalName, alias, ast.CommonTableExpression(internalName, query, [], false)]
  end if
  tableName = parseObjectName(state, description)
  return [tableName, parseTableAlias(state), void]
end function

/// Parses join clause using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseJoinClause(state)
  joinType = ast.JOIN_INNER
  if matchKeyword(state, "INNER") then
    expectKeyword(state, "JOIN")
    joinType = ast.JOIN_INNER
  else if matchKeyword(state, "LEFT") then
    ignoredOuter = matchKeyword(state, "OUTER")
    expectKeyword(state, "JOIN")
    joinType = ast.JOIN_LEFT
  else if matchKeyword(state, "RIGHT") then
    ignoredOuter = matchKeyword(state, "OUTER")
    expectKeyword(state, "JOIN")
    joinType = ast.JOIN_RIGHT
  else if matchKeyword(state, "FULL") then
    ignoredOuter = matchKeyword(state, "OUTER")
    expectKeyword(state, "JOIN")
    joinType = ast.JOIN_FULL
  else if matchKeyword(state, "CROSS") then
    expectKeyword(state, "JOIN")
    joinType = ast.JOIN_CROSS
  else
    expectKeyword(state, "JOIN")
  end if
  source = parseTableSource(state, "joined table name")
  tableName = source[0]
  tableAlias = source[1]
  condition = void
  if joinType != ast.JOIN_CROSS then
    expectKeyword(state, "ON")
    condition = parseExpression(state, 0)
  end if
  return [ast.JoinClause(joinType, tableName, tableAlias, condition), source[2]]
end function

/// Implements starts join for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function startsJoin(state)
  return checkKeyword(state, "JOIN") or checkKeyword(state, "INNER") or checkKeyword(state, "LEFT") or checkKeyword(state, "RIGHT") or checkKeyword(state, "FULL") or checkKeyword(state, "CROSS")
end function

/// Parses select core using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseSelectCore(state)
  return parseSelectCoreTargets(state, false)[0]
end function

/// Parses the SELECT core and optional procedure INTO destinations.
function parseSelectCoreTargets(state, allowInto)
  distinct = matchKeyword(state, "DISTINCT")
  items = [parseSelectItem(state)]
  while matchKind(state, token.TokenKind.Comma)
    items = items + [parseSelectItem(state)]
  end while
  targets = []
  if allowInto and matchKeyword(state, "INTO") then targets = parseRoutineTargets(state) end if
  tableName = void
  tableAlias = void
  joins = []
  derivedTables = []
  if matchKeyword(state, "FROM") then
    source = parseTableSource(state, "table name")
    tableName = source[0]
    tableAlias = source[1]
    if source[2] is not void then derivedTables = derivedTables + [source[2]] end if
    parsingSources = true
    while parsingSources
      if matchKind(state, token.TokenKind.Comma) then
        // SQL's legacy comma-separated FROM list is a cartesian product. The
        // ordinary WHERE pipeline may subsequently restrict it to an equijoin.
        commaSource = parseTableSource(state, "table name after ','")
        joins = joins + [ast.JoinClause(ast.JOIN_CROSS, commaSource[0], commaSource[1], void)]
        if commaSource[2] is not void then derivedTables = derivedTables + [commaSource[2]] end if
      else if startsJoin(state) then
        parsedJoin = parseJoinClause(state)
        joins = joins + [parsedJoin[0]]
        if parsedJoin[1] is not void then derivedTables = derivedTables + [parsedJoin[1]] end if
      else
        parsingSources = false
      end if
    end while
  end if
  whereExpression = void
  if matchKeyword(state, "WHERE") then whereExpression = parseExpression(state, 0) end if
  groupBy = []
  if matchKeyword(state, "GROUP") then
    expectKeyword(state, "BY")
    groupBy = [parseExpression(state, 0)]
    while matchKind(state, token.TokenKind.Comma)
      groupBy = groupBy + [parseExpression(state, 0)]
    end while
  end if
  havingExpression = void
  if matchKeyword(state, "HAVING") then havingExpression = parseExpression(state, 0) end if
  return [ast.SelectStatement(distinct, items, tableName, tableAlias, joins, whereExpression, groupBy, havingExpression, [], [], -1, 0, derivedTables), targets]
end function

/// Parses select using the supplied inputs.
/// Returns the computed value or operation status.
/// May mutate supplied state as documented by the operation name.
/// @param state Mutable state inspected or updated by the operation.
function parseSelect(state)
  return parseSelectTargets(state, false)[0]
end function

/// Retains variable/parameter LIMIT operands for session-aware execution binding.
function parseSelectLimit(state, description)
  if checkKind(state, token.TokenKind.IntegerLiteral) or checkKind(state, token.TokenKind.Plus) or checkKind(state, token.TokenKind.Minus) then return parseIntegerValue(state, description) end if
  return parseExpression(state, 0)
end function

/// Parses a complete SELECT, retaining early or final INTO destinations.
function parseSelectTargets(state, allowInto)
  selected = parseSelectCoreTargets(state, allowInto)
  statement = selected[0]
  targets = selected[1]
  while checkKeyword(state, "UNION") or checkKeyword(state, "INTERSECT") or checkKeyword(state, "EXCEPT")
    operatorValue = ast.SET_UNION
    if matchKeyword(state, "UNION") then
      operatorValue = ast.SET_UNION
    else if matchKeyword(state, "INTERSECT") then
      operatorValue = ast.SET_INTERSECT
    else
      expectKeyword(state, "EXCEPT")
      operatorValue = ast.SET_EXCEPT
    end if
    all = matchKeyword(state, "ALL")
    expectKeyword(state, "SELECT")
    statement.setOperations = statement.setOperations + [ast.SetOperation(operatorValue, all, parseSelectCore(state))]
  end while
  orderBy = []
  if matchKeyword(state, "ORDER") then
    expectKeyword(state, "BY")
    orderBy = [parseOrderItem(state)]
    while matchKind(state, token.TokenKind.Comma)
      orderBy = orderBy + [parseOrderItem(state)]
    end while
  end if
  limit = -1
  offset = 0
  limitSpecified = false
  commaOffset = false
  if matchKeyword(state, "LIMIT") then
    limitSpecified = true
    limit = parseSelectLimit(state, "LIMIT")
    if matchKind(state, token.TokenKind.Comma) then
      commaOffset = true
      offset = limit
      limit = parseSelectLimit(state, "LIMIT count")
    end if
  end if
  if matchKeyword(state, "OFFSET") then
    if commaOffset then return fail(state, "LIMIT offset,count and OFFSET cannot be combined") end if
    offset = parseSelectLimit(state, "OFFSET")
    if checkKeyword(state, "ROW") or checkKeyword(state, "ROWS") then advance(state) end if
  end if
  if matchKeyword(state, "FETCH") then
    if limitSpecified then return fail(state, "LIMIT and FETCH cannot be combined") end if
    limitSpecified = true
    if not matchKeyword(state, "FIRST") then expectKeyword(state, "NEXT") end if
    limit = parseIntegerValue(state, "FETCH")
    if not matchKeyword(state, "ROW") then expectKeyword(state, "ROWS") end if
    expectKeyword(state, "ONLY")
  end if
  if (limitSpecified and typeof(limit) == "int" and limit < 0) or (typeof(offset) == "int" and offset < 0) then return fail(state, "LIMIT/OFFSET/FETCH must be non-negative") end if
  statement.orderBy = orderBy
  statement.limit = limit
  statement.offset = offset
  if allowInto and matchKeyword(state, "INTO") then
    if len(targets) > 0 then return fail(state, "SELECT has more than one INTO clause") end if
    targets = parseRoutineTargets(state)
  end if
  return [statement, targets]
end function

/// Parses with select using the supplied inputs.
/// Returns the computed value or operation status.
/// May mutate supplied state as documented by the operation name.
/// @param state Mutable state inspected or updated by the operation.
function parseWithSelect(state)
  return parseWithSelectTargets(state, false)[0]
end function

/// Retains INTO targets on the outer SELECT while CTE bodies remain queries.
function parseWithSelectTargets(state, allowInto)
  recursive = matchKeyword(state, "RECURSIVE")
  ctes = []
  parsing = true
  while parsing
    name = parseIdentifierName(state, "CTE name")
    columnNames = []
    if checkKind(state, token.TokenKind.LeftParen) then columnNames = parseIdentifierList(state) end if
    expectKeyword(state, "AS")
    expectKind(state, token.TokenKind.LeftParen, "'('")
    query = void
    if matchKeyword(state, "WITH") then
      query = parseWithSelect(state)
    else
      expectKeyword(state, "SELECT")
      query = parseSelect(state)
    end if
    expectKind(state, token.TokenKind.RightParen, "')'")
    ctes = ctes + [ast.CommonTableExpression(name, query, columnNames, recursive)]
    if not matchKind(state, token.TokenKind.Comma) then parsing = false end if
  end while
  expectKeyword(state, "SELECT")
  selected = parseSelectTargets(state, allowInto)
  statement = selected[0]
  statement.ctes = ctes + statement.ctes
  return [statement, selected[1]]
end function

/// Parses begin using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseBegin(state)
  ignoredTransaction = matchKeyword(state, "TRANSACTION")
  readOnly = false
  isolationLevel = "SERIALIZABLE"
  parsing = true
  while parsing
    if matchKeyword(state, "READ") then
      if matchKeyword(state, "ONLY") then readOnly = true else expectKeyword(state, "WRITE"); readOnly = false end if
    else if matchKeyword(state, "ISOLATION") then
      expectKeyword(state, "LEVEL")
      if matchKeyword(state, "SERIALIZABLE") then
        isolationLevel = "SERIALIZABLE"
      else if matchKeyword(state, "READ") then
        expectKeyword(state, "COMMITTED")
        isolationLevel = "READ COMMITTED"
      else
        return fail(state, "unsupported isolation level")
      end if
    else
      parsing = false
    end if
  end while
  return ast.BeginStatement(readOnly, isolationLevel)
end function

/// Parses the core SQL MERGE form with table source, matched update/delete, and insert.
/// @param state Mutable state inspected or updated by the operation.
function parseMerge(state)
  expectKeyword(state, "INTO")
  targetTable = parseObjectName(state, "MERGE target table")
  targetAlias = parseTableAlias(state)
  expectKeyword(state, "USING")
  sourceTable = parseObjectName(state, "MERGE source table")
  sourceAlias = parseTableAlias(state)
  expectKeyword(state, "ON")
  condition = parseExpression(state, 0)
  matchedAssignments = []
  matchedDelete = false
  insertColumns = []
  insertValues = []
  actionCount = 0
  while matchKeyword(state, "WHEN")
    if matchKeyword(state, "MATCHED") then
      expectKeyword(state, "THEN")
      if matchKeyword(state, "DELETE") then
        matchedDelete = true
      else
        expectKeyword(state, "UPDATE")
        expectKeyword(state, "SET")
        matchedAssignments = parseAssignments(state)
      end if
    else
      expectKeyword(state, "NOT")
      expectKeyword(state, "MATCHED")
      expectKeyword(state, "THEN")
      expectKeyword(state, "INSERT")
      if checkKind(state, token.TokenKind.LeftParen) then insertColumns = parseIdentifierList(state) end if
      expectKeyword(state, "VALUES")
      expectKind(state, token.TokenKind.LeftParen, "'('")
      if not checkKind(state, token.TokenKind.RightParen) then
        insertValues = [parseExpression(state, 0)]
        while matchKind(state, token.TokenKind.Comma)
          insertValues = insertValues + [parseExpression(state, 0)]
        end while
      end if
      expectKind(state, token.TokenKind.RightParen, "')'")
    end if
    actionCount = actionCount + 1
  end while
  if actionCount == 0 then return fail(state, "MERGE requires at least one WHEN action") end if
  if matchedDelete and len(matchedAssignments) > 0 then return fail(state, "MERGE cannot both UPDATE and DELETE matched rows") end if
  if len(insertValues) > 0 and len(insertColumns) > 0 and len(insertValues) != len(insertColumns) then return fail(state, "MERGE INSERT column/value count mismatch") end if
  return ast.MergeStatement(targetTable, targetAlias, sourceTable, sourceAlias, condition, matchedAssignments, matchedDelete, insertColumns, insertValues)
end function

/// Implements preparable statement for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param statement statement value consumed by this operation.
function preparableStatement(statement)
  if ast.isRoutineStatement(statement) then
    if statement.kind == "SHOW_CREATE_PROCEDURE" or statement.kind == "SHOW_PROCEDURE_STATUS" then return true end if
    if statement.kind != "SELECT_INTO" and statement.kind != "SET" then return false end if
    for each name in statement.names
      if len(bytes(name)) == 0 or bytes(name)[0] != 64 then return false end if
    end for
    return true
  end if
  if ast.isPrepareStatement(statement) or ast.isExecutePreparedStatement(statement) or ast.isDeallocateStatement(statement) then return false end if
  if ast.isCreateProcedureStatement(statement) or ast.isDropProcedureStatement(statement) then return false end if
  if ast.isCreateTriggerStatement(statement) or ast.isDropTriggerStatement(statement) or ast.isAlterTriggerStatement(statement) then return false end if
  if ast.isShutdownStatement(statement) then return false end if
  return ast.isStatement(statement)
end function

/// Parses prepare using the supplied inputs.
/// Returns the computed value or operation status.
/// May mutate supplied state as documented by the operation name.
/// @param state Mutable state inspected or updated by the operation.
function parsePrepare(state)
  name = parseIdentifierName(state, "prepared statement name")
  if matchKeyword(state, "FROM") then
    node = routineNode("PREPARE_DYNAMIC", name)
    if not checkKind(state, token.TokenKind.StringLiteral) and not checkKind(state, token.TokenKind.UserVariable) then return fail(state, "PREPARE FROM requires a string or session variable") end if
    node.expressions = [parseExpression(state, 0)]
    return node
  end if
  expectKeyword(state, "AS")
  // Parameter ordinals are local to one prepared statement. Preserve the outer
  // parser counter so several PREPARE statements in one SQL batch all start at 0.
  outerParameterCount = state.parameterCount
  state.parameterCount = 0
  statement = parseStatement(state)
  parameterCount = state.parameterCount
  state.parameterCount = outerParameterCount
  if not preparableStatement(statement) then return fail(state, "PREPARE requires one supported SQL statement, without procedural control flow or local targets") end if
  return ast.PrepareStatement(name, statement, parameterCount)
end function

/// Parses execute prepared using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseExecutePrepared(state)
  name = parseIdentifierName(state, "prepared statement name")
  arguments = []
  if matchKeyword(state, "USING") then
    arguments = [parseExpression(state, 0)]
    while matchKind(state, token.TokenKind.Comma)
      arguments = arguments + [parseExpression(state, 0)]
    end while
  end if
  return ast.ExecutePreparedStatement(name, arguments)
end function

/// Parses CALL with positional arguments, allowing omitted parentheses for zero arguments.
/// @param state Mutable state inspected or updated by the operation.
function parseCall(state)
  name = parseObjectName(state, "procedure name")
  arguments = []
  if not matchKind(state, token.TokenKind.LeftParen) then return ast.CallStatement(name, arguments) end if
  if not checkKind(state, token.TokenKind.RightParen) then
    arguments = [parseExpression(state, 0)]
    while matchKind(state, token.TokenKind.Comma)
      arguments = arguments + [parseExpression(state, 0)]
    end while
  end if
  expectKind(state, token.TokenKind.RightParen, "')'")
  return ast.CallStatement(name, arguments)
end function

/// Parses deallocate using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseDeallocate(state)
  ignoredPrepare = matchKeyword(state, "PREPARE")
  return ast.DeallocateStatement(parseIdentifierName(state, "prepared statement name"))
end function

/// Parses statement using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseStatement(state)
  if matchKeyword(state, "SET") then return parseRoutineSet(state) end if
  if matchKeyword(state, "SIGNAL") then return parseRoutineSignal(state, "SIGNAL") end if
  if matchKeyword(state, "RESIGNAL") then return parseRoutineSignal(state, "RESIGNAL") end if
  if matchKeyword(state, "GET") then return parseRoutineDiagnostics(state) end if
  if matchKeyword(state, "START") then expectKeyword(state, "TRANSACTION"); return parseBegin(state) end if
  if matchKeyword(state, "SHUTDOWN") then return ast.ShutdownStatement(1) end if
  if matchKeyword(state, "CALL") then return parseCall(state) end if
  if matchKeyword(state, "PREPARE") then return parsePrepare(state) end if
  if matchKeyword(state, "EXECUTE") then return parseExecutePrepared(state) end if
  if matchKeyword(state, "DEALLOCATE") then return parseDeallocate(state) end if
  if matchKeyword(state, "VACUUM") then
    tableName = void
    if isIdentifierToken(current(state)) then tableName = parseObjectName(state, "table name") end if
    return ast.VacuumStatement(tableName)
  end if
  if matchKeyword(state, "REINDEX") then
    name = void
    if isIdentifierToken(current(state)) then name = parseObjectName(state, "table or index name") end if
    return ast.ReindexStatement(name)
  end if
  if matchKeyword(state, "SHOW") then return parseShow(state) end if
  if matchKeyword(state, "DESCRIBE") then return parseDescribe(state) end if
  if matchKeyword(state, "CREATE") then return parseCreate(state) end if
  if matchKeyword(state, "ALTER") then return parseAlter(state) end if
  if matchKeyword(state, "DROP") then return parseDrop(state) end if
  if matchKeyword(state, "GRANT") then return parseGrant(state) end if
  if matchKeyword(state, "REVOKE") then return parseRevoke(state) end if
  if matchKeyword(state, "INSERT") then return parseInsert(state) end if
  if matchKeyword(state, "UPDATE") then return parseUpdate(state) end if
  if matchKeyword(state, "DELETE") then return parseDelete(state) end if
  if matchKeyword(state, "MERGE") then return parseMerge(state) end if
  if matchKeyword(state, "TRUNCATE") then return parseTruncate(state) end if
  if matchKeyword(state, "WITH") then return parseSelectTargetStatement(state, true) end if
  if matchKeyword(state, "SELECT") then return parseSelectTargetStatement(state, false) end if
  if matchKeyword(state, "BEGIN") then return parseBegin(state) end if
  if matchKeyword(state, "COMMIT") then ignored = matchKeyword(state, "TRANSACTION"); return ast.CommitStatement(true) end if
  if matchKeyword(state, "ROLLBACK") then
    ignoredTransaction = matchKeyword(state, "TRANSACTION")
    if matchKeyword(state, "TO") then
      ignoredSavepoint = matchKeyword(state, "SAVEPOINT")
      return ast.RollbackToStatement(parseIdentifierName(state, "savepoint name"))
    end if
    return ast.RollbackStatement(true)
  end if
  if matchKeyword(state, "SAVEPOINT") then return ast.SavepointStatement(parseIdentifierName(state, "savepoint name")) end if
  if matchKeyword(state, "RELEASE") then
    ignoredSavepoint = matchKeyword(state, "SAVEPOINT")
    return ast.ReleaseSavepointStatement(parseIdentifierName(state, "savepoint name"))
  end if
  if matchKeyword(state, "ANALYZE") then
    tableName = void
    if isIdentifierToken(current(state)) then tableName = parseObjectName(state, "table name") end if
    return ast.AnalyzeStatement(tableName)
  end if
  if matchKeyword(state, "EXPLAIN") then
    analyze = matchKeyword(state, "ANALYZE")
    return ast.ExplainStatement(analyze, parseStatement(state))
  end if
  return fail(state, "unsupported or missing SQL statement")
end function

/// Maps binary operators to increasing binding strength; zero means non-operator.
/// The table makes OR weakest and multiplicative operators strongest.
/// @param value Value consumed or transformed by the operation.
function operatorPrecedence(value)
  if token.isKeyword(value, "OR") then return 1 end if
  if token.isKeyword(value, "AND") then return 2 end if
  if value.kind == token.TokenKind.Equal or value.kind == token.TokenKind.NotEqual or value.kind == token.TokenKind.Less or value.kind == token.TokenKind.LessEqual or value.kind == token.TokenKind.Greater or value.kind == token.TokenKind.GreaterEqual then return 3 end if
  if value.kind == token.TokenKind.Concat then return 4 end if
  if value.kind == token.TokenKind.Plus or value.kind == token.TokenKind.Minus then return 5 end if
  if value.kind == token.TokenKind.Star or value.kind == token.TokenKind.Slash or value.kind == token.TokenKind.Percent then return 6 end if
  return 0
end function

/// Implements operator text for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
function operatorText(value)
  if value.kind == token.TokenKind.Keyword then return value.text end if
  return value.text
end function

/// Parses case expression using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseCaseExpression(state)
  expectKeyword(state, "CASE")
  operand = void
  if not checkKeyword(state, "WHEN") then operand = parseExpression(state, 0) end if
  branches = []
  while matchKeyword(state, "WHEN")
    condition = parseExpression(state, 0)
    if operand is not void then condition = ast.binaryExpression("=", operand, condition) end if
    expectKeyword(state, "THEN")
    result = parseExpression(state, 0)
    branches = branches + [ast.caseBranch(condition, result)]
  end while
  if len(branches) == 0 then return fail(state, "CASE requires at least one WHEN") end if
  elseExpression = void
  if matchKeyword(state, "ELSE") then elseExpression = parseExpression(state, 0) end if
  expectKeyword(state, "END")
  return ast.caseExpression(branches, elseExpression)
end function

/// Parses cast expression using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseCastExpression(state)
  expectKeyword(state, "CAST")
  expectKind(state, token.TokenKind.LeftParen, "'('")
  operand = parseExpression(state, 0)
  expectKeyword(state, "AS")
  targetType = parseTypeName(state)
  expectKind(state, token.TokenKind.RightParen, "')'")
  return ast.castExpression(operand, targetType)
end function

/// Parses primary using the supplied inputs.
/// Returns the computed value or operation status.
/// May mutate supplied state as documented by the operation name.
/// @param state Mutable state inspected or updated by the operation.
function parsePrimary(state)
  value = current(state)
  if matchKeyword(state, "EXISTS") then
    expectKind(state, token.TokenKind.LeftParen, "'('")
    query = void
    if matchKeyword(state, "WITH") then
      query = parseWithSelect(state)
    else
      expectKeyword(state, "SELECT")
      query = parseSelect(state)
    end if
    expectKind(state, token.TokenKind.RightParen, "')'")
    return ast.existsExpression(query)
  end if
  if checkKeyword(state, "CASE") then return parseCaseExpression(state) end if
  if checkKeyword(state, "CAST") then return parseCastExpression(state) end if
  if matchKind(state, token.TokenKind.Parameter) then
    index = state.parameterCount
    state.parameterCount = state.parameterCount + 1
    return ast.parameterExpression(index)
  end if
  if matchKind(state, token.TokenKind.UserVariable) then return ast.columnExpression(void, value.text) end if
  if matchKind(state, token.TokenKind.IntegerLiteral) then return ast.integerLiteral(value.value) end if
  if matchKind(state, token.TokenKind.FloatLiteral) then return ast.floatLiteral(value.value) end if
  if matchKind(state, token.TokenKind.StringLiteral) then return ast.stringLiteral(value.value) end if
  if matchKeyword(state, "NULL") then return ast.nullLiteral() end if
  if matchKeyword(state, "TRUE") then return ast.booleanLiteral(true) end if
  if matchKeyword(state, "FALSE") then return ast.booleanLiteral(false) end if
  if matchKeyword(state, "CURRENT_TIMESTAMP") then return ast.currentTimestampLiteral() end if
  if matchKind(state, token.TokenKind.Star) then return ast.starExpression(void) end if
  if matchKind(state, token.TokenKind.LeftParen) then
    if matchKeyword(state, "WITH") then
      query = parseWithSelect(state)
      expectKind(state, token.TokenKind.RightParen, "')'")
      return ast.subqueryExpression(query)
    end if
    if matchKeyword(state, "SELECT") then
      query = parseSelect(state)
      expectKind(state, token.TokenKind.RightParen, "')'")
      return ast.subqueryExpression(query)
    end if
    expression = parseExpression(state, 0)
    expectKind(state, token.TokenKind.RightParen, "')'")
    return expression
  end if
  if isTriggerRowQualifierToken(current(state)) and nextIsKind(state, token.TokenKind.Dot) then
    qualifierToken = advance(state)
    expectKind(state, token.TokenKind.Dot, "'.'")
    qualifier = dialect.canonicalIdentifier(qualifierToken.text, false)
    return ast.columnExpression(qualifier, parseIdentifierName(state, "trigger row column name"))
  end if
  if isFunctionNameToken(current(state)) and nextIsKind(state, token.TokenKind.LeftParen) then
    functionName = advance(state).text
    expectKind(state, token.TokenKind.LeftParen, "'('")
    distinct = matchKeyword(state, "DISTINCT")
    arguments = []
    if not checkKind(state, token.TokenKind.RightParen) then
      arguments = [parseExpression(state, 0)]
      while matchKind(state, token.TokenKind.Comma)
        arguments = arguments + [parseExpression(state, 0)]
      end while
    end if
    expectKind(state, token.TokenKind.RightParen, "')'")
    functionValue = ast.functionExpression(functionName, arguments, distinct)
    if matchKeyword(state, "OVER") then
      expectKind(state, token.TokenKind.LeftParen, "'('")
      partitionBy = []
      orderBy = []
      if matchKeyword(state, "PARTITION") then
        expectKeyword(state, "BY")
        partitionBy = [parseExpression(state, 0)]
        while matchKind(state, token.TokenKind.Comma)
          partitionBy = partitionBy + [parseExpression(state, 0)]
        end while
      end if
      if matchKeyword(state, "ORDER") then
        expectKeyword(state, "BY")
        orderBy = [parseOrderItem(state)]
        while matchKind(state, token.TokenKind.Comma)
          orderBy = orderBy + [parseOrderItem(state)]
        end while
      end if
      expectKind(state, token.TokenKind.RightParen, "')'")
      return ast.windowExpression(functionName, arguments, partitionBy, orderBy)
    end if
    return functionValue
  end if
  if isIdentifierToken(current(state)) then
    first = parseIdentifierName(state, "identifier")
    if matchKind(state, token.TokenKind.Dot) then
      if matchKind(state, token.TokenKind.Star) then return ast.starExpression(first) end if
      return ast.columnExpression(first, parseIdentifierName(state, "column name"))
    end if
    return ast.columnExpression(void, first)
  end if
  return fail(state, "expected expression")
end function

/// Parses predicate tail using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param expression expression value consumed by this operation.
function parsePredicateTail(state, expression)
  parsing = true
  while parsing
    if matchKeyword(state, "IS") then
      negated = matchKeyword(state, "NOT")
      if matchKeyword(state, "NULL") then
        expression = ast.isNullExpression(expression, negated)
      else if matchKeyword(state, "TRUE") then
        expression = ast.truthTestExpression(expression, "TRUE", negated)
      else if matchKeyword(state, "FALSE") then
        expression = ast.truthTestExpression(expression, "FALSE", negated)
      else
        expectKeyword(state, "UNKNOWN")
        expression = ast.truthTestExpression(expression, "UNKNOWN", negated)
      end if
    else
      negated = false
      if checkKeyword(state, "NOT") and (nextIsKeyword(state, "LIKE") or nextIsKeyword(state, "IN") or nextIsKeyword(state, "BETWEEN")) then
        advance(state)
        negated = true
      end if
      if matchKeyword(state, "LIKE") then
        right = parseExpression(state, 3)
        operatorValue = "LIKE"
        if negated then operatorValue = "NOT LIKE" end if
        expression = ast.binaryExpression(operatorValue, expression, right)
      else if matchKeyword(state, "IN") then
        expectKind(state, token.TokenKind.LeftParen, "'('")
        if matchKeyword(state, "WITH") then
          query = parseWithSelect(state)
          expectKind(state, token.TokenKind.RightParen, "')'")
          expression = ast.inSubqueryExpression(expression, query, negated)
        else if matchKeyword(state, "SELECT") then
          query = parseSelect(state)
          expectKind(state, token.TokenKind.RightParen, "')'")
          expression = ast.inSubqueryExpression(expression, query, negated)
        else
          candidates = [parseExpression(state, 0)]
          while matchKind(state, token.TokenKind.Comma)
            candidates = candidates + [parseExpression(state, 0)]
          end while
          expectKind(state, token.TokenKind.RightParen, "')'")
          expression = ast.inExpression(expression, candidates, negated)
        end if
      else if matchKeyword(state, "BETWEEN") then
        lower = parseExpression(state, 2)
        expectKeyword(state, "AND")
        upper = parseExpression(state, 2)
        expression = ast.betweenExpression(expression, lower, upper, negated)
      else
        if negated then return fail(state, "expected LIKE, IN or BETWEEN after NOT") end if
        parsing = false
      end if
    end if
  end while
  return expression
end function

/// Parses unary using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function parseUnary(state)
  if matchKeyword(state, "NOT") then return ast.unaryExpression("NOT", parseUnary(state)) end if
  if matchKind(state, token.TokenKind.Plus) then return ast.unaryExpression("+", parseUnary(state)) end if
  if matchKind(state, token.TokenKind.Minus) then return ast.unaryExpression("-", parseUnary(state)) end if
  return parsePredicateTail(state, parsePrimary(state))
end function

/// Parses a binary expression with precedence climbing and left associativity.
/// Unary/predicate parsing supplies the left operand; recursive calls consume only
/// operators stronger than `minimumPrecedence`. Advances `state` or returns syntax errors.
/// @param state Mutable state inspected or updated by the operation.
/// @param minimumPrecedence minimumPrecedence value consumed by this operation.
function parseExpression(state, minimumPrecedence)
  left = parseUnary(state)
  precedence = operatorPrecedence(current(state))
  while precedence > minimumPrecedence
    operatorToken = advance(state)
    right = parseExpression(state, precedence)
    left = ast.binaryExpression(operatorText(operatorToken), left, right)
    precedence = operatorPrecedence(current(state))
  end while
  return left
end function

/// Parses a complete token stream into ordered statement AST nodes.
/// Empty statements between semicolons are ignored; any other trailing token is a
/// syntax error. The input must be a non-empty array ending in EndOfInput.
/// @param tokens tokens value consumed by this operation.
function parseTokens(tokens)
  if typeof(tokens) != "array" or len(tokens) == 0 then return error(INVALID_ARGUMENT, "sql.parser.parseTokens: tokens must be a non-empty array") end if
  state = ParserState(tokens, 0, 0, 0)
  statements = []
  while not atEnd(state)
    while matchKind(state, token.TokenKind.Semicolon)
    end while
    if atEnd(state) then break end if
    statements = statements + [parseStatement(state)]
    if not atEnd(state) and not checkKind(state, token.TokenKind.Semicolon) then return fail(state, "expected ';' or end of input") end if
    while matchKind(state, token.TokenKind.Semicolon)
    end while
  end while
  if len(statements) == 0 then return error(SQL_SYNTAX, "sql.parser: SQL text contains no statement") end if
  return statements
end function

/// Parses SQL using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param source source value consumed by this operation.
function parseSql(source)
  return parseTokens(lexer.tokenizeSql(source))
end function

/// Parses expression text using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param source source value consumed by this operation.
function parseExpressionText(source)
  tokens = lexer.tokenizeSql(source)
  state = ParserState(tokens, 0, 0, 0)
  expression = parseExpression(state, 0)
  while matchKind(state, token.TokenKind.Semicolon)
  end while
  if not atEnd(state) then return fail(state, "unexpected token after expression") end if
  return expression
end function

/// Performs the componentName operation for the minisql sql parser module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "sql.parser"
end function

/// Performs the targetMilestone operation for the minisql sql parser module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M12"
end function

/// Returns whether implemented satisfies the condition required by the minisql sql parser module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
