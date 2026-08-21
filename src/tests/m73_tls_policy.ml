// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian
import minisql.platform.tls_policy as tls_policy
import tests.support.testkit as test

// Builds a minimal, well-formed TLS 1.3 ServerHello selecting the MiniSQL profile.
function serverHello()
  record = bytes(95, 0)
  record[0] = 22
  endian.writeU16BE(record, 1, 0x0303)
  endian.writeU16BE(record, 3, 90)
  record[5] = 2
  record[6] = 0
  record[7] = 0
  record[8] = 86
  endian.writeU16BE(record, 9, 0x0303)
  record[43] = 0
  endian.writeU16BE(record, 44, tls_policy.TLS_AES_256_GCM_SHA384_ID)
  record[46] = 0
  endian.writeU16BE(record, 47, 46)
  endian.writeU16BE(record, 49, 0x002B)
  endian.writeU16BE(record, 51, 2)
  endian.writeU16BE(record, 53, 0x0304)
  endian.writeU16BE(record, 55, 0x0033)
  endian.writeU16BE(record, 57, 36)
  endian.writeU16BE(record, 59, tls_policy.X25519_ID)
  endian.writeU16BE(record, 61, 32)
  for index = 0 to 31
    record[63 + index] = index + 1
  end for
  return record
end function

// Runs the pure TLS registry, pin parser, and ServerHello enforcement contract.
function main(args)
  state = test.create()
  policy = tls_policy.defaultClientPolicy("localhost")
  test.equal(state, tls_policy.validate(policy), true, "default policy type")
  test.equal(state, policy.cipherSuites[0].name, "TLS_AES_256_GCM_SHA384", "cipher suite")
  test.equal(state, policy.groups[0].name, "X25519", "named group")

  selection = tls_policy.verifyServerHello(policy, serverHello())
  test.record(state, typeof(selection) != "error", "ServerHello selection")
  test.equal(state, selection.protocolVersion, 0x0304, "TLS version")
  test.equal(state, selection.cipherSuiteId, 0x1302, "cipher ID")
  test.equal(state, selection.groupId, 0x001D, "group ID")

  pin = tls_policy.parseSha256Pin("sha256:000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f")
  test.record(state, typeof(pin) == "bytes" and len(pin) == 32 and pin[31] == 31, "pin parser")
  shortPin = try(tls_policy.parseSha256Pin("00"))
  test.record(state, typeof(shortPin) == "error", "short pin rejection")

  wrongSuite = serverHello()
  endian.writeU16BE(wrongSuite, 44, 0x1301)
  suiteResult = try(tls_policy.verifyServerHello(policy, wrongSuite))
  test.record(state, typeof(suiteResult) == "error", "forbidden cipher rejection")

  wrongGroup = serverHello()
  endian.writeU16BE(wrongGroup, 59, 0x0017)
  groupResult = try(tls_policy.verifyServerHello(policy, wrongGroup))
  test.record(state, typeof(groupResult) == "error", "forbidden group rejection")

  test.verifyChecks(state, 11, "M73 TLS policy checks")
  return test.finish(state, "MiniSQL M73 TLS policy test: SUCCESS", "MiniSQL M73 TLS policy test: FAILED")
end function
