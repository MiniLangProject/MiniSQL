# `minisql.platform.tls_policy.ServerHelloSelection`

[Home](README.md) · [Source file](File-src-minisql-platform-tls-policy-ml-1426658235.md)

<a id="struct-struct-minisql-platform-tls-policy-serverhelloselection-struct-serverhelloselection-src-minisql-platform-tls-policy-ml-1364259691"></a>
## ServerHelloSelection

```ml
struct ServerHelloSelection
```

Captures the security-relevant plaintext fields selected by ServerHello.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L86)

## Members

<a id="field-field-minisql-platform-tls-policy-serverhelloselection-ciphersuiteid-ciphersuiteid-src-minisql-platform-tls-policy-ml-1972546572"></a>
### cipherSuiteId

```ml
cipherSuiteId
```

Cipher suite selected by the server.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L90)

<a id="field-field-minisql-platform-tls-policy-serverhelloselection-groupid-groupid-src-minisql-platform-tls-policy-ml-182068456"></a>
### groupId

```ml
groupId
```

Named group selected by the server key_share extension.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L92)

<a id="field-field-minisql-platform-tls-policy-serverhelloselection-protocolversion-protocolversion-src-minisql-platform-tls-policy-ml-1124532088"></a>
### protocolVersion

```ml
protocolVersion
```

Version selected by the supported_versions extension.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L88)
