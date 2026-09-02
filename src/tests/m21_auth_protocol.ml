// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages
import minisql.server.database_manager as database_manager
import minisql.server.session as session
import minisql.common.uuid as uuid
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Derives the authentication proof from the password, normalized username, and server challenge using the protocol's hash composition.
function clientProof(password, username, challenge)
  // The returned verifier is retained only so the test can verify the server's
  // reciprocal proof; the raw password-derived secret is wiped immediately.
  secret = uuid.validatePassword(password, "m21AuthTest")
  verifier = uuid.deriveKey(secret, challenge[1], challenge[0], uuid.PASSWORD_VERIFIER_BYTES)
  fillBytes(secret, 0, len(secret), 0)
  proof = void
  if challenge[3] == uuid.AUTH_SCHEME_SCRAM_SHA256 then proof = uuid.scramClientProof(verifier, challenge[2], username) else proof = uuid.authProof(verifier, challenge[2], username, "client") end if
  return [verifier, proof]
end function

// Performs the challenge-response authentication exchange and returns the authenticated protocol response; transport and proof failures propagate.
function authenticate(target, username, password, firstRequestId)
  // Keep request IDs monotonic across the two-message handshake and return the
  // challenge material solely for proof verification and explicit wiping.
  challengeMessage = session.handle(target, messages.authBegin(firstRequestId, username))
  if challengeMessage.messageType != constants.TYPE_AUTH_CHALLENGE then return error(9027, "challenge rejected") end if
  challenge = messages.decodeAuthChallenge(challengeMessage.payload)
  proofParts = clientProof(password, username, challenge)
  reply = session.handle(target, messages.authProof(firstRequestId + 1, proofParts[1]))
  fillBytes(proofParts[1], 0, len(proofParts[1]), 0)
  return [reply, proofParts[0], challenge]
end function

// Runs the auth protocol test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M21 authentication protocol tests: FAIL (missing data root)"
    return 1
  end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m21_auth_protocol", config_model.defaultDatabaseSettings(4096))
  path = managed.path
  admin = executor.attach(managed)
  executeOne(admin, "CREATE TABLE secure_data (id INTEGER PRIMARY KEY, note VARCHAR(40))")
  executeOne(admin, "INSERT INTO secure_data(id, note) VALUES (1, 'visible')")
  executeOne(admin, "CREATE USER alice WITH PASSWORD 'Alice-Network-21!'")
  executeOne(admin, "GRANT CONNECT ON DATABASE TO alice")
  executeOne(admin, "GRANT SELECT ON TABLE secure_data TO alice")
  executor.close(admin)
  database_manager.close(managed)

  // Establish the positive control: unauthenticated SQL is rejected, a valid
  // client proof authenticates the session, and the server proves that it owns
  // the stored verifier before authorized SQL becomes available.
  secure = session.openSecure(path)
  hello = session.handle(secure, messages.hello(1))
  helloResponse = messages.decodeResponse(hello.payload)
  testkit.equal(state, helloResponse.command, "HELLO", "secure HELLO response")
  testkit.record(state, not secure.authenticated, "secure session starts unauthenticated")

  blocked = session.handle(secure, messages.query(2, "SELECT id FROM secure_data"))
  blockedResponse = messages.decodeResponse(blocked.payload)
  testkit.equal(state, blocked.messageType, constants.TYPE_ERROR, "query blocked before authentication")
  testkit.equal(state, blockedResponse.errorCode, 9028, "pre-authentication error code")

  auth = authenticate(secure, "alice", "Alice-Network-21!", 3)
  authReply = auth[0]
  verifier = auth[1]
  challenge = auth[2]
  testkit.equal(state, authReply.messageType, constants.TYPE_AUTH_OK, "valid proof accepted")
  expectedServerProof = void
  if challenge[3] == uuid.AUTH_SCHEME_SCRAM_SHA256 then expectedServerProof = uuid.scramServerProofFromPassword(verifier, challenge[2], "alice") else expectedServerProof = uuid.authProof(verifier, challenge[2], "alice", "server") end if
  testkit.record(state, uuid.constantTimeEquals(expectedServerProof, authReply.payload), "server proves verifier possession")
  testkit.equal(state, challenge[3], uuid.AUTH_SCHEME_SCRAM_SHA256, "new accounts negotiate hardened authentication")
  fillBytes(expectedServerProof, 0, len(expectedServerProof), 0)
  fillBytes(verifier, 0, len(verifier), 0)
  fillBytes(challenge[1], 0, len(challenge[1]), 0)
  fillBytes(challenge[2], 0, len(challenge[2]), 0)
  testkit.record(state, secure.authenticated, "session becomes authenticated")

  queryReply = session.handle(secure, messages.query(5, "SELECT note FROM secure_data WHERE id = 1"))
  queryResponse = messages.decodeResponse(queryReply.payload)
  testkit.equal(state, queryResponse.status, constants.STATUS_ROWS, "authenticated query succeeds")
  testkit.equal(state, queryResponse.rows[0][0], "visible", "authenticated row payload")
  session.close(secure)

  // Wrong-password and unknown-user paths deliberately compare identical
  // public errors to prevent account enumeration through protocol diagnostics.
  wrong = session.openSecure(path)
  wrongAuth = authenticate(wrong, "alice", "Wrong-Network-21!", 10)
  wrongResponse = messages.decodeResponse(wrongAuth[0].payload)
  fillBytes(wrongAuth[1], 0, len(wrongAuth[1]), 0)
  fillBytes(wrongAuth[2][1], 0, len(wrongAuth[2][1]), 0)
  fillBytes(wrongAuth[2][2], 0, len(wrongAuth[2][2]), 0)
  testkit.equal(state, wrongAuth[0].messageType, constants.TYPE_ERROR, "wrong password rejected")
  testkit.equal(state, wrongResponse.errorCode, 9027, "wrong password generic code")
  session.close(wrong)

  unknown = session.openSecure(path)
  unknownAuth = authenticate(unknown, "missing_user", "Wrong-Network-21!", 20)
  unknownResponse = messages.decodeResponse(unknownAuth[0].payload)
  fillBytes(unknownAuth[1], 0, len(unknownAuth[1]), 0)
  fillBytes(unknownAuth[2][1], 0, len(unknownAuth[2][1]), 0)
  fillBytes(unknownAuth[2][2], 0, len(unknownAuth[2][2]), 0)
  testkit.equal(state, unknownAuth[0].messageType, constants.TYPE_ERROR, "unknown user rejected")
  testkit.equal(state, unknownResponse.errorCode, wrongResponse.errorCode, "unknown user and wrong password share code")
  testkit.equal(state, unknownResponse.message, wrongResponse.message, "unknown user and wrong password share message")
  session.close(unknown)

  // Reuse one session for three failed proofs to verify the bounded-attempt
  // state machine requests connection closure at the configured threshold.
  limited = session.openSecure(path)
  for attempt = 0 to 2
    challengeMessage = session.handle(limited, messages.authBegin(30 + attempt * 2, "missing_user"))
    testkit.equal(state, challengeMessage.messageType, constants.TYPE_AUTH_CHALLENGE, "failed-attempt challenge issued")
    failedReply = session.handle(limited, messages.authProof(31 + attempt * 2, bytes(32, 0)))
    failedResponse = messages.decodeResponse(failedReply.payload)
    testkit.equal(state, failedResponse.errorCode, 9027, "failed-attempt generic code")
    fillBytes(challengeMessage.payload, 0, len(challengeMessage.payload), 0)
  end for
  testkit.record(state, limited.closeRequested, "three failed proofs request connection closure")
  session.close(limited)

  return testkit.finish(state, "MiniSQL M21 authentication protocol tests: SUCCESS", "MiniSQL M21 authentication protocol tests: FAIL")
end function
