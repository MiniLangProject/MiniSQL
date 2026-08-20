// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.common.uuid as uuid
import minisql.config.model as config_model
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.storage.paged_file as paged_file
import tests.support.testkit as testkit

// Performs an exact linear membership check over the supplied values.
function contains(values, wanted)
  for each value in values
    if value == wanted then return true end if
  end for
  return false
end function

// Flips one byte at the requested file offset and flushes it to construct a deterministic on-disk corruption fixture.
function corruptByte(path, offset)
  handle = file_api.openReadWrite(path, false)
  data = bytes(1, 0)
  file_api.readExactAt(handle, offset, data, 0, 1)
  data[0] = data[0] ^ 0x5A
  file_api.writeAt(handle, offset, data, 0, 1)
  file_api.flush(handle)
  file_api.close(handle)
  return true
end function

// Runs the security catalog test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M21 security catalog tests: FAIL (missing data root)"
    return 1
  end if
  state = testkit.create()
  root = args[0]

  managed = database_manager.create(root, "m21_security", config_model.defaultDatabaseSettings(4096))
  handle = managed.catalogHandle
  admin = catalog.findPrincipal(handle, "admin")
  publicRole = catalog.findPrincipal(handle, "public")
  testkit.record(state, metadata.isPrincipalMetadata(admin), "built-in administrator exists")
  testkit.record(state, admin.superuser and admin.canLogin and admin.enabled, "administrator semantics")
  testkit.record(state, metadata.isPrincipalMetadata(publicRole), "PUBLIC role exists")
  testkit.record(state, publicRole.principalKind == metadata.PRINCIPAL_ROLE and not publicRole.canLogin, "PUBLIC role semantics")

  alice = catalog.createUser(handle, "alice", "Correct-Horse-21!")
  reader = catalog.createRole(handle, "reader")
  reporter = catalog.createRole(handle, "reporter")
  testkit.record(state, catalog.authenticatePassword(handle, "alice", "Correct-Horse-21!"), "password verifier accepts correct password")
  testkit.record(state, not catalog.authenticatePassword(handle, "alice", "Wrong-Password-21!"), "password verifier rejects wrong password")
  testkit.record(state, len(alice.salt) == uuid.PASSWORD_SALT_BYTES and len(alice.verifier) == uuid.PASSWORD_VERIFIER_BYTES, "password material lengths")
  testkit.record(state, alice.iterations == uuid.DEFAULT_PBKDF2_ITERATIONS, "PBKDF2 work factor")
  catalog.setUserEnabled(handle, "alice", false)
  testkit.record(state, catalog.authenticationMaterial(handle, "alice") is void, "disabled user has no authentication material")
  testkit.record(state, not catalog.authenticatePassword(handle, "alice", "Correct-Horse-21!"), "disabled user cannot authenticate")
  catalog.setUserEnabled(handle, "alice", true)
  testkit.record(state, catalog.authenticatePassword(handle, "alice", "Correct-Horse-21!"), "re-enabled user can authenticate")
  testkit.errorCode(state, try(metadata.createPrincipal(100, "bad_role", metadata.PRINCIPAL_ROLE, true, false, false, false, bytes(16, 1), uuid.DEFAULT_PBKDF2_ITERATIONS, bytes(32, 2))), 9001, "role password material rejected")
  testkit.errorCode(state, try(metadata.createPrincipal(101, "empty_login", metadata.PRINCIPAL_USER, true, true, false, false, bytes(0), 0, bytes(0))), 9001, "non-built-in login without password rejected")

  catalog.grantRole(handle, "reader", "alice", metadata.PRINCIPAL_ADMIN_ID, true)
  catalog.grantRole(handle, "reporter", "reader", metadata.PRINCIPAL_ADMIN_ID, false)
  effective = catalog.effectivePrincipalIds(handle, alice.principalId)
  testkit.record(state, contains(effective, alice.principalId), "effective principals include user")
  testkit.record(state, contains(effective, metadata.PRINCIPAL_PUBLIC_ID), "effective principals include PUBLIC")
  testkit.record(state, contains(effective, reader.principalId), "effective principals include direct role")
  testkit.record(state, contains(effective, reporter.principalId), "effective principals include inherited role")
  testkit.errorCode(state, try(catalog.grantRole(handle, "reader", "reporter", metadata.PRINCIPAL_ADMIN_ID, false)), 9001, "role cycle rejected")

  catalog.grantPrivilege(handle, "reader", metadata.PRINCIPAL_ADMIN_ID, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CONNECT, true)
  testkit.record(state, catalog.hasPrivilege(handle, alice.principalId, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CONNECT, false), "role privilege inherited")
  testkit.record(state, catalog.hasPrivilege(handle, alice.principalId, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CONNECT, true), "grant option inherited")

  databasePath = managed.path
  generation = handle.security.generation
  database_manager.close(managed)
  reopened = database_manager.open(databasePath)
  testkit.record(state, reopened.catalogHandle.security.generation == generation, "security generation persists")
  persistedAlice = catalog.findPrincipal(reopened.catalogHandle, "alice")
  testkit.record(state, metadata.isPrincipalMetadata(persistedAlice), "principal persists")
  testkit.record(state, catalog.authenticatePassword(reopened.catalogHandle, "alice", "Correct-Horse-21!"), "password persists")
  database_manager.close(reopened)

  fallback = database_manager.create(root, "m21_fallback", config_model.defaultDatabaseSettings(4096))
  catalog.createRole(fallback.catalogHandle, "generation_two")
  catalog.createRole(fallback.catalogHandle, "generation_three")
  fallbackPath = fallback.path
  newestGeneration = fallback.catalogHandle.security.generation
  newestSlot = (newestGeneration - 1) % 2
  securityPath = catalog.securityFilePath(fallbackPath)
  pageSize = fallback.catalogHandle.metadata.pageSize
  database_manager.close(fallback)
  corruptByte(securityPath, paged_file.DATA_OFFSET + newestSlot * pageSize + 100)
  recovered = database_manager.open(fallbackPath)
  testkit.record(state, recovered.catalogHandle.security.generation == newestGeneration - 1, "newest corrupt generation falls back")
  testkit.record(state, catalog.findPrincipal(recovered.catalogHandle, "generation_two") is not void, "previous generation remains available")
  testkit.record(state, catalog.findPrincipal(recovered.catalogHandle, "generation_three") is void, "corrupt newest mutation is not exposed")
  database_manager.close(recovered)

  return testkit.finish(state, "MiniSQL M21 security catalog tests: SUCCESS", "MiniSQL M21 security catalog tests: FAIL")
end function
