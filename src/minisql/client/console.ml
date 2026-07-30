package minisql.client.console

import minisql.client.client as client
import minisql.client.formatter as formatter
import minisql.common.uuid as uuid
import minisql.common.endian as endian
import minisql.platform.file as file_api
import minisql.protocol.constants as constants

const INVALID_ARGUMENT = 9001
const IO_FAILURE = 9005
const STD_INPUT_HANDLE = -10
const STD_OUTPUT_HANDLE = -11
const ENABLE_ECHO_INPUT = 4
const CP_UTF8 = 65001
const WC_ERR_INVALID_CHARS = 0x80
const MAX_PASSWORD_UTF16_UNITS = 1024

struct SqlBatch
  statements
  remainder
end struct

extern function GetStdHandle(kind as i32) from "kernel32.dll" symbol "GetStdHandle" returns ptr
extern function GetConsoleMode(handle as ptr, mode as bytes) from "kernel32.dll" symbol "GetConsoleMode" returns bool
extern function SetConsoleMode(handle as ptr, mode as u32) from "kernel32.dll" symbol "SetConsoleMode" returns bool
extern function ReadConsoleW(handle as ptr, buffer as bytes, count as u32, readOut as bytes, control as ptr) from "kernel32.dll" symbol "ReadConsoleW" returns bool
extern function WriteConsoleW(handle as ptr, text as wstr, count as u32, writtenOut as bytes, reserved as ptr) from "kernel32.dll" symbol "WriteConsoleW" returns bool
extern function WideCharToMultiByte(codePage as u32, flags as u32, wideText as bytes, wideCount as i32, output as bytes, outputCount as i32, defaultChar as ptr, usedDefault as ptr) from "kernel32.dll" symbol "WideCharToMultiByte" returns i32

function fail(code, operation, message)
  return error(code, "client.console." + operation + ": " + message)
end function

function isMetaCommand(text)
  return typeof(text) == "string" and len(text) > 0 and bytes(text)[0] == 92
end function

function executeOnce(activeClient, sqlText)
  return formatter.formatResponse(client.query(activeClient, sqlText))
end function

function wipePassword(passwordBytes)
  return uuid.wipeSecret(passwordBytes)
end function

function writePrompt(outputHandle, prompt)
  if typeof(prompt) != "string" then return fail(INVALID_ARGUMENT, "writePrompt", "prompt must be string") end if
  promptBytes = bytes(prompt)
  for each value in promptBytes
    if value > 127 then return fail(INVALID_ARGUMENT, "writePrompt", "prompt must be ASCII") end if
  end for
  written = bytes(4, 0)
  if not WriteConsoleW(outputHandle, prompt, len(promptBytes), written, void) then return fail(IO_FAILURE, "writePrompt", "WriteConsoleW failed") end if
  return true
end function

function utf16PasswordToUtf8(wide, units)
  if typeof(wide) != "bytes" or typeof(units) != "int" or units < 0 or units > MAX_PASSWORD_UTF16_UNITS then return fail(INVALID_ARGUMENT, "utf16PasswordToUtf8", "invalid UTF-16 input") end if
  if units == 0 then return bytes(0) end if
  required = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, wide, units, void, 0, void, void)
  if required <= 0 or required > 4096 then return fail(IO_FAILURE, "utf16PasswordToUtf8", "password is not valid UTF-16") end if
  output = bytes(required, 0)
  actual = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, wide, units, output, required, void, void)
  if actual != required then uuid.wipeSecret(output); return fail(IO_FAILURE, "utf16PasswordToUtf8", "UTF-8 conversion failed") end if
  return output
end function

function readPassword(prompt)
  if typeof(prompt) != "string" then return fail(INVALID_ARGUMENT, "readPassword", "prompt must be string") end if
  inputHandle = GetStdHandle(STD_INPUT_HANDLE)
  outputHandle = GetStdHandle(STD_OUTPUT_HANDLE)
  if inputHandle == 0 or inputHandle == -1 or outputHandle == 0 or outputHandle == -1 then return fail(IO_FAILURE, "readPassword", "console handles are unavailable") end if
  modeBytes = bytes(4, 0)
  if not GetConsoleMode(inputHandle, modeBytes) then return fail(IO_FAILURE, "readPassword", "standard input is not a console") end if
  oldMode = endian.readU32LE(modeBytes, 0)
  hiddenMode = oldMode & ~ENABLE_ECHO_INPUT
  if not SetConsoleMode(inputHandle, hiddenMode) then return fail(IO_FAILURE, "readPassword", "cannot disable console echo") end if

  wide = bytes((MAX_PASSWORD_UTF16_UNITS + 2) * 2, 0)
  readOut = bytes(4, 0)
  promptResult = try(writePrompt(outputHandle, prompt))
  readOk = false
  if typeof(promptResult) != "error" then readOk = ReadConsoleW(inputHandle, wide, MAX_PASSWORD_UTF16_UNITS + 1, readOut, void) end if
  restored = SetConsoleMode(inputHandle, oldMode)
  newlineWritten = bytes(4, 0)
  ignoredNewline = WriteConsoleW(outputHandle, "\r\n", 2, newlineWritten, void)

  if typeof(promptResult) == "error" then uuid.wipeSecret(wide); return promptResult end if
  if not restored then uuid.wipeSecret(wide); return fail(IO_FAILURE, "readPassword", "cannot restore console mode") end if
  if not readOk then uuid.wipeSecret(wide); return fail(IO_FAILURE, "readPassword", "ReadConsoleW failed") end if
  units = endian.readU32LE(readOut, 0)
  while units > 0
    last = endian.readU16LE(wide, (units - 1) * 2)
    if last == 10 or last == 13 then units = units - 1 else break end if
  end while
  secret = try(utf16PasswordToUtf8(wide, units))
  uuid.wipeSecret(wide)
  uuid.wipeSecret(readOut)
  if typeof(secret) == "error" then return secret end if
  validated = try(uuid.validatePasswordBytes(secret, "readPassword"))
  uuid.wipeSecret(secret)
  if typeof(validated) == "error" then return validated end if
  return validated
end function

function readPasswordConfirmed(prompt, confirmationPrompt)
  first = try(readPassword(prompt))
  if typeof(first) == "error" then return first end if
  second = try(readPassword(confirmationPrompt))
  if typeof(second) == "error" then uuid.wipeSecret(first); return second end if
  same = uuid.constantTimeEquals(first, second)
  uuid.wipeSecret(second)
  if not same then uuid.wipeSecret(first); return fail(INVALID_ARGUMENT, "readPasswordConfirmed", "password confirmation does not match") end if
  return first
end function

function openAuthenticatedPrompt(address, port, username)
  secret = try(readPassword("Password: "))
  if typeof(secret) == "error" then return secret end if
  active = try(client.openAuthenticatedAddressBytes(address, port, username, secret))
  uuid.wipeSecret(secret)
  if typeof(active) == "error" then return active end if
  return active
end function

function trimAscii(text)
  if typeof(text) != "string" then return fail(INVALID_ARGUMENT, "trimAscii", "text must be string") end if
  raw = bytes(text)
  first = 0
  while first < len(raw) and (raw[first] == 32 or raw[first] == 9 or raw[first] == 10 or raw[first] == 13)
    first = first + 1
  end while
  last = len(raw)
  while last > first and (raw[last - 1] == 32 or raw[last - 1] == 9 or raw[last - 1] == 10 or raw[last - 1] == 13)
    last = last - 1
  end while
  if last == first then return "" end if
  return decode(slice(raw, first, last - first))
end function

function startsWithBytes(text, first, second)
  if typeof(text) != "string" or typeof(first) != "int" or typeof(second) != "int" then return false end if
  raw = bytes(text)
  return len(raw) >= 2 and raw[0] == first and raw[1] == second
end function

function startsWithText(text, prefix)
  if typeof(text) != "string" or typeof(prefix) != "string" then return false end if
  raw = bytes(text)
  prefixRaw = bytes(prefix)
  if len(raw) < len(prefixRaw) then return false end if
  if len(prefixRaw) > 0 then
    for index = 0 to len(prefixRaw) - 1
      if raw[index] != prefixRaw[index] then return false end if
    end for
  end if
  return true
end function

function isScriptComment(line)
  if typeof(line) != "string" or len(line) == 0 then return false end if
  raw = bytes(line)
  if raw[0] == 35 then return true end if
  return startsWithBytes(line, 45, 45)
end function

function splitLines(text)
  if typeof(text) != "string" then return fail(INVALID_ARGUMENT, "splitLines", "text must be string") end if
  raw = bytes(text)
  lines = []
  start = 0
  index = 0
  while index < len(raw)
    if raw[index] == 10 or raw[index] == 13 then
      count = index - start
      part = ""
      if count > 0 then part = decode(slice(raw, start, count)) end if
      lines = lines + [part]
      if raw[index] == 13 and index + 1 < len(raw) and raw[index + 1] == 10 then index = index + 1 end if
      start = index + 1
    end if
    index = index + 1
  end while
  if start < len(raw) then
    lines = lines + [decode(slice(raw, start, len(raw) - start))]
  else if len(raw) == 0 or start == len(raw) then
    lines = lines + [""]
  end if
  return lines
end function

function isSqlBatch(value)
  return value is SqlBatch
end function

function isWhitespaceByte(value)
  return value == 32 or value == 9 or value == 10 or value == 13
end function

function rawText(source, offset, count)
  if count <= 0 then return "" end if
  value = decode(slice(source, offset, count))
  if typeof(value) != "string" then return fail(INVALID_ARGUMENT, "rawText", "SQL text is not valid UTF-8") end if
  return value
end function

function appendSqlFragment(statements, source, startOffset, endOffset, hasToken)
  if not hasToken or endOffset <= startOffset then return statements end if
  text = trimAscii(rawText(source, startOffset, endOffset - startOffset))
  if len(text) == 0 then return statements end if
  return statements + [text]
end function

// Split complete SQL statements without treating semicolons inside quoted
// strings, quoted identifiers or comments as terminators. When finalInput is
// false, an incomplete suffix is returned for the interactive continuation
// prompt. When finalInput is true, a final statement may omit its semicolon.
function scanSqlBatch(text, finalInput)
  if typeof(text) != "string" or typeof(finalInput) != "bool" then return fail(INVALID_ARGUMENT, "scanSqlBatch", "invalid arguments") end if
  source = bytes(text)
  statements = []
  startOffset = 0
  index = 0
  mode = 0 // 0 normal, 1 string, 2 quoted identifier, 3 SQL line comment, 4 block comment, 5 shell hash comment
  hasToken = false
  lineStart = true
  while index < len(source)
    value = source[index]
    nextValue = -1
    if index + 1 < len(source) then nextValue = source[index + 1] end if
    if mode == 1 then
      if value == 39 then
        if nextValue == 39 then index = index + 1 else mode = 0 end if
      end if
    else if mode == 2 then
      if value == 34 then
        if nextValue == 34 then index = index + 1 else mode = 0 end if
      end if
    else if mode == 3 then
      if value == 10 or value == 13 then mode = 0; lineStart = true end if
    else if mode == 5 then
      if value == 10 or value == 13 then
        mode = 0
        lineStart = true
        if not hasToken then startOffset = index + 1 end if
      end if
    else if mode == 4 then
      if value == 42 and nextValue == 47 then mode = 0; index = index + 1 end if
    else
      if value == 39 then
        mode = 1
        hasToken = true
        lineStart = false
      else if value == 34 then
        mode = 2
        hasToken = true
        lineStart = false
      else if value == 45 and nextValue == 45 then
        mode = 3
        index = index + 1
      else if value == 47 and nextValue == 42 then
        mode = 4
        index = index + 1
      else if value == 35 and lineStart then
        mode = 5
      else if value == 59 then
        statements = appendSqlFragment(statements, source, startOffset, index + 1, hasToken)
        startOffset = index + 1
        hasToken = false
        lineStart = true
      else if value == 10 or value == 13 then
        lineStart = true
      else if not isWhitespaceByte(value) then
        hasToken = true
        lineStart = false
      end if
    end if
    index = index + 1
  end while

  if finalInput and mode == 1 then return fail(INVALID_ARGUMENT, "scanSqlBatch", "unterminated SQL string literal") end if
  if finalInput and mode == 2 then return fail(INVALID_ARGUMENT, "scanSqlBatch", "unterminated quoted identifier") end if
  if finalInput and mode == 4 then return fail(INVALID_ARGUMENT, "scanSqlBatch", "unterminated block comment") end if

  remainder = ""
  if startOffset < len(source) then remainder = trimAscii(rawText(source, startOffset, len(source) - startOffset)) end if
  if finalInput then
    if hasToken and len(remainder) > 0 then statements = statements + [remainder] end if
    remainder = ""
  else if not hasToken then
    remainder = ""
  end if
  return SqlBatch(statements, remainder)
end function

function splitSqlStatements(text)
  return scanSqlBatch(text, true).statements
end function

function printQueryResponse(response)
  formatted = try(formatter.formatResponse(response))
  if typeof(formatted) == "error" then return formatted end if
  print formatted
  return true
end function

function executeStatements(activeClient, statements)
  if typeof(statements) != "array" then return fail(INVALID_ARGUMENT, "executeStatements", "statements must be array") end if
  executed = 0
  for each statement in statements
    response = try(client.query(activeClient, statement))
    if typeof(response) == "error" then return response end if
    printed = try(printQueryResponse(response))
    if typeof(printed) == "error" then return printed end if
    if response.status == constants.STATUS_ERROR then return fail(response.errorCode, "executeStatements", response.message) end if
    executed = executed + 1
  end for
  return executed
end function

function runScript(activeClient, path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "runScript", "path must be non-empty") end if
  content = try(file_api.readAllText(path, 1048576))
  if typeof(content) == "error" then return content end if
  batch = try(scanSqlBatch(content, true))
  if typeof(batch) == "error" then return batch end if
  return executeStatements(activeClient, batch.statements)
end function

function commandArgument(line, prefix)
  if typeof(line) != "string" or typeof(prefix) != "string" then return "" end if
  raw = bytes(line)
  prefixRaw = bytes(prefix)
  if len(raw) <= len(prefixRaw) then return "" end if
  return trimAscii(rawText(raw, len(prefixRaw), len(raw) - len(prefixRaw)))
end function

function isIdentifierByte(value, first)
  if value >= 65 and value <= 90 then return true end if
  if value >= 97 and value <= 122 then return true end if
  if value == 95 then return true end if
  return not first and value >= 48 and value <= 57
end function

function isSafeMetaIdentifier(value)
  if typeof(value) != "string" or len(value) == 0 then return false end if
  raw = bytes(value)
  if not isIdentifierByte(raw[0], true) then return false end if
  if len(raw) > 1 then
    for index = 1 to len(raw) - 1
      if not isIdentifierByte(raw[index], false) then return false end if
    end for
  end if
  return true
end function

function printShellHelp()
  print "MiniSQL shell commands:"
  print "  \\q or \\quit          close the session"
  print "  \\g                    execute the current multiline buffer"
  print "  \\reset                clear the current multiline buffer"
  print "  \\source <file>        execute a UTF-8 SQL script"
  print "  \\tables               list tables"
  print "  \\describe <table>     describe columns"
  print "  \\indexes <table>      list indexes and key constraints"
  print "  \\ping                 test the connection"
  print "  \\help                 show this help"
  print "SQL statements may span lines and end with ';'. Strings, quoted identifiers and comments are scanned safely."
  return true
end function

function executeMeta(activeClient, line)
  if line == "\\ping" then
    pong = try(client.ping(activeClient))
    if typeof(pong) == "error" then print "ERROR " + pong.code + ": " + pong.message else if pong then print "PONG" else print "PING failed" end if
    return true
  end if
  if line == "\\tables" then
    response = try(client.query(activeClient, "SHOW TABLES"))
    if typeof(response) == "error" then print "ERROR " + response.code + ": " + response.message else ignored = try(printQueryResponse(response)) end if
    return true
  end if
  if startsWithText(line, "\\describe ") then
    tableName = commandArgument(line, "\\describe")
    if isSafeMetaIdentifier(tableName) then
      response = try(client.query(activeClient, "DESCRIBE " + tableName))
      if typeof(response) == "error" then print "ERROR " + response.code + ": " + response.message else ignored = try(printQueryResponse(response)) end if
      return true
    end if
  end if
  if startsWithText(line, "\\indexes ") then
    tableName = commandArgument(line, "\\indexes")
    if isSafeMetaIdentifier(tableName) then
      response = try(client.query(activeClient, "SHOW INDEXES FROM " + tableName))
      if typeof(response) == "error" then print "ERROR " + response.code + ": " + response.message else ignored = try(printQueryResponse(response)) end if
      return true
    end if
  end if
  return false
end function

function runShell(activeClient, prompt)
  if typeof(prompt) != "string" then return fail(INVALID_ARGUMENT, "runShell", "prompt must be string") end if
  print "MiniSQL interactive client. Type \\help for help and \\q to quit."
  buffer = ""
  while true
    activePrompt = prompt
    if len(buffer) > 0 then activePrompt = "...> " end if
    sourceLine = input(activePrompt)
    if typeof(sourceLine) != "string" then break end if
    line = try(trimAscii(sourceLine))
    if typeof(line) == "error" then return line end if

    if line == "\\reset" then buffer = ""; continue end if
    if line == "\\g" then
      batch = try(scanSqlBatch(buffer, true))
      if typeof(batch) == "error" then print "ERROR " + batch.code + ": " + batch.message else ignored = try(executeStatements(activeClient, batch.statements)) end if
      buffer = ""
      continue
    end if

    if len(buffer) == 0 and isMetaCommand(line) then
      if line == "\\q" or line == "\\quit" then break end if
      if line == "\\help" then printShellHelp(); continue end if
      if line == "\\source" then print "Usage: \\source <file>"; continue end if
      if startsWithText(line, "\\source ") then
        path = commandArgument(line, "\\source")
        if len(path) > 0 then
          result = try(runScript(activeClient, path))
          if typeof(result) == "error" then print "ERROR " + result.code + ": " + result.message else print "MiniSQL script completed statements=" + result end if
          continue
        end if
      end if
      if executeMeta(activeClient, line) then continue end if
      print "Unknown command: " + line
      continue
    end if

    buffer = buffer + sourceLine + "\n"
    batch = try(scanSqlBatch(buffer, false))
    if typeof(batch) == "error" then print "ERROR " + batch.code + ": " + batch.message; buffer = ""; continue end if
    if len(batch.statements) > 0 then
      executed = try(executeStatements(activeClient, batch.statements))
      if typeof(executed) == "error" then print "ERROR " + executed.code + ": " + executed.message end if
    end if
    buffer = batch.remainder
  end while
  if len(buffer) > 0 then
    batch = try(scanSqlBatch(buffer, true))
    if typeof(batch) == "error" then return batch end if
    executeStatements(activeClient, batch.statements)
  end if
  return true
end function

function componentName()
  return "client.console"
end function

function targetMilestone()
  return "M18"
end function

function isImplemented()
  return true
end function
