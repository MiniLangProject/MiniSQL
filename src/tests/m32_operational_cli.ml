import minisql.catalog.catalog as catalog
import minisql.client.console as console
import minisql.common.uuid as uuid
import minisql.config.model as config_model
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.server.listener as listener
import minisql.server.session as session
import tests.support.testkit as testkit

function allZero(value)
  if typeof(value) != "bytes" then return false end if
  for each current in value
    if current != 0 then return false end if
  end for
  return true
end function

function main(args)
  if len(args) != 1 then print "MiniSQL M32 operational helper tests: FAIL args"; return 2 end if
  state = testkit.create()
  root = args[0]
  file_api.createDirectory(root)

  managed = database_manager.create(root, "m32_operational", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  testkit.record(state, file_api.directoryExists(databasePath), "database initialization publishes directory")
  testkit.equal(state, managed.catalogHandle.metadata.name, "m32_operational", "database initialization preserves logical name")
  testkit.equal(state, managed.catalogHandle.metadata.pageSize, 4096, "database initialization freezes page size")

  secret = bytes("M32-Operational-Admin-Password!")
  changed = catalog.setUserPasswordBytes(managed.catalogHandle, "admin", secret)
  testkit.record(state, changed is not void, "byte-based administrator password update succeeds")
  material = catalog.authenticationMaterial(managed.catalogHandle, "admin")
  testkit.record(state, material is not void, "administrator authentication material becomes available")
  testkit.record(state, uuid.verifyPasswordBytes(secret, material.salt, material.iterations, material.verifier), "administrator password verifier matches byte secret")
  database_manager.close(managed)

  reopened = database_manager.open(databasePath)
  persistentMaterial = catalog.authenticationMaterial(reopened.catalogHandle, "admin")
  testkit.record(state, persistentMaterial is not void, "administrator password material persists across reopen")
  testkit.record(state, uuid.verifyPasswordBytes(secret, persistentMaterial.salt, persistentMaterial.iterations, persistentMaterial.verifier), "persisted administrator password verifies")
  database_manager.close(reopened)
  uuid.wipeSecret(secret)
  testkit.record(state, allZero(secret), "administrator password buffer is wipeable")

  scriptPath = file_api.joinPath(root, "m32-script.sql")
  scriptBytes = bytes("# comment\r\nBEGIN;\r\n-- another comment\r\nCOMMIT;\r\n")
  scriptFile = file_api.create(scriptPath)
  file_api.writeAt(scriptFile, 0, scriptBytes, 0, len(scriptBytes))
  file_api.flush(scriptFile)
  file_api.close(scriptFile)
  loaded = file_api.readAllText(scriptPath, 1048576)
  testkit.equal(state, loaded, decode(scriptBytes), "bounded UTF-8 whole-file reader")
  lines = console.splitLines(loaded)
  testkit.equal(state, len(lines), 5, "script line splitter handles CRLF and trailing line")
  testkit.record(state, console.isScriptComment(console.trimAscii(lines[0])), "hash script comment recognized")
  testkit.record(state, console.isScriptComment(console.trimAscii(lines[2])), "SQL line comment recognized")
  testkit.equal(state, console.trimAscii("  SELECT 1;  "), "SELECT 1;", "ASCII trim supports shell input")

  testkit.record(state, listener.validateArguments("database", 0, "m32"), "zero request budget means unlimited")
  testkit.equal(state, session.idleTimeoutMilliseconds(), session.SESSION_IDLE_TIMEOUT_MS, "listener uses public session idle timeout")
  testkit.errorCode(state, try(file_api.readAllText(scriptPath, 1)), 9001, "script size limit is enforced")

  return testkit.finish(state, "MiniSQL M32 operational helper tests: SUCCESS", "MiniSQL M32 operational helper tests: FAIL")
end function
