package minisql.sql.dialect

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

// MiniSQL SQL 1.0 keyword and identifier policy. Unquoted identifiers are
// canonicalized to lower case by the lexer while quoted identifiers preserve
// spelling and case.

// Implements ascii upper for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function asciiUpper(text)
  if typeof(text) != "string" then return error(9001, "sql.dialect.asciiUpper: text must be string") end if
  raw = bytes(text)
  if len(raw) > 0 then
    for index = 0 to len(raw) - 1
      if raw[index] >= 97 and raw[index] <= 122 then raw[index] = raw[index] - 32 end if
    end for
  end if
  return decode(raw)
end function

// Implements ascii lower for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function asciiLower(text)
  if typeof(text) != "string" then return error(9001, "sql.dialect.asciiLower: text must be string") end if
  raw = bytes(text)
  if len(raw) > 0 then
    for index = 0 to len(raw) - 1
      if raw[index] >= 65 and raw[index] <= 90 then raw[index] = raw[index] + 32 end if
    end for
  end if
  return decode(raw)
end function

// Implements keyword list for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function keywordList()
  return [
    "ABS", "ACTION", "ADD", "ADMIN", "AFTER", "ALL", "ALTER", "ALWAYS", "ANALYZE", "AND", "AS", "ASC", "AUTO_INCREMENT", "AUTOINCREMENT", "AVG", "BEFORE", "BEGIN", "BETWEEN", "BIGINT", "BINARY", "BLOB", "BOOL_AND", "BOOL_OR", "BOOLEAN",
    "BY", "CASCADE", "CASE", "CAST", "CHAR", "CHECK", "COMMIT", "COMMITTED", "CONNECT", "CONSTRAINT", "CREATE", "CROSS", "CURRENT_TIMESTAMP",
    "CEIL", "CHAR_LENGTH", "COLUMN", "COALESCE", "CONCAT", "CONFLICT", "CONTINUE", "COUNT", "CURRVAL", "CYCLE", "DATABASE", "DATE", "DATE_PART", "DEALLOCATE", "DESCRIBE", "DECIMAL", "DEFAULT", "DELETE", "DESC", "DO", "DISABLE", "DISTINCT", "DOUBLE", "DROP", "ELSE", "ENABLE", "END", "EXCEPT", "EXECUTE", "EXPLAIN", "FLOOR",
    "EACH", "EXISTS", "FALSE", "FETCH", "FIRST", "FLOAT", "FOR", "FOREIGN", "FROM", "FULL", "GENERATED",
    "GRANT", "GROUP", "HAVING", "IDENTITY", "INCREMENT", "IF", "IN", "INCLUDE", "INDEX", "INNER", "INSERT", "INT", "INTEGER",
    "INDEXES", "INTERSECT", "INTO", "IS", "ISOLATION", "JOIN", "KEY", "LAST", "LEFT", "LENGTH", "LEVEL", "LIKE", "LIMIT", "LOWER",
    "MAINTAIN", "MATCHED", "MAX", "MAXVALUE", "MERGE", "MIN", "MINVALUE", "NEW", "NEXT", "NEXTVAL", "NO", "NOT", "NOTHING", "NULLIF", "NULL", "NULLS", "NUMERIC", "OF", "OFFSET", "ON", "ONLY", "OPTION", "OR", "ORDER",
    "OLD", "OUTER", "OVER", "PARTITION", "PASSWORD", "PRECISION", "PREPARE", "PRIVILEGES", "PUBLIC", "PRIMARY", "READ", "REAL", "REFERENCES", "REINDEX", "RELEASE", "RENAME", "RESTART", "RETURNING", "REVOKE", "ROLE", "RESTRICT", "RIGHT",
    "POWER", "PROCEDURE", "CALL", "RANK", "PERCENT_RANK", "CUME_DIST", "NTILE", "LAG", "LEAD", "FIRST_VALUE", "LAST_VALUE", "NTH_VALUE", "RECURSIVE", "REPLACE", "ROLLBACK", "ROUND", "ROW", "ROWS", "ROW_NUMBER", "SAVEPOINT", "SELECT", "SERIALIZABLE", "SET", "SMALLINT", "STRING_AGG", "SUBSTRING", "TABLE",
    "SCHEMA", "SEQUENCE", "SHOW", "SHUTDOWN", "START", "STATUS", "STORED", "SUM", "TABLES", "TEXT", "THEN", "TRIGGER", "TRIM", "TRUNCATE", "TIME", "TIMESTAMP", "TO", "TRANSACTION", "TRUE", "UNION", "UNIQUE", "UPDATE", "UPPER",
    "UNKNOWN", "USER", "USING", "VACUUM", "VALUES", "VARBINARY", "VARCHAR", "VIEW", "WHEN", "WHERE", "WITH", "WRITE", "DENSE_RANK", "PROCESSLIST"
  ]
end function

// Returns whether the supplied value satisfies the keyword condition.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isKeyword(text)
  if typeof(text) != "string" then return false end if
  upper = asciiUpper(text)
  for each keyword in keywordList()
    if upper == keyword then return true end if
  end for
  return false
end function

// MiniSQL distinguishes fully reserved grammar words from contextual words.
// SQL type names and aggregate function names are keywords while parsing their
// dedicated constructs, but remain legal unquoted identifiers where an object,
// column, alias, savepoint or principal name is expected.
// Implements non reserved identifier keyword list for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function nonReservedIdentifierKeywordList()
  return [
    "ABS", "ACTION", "AVG", "BIGINT", "BINARY", "BLOB", "BOOL_AND", "BOOL_OR", "BOOLEAN", "CEIL", "CHAR", "CHAR_LENGTH", "CONCAT", "COUNT",
    "DATE", "DATE_PART", "DECIMAL", "DOUBLE", "FLOAT", "FLOOR", "INT", "INTEGER", "LENGTH", "LOWER", "MAX",
    "INCLUDE", "MIN", "NEXTVAL", "CURRVAL", "NUMERIC", "POWER", "RANK", "PERCENT_RANK", "CUME_DIST", "NTILE", "LAG", "LEAD", "FIRST_VALUE", "LAST_VALUE", "NTH_VALUE", "REAL", "REPLACE", "ROUND", "ROW_NUMBER", "DENSE_RANK", "SMALLINT", "STRING_AGG", "SUBSTRING", "SUM", "TEXT", "TIME", "TRIM",
    "TABLES", "TIMESTAMP", "UPPER", "VARBINARY", "VARCHAR"
  ]
end function

// Returns whether the supplied value satisfies the non reserved identifier keyword condition.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isNonReservedIdentifierKeyword(text)
  if typeof(text) != "string" then return false end if
  upper = asciiUpper(text)
  for each keyword in nonReservedIdentifierKeywordList()
    if upper == keyword then return true end if
  end for
  return false
end function

// Implements canonical identifier for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Does not modify its inputs.
function canonicalIdentifier(text, quoted)
  if typeof(text) != "string" or typeof(quoted) != "bool" then return error(9001, "sql.dialect.canonicalIdentifier: invalid arguments") end if
  if quoted then return text end if
  return asciiLower(text)
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "sql.dialect"
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
