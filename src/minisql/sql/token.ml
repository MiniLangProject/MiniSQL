package minisql.sql.token

// Token model for the MiniSQL SQL 1.0 grammar. Keywords use one token kind and
// carry an upper-case canonical text value. Quoted identifiers remain
// identifiers and preserve exact spelling.

enum TokenKind
  EndOfInput = 0
  Identifier = 1
  Keyword = 2
  IntegerLiteral = 3
  FloatLiteral = 4
  StringLiteral = 5
  Comma = 6
  Dot = 7
  Star = 8
  LeftParen = 9
  RightParen = 10
  Semicolon = 11
  Equal = 12
  NotEqual = 13
  Less = 14
  LessEqual = 15
  Greater = 16
  GreaterEqual = 17
  Plus = 18
  Minus = 19
  Slash = 20
  Percent = 21
  Concat = 22
  Parameter = 23
end enum

struct Token
  kind
  text
  value
  offset
  line
  column
  quoted
end struct

function create(kind, text, value, offset, line, column, quoted)
  if typeof(kind) != "int" or kind < 0 or kind > 65535 then return error(9001, "sql.token.create: kind must fit U16") end if
  if typeof(text) != "string" or typeof(offset) != "int" or offset < 0 or typeof(line) != "int" or line <= 0 or typeof(column) != "int" or column <= 0 or typeof(quoted) != "bool" then
    return error(9001, "sql.token.create: invalid token metadata")
  end if
  return Token(kind, text, value, offset, line, column, quoted)
end function

function eof(offset, line, column)
  return create(TokenKind.EndOfInput, "", void, offset, line, column, false)
end function

function isKind(value, kind)
  return value is Token and value.kind == kind
end function

function isKeyword(value, keyword)
  return value is Token and value.kind == TokenKind.Keyword and value.text == keyword
end function

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

function componentName()
  return "sql.token"
end function

function targetMilestone()
  return "M12"
end function

function isImplemented()
  return true
end function
