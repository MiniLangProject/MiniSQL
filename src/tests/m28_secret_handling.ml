import minisql.client.console as console
import minisql.common.endian as endian
import minisql.common.uuid as uuid
import minisql.config.model as config_model
import minisql.platform.clock as clock
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.server.session as session
import tests.support.testkit as testkit

function allZero(value)
  if typeof(value) != "bytes" then return false end if
  for each item in value
    if item != 0 then return false end if
  end for
  return true
end function

function main(args)
  if len(args) != 1 then print "MiniSQL M28 secret handling tests: FAIL args"; return 2 end if
  state = testkit.create()
  original = bytes("M28-Password-Is-Secret!")
  validated = uuid.validatePasswordBytes(original, "m28")
  testkit.record(state, typeof(validated) == "bytes", "byte password accepted")
  testkit.record(state, uuid.constantTimeEquals(original, validated), "validated password preserves bytes")
  uuid.wipeSecret(validated)
  testkit.record(state, allZero(validated), "validated secret is explicitly wiped")
  testkit.record(state, not allZero(original), "caller secret remains independently owned")

  material = uuid.createPasswordMaterialBytes(original)
  testkit.record(state, len(material.salt) == uuid.PASSWORD_SALT_BYTES, "random salt length")
  testkit.record(state, len(material.verifier) == uuid.PASSWORD_VERIFIER_BYTES, "verifier length")
  testkit.record(state, uuid.verifyPasswordBytes(original, material.salt, material.iterations, material.verifier), "byte password verifies")
  wrong = bytes("M28-Wrong-Password-Secret!")
  testkit.record(state, not uuid.verifyPasswordBytes(wrong, material.salt, material.iterations, material.verifier), "wrong byte password rejected")
  uuid.wipeSecret(wrong)
  uuid.wipePasswordMaterial(material)
  testkit.record(state, allZero(material.salt) and allZero(material.verifier) and material.iterations == 0, "password material is wiped")

  // Deterministically exercise the Windows UTF-16 console conversion without
  // requiring an interactive prompt in the acceptance runner.
  sample = "M28-Console-Secret!"
  sampleBytes = bytes(sample)
  wide = bytes(len(sampleBytes) * 2, 0)
  if len(sampleBytes) > 0 then
    for index = 0 to len(sampleBytes) - 1
      endian.writeU16LE(wide, index * 2, sampleBytes[index])
    end for
  end if
  converted = console.utf16PasswordToUtf8(wide, len(sampleBytes))
  testkit.record(state, uuid.constantTimeEquals(converted, sampleBytes), "UTF-16 console input converts to UTF-8 bytes")
  uuid.wipeSecret(converted)
  uuid.wipeSecret(wide)
  uuid.wipeSecret(sampleBytes)
  testkit.record(state, allZero(converted) and allZero(wide) and allZero(sampleBytes), "console conversion buffers are wipeable")

  uuid.wipeSecret(original)
  testkit.record(state, allZero(original), "original password buffer is wiped")
  testkit.errorCode(state, try(uuid.validatePasswordBytes(bytes("too-short"), "m28")), 9001, "short password rejected")
  testkit.errorCode(state, try(uuid.validatePasswordBytes("not-bytes", "m28")), 9001, "string secret rejected by byte API")

  // Timeout behavior is tested without waiting in real time by moving the
  // session timestamps behind their configured limits.
  root = args[0]
  file_api.createDirectory(root)
  managed = database_manager.create(root, "m28_timeouts", config_model.defaultDatabaseSettings(4096))
  pending = session.openSecureAttached(managed)
  now = clock.monotonicMilliseconds()
  pending.createdAt = now - session.AUTH_HANDSHAKE_TIMEOUT_MS - 1
  pending.lastActivity = now
  testkit.record(state, session.isExpired(pending), "authentication handshake timeout expires unauthenticated session")
  pending.authenticated = true
  pending.createdAt = now
  pending.lastActivity = now - session.SESSION_IDLE_TIMEOUT_MS - 1
  testkit.record(state, session.isExpired(pending), "authenticated session idle timeout")
  pending.lastActivity = clock.monotonicMilliseconds()
  testkit.record(state, not session.isExpired(pending), "active authenticated session is not expired")
  session.close(pending)
  database_manager.close(managed)

  return testkit.finish(state, "MiniSQL M28 secret handling tests: SUCCESS", "MiniSQL M28 secret handling tests: FAIL")
end function
