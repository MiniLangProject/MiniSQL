# `minisql.platform.tls_policy.TlsPolicy`

[Home](README.md) · [Source file](File-src-minisql-platform-tls-policy-ml-1426658235.md)

<a id="struct-struct-minisql-platform-tls-policy-tlspolicy-struct-tlspolicy-src-minisql-platform-tls-policy-ml-899271599"></a>
## TlsPolicy

```ml
struct TlsPolicy
```

Collects all independently extensible TLS policy dimensions.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L80)

## Members

<a id="field-field-minisql-platform-tls-policy-tlspolicy-certificatepolicy-certificatepolicy-src-minisql-platform-tls-policy-ml-1467710332"></a>
### certificatePolicy

```ml
certificatePolicy
```

Peer certificate authentication policy used by a client.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L90)

<a id="field-field-minisql-platform-tls-policy-tlspolicy-ciphersuites-ciphersuites-src-minisql-platform-tls-policy-ml-1435004992"></a>
### cipherSuites

```ml
cipherSuites
```

Explicit allow-list of accepted TLS 1.3 cipher suites.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L86)

<a id="field-field-minisql-platform-tls-policy-tlspolicy-groups-groups-src-minisql-platform-tls-policy-ml-1388638444"></a>
### groups

```ml
groups
```

Explicit allow-list of accepted key-exchange groups.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L88)

<a id="field-field-minisql-platform-tls-policy-tlspolicy-maximumversion-maximumversion-src-minisql-platform-tls-policy-ml-1517324864"></a>
### maximumVersion

```ml
maximumVersion
```

Maximum accepted TLS protocol version.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L84)

<a id="field-field-minisql-platform-tls-policy-tlspolicy-minimumversion-minimumversion-src-minisql-platform-tls-policy-ml-1652080964"></a>
### minimumVersion

```ml
minimumVersion
```

Minimum accepted TLS protocol version.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L82)
