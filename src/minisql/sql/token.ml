package minisql.sql.token

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

// Token model for the MiniSQL SQL 1.0 grammar. Keywords use one token kind and
// carry an upper-case canonical text value. Quoted identifiers remain
// identifiers and preserve exact spelling.

// Enumerates the supported token kind variants used by this module.
enum TokenKind
  // Represents the end of input variant.
  EndOfInput = 0
  // Identifies the identifier.
  // Represents the identifier variant.
  Identifier = 1
  // Represents the keyword variant.
  Keyword = 2
  // Represents the integer literal variant.
  IntegerLiteral = 3
  // Represents the float literal variant.
  FloatLiteral = 4
  // Represents the string literal variant.
  StringLiteral = 5
  // Represents the comma variant.
  Comma = 6
  // Represents the dot variant.
  Dot = 7
  // Represents the star variant.
  Star = 8
  // Represents the left paren variant.
  LeftParen = 9
  // Represents the right paren variant.
  RightParen = 10
  // Represents the semicolon variant.
  Semicolon = 11
  // Represents the equal variant.
  Equal = 12
  // Represents the not equal variant.
  NotEqual = 13
  // Represents the less variant.
  Less = 14
  // Represents the less equal variant.
  LessEqual = 15
  // Represents the greater variant.
  Greater = 16
  // Represents the greater equal variant.
  GreaterEqual = 17
  // Represents the plus variant.
  Plus = 18
  // Represents the minus variant.
  Minus = 19
  // Represents the slash variant.
  Slash = 20
  // Represents the percent variant.
  Percent = 21
  // Represents the concat variant.
  Concat = 22
  // Represents the parameter variant.
  Parameter = 23
end enum

// Groups the token state and preserves the field relationships documented below.
struct Token
  // Stores the kind associated with this value.
  kind
  // Stores the text associated with this value.
  text
  // Stores the value associated with this value.
  value
  // Tracks the offset numeric value.
  offset
  // Stores the line associated with this value.
  line
  // Stores the column associated with this value.
  column
  // Indicates whether the quoted condition is active.
  quoted
end struct

// Creates create using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function create(kind, text, value, offset, line, column, quoted)
  if typeof(kind) != "int" or kind < 0 or kind > 65535 then return error(9001, "sql.token.create: kind must fit U16") end if
  if typeof(text) != "string" or typeof(offset) != "int" or offset < 0 or typeof(line) != "int" or line <= 0 or typeof(column) != "int" or column <= 0 or typeof(quoted) != "bool" then
    return error(9001, "sql.token.create: invalid token metadata")
  end if
  return Token(kind, text, value, offset, line, column, quoted)
end function

// Implements eof for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function eof(offset, line, column)
  return create(TokenKind.EndOfInput, "", void, offset, line, column, false)
end function

// Returns whether the supplied value satisfies the kind condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isKind(value, kind)
  return value is Token and value.kind == kind
end function

// Returns whether the supplied value satisfies the keyword condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isKeyword(value, keyword)
  return value is Token and value.kind == TokenKind.Keyword and value.text == keyword
end function

// Implements describe for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function describe(value)
  if value is not Token then return "<not-token>" end if
  if value.kind == TokenKind.EndOfInput then return "end of input" end if
  if value.kind == TokenKind.Identifier then return "identifier '" + value.text + "'" end if
  if value.kind == TokenKind.Keyword then return "keyword " + value.text end if
  if value.kind == TokenKind.StringLiteral then return "string literal" end if
  if value.kind == TokenKind.IntegerLiteral or value.kind == TokenKind.FloatLiteral then return "numeric literal '" + value.text + "'" end if
  if value.kind == TokenKind.Parameter then return "parameter marker ?" end if
  return "token '" + value.text + "'"
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "sql.token"
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
