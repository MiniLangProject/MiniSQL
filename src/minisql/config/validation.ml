package minisql.config.validation

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.limits as limits
import minisql.config.model as model

const INVALID_CONFIGURATION = 9002

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(message)
  return error(INVALID_CONFIGURATION, "config.validation.validate: " + message)
end function

// Implements positive for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function positive(value, name)
  if typeof(value) != "int" or value <= 0 then return fail(name + " must be a positive integer") end if
  return true
end function

// Implements non empty for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function nonEmpty(value, name)
  if typeof(value) != "string" or len(value) == 0 then return fail(name + " must be a non-empty string") end if
  return true
end function

// Validates validate using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function validate(config)
  if not model.isMiniSqlConfig(config) then return fail("value must be MiniSqlConfig") end if
  if not model.isPathsConfig(config.paths) or not model.isServerConfig(config.server) or not model.isRuntimeConfig(config.runtime) or not model.isLoggingConfig(config.logging) or not model.isBinlogConfig(config.binlog) or not model.isTlsConfig(config.tls) or not model.isDatabaseDefaults(config.databaseDefaults) or not model.isSafetyConfig(config.safety) then return fail("configuration sections have invalid types") end if
  if typeof(config.configVersion) != "int" or config.configVersion != 1 then return fail("configVersion must be 1") end if
  nonEmpty(config.paths.dataRoot, "paths.dataRoot")
  nonEmpty(config.paths.temporaryRoot, "paths.temporaryRoot")
  nonEmpty(config.paths.logDirectory, "paths.logDirectory")
  nonEmpty(config.server.bindAddress, "server.bindAddress")
  if typeof(config.server.port) != "int" or config.server.port < 1 or config.server.port > 65535 then return fail("server.port must be in 1..65535") end if
  positive(config.server.maxConnections, "server.maxConnections")
  positive(config.server.maxStatementBytes, "server.maxStatementBytes")
  positive(config.server.maxFrameBytes, "server.maxFrameBytes")
  positive(config.server.maxResultRows, "server.maxResultRows")
  positive(config.server.maxResultBytes, "server.maxResultBytes")
  if config.server.maxResultBytes < 1048576 then return fail("server.maxResultBytes must be at least 1048576") end if
  positive(config.server.idleTimeoutMs, "server.idleTimeoutMs")
  if config.server.maxFrameBytes > 16777216 then return fail("server.maxFrameBytes must not exceed protocol limit 16777216") end if
  positive(config.runtime.bufferPoolBytes, "runtime.bufferPoolBytes")
  positive(config.runtime.queryTimeoutMs, "runtime.queryTimeoutMs")
  positive(config.runtime.checkpointWalBytes, "runtime.checkpointWalBytes")
  positive(config.runtime.temporaryMemoryBytes, "runtime.temporaryMemoryBytes")
  positive(config.runtime.processMemoryBytes, "runtime.processMemoryBytes")
  positive(config.runtime.temporaryStorageBytes, "runtime.temporaryStorageBytes")
  positive(config.runtime.slowQueryMs, "runtime.slowQueryMs")
  if config.runtime.processMemoryBytes < 16777216 then return fail("runtime.processMemoryBytes must be at least 16777216") end if
  if config.runtime.temporaryStorageBytes < 1048576 then return fail("runtime.temporaryStorageBytes must be at least 1048576") end if
  if config.runtime.processMemoryBytes < config.runtime.bufferPoolBytes + config.runtime.temporaryMemoryBytes then return fail("runtime.processMemoryBytes must cover bufferPoolBytes plus temporaryMemoryBytes") end if
  if not limits.isSupportedPageSize(config.databaseDefaults.pageSize) then return fail("unsupported databaseDefaults.pageSize") end if
  if config.databaseDefaults.checksumAlgorithm != "crc32c" then return fail("only crc32c is supported") end if
  if config.databaseDefaults.textEncoding != "utf-8" then return fail("only utf-8 is supported") end if
  if config.databaseDefaults.defaultCollation != "binary" then return fail("only binary collation is supported in M8") end if
  positive(config.databaseDefaults.walSegmentBytes, "databaseDefaults.walSegmentBytes")
  if config.databaseDefaults.walSegmentBytes < 4096 then return fail("databaseDefaults.walSegmentBytes must be at least 4096") end if
  if config.databaseDefaults.databaseFormatVersion != 1 or config.databaseDefaults.tableFileFormatVersion != 1 or config.databaseDefaults.indexFileFormatVersion != 1 or config.databaseDefaults.walFormatVersion != 1 or config.databaseDefaults.rowFormatVersion != 1 then
    return fail("all persisted format versions must be 1")
  end if
  if config.runtime.logLevel != "debug" and config.runtime.logLevel != "info" and config.runtime.logLevel != "warning" and config.runtime.logLevel != "warn" and config.runtime.logLevel != "error" then return fail("runtime.logLevel must be debug, info, warning or error") end if
  if typeof(config.logging.stdoutEnabled) != "bool" or typeof(config.logging.fileEnabled) != "bool" then return fail("logging destination flags must be boolean") end if
  if not config.logging.stdoutEnabled and not config.logging.fileEnabled then return fail("at least one ordinary logging destination must be enabled") end if
  nonEmpty(config.logging.fileName, "logging.fileName")
  positive(config.logging.rotationHours, "logging.rotationHours")
  if config.logging.rotationHours > 87600 then return fail("logging.rotationHours must not exceed ten years") end if
  if typeof(config.binlog.enabled) != "bool" then return fail("binlog.enabled must be boolean") end if
  nonEmpty(config.binlog.fileName, "binlog.fileName")
  if typeof(config.tls.enabled) != "bool" then return fail("tls.enabled must be boolean") end if
  if typeof(config.tls.certificateReference) != "string" then return fail("tls.certificateReference must be string") end if
  if config.tls.enabled and len(config.tls.certificateReference) == 0 then return fail("tls.certificateReference must be non-empty when TLS is enabled") end if
  if config.tls.pfxPasswordEnvironment != "MINISQL_TLS_PFX_PASSWORD" then return fail("tls.pfxPasswordEnvironment must be MINISQL_TLS_PFX_PASSWORD") end if
  if config.tls.protocolVersion != "TLS1.3" then return fail("tls.protocolVersion must be TLS1.3") end if
  if config.tls.cipherSuite != "TLS_AES_256_GCM_SHA384" then return fail("tls.cipherSuite must be TLS_AES_256_GCM_SHA384") end if
  if config.tls.namedGroup != "X25519" then return fail("tls.namedGroup must be X25519") end if
  if typeof(config.safety.allowRemoteWithoutAuthentication) != "bool" or typeof(config.safety.allowUnknownFormatFeatures) != "bool" then return fail("safety flags must be boolean") end if
  if config.safety.durability != "full" then return fail("safety.durability must be full") end if
  if config.server.bindAddress != "127.0.0.1" and not config.tls.enabled and not config.safety.allowRemoteWithoutAuthentication then
    return fail("remote bind requires native TLS or an explicit unsafe override")
  end if
  if config.safety.allowUnknownFormatFeatures then return fail("unknown persisted format features must not be allowed") end if
  return true
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "config.validation"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M8"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
