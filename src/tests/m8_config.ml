// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.config.loader as loader
import minisql.config.model as model
import minisql.config.validation as validation
import minisql.platform.file as file_api
import tests.support.testkit as testkit

// Writes and flushes a complete text fixture, ensuring subsequent loader checks observe durable contents.
function writeText(path, text)
  handle = file_api.create(path)
  data = bytes(text)
  if len(data) > 0 then file_api.writeAt(handle, 0, data, 0, len(data)) end if
  file_api.flush(handle)
  file_api.close(handle)
  return true
end function

// Runs the config test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 2 then
    print "MiniSQL M8 configuration tests: FAIL (missing paths)"
    return 1
  end if
  validPath = args[0]
  invalidPath = args[1]
  state = testkit.create()

  config = loader.load(validPath)
  testkit.equal(state, config.configVersion, 1, "config version")
  testkit.equal(state, config.server.port, 7432, "server port")
  testkit.equal(state, config.databaseDefaults.pageSize, 4096, "page default")
  testkit.equal(state, config.databaseDefaults.checksumAlgorithm, "crc32c", "checksum default")
  testkit.equal(state, config.databaseDefaults.textEncoding, "utf-8", "encoding default")
  testkit.equal(state, config.runtime.logLevel, "info", "logger threshold")
  testkit.record(state, config.logging.stdoutEnabled and config.logging.fileEnabled, "logger destinations enabled")
  testkit.equal(state, config.logging.rotationHours, 24, "logger rotation hours")
  testkit.record(state, not config.binlog.enabled, "SQL binlog disabled by default")
  testkit.record(state, model.isTlsConfig(config.tls), "native TLS exact type predicate")
  testkit.record(state, not config.tls.enabled, "native TLS disabled by default")
  testkit.equal(state, config.tls.protocolVersion, "TLS1.3", "native TLS protocol policy")
  testkit.equal(state, config.tls.cipherSuite, "TLS_AES_256_GCM_SHA384", "native TLS cipher policy")
  testkit.equal(state, config.tls.namedGroup, "X25519", "native TLS group policy")
  testkit.record(state, model.isMiniSqlConfig(config), "config exact type predicate")
  testkit.record(state, model.isDatabaseDefaults(config.databaseDefaults), "database defaults exact type predicate")
  testkit.record(state, validation.validate(config), "valid config")
  testkit.errorCode(state, try(validation.validate([])), validation.INVALID_CONFIGURATION, "wrong config struct rejected")

  writeText(invalidPath, "{\"configVersion\":1,\"paths\":")
  testkit.errorCode(state, try(loader.load(invalidPath)), loader.INVALID_CONFIGURATION, "truncated JSON rejected")
  testkit.errorCode(state, try(loader.parse("{\"n\":01}")), loader.INVALID_CONFIGURATION, "leading-zero JSON number rejected")
  testkit.errorCode(state, try(loader.ensureOnlyKeys(loader.parse("{\"known\":1,\"extra\":2}"), ["known"], "test")), loader.INVALID_CONFIGURATION, "unknown configuration key rejected")
  config.server.bindAddress = "0.0.0.0"
  testkit.errorCode(state, try(validation.validate(config)), validation.INVALID_CONFIGURATION, "remote bind rejected before DCL")
  config.tls.enabled = true
  config.tls.certificateReference = "pfx:server.pfx"
  testkit.record(state, validation.validate(config), "remote bind accepted with native TLS")
  config.tls.cipherSuite = "TLS_AES_128_GCM_SHA256"
  testkit.errorCode(state, try(validation.validate(config)), validation.INVALID_CONFIGURATION, "unconfigured TLS cipher rejected")
  config.tls.cipherSuite = "TLS_AES_256_GCM_SHA384"
  config.tls.enabled = false
  config.server.bindAddress = "127.0.0.1"
  config.databaseDefaults.pageSize = 5000
  testkit.errorCode(state, try(validation.validate(config)), validation.INVALID_CONFIGURATION, "unsupported page size rejected")

  ignored = try(file_api.deletePath(invalidPath))
  return testkit.finish(state, "MiniSQL M8 configuration tests: SUCCESS", "MiniSQL M8 configuration tests: FAIL")
end function
