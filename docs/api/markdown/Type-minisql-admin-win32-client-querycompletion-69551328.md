# `minisql.admin.win32_client.QueryCompletion`

[Home](README.md) · [Source file](File-src-minisql-admin-win32-client-ml-1780719346.md)

<a id="struct-struct-minisql-admin-win32-client-querycompletion-struct-querycompletion-src-minisql-admin-win32-client-ml-1322210607"></a>
## QueryCompletion

```ml
struct QueryCompletion
```

Carries one worker result and its optional object-tree refresh back to the UI.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L351)

## Members

<a id="field-field-minisql-admin-win32-client-querycompletion-operation-operation-src-minisql-admin-win32-client-ml-204571381"></a>
### operation

```ml
operation
```

Identifies the operation that produced this completion.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L353)

<a id="field-field-minisql-admin-win32-client-querycompletion-refreshresult-refreshresult-src-minisql-admin-win32-client-ml-1065632933"></a>
### refreshResult

```ml
refreshResult
```

Stores the follow-up refresh result or void when no refresh was required.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L357)

<a id="field-field-minisql-admin-win32-client-querycompletion-result-result-src-minisql-admin-win32-client-ml-1220563835"></a>
### result

```ml
result
```

Stores the primary operation result or structured error.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L355)

<a id="field-field-minisql-admin-win32-client-querycompletion-statustext-statustext-src-minisql-admin-win32-client-ml-1182765047"></a>
### statusText

```ml
statusText
```

Preserves the primary status text before a refresh updates shared state.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/win32_client.ml#L359)
