// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.uuid as uuid
import minisql.platform.network as network
import minisql.protocol.connection as connection
import minisql.protocol.messages as messages
import tests.support.testkit as testkit

// Compares two byte arrays without assuming equal types or lengths and reports whether any byte differs.
function bytesDiffer(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return true end if
  end for
  return false
end function

// Runs the secure transport test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = testkit.create()
  // Bind sequence, direction, message type, and request ID into AEAD. Changing
  // any authenticated field or tag must make decryption fail deterministically.
  key = uuid.randomBytes(32)
  plaintext = bytes("authenticated MiniSQL frame")
  packet = uuid.transportEncrypt(key, 7, 3, 1, 42, plaintext)
  testkit.record(state, uuid.isAeadPacket(packet), "AES-GCM packet returned")
  testkit.equal(state, len(packet.ciphertext), len(plaintext), "ciphertext length")
  testkit.equal(state, len(packet.tag), uuid.AES_GCM_TAG_BYTES, "GCM tag length")
  recovered = uuid.transportDecrypt(key, 7, 3, 1, 42, packet.ciphertext, packet.tag)
  testkit.record(state, uuid.constantTimeEquals(recovered, plaintext), "AES-GCM roundtrip")
  secondPacket = uuid.transportEncrypt(key, 8, 3, 1, 42, plaintext)
  testkit.record(state, bytesDiffer(packet.ciphertext, secondPacket.ciphertext), "different sequence uses a different nonce stream")
  testkit.errorCode(state, try(uuid.transportDecrypt(key, 7, 3, 1, 43, packet.ciphertext, packet.tag)), 9027, "request ID is authenticated as AAD")
  packet.tag[0] = packet.tag[0] ^ 1
  testkit.errorCode(state, try(uuid.transportDecrypt(key, 7, 3, 1, 42, packet.ciphertext, packet.tag)), 9027, "tag tampering rejected")

  // Two connection states use opposite send/receive counters. A protected frame
  // is accepted once, then both replay and post-activation plaintext are denied.
  sender = connection.create(1)
  receiver = connection.create(2)
  connection.enableSecure(sender, key, key)
  connection.enableSecure(receiver, key, key)
  original = messages.query(11, "SELECT 1")
  protected = connection.protectMessage(sender, original)
  testkit.record(state, protected.flags != original.flags, "secure flag applied")
  decoded = connection.unprotectMessage(receiver, protected)
  testkit.equal(state, decode(decoded.payload), "SELECT 1", "secure message recovered")
  testkit.errorCode(state, try(connection.unprotectMessage(receiver, protected)), 9030, "replayed sequence rejected")
  testkit.errorCode(state, try(connection.unprotectMessage(receiver, original)), 9030, "plaintext rejected after activation")
  testkit.errorCode(state, try(network.listenAddress("0.0.0.0", 7432, 1, false)), 9001, "remote bind rejected without secure server mode")

  // Explicitly wipe every secret or derived byte buffer owned by this test.
  uuid.wipeSecret(key)
  uuid.wipeSecret(plaintext)
  uuid.wipeSecret(recovered)
  uuid.wipeSecret(packet.ciphertext)
  uuid.wipeSecret(packet.tag)
  uuid.wipeSecret(secondPacket.ciphertext)
  uuid.wipeSecret(secondPacket.tag)
  return testkit.finish(state, "MiniSQL M29 secure transport tests: SUCCESS", "MiniSQL M29 secure transport tests: FAIL")
end function
