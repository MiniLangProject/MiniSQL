# `minisql.platform.tls_policy.CertificatePolicy`

[Home](README.md) · [Source file](File-src-minisql-platform-tls-policy-ml-1426658235.md)

<a id="struct-struct-minisql-platform-tls-policy-certificatepolicy-struct-certificatepolicy-src-minisql-platform-tls-policy-ml-1075736579"></a>
## CertificatePolicy

```ml
struct CertificatePolicy
```

Defines how a client authenticates the peer certificate.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L70)

## Members

<a id="field-field-minisql-platform-tls-policy-certificatepolicy-mode-mode-src-minisql-platform-tls-policy-ml-1366044808"></a>
### mode

```ml
mode
```

Either `system` for Windows trust or `pin-sha256` for an exact leaf pin.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L72)

<a id="field-field-minisql-platform-tls-policy-certificatepolicy-pinnedleafsha256-pinnedleafsha256-src-minisql-platform-tls-policy-ml-1700318756"></a>
### pinnedLeafSha256

```ml
pinnedLeafSha256
```

Exact SHA-256 digest of the leaf certificate DER, or empty for system trust.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L76)

<a id="field-field-minisql-platform-tls-policy-certificatepolicy-servername-servername-src-minisql-platform-tls-policy-ml-1514282278"></a>
### serverName

```ml
serverName
```

DNS name checked against the certificate and sent as TLS SNI.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L74)
