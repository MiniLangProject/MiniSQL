# `minisql.platform.tls_openssl.ServerOptions`

[Home](README.md) · [Source file](File-src-minisql-platform-tls-openssl-ml-2109347483.md)

<a id="struct-struct-minisql-platform-tls-openssl-serveroptions-struct-serveroptions-src-minisql-platform-tls-openssl-ml-664346079"></a>
## ServerOptions

```ml
struct ServerOptions
```

Describes the server certificate and protocol settings passed to OpenSSL.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L47)

## Members

<a id="field-field-minisql-platform-tls-openssl-serveroptions-certificatereference-certificatereference-src-minisql-platform-tls-openssl-ml-121811372"></a>
### certificateReference

```ml
certificateReference
```

PEM certificate-chain path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L49)

<a id="field-field-minisql-platform-tls-openssl-serveroptions-minimumversion-minimumversion-src-minisql-platform-tls-openssl-ml-1026603624"></a>
### minimumVersion

```ml
minimumVersion
```

Minimum encoded TLS protocol version.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L55)

<a id="field-field-minisql-platform-tls-openssl-serveroptions-privatekeyreference-privatekeyreference-src-minisql-platform-tls-openssl-ml-1659881376"></a>
### privateKeyReference

```ml
privateKeyReference
```

PEM private-key path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L51)

<a id="field-field-minisql-platform-tls-openssl-serveroptions-requireclientcertificate-requireclientcertificate-src-minisql-platform-tls-openssl-ml-1449140274"></a>
### requireClientCertificate

```ml
requireClientCertificate
```

Whether the server requires a client certificate.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L53)
