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
    "ACTION", "ADD", "ADMIN", "AFTER", "ALGORITHM", "ALL", "ALTER", "ALWAYS", "ANALYZE", "AND", "AS", "ASC", "AUTO_INCREMENT", "AUTOINCREMENT", "AVG", "BEFORE", "BEGIN", "BETWEEN", "BIGINT", "BINARY", "BIT", "BLOB", "BOOL", "BOOLEAN",
    "BY", "CASCADE", "CASE", "CAST", "CHANGE", "CHAR", "CHARACTER", "CHARSET", "CHECK", "COLLATE", "COLUMN", "COLUMN_FORMAT", "COMMENT", "COMMIT", "COMMITTED", "CONNECT", "CONSTRAINT", "CREATE", "CROSS", "CURRENT_TIMESTAMP",
    "COALESCE", "CONFLICT", "CONTINUE", "COUNT", "CURRVAL", "CYCLE", "DATABASE", "DATE", "DATETIME", "DEALLOCATE", "DEFAULT", "DELAYED", "DELETE", "DESC", "DESCRIBE", "DO", "DOUBLE", "DROP", "DUPLICATE", "DISABLE", "DISTINCT", "EACH", "ELSE", "ENABLE", "END", "ENGINE", "ENUM", "EXCEPT", "EXECUTE", "EXPLAIN",
    "EXISTS", "FALSE", "FETCH", "FIRST", "FLOAT", "FOR", "FOREIGN", "FROM", "FULL", "FULLTEXT", "GENERATED",
    "GRANT", "GROUP", "HAVING", "HIGH_PRIORITY", "IDENTITY", "IFNULL", "IGNORE", "INCREMENT", "IF", "IN", "INDEX", "INNER", "INSERT", "INT", "INTEGER", "INVISIBLE",
    "INDEXES", "INTERSECT", "INTO", "IS", "ISOLATION", "JOIN", "KEY", "LAST", "LEFT", "LEVEL", "LIKE", "LIMIT",
    "LOCK", "LONG", "LONGBLOB", "LONGTEXT", "LOW_PRIORITY", "MAINTAIN", "MAX", "MAXVALUE", "MEDIUMBLOB", "MEDIUMINT", "MEDIUMTEXT", "MIN", "MINVALUE", "MODIFY", "NATURAL", "NEW", "NEXT", "NEXTVAL", "NO", "NOT", "NOTHING", "NOW", "NULLIF", "NULL", "NULLS", "NUMERIC", "OF", "OFFSET", "ON", "ONLY", "OPTION", "OR", "ORDER",
    "OLD", "OUTER", "OVER", "PARTITION", "PASSWORD", "PRECISION", "PREPARE", "PRIVILEGES", "PUBLIC", "PRIMARY", "QUICK", "READ", "REAL", "REFERENCES", "REINDEX", "RELEASE", "RENAME", "REPLACE", "RESTART", "RETURNING", "REVOKE", "RIGHT", "ROLE",
    "RANK", "RECURSIVE", "RESTRICT", "ROLLBACK", "ROW", "ROWS", "ROW_FORMAT", "ROW_NUMBER", "SAVEPOINT", "SELECT", "SEQUENCE", "SERIALIZABLE", "SET", "SHOW", "SIGNED", "SMALLINT", "SPATIAL", "START", "STORAGE", "STORED", "SUM", "TABLE", "TABLES", "TEXT", "THEN",
    "TINYBLOB", "TINYINT", "TINYTEXT", "TIME", "TIMESTAMP", "TO", "TRANSACTION", "TRIGGER", "TRUE", "TRUNCATE", "UNION", "UNIQUE", "UNKNOWN", "UNSIGNED", "UPDATE", "USER", "USING",
    "VACUUM", "VALUE", "VALUES", "VARBINARY", "VARCHAR", "VARYING", "VIEW", "VIRTUAL", "VISIBLE", "WHEN", "WHERE", "WITH", "WRITE", "YEAR", "ZEROFILL", "JSON", "DENSE_RANK"
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
    "ACTION", "ALGORITHM", "AVG", "BIGINT", "BINARY", "BIT", "BLOB", "BOOL", "BOOLEAN", "CHANGE", "CHAR", "CHARACTER", "CHARSET", "COLLATE", "COLUMN_FORMAT", "COMMENT", "COUNT",
    "DATE", "DATETIME", "DECIMAL", "DOUBLE", "ENGINE", "ENUM", "FLOAT", "FULLTEXT", "IFNULL", "INT", "INTEGER", "INVISIBLE", "JSON", "KEY", "LOCK", "LONG", "LONGBLOB", "LONGTEXT", "MAX",
    "MEDIUMBLOB", "MEDIUMINT", "MEDIUMTEXT", "MIN", "MODIFY", "NATURAL", "NEXTVAL", "CURRVAL", "NOW", "NUMERIC", "QUICK", "RANK", "REAL", "ROW_FORMAT", "ROW_NUMBER", "DENSE_RANK", "SIGNED", "SMALLINT", "SPATIAL", "STORAGE", "SUM", "TEXT", "TIME",
    "TIMESTAMP", "TINYBLOB", "TINYINT", "TINYTEXT", "UNSIGNED", "VALUE", "VARBINARY", "VARCHAR", "VARYING", "VIRTUAL", "VISIBLE", "YEAR", "ZEROFILL"
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
