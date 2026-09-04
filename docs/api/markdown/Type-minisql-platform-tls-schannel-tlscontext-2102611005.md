# `minisql.platform.tls_schannel.TlsContext`

[Home](README.md) · [Source file](File-src-minisql-platform-tls-schannel-ml-61867785.md)

<a id="struct-struct-minisql-platform-tls-schannel-tlscontext-struct-tlscontext-src-minisql-platform-tls-schannel-ml-618011011"></a>
## TlsContext

```ml
struct TlsContext
```

Holds one established TLS connection plus its encrypted and plaintext queues.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L208)

## Members

<a id="field-field-minisql-platform-tls-schannel-tlscontext-attributes-attributes-src-minisql-platform-tls-schannel-ml-1816493409"></a>
### attributes

```ml
attributes
```

Negotiated SSPI context attributes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L216)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-closed-closed-src-minisql-platform-tls-schannel-ml-437562527"></a>
### closed

```ml
closed
```

Prevents use or release after closure.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L218)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-credential-credential-src-minisql-platform-tls-schannel-ml-1132596693"></a>
### credential

```ml
credential
```

Credential that authenticated and parameterized this connection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L210)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-decryptedinput-decryptedinput-src-minisql-platform-tls-schannel-ml-1221475023"></a>
### decryptedInput

```ml
decryptedInput
```

Plaintext produced by Schannel but not yet consumed by MiniSQL framing.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L224)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-encryptedinput-encryptedinput-src-minisql-platform-tls-schannel-ml-14646047"></a>
### encryptedInput

```ml
encryptedInput
```

TLS records received but not yet consumed by Schannel.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L222)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-expiry-expiry-src-minisql-platform-tls-schannel-ml-495387633"></a>
### expiry

```ml
expiry
```

Context expiry timestamp returned by SSPI.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L214)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-handle-handle-src-minisql-platform-tls-schannel-ml-323715279"></a>
### handle

```ml
handle
```

SSPI CtxtHandle encoded in native-layout bytes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L212)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-handshaketranscript-handshaketranscript-src-minisql-platform-tls-schannel-ml-667004743"></a>
### handshakeTranscript

```ml
handshakeTranscript
```

Handshake records retained until the ServerHello profile is verified.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L234)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-maximummessagebytes-maximummessagebytes-src-minisql-platform-tls-schannel-ml-1935706019"></a>
### maximumMessageBytes

```ml
maximumMessageBytes
```

Maximum plaintext carried by one encrypted TLS record.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L230)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-negotiatedciphersuite-negotiatedciphersuite-src-minisql-platform-tls-schannel-ml-2139145831"></a>
### negotiatedCipherSuite

```ml
negotiatedCipherSuite
```

IANA identifier of the negotiated TLS cipher suite.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L236)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-negotiatedgroup-negotiatedgroup-src-minisql-platform-tls-schannel-ml-1337717747"></a>
### negotiatedGroup

```ml
negotiatedGroup
```

IANA identifier of the negotiated key-exchange group.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L238)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-peercertificatesha256-peercertificatesha256-src-minisql-platform-tls-schannel-ml-1959677055"></a>
### peerCertificateSha256

```ml
peerCertificateSha256
```

SHA-256 digest of the peer leaf certificate in DER form.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L240)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-policy-policy-src-minisql-platform-tls-schannel-ml-308591675"></a>
### policy

```ml
policy
```

Immutable version, cipher, group, and certificate-validation policy.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L232)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-server-server-src-minisql-platform-tls-schannel-ml-757572493"></a>
### server

```ml
server
```

True for the accepted server side and false for the connecting client side.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L220)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-streamheaderbytes-streamheaderbytes-src-minisql-platform-tls-schannel-ml-1864226283"></a>
### streamHeaderBytes

```ml
streamHeaderBytes
```

Provider-specific record header capacity.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L226)

<a id="field-field-minisql-platform-tls-schannel-tlscontext-streamtrailerbytes-streamtrailerbytes-src-minisql-platform-tls-schannel-ml-1046976963"></a>
### streamTrailerBytes

```ml
streamTrailerBytes
```

Provider-specific AEAD trailer capacity.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L228)
