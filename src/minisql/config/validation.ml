package minisql.config.validation

import minisql.common.limits as limits
import minisql.config.model as model

const INVALID_CONFIGURATION = 9002

function fail(message)
  return error(INVALID_CONFIGURATION, "config.validation.validate: " + message)
end function

function positive(value, name)
  if typeof(value) != "int" or value <= 0 then return fail(name + " must be a positive integer") end if
  return true
end function

function nonEmpty(value, name)
  if typeof(value) != "string" or len(value) == 0 then return fail(name + " must be a non-empty string") end if
  return true
end function

function validate(config)
  if not model.isMiniSqlConfig(config) then return fail("value must be MiniSqlConfig") end if
  if not model.isPathsConfig(config.paths) or not model.isServerConfig(config.server) or not model.isRuntimeConfig(config.runtime) or not model.isDatabaseDefaults(config.databaseDefaults) or not model.isSafetyConfig(config.safety) then return fail("configuration sections have invalid types") end if
  if typeof(config.configVersion) != "int" or config.configVersion != 1 then return fail("configVersion must be 1") end if
  nonEmpty(config.paths.dataRoot, "paths.dataRoot")
  nonEmpty(config.paths.temporaryRoot, "paths.temporaryRoot")
  nonEmpty(config.paths.logDirectory, "paths.logDirectory")
  nonEmpty(config.server.bindAddress, "server.bindAddress")
  if typeof(config.server.port) != "int" or config.server.port < 1 or config.server.port > 65535 then return fail("server.port must be in 1..65535") end if
  positive(config.server.maxConnections, "server.maxConnections")
  positive(config.server.maxStatementBytes, "server.maxStatementBytes")
  positive(config.server.maxFrameBytes, "server.maxFrameBytes")
  positive(config.runtime.bufferPoolBytes, "runtime.bufferPoolBytes")
  positive(config.runtime.queryTimeoutMs, "runtime.queryTimeoutMs")
  positive(config.runtime.checkpointWalBytes, "runtime.checkpointWalBytes")
  positive(config.runtime.temporaryMemoryBytes, "runtime.temporaryMemoryBytes")
  if not limits.isSupportedPageSize(config.databaseDefaults.pageSize) then return fail("unsupported databaseDefaults.pageSize") end if
  if config.databaseDefaults.checksumAlgorithm != "crc32c" then return fail("only crc32c is supported") end if
  if config.databaseDefaults.textEncoding != "utf-8" then return fail("only utf-8 is supported") end if
  if config.databaseDefaults.defaultCollation != "binary" then return fail("only binary collation is supported in M8") end if
  positive(config.databaseDefaults.walSegmentBytes, "databaseDefaults.walSegmentBytes")
  if config.databaseDefaults.walSegmentBytes < 4096 then return fail("databaseDefaults.walSegmentBytes must be at least 4096") end if
  if config.databaseDefaults.databaseFormatVersion != 1 or config.databaseDefaults.tableFileFormatVersion != 1 or config.databaseDefaults.indexFileFormatVersion != 1 or config.databaseDefaults.walFormatVersion != 1 or config.databaseDefaults.rowFormatVersion != 1 then
    return fail("all persisted format versions must be 1")
  end if
  if config.runtime.logLevel != "trace" and config.runtime.logLevel != "debug" and config.runtime.logLevel != "info" and config.runtime.logLevel != "warn" and config.runtime.logLevel != "error" then return fail("runtime.logLevel is unsupported") end if
  if typeof(config.safety.allowRemoteWithoutAuthentication) != "bool" or typeof(config.safety.allowUnknownFormatFeatures) != "bool" then return fail("safety flags must be boolean") end if
  if config.safety.durability != "full" then return fail("safety.durability must be full") end if
  if config.server.bindAddress != "127.0.0.1" and not config.safety.allowRemoteWithoutAuthentication then
    return fail("remote bind requires explicit unsafe override before DCL")
  end if
  if config.safety.allowUnknownFormatFeatures then return fail("unknown persisted format features must not be allowed") end if
  return true
end function

function componentName()
  return "config.validation"
end function

function targetMilestone()
  return "M8"
end function

function isImplemented()
  return true
end function
