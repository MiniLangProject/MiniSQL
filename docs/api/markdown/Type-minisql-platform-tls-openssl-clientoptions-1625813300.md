# `minisql.platform.tls_openssl.ClientOptions`

[Home](README.md) · [Source file](File-src-minisql-platform-tls-openssl-ml-2109347483.md)

<a id="struct-struct-minisql-platform-tls-openssl-clientoptions-struct-clientoptions-src-minisql-platform-tls-openssl-ml-2143181423"></a>
## ClientOptions

```ml
struct ClientOptions
```

These option records mirror the backend-neutral std.tls contract without importing its conditional facade into a Linux-only adapter.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L35)

## Members

<a id="field-field-minisql-platform-tls-openssl-clientoptions-cafile-cafile-src-minisql-platform-tls-openssl-ml-266187208"></a>
### caFile

```ml
caFile
```

Optional explicit CA bundle path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L45)

<a id="field-field-minisql-platform-tls-openssl-clientoptions-minimumversion-minimumversion-src-minisql-platform-tls-openssl-ml-572479452"></a>
### minimumVersion

```ml
minimumVersion
```

Minimum TLS protocol version.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L43)

<a id="field-field-minisql-platform-tls-openssl-clientoptions-servername-servername-src-minisql-platform-tls-openssl-ml-1505067768"></a>
### serverName

```ml
serverName
```

DNS name required for SNI and hostname validation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L37)

<a id="field-field-minisql-platform-tls-openssl-clientoptions-sha256pin-sha256pin-src-minisql-platform-tls-openssl-ml-715742560"></a>
### sha256Pin

```ml
sha256Pin
```

Optional exact SHA-256 leaf pin bytes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L41)

<a id="field-field-minisql-platform-tls-openssl-clientoptions-verifypeer-verifypeer-src-minisql-platform-tls-openssl-ml-275076238"></a>
### verifyPeer

```ml
verifyPeer
```

Whether the server certificate chain must be verified.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L39)
