package minisql.sql.dialect

// MiniSQL SQL 1.0 keyword and identifier policy. Unquoted identifiers are
// canonicalized to lower case by the lexer while quoted identifiers preserve
// spelling and case.

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

function keywordList()
  return [
    "ACTION", "ADD", "ADMIN", "AFTER", "ALL", "ALTER", "ALWAYS", "ANALYZE", "AND", "AS", "ASC", "AUTO_INCREMENT", "AUTOINCREMENT", "AVG", "BEFORE", "BEGIN", "BETWEEN", "BIGINT", "BINARY", "BLOB", "BOOLEAN",
    "BY", "CASCADE", "CASE", "CAST", "CHAR", "CHECK", "COMMIT", "COMMITTED", "CONNECT", "CONSTRAINT", "CREATE", "CROSS", "CURRENT_TIMESTAMP",
    "COLUMN", "COALESCE", "CONFLICT", "CONTINUE", "COUNT", "CURRVAL", "CYCLE", "DATABASE", "DATE", "DEALLOCATE", "DESCRIBE", "DECIMAL", "DEFAULT", "DELETE", "DESC", "DO", "DISABLE", "DISTINCT", "DOUBLE", "DROP", "ELSE", "ENABLE", "END", "EXCEPT", "EXECUTE", "EXPLAIN",
    "EACH", "EXISTS", "FALSE", "FETCH", "FIRST", "FLOAT", "FOR", "FOREIGN", "FROM", "FULL", "GENERATED",
    "GRANT", "GROUP", "HAVING", "IDENTITY", "INCREMENT", "IF", "IN", "INDEX", "INNER", "INSERT", "INT", "INTEGER",
    "INDEXES", "INTERSECT", "INTO", "IS", "ISOLATION", "JOIN", "KEY", "LAST", "LEFT", "LEVEL", "LIKE", "LIMIT",
    "MAINTAIN", "MAX", "MAXVALUE", "MIN", "MINVALUE", "NEW", "NEXT", "NEXTVAL", "NO", "NOT", "NOTHING", "NULLIF", "NULL", "NULLS", "NUMERIC", "OF", "OFFSET", "ON", "ONLY", "OPTION", "OR", "ORDER",
    "OLD", "OUTER", "OVER", "PARTITION", "PASSWORD", "PRECISION", "PREPARE", "PRIVILEGES", "PUBLIC", "PRIMARY", "READ", "REAL", "REFERENCES", "REINDEX", "RELEASE", "RENAME", "RESTART", "RETURNING", "REVOKE", "ROLE", "RESTRICT", "RIGHT",
    "RANK", "RECURSIVE", "REPLACE", "ROLLBACK", "ROW", "ROWS", "ROW_NUMBER", "SAVEPOINT", "SELECT", "SERIALIZABLE", "SET", "SMALLINT", "TABLE",
    "SEQUENCE", "SHOW", "START", "STORED", "SUM", "TABLES", "TEXT", "THEN", "TRIGGER", "TRUNCATE", "TIME", "TIMESTAMP", "TO", "TRANSACTION", "TRUE", "UNION", "UNIQUE", "UPDATE",
    "UNKNOWN", "USER", "USING", "VACUUM", "VALUES", "VARBINARY", "VARCHAR", "VIEW", "WHEN", "WHERE", "WITH", "WRITE", "DENSE_RANK"
  ]
end function

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
function nonReservedIdentifierKeywordList()
  return [
    "ACTION", "AVG", "BIGINT", "BINARY", "BLOB", "BOOLEAN", "CHAR", "COUNT",
    "DATE", "DECIMAL", "DOUBLE", "FLOAT", "INT", "INTEGER", "MAX",
    "MIN", "NEXTVAL", "CURRVAL", "NUMERIC", "RANK", "REAL", "ROW_NUMBER", "DENSE_RANK", "SMALLINT", "SUM", "TEXT", "TIME",
    "TIMESTAMP", "VARBINARY", "VARCHAR"
  ]
end function

function isNonReservedIdentifierKeyword(text)
  if typeof(text) != "string" then return false end if
  upper = asciiUpper(text)
  for each keyword in nonReservedIdentifierKeywordList()
    if upper == keyword then return true end if
  end for
  return false
end function

function canonicalIdentifier(text, quoted)
  if typeof(text) != "string" or typeof(quoted) != "bool" then return error(9001, "sql.dialect.canonicalIdentifier: invalid arguments") end if
  if quoted then return text end if
  return asciiLower(text)
end function

function componentName()
  return "sql.dialect"
end function

function targetMilestone()
  return "M12"
end function

function isImplemented()
  return true
end function
