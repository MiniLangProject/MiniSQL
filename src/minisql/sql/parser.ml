package minisql.sql.parser

import minisql.sql.ast as ast
import minisql.sql.dialect as dialect
import minisql.sql.lexer as lexer
import minisql.sql.token as token

const INVALID_ARGUMENT = 9001
const SQL_SYNTAX = 9019

struct ParserState
  tokens
  index
  parameterCount
  mysqlMode
  mysqlConflictUpdate
end struct

function fail(state, message)
  currentToken = state.tokens[state.index]
  return error(SQL_SYNTAX, "sql.parser at line " + currentToken.line + ", column " + currentToken.column + ": " + message + "; found " + token.describe(currentToken))
end function

function current(state)
  return state.tokens[state.index]
end function

function previous(state)
  if state.index <= 0 then return state.tokens[0] end if
  return state.tokens[state.index - 1]
end function

function atEnd(state)
  return current(state).kind == token.TokenKind.EndOfInput
end function

function advance(state)
  value = current(state)
  if not atEnd(state) then state.index = state.index + 1 end if
  return value
end function

function checkKind(state, kind)
  return current(state).kind == kind
end function

function checkKeyword(state, keyword)
  return token.isKeyword(current(state), keyword)
end function

function nextIsKind(state, kind)
  position = state.index + 1
  if position >= len(state.tokens) then return false end if
  return state.tokens[position].kind == kind
end function

function nextIsKeyword(state, keyword)
  position = state.index + 1
  if position >= len(state.tokens) then return false end if
  return token.isKeyword(state.tokens[position], keyword)
end function

function isIdentifierToken(value)
  if token.isKind(value, token.TokenKind.Identifier) then return true end if
  if not token.isKind(value, token.TokenKind.Keyword) then return false end if
  return dialect.isNonReservedIdentifierKeyword(value.text)
end function

function isFunctionNameToken(value)
  return isIdentifierToken(value) or token.isKeyword(value, "COALESCE") or token.isKeyword(value, "IFNULL") or token.isKeyword(value, "NOW") or token.isKeyword(value, "NULLIF") or token.isKeyword(value, "ROW_NUMBER") or token.isKeyword(value, "RANK") or token.isKeyword(value, "DENSE_RANK") or token.isKeyword(value, "NEXTVAL") or token.isKeyword(value, "CURRVAL")
end function

// OLD and NEW are reserved pseudo-row qualifiers, not general identifiers.
// The parser accepts them only in the qualified form OLD.column / NEW.column.
// Trigger execution replaces those qualified column expressions with typed row
// literals before the body is bound and executed.
function isTriggerRowQualifierToken(value)
  return token.isKeyword(value, "OLD") or token.isKeyword(value, "NEW")
end function

function matchKind(state, kind)
  if not checkKind(state, kind) then return false end if
  advance(state)
  return true
end function

function matchKeyword(state, keyword)
  if not checkKeyword(state, keyword) then return false end if
  advance(state)
  return true
end function

function expectKind(state, kind, description)
  if not checkKind(state, kind) then return fail(state, "expected " + description) end if
  return advance(state)
end function

function expectKeyword(state, keyword)
  if not checkKeyword(state, keyword) then return fail(state, "expected keyword " + keyword) end if
  return advance(state)
end function

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

function parseIdentifierName(state, description)
  return parseIdentifier(state, description).name
end function

function parseQualifiedIdentifierName(state, description)
  name = parseIdentifierName(state, description)
  if state.mysqlMode and matchKind(state, token.TokenKind.Dot) then
    name = parseIdentifierName(state, description)
    if matchKind(state, token.TokenKind.Dot) then name = parseIdentifierName(state, description) end if
  end if
  return name
end function

function parsePrincipalName(state, description)
  if matchKeyword(state, "PUBLIC") then return "public" end if
  return parseIdentifierName(state, description)
end function

function parsePasswordLiteral(state)
  value = expectKind(state, token.TokenKind.StringLiteral, "password string literal")
  return value.value
end function

function parseIdentifierList(state)
  expectKind(state, token.TokenKind.LeftParen, "'('")
  result = [parseIdentifierName(state, "column name")]
  while matchKind(state, token.TokenKind.Comma)
    result = result + [parseIdentifierName(state, "column name")]
  end while
  expectKind(state, token.TokenKind.RightParen, "')'")
  return result
end function

function parseIntegerValue(state, description)
  sign = ""
  if matchKind(state, token.TokenKind.Plus) then sign = "+" else if matchKind(state, token.TokenKind.Minus) then sign = "-" end if
  value = expectKind(state, token.TokenKind.IntegerLiteral, description)
  parsed = toNumber(sign + value.text)
  if parsed is void or typeof(parsed) != "int" then return fail(state, description + " must fit the native MiniLang integer range") end if
  return parsed
end function

function parseTypeName(state)
  currentToken = current(state)
  if currentToken.kind != token.TokenKind.Keyword and currentToken.kind != token.TokenKind.Identifier then return fail(state, "expected SQL data type") end if
  advance(state)
  name = currentToken.text
  if currentToken.kind == token.TokenKind.Identifier then name = currentToken.text end if
  if state.mysqlMode and name == "CHARACTER" and matchKeyword(state, "VARYING") then name = "VARCHAR" end if
  if name == "DOUBLE" and matchKeyword(state, "PRECISION") then name = "DOUBLE PRECISION" end if
  length = 0
  precision = 0
  scale = 0
  if state.mysqlMode and (name == "ENUM" or name == "SET") and matchKind(state, token.TokenKind.LeftParen) then
    expectKind(state, token.TokenKind.StringLiteral, "type label")
    while matchKind(state, token.TokenKind.Comma)
      expectKind(state, token.TokenKind.StringLiteral, "type label")
    end while
    expectKind(state, token.TokenKind.RightParen, "')'")
  else if matchKind(state, token.TokenKind.LeftParen) then
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
  if state.mysqlMode then
    parsingAttributes = true
    while parsingAttributes
      if matchKeyword(state, "UNSIGNED") then
        ignoredUnsigned = true
      else if matchKeyword(state, "SIGNED") then
        ignoredSigned = true
      else if matchKeyword(state, "ZEROFILL") then
        ignoredZerofill = true
      else
        parsingAttributes = false
      end if
    end while
  end if
  return ast.typeName(name, length, precision, scale)
end function

function parseReferentialAction(state)
  if matchKeyword(state, "RESTRICT") then return "RESTRICT" end if
  if matchKeyword(state, "CASCADE") then return "CASCADE" end if
  if matchKeyword(state, "NO") then expectKeyword(state, "ACTION"); return "NO ACTION" end if
  if matchKeyword(state, "SET") then expectKeyword(state, "NULL"); return "SET NULL" end if
  return fail(state, "expected referential action")
end function

function parseIndexColumnList(state)
  expectKind(state, token.TokenKind.LeftParen, "'('")
  result = [parseIdentifierName(state, "index column name")]
  if state.mysqlMode and matchKind(state, token.TokenKind.LeftParen) then
    ignoredPrefixLength = parseIntegerValue(state, "index prefix length")
    expectKind(state, token.TokenKind.RightParen, "')'")
  end if
  if state.mysqlMode and (matchKeyword(state, "ASC") or matchKeyword(state, "DESC")) then ignoredDirection = true end if
  while matchKind(state, token.TokenKind.Comma)
    result = result + [parseIdentifierName(state, "index column name")]
    if state.mysqlMode and matchKind(state, token.TokenKind.LeftParen) then
      ignoredPrefixLength = parseIntegerValue(state, "index prefix length")
      expectKind(state, token.TokenKind.RightParen, "')'")
    end if
    if state.mysqlMode and (matchKeyword(state, "ASC") or matchKeyword(state, "DESC")) then ignoredDirection = true end if
  end while
  expectKind(state, token.TokenKind.RightParen, "')'")
  return result
end function

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
      if state.mysqlMode then ignoredKey = matchKeyword(state, "KEY") end if
    else if matchKeyword(state, "DEFAULT") then
      defaultExpression = parseExpression(state, 0)
    else if matchKeyword(state, "CHECK") then
      expectKind(state, token.TokenKind.LeftParen, "'('")
      checkExpression = parseExpression(state, 0)
      expectKind(state, token.TokenKind.RightParen, "')'")
    else if matchKeyword(state, "REFERENCES") then
      referencesTable = parseIdentifierName(state, "referenced table")
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
        if matchKeyword(state, "STORED") then
          generatedStored = true
        else if state.mysqlMode and matchKeyword(state, "VIRTUAL") then
          generatedStored = false
        else if state.mysqlMode then
          generatedStored = false
        else
          expectKeyword(state, "STORED")
        end if
      end if
    else if matchKeyword(state, "AUTO_INCREMENT") then
      identity = true
      nullable = false
      nullableSpecified = true
    else if matchKeyword(state, "AUTOINCREMENT") then
      identity = true
      nullable = false
      nullableSpecified = true
    else if state.mysqlMode and matchKeyword(state, "COMMENT") then
      expectKind(state, token.TokenKind.StringLiteral, "column comment")
    else if state.mysqlMode and matchKeyword(state, "COLLATE") then
      ignoredCollation = parseIdentifierName(state, "collation name")
    else if state.mysqlMode and matchKeyword(state, "CHARACTER") then
      expectKeyword(state, "SET")
      ignoredCharacterSet = parseIdentifierName(state, "character set name")
    else if state.mysqlMode and matchKeyword(state, "ON") then
      expectKeyword(state, "UPDATE")
      ignoredOnUpdate = parseExpression(state, 0)
    else if state.mysqlMode and (matchKeyword(state, "VISIBLE") or matchKeyword(state, "INVISIBLE")) then
      ignoredVisibility = true
    else if state.mysqlMode and matchKeyword(state, "COLUMN_FORMAT") then
      ignoredColumnFormat = parseIdentifierName(state, "column format")
    else if state.mysqlMode and matchKeyword(state, "STORAGE") then
      ignoredStorage = parseIdentifierName(state, "storage kind")
    else
      parsing = false
    end if
  end while
  return ast.ColumnDefinition(name, dataType, nullable, nullableSpecified, primaryKey, unique, defaultExpression, checkExpression, referencesTable, referencesColumns, onDelete, onUpdate, identity, generatedExpression, generatedStored)
end function

function parseTableConstraint(state)
  name = void
  if matchKeyword(state, "CONSTRAINT") then name = parseIdentifierName(state, "constraint name") end if
  if matchKeyword(state, "PRIMARY") then
    expectKeyword(state, "KEY")
    if state.mysqlMode then return ast.TableConstraint(ast.CONSTRAINT_PRIMARY_KEY, name, parseIndexColumnList(state), void, void, [], "NO ACTION", "NO ACTION") end if
    return ast.TableConstraint(ast.CONSTRAINT_PRIMARY_KEY, name, parseIdentifierList(state), void, void, [], "NO ACTION", "NO ACTION")
  end if
  if matchKeyword(state, "UNIQUE") then
    if state.mysqlMode then
      ignoredKey = matchKeyword(state, "KEY")
      if not ignoredKey then ignoredIndex = matchKeyword(state, "INDEX") end if
      inlineName = name
      if not checkKind(state, token.TokenKind.LeftParen) then inlineName = parseIdentifierName(state, "index name") end if
      return ast.TableConstraint(ast.CONSTRAINT_UNIQUE, inlineName, parseIndexColumnList(state), void, void, [], "NO ACTION", "NO ACTION")
    end if
    return ast.TableConstraint(ast.CONSTRAINT_UNIQUE, name, parseIdentifierList(state), void, void, [], "NO ACTION", "NO ACTION")
  end if
  if state.mysqlMode and (matchKeyword(state, "KEY") or matchKeyword(state, "INDEX")) then
    inlineName = name
    if not checkKind(state, token.TokenKind.LeftParen) then inlineName = parseIdentifierName(state, "index name") end if
    return ast.TableConstraint(ast.CONSTRAINT_INDEX, inlineName, parseIndexColumnList(state), void, void, [], "NO ACTION", "NO ACTION")
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
    referenceTable = parseIdentifierName(state, "referenced table")
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

function startsTableConstraint(state)
  if checkKeyword(state, "CONSTRAINT") or checkKeyword(state, "PRIMARY") or checkKeyword(state, "UNIQUE") or checkKeyword(state, "CHECK") or checkKeyword(state, "FOREIGN") then return true end if
  return state.mysqlMode and (checkKeyword(state, "KEY") or checkKeyword(state, "INDEX"))
end function

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

function parseMySqlColumnPosition(state)
  if not state.mysqlMode then return true end if
  if matchKeyword(state, "FIRST") then return true end if
  if matchKeyword(state, "AFTER") then
    ignoredColumnName = parseIdentifierName(state, "column position")
    return true
  end if
  return true
end function

function parseAlterTable(state)
  tableName = parseQualifiedIdentifierName(state, "table name")
  if matchKeyword(state, "ADD") then
    ignoredColumn = matchKeyword(state, "COLUMN")
    if startsTableConstraint(state) then
      return ast.AlterTableStatement(tableName, ast.ALTER_TABLE_ADD_CONSTRAINT, void, void, void, parseTableConstraint(state), void)
    end if
    definition = parseColumnDefinition(state)
    parseMySqlColumnPosition(state)
    return ast.AlterTableStatement(tableName, ast.ALTER_TABLE_ADD_COLUMN, definition, void, void, void, void)
  end if
  if state.mysqlMode and (matchKeyword(state, "MODIFY") or matchKeyword(state, "CHANGE")) then return fail(state, "ALTER TABLE column rewrites are not supported by the mysql84 dialect") end if
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
    if state.mysqlMode and matchKeyword(state, "COLUMN") then return fail(state, "ALTER TABLE DROP COLUMN requires a table rewrite and is not supported by the mysql84 dialect") end if
    if state.mysqlMode and (matchKeyword(state, "INDEX") or matchKeyword(state, "KEY")) then
      return ast.AlterTableStatement(tableName, ast.ALTER_TABLE_DROP_CONSTRAINT, void, void, void, void, parseIdentifierName(state, "index name"))
    end if
    expectKeyword(state, "CONSTRAINT")
    return ast.AlterTableStatement(tableName, ast.ALTER_TABLE_DROP_CONSTRAINT, void, void, void, void, parseIdentifierName(state, "constraint name"))
  end if
  return fail(state, "expected ADD, RENAME or DROP after ALTER TABLE")
end function

function parseAlter(state)
  if matchKeyword(state, "TABLE") then return parseAlterTable(state) end if
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

function privilegeName(state)
  value = current(state)
  if value.kind != token.TokenKind.Keyword then return fail(state, "expected privilege name") end if
  allowed = value.text == "CONNECT" or value.text == "CREATE" or value.text == "MAINTAIN" or value.text == "ADMIN" or value.text == "SELECT" or value.text == "INSERT" or value.text == "UPDATE" or value.text == "DELETE" or value.text == "REFERENCES" or value.text == "INDEX" or value.text == "ALTER" or value.text == "DROP"
  if not allowed then return fail(state, "unsupported privilege " + value.text) end if
  advance(state)
  return value.text
end function

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
  else
    ignoredTable = matchKeyword(state, "TABLE")
    objectName = parseIdentifierName(state, "table name")
  end if
  expectKeyword(state, "TO")
  granteeName = parsePrincipalName(state, "grantee name")
  grantOption = false
  if matchKeyword(state, "WITH") then expectKeyword(state, "GRANT"); expectKeyword(state, "OPTION"); grantOption = true end if
  return ast.GrantPrivilegeStatement(privileges, objectType, objectName, granteeName, grantOption)
end function

function parseRevokeBehavior(state)
  cascade = false
  if matchKeyword(state, "CASCADE") then return true end if
  if matchKeyword(state, "RESTRICT") then return false end if
  return cascade
end function

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
  else
    ignoredTable = matchKeyword(state, "TABLE")
    objectName = parseIdentifierName(state, "table name")
  end if
  expectKeyword(state, "FROM")
  granteeName = parsePrincipalName(state, "grantee name")
  cascade = parseRevokeBehavior(state)
  return ast.RevokePrivilegeStatement(privileges, objectType, objectName, granteeName, cascade)
end function

function consumeMySqlOptionAtom(state, description)
  if checkKind(state, token.TokenKind.StringLiteral) or checkKind(state, token.TokenKind.IntegerLiteral) or checkKind(state, token.TokenKind.FloatLiteral) or isIdentifierToken(current(state)) then
    advance(state)
    return true
  end if
  return fail(state, "expected " + description)
end function

function consumeMySqlOptionValue(state)
  if matchKind(state, token.TokenKind.LeftParen) then
    depth = 1
    while depth > 0
      if atEnd(state) then return fail(state, "unterminated table option") end if
      if matchKind(state, token.TokenKind.LeftParen) then
        depth = depth + 1
      else if matchKind(state, token.TokenKind.RightParen) then
        depth = depth - 1
      else
        advance(state)
      end if
    end while
    return true
  end if
  return consumeMySqlOptionAtom(state, "table option value")
end function

function consumeMySqlNamedOption(state)
  if matchKind(state, token.TokenKind.Equal) then return consumeMySqlOptionValue(state) end if
  if not checkKind(state, token.TokenKind.Semicolon) and not atEnd(state) then return consumeMySqlOptionValue(state) end if
  return true
end function

function parseMySqlTableOptions(state)
  if not state.mysqlMode then return true end if
  while not atEnd(state) and not checkKind(state, token.TokenKind.Semicolon)
    ignoredComma = matchKind(state, token.TokenKind.Comma)
    if matchKeyword(state, "DEFAULT") then
      if matchKeyword(state, "CHARACTER") then
        expectKeyword(state, "SET")
        consumeMySqlNamedOption(state)
      else if matchKeyword(state, "CHARSET") then
        consumeMySqlNamedOption(state)
      else if matchKeyword(state, "COLLATE") then
        consumeMySqlNamedOption(state)
      else
        consumeMySqlNamedOption(state)
      end if
    else if matchKeyword(state, "CHARACTER") then
      expectKeyword(state, "SET")
      consumeMySqlNamedOption(state)
    else if matchKeyword(state, "ENGINE") or matchKeyword(state, "CHARSET") or matchKeyword(state, "COLLATE") or matchKeyword(state, "COMMENT") or matchKeyword(state, "AUTO_INCREMENT") or matchKeyword(state, "ROW_FORMAT") then
      consumeMySqlNamedOption(state)
    else
      if not isIdentifierToken(current(state)) then return fail(state, "unsupported MySQL table option") end if
      advance(state)
      consumeMySqlNamedOption(state)
    end if
  end while
  return true
end function

function parseCreateTable(state)
  ifNotExists = false
  if matchKeyword(state, "IF") then expectKeyword(state, "NOT"); expectKeyword(state, "EXISTS"); ifNotExists = true end if
  name = parseQualifiedIdentifierName(state, "table name")
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
  parseMySqlTableOptions(state)
  return ast.CreateTableStatement(name, columns, constraints, ifNotExists)
end function

function parseCreateIndex(state, unique)
  ifNotExists = false
  if matchKeyword(state, "IF") then expectKeyword(state, "NOT"); expectKeyword(state, "EXISTS"); ifNotExists = true end if
  name = parseIdentifierName(state, "index name")
  expectKeyword(state, "ON")
  tableName = parseQualifiedIdentifierName(state, "table name")
  columns = parseIndexColumnList(state)
  return ast.CreateIndexStatement(name, tableName, columns, unique, ifNotExists)
end function

function parseCreateView(state, replace)
  name = parseQualifiedIdentifierName(state, "view name")
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

function parseCreateSequence(state)
  ifNotExists = false
  if matchKeyword(state, "IF") then expectKeyword(state, "NOT"); expectKeyword(state, "EXISTS"); ifNotExists = true end if
  name = parseIdentifierName(state, "sequence name")
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

function parseCreateTrigger(state)
  ifNotExists = false
  if matchKeyword(state, "IF") then expectKeyword(state, "NOT"); expectKeyword(state, "EXISTS"); ifNotExists = true end if
  name = parseIdentifierName(state, "trigger name")
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
  tableName = parseIdentifierName(state, "trigger table")
  if matchKeyword(state, "FOR") then expectKeyword(state, "EACH"); expectKeyword(state, "ROW") end if
  body = parseStatement(state)
  if not (ast.isInsertStatement(body) or ast.isUpdateStatement(body) or ast.isDeleteStatement(body)) then return fail(state, "trigger body must be one INSERT, UPDATE or DELETE statement") end if
  return ast.CreateTriggerStatement(name, timing, eventType, tableName, targetColumn, body, ifNotExists)
end function

function parseCreate(state)
  if matchKeyword(state, "USER") then return parseCreatePrincipal(state, ast.PRINCIPAL_USER) end if
  if matchKeyword(state, "ROLE") then return parseCreatePrincipal(state, ast.PRINCIPAL_ROLE) end if
  if matchKeyword(state, "TABLE") then return parseCreateTable(state) end if
  if matchKeyword(state, "VIEW") then return parseCreateView(state, false) end if
  if matchKeyword(state, "OR") then expectKeyword(state, "REPLACE"); expectKeyword(state, "VIEW"); return parseCreateView(state, true) end if
  if matchKeyword(state, "SEQUENCE") then return parseCreateSequence(state) end if
  if matchKeyword(state, "TRIGGER") then return parseCreateTrigger(state) end if
  unique = matchKeyword(state, "UNIQUE")
  if matchKeyword(state, "INDEX") then return parseCreateIndex(state, unique) end if
  return fail(state, "expected USER, ROLE, TABLE, VIEW, SEQUENCE, TRIGGER or INDEX after CREATE")
end function

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
    if state.mysqlMode and matchKeyword(state, "IF") then expectKeyword(state, "EXISTS"); ifExists = true end if
    name = parseIdentifierName(state, "index name")
    expectKeyword(state, "ON")
    tableName = parseQualifiedIdentifierName(state, "table name")
    if state.mysqlMode then
      if matchKeyword(state, "ALGORITHM") then consumeMySqlNamedOption(state) end if
      if matchKeyword(state, "LOCK") then consumeMySqlNamedOption(state) end if
    end if
    return ast.DropIndexStatement(name, tableName, ifExists)
  end if
  objectKind = "TABLE"
  if matchKeyword(state, "VIEW") then objectKind = "VIEW" else if matchKeyword(state, "SEQUENCE") then objectKind = "SEQUENCE" else if matchKeyword(state, "TRIGGER") then objectKind = "TRIGGER" else expectKeyword(state, "TABLE") end if
  ifExists = false
  if matchKeyword(state, "IF") then expectKeyword(state, "EXISTS"); ifExists = true end if
  name = parseQualifiedIdentifierName(state, "object name")
  if objectKind == "VIEW" then return ast.DropViewStatement(name, ifExists) end if
  if objectKind == "SEQUENCE" then return ast.DropSequenceStatement(name, ifExists) end if
  if objectKind == "TRIGGER" then return ast.DropTriggerStatement(name, ifExists) end if
  return ast.DropTableStatement(name, ifExists)
end function

function parseReturning(state)
  items = []
  if not matchKeyword(state, "RETURNING") then return items end if
  items = [parseSelectItem(state)]
  while matchKind(state, token.TokenKind.Comma)
    items = items + [parseSelectItem(state)]
  end while
  return items
end function

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

function parseMySqlPriorityModifiers(state)
  if not state.mysqlMode then return true end if
  parsing = true
  while parsing
    if matchKeyword(state, "LOW_PRIORITY") then
      ignoredLowPriority = true
    else if matchKeyword(state, "HIGH_PRIORITY") then
      ignoredHighPriority = true
    else if matchKeyword(state, "DELAYED") then
      ignoredDelayed = true
    else
      parsing = false
    end if
  end while
  return true
end function

function parseMySqlDeleteModifiers(state)
  if not state.mysqlMode then return false end if
  ignored = false
  parsing = true
  while parsing
    if matchKeyword(state, "LOW_PRIORITY") then
      ignored = true
    else if matchKeyword(state, "QUICK") then
      ignored = true
    else if matchKeyword(state, "IGNORE") then
      ignored = true
    else
      parsing = false
    end if
  end while
  return ignored
end function

function parseInsert(state)
  parseMySqlPriorityModifiers(state)
  insertIgnore = false
  if state.mysqlMode and matchKeyword(state, "IGNORE") then insertIgnore = true end if
  expectKeyword(state, "INTO")
  tableName = parseQualifiedIdentifierName(state, "table name")
  columns = []
  if checkKind(state, token.TokenKind.LeftParen) then columns = parseIdentifierList(state) end if
  rows = []
  sourceQuery = void
  if state.mysqlMode and matchKeyword(state, "SET") then
    if len(columns) > 0 then return fail(state, "INSERT SET cannot also specify a column list") end if
    assignments = parseAssignments(state)
    rowValues = []
    for each assignment in assignments
      columns = columns + [assignment.column]
      rowValues = rowValues + [assignment.expression]
    end for
    rows = [rowValues]
  else if matchKeyword(state, "VALUES") or (state.mysqlMode and matchKeyword(state, "VALUE")) then
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
  mysqlDuplicateKeyUpdate = false
  if matchKeyword(state, "ON") then
    if state.mysqlMode and matchKeyword(state, "DUPLICATE") then
      expectKeyword(state, "KEY")
      expectKeyword(state, "UPDATE")
      conflictAction = ast.CONFLICT_DO_UPDATE
      mysqlDuplicateKeyUpdate = true
      state.mysqlConflictUpdate = true
      conflictAssignments = parseAssignments(state)
      state.mysqlConflictUpdate = false
    else
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
  end if
  if insertIgnore and conflictAction == ast.CONFLICT_NONE then conflictAction = ast.CONFLICT_DO_NOTHING end if
  return ast.InsertStatement(tableName, columns, rows, sourceQuery, conflictTarget, conflictAction, conflictAssignments, conflictWhere, parseReturning(state), mysqlDuplicateKeyUpdate)
end function

function parseUpdate(state)
  parseMySqlPriorityModifiers(state)
  ignoredUpdateIgnore = false
  if state.mysqlMode and matchKeyword(state, "IGNORE") then ignoredUpdateIgnore = true end if
  tableName = parseQualifiedIdentifierName(state, "table name")
  expectKeyword(state, "SET")
  assignments = parseAssignments(state)
  whereExpression = void
  if matchKeyword(state, "WHERE") then whereExpression = parseExpression(state, 0) end if
  orderBy = []
  limit = -1
  if state.mysqlMode and matchKeyword(state, "ORDER") then
    expectKeyword(state, "BY")
    orderBy = [parseOrderItem(state)]
    while matchKind(state, token.TokenKind.Comma)
      orderBy = orderBy + [parseOrderItem(state)]
    end while
  end if
  if state.mysqlMode and matchKeyword(state, "LIMIT") then limit = parseIntegerValue(state, "LIMIT") end if
  return ast.UpdateStatement(tableName, assignments, whereExpression, orderBy, limit, parseReturning(state))
end function

function parseDelete(state)
  parseMySqlDeleteModifiers(state)
  expectKeyword(state, "FROM")
  tableName = parseQualifiedIdentifierName(state, "table name")
  whereExpression = void
  if matchKeyword(state, "WHERE") then whereExpression = parseExpression(state, 0) end if
  orderBy = []
  limit = -1
  if state.mysqlMode and matchKeyword(state, "ORDER") then
    expectKeyword(state, "BY")
    orderBy = [parseOrderItem(state)]
    while matchKind(state, token.TokenKind.Comma)
      orderBy = orderBy + [parseOrderItem(state)]
    end while
  end if
  if state.mysqlMode and matchKeyword(state, "LIMIT") then limit = parseIntegerValue(state, "LIMIT") end if
  return ast.DeleteStatement(tableName, whereExpression, orderBy, limit, parseReturning(state))
end function

function parseTruncate(state)
  ignoredTable = matchKeyword(state, "TABLE")
  tableName = parseQualifiedIdentifierName(state, "table name")
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

function parseShow(state)
  if matchKeyword(state, "TABLES") then return ast.ShowTablesStatement(1) end if
  if matchKeyword(state, "INDEXES") then
    if not matchKeyword(state, "FROM") then expectKeyword(state, "ON") end if
    return ast.ShowIndexesStatement(parseQualifiedIdentifierName(state, "table name"))
  end if
  return fail(state, "expected TABLES or INDEXES after SHOW")
end function

function parseDescribe(state)
  return ast.DescribeTableStatement(parseQualifiedIdentifierName(state, "table name"))
end function

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

function parseTableAlias(state)
  alias = void
  if matchKeyword(state, "AS") then
    alias = parseIdentifierName(state, "table alias")
  else if isIdentifierToken(current(state)) then
    alias = parseIdentifierName(state, "table alias")
  end if
  return alias
end function

function visibleSourceName(tableName, alias)
  if alias is not void then return alias end if
  return tableName
end function

function usingCondition(leftName, rightName, columns)
  condition = void
  for each columnName in columns
    comparison = ast.binaryExpression("=", ast.columnExpression(leftName, columnName), ast.columnExpression(rightName, columnName))
    if condition is void then condition = comparison else condition = ast.binaryExpression("AND", condition, comparison) end if
  end for
  return condition
end function

function parseJoinClause(state, leftName)
  joinType = ast.JOIN_INNER
  if state.mysqlMode and matchKeyword(state, "NATURAL") then return fail(state, "NATURAL JOIN is not supported by the mysql84 dialect") end if
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
    if state.mysqlMode then return fail(state, "FULL OUTER JOIN is not supported by the mysql84 dialect") end if
    ignoredOuter = matchKeyword(state, "OUTER")
    expectKeyword(state, "JOIN")
    joinType = ast.JOIN_FULL
  else if matchKeyword(state, "CROSS") then
    expectKeyword(state, "JOIN")
    joinType = ast.JOIN_CROSS
  else
    expectKeyword(state, "JOIN")
  end if
  tableName = parseQualifiedIdentifierName(state, "joined table name")
  tableAlias = parseTableAlias(state)
  condition = void
  if joinType != ast.JOIN_CROSS then
    if state.mysqlMode and matchKeyword(state, "USING") then
      condition = usingCondition(leftName, visibleSourceName(tableName, tableAlias), parseIdentifierList(state))
    else
      expectKeyword(state, "ON")
      condition = parseExpression(state, 0)
    end if
  end if
  return ast.JoinClause(joinType, tableName, tableAlias, condition)
end function

function startsJoin(state)
  return checkKeyword(state, "JOIN") or checkKeyword(state, "INNER") or checkKeyword(state, "LEFT") or checkKeyword(state, "RIGHT") or checkKeyword(state, "FULL") or checkKeyword(state, "CROSS") or (state.mysqlMode and checkKeyword(state, "NATURAL"))
end function

function parseSelectCore(state)
  distinct = matchKeyword(state, "DISTINCT")
  items = [parseSelectItem(state)]
  while matchKind(state, token.TokenKind.Comma)
    items = items + [parseSelectItem(state)]
  end while
  tableName = void
  tableAlias = void
  joins = []
  if matchKeyword(state, "FROM") then
    tableName = parseQualifiedIdentifierName(state, "table name")
    tableAlias = parseTableAlias(state)
    leftName = visibleSourceName(tableName, tableAlias)
    while startsJoin(state)
      joinClause = parseJoinClause(state, leftName)
      joins = joins + [joinClause]
      leftName = visibleSourceName(joinClause.tableName, joinClause.tableAlias)
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
  return ast.SelectStatement(distinct, items, tableName, tableAlias, joins, whereExpression, groupBy, havingExpression, [], [], -1, 0, [])
end function

function parseSelect(state)
  statement = parseSelectCore(state)
  while checkKeyword(state, "UNION") or checkKeyword(state, "INTERSECT") or checkKeyword(state, "EXCEPT")
    operator = ast.SET_UNION
    if matchKeyword(state, "UNION") then
      operator = ast.SET_UNION
    else if matchKeyword(state, "INTERSECT") then
      operator = ast.SET_INTERSECT
    else
      expectKeyword(state, "EXCEPT")
      operator = ast.SET_EXCEPT
    end if
    all = matchKeyword(state, "ALL")
    expectKeyword(state, "SELECT")
    statement.setOperations = statement.setOperations + [ast.SetOperation(operator, all, parseSelectCore(state))]
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
  if matchKeyword(state, "LIMIT") then limit = parseIntegerValue(state, "LIMIT") end if
  if state.mysqlMode and limit >= 0 and matchKind(state, token.TokenKind.Comma) then
    offset = limit
    limit = parseIntegerValue(state, "LIMIT row count")
  end if
  if matchKeyword(state, "OFFSET") then
    offset = parseIntegerValue(state, "OFFSET")
    if checkKeyword(state, "ROW") or checkKeyword(state, "ROWS") then advance(state) end if
  end if
  if matchKeyword(state, "FETCH") then
    if limit >= 0 then return fail(state, "LIMIT and FETCH cannot be combined") end if
    if not matchKeyword(state, "FIRST") then expectKeyword(state, "NEXT") end if
    limit = parseIntegerValue(state, "FETCH")
    if not matchKeyword(state, "ROW") then expectKeyword(state, "ROWS") end if
    expectKeyword(state, "ONLY")
  end if
  if limit < -1 or offset < 0 then return fail(state, "LIMIT/OFFSET/FETCH must be non-negative") end if
  statement.orderBy = orderBy
  statement.limit = limit
  statement.offset = offset
  return statement
end function

function parseWithSelect(state)
  if matchKeyword(state, "RECURSIVE") then return fail(state, "recursive CTEs are not supported") end if
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
    ctes = ctes + [ast.CommonTableExpression(name, query, columnNames)]
    if not matchKind(state, token.TokenKind.Comma) then parsing = false end if
  end while
  expectKeyword(state, "SELECT")
  statement = parseSelect(state)
  statement.ctes = ctes
  return statement
end function

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

function preparableStatement(statement)
  return ast.isSelectStatement(statement) or ast.isInsertStatement(statement) or ast.isUpdateStatement(statement) or ast.isDeleteStatement(statement)
end function

function parsePrepare(state)
  name = parseIdentifierName(state, "prepared statement name")
  expectKeyword(state, "AS")
  // Parameter ordinals are local to one prepared statement. Preserve the outer
  // parser counter so several PREPARE statements in one SQL batch all start at 0.
  outerParameterCount = state.parameterCount
  state.parameterCount = 0
  statement = parseStatement(state)
  parameterCount = state.parameterCount
  state.parameterCount = outerParameterCount
  if not preparableStatement(statement) then return fail(state, "PREPARE supports SELECT, INSERT, UPDATE or DELETE") end if
  return ast.PrepareStatement(name, statement, parameterCount)
end function

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

function parseDeallocate(state)
  ignoredPrepare = matchKeyword(state, "PREPARE")
  return ast.DeallocateStatement(parseIdentifierName(state, "prepared statement name"))
end function

function parseStatement(state)
  if matchKeyword(state, "PREPARE") then return parsePrepare(state) end if
  if matchKeyword(state, "EXECUTE") then return parseExecutePrepared(state) end if
  if matchKeyword(state, "DEALLOCATE") then return parseDeallocate(state) end if
  if matchKeyword(state, "VACUUM") then
    tableName = void
    if isIdentifierToken(current(state)) then tableName = parseIdentifierName(state, "table name") end if
    return ast.VacuumStatement(tableName)
  end if
  if matchKeyword(state, "REINDEX") then
    name = void
    if isIdentifierToken(current(state)) then name = parseIdentifierName(state, "table or index name") end if
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
  if matchKeyword(state, "TRUNCATE") then return parseTruncate(state) end if
  if matchKeyword(state, "WITH") then return parseWithSelect(state) end if
  if matchKeyword(state, "SELECT") then return parseSelect(state) end if
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
    if isIdentifierToken(current(state)) then tableName = parseIdentifierName(state, "table name") end if
    return ast.AnalyzeStatement(tableName)
  end if
  if matchKeyword(state, "EXPLAIN") then
    analyze = matchKeyword(state, "ANALYZE")
    return ast.ExplainStatement(analyze, parseStatement(state))
  end if
  return fail(state, "unsupported or missing SQL statement")
end function

function operatorPrecedence(value)
  if token.isKeyword(value, "OR") then return 1 end if
  if token.isKeyword(value, "AND") then return 2 end if
  if value.kind == token.TokenKind.Equal or value.kind == token.TokenKind.NotEqual or value.kind == token.TokenKind.Less or value.kind == token.TokenKind.LessEqual or value.kind == token.TokenKind.Greater or value.kind == token.TokenKind.GreaterEqual then return 3 end if
  if value.kind == token.TokenKind.Concat then return 4 end if
  if value.kind == token.TokenKind.Plus or value.kind == token.TokenKind.Minus then return 5 end if
  if value.kind == token.TokenKind.Star or value.kind == token.TokenKind.Slash or value.kind == token.TokenKind.Percent then return 6 end if
  return 0
end function

function operatorText(value)
  if value.kind == token.TokenKind.Keyword then return value.text end if
  return value.text
end function

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

function parseCastExpression(state)
  expectKeyword(state, "CAST")
  expectKind(state, token.TokenKind.LeftParen, "'('")
  operand = parseExpression(state, 0)
  expectKeyword(state, "AS")
  targetType = parseTypeName(state)
  expectKind(state, token.TokenKind.RightParen, "')'")
  return ast.castExpression(operand, targetType)
end function

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
  if matchKind(state, token.TokenKind.IntegerLiteral) then return ast.integerLiteral(value.value) end if
  if matchKind(state, token.TokenKind.FloatLiteral) then return ast.floatLiteral(value.value) end if
  if matchKind(state, token.TokenKind.StringLiteral) then return ast.stringLiteral(value.value) end if
  if matchKeyword(state, "NULL") then return ast.nullLiteral() end if
  if matchKeyword(state, "TRUE") then return ast.booleanLiteral(true) end if
  if matchKeyword(state, "FALSE") then return ast.booleanLiteral(false) end if
  if matchKeyword(state, "CURRENT_TIMESTAMP") then return ast.currentTimestampLiteral() end if
  if matchKind(state, token.TokenKind.Star) then return ast.starExpression(void) end if
  if state.mysqlMode and state.mysqlConflictUpdate and matchKeyword(state, "VALUES") then
    expectKind(state, token.TokenKind.LeftParen, "'('")
    columnName = parseIdentifierName(state, "VALUES column name")
    expectKind(state, token.TokenKind.RightParen, "')'")
    return ast.columnExpression("excluded", columnName)
  end if
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
      second = parseIdentifierName(state, "column name")
      if state.mysqlMode and matchKind(state, token.TokenKind.Dot) then
        if matchKind(state, token.TokenKind.Star) then return ast.starExpression(second) end if
        return ast.columnExpression(second, parseIdentifierName(state, "column name"))
      end if
      return ast.columnExpression(first, second)
    end if
    return ast.columnExpression(void, first)
  end if
  return fail(state, "expected expression")
end function

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
        operator = "LIKE"
        if negated then operator = "NOT LIKE" end if
        expression = ast.binaryExpression(operator, expression, right)
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

function parseUnary(state)
  if matchKeyword(state, "NOT") then return ast.unaryExpression("NOT", parseUnary(state)) end if
  if matchKind(state, token.TokenKind.Plus) then return ast.unaryExpression("+", parseUnary(state)) end if
  if matchKind(state, token.TokenKind.Minus) then return ast.unaryExpression("-", parseUnary(state)) end if
  return parsePredicateTail(state, parsePrimary(state))
end function

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

function parseTokensWithMode(tokens, mysqlMode)
  if typeof(tokens) != "array" or len(tokens) == 0 then return error(INVALID_ARGUMENT, "sql.parser.parseTokens: tokens must be a non-empty array") end if
  state = ParserState(tokens, 0, 0, mysqlMode, false)
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

function parseTokens(tokens)
  return parseTokensWithMode(tokens, false)
end function

function parseSql(source)
  return parseTokens(lexer.tokenizeSql(source))
end function

function parseMySql(source)
  return parseTokensWithMode(lexer.tokenizeMySql(source), true)
end function

function parseExpressionText(source)
  tokens = lexer.tokenizeSql(source)
  state = ParserState(tokens, 0, 0, false, false)
  expression = parseExpression(state, 0)
  while matchKind(state, token.TokenKind.Semicolon)
  end while
  if not atEnd(state) then return fail(state, "unexpected token after expression") end if
  return expression
end function

function componentName()
  return "sql.parser"
end function

function targetMilestone()
  return "M12"
end function

function isImplemented()
  return true
end function
