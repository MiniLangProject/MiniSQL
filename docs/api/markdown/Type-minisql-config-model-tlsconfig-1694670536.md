# `minisql.config.model.TlsConfig`

[Home](README.md) · [Source file](File-src-minisql-config-model-ml-1120384851.md)

<a id="struct-struct-minisql-config-model-tlsconfig-struct-tlsconfig-src-minisql-config-model-ml-1004438859"></a>
## TlsConfig

```ml
struct TlsConfig
```

Defines the native TLS server profile independently of ordinary authentication.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L79)

## Members

<a id="field-field-minisql-config-model-tlsconfig-certificatereference-certificatereference-src-minisql-config-model-ml-59896160"></a>
### certificateReference

```ml
certificateReference
```

Locates the server certificate as store:/pfx: on Windows or pem:cert|key on Linux.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L83)

<a id="field-field-minisql-config-model-tlsconfig-ciphersuite-ciphersuite-src-minisql-config-model-ml-2129168624"></a>
### cipherSuite

```ml
cipherSuite
```

Declares the only cipher suite accepted by the current fail-closed policy.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L87)

<a id="field-field-minisql-config-model-tlsconfig-enabled-enabled-src-minisql-config-model-ml-168034112"></a>
### enabled

```ml
enabled
```

Enables native TLS 1.3 for the configured listener.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L81)

<a id="field-field-minisql-config-model-tlsconfig-namedgroup-namedgroup-src-minisql-config-model-ml-2000846900"></a>
### namedGroup

```ml
namedGroup
```

Declares the only key-exchange group accepted by the current policy.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L89)

<a id="field-field-minisql-config-model-tlsconfig-pfxpasswordenvironment-pfxpasswordenvironment-src-minisql-config-model-ml-598646220"></a>
### pfxPasswordEnvironment

```ml
pfxPasswordEnvironment
```

Names the environment variable that supplies an optional PFX password.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L85)

<a id="field-field-minisql-config-model-tlsconfig-protocolversion-protocolversion-src-minisql-config-model-ml-843568520"></a>
### protocolVersion

```ml
protocolVersion
```

Declares the exact protocol version accepted by the current policy.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/config/model.ml#L91)
