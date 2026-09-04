# `minisql.admin.win32_client.ConnectionTask`

[Home](README.md) · [Source file](File-src-minisql-admin-win32-client-ml-1780719346.md)

<a id="struct-struct-minisql-admin-win32-client-connectiontask-struct-connectiontask-src-minisql-admin-win32-client-ml-48619473"></a>
## ConnectionTask

```ml
struct ConnectionTask
```

Owns credentials while one connection handshake runs outside the UI thread.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L456)

## Members

<a id="field-field-minisql-admin-win32-client-connectiontask-password-password-src-minisql-admin-win32-client-ml-1647543252"></a>
### password

```ml
password
```

Stores transient password bytes read from the password editor.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L460)

<a id="field-field-minisql-admin-win32-client-connectiontask-profile-profile-src-minisql-admin-win32-client-ml-767975842"></a>
### profile

```ml
profile
```

Stores the validated, secret-free connection profile.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L458)
