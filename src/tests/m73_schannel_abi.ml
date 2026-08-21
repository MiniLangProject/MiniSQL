// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian
import minisql.platform.tls_policy as tls_policy
import minisql.platform.tls_schannel as tls_schannel
import tests.support.testkit as test

// Exercises native credential acquisition and the security-sensitive ABI layouts.
function main(args)
  state = test.create()
  policy = tls_policy.defaultClientPolicy("localhost")
  credential = tls_schannel.acquireClientCredential(policy)
  test.record(state, tls_schannel.isCredential(credential), "client credential acquired")
  test.record(state, not credential.manualValidation, "system validation credential")
  test.equal(state, endian.readU32LE(credential.credentialBytes, 0), tls_schannel.SCH_CREDENTIALS_VERSION, "crypto-agile credential ABI")
  test.equal(state, endian.readU32LE(credential.tlsParameters, 16), tls_schannel.SP_PROT_LEGACY_CLIENT, "legacy protocols disabled")
  test.record(state, tls_schannel.closeCredential(credential), "client credential released")

  pinPolicy = tls_policy.pinnedClientPolicy("localhost", "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f")
  pinnedCredential = tls_schannel.acquireClientCredential(pinPolicy)
  test.record(state, pinnedCredential.manualValidation, "pinning uses manual validation")
  test.record(state, tls_schannel.closeCredential(pinnedCredential), "pinned credential released")
  test.equal(state, tls_schannel.SECPKG_CIPHER_INFO_BYTES, 680, "cipher-info ABI size")
  test.equal(state, tls_schannel.CERT_CHAIN_PARA_BYTES, 96, "chain-parameter ABI size")
  test.verifyChecks(state, 9, "M73 Schannel ABI checks")
  return test.finish(state, "MiniSQL M73 Schannel ABI test: SUCCESS", "MiniSQL M73 Schannel ABI test: FAILED")
end function
