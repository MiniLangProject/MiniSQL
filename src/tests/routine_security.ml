// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.catalog.schema_history as schema_history
import minisql.sql.binder as binder
import minisql.sql.types as types
import minisql.sql.values as values
import minisql.common.endian as endian
import minisql.executor.executor as executor
import minisql.config.model as config_model
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

/// Executes a single SQL statement without hiding authentication or metadata failures.
/// @param engine Open engine with its current effective principal.
/// @param sql Complete statement text.
function securityExecute(engine, sql)
  return executor.executeSql(engine, sql)[0]
end function

/// Reads one scalar while retaining SQL NULL and the native SQL type.
/// @param engine Authenticated engine used for the metadata query.
/// @param sql Single-row, single-column query.
function securityScalar(engine, sql)
  return securityExecute(engine, sql).rows[0][0]
end function

/// A malformed persisted context must fail before installing a privileged definer.
/// @param tests Shared assertion accumulator for identity and permission boundaries.
/// @param admin Trusted fixture owner with access to the storage test seam.
/// @param author Routine creator authorized to read the protected table.
/// @param reader EXECUTE-only caller without the underlying table permission.
function testCorruptRoutineContext(tests, admin, author, reader)
  securityExecute(admin, "CREATE TABLE context_private_data(secret_value INT)")
  securityExecute(admin, "INSERT INTO context_private_data VALUES(73)")
  securityExecute(admin, "GRANT SELECT ON TABLE context_private_data TO routine_author")
  securityExecute(author, "CREATE PROCEDURE context_guard() SELECT secret_value FROM context_private_data")
  securityExecute(admin, "GRANT EXECUTE ON PROCEDURE context_guard TO routine_reader")
  testkit.errorCode(tests, try(securityExecute(reader, "SELECT secret_value FROM context_private_data")), 9029, "context fixture caller cannot read the definer's protected table")
  original = executor.routineFind(author, "context_guard")
  originalPrincipal = reader.principalId
  originalTrusted = reader.trusted
  session = reader.routineSession
  originalMode = session.sqlMode
  originalCharset = session.characterSetClient
  originalCollation = session.collationConnection
  originalDatabaseCollation = session.databaseCollation
  database = admin.database
  malformed = [schema_history.PROCEDURE_METADATA_V2, "" + author.principalId, schema_history.PROCEDURE_CONTEXT_V1, "sql_mode"]
  schema_history.putProcedure(database.path, database.catalogHandle.metadata.databaseId, "context_guard", original.sqlText, malformed, true)
  rejected = try(securityExecute(reader, "CALL context_guard()"))
  // Restore durable bytes before assertions so a failed assertion cannot leave
  // the rest of this fixture dependent on deliberately corrupt metadata.
  schema_history.putProcedure(database.path, database.catalogHandle.metadata.databaseId, "context_guard", original.sqlText, original.columnNames, true)
  testkit.errorCode(tests, rejected, 9004, "malformed persisted context fails with corruption diagnostic")
  testkit.equal(tests, reader.principalId, originalPrincipal, "corrupt context cannot install the definer identity")
  testkit.equal(tests, reader.trusted, originalTrusted, "corrupt context cannot change the trusted-session flag")
  testkit.record(tests, session.sqlMode == originalMode and session.characterSetClient == originalCharset and session.collationConnection == originalCollation and session.databaseCollation == originalDatabaseCollation, "corrupt context leaves all caller execution settings intact")
  testkit.equal(tests, len(session.frames), 0, "corrupt context leaves no active procedure frame")
  testkit.errorCode(tests, try(securityExecute(reader, "SELECT secret_value FROM context_private_data")), 9029, "caller retains its original table restriction after corrupt CALL")
  restored = securityExecute(reader, "CALL context_guard()")
  testkit.equal(tests, values.asNumber(restored.rows[0].rows[0][0]), 73, "restored context invalidates the failed parse entry and permits authorized CALL")
  return true
end function

/// Verifies externally visible authorization boundaries and complete, persistent metadata.
/// @param tests Shared assertion accumulator; SQL failures propagate to the group boundary.
/// @param root Isolated directory supplied by the native test runner.
function testSqlRoutineSecurity(tests, root)
  managed = database_manager.create(root, "routine_metadata_security", config_model.defaultDatabaseSettings(4096))
  path = managed.path
  admin = executor.attach(managed)
  securityExecute(admin, "CREATE USER routine_author WITH PASSWORD 'Routine-Author-Password-2026!'")
  securityExecute(admin, "CREATE USER routine_reader WITH PASSWORD 'Routine-Reader-Password-2026!'")
  securityExecute(admin, "GRANT CONNECT ON DATABASE TO routine_author")
  securityExecute(admin, "GRANT CONNECT ON DATABASE TO routine_reader")
  securityExecute(admin, "GRANT CREATE ON DATABASE TO routine_author")
  authorId = catalog.findPrincipal(managed.catalogHandle, "routine_author").principalId
  readerId = catalog.findPrincipal(managed.catalogHandle, "routine_reader").principalId
  author = executor.attach(managed)
  reader = executor.attach(managed)
  executor.setPrincipal(author, authorId)
  executor.setPrincipal(reader, readerId)
  testkit.errorCode(tests, try(securityExecute(author, "CREATE PROCEDURE generic_create_is_not_enough() SELECT 1")), 9029, "generic CREATE cannot create a security-bearing routine")
  securityExecute(admin, "GRANT CREATE ROUTINE ON DATABASE TO routine_author")
  securityExecute(author, "CREATE PROCEDURE protected_body() SELECT 42 AS answer")
  securityExecute(author, "CREATE PROCEDURE metadata_types(IN p_text VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin, IN p_int INT, IN p_decimal DECIMAL(8,2), IN p_time TIMESTAMP(3), IN p_binary VARBINARY(6), IN p_double DOUBLE) COMMENT 'metadata probe' BEGIN END")
  securityExecute(admin, "GRANT EXECUTE ON PROCEDURE protected_body TO routine_reader")
  shown = securityExecute(reader, "SHOW CREATE PROCEDURE protected_body")
  testkit.equal(tests, len(shown.columns), 6, "SHOW CREATE contains the complete MySQL layout")
  testkit.record(tests, shown.rows[0][2].isNull, "EXECUTE exposes metadata but not source text")
  testkit.record(tests, securityScalar(reader, "SELECT routine_definition FROM information_schema.routines WHERE routine_name = 'protected_body'").isNull, "ROUTINES masks source independently of execution")
  called = securityExecute(reader, "CALL protected_body()")
  testkit.equal(tests, values.asNumber(called.rows[0].rows[0][0]), 42, "an EXECUTE-only caller can run the authorized body")
  testCorruptRoutineContext(tests, admin, author, reader)
  securityExecute(admin, "REVOKE EXECUTE ON PROCEDURE protected_body FROM routine_author")
  testkit.errorCode(tests, try(securityExecute(reader, "CALL protected_body()")), 9029, "definer must independently hold EXECUTE")
  testkit.equal(tests, reader.principalId, readerId, "failed definer authorization preserves caller identity")
  securityExecute(admin, "GRANT EXECUTE ON PROCEDURE protected_body TO routine_author")
  securityExecute(admin, "GRANT ALTER ROUTINE ON PROCEDURE protected_body TO routine_reader")
  testkit.record(tests, securityExecute(reader, "SHOW CREATE PROCEDURE protected_body").rows[0][2].isNull, "ALTER ROUTINE does not grant source-reading permission")
  securityExecute(admin, "REVOKE EXECUTE ON PROCEDURE protected_body FROM routine_reader")
  securityExecute(admin, "REVOKE ALTER ROUTINE ON PROCEDURE protected_body FROM routine_reader")
  securityExecute(admin, "GRANT CREATE ROUTINE ON DATABASE TO routine_reader")
  testkit.record(tests, securityExecute(reader, "SHOW CREATE PROCEDURE protected_body").rows[0][2].isNull, "CREATE ROUTINE alone exposes metadata without definitions")
  securityExecute(admin, "CREATE ROLE routine_inspectors")
  securityExecute(admin, "GRANT SHOW_ROUTINE ON DATABASE TO routine_inspectors")
  securityExecute(admin, "GRANT routine_inspectors TO routine_reader")
  testkit.record(tests, not securityExecute(reader, "SHOW CREATE PROCEDURE protected_body").rows[0][2].isNull, "inherited SHOW_ROUTINE reveals complete definitions")
  testkit.errorCode(tests, try(securityExecute(reader, "CALL protected_body()")), 9029, "SHOW_ROUTINE does not imply EXECUTE")
  securityExecute(admin, "REVOKE SHOW_ROUTINE ON DATABASE FROM routine_inspectors")
  securityExecute(admin, "GRANT SELECT ON DATABASE TO routine_reader")
  testkit.record(tests, not securityScalar(reader, "SELECT routine_definition FROM information_schema.routines WHERE routine_name = 'protected_body'").isNull, "database SELECT grants definition visibility")
  securityExecute(admin, "CREATE TABLE visible_with_database_select(id INT)")
  securityExecute(admin, "INSERT INTO visible_with_database_select VALUES(8)")
  testkit.equal(tests, values.asNumber(securityScalar(reader, "SELECT id FROM visible_with_database_select")), 8, "database SELECT also authorizes table reads")
  testkit.errorCode(tests, try(securityExecute(reader, "INSERT INTO visible_with_database_select VALUES(9)")), 9029, "database SELECT cannot authorize table mutations")
  securityExecute(admin, "REVOKE EXECUTE ON PROCEDURE protected_body FROM routine_author")
  securityExecute(admin, "REVOKE ALTER ROUTINE ON PROCEDURE protected_body FROM routine_author")
  securityExecute(admin, "REVOKE CREATE ROUTINE ON DATABASE FROM routine_author")
  testkit.record(tests, not securityExecute(author, "SHOW CREATE PROCEDURE protected_body").rows[0][2].isNull, "definer retains source visibility without routine grants")
  testkit.errorCode(tests, try(securityExecute(reader, "CREATE DEFINER = routine_author PROCEDURE selected_definer() SELECT 7")), 9029, "choosing another definer requires its dedicated privilege")
  securityExecute(admin, "GRANT SET_ANY_DEFINER ON DATABASE TO routine_reader")
  securityExecute(reader, "CREATE DEFINER = routine_author PROCEDURE selected_definer() SELECT 7")
  testkit.equal(tests, securityScalar(reader, "SELECT definer FROM information_schema.routines WHERE routine_name = 'selected_definer'").value, "routine_author", "SET_ANY_DEFINER permits a bounded nonadministrator workflow")
  testkit.errorCode(tests, try(securityExecute(reader, "CALL selected_definer()")), 9029, "creator EXECUTE does not substitute for the selected definer's EXECUTE")
  securityExecute(admin, "GRANT EXECUTE ON PROCEDURE selected_definer TO routine_author")
  testkit.equal(tests, values.asNumber(securityExecute(reader, "CALL selected_definer()").rows[0].rows[0][0]), 7, "selected definer executes after its own EXECUTE grant")
  testkit.errorCode(tests, try(securityExecute(reader, "CREATE DEFINER = 'admin' PROCEDURE privileged_definer() SELECT 1")), 9029, "SET_ANY_DEFINER alone cannot select a superuser")
  reader.routineSession.automaticSpPrivileges = false
  securityExecute(reader, "CREATE PROCEDURE no_automatic_grant() SQL SECURITY INVOKER SELECT 1")
  testkit.errorCode(tests, try(securityExecute(reader, "CALL no_automatic_grant()")), 9029, "disabled automatic privileges do not grant creator EXECUTE")
  testkit.errorCode(tests, try(securityExecute(reader, "ALTER PROCEDURE no_automatic_grant COMMENT 'denied'")), 9029, "disabled automatic privileges do not grant creator ALTER")
  reader.routineSession.automaticSpPrivileges = true

  parameters = securityExecute(admin, "SELECT * FROM information_schema.parameters WHERE specific_name = 'metadata_types' ORDER BY ordinal_position")
  testkit.equal(tests, len(parameters.columns), 16, "PARAMETERS exposes all sixteen fields")
  testkit.equal(tests, len(parameters.rows), 6, "all declared parameters appear exactly once")
  textType = parameters.rows[0]
  testkit.equal(tests, values.asNumber(textType[7]), 20, "text length is expressed in characters")
  testkit.equal(tests, values.asNumber(textType[8]), 80, "utf8mb4 octet length uses four bytes per character")
  testkit.record(tests, textType[9].isNull and textType[10].isNull, "text parameters have no fabricated numeric precision")
  testkit.equal(tests, textType[12].value, "utf8mb4", "explicit parameter character set exposed")
  testkit.equal(tests, textType[13].value, "utf8mb4_bin", "explicit parameter collation exposed")
  testkit.equal(tests, textType[14].value, "VARCHAR(20)", "DTD_IDENTIFIER reports the complete base SQL type")
  testkit.equal(tests, values.asNumber(parameters.rows[1][9]), 10, "INTEGER precision is derived without explicit type arguments")
  testkit.equal(tests, values.asNumber(parameters.rows[1][10]), 0, "INTEGER scale is zero")
  testkit.record(tests, parameters.rows[1][7].isNull and parameters.rows[1][12].isNull, "numeric parameters have no character attributes")
  testkit.equal(tests, values.asNumber(parameters.rows[2][9]), 8, "DECIMAL precision exposed")
  testkit.equal(tests, values.asNumber(parameters.rows[2][10]), 2, "DECIMAL scale exposed")
  testkit.equal(tests, values.asNumber(parameters.rows[3][11]), 3, "temporal fractional precision is separate from numeric precision")
  testkit.record(tests, parameters.rows[3][9].isNull, "TIMESTAMP has no numeric precision")
  testkit.equal(tests, values.asNumber(parameters.rows[4][8]), 6, "binary maximum length remains byte based")
  testkit.record(tests, parameters.rows[4][12].isNull, "binary values do not claim a character set")
  testkit.equal(tests, values.asNumber(parameters.rows[5][9]), 22, "approximate numeric precision follows its concrete type")
  testkit.record(tests, parameters.rows[5][10].isNull, "approximate numeric scale is unspecified")
  securityExecute(admin, "CREATE PROCEDURE metadata_binary(IN fixed_bytes CHAR(2) CHARACTER SET binary, IN varying_bytes VARCHAR(3) CHARACTER SET binary, IN long_bytes TEXT CHARACTER SET binary) BEGIN END")
  binaryParameters = securityExecute(admin, "SELECT * FROM information_schema.parameters WHERE specific_name = 'metadata_binary' ORDER BY ordinal_position").rows
  testkit.equal(tests, len(binaryParameters), 3, "binary charset parameters are exposed in declaration order")
  testkit.equal(tests, binaryParameters[0][6].value, "BINARY", "binary CHAR metadata uses its effective binary type")
  testkit.equal(tests, binaryParameters[0][14].value, "BINARY(2)", "binary CHAR DTD identifier matches runtime conversion")
  testkit.equal(tests, binaryParameters[1][6].value, "VARBINARY", "binary VARCHAR metadata uses its effective binary type")
  testkit.equal(tests, binaryParameters[1][14].value, "VARBINARY(3)", "binary VARCHAR DTD identifier matches runtime conversion")
  testkit.equal(tests, binaryParameters[2][6].value, "BLOB", "binary TEXT metadata uses its effective binary type")
  testkit.equal(tests, binaryParameters[2][14].value, "BLOB", "binary TEXT DTD identifier matches runtime conversion")
  testkit.equal(tests, values.asNumber(binaryParameters[0][7]), 2, "binary CHAR maximum length counts bytes")
  testkit.equal(tests, values.asNumber(binaryParameters[1][8]), 3, "binary VARCHAR maximum octets are not multiplied by UTF-8 width")
  testkit.record(tests, binaryParameters[2][7].isNull and binaryParameters[2][8].isNull, "unbounded native BLOB does not fabricate a MySQL capacity")
  testkit.record(tests, binaryParameters[0][12].isNull and binaryParameters[0][13].isNull and binaryParameters[1][12].isNull and binaryParameters[1][13].isNull and binaryParameters[2][12].isNull and binaryParameters[2][13].isNull, "effective binary types expose no character set or collation")
  metadataRows = securityExecute(admin, "SELECT * FROM information_schema.routines WHERE routine_name = 'metadata_types'")
  testkit.equal(tests, len(metadataRows.columns), 31, "ROUTINES exposes all thirty-one fields")
  record = metadataRows.rows[0]
  testkit.equal(tests, record[23].typeKind, types.SqlTypeKind.Timestamp, "CREATED has a native SQL timestamp type")
  testkit.record(tests, not record[23].isNull and not record[24].isNull, "new routines have actual creation and alteration times")
  created = endian.int64ToInt(record[23].value)
  testkit.record(tests, created > 0, "persisted creation time is a positive Unix timestamp")
  testkit.equal(tests, record[25].value, "STRICT_TRANS_TABLES", "routine captures its SQL mode")
  testkit.equal(tests, record[28].value, "utf8mb4", "routine captures client character set")
  testkit.equal(tests, record[30].value, "utf8mb4_bin", "routine captures database collation")
  admin.routineSession.sqlMode = ""
  admin.routineSession.databaseCollation = "binary"
  securityExecute(admin, "ALTER PROCEDURE metadata_types COMMENT 'changed metadata'")
  changed = securityExecute(admin, "SELECT created, last_altered, sql_mode, database_collation FROM information_schema.routines WHERE routine_name = 'metadata_types'").rows[0]
  testkit.equal(tests, endian.int64ToInt(changed[0].value), created, "ALTER preserves the original creation timestamp")
  testkit.record(tests, endian.int64ToInt(changed[1].value) >= created, "ALTER records a current modification timestamp")
  testkit.equal(tests, changed[2].value, "", "ALTER captures the current SQL mode")
  testkit.equal(tests, changed[3].value, "utf8mb4_bin", "ALTER does not relabel the creation-time collation")
  status = securityExecute(admin, "SHOW PROCEDURE STATUS WHERE name = 'metadata_types'")
  testkit.equal(tests, len(status.columns), 11, "SHOW STATUS exposes all MySQL fields")
  testkit.equal(tests, len(status.rows[0][5].value), 26, "SHOW timestamps are readable UTC with microsecond units")
  securityExecute(admin, "CREATE TABLE routine_ddl_changes(id INT)")
  securityExecute(admin, "GRANT INSERT ON TABLE routine_ddl_changes TO routine_author")
  securityExecute(author, "START TRANSACTION")
  securityExecute(author, "INSERT INTO routine_ddl_changes VALUES(99)")
  testkit.errorCode(tests, try(securityExecute(author, "CREATE PROCEDURE unauthorized_ddl_commit() SELECT 1")), 9029, "unauthorized routine DDL fails before implicit commit")
  testkit.record(tests, author.explicitTransaction, "authorization failure retains the explicit transaction")
  securityExecute(author, "ROLLBACK")
  testkit.equal(tests, values.asNumber(securityScalar(admin, "SELECT COUNT(*) FROM routine_ddl_changes")), 0, "unauthorized DDL cannot publish preceding writes")
  securityExecute(admin, "GRANT INSERT ON TABLE routine_ddl_changes TO routine_reader")
  securityExecute(reader, "START TRANSACTION")
  securityExecute(reader, "INSERT INTO routine_ddl_changes VALUES(98)")
  testkit.errorCode(tests, try(securityExecute(reader, "CREATE DEFINER = 'admin' PROCEDURE refused_superuser_ddl() SELECT 1")), 9029, "superuser-definer authorization precedes implicit commit")
  testkit.record(tests, reader.explicitTransaction, "superuser-definer rejection retains the explicit transaction")
  securityExecute(reader, "ROLLBACK")
  securityExecute(reader, "START TRANSACTION")
  securityExecute(reader, "INSERT INTO routine_ddl_changes VALUES(97)")
  testkit.errorCode(tests, try(securityExecute(reader, "CREATE OR REPLACE PROCEDURE metadata_types() SELECT 1")), 9029, "replacement ALTER authorization precedes implicit commit")
  testkit.record(tests, reader.explicitTransaction, "replacement rejection retains the explicit transaction")
  securityExecute(reader, "ROLLBACK")
  securityExecute(admin, "REVOKE SET_ANY_DEFINER ON DATABASE FROM routine_reader")
  securityExecute(reader, "START TRANSACTION")
  securityExecute(reader, "INSERT INTO routine_ddl_changes VALUES(96)")
  testkit.errorCode(tests, try(securityExecute(reader, "CREATE DEFINER = routine_author PROCEDURE refused_foreign_ddl() SELECT 1")), 9029, "foreign-definer authorization precedes implicit commit")
  testkit.record(tests, reader.explicitTransaction, "foreign-definer rejection retains the explicit transaction")
  securityExecute(reader, "ROLLBACK")
  testkit.equal(tests, values.asNumber(securityScalar(admin, "SELECT COUNT(*) FROM routine_ddl_changes")), 0, "all denied DDL authorization paths leave prior writes rollbackable")
  securityExecute(admin, "START TRANSACTION")
  securityExecute(admin, "INSERT INTO routine_ddl_changes VALUES(1)")
  securityExecute(admin, "CREATE PROCEDURE implicit_commit_probe() SELECT 1")
  testkit.record(tests, not admin.explicitTransaction, "CREATE PROCEDURE implicitly commits an active transaction")
  testkit.equal(tests, values.asNumber(securityScalar(reader, "SELECT COUNT(*) FROM routine_ddl_changes")), 1, "CREATE PROCEDURE publishes preceding writes")
  securityExecute(admin, "START TRANSACTION")
  securityExecute(admin, "INSERT INTO routine_ddl_changes VALUES(2)")
  securityExecute(admin, "ALTER PROCEDURE implicit_commit_probe COMMENT 'committed'")
  testkit.record(tests, not admin.explicitTransaction, "ALTER PROCEDURE implicitly commits an active transaction")
  securityExecute(admin, "START TRANSACTION")
  securityExecute(admin, "INSERT INTO routine_ddl_changes VALUES(3)")
  securityExecute(admin, "DROP PROCEDURE implicit_commit_probe")
  testkit.record(tests, not admin.explicitTransaction, "DROP PROCEDURE implicitly commits an active transaction")
  testkit.equal(tests, values.asNumber(securityScalar(reader, "SELECT COUNT(*) FROM routine_ddl_changes")), 3, "ALTER and DROP preserve the previously committed changes")
  securityExecute(admin, "START TRANSACTION")
  securityExecute(admin, "INSERT INTO routine_ddl_changes VALUES(4)")
  testkit.errorCode(tests, try(securityExecute(admin, "CREATE PROCEDURE metadata_types() SELECT 1")), 1304, "authorized duplicate definition fails after the DDL commit boundary")
  testkit.record(tests, not admin.explicitTransaction, "definition error does not resurrect the committed transaction")
  testkit.equal(tests, values.asNumber(securityScalar(reader, "SELECT COUNT(*) FROM routine_ddl_changes")), 4, "authorized failing DDL still preserves its implicit commit")
  legacy = schema_history.putProcedure(path, managed.catalogHandle.metadata.databaseId, "legacy_context", "CREATE PROCEDURE legacy_context() BEGIN END", [schema_history.PROCEDURE_METADATA_V2, "1"], false)
  old = securityExecute(admin, "SELECT created, sql_mode, character_set_client FROM information_schema.routines WHERE routine_name = 'legacy_context'").rows[0]
  testkit.record(tests, old[0].isNull and old[1].isNull and old[2].isNull, "old records retain unknown context as SQL NULL")
  executor.close(author)
  executor.close(reader)
  executor.close(admin)
  database_manager.close(managed)
  reopened = executor.open(path)
  durable = securityExecute(reopened, "SELECT created, sql_mode, routine_comment FROM information_schema.routines WHERE routine_name = 'metadata_types'").rows[0]
  testkit.equal(tests, endian.int64ToInt(durable[0].value), created, "routine creation timestamp survives reopen")
  testkit.equal(tests, durable[1].value, "", "changed routine SQL mode survives reopen")
  testkit.equal(tests, durable[2].value, "changed metadata", "ALTER characteristics survive reopen with context")
  testkit.equal(tests, values.asNumber(securityScalar(reopened, "SELECT COUNT(*) FROM routine_ddl_changes")), 4, "routine DDL implicit commits remain durable after reopen")
  executor.close(reopened)
  return true
end function

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
  restored.grants = [metadata.createPrivilegeGrant(3, 1, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_SHOW_ROUTINE, false), metadata.createPrivilegeGrant(3, 1, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_SET_ANY_DEFINER, false)]
  testkit.record(tests, catalog.hasPrivilege(handle, 2, 1, 0, 23, false), "definition-reading grant is inherited")
  testkit.record(tests, catalog.hasPrivilege(handle, 2, 1, 0, 24, false), "granular definer grant is inherited")
  testkit.record(tests, not catalog.hasPrivilege(handle, 2, 3, 43, 20, false), "reading definitions does not authorize execution")
  testkit.record(tests, not catalog.hasPrivilege(handle, 2, 1, 0, 23, true), "definition-reading grant cannot be redelegated")
  testkit.errorCode(tests, try(metadata.createPrivilegeGrant(3, 1, metadata.OBJECT_PROCEDURE, 42, metadata.PRIVILEGE_SHOW_ROUTINE, false)), 9001, "SHOW_ROUTINE is database scoped")
  testkit.errorCode(tests, try(metadata.createPrivilegeGrant(3, 1, metadata.OBJECT_TABLE, 42, metadata.PRIVILEGE_SET_ANY_DEFINER, false)), 9001, "SET_ANY_DEFINER cannot authorize a table")
  restored.grants = [metadata.createPrivilegeGrant(3, 1, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_SELECT, false)]
  testkit.record(tests, catalog.hasPrivilege(handle, 2, 2, 43, 10, false), "database SELECT covers table reads")
  testkit.record(tests, not catalog.hasPrivilege(handle, 2, 2, 43, 11, false), "database SELECT does not authorize writes")
  testkit.record(tests, not catalog.hasPrivilege(handle, 2, 2, 43, 10, true), "database SELECT grant option remains restricted")

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
  attributes = ["created", "1700000000000000", "last_altered", "1700000000001000", "sql_mode", "STRICT_TRANS_TABLES", "character_set_client", "utf8mb4", "collation_connection", "utf8mb4_bin", "database_collation", "utf8mb4_bin"]
  encodedContext = schema_history.routineMetadata(1, attributes)
  contextView = schema_history.viewDefinition(1001, "__minisql_procedure__context", "CREATE PROCEDURE context() BEGIN END", encodedContext)
  testkit.equal(tests, schema_history.routineAttribute(contextView, "created"), "1700000000000000", "routine creation time survives metadata encoding")
  testkit.equal(tests, schema_history.routineAttribute(contextView, "sql_mode"), "STRICT_TRANS_TABLES", "routine SQL mode stored independently from SQL source")
  legacyView = schema_history.viewDefinition(1002, "__minisql_procedure__old", "CREATE PROCEDURE old() BEGIN END", [schema_history.PROCEDURE_METADATA_V2, "1"])
  testkit.record(tests, schema_history.routineAttribute(legacyView, "created") is void, "legacy creation time remains unknown")
  testkit.record(tests, schema_history.routineAttribute(legacyView, "sql_mode") is void, "legacy SQL mode is not fabricated")
  testkit.equal(tests, schema_history.routineTimestampText("0"), "1970-01-01 00:00:00.000000", "SHOW timestamps use readable UTC calendar values")
  testkit.record(tests, toNumber(schema_history.routineNowMicros()) > 0, "routine timestamp uses an actual UTC clock")
  testkit.errorCode(tests, try(schema_history.routineMetadata(1, ["sql_mode", "", "sql_mode", "STRICT_TRANS_TABLES"])), 9001, "duplicate persisted context keys rejected")
  testkit.errorCode(tests, try(schema_history.routineMetadata(1, ["created", "not a timestamp"])), 9001, "invalid stored timestamp rejected")
  corruptContext = schema_history.viewDefinition(1003, "__minisql_procedure__bad", "SELECT 1", [schema_history.PROCEDURE_METADATA_V2, "1", schema_history.PROCEDURE_CONTEXT_V1, "created"])
  testkit.errorCode(tests, try(schema_history.routineAttributes(corruptContext)), 9004, "truncated persisted routine context fails closed")

  routines = binder.informationSchemaTable("information_schema.routines")
  testkit.equal(tests, len(routines[0].columns), 31, "routine metadata has all MySQL column names")
  testkit.equal(tests, routines[0].columns[22].name, "security_type", "routine metadata uses canonical MySQL field order")
  testkit.record(tests, routines[0].columns[15].nullable, "routine definition can be hidden independently from metadata")
  parameters = binder.informationSchemaTable("information_schema.parameters")
  testkit.equal(tests, parameters[1].relationKind, binder.INFORMATION_PARAMETERS, "parameter metadata relation kind")
  testkit.equal(tests, len(parameters[0].columns), 16, "parameter metadata has all MySQL column names")
  testkit.equal(tests, parameters[0].columns[15].name, "routine_type", "parameter metadata ends with routine type")
  managed = database_manager.create(args[0], "routine_security", config_model.defaultDatabaseSettings(4096))
  persistent = managed.catalogHandle
  runner = catalog.createRole(persistent, "runner")
  reader = catalog.createRole(persistent, "reader")
  catalog.grantRole(persistent, "runner", "reader", metadata.PRINCIPAL_ADMIN_ID, false)
  procedure = schema_history.putProcedure(managed.path, persistent.metadata.databaseId, "sample", "CREATE PROCEDURE sample() BEGIN END", encodedContext, false)
  procedureId = procedure.viewId
  catalog.grantPrivilege(persistent, "runner", 1, metadata.OBJECT_PROCEDURE, procedureId, metadata.PRIVILEGE_EXECUTE, true)
  catalog.grantPrivilege(persistent, "runner", 1, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CREATE_ROUTINE, false)
  catalog.grantPrivilege(persistent, "runner", 1, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_SHOW_ROUTINE, false)
  catalog.grantPrivilege(persistent, "runner", 1, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_SET_ANY_DEFINER, false)
  catalog.grantPrivilege(persistent, "runner", 1, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_SELECT, false)
  testkit.record(tests, catalog.hasPrivilege(persistent, reader.principalId, 3, procedureId, 20, true), "durable procedure grant is inherited through role")
  path = managed.path
  database_manager.close(managed)
  managed = database_manager.open(path)
  persistent = managed.catalogHandle
  testkit.record(tests, catalog.hasPrivilege(persistent, reader.principalId, 3, procedureId, 20, true), "procedure grant and role membership survive reopen")
  testkit.record(tests, catalog.hasPrivilege(persistent, reader.principalId, 1, 0, 22, false), "database CREATE ROUTINE survives reopen")
  testkit.record(tests, catalog.hasPrivilege(persistent, reader.principalId, 1, 0, 23, false), "SHOW_ROUTINE survives reopen")
  testkit.record(tests, catalog.hasPrivilege(persistent, reader.principalId, 1, 0, 24, false), "SET_ANY_DEFINER survives reopen")
  testkit.record(tests, catalog.hasPrivilege(persistent, reader.principalId, 2, 43, 10, false), "database SELECT inheritance survives reopen")
  persistedProcedure = schema_history.findProcedure(schema_history.loadOrCreate(path, persistent.metadata.databaseId), "sample")
  testkit.equal(tests, schema_history.routineAttribute(persistedProcedure, "created"), "1700000000000000", "creation time survives database reopen")
  testkit.equal(tests, schema_history.routineAttribute(persistedProcedure, "database_collation"), "utf8mb4_bin", "creation collation survives database reopen")
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
  sqlOutcome = try(testSqlRoutineSecurity(tests, args[0]))
  testkit.record(tests, typeof(sqlOutcome) != "error", "SQL security and metadata group completes")
  if typeof(sqlOutcome) == "error" then print "SQL SECURITY ERROR " + sqlOutcome.code + ": " + sqlOutcome.message end if
  print "Routine security assertions: " + tests.checks
  return testkit.finish(tests, "MiniSQL routine security tests: SUCCESS", "MiniSQL routine security tests: FAIL")
end function
