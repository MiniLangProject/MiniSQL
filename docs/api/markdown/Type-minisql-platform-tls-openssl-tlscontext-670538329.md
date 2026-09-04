# `minisql.platform.tls_openssl.TlsContext`

[Home](README.md) · [Source file](File-src-minisql-platform-tls-openssl-ml-2109347483.md)

<a id="struct-struct-minisql-platform-tls-openssl-tlscontext-struct-tlscontext-src-minisql-platform-tls-openssl-ml-418681155"></a>
## TlsContext

```ml
struct TlsContext
```

Owns one established OpenSSL TLS stream.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L26)

## Members

<a id="field-field-minisql-platform-tls-openssl-tlscontext-closed-closed-src-minisql-platform-tls-openssl-ml-646250045"></a>
### closed

```ml
closed
```

True after the stream has been closed.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L30)

<a id="field-field-minisql-platform-tls-openssl-tlscontext-stream-stream-src-minisql-platform-tls-openssl-ml-1867832589"></a>
### stream

```ml
stream
```

Native `std.tls._openssl` stream wrapper.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L28)
