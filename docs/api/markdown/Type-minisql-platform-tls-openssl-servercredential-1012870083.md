# `minisql.platform.tls_openssl.ServerCredential`

[Home](README.md) · [Source file](File-src-minisql-platform-tls-openssl-ml-2109347483.md)

<a id="struct-struct-minisql-platform-tls-openssl-servercredential-struct-servercredential-src-minisql-platform-tls-openssl-ml-536512139"></a>
## ServerCredential

```ml
struct ServerCredential
```

Owns immutable OpenSSL server options until listener shutdown.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L16)

## Members

<a id="field-field-minisql-platform-tls-openssl-servercredential-closed-closed-src-minisql-platform-tls-openssl-ml-1499832127"></a>
### closed

```ml
closed
```

True after the listener has released this credential.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L20)

<a id="field-field-minisql-platform-tls-openssl-servercredential-options-options-src-minisql-platform-tls-openssl-ml-1548177471"></a>
### options

```ml
options
```

Certificate, private-key, client-auth, and protocol settings.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L18)
