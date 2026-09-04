# `minisql.security.key_provider.DatabaseKey`

[Home](README.md) · [Source file](File-src-minisql-security-key-provider-ml-1192998689.md)

<a id="struct-struct-minisql-security-key-provider-databasekey-struct-databasekey-src-minisql-security-key-provider-ml-611606493"></a>
## DatabaseKey

```ml
struct DatabaseKey
```

Owns one unwrapped wipeable DEK and its envelope identity.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L45)

## Members

<a id="field-field-minisql-security-key-provider-databasekey-databaseid-databaseid-src-minisql-security-key-provider-ml-809884909"></a>
### databaseId

```ml
databaseId
```

Immutable 16-byte database identifier.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L49)

<a id="field-field-minisql-security-key-provider-databasekey-databaseroot-databaseroot-src-minisql-security-key-provider-ml-1259753895"></a>
### databaseRoot

```ml
databaseRoot
```

Root directory containing the database envelope.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L47)

<a id="field-field-minisql-security-key-provider-databasekey-key-key-src-minisql-security-key-provider-ml-1130711265"></a>
### key

```ml
key
```

Mutable 32-byte DEK that must be wiped after use.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L53)

<a id="field-field-minisql-security-key-provider-databasekey-provider-provider-src-minisql-security-key-provider-ml-406766215"></a>
### provider

```ml
provider
```

Provider used to unwrap the DEK.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/security/key_provider.ml#L51)
