package minisql.sql.lexer

import minisql.sql.dialect as dialect
import minisql.sql.token as token

const INVALID_ARGUMENT = 9001
const SQL_SYNTAX = 9019
const MAX_SQL_BYTES = 1048576

struct LexerState
  source
  raw
  index
  line
  column
  tokens
  mysqlMode
end struct

function fail(state, message)
  return error(SQL_SYNTAX, "sql.lexer at line " + state.line + ", column " + state.column + ": " + message)
end function

function isWhitespace(value)
  return value == 32 or value == 9 or value == 10 or value == 13 or value == 12
end function

function isDigit(value)
  return value >= 48 and value <= 57
end function

function isIdentifierStart(value)
  return (value >= 65 and value <= 90) or (value >= 97 and value <= 122) or value == 95 or value >= 128
end function

function isIdentifierPart(value)
  return isIdentifierStart(value) or isDigit(value) or value == 36
end function

function current(state)
  if state.index >= len(state.raw) then return -1 end if
  return state.raw[state.index]
end function

function peek(state, distance)
  position = state.index + distance
  if position < 0 or position >= len(state.raw) then return -1 end if
  return state.raw[position]
end function

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

function rawText(state, startOffset, endOffset)
  return decode(slice(state.raw, startOffset, endOffset - startOffset))
end function

function appendToken(state, kind, text, value, offset, line, column, quoted)
  state.tokens = state.tokens + [token.create(kind, text, value, offset, line, column, quoted)]
  return true
end function

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
    else if state.mysqlMode and current(state) == 35 then
      changed = true
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

function readBacktickIdentifier(state)
  startOffset = state.index
  startLine = state.line
  startColumn = state.column
  advance(state)
  output = []
  closed = false
  while current(state) >= 0
    value = current(state)
    if value == 96 then
      if peek(state, 1) == 96 then
        output = output + [96]
        advance(state)
        advance(state)
      else
        advance(state)
        closed = true
        break
      end if
    else
      output = output + [value]
      advance(state)
    end if
  end while
  if not closed then return fail(state, "unterminated quoted identifier") end if
  text = decode(bytes(output))
  if len(text) == 0 then return fail(state, "quoted identifier must not be empty") end if
  appendToken(state, token.TokenKind.Identifier, text, text, startOffset, startLine, startColumn, true)
  return true
end function

function readQuotedIdentifier(state)
  startOffset = state.index
  startLine = state.line
  startColumn = state.column
  advance(state)
  output = []
  closed = false
  while current(state) >= 0
    value = current(state)
    if value == 34 then
      if peek(state, 1) == 34 then
        output = output + [34]
        advance(state)
        advance(state)
      else
        advance(state)
        closed = true
        break
      end if
    else
      output = output + [value]
      advance(state)
    end if
  end while
  if not closed then return fail(state, "unterminated quoted identifier") end if
  text = decode(bytes(output))
  if len(text) == 0 then return fail(state, "quoted identifier must not be empty") end if
  appendToken(state, token.TokenKind.Identifier, text, text, startOffset, startLine, startColumn, true)
  return true
end function

function mysqlEscapeByte(value)
  if value == 48 then return 0 end if
  if value == 98 then return 8 end if
  if value == 110 then return 10 end if
  if value == 114 then return 13 end if
  if value == 116 then return 9 end if
  if value == 90 then return 26 end if
  return value
end function

function readString(state)
  startOffset = state.index
  startLine = state.line
  startColumn = state.column
  advance(state)
  output = []
  closed = false
  while current(state) >= 0
    value = current(state)
    if value == 39 then
      if peek(state, 1) == 39 then
        output = output + [39]
        advance(state)
        advance(state)
      else
        advance(state)
        closed = true
        break
      end if
    else if state.mysqlMode and value == 92 and peek(state, 1) >= 0 then
      advance(state)
      output = output + [mysqlEscapeByte(current(state))]
      advance(state)
    else
      output = output + [value]
      advance(state)
    end if
  end while
  if not closed then return fail(state, "unterminated string literal") end if
  value = decode(bytes(output))
  appendToken(state, token.TokenKind.StringLiteral, rawText(state, startOffset, state.index), value, startOffset, startLine, startColumn, false)
  return true
end function

function readDoubleString(state)
  startOffset = state.index
  startLine = state.line
  startColumn = state.column
  advance(state)
  output = []
  closed = false
  while current(state) >= 0
    value = current(state)
    if value == 34 then
      if peek(state, 1) == 34 then
        output = output + [34]
        advance(state)
        advance(state)
      else
        advance(state)
        closed = true
        break
      end if
    else if state.mysqlMode and value == 92 and peek(state, 1) >= 0 then
      advance(state)
      output = output + [mysqlEscapeByte(current(state))]
      advance(state)
    else
      output = output + [value]
      advance(state)
    end if
  end while
  if not closed then return fail(state, "unterminated string literal") end if
  value = decode(bytes(output))
  appendToken(state, token.TokenKind.StringLiteral, rawText(state, startOffset, state.index), value, startOffset, startLine, startColumn, false)
  return true
end function

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
  if state.mysqlMode and first == 33 then advance(state); return token.create(token.TokenKind.Keyword, "NOT", "NOT", startOffset, startLine, startColumn, false) end if
  if state.mysqlMode and first == 38 and second == 38 then advance(state); advance(state); return token.create(token.TokenKind.Keyword, "AND", "AND", startOffset, startLine, startColumn, false) end if
  if first == 124 and second == 124 then
    advance(state)
    advance(state)
    if state.mysqlMode then return token.create(token.TokenKind.Keyword, "OR", "OR", startOffset, startLine, startColumn, false) end if
    return token.create(token.TokenKind.Concat, "||", void, startOffset, startLine, startColumn, false)
  end if
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

function tokenizeWithMode(source, mysqlMode)
  if typeof(source) != "string" then return error(INVALID_ARGUMENT, "sql.lexer.tokenizeSql: source must be string") end if
  raw = bytes(source)
  if len(raw) > MAX_SQL_BYTES then return error(INVALID_ARGUMENT, "sql.lexer.tokenizeSql: SQL text exceeds 1 MiB") end if
  state = LexerState(source, raw, 0, 1, 1, [], mysqlMode)
  while state.index < len(raw)
    skipIgnored(state)
    if state.index >= len(raw) then break end if
    value = current(state)
    if isIdentifierStart(value) then
      readIdentifier(state)
    else if mysqlMode and value == 96 then
      readBacktickIdentifier(state)
    else if mysqlMode and value == 34 then
      readDoubleString(state)
    else if value == 34 then
      readQuotedIdentifier(state)
    else if value == 39 then
      readString(state)
    else if isDigit(value) then
      readNumber(state)
    else
      produced = symbolToken(state)
      state.tokens = state.tokens + [produced]
    end if
  end while
  state.tokens = state.tokens + [token.eof(state.index, state.line, state.column)]
  return state.tokens
end function

function tokenizeSql(source)
  return tokenizeWithMode(source, false)
end function

function tokenizeMySql(source)
  return tokenizeWithMode(source, true)
end function

function componentName()
  return "sql.lexer"
end function

function targetMilestone()
  return "M12"
end function

function isImplemented()
  return true
end function
