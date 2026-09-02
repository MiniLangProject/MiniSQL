# `minisql.admin.win32_client.ConnectionAttempt`

[Home](README.md) · [Source file](File-src-minisql-admin-win32-client-ml-1780719346.md)

<a id="struct-struct-minisql-admin-win32-client-connectionattempt-struct-connectionattempt-src-minisql-admin-win32-client-ml-723610317"></a>
## ConnectionAttempt

```ml
struct ConnectionAttempt
```

Tracks a connection worker and guarantees eventual credential destruction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L371)

## Members

<a id="field-field-minisql-admin-win32-client-connectionattempt-busy-busy-src-minisql-admin-win32-client-ml-1828668280"></a>
### busy

```ml
busy
```

Indicates whether a handshake is currently in flight.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L377)

<a id="field-field-minisql-admin-win32-client-connectionattempt-password-password-src-minisql-admin-win32-client-ml-2010157608"></a>
### password

```ml
password
```

Stores the caller-owned password bytes until the worker has terminated.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L375)

<a id="field-field-minisql-admin-win32-client-connectionattempt-worker-worker-src-minisql-admin-win32-client-ml-894303498"></a>
### worker

```ml
worker
```

Stores the active native handshake worker or void.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L373)
