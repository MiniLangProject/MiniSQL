# `minisql.platform.tls_policy.TlsCipherSuite`

[Home](README.md) · [Source file](File-src-minisql-platform-tls-policy-ml-1426658235.md)

<a id="struct-struct-minisql-platform-tls-policy-tlsciphersuite-struct-tlsciphersuite-src-minisql-platform-tls-policy-ml-1854691967"></a>
## TlsCipherSuite

```ml
struct TlsCipherSuite
```

Describes one TLS 1.3 cipher suite independently of the platform provider.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L36)

## Members

<a id="field-field-minisql-platform-tls-policy-tlsciphersuite-aead-aead-src-minisql-platform-tls-policy-ml-1995705311"></a>
### aead

```ml
aead
```

AEAD primitive that protects TLS application records.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L42)

<a id="field-field-minisql-platform-tls-policy-tlsciphersuite-hash-hash-src-minisql-platform-tls-policy-ml-1310719009"></a>
### hash

```ml
hash
```

HKDF transcript hash selected by this TLS 1.3 cipher suite.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L50)

<a id="field-field-minisql-platform-tls-policy-tlsciphersuite-hashbytes-hashbytes-src-minisql-platform-tls-policy-ml-2068141917"></a>
### hashBytes

```ml
hashBytes
```

Digest size of the selected transcript hash.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L52)

<a id="field-field-minisql-platform-tls-policy-tlsciphersuite-ivbytes-ivbytes-src-minisql-platform-tls-policy-ml-596692081"></a>
### ivBytes

```ml
ivBytes
```

Number of static IV bytes used by the TLS record nonce construction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L46)

<a id="field-field-minisql-platform-tls-policy-tlsciphersuite-keybytes-keybytes-src-minisql-platform-tls-policy-ml-1520185217"></a>
### keyBytes

```ml
keyBytes
```

Number of traffic-key bytes required by the AEAD primitive.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L44)

<a id="field-field-minisql-platform-tls-policy-tlsciphersuite-name-name-src-minisql-platform-tls-policy-ml-1094042475"></a>
### name

```ml
name
```

Stable IANA cipher-suite name used by configuration and diagnostics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L40)

<a id="field-field-minisql-platform-tls-policy-tlsciphersuite-tagbytes-tagbytes-src-minisql-platform-tls-policy-ml-1333172115"></a>
### tagBytes

```ml
tagBytes
```

Authentication-tag size emitted for every encrypted TLS record.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L48)

<a id="field-field-minisql-platform-tls-policy-tlsciphersuite-wireid-wireid-src-minisql-platform-tls-policy-ml-316921713"></a>
### wireId

```ml
wireId
```

Two-byte IANA cipher-suite identifier carried in ServerHello.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L38)
