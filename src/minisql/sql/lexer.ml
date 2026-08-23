package minisql.sql.lexer

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.sql.dialect as dialect
import minisql.sql.token as token
import std.ds.list as list

const INVALID_ARGUMENT = 9001
const SQL_SYNTAX = 9019

// Groups the lexer state state and preserves the field relationships documented below.
struct LexerState
  // Stores the source associated with this value.
  source
  // Stores the raw associated with this value.
  raw
  // Tracks the index numeric value.
  index
  // Stores the line associated with this value.
  line
  // Stores the column associated with this value.
  column
  // Contains the ordered tokens collection.
  tokens
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(state, message)
  return error(SQL_SYNTAX, "sql.lexer at line " + state.line + ", column " + state.column + ": " + message)
end function

// Returns whether the supplied value satisfies the whitespace condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isWhitespace(value)
  return value == 32 or value == 9 or value == 10 or value == 13 or value == 12
end function

// Returns whether the supplied value satisfies the digit condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isDigit(value)
  return value >= 48 and value <= 57
end function

// Returns whether the supplied value satisfies the identifier start condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isIdentifierStart(value)
  return (value >= 65 and value <= 90) or (value >= 97 and value <= 122) or value == 95 or value >= 128
end function

// Returns whether the supplied value satisfies the identifier part condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isIdentifierPart(value)
  return isIdentifierStart(value) or isDigit(value) or value == 36
end function

// Implements current for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function current(state)
  if state.index >= len(state.raw) then return -1 end if
  return state.raw[state.index]
end function

// Implements peek for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function peek(state, distance)
  position = state.index + distance
  if position < 0 or position >= len(state.raw) then return -1 end if
  return state.raw[position]
end function

// Advances advance using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function advance(state)
  if state.index >= len(state.raw) then return -1 end if
  value = state.raw[state.index]
  state.index = state.index + 1
  if value == 10 then
    state.line = state.line + 1
    state.column = 1
  else
    state.column = state.column + 1
  end if
  return value
end function

// Implements raw text for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function rawText(state, startOffset, endOffset)
  return decode(slice(state.raw, startOffset, endOffset - startOffset))
end function

// Appends token using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function appendToken(state, kind, text, value, offset, line, column, quoted)
  state.tokens.add(token.create(kind, text, value, offset, line, column, quoted))
  return true
end function

// Implements skip ignored for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function skipIgnored(state)
  changed = true
  while changed
    changed = false
    while isWhitespace(current(state))
      advance(state)
      changed = true
    end while
    if current(state) == 45 and peek(state, 1) == 45 then
      changed = true
      advance(state)
      advance(state)
      while current(state) >= 0 and current(state) != 10
        advance(state)
      end while
    else if current(state) == 47 and peek(state, 1) == 42 then
      changed = true
      advance(state)
      advance(state)
      closed = false
      while current(state) >= 0
        if current(state) == 42 and peek(state, 1) == 47 then
          advance(state)
          advance(state)
          closed = true
          break
        end if
        advance(state)
      end while
      if not closed then return fail(state, "unterminated block comment") end if
    end if
  end while
  return true
end function

// Reads identifier using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function readIdentifier(state)
  startOffset = state.index
  startLine = state.line
  startColumn = state.column
  while isIdentifierPart(current(state))
    advance(state)
  end while
  original = rawText(state, startOffset, state.index)
  upper = dialect.asciiUpper(original)
  if dialect.isKeyword(upper) then
    appendToken(state, token.TokenKind.Keyword, upper, upper, startOffset, startLine, startColumn, false)
  else
    canonical = dialect.canonicalIdentifier(original, false)
    appendToken(state, token.TokenKind.Identifier, canonical, canonical, startOffset, startLine, startColumn, false)
  end if
  return true
end function

// Reads quoted identifier using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function readQuotedIdentifier(state)
  startOffset = state.index
  startLine = state.line
  startColumn = state.column
  advance(state)
  output = bytes(len(state.raw) - state.index, 0)
  outputLength = 0
  closed = false
  while current(state) >= 0
    value = current(state)
    if value == 34 then
      if peek(state, 1) == 34 then
        output[outputLength] = 34
        outputLength = outputLength + 1
        advance(state)
        advance(state)
      else
        advance(state)
        closed = true
        break
      end if
    else
      output[outputLength] = value
      outputLength = outputLength + 1
      advance(state)
    end if
  end while
  if not closed then return fail(state, "unterminated quoted identifier") end if
  text = decode(slice(output, 0, outputLength))
  if len(text) == 0 then return fail(state, "quoted identifier must not be empty") end if
  appendToken(state, token.TokenKind.Identifier, text, text, startOffset, startLine, startColumn, true)
  return true
end function

// Reads string using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function readString(state)
  startOffset = state.index
  startLine = state.line
  startColumn = state.column
  advance(state)
  output = bytes(len(state.raw) - state.index, 0)
  outputLength = 0
  closed = false
  while current(state) >= 0
    value = current(state)
    if value == 39 then
      if peek(state, 1) == 39 then
        output[outputLength] = 39
        outputLength = outputLength + 1
        advance(state)
        advance(state)
      else
        advance(state)
        closed = true
        break
      end if
    else
      output[outputLength] = value
      outputLength = outputLength + 1
      advance(state)
    end if
  end while
  if not closed then return fail(state, "unterminated string literal") end if
  value = decode(slice(output, 0, outputLength))
  // Literal contents live in value. Avoid retaining a second raw copy of a
  // potentially multi-gigabyte literal solely for diagnostic rendering.
  appendToken(state, token.TokenKind.StringLiteral, "<string>", value, startOffset, startLine, startColumn, false)
  return true
end function

// Reads number using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function readNumber(state)
  startOffset = state.index
  startLine = state.line
  startColumn = state.column
  while isDigit(current(state))
    advance(state)
  end while
  isFloat = false
  if current(state) == 46 and isDigit(peek(state, 1)) then
    isFloat = true
    advance(state)
    while isDigit(current(state))
      advance(state)
    end while
  end if
  if current(state) == 69 or current(state) == 101 then
    isFloat = true
    advance(state)
    if current(state) == 43 or current(state) == 45 then advance(state) end if
    if not isDigit(current(state)) then return fail(state, "exponent requires digits") end if
    while isDigit(current(state))
      advance(state)
    end while
  end if
  text = rawText(state, startOffset, state.index)
  kind = token.TokenKind.IntegerLiteral
  if isFloat then kind = token.TokenKind.FloatLiteral end if
  appendToken(state, kind, text, text, startOffset, startLine, startColumn, false)
  return true
end function

// Implements symbol token for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function symbolToken(state)
  startOffset = state.index
  startLine = state.line
  startColumn = state.column
  first = current(state)
  second = peek(state, 1)
  if first == 60 and second == 61 then advance(state); advance(state); return token.create(token.TokenKind.LessEqual, "<=", void, startOffset, startLine, startColumn, false) end if
  if first == 62 and second == 61 then advance(state); advance(state); return token.create(token.TokenKind.GreaterEqual, ">=", void, startOffset, startLine, startColumn, false) end if
  if first == 60 and second == 62 then advance(state); advance(state); return token.create(token.TokenKind.NotEqual, "<>", void, startOffset, startLine, startColumn, false) end if
  if first == 33 and second == 61 then advance(state); advance(state); return token.create(token.TokenKind.NotEqual, "!=", void, startOffset, startLine, startColumn, false) end if
  if first == 124 and second == 124 then advance(state); advance(state); return token.create(token.TokenKind.Concat, "||", void, startOffset, startLine, startColumn, false) end if
  advance(state)
  if first == 44 then return token.create(token.TokenKind.Comma, ",", void, startOffset, startLine, startColumn, false) end if
  if first == 46 then return token.create(token.TokenKind.Dot, ".", void, startOffset, startLine, startColumn, false) end if
  if first == 42 then return token.create(token.TokenKind.Star, "*", void, startOffset, startLine, startColumn, false) end if
  if first == 40 then return token.create(token.TokenKind.LeftParen, "(", void, startOffset, startLine, startColumn, false) end if
  if first == 41 then return token.create(token.TokenKind.RightParen, ")", void, startOffset, startLine, startColumn, false) end if
  if first == 59 then return token.create(token.TokenKind.Semicolon, ";", void, startOffset, startLine, startColumn, false) end if
  if first == 61 then return token.create(token.TokenKind.Equal, "=", void, startOffset, startLine, startColumn, false) end if
  if first == 60 then return token.create(token.TokenKind.Less, "<", void, startOffset, startLine, startColumn, false) end if
  if first == 62 then return token.create(token.TokenKind.Greater, ">", void, startOffset, startLine, startColumn, false) end if
  if first == 43 then return token.create(token.TokenKind.Plus, "+", void, startOffset, startLine, startColumn, false) end if
  if first == 45 then return token.create(token.TokenKind.Minus, "-", void, startOffset, startLine, startColumn, false) end if
  if first == 47 then return token.create(token.TokenKind.Slash, "/", void, startOffset, startLine, startColumn, false) end if
  if first == 37 then return token.create(token.TokenKind.Percent, "%", void, startOffset, startLine, startColumn, false) end if
  if first == 63 then return token.create(token.TokenKind.Parameter, "?", void, startOffset, startLine, startColumn, false) end if
  return fail(state, "unexpected byte 0x" + hex(bytes([first])))
end function

// Tokenizes SQL using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// May mutate supplied state as documented by the operation name.
function tokenizeSql(source)
  if typeof(source) != "string" then return error(INVALID_ARGUMENT, "sql.lexer.tokenizeSql: source must be string") end if
  raw = bytes(source)
  state = LexerState(source, raw, 0, 1, 1, list.List.new())
  while state.index < len(raw)
    skipIgnored(state)
    if state.index >= len(raw) then break end if
    value = current(state)
    if isIdentifierStart(value) then
      readIdentifier(state)
    else if value == 34 then
      readQuotedIdentifier(state)
    else if value == 39 then
      readString(state)
    else if isDigit(value) then
      readNumber(state)
    else
      produced = symbolToken(state)
      state.tokens.add(produced)
    end if
  end while
  state.tokens.add(token.eof(state.index, state.line, state.column))
  return state.tokens.toArray()
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "sql.lexer"
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
