# `minisql.platform.tls_policy.TlsNamedGroup`

[Home](README.md) · [Source file](File-src-minisql-platform-tls-policy-ml-1426658235.md)

<a id="struct-struct-minisql-platform-tls-policy-tlsnamedgroup-struct-tlsnamedgroup-src-minisql-platform-tls-policy-ml-1098003155"></a>
## TlsNamedGroup

```ml
struct TlsNamedGroup
```

Describes one TLS named group independently of the platform provider.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L56)

## Members

<a id="field-field-minisql-platform-tls-policy-tlsnamedgroup-family-family-src-minisql-platform-tls-policy-ml-233539650"></a>
### family

```ml
family
```

Key-agreement family used for security review and diagnostics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L62)

<a id="field-field-minisql-platform-tls-policy-tlsnamedgroup-name-name-src-minisql-platform-tls-policy-ml-1862155528"></a>
### name

```ml
name
```

Stable IANA group name used by configuration and diagnostics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L60)

<a id="field-field-minisql-platform-tls-policy-tlsnamedgroup-publickeybytes-publickeybytes-src-minisql-platform-tls-policy-ml-493311268"></a>
### publicKeyBytes

```ml
publicKeyBytes
```

Encoded public-key length expected in a ServerHello key share.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L64)

<a id="field-field-minisql-platform-tls-policy-tlsnamedgroup-sharedsecretbytes-sharedsecretbytes-src-minisql-platform-tls-policy-ml-1819365086"></a>
### sharedSecretBytes

```ml
sharedSecretBytes
```

Shared-secret length produced by the key agreement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L66)

<a id="field-field-minisql-platform-tls-policy-tlsnamedgroup-wireid-wireid-src-minisql-platform-tls-policy-ml-997059422"></a>
### wireId

```ml
wireId
```

Two-byte IANA NamedGroup identifier carried in the key_share extension.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L58)
