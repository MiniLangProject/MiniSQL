import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.common.diagnostics as diagnostics
import minisql.common.uuid as uuid
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.sql.ast as ast
import minisql.sql.parser as parser
import tests.support.testkit as testkit

function containsMembership(state, roleId, memberId)
  for each item in state.memberships
    if item.roleId == roleId and item.memberId == memberId then return true end if
  end for
  return false
end function

function containsGrant(state, granteeId, objectType, objectId, privilege)
  for each item in state.grants
    if item.granteeId == granteeId and item.objectType == objectType and item.objectId == objectId and item.privilege == privilege then return true end if
  end for
  return false
end function

function containsBytes(haystack, needle)
  if typeof(haystack) != "bytes" or typeof(needle) != "bytes" then return false end if
  if len(needle) == 0 then return true end if
  if len(haystack) < len(needle) then return false end if
  for start = 0 to len(haystack) - len(needle)
    matched = true
    for index = 0 to len(needle) - 1
      if haystack[start + index] != needle[index] then matched = false; break end if
    end for
    if matched then return true end if
  end for
  return false
end function

function main(args)
  if len(args) != 1 then print "MiniSQL M30 audit and grant-chain tests: FAIL args"; return 2 end if
  state = testkit.create()
  root = args[0]
  file_api.createDirectory(root)

  // Pure tamper-evident record chain.
  key = bytes(32, 0x5A)
  previous = diagnostics.zeroHash()
  first = diagnostics.encodeAuditRecord(key, 1, 100, diagnostics.AUDIT_LOGIN, diagnostics.AUDIT_SUCCESS, 7, 10, previous, "login")
  firstScan = diagnostics.scanAuditBytes(first, key, previous, false)
  second = diagnostics.encodeAuditRecord(key, 2, 101, diagnostics.AUDIT_DDL, diagnostics.AUDIT_FAILURE, 7, 10, firstScan.lastHash, "denied ddl")
  secondOnly = diagnostics.scanAuditBytesFromSequence(second, key, firstScan.lastHash, 1, false)
  testkit.equal(state, secondOnly.recordCount, 1, "single appended audit suffix scans")
  testkit.equal(state, secondOnly.lastSequence, 2, "single appended audit suffix preserves sequence")
  testkit.errorCode(state, try(diagnostics.scanAuditBytes(second, key, firstScan.lastHash, false)), 9004, "full-segment scanner rejects non-one first sequence")
  combined = first + second
  scanned = diagnostics.scanAuditBytes(combined, key, previous, false)
  testkit.equal(state, scanned.recordCount, 2, "two audit records scan")
  testkit.equal(state, scanned.lastSequence, 2, "audit sequence")
  tampered = bytes(combined)
  tampered[len(tampered) - 1] = tampered[len(tampered) - 1] ^ 1
  testkit.errorCode(state, try(diagnostics.scanAuditBytes(tampered, key, previous, false)), 9004, "audit payload tamper detected")
  torn = combined + bytes(17, 0xAA)
  repaired = diagnostics.scanAuditBytes(torn, key, previous, true)
  testkit.equal(state, repaired.validBytes, len(combined), "torn audit tail boundary")

  // Two rotations verify that the retained segment can start at a non-zero
  // predecessor hash. The previous segment has its own durable anchor.
  auditPath = file_api.joinPath(root, "standalone")
  file_api.createDirectory(auditPath)
  log = diagnostics.openAudit(auditPath)
  diagnostics.appendAudit(log, diagnostics.AUDIT_LOGIN, diagnostics.AUDIT_SUCCESS, 1, 1, "admin login")
  diagnostics.appendAudit(log, diagnostics.AUDIT_DCL, diagnostics.AUDIT_SUCCESS, 1, 1, "role created")
  beforeRotate = diagnostics.verifyAudit(auditPath)
  testkit.equal(state, beforeRotate.recordCount, 2, "durable audit records")
  log = diagnostics.rotateAudit(log, auditPath, 1, 1)
  diagnostics.appendAudit(log, diagnostics.AUDIT_MAINTENANCE, diagnostics.AUDIT_SUCCESS, 1, 1, "check complete")
  afterFirst = diagnostics.verifyAudit(auditPath)
  testkit.equal(state, afterFirst.recordCount, 1, "current audit segment after first rotation")
  log = diagnostics.rotateAudit(log, auditPath, 1, 1)
  diagnostics.appendAudit(log, diagnostics.AUDIT_BACKUP, diagnostics.AUDIT_SUCCESS, 1, 1, "backup complete")
  afterSecond = diagnostics.verifyAudit(auditPath)
  testkit.equal(state, afterSecond.recordCount, 1, "second rotation preserves verifiable predecessor anchor")
  diagnostics.closeAudit(log)
  testkit.record(state, file_api.fileExists(diagnostics.auditPreviousAnchorPath(auditPath)), "rotated segment anchor persisted")

  currentLogPath = file_api.joinPath(file_api.joinPath(auditPath, "audit"), "audit.log")
  originalLog = diagnostics.readWhole(currentLogPath, diagnostics.MAX_AUDIT_FILE_BYTES)
  damagedLog = bytes(originalLog)
  damagedLog[len(damagedLog) - 1] = damagedLog[len(damagedLog) - 1] ^ 1
  diagnostics.writeWholeDurable(currentLogPath, damagedLog)
  testkit.errorCode(state, try(diagnostics.verifyAudit(auditPath)), 9004, "durable audit tamper is detected")
  diagnostics.writeWholeDurable(currentLogPath, originalLog)
  testkit.record(state, diagnostics.verifyAudit(auditPath).recordCount == 1, "restored audit verifies")

  managed = database_manager.create(root, "m30_security", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)
  executor.executeSql(engine, "CREATE TABLE secured_item (id INTEGER PRIMARY KEY, value VARCHAR(40))")
  executor.executeSql(engine, "CREATE ROLE reader")
  executor.executeSql(engine, "CREATE USER alice WITH PASSWORD 'Alice-M30-Password!'")
  executor.executeSql(engine, "CREATE USER bob WITH PASSWORD 'Bob-M30-Password!!!'")
  executor.executeSql(engine, "CREATE USER carol WITH PASSWORD 'Carol-M30-Password!'")
  executor.executeSql(engine, "ANALYZE secured_item")
  handle = managed.catalogHandle
  reader = catalog.findPrincipal(handle, "reader")
  alice = catalog.findPrincipal(handle, "alice")
  bob = catalog.findPrincipal(handle, "bob")
  carol = catalog.findPrincipal(handle, "carol")
  table = catalog.findTable(handle, "secured_item")

  catalog.grantRole(handle, "reader", "alice", metadata.PRINCIPAL_ADMIN_ID, true)
  catalog.grantRole(handle, "reader", "bob", alice.principalId, true)
  catalog.grantRole(handle, "reader", "carol", bob.principalId, false)
  testkit.errorCode(state, try(catalog.revokeRoleWithBehavior(handle, "reader", "alice", false)), 9001, "REVOKE ROLE RESTRICT blocks dependent grants")
  catalog.revokeRoleWithBehavior(handle, "reader", "alice", true)
  testkit.record(state, not containsMembership(handle.security, reader.principalId, alice.principalId), "root role grant removed")
  testkit.record(state, not containsMembership(handle.security, reader.principalId, bob.principalId), "dependent role grant removed")
  testkit.record(state, not containsMembership(handle.security, reader.principalId, carol.principalId), "transitive role grant removed")

  catalog.grantPrivilege(handle, "alice", metadata.PRINCIPAL_ADMIN_ID, metadata.OBJECT_TABLE, table.tableId, metadata.PRIVILEGE_SELECT, true)
  catalog.grantPrivilege(handle, "bob", alice.principalId, metadata.OBJECT_TABLE, table.tableId, metadata.PRIVILEGE_SELECT, true)
  catalog.grantPrivilege(handle, "carol", bob.principalId, metadata.OBJECT_TABLE, table.tableId, metadata.PRIVILEGE_SELECT, false)
  testkit.errorCode(state, try(catalog.revokePrivilegesWithBehavior(handle, "alice", metadata.OBJECT_TABLE, table.tableId, [metadata.PRIVILEGE_SELECT], false)), 9001, "REVOKE PRIVILEGE RESTRICT blocks grant chain")
  catalog.revokePrivilegesWithBehavior(handle, "alice", metadata.OBJECT_TABLE, table.tableId, [metadata.PRIVILEGE_SELECT], true)
  testkit.record(state, not containsGrant(handle.security, alice.principalId, metadata.OBJECT_TABLE, table.tableId, metadata.PRIVILEGE_SELECT), "root privilege grant removed")
  testkit.record(state, not containsGrant(handle.security, bob.principalId, metadata.OBJECT_TABLE, table.tableId, metadata.PRIVILEGE_SELECT), "dependent privilege grant removed")
  testkit.record(state, not containsGrant(handle.security, carol.principalId, metadata.OBJECT_TABLE, table.tableId, metadata.PRIVILEGE_SELECT), "transitive privilege grant removed")

  roleRevoke = parser.parseSql("REVOKE reader FROM alice CASCADE")[0]
  privilegeRevoke = parser.parseSql("REVOKE SELECT ON TABLE secured_item FROM alice RESTRICT")[0]
  testkit.record(state, ast.isRevokeRoleStatement(roleRevoke) and roleRevoke.cascade, "role CASCADE parsed")
  testkit.record(state, ast.isRevokePrivilegeStatement(privilegeRevoke) and not privilegeRevoke.cascade, "privilege RESTRICT parsed")

  databaseAudit = database_manager.verifyAudit(managed)
  testkit.record(state, databaseAudit.recordCount >= 5, "DDL and DCL operations entered durable audit")
  auditImage = diagnostics.snapshotAuditBytes(managed.auditLog, diagnostics.MAX_AUDIT_FILE_BYTES)
  aliceSecret = bytes("Alice-M30-Password!")
  bobSecret = bytes("Bob-M30-Password!!!")
  carolSecret = bytes("Carol-M30-Password!")
  testkit.record(state, not containsBytes(auditImage, aliceSecret) and not containsBytes(auditImage, bobSecret) and not containsBytes(auditImage, carolSecret), "raw password literals are absent from audit records")
  uuid.wipeSecret(aliceSecret)
  uuid.wipeSecret(bobSecret)
  uuid.wipeSecret(carolSecret)
  uuid.wipeSecret(auditImage)
  executor.close(engine)
  databasePath = managed.path
  database_manager.close(managed)
  testkit.record(state, diagnostics.verifyAudit(databasePath).recordCount >= 5, "database audit verifies after reopen boundary")
  uuid.wipeSecret(key)

  return testkit.finish(state, "MiniSQL M30 audit and grant-chain tests: SUCCESS", "MiniSQL M30 audit and grant-chain tests: FAIL")
end function
