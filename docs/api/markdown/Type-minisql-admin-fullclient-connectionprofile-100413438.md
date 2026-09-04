# `minisql.admin.fullclient.ConnectionProfile`

[Home](README.md) · [Source file](File-src-minisql-admin-fullclient-ml-1896932593.md)

<a id="struct-struct-minisql-admin-fullclient-connectionprofile-struct-connectionprofile-src-minisql-admin-fullclient-ml-120265257"></a>
## ConnectionProfile

```ml
struct ConnectionProfile
```

Describes one persistent MiniSQL connection alias without retaining a password.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L41)

## Members

<a id="field-field-minisql-admin-fullclient-connectionprofile-address-address-src-minisql-admin-fullclient-ml-80560148"></a>
### address

```ml
address
```

Stores the TCP address of the MiniSQL server.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L45)

<a id="field-field-minisql-admin-fullclient-connectionprofile-databasename-databasename-src-minisql-admin-fullclient-ml-125185792"></a>
### databaseName

```ml
databaseName
```

Stores a user-visible label for the single database served by the endpoint.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L51)

<a id="field-field-minisql-admin-fullclient-connectionprofile-name-name-src-minisql-admin-fullclient-ml-1422029918"></a>
### name

```ml
name
```

Stores the user-visible alias name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L43)

<a id="field-field-minisql-admin-fullclient-connectionprofile-pinsha256-pinsha256-src-minisql-admin-fullclient-ml-860884304"></a>
### pinSha256

```ml
pinSha256
```

Stores an optional exact SHA-256 leaf-certificate pin.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L57)

<a id="field-field-minisql-admin-fullclient-connectionprofile-port-port-src-minisql-admin-fullclient-ml-1770218610"></a>
### port

```ml
port
```

Stores the TCP port of the MiniSQL server.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L47)

<a id="field-field-minisql-admin-fullclient-connectionprofile-servername-servername-src-minisql-admin-fullclient-ml-912009576"></a>
### serverName

```ml
serverName
```

Stores the TLS server name used for X.509 hostname validation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L49)

<a id="field-field-minisql-admin-fullclient-connectionprofile-tls-tls-src-minisql-admin-fullclient-ml-493287884"></a>
### tls

```ml
tls
```

Selects native TLS 1.3 transport protection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L55)

<a id="field-field-minisql-admin-fullclient-connectionprofile-trustedlocal-trustedlocal-src-minisql-admin-fullclient-ml-2041923760"></a>
### trustedLocal

```ml
trustedLocal
```

Selects the loopback-only trusted-local server mode.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L59)

<a id="field-field-minisql-admin-fullclient-connectionprofile-username-username-src-minisql-admin-fullclient-ml-1913036728"></a>
### userName

```ml
userName
```

Stores the MiniSQL account name used for challenge-response authentication.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L53)
