# `src/minisql/platform/tls_openssl.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql platform tls openssl facilities for this project.

Package: [`minisql.platform.tls_openssl`](Package-minisql-platform-tls-openssl-1281501093.md)

Reachable from entry: **no**

## Imports

- `minisql/platform/network.ml` as `network` → [src/minisql/platform/network.ml](File-src-minisql-platform-network-ml-77221021.md)
- `minisql/platform/tls_policy.ml` as `tls_policy` → [src/minisql/platform/tls_policy.ml](File-src-minisql-platform-tls-policy-ml-1426658235.md)
- `std/tls/_openssl.ml` as `openssl` → `../MiniLangCompilerML/std/tls/_openssl.ml` — external dependency

## Declarations

<a id="function-function-minisql-platform-tls-openssl-acceptserver-function-acceptserver-sockethandle-credential-src-minisql-platform-tls-openssl-ml-112901004"></a>
### acceptServer

```ml
function acceptServer(socketHandle, credential)
```

Accepts one TLS server stream on an already connected socket.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |
| `credential` | `dynamic` | — | credential value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L146)

<a id="function-function-minisql-platform-tls-openssl-acquireservercredential-function-acquireservercredential-src-minisql-platform-tls-openssl-ml-1467706578"></a>
### acquireServerCredential

```ml
function acquireServerCredential()
```

Rejects credential acquisition without an explicit Linux PEM reference.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L118)

<a id="function-function-minisql-platform-tls-openssl-acquireservercredentialwithpassword-function-acquireservercredentialwithpassword-certificatereference-passwordbytes-src-minisql-platform-tls-openssl-ml-560246366"></a>
### acquireServerCredentialWithPassword

```ml
function acquireServerCredentialWithPassword(certificateReference, passwordBytes)
```

Creates server options from an unencrypted PEM certificate and key reference.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `certificateReference` | `dynamic` | — | certificateReference value consumed by this operation. |
| `passwordBytes` | `dynamic` | — | passwordBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L125)

- [minisql.platform.tls_openssl.ClientOptions](Type-minisql-platform-tls-openssl-clientoptions-1625813300.md) — struct
<a id="function-function-minisql-platform-tls-openssl-closecontext-function-closecontext-context-src-minisql-platform-tls-openssl-ml-1159761225"></a>
### closeContext

```ml
function closeContext(context)
```

Releases one TLS stream and marks the wrapper closed.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L208)

<a id="function-function-minisql-platform-tls-openssl-closecredential-function-closecredential-credential-src-minisql-platform-tls-openssl-ml-1262237651"></a>
### closeCredential

```ml
function closeCredential(credential)
```

Marks a server credential closed after listener shutdown.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `credential` | `dynamic` | — | credential value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L137)

<a id="function-function-minisql-platform-tls-openssl-componentname-function-componentname-src-minisql-platform-tls-openssl-ml-900280126"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name used by the module catalog.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L221)

<a id="function-function-minisql-platform-tls-openssl-connectclient-function-connectclient-sockethandle-servername-src-minisql-platform-tls-openssl-ml-2135938577"></a>
### connectClient

```ml
function connectClient(socketHandle, serverName)
```

Performs a verified TLS client handshake using system trust and hostname checks.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L77)

<a id="function-function-minisql-platform-tls-openssl-connectclientpinned-function-connectclientpinned-sockethandle-servername-pintext-src-minisql-platform-tls-openssl-ml-1090439497"></a>
### connectClientPinned

```ml
function connectClientPinned(socketHandle, serverName, pinText)
```

Performs a verified TLS client handshake with an additional exact leaf pin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |
| `pinText` | `dynamic` | — | pinText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L88)

<a id="function-function-minisql-platform-tls-openssl-fail-function-fail-operation-message-src-minisql-platform-tls-openssl-ml-2051944426"></a>
### fail

```ml
function fail(operation, message)
```

Creates a stable MiniSQL TLS error with provider context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L63)

<a id="constant-constant-minisql-platform-tls-openssl-invalid-argument-const-invalid-argument-9001-src-minisql-platform-tls-openssl-ml-106467635"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

OpenSSL-backed compatibility adapter for MiniSQL's established Schannel


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L13)

<a id="function-function-minisql-platform-tls-openssl-iscredential-function-iscredential-value-src-minisql-platform-tls-openssl-ml-845291527"></a>
### isCredential

```ml
function isCredential(value)
```

Reports whether a value is an OpenSSL server credential.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L69)

<a id="function-function-minisql-platform-tls-openssl-isimplemented-function-isimplemented-src-minisql-platform-tls-openssl-ml-775886350"></a>
### isImplemented

```ml
function isImplemented()
```

Reports that the OpenSSL backend is complete.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L231)

<a id="function-function-minisql-platform-tls-openssl-istlscontext-function-istlscontext-value-src-minisql-platform-tls-openssl-ml-17185167"></a>
### isTlsContext

```ml
function isTlsContext(value)
```

Reports whether a value is an open OpenSSL TLS context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L72)

<a id="function-function-minisql-platform-tls-openssl-providername-function-providername-src-minisql-platform-tls-openssl-ml-1149016846"></a>
### providerName

```ml
function providerName()
```

Returns the diagnostic provider name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L218)

<a id="function-function-minisql-platform-tls-openssl-receiveavailable-function-receiveavailable-context-sockethandle-maximum-src-minisql-platform-tls-openssl-ml-1672423348"></a>
### receiveAvailable

```ml
function receiveAvailable(context, socketHandle, maximum)
```

Receives up to the requested bounded count from a TLS stream.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |
| `maximum` | `dynamic` | — | maximum value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L168)

<a id="function-function-minisql-platform-tls-openssl-receiveexact-function-receiveexact-context-sockethandle-count-src-minisql-platform-tls-openssl-ml-1761416323"></a>
### receiveExact

```ml
function receiveExact(context, socketHandle, count)
```

Receives exactly the requested count or reports premature connection closure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L180)

<a id="function-function-minisql-platform-tls-openssl-sendall-function-sendall-context-sockethandle-data-src-minisql-platform-tls-openssl-ml-756994922"></a>
### sendAll

```ml
function sendAll(context, socketHandle, data)
```

Sends the complete byte buffer over an established TLS stream.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L157)

- [minisql.platform.tls_openssl.ServerCredential](Type-minisql-platform-tls-openssl-servercredential-1012870083.md) — struct
- [minisql.platform.tls_openssl.ServerOptions](Type-minisql-platform-tls-openssl-serveroptions-1414406072.md) — struct
<a id="function-function-minisql-platform-tls-openssl-shutdown-function-shutdown-context-sockethandle-src-minisql-platform-tls-openssl-ml-1185133392"></a>
### shutdown

```ml
function shutdown(context, socketHandle)
```

Sends and receives the provider's authenticated TLS shutdown notification.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L198)

<a id="function-function-minisql-platform-tls-openssl-splitpemreference-function-splitpemreference-certificatereference-src-minisql-platform-tls-openssl-ml-1393541124"></a>
### splitPemReference

```ml
function splitPemReference(certificateReference)
```

Parses the Linux `pem:certificate|private-key` server reference.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `certificateReference` | `dynamic` | — | certificateReference value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L99)

<a id="function-function-minisql-platform-tls-openssl-targetmilestone-function-targetmilestone-src-minisql-platform-tls-openssl-ml-122786532"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone whose TLS contract this provider implements.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L226)

<a id="constant-constant-minisql-platform-tls-openssl-tls-error-const-tls-error-9034-src-minisql-platform-tls-openssl-ml-1924264579"></a>
### TLS_ERROR

```ml
const TLS_ERROR = 9034
```

Defines the tls error constant used by the minisql platform tls openssl module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_openssl.ml#L15)

- [minisql.platform.tls_openssl.TlsContext](Type-minisql-platform-tls-openssl-tlscontext-670538329.md) — struct
