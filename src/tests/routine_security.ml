// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.catalog.schema_history as schema_history
import minisql.sql.binder as binder
import minisql.config.model as config_model
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

/// Checks durable routine grants, inherited authorization, and metadata layouts.
function main(args)
  if len(args) != 1 then print "MiniSQL routine security tests: FAIL (missing data root)"; return 1 end if
  tests = testkit.create()
  identity = bytes(16, 13)
  security = metadata.createSecurity(identity)
  role = metadata.createPrincipal(3, "runner", metadata.PRINCIPAL_ROLE, true, false, false, false, bytes(0), 0, bytes(0))
  security.principals = security.principals + [role]
  security.nextPrincipalId = 4
  security.memberships = [metadata.createRoleMembership(3, metadata.PRINCIPAL_PUBLIC_ID, metadata.PRINCIPAL_ADMIN_ID, false)]
  grant = metadata.createPrivilegeGrant(3, 1, metadata.OBJECT_PROCEDURE, 42, metadata.PRIVILEGE_EXECUTE, false)
  security.grants = [grant]
  restored = metadata.decodeSecurity(metadata.encodeSecurity(security))
  testkit.equal(tests, restored.grants[0].objectType, 3, "procedure object type survives security roundtrip")
  testkit.equal(tests, restored.grants[0].privilege, 20, "execute code survives security roundtrip")
  testkit.equal(tests, restored.grants[0].objectId, 42, "procedure identifier survives security roundtrip")
  testkit.errorCode(tests, try(metadata.createPrivilegeGrant(3, 1, metadata.OBJECT_PROCEDURE, 0, metadata.PRIVILEGE_EXECUTE, false)), 9001, "procedure zero identifier rejected")
  testkit.errorCode(tests, try(metadata.createPrivilegeGrant(3, 1, metadata.OBJECT_PROCEDURE, 42, metadata.PRIVILEGE_CREATE_ROUTINE, false)), 9001, "create routine must be database scoped")
  testkit.errorCode(tests, try(metadata.createPrivilegeGrant(3, 1, metadata.OBJECT_TABLE, 42, metadata.PRIVILEGE_EXECUTE, false)), 9001, "routine execute cannot authorize a table")
  handle = catalog.DatabaseHandle("", void, void, void, [], void, void, restored, false, false)
  testkit.record(tests, catalog.hasPrivilege(handle, 2, 3, 42, 20, false), "procedure execute inherited through role")
  testkit.record(tests, not catalog.hasPrivilege(handle, 2, 3, 43, 20, false), "procedure grant does not leak to another object")
  testkit.record(tests, not catalog.hasPrivilege(handle, 2, 3, 42, 20, true), "execute without grant option cannot delegate")
  restored.grants = [metadata.createPrivilegeGrant(3, 1, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_EXECUTE, false)]
  testkit.record(tests, catalog.hasPrivilege(handle, 2, 3, 43, 20, false), "database execute inherited for any procedure")
  testkit.record(tests, not catalog.hasPrivilege(handle, 2, 3, 43, 20, true), "database grant option stays restricted")
  testkit.record(tests, not catalog.hasPrivilege(handle, 2, 3, 43, 21, false), "execute does not imply alter")
  restored.grants = [metadata.createPrivilegeGrant(3, 1, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_ALTER_ROUTINE, true)]
  testkit.record(tests, catalog.hasPrivilege(handle, 2, 3, 43, 21, true), "database alter grant option is inherited")

  schema = schema_history.createState(identity)
  first = schema_history.nextExtensionId(schema)
  schema.views = [schema_history.viewDefinition(first, "__minisql_procedure__sample", "SELECT 1", [])]
  schema.generation = schema.generation + 1
  schema.views = []
  schema.generation = schema.generation + 1
  reloaded = schema_history.decodeExtensions(schema_history.encodeExtensions(schema), identity)
  second = schema_history.nextExtensionId(reloaded)
  testkit.record(tests, second > first, "drop/reopen/recreate never reuses grant-bearing identifier")
  reloaded.views = [schema_history.viewDefinition(1000, "__minisql_procedure__legacy", "SELECT 1", [])]
  nextLegacy = schema_history.nextExtensionId(reloaded)
  testkit.equal(tests, nextLegacy, 1001, "legacy larger identifier raises allocation high-water mark")
  testkit.equal(tests, reloaded.generation, 1000, "raised high-water mark will persist with generation")

  routines = binder.informationSchemaTable("information_schema.routines")
  testkit.equal(tests, len(routines[0].columns), 9, "routine metadata has nine columns")
  testkit.equal(tests, routines[0].columns[4].name, "security_type", "routine metadata field order is stable")
  parameters = binder.informationSchemaTable("information_schema.parameters")
  testkit.equal(tests, parameters[1].relationKind, binder.INFORMATION_PARAMETERS, "parameter metadata relation kind")
  testkit.equal(tests, len(parameters[0].columns), 9, "parameter metadata has nine columns")
  testkit.equal(tests, parameters[0].columns[8].name, "numeric_scale", "parameter metadata ends with scale")
  managed = database_manager.create(args[0], "routine_security", config_model.defaultDatabaseSettings(4096))
  persistent = managed.catalogHandle
  runner = catalog.createRole(persistent, "runner")
  reader = catalog.createRole(persistent, "reader")
  catalog.grantRole(persistent, "runner", "reader", metadata.PRINCIPAL_ADMIN_ID, false)
  procedure = schema_history.putProcedure(managed.path, persistent.metadata.databaseId, "sample", "SELECT 1", [], false)
  procedureId = procedure.viewId
  catalog.grantPrivilege(persistent, "runner", 1, metadata.OBJECT_PROCEDURE, procedureId, metadata.PRIVILEGE_EXECUTE, true)
  catalog.grantPrivilege(persistent, "runner", 1, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CREATE_ROUTINE, false)
  testkit.record(tests, catalog.hasPrivilege(persistent, reader.principalId, 3, procedureId, 20, true), "durable procedure grant is inherited through role")
  path = managed.path
  database_manager.close(managed)
  managed = database_manager.open(path)
  persistent = managed.catalogHandle
  testkit.record(tests, catalog.hasPrivilege(persistent, reader.principalId, 3, procedureId, 20, true), "procedure grant and role membership survive reopen")
  testkit.record(tests, catalog.hasPrivilege(persistent, reader.principalId, 1, 0, 22, false), "database CREATE ROUTINE survives reopen")
  schema_history.dropProcedure(path, persistent.metadata.databaseId, "sample", false)
  database_manager.close(managed)
  managed = database_manager.open(path)
  persistent = managed.catalogHandle
  replacement = schema_history.putProcedure(path, persistent.metadata.databaseId, "sample", "SELECT 2", [], false)
  testkit.record(tests, replacement.viewId > procedureId, "persisted drop/recreate has a fresh durable procedure identifier")
  testkit.record(tests, not catalog.hasPrivilege(persistent, reader.principalId, 3, replacement.viewId, 20, false), "uncleaned old grant cannot authorize replacement")
  catalog.grantPrivilege(persistent, "runner", 1, 3, replacement.viewId, 21, false)
  testkit.record(tests, catalog.removeProcedurePrivileges(persistent, procedureId), "drop cleanup removes old procedure grant")
  testkit.record(tests, not catalog.hasPrivilege(persistent, reader.principalId, 3, procedureId, 20, false), "old procedure grant is revoked after cleanup")
  testkit.record(tests, catalog.hasPrivilege(persistent, reader.principalId, 3, replacement.viewId, 21, false), "cleanup leaves replacement grants intact")
  testkit.record(tests, catalog.hasPrivilege(persistent, reader.principalId, 1, 0, 22, false), "cleanup leaves database grants intact")
  testkit.record(tests, not catalog.removeProcedurePrivileges(persistent, procedureId), "drop cleanup is idempotent")
  database_manager.close(managed)
  managed = database_manager.open(path)
  testkit.record(tests, not catalog.hasPrivilege(managed.catalogHandle, reader.principalId, 3, procedureId, 20, false), "cleanup persists across reopen")
  testkit.record(tests, catalog.hasPrivilege(managed.catalogHandle, reader.principalId, 3, replacement.viewId, 21, false), "remaining replacement grant persists")
  database_manager.close(managed)
  return testkit.finish(tests, "MiniSQL routine security tests: SUCCESS", "MiniSQL routine security tests: FAIL")
end function
