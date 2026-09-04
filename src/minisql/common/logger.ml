//! Provides minisql common logger facilities for this project.

package minisql.common.logger
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import std.string_builder as string_builder
import std.time as time_api
import minisql.platform.clock as clock
import minisql.platform.file as file_api

/// Process-wide, thread-safe operational logger. Synchronized entry points form

const INVALID_ARGUMENT = 9001
/// Defines the io failure constant used by the minisql common logger module.
const IO_FAILURE = 9005

/// Defines the level debug constant used by the minisql common logger module.
const LEVEL_DEBUG = 10
/// Defines the level info constant used by the minisql common logger module.
const LEVEL_INFO = 20
/// Defines the level warning constant used by the minisql common logger module.
const LEVEL_WARNING = 30
/// Defines the level error constant used by the minisql common logger module.
const LEVEL_ERROR = 40

/// Stores module-wide logger configured state for the minisql common logger module.
synchronized loggerConfigured = false
/// Stores module-wide logger minimum level state for the minisql common logger module.
synchronized loggerMinimumLevel = LEVEL_INFO
/// Stores module-wide logger stdout enabled state for the minisql common logger module.
synchronized loggerStdoutEnabled = true
/// Stores module-wide logger file enabled state for the minisql common logger module.
synchronized loggerFileEnabled = false
/// Stores module-wide logger binlog enabled state for the minisql common logger module.
synchronized loggerBinlogEnabled = false
/// Stores module-wide logger directory state for the minisql common logger module.
synchronized loggerDirectory = "./logs"
/// Stores module-wide logger file name state for the minisql common logger module.
synchronized loggerFileName = "minisql.log"
/// Stores module-wide logger binlog file name state for the minisql common logger module.
synchronized loggerBinlogFileName = "minisql-bin.log"
/// Stores module-wide logger rotation milliseconds state for the minisql common logger module.
synchronized loggerRotationMilliseconds = 86400000
/// Stores module-wide logger file state for the minisql common logger module.
synchronized loggerFile = void
/// Stores module-wide logger binlog file state for the minisql common logger module.
synchronized loggerBinlogFile = void
/// Stores module-wide logger opened at state for the minisql common logger module.
synchronized loggerOpenedAt = 0
/// Stores module-wide logger binlog opened at state for the minisql common logger module.
synchronized loggerBinlogOpenedAt = 0
/// Stores module-wide logger rotation sequence state for the minisql common logger module.
synchronized loggerRotationSequence = 0
/// Stores module-wide logger last log archive state for the minisql common logger module.
synchronized loggerLastLogArchive = ""
/// Stores module-wide logger last binlog archive state for the minisql common logger module.
synchronized loggerLastBinlogArchive = ""

/// Creates a structured logger error.
/// Inputs: `code`, `operation`, `message`. Returns an error with stable component context.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "common.logger." + operation + ": " + message)
end function

/// Converts a configured textual level to its ordered numeric severity.
/// Inputs: `value`. Returns a level constant or an invalid-argument error.
/// @param value Value consumed or transformed by the operation.
function parseLevel(value)
  if value == "debug" or value == "DEBUG" then return LEVEL_DEBUG end if
  if value == "info" or value == "INFO" then return LEVEL_INFO end if
  if value == "warning" or value == "WARNING" or value == "warn" or value == "WARN" then return LEVEL_WARNING end if
  if value == "error" or value == "ERROR" then return LEVEL_ERROR end if
  return fail(INVALID_ARGUMENT, "parseLevel", "level must be debug, info, warning or error")
end function

/// Returns the canonical uppercase label for a numeric severity.
/// Inputs: `level`. Returns DEBUG, INFO, WARNING, or ERROR.
/// @param level level value consumed by this operation.
function levelName(level)
  if level == LEVEL_DEBUG then return "DEBUG" end if
  if level == LEVEL_INFO then return "INFO" end if
  if level == LEVEL_WARNING then return "WARNING" end if
  if level == LEVEL_ERROR then return "ERROR" end if
  return "UNKNOWN"
end function

/// Formats an integer with at least two decimal digits.
/// Inputs: `value`. Returns a zero-padded string.
/// @param value Value consumed or transformed by the operation.
function pad2(value)
  if value < 10 then return "0" + value end if
  return "" + value
end function

/// Formats a year with at least four decimal digits.
/// Inputs: `value`. Returns a zero-padded string.
/// @param value Value consumed or transformed by the operation.
function pad4(value)
  if value < 10 then return "000" + value end if
  if value < 100 then return "00" + value end if
  if value < 1000 then return "0" + value end if
  return "" + value
end function

/// Captures local wall-clock text for record display and collision-resistant
/// rolled-file suffixes from the same SYSTEMTIME snapshot.
/// Takes no caller inputs. Returns `[displayTimestamp, fileTimestamp]`.
function timestampParts()
  current = time_api.datetime.nowLocal()
  if current is void then return ["0000-00-00 00:00:00", "00000000-000000"] end if
  year = current.date.year
  month = current.date.month
  day = current.date.day
  hour = current.time.hour
  minute = current.time.minute
  second = current.time.second
  display = pad4(year) + "-" + pad2(month) + "-" + pad2(day) + " " + pad2(hour) + ":" + pad2(minute) + ":" + pad2(second)
  suffix = pad4(year) + pad2(month) + pad2(day) + "-" + pad2(hour) + pad2(minute) + pad2(second)
  return [display, suffix]
end function

/// Rejects path separators so configured file names cannot escape the selected
/// log directory.
/// Inputs: `value`, `name`. Returns true or an invalid-argument error.
/// @param value Value consumed or transformed by the operation.
/// @param name Name of the affected item.
function validateFileName(value, name)
  if typeof(value) != "string" or len(value) == 0 then return fail(INVALID_ARGUMENT, "configure", name + " must be non-empty") end if
  raw = bytes(value)
  for each byteValue in raw
    if byteValue == 47 or byteValue == 92 or byteValue == 58 or byteValue == 0 then return fail(INVALID_ARGUMENT, "configure", name + " must be a file name without path separators") end if
  end for
  return true
end function

/// Closes an optional file handle and preserves logger shutdown idempotence.
/// Inputs: `handle`. Returns true when no open handle remains.
/// @param handle Native or runtime handle used by the operation.
function closeHandle(handle)
  if handle is void then return true end if
  if handle.closed then return true end if
  return file_api.close(handle)
end function

/// Opens an append-capable log file inside the configured directory.
/// Inputs: `name`. Returns an open writable handle.
/// @param name Name of the affected item.
function openLogFile(name)
  global loggerDirectory
  return file_api.openReadWrite(file_api.joinPath(loggerDirectory, name), true)
end function

/// Configures the singleton and opens enabled file destinations eagerly so a
/// bad path fails server startup rather than silently losing later records.
/// Inputs: level/destination/rotation/binlog settings. Returns true when ready.
/// @param level level value consumed by this operation.
/// @param directory directory value consumed by this operation.
/// @param stdoutEnabled stdoutEnabled value consumed by this operation.
/// @param fileEnabled fileEnabled value consumed by this operation.
/// @param fileName fileName value consumed by this operation.
/// @param rotationHours rotationHours value consumed by this operation.
/// @param binlogEnabled binlogEnabled value consumed by this operation.
/// @param binlogFileName binlogFileName value consumed by this operation.
function synchronized configure(level, directory, stdoutEnabled, fileEnabled, fileName, rotationHours, binlogEnabled, binlogFileName)
  global loggerConfigured, loggerMinimumLevel, loggerStdoutEnabled, loggerFileEnabled, loggerBinlogEnabled, loggerDirectory, loggerFileName, loggerBinlogFileName, loggerRotationMilliseconds, loggerFile, loggerBinlogFile, loggerOpenedAt, loggerBinlogOpenedAt, loggerLastLogArchive, loggerLastBinlogArchive
  parsedLevel = parseLevel(level)
  if typeof(directory) != "string" or len(directory) == 0 then return fail(INVALID_ARGUMENT, "configure", "log directory must be non-empty") end if
  if typeof(stdoutEnabled) != "bool" or typeof(fileEnabled) != "bool" or typeof(binlogEnabled) != "bool" then return fail(INVALID_ARGUMENT, "configure", "destination flags must be bool") end if
  if not stdoutEnabled and not fileEnabled then return fail(INVALID_ARGUMENT, "configure", "at least one ordinary log destination must be enabled") end if
  if typeof(rotationHours) != "int" or rotationHours < 1 or rotationHours > 87600 then return fail(INVALID_ARGUMENT, "configure", "rotationHours must be in 1..87600") end if
  validateFileName(fileName, "fileName")
  validateFileName(binlogFileName, "binlogFileName")
  if fileName == binlogFileName then return fail(INVALID_ARGUMENT, "configure", "ordinary log and binlog must use different file names") end if

  closeHandle(loggerFile)
  closeHandle(loggerBinlogFile)
  loggerFile = void
  loggerBinlogFile = void
  if not file_api.directoryExists(directory) then file_api.createDirectory(directory) end if
  loggerMinimumLevel = parsedLevel
  loggerStdoutEnabled = stdoutEnabled
  loggerFileEnabled = fileEnabled
  loggerBinlogEnabled = binlogEnabled
  loggerDirectory = directory
  loggerFileName = fileName
  loggerBinlogFileName = binlogFileName
  loggerLastLogArchive = ""
  loggerLastBinlogArchive = ""
  loggerRotationMilliseconds = rotationHours * 3600000
  if loggerFileEnabled then loggerFile = openLogFile(loggerFileName) end if
  if loggerBinlogEnabled then loggerBinlogFile = openLogFile(loggerBinlogFileName) end if
  now = clock.monotonicMilliseconds()
  loggerOpenedAt = now
  loggerBinlogOpenedAt = now
  loggerConfigured = true
  return true
end function

/// Produces a unique archive path for one active file.
/// Inputs: `activeName`, `timestamp`. Returns a path inside the log directory.
/// @param activeName activeName value consumed by this operation.
/// @param timestamp timestamp value consumed by this operation.
function nextArchivePath(activeName, timestamp)
  global loggerDirectory, loggerRotationSequence
  loggerRotationSequence = loggerRotationSequence + 1
  return file_api.joinPath(loggerDirectory, activeName + "." + timestamp + "." + loggerRotationSequence)
end function

/// Rolls one destination by closing, renaming a non-empty active file, and
/// opening a fresh active name. The caller holds the singleton monitor.
/// Inputs: `handle`, `activeName`, `timestamp`. Returns the new handle.
/// @param handle Native or runtime handle used by the operation.
/// @param activeName activeName value consumed by this operation.
/// @param timestamp timestamp value consumed by this operation.
function rollHandle(handle, activeName, timestamp)
  global loggerDirectory, loggerFileName, loggerBinlogFileName, loggerLastLogArchive, loggerLastBinlogArchive
  activePath = file_api.joinPath(loggerDirectory, activeName)
  hasContent = false
  if handle is not void and not handle.closed then hasContent = file_api.size(handle) > 0; file_api.close(handle) end if
  if hasContent and file_api.fileExists(activePath) then
    archivePath = nextArchivePath(activeName, timestamp)
    file_api.movePath(activePath, archivePath, false)
    if activeName == loggerFileName then loggerLastLogArchive = archivePath end if
    if activeName == loggerBinlogFileName then loggerLastBinlogArchive = archivePath end if
  end if
  return openLogFile(activeName)
end function

/// Rolls elapsed file destinations before the next record is appended.
/// Inputs: `now`, `timestamp`. Returns true after both destinations are current.
/// @param now now value consumed by this operation.
/// @param timestamp timestamp value consumed by this operation.
function rotateIfDue(now, timestamp)
  global loggerFileEnabled, loggerBinlogEnabled, loggerRotationMilliseconds, loggerFile, loggerBinlogFile, loggerOpenedAt, loggerBinlogOpenedAt
  if loggerFileEnabled and now - loggerOpenedAt >= loggerRotationMilliseconds then
    loggerFile = rollHandle(loggerFile, loggerFileName, timestamp)
    loggerOpenedAt = now
  end if
  if loggerBinlogEnabled and now - loggerBinlogOpenedAt >= loggerRotationMilliseconds then
    loggerBinlogFile = rollHandle(loggerBinlogFile, loggerBinlogFileName, timestamp)
    loggerBinlogOpenedAt = now
  end if
  return true
end function

/// Appends and flushes one line so a successful call makes the record durable.
/// Inputs: `handle`, `line`. Returns true after the newline reaches the file.
/// @param handle Native or runtime handle used by the operation.
/// @param line line value consumed by this operation.
function appendLine(handle, line)
  encoded = bytes(line + "\r\n")
  file_api.append(handle, encoded, 0, len(encoded))
  file_api.flush(handle)
  return true
end function

/// Writes one severity-filtered operational record to every enabled destination.
/// Inputs: `level`, `component`, `message`. Returns false only if a destination fails.
/// @param level level value consumed by this operation.
/// @param component component value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function synchronized write(level, component, message)
  global loggerConfigured, loggerMinimumLevel, loggerStdoutEnabled, loggerFileEnabled, loggerFile
  if not loggerConfigured then return false end if
  if typeof(level) != "int" or (level != LEVEL_DEBUG and level != LEVEL_INFO and level != LEVEL_WARNING and level != LEVEL_ERROR) then return false end if
  if level < loggerMinimumLevel then return true end if
  if typeof(component) != "string" or len(component) == 0 or typeof(message) != "string" then return false end if
  parts = timestampParts()
  line = "[" + levelName(level) + "] " + parts[0] + " " + component + " " + message
  rotated = try(rotateIfDue(clock.monotonicMilliseconds(), parts[1]))
  if typeof(rotated) == "error" then if loggerStdoutEnabled then print "[ERROR] " + parts[0] + " minisql.common.logger.write log rotation failed: " + rotated.message end if; return false end if
  // Persist first so a console-host stall cannot hide the last attempted event.
  // Operational server startup disables Windows QuickEdit to keep stdout live.
  if loggerFileEnabled then
    persisted = try(appendLine(loggerFile, line))
    if typeof(persisted) == "error" then if loggerStdoutEnabled then print "[ERROR] " + parts[0] + " minisql.common.logger.write file append failed: " + persisted.message end if; return false end if
  end if
  if loggerStdoutEnabled then print line end if
  return true
end function

/// Writes a DEBUG record.
/// Inputs: `component`, `message`. Returns the singleton write status.
/// @param component component value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function debug(component, message)
  return write(LEVEL_DEBUG, component, message)
end function

/// Writes an INFO record.
/// Inputs: `component`, `message`. Returns the singleton write status.
/// @param component component value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function info(component, message)
  return write(LEVEL_INFO, component, message)
end function

/// Writes a WARNING record.
/// Inputs: `component`, `message`. Returns the singleton write status.
/// @param component component value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function warning(component, message)
  return write(LEVEL_WARNING, component, message)
end function

/// Writes an ERROR record.
/// Inputs: `component`, `message`. Returns the singleton write status.
/// @param component component value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function errorLog(component, message)
  return write(LEVEL_ERROR, component, message)
end function

/// Escapes control characters so each SQL command occupies exactly one binlog
/// record while retaining its complete text reversibly.
/// Inputs: `sqlText`. Returns escaped SQL text.
/// @param sqlText sqlText value consumed by this operation.
function escapeSql(sqlText)
  if typeof(sqlText) != "string" then return "" end if
  builder = string_builder.StringBuilder.withCapacity(len(bytes(sqlText)) + 16)
  raw = bytes(sqlText)
  runStart = 0
  if len(raw) > 0 then
    for index = 0 to len(raw) - 1
      value = raw[index]
      special = value == 13 or value == 10 or value == 9 or value == 92 or value == 0
      if special then
        if index > runStart then builder.appendSlice(sqlText, runStart, index - runStart) end if
        if value == 13 then builder.appendString("\\r") else if value == 10 then builder.appendString("\\n") else if value == 9 then builder.appendString("\\t") else if value == 92 then builder.appendString("\\\\") else builder.appendString("\\0") end if
        runStart = index + 1
      end if
    end for
    if runStart < len(raw) then builder.appendSlice(sqlText, runStart, len(raw) - runStart) end if
  end if
  return builder.toString()
end function

/// Durably records one SQL command independently of the ordinary log threshold.
/// Inputs: `component`, `sqlText`. Returns true when disabled or successfully appended.
/// @param component component value consumed by this operation.
/// @param sqlText sqlText value consumed by this operation.
function synchronized binlog(component, sqlText)
  global loggerConfigured, loggerBinlogEnabled, loggerBinlogFile, loggerStdoutEnabled
  if not loggerConfigured or not loggerBinlogEnabled then return true end if
  if typeof(component) != "string" or len(component) == 0 or typeof(sqlText) != "string" then return false end if
  parts = timestampParts()
  rotated = try(rotateIfDue(clock.monotonicMilliseconds(), parts[1]))
  if typeof(rotated) == "error" then if loggerStdoutEnabled then print "[ERROR] " + parts[0] + " minisql.common.logger.binlog rotation failed: " + rotated.message end if; return false end if
  line = "[BINLOG] " + parts[0] + " " + component + " " + escapeSql(sqlText)
  persisted = try(appendLine(loggerBinlogFile, line))
  if typeof(persisted) == "error" then if loggerStdoutEnabled then print "[ERROR] " + parts[0] + " minisql.common.logger.binlog append failed: " + persisted.message end if; return false end if
  return true
end function

/// Forces both enabled destinations to roll immediately. This is useful for
/// administrative rotation and deterministic tests without waiting for hours.
/// Takes no caller inputs. Returns true after fresh active files are open.
function synchronized rotateNow()
  global loggerConfigured, loggerFileEnabled, loggerBinlogEnabled, loggerFile, loggerBinlogFile, loggerOpenedAt, loggerBinlogOpenedAt
  if not loggerConfigured then return false end if
  parts = timestampParts()
  now = clock.monotonicMilliseconds()
  if loggerFileEnabled then loggerFile = rollHandle(loggerFile, loggerFileName, parts[1]); loggerOpenedAt = now end if
  if loggerBinlogEnabled then loggerBinlogFile = rollHandle(loggerBinlogFile, loggerBinlogFileName, parts[1]); loggerBinlogOpenedAt = now end if
  return true
end function

/// Returns the most recently created ordinary-log archive path, or an empty string before the first non-empty roll.
/// Takes no caller inputs. Returns a stable snapshot under the singleton monitor.
function synchronized lastLogArchivePath()
  global loggerLastLogArchive
  return loggerLastLogArchive
end function

/// Returns the most recently created binlog archive path, or an empty string before the first non-empty roll.
/// Takes no caller inputs. Returns a stable snapshot under the singleton monitor.
function synchronized lastBinlogArchivePath()
  global loggerLastBinlogArchive
  return loggerLastBinlogArchive
end function

/// Flushes, closes, and disables the singleton destinations.
/// Takes no caller inputs. Returns true after logger shutdown.
function synchronized close()
  global loggerConfigured, loggerFile, loggerBinlogFile
  if not loggerConfigured then return true end if
  first = try(closeHandle(loggerFile))
  second = try(closeHandle(loggerBinlogFile))
  loggerFile = void
  loggerBinlogFile = void
  loggerConfigured = false
  if typeof(first) == "error" then return first end if
  if typeof(second) == "error" then return second end if
  return true
end function

/// Performs the componentName operation for the minisql common logger module.
/// Takes no caller inputs. Returns `common.logger`.
function componentName()
  return "common.logger"
end function

/// Returns the milestone introducing the singleton operational logger.
/// Takes no caller inputs. Returns `M51`.
function targetMilestone()
  return "M51"
end function

/// Returns whether implemented satisfies the condition required by the minisql common logger module.
/// Takes no caller inputs. Returns true.
function isImplemented()
  return true
end function
