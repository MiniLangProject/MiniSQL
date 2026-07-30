package minisql.config.model

struct PathsConfig
  dataRoot
  temporaryRoot
  logDirectory
end struct

struct ServerConfig
  bindAddress
  port
  maxConnections
  maxStatementBytes
  maxFrameBytes
end struct

struct RuntimeConfig
  bufferPoolBytes
  queryTimeoutMs
  checkpointWalBytes
  temporaryMemoryBytes
  logLevel
end struct

struct DatabaseDefaults
  pageSize
  checksumAlgorithm
  walSegmentBytes
  textEncoding
  defaultCollation
  databaseFormatVersion
  tableFileFormatVersion
  indexFileFormatVersion
  walFormatVersion
  rowFormatVersion
end struct

struct SafetyConfig
  allowRemoteWithoutAuthentication
  durability
  allowUnknownFormatFeatures
end struct

struct MiniSqlConfig
  configVersion
  paths
  server
  runtime
  databaseDefaults
  safety
end struct

function isPathsConfig(value)
  return value is PathsConfig
end function

function isServerConfig(value)
  return value is ServerConfig
end function

function isRuntimeConfig(value)
  return value is RuntimeConfig
end function

function isDatabaseDefaults(value)
  return value is DatabaseDefaults
end function

function isSafetyConfig(value)
  return value is SafetyConfig
end function

function isMiniSqlConfig(value)
  return value is MiniSqlConfig
end function

function componentName()
  return "config.model"
end function

function targetMilestone()
  return "M0"
end function

function isImplemented()
  return true
end function

function defaultDatabaseSettings(pageSize)
  return DatabaseDefaults(pageSize, "crc32c", 16777216, "utf-8", "binary", 1, 1, 1, 1, 1)
end function

function defaultConfig(dataRoot)
  return MiniSqlConfig(
    1,
    PathsConfig(dataRoot, ".\\tmp", ".\\logs"),
    ServerConfig("127.0.0.1", 7432, 32, 1048576, 8388608),
    RuntimeConfig(268435456, 30000, 67108864, 134217728, "info"),
    defaultDatabaseSettings(4096),
    SafetyConfig(false, "full", false)
  )
end function
