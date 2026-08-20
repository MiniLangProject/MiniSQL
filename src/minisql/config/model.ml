package minisql.config.model

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

// Groups the paths config state and preserves the field relationships documented below.
struct PathsConfig
  // Stores the data root associated with this value.
  dataRoot
  // Indicates whether the temporary root condition is active.
  temporaryRoot
  // Stores the log directory associated with this value.
  logDirectory
end struct

// Groups the server config state and preserves the field relationships documented below.
struct ServerConfig
  // Stores the bind address associated with this value.
  bindAddress
  // Tracks the port numeric value.
  port
  // Stores the max connections associated with this value.
  maxConnections
  // Tracks the max statement bytes numeric value.
  maxStatementBytes
  // Tracks the max frame bytes numeric value.
  maxFrameBytes
end struct

// Groups the runtime config state and preserves the field relationships documented below.
struct RuntimeConfig
  // Tracks the buffer pool bytes numeric value.
  bufferPoolBytes
  // Tracks the query timeout ms numeric value.
  queryTimeoutMs
  // Tracks the checkpoint WAL bytes numeric value.
  checkpointWalBytes
  // Indicates whether the temporary memory bytes condition is active.
  temporaryMemoryBytes
  // Stores the log level associated with this value.
  logLevel
end struct

// Defines ordinary server-log destinations and time-based file rotation.
struct LoggingConfig
  // Enables writing each accepted log record to standard output.
  stdoutEnabled
  // Enables writing the same accepted record to the active log file.
  fileEnabled
  // Names the active log file inside `paths.logDirectory`.
  fileName
  // Selects the number of elapsed hours after which the active file is rolled.
  rotationHours
end struct

// Defines the independent SQL statement log. Binlog records bypass the
// ordinary severity threshold so enabling it always captures every statement.
struct BinlogConfig
  // Enables durable SQL statement recording.
  enabled
  // Names the active binlog file inside `paths.logDirectory`.
  fileName
end struct

// Groups the database defaults state and preserves the field relationships documented below.
struct DatabaseDefaults
  // Tracks the page size numeric value.
  pageSize
  // Stores the checksum algorithm associated with this value.
  checksumAlgorithm
  // Tracks the WAL segment bytes numeric value.
  walSegmentBytes
  // Stores the text encoding associated with this value.
  textEncoding
  // Stores the default collation associated with this value.
  defaultCollation
  // Tracks the database format version numeric value.
  databaseFormatVersion
  // Tracks the table file format version numeric value.
  tableFileFormatVersion
  // Tracks the index file format version numeric value.
  indexFileFormatVersion
  // Tracks the WAL format version numeric value.
  walFormatVersion
  // Tracks the row format version numeric value.
  rowFormatVersion
end struct

// Groups the safety config state and preserves the field relationships documented below.
struct SafetyConfig
  // Indicates whether the allow remote without authentication condition is active.
  allowRemoteWithoutAuthentication
  // Stores the durability associated with this value.
  durability
  // Indicates whether the allow unknown format features condition is active.
  allowUnknownFormatFeatures
end struct

// Groups the mini SQL config state and preserves the field relationships documented below.
struct MiniSqlConfig
  // Tracks the config version numeric value.
  configVersion
  // Stores the filesystem paths.
  paths
  // Stores the server associated with this value.
  server
  // Stores the runtime associated with this value.
  runtime
  // Stores ordinary logger destination and rotation settings.
  logging
  // Stores SQL binlog settings.
  binlog
  // Stores the database defaults associated with this value.
  databaseDefaults
  // Stores the safety associated with this value.
  safety
end struct

// Returns whether the supplied value satisfies the paths config condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isPathsConfig(value)
  return value is PathsConfig
end function

// Returns whether the supplied value satisfies the server config condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isServerConfig(value)
  return value is ServerConfig
end function

// Returns whether the supplied value satisfies the runtime config condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isRuntimeConfig(value)
  return value is RuntimeConfig
end function

// Returns whether the supplied value is a logger configuration.
// Inputs: `value`. Returns true only for `LoggingConfig` values.
function isLoggingConfig(value)
  return value is LoggingConfig
end function

// Returns whether the supplied value is a binlog configuration.
// Inputs: `value`. Returns true only for `BinlogConfig` values.
function isBinlogConfig(value)
  return value is BinlogConfig
end function

// Returns whether the supplied value satisfies the database defaults condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isDatabaseDefaults(value)
  return value is DatabaseDefaults
end function

// Returns whether the supplied value satisfies the safety config condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isSafetyConfig(value)
  return value is SafetyConfig
end function

// Returns whether the supplied value satisfies the mini SQL config condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isMiniSqlConfig(value)
  return value is MiniSqlConfig
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "config.model"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M0"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function

// Implements default database settings for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function defaultDatabaseSettings(pageSize)
  return DatabaseDefaults(pageSize, "crc32c", 16777216, "utf-8", "binary", 1, 1, 1, 1, 1)
end function

// Implements default config for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function defaultConfig(dataRoot)
  return MiniSqlConfig(
    1,
    PathsConfig(dataRoot, ".\\tmp", ".\\logs"),
    ServerConfig("127.0.0.1", 7432, 32, 1048576, 8388608),
    RuntimeConfig(268435456, 30000, 67108864, 134217728, "info"),
    LoggingConfig(true, true, "minisql.log", 24),
    BinlogConfig(false, "minisql-bin.log"),
    defaultDatabaseSettings(4096),
    SafetyConfig(false, "full", false)
  )
end function
