//! Provides minisql sql types facilities for this project.

package minisql.sql.types

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.sql.ast as ast

/// Defines the invalid argument constant used by the minisql sql types module.
const INVALID_ARGUMENT = 9001
/// Defines the type mismatch constant used by the minisql sql types module.
const TYPE_MISMATCH = 9017
/// Defines the binding error constant used by the minisql sql types module.
const BINDING_ERROR = 9020

/// Type codes intentionally match storage.row_codec so catalog metadata can be
/// turned into row schemas without a translation table.
/// Enumerates the supported SQL type kind variants used by this module.
enum SqlTypeKind
  /// Represents the unknown variant.
  Unknown = 0
  /// Represents the boolean variant.
  Boolean = 1
  /// Represents the small int variant.
  SmallInt = 2
  /// Represents the integer variant.
  Integer = 3
  /// Represents the big int variant.
  BigInt = 4
  /// Represents the real variant.
  Real = 5
  /// Represents the double variant.
  Double = 6
  /// Represents the decimal variant.
  Decimal = 7
  /// Represents the char variant.
  Char = 8
  /// Represents the var char variant.
  VarChar = 9
  /// Represents the text variant.
  Text = 10
  /// Represents the binary variant.
  Binary = 11
  /// Represents the var binary variant.
  VarBinary = 12
  /// Represents the blob variant.
  Blob = 13
  /// Represents the date variant.
  Date = 14
  /// Represents the time variant.
  Time = 15
  /// Represents the timestamp variant.
  Timestamp = 16
end enum

/// Groups the SQL type state and preserves the field relationships documented below.
struct SqlType
  /// Stores the kind associated with this value.
  kind
  /// Tracks the length numeric value.
  length
  /// Stores the precision associated with this value.
  precision
  /// Stores the scale associated with this value.
  scale
  /// Indicates whether the nullable condition is active.
  nullable
end struct

/// Performs the fail operation for the minisql sql types module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "sql.types." + operation + ": " + message)
end function

/// Returns whether the supplied value satisfies the SQL type condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isSqlType(value)
  return value is SqlType
end function

/// Implements valid kind for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param kind kind value consumed by this operation.
function validKind(kind)
  return typeof(kind) == "int" and kind >= SqlTypeKind.Boolean and kind <= SqlTypeKind.Timestamp
end function

/// Creates create for the minisql sql types module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param kind kind value consumed by this operation.
/// @param length length value consumed by this operation.
/// @param precision precision value consumed by this operation.
/// @param scale scale value consumed by this operation.
/// @param nullable nullable value consumed by this operation.
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

/// Implements with nullable for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
/// @param nullable nullable value consumed by this operation.
function withNullable(value, nullable)
  if value is not SqlType then return fail(INVALID_ARGUMENT, "withNullable", "value must be SqlType") end if
  return create(value.kind, value.length, value.precision, value.scale, nullable)
end function

/// Implements kind name for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param kind kind value consumed by this operation.
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

/// Implements from type name for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param typeName typeName value consumed by this operation.
/// @param nullable nullable value consumed by this operation.
function fromTypeName(typeName, nullable)
  if not ast.isTypeName(typeName) then return fail(INVALID_ARGUMENT, "fromTypeName", "typeName must be AST TypeName") end if
  name = typeName.name
  if name == "BOOL" then name = "BOOLEAN" end if
  if name == "INT" then name = "INTEGER" end if
  if name == "FLOAT" then name = "DOUBLE" end if
  if name == "NUMERIC" then name = "DECIMAL" end if
  if name == "DOUBLE PRECISION" then name = "DOUBLE" end if
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

/// Implements from column for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param column column value consumed by this operation.
function fromColumn(column)
  if typeof(column) != "struct" then return fail(INVALID_ARGUMENT, "fromColumn", "column must be metadata struct") end if
  return create(column.typeCode, column.maxLength, column.precision, column.scale, column.nullable)
end function

/// Returns whether the supplied value satisfies the numeric condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isNumeric(value)
  if value is SqlType then return isNumericKind(value.kind) end if
  return false
end function

/// Returns whether the supplied value satisfies the numeric kind condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param kind kind value consumed by this operation.
function isNumericKind(kind)
  return kind == SqlTypeKind.SmallInt or kind == SqlTypeKind.Integer or kind == SqlTypeKind.BigInt or kind == SqlTypeKind.Real or kind == SqlTypeKind.Double or kind == SqlTypeKind.Decimal
end function

/// Returns whether the supplied value satisfies the integral kind condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param kind kind value consumed by this operation.
function isIntegralKind(kind)
  return kind == SqlTypeKind.SmallInt or kind == SqlTypeKind.Integer or kind == SqlTypeKind.BigInt
end function

/// Returns whether the supplied value satisfies the text kind condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param kind kind value consumed by this operation.
function isTextKind(kind)
  return kind == SqlTypeKind.Char or kind == SqlTypeKind.VarChar or kind == SqlTypeKind.Text
end function

/// Returns whether the supplied value satisfies the binary kind condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param kind kind value consumed by this operation.
function isBinaryKind(kind)
  return kind == SqlTypeKind.Binary or kind == SqlTypeKind.VarBinary or kind == SqlTypeKind.Blob
end function

/// Implements same base for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function sameBase(left, right)
  if left is not SqlType or right is not SqlType then return false end if
  return left.kind == right.kind and left.length == right.length and left.precision == right.precision and left.scale == right.scale
end function

/// Implements numeric rank for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param kind kind value consumed by this operation.
function numericRank(kind)
  if kind == SqlTypeKind.SmallInt then return 1 end if
  if kind == SqlTypeKind.Integer then return 2 end if
  if kind == SqlTypeKind.BigInt then return 3 end if
  if kind == SqlTypeKind.Decimal then return 4 end if
  if kind == SqlTypeKind.Real then return 5 end if
  if kind == SqlTypeKind.Double then return 6 end if
  return 0
end function

/// Implements common numeric for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
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

/// Returns whether the supplied value satisfies the assign condition.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param source source value consumed by this operation.
/// @param target target value consumed by this operation.
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

/// Implements comparable for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function comparable(left, right)
  if left is not SqlType or right is not SqlType then return false end if
  if left.kind == right.kind then return true end if
  if isNumeric(left) and isNumeric(right) then return true end if
  if isTextKind(left.kind) and isTextKind(right.kind) then return true end if
  if isBinaryKind(left.kind) and isBinaryKind(right.kind) then return true end if
  return false
end function

/// Performs the componentName operation for the minisql sql types module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "sql.types"
end function

/// Performs the targetMilestone operation for the minisql sql types module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M13"
end function

/// Returns whether implemented satisfies the condition required by the minisql sql types module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
