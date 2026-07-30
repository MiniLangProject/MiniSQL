package minisql.sql.types

import minisql.sql.ast as ast
import minisql.sql.dialect as dialect

const INVALID_ARGUMENT = 9001
const TYPE_MISMATCH = 9017
const BINDING_ERROR = 9020

// Type codes intentionally match storage.row_codec so catalog metadata can be
// turned into row schemas without a translation table.
enum SqlTypeKind
  Unknown = 0
  Boolean = 1
  SmallInt = 2
  Integer = 3
  BigInt = 4
  Real = 5
  Double = 6
  Decimal = 7
  Char = 8
  VarChar = 9
  Text = 10
  Binary = 11
  VarBinary = 12
  Blob = 13
  Date = 14
  Time = 15
  Timestamp = 16
end enum

struct SqlType
  kind
  length
  precision
  scale
  nullable
end struct

function fail(code, operation, message)
  return error(code, "sql.types." + operation + ": " + message)
end function

function isSqlType(value)
  return value is SqlType
end function

function validKind(kind)
  return typeof(kind) == "int" and kind >= SqlTypeKind.Boolean and kind <= SqlTypeKind.Timestamp
end function

function create(kind, length, precision, scale, nullable)
  if not validKind(kind) then return fail(INVALID_ARGUMENT, "create", "unknown SQL type kind") end if
  if typeof(length) != "int" or length < 0 or typeof(precision) != "int" or precision < 0 or typeof(scale) != "int" or scale < 0 or typeof(nullable) != "bool" then
    return fail(INVALID_ARGUMENT, "create", "invalid type attributes")
  end if
  if (kind == SqlTypeKind.Char or kind == SqlTypeKind.VarChar or kind == SqlTypeKind.Binary or kind == SqlTypeKind.VarBinary) and length <= 0 then
    return fail(INVALID_ARGUMENT, "create", "bounded character/binary types require positive length")
  end if
  if kind == SqlTypeKind.Decimal then
    if precision <= 0 or precision > 18 or scale > precision then return fail(INVALID_ARGUMENT, "create", "DECIMAL requires 1<=precision<=18 and 0<=scale<=precision") end if
  end if
  if (kind == SqlTypeKind.Time or kind == SqlTypeKind.Timestamp) and precision > 6 then return fail(INVALID_ARGUMENT, "create", "time precision must be 0..6") end if
  return SqlType(kind, length, precision, scale, nullable)
end function

function withNullable(value, nullable)
  if value is not SqlType then return fail(INVALID_ARGUMENT, "withNullable", "value must be SqlType") end if
  return create(value.kind, value.length, value.precision, value.scale, nullable)
end function

function kindName(kind)
  if kind == SqlTypeKind.Boolean then return "BOOLEAN" end if
  if kind == SqlTypeKind.SmallInt then return "SMALLINT" end if
  if kind == SqlTypeKind.Integer then return "INTEGER" end if
  if kind == SqlTypeKind.BigInt then return "BIGINT" end if
  if kind == SqlTypeKind.Real then return "REAL" end if
  if kind == SqlTypeKind.Double then return "DOUBLE PRECISION" end if
  if kind == SqlTypeKind.Decimal then return "DECIMAL" end if
  if kind == SqlTypeKind.Char then return "CHAR" end if
  if kind == SqlTypeKind.VarChar then return "VARCHAR" end if
  if kind == SqlTypeKind.Text then return "TEXT" end if
  if kind == SqlTypeKind.Binary then return "BINARY" end if
  if kind == SqlTypeKind.VarBinary then return "VARBINARY" end if
  if kind == SqlTypeKind.Blob then return "BLOB" end if
  if kind == SqlTypeKind.Date then return "DATE" end if
  if kind == SqlTypeKind.Time then return "TIME" end if
  if kind == SqlTypeKind.Timestamp then return "TIMESTAMP" end if
  return "UNKNOWN"
end function

function fromTypeName(typeName, nullable)
  if not ast.isTypeName(typeName) then return fail(INVALID_ARGUMENT, "fromTypeName", "typeName must be AST TypeName") end if
  name = dialect.asciiUpper(typeName.name)
  if name == "BOOL" then name = "BOOLEAN" end if
  if name == "TINYINT" then name = "SMALLINT" end if
  if name == "MEDIUMINT" then name = "INTEGER" end if
  if name == "INT" then name = "INTEGER" end if
  if name == "FLOAT" then name = "DOUBLE" end if
  if name == "NUMERIC" then name = "DECIMAL" end if
  if name == "DOUBLE PRECISION" then name = "DOUBLE" end if
  if name == "DATETIME" then name = "TIMESTAMP" end if
  if name == "YEAR" then name = "INTEGER" end if
  if name == "JSON" then name = "TEXT" end if
  if name == "ENUM" then name = "TEXT" end if
  if name == "SET" then name = "TEXT" end if
  if name == "TINYTEXT" then name = "TEXT" end if
  if name == "MEDIUMTEXT" then name = "TEXT" end if
  if name == "LONGTEXT" then name = "TEXT" end if
  if name == "TINYBLOB" then name = "BLOB" end if
  if name == "MEDIUMBLOB" then name = "BLOB" end if
  if name == "LONGBLOB" then name = "BLOB" end if
  kind = SqlTypeKind.Unknown
  if name == "BOOLEAN" then kind = SqlTypeKind.Boolean end if
  if name == "SMALLINT" then kind = SqlTypeKind.SmallInt end if
  if name == "INTEGER" then kind = SqlTypeKind.Integer end if
  if name == "BIGINT" then kind = SqlTypeKind.BigInt end if
  if name == "REAL" then kind = SqlTypeKind.Real end if
  if name == "DOUBLE" then kind = SqlTypeKind.Double end if
  if name == "DECIMAL" then kind = SqlTypeKind.Decimal end if
  if name == "CHAR" then kind = SqlTypeKind.Char end if
  if name == "VARCHAR" then kind = SqlTypeKind.VarChar end if
  if name == "TEXT" then kind = SqlTypeKind.Text end if
  if name == "BINARY" then kind = SqlTypeKind.Binary end if
  if name == "VARBINARY" then kind = SqlTypeKind.VarBinary end if
  if name == "BLOB" then kind = SqlTypeKind.Blob end if
  if name == "DATE" then kind = SqlTypeKind.Date end if
  if name == "TIME" then kind = SqlTypeKind.Time end if
  if name == "TIMESTAMP" then kind = SqlTypeKind.Timestamp end if
  if kind == SqlTypeKind.Unknown then return fail(BINDING_ERROR, "fromTypeName", "unsupported SQL type " + typeName.name) end if
  length = typeName.length
  precision = typeName.precision
  scale = typeName.scale
  if kind == SqlTypeKind.Char or kind == SqlTypeKind.VarChar or kind == SqlTypeKind.Binary or kind == SqlTypeKind.VarBinary then
    if length == 0 then return fail(BINDING_ERROR, "fromTypeName", kindName(kind) + " requires a length") end if
  end if
  if kind == SqlTypeKind.Decimal and precision == 0 then precision = 18 end if
  return create(kind, length, precision, scale, nullable)
end function

function fromColumn(column)
  if typeof(column) != "struct" then return fail(INVALID_ARGUMENT, "fromColumn", "column must be metadata struct") end if
  return create(column.typeCode, column.maxLength, column.precision, column.scale, column.nullable)
end function

function isNumeric(value)
  if value is SqlType then return isNumericKind(value.kind) end if
  return false
end function

function isNumericKind(kind)
  return kind == SqlTypeKind.SmallInt or kind == SqlTypeKind.Integer or kind == SqlTypeKind.BigInt or kind == SqlTypeKind.Real or kind == SqlTypeKind.Double or kind == SqlTypeKind.Decimal
end function

function isIntegralKind(kind)
  return kind == SqlTypeKind.SmallInt or kind == SqlTypeKind.Integer or kind == SqlTypeKind.BigInt
end function

function isTextKind(kind)
  return kind == SqlTypeKind.Char or kind == SqlTypeKind.VarChar or kind == SqlTypeKind.Text
end function

function isBinaryKind(kind)
  return kind == SqlTypeKind.Binary or kind == SqlTypeKind.VarBinary or kind == SqlTypeKind.Blob
end function

function sameBase(left, right)
  if left is not SqlType or right is not SqlType then return false end if
  return left.kind == right.kind and left.length == right.length and left.precision == right.precision and left.scale == right.scale
end function

function numericRank(kind)
  if kind == SqlTypeKind.SmallInt then return 1 end if
  if kind == SqlTypeKind.Integer then return 2 end if
  if kind == SqlTypeKind.BigInt then return 3 end if
  if kind == SqlTypeKind.Decimal then return 4 end if
  if kind == SqlTypeKind.Real then return 5 end if
  if kind == SqlTypeKind.Double then return 6 end if
  return 0
end function

function commonNumeric(left, right)
  if left is not SqlType or right is not SqlType or not isNumeric(left) or not isNumeric(right) then return fail(TYPE_MISMATCH, "commonNumeric", "both operands must be numeric") end if
  rank = numericRank(left.kind)
  kind = left.kind
  if numericRank(right.kind) > rank then kind = right.kind end if
  precision = 0
  scale = 0
  if kind == SqlTypeKind.Decimal then
    precision = left.precision
    if right.precision > precision then precision = right.precision end if
    scale = left.scale
    if right.scale > scale then scale = right.scale end if
    if precision == 0 then precision = 18 end if
  end if
  return create(kind, 0, precision, scale, left.nullable or right.nullable)
end function

function canAssign(source, target)
  if source is not SqlType or target is not SqlType then return false end if
  if source.kind == target.kind then
    if source.kind == SqlTypeKind.Decimal then return source.scale == target.scale end if
    return true
  end if
  // DECIMAL assignment is validated exactly by sql.values.convert. Floating
  // values are accepted only when they can be represented at the target scale
  // without rounding or truncation.
  if target.kind == SqlTypeKind.Decimal and isNumeric(source) then return true end if
  if isNumeric(source) and isNumeric(target) then return numericRank(source.kind) <= numericRank(target.kind) end if
  if isTextKind(source.kind) and isTextKind(target.kind) then return true end if
  if isBinaryKind(source.kind) and isBinaryKind(target.kind) then return true end if
  return false
end function

function comparable(left, right)
  if left is not SqlType or right is not SqlType then return false end if
  if left.kind == right.kind then return true end if
  if isNumeric(left) and isNumeric(right) then return true end if
  if isTextKind(left.kind) and isTextKind(right.kind) then return true end if
  if isBinaryKind(left.kind) and isBinaryKind(right.kind) then return true end if
  return false
end function

function componentName()
  return "sql.types"
end function

function targetMilestone()
  return "M13"
end function

function isImplemented()
  return true
end function
