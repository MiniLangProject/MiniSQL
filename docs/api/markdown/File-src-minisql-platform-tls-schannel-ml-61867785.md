# `src/minisql/platform/tls_schannel.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql platform tls schannel facilities for this project.

Package: [`minisql.platform.tls_schannel`](Package-minisql-platform-tls-schannel-269248945.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/platform/network.ml` as `network` → [src/minisql/platform/network.ml](File-src-minisql-platform-network-ml-77221021.md)
- `minisql/platform/tls_policy.ml` as `tls_policy` → [src/minisql/platform/tls_policy.ml](File-src-minisql-platform-tls-policy-ml-1426658235.md)

## Declarations

<a id="extern_function-extern-function-minisql-platform-tls-schannel-acceptsecuritycontextcontinue-extern-function-acceptsecuritycontextcontinue-credentialhandle-as-bytes-contexthandle-as-bytes-inputdesc-as-bytes-contextreq-as-u32-targetdatarep-as-u32-newcontext-as-bytes-outputdesc-as-bytes-contextattr-as-bytes-expiry-as-bytes-from-secur32-dll-symbol-acceptsecuritycontext-returns-i32-src-minisql-platform-tls-schannel-ml-1944300757"></a>
### AcceptSecurityContextContinue

```ml
extern function AcceptSecurityContextContinue(credentialHandle as bytes, contextHandle as bytes, inputDesc as bytes, contextReq as u32, targetDataRep as u32, newContext as bytes, outputDesc as bytes, contextAttr as bytes, expiry as bytes) from "secur32.dll" symbol "AcceptSecurityContext" returns i32
```

Advances a server handshake using an existing context and peer input.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `credentialHandle` | `bytes` | — | credentialHandle value consumed by this operation. |
| `contextHandle` | `bytes` | — | contextHandle value consumed by this operation. |
| `inputDesc` | `bytes` | — | inputDesc value consumed by this operation. |
| `contextReq` | `u32` | — | contextReq value consumed by this operation. |
| `targetDataRep` | `u32` | — | targetDataRep value consumed by this operation. |
| `newContext` | `bytes` | — | newContext value consumed by this operation. |
| `outputDesc` | `bytes` | — | outputDesc value consumed by this operation. |
| `contextAttr` | `bytes` | — | contextAttr value consumed by this operation. |
| `expiry` | `bytes` | — | expiry value consumed by this operation. |


**Returns:** Native i32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L327)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-acceptsecuritycontextinitial-extern-function-acceptsecuritycontextinitial-credentialhandle-as-bytes-contexthandle-as-ptr-inputdesc-as-bytes-contextreq-as-u32-targetdatarep-as-u32-newcontext-as-bytes-outputdesc-as-bytes-contextattr-as-bytes-expiry-as-bytes-from-secur32-dll-symbol-acceptsecuritycontext-returns-i32-src-minisql-platform-tls-schannel-ml-909177022"></a>
### AcceptSecurityContextInitial

```ml
extern function AcceptSecurityContextInitial(credentialHandle as bytes, contextHandle as ptr, inputDesc as bytes, contextReq as u32, targetDataRep as u32, newContext as bytes, outputDesc as bytes, contextAttr as bytes, expiry as bytes) from "secur32.dll" symbol "AcceptSecurityContext" returns i32
```

Starts a server handshake from the first client token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `credentialHandle` | `bytes` | — | credentialHandle value consumed by this operation. |
| `contextHandle` | `ptr` | — | contextHandle value consumed by this operation. |
| `inputDesc` | `bytes` | — | inputDesc value consumed by this operation. |
| `contextReq` | `u32` | — | contextReq value consumed by this operation. |
| `targetDataRep` | `u32` | — | targetDataRep value consumed by this operation. |
| `newContext` | `bytes` | — | newContext value consumed by this operation. |
| `outputDesc` | `bytes` | — | outputDesc value consumed by this operation. |
| `contextAttr` | `bytes` | — | contextAttr value consumed by this operation. |
| `expiry` | `bytes` | — | expiry value consumed by this operation. |


**Returns:** Native i32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L315)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-acceptsecuritycontextshutdown-extern-function-acceptsecuritycontextshutdown-credentialhandle-as-bytes-contexthandle-as-bytes-inputdesc-as-ptr-contextreq-as-u32-targetdatarep-as-u32-newcontext-as-bytes-outputdesc-as-bytes-contextattr-as-bytes-expiry-as-bytes-from-secur32-dll-symbol-acceptsecuritycontext-returns-i32-src-minisql-platform-tls-schannel-ml-1748749408"></a>
### AcceptSecurityContextShutdown

```ml
extern function AcceptSecurityContextShutdown(credentialHandle as bytes, contextHandle as bytes, inputDesc as ptr, contextReq as u32, targetDataRep as u32, newContext as bytes, outputDesc as bytes, contextAttr as bytes, expiry as bytes) from "secur32.dll" symbol "AcceptSecurityContext" returns i32
```

Produces the server-side close_notify token after applying SCHANNEL_SHUTDOWN.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `credentialHandle` | `bytes` | — | credentialHandle value consumed by this operation. |
| `contextHandle` | `bytes` | — | contextHandle value consumed by this operation. |
| `inputDesc` | `ptr` | — | inputDesc value consumed by this operation. |
| `contextReq` | `u32` | — | contextReq value consumed by this operation. |
| `targetDataRep` | `u32` | — | targetDataRep value consumed by this operation. |
| `newContext` | `bytes` | — | newContext value consumed by this operation. |
| `outputDesc` | `bytes` | — | outputDesc value consumed by this operation. |
| `contextAttr` | `bytes` | — | contextAttr value consumed by this operation. |
| `expiry` | `bytes` | — | expiry value consumed by this operation. |


**Returns:** Native i32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L339)

<a id="function-function-minisql-platform-tls-schannel-acceptserver-function-acceptserver-sockethandle-credential-src-minisql-platform-tls-schannel-ml-1828498308"></a>
### acceptServer

```ml
function acceptServer(socketHandle, credential)
```

Completes a server handshake and enforces the current TLS algorithm profile.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |
| `credential` | `dynamic` | — | credential value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1230)

<a id="function-function-minisql-platform-tls-schannel-acquireclientcredential-function-acquireclientcredential-policy-src-minisql-platform-tls-schannel-ml-667000540"></a>
### acquireClientCredential

```ml
function acquireClientCredential(policy)
```

Acquires an outbound Schannel credential with automatic or manual pin validation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `policy` | `dynamic` | — | policy value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L808)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-acquirecredentialshandlewwithauth-extern-function-acquirecredentialshandlewwithauth-principal-as-ptr-packagename-as-wstr-credentialuse-as-u32-logonid-as-ptr-authdata-as-bytes-getkeyfn-as-ptr-getkeyargument-as-ptr-credentialhandle-as-bytes-expiry-as-bytes-from-secur32-dll-symbol-acquirecredentialshandlew-returns-i32-src-minisql-platform-tls-schannel-ml-857460501"></a>
### AcquireCredentialsHandleWWithAuth

```ml
extern function AcquireCredentialsHandleWWithAuth(principal as ptr, packageName as wstr, credentialUse as u32, logonId as ptr, authData as bytes, getKeyFn as ptr, getKeyArgument as ptr, credentialHandle as bytes, expiry as bytes) from "secur32.dll" symbol "AcquireCredentialsHandleW" returns i32
```

Acquires a Schannel credential from the supplied SCH_CREDENTIALS byte structure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `principal` | `ptr` | — | principal value consumed by this operation. |
| `packageName` | `wstr` | — | packageName value consumed by this operation. |
| `credentialUse` | `u32` | — | credentialUse value consumed by this operation. |
| `logonId` | `ptr` | — | Identifier of logon. |
| `authData` | `bytes` | — | authData value consumed by this operation. |
| `getKeyFn` | `ptr` | — | getKeyFn value consumed by this operation. |
| `getKeyArgument` | `ptr` | — | getKeyArgument value consumed by this operation. |
| `credentialHandle` | `bytes` | — | credentialHandle value consumed by this operation. |
| `expiry` | `bytes` | — | expiry value consumed by this operation. |


**Returns:** Native i32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L254)

<a id="function-function-minisql-platform-tls-schannel-acquireservercredential-function-acquireservercredential-src-minisql-platform-tls-schannel-ml-704840558"></a>
### acquireServerCredential

```ml
function acquireServerCredential()
```

Creates the compatibility server credential without an explicit identity.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L822)

<a id="function-function-minisql-platform-tls-schannel-acquireservercredentialwithpassword-function-acquireservercredentialwithpassword-certificatereference-passwordbytes-src-minisql-platform-tls-schannel-ml-217220514"></a>
### acquireServerCredentialWithPassword

```ml
function acquireServerCredentialWithPassword(certificateReference, passwordBytes)
```

Loads the configured identity and acquires the restricted TLS 1.3 server credential.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `certificateReference` | `dynamic` | — | certificateReference value consumed by this operation. |
| `passwordBytes` | `dynamic` | — | passwordBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L829)

<a id="function-function-minisql-platform-tls-schannel-appendbytes-function-appendbytes-left-right-src-minisql-platform-tls-schannel-ml-2146878631"></a>
### appendBytes

```ml
function appendBytes(left, right)
```

Concatenates two immutable byte sequences into fresh storage.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L585)

<a id="function-function-minisql-platform-tls-schannel-appendhandshaketranscript-function-appendhandshaketranscript-context-fragment-src-minisql-platform-tls-schannel-ml-2034274017"></a>
### appendHandshakeTranscript

```ml
function appendHandshakeTranscript(context, fragment)
```

Records directional handshake bytes until policy verification completes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `fragment` | `dynamic` | — | fragment value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1080)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-applycontroltoken-extern-function-applycontroltoken-contexthandle-as-bytes-inputdesc-as-bytes-from-secur32-dll-symbol-applycontroltoken-returns-i32-src-minisql-platform-tls-schannel-ml-412281635"></a>
### ApplyControlToken

```ml
extern function ApplyControlToken(contextHandle as bytes, inputDesc as bytes) from "secur32.dll" symbol "ApplyControlToken" returns i32
```

Applies the SCHANNEL_SHUTDOWN control token to an established context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `contextHandle` | `bytes` | — | contextHandle value consumed by this operation. |
| `inputDesc` | `bytes` | — | inputDesc value consumed by this operation. |


**Returns:** Native i32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L364)

<a id="constant-constant-minisql-platform-tls-schannel-asc-req-confidentiality-const-asc-req-confidentiality-16-src-minisql-platform-tls-schannel-ml-2038249262"></a>
### ASC_REQ_CONFIDENTIALITY

```ml
const ASC_REQ_CONFIDENTIALITY = 16
```

Defines the asc req confidentiality constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L61)

<a id="constant-constant-minisql-platform-tls-schannel-asc-req-extended-error-const-asc-req-extended-error-32768-src-minisql-platform-tls-schannel-ml-274972829"></a>
### ASC_REQ_EXTENDED_ERROR

```ml
const ASC_REQ_EXTENDED_ERROR = 32768
```

Defines the asc req extended error constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L63)

<a id="constant-constant-minisql-platform-tls-schannel-asc-req-replay-detect-const-asc-req-replay-detect-4-src-minisql-platform-tls-schannel-ml-1581880149"></a>
### ASC_REQ_REPLAY_DETECT

```ml
const ASC_REQ_REPLAY_DETECT = 4
```

Defines the asc req replay detect constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L57)

<a id="constant-constant-minisql-platform-tls-schannel-asc-req-sequence-detect-const-asc-req-sequence-detect-8-src-minisql-platform-tls-schannel-ml-1727457921"></a>
### ASC_REQ_SEQUENCE_DETECT

```ml
const ASC_REQ_SEQUENCE_DETECT = 8
```

Defines the asc req sequence detect constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L59)

<a id="constant-constant-minisql-platform-tls-schannel-asc-req-stream-const-asc-req-stream-65536-src-minisql-platform-tls-schannel-ml-1275783254"></a>
### ASC_REQ_STREAM

```ml
const ASC_REQ_STREAM = 65536
```

Defines the asc req stream constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L65)

<a id="constant-constant-minisql-platform-tls-schannel-authtype-server-const-authtype-server-2-src-minisql-platform-tls-schannel-ml-1234457991"></a>
### AUTHTYPE_SERVER

```ml
const AUTHTYPE_SERVER = 2
```

Defines the authtype server constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L163)

<a id="constant-constant-minisql-platform-tls-schannel-cert-chain-cache-end-cert-const-cert-chain-cache-end-cert-1-src-minisql-platform-tls-schannel-ml-189694720"></a>
### CERT_CHAIN_CACHE_END_CERT

```ml
const CERT_CHAIN_CACHE_END_CERT = 1
```

Defines the cert chain cache end cert constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L161)

<a id="constant-constant-minisql-platform-tls-schannel-cert-chain-para-bytes-const-cert-chain-para-bytes-96-src-minisql-platform-tls-schannel-ml-2021624030"></a>
### CERT_CHAIN_PARA_BYTES

```ml
const CERT_CHAIN_PARA_BYTES = 96
```

Defines the cert chain para bytes constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L167)

<a id="constant-constant-minisql-platform-tls-schannel-cert-chain-policy-para-bytes-const-cert-chain-policy-para-bytes-16-src-minisql-platform-tls-schannel-ml-1177848492"></a>
### CERT_CHAIN_POLICY_PARA_BYTES

```ml
const CERT_CHAIN_POLICY_PARA_BYTES = 16
```

Defines the cert chain policy para bytes constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L171)

<a id="constant-constant-minisql-platform-tls-schannel-cert-chain-policy-ssl-const-cert-chain-policy-ssl-4-src-minisql-platform-tls-schannel-ml-1917970341"></a>
### CERT_CHAIN_POLICY_SSL

```ml
const CERT_CHAIN_POLICY_SSL = 4
```

Defines the cert chain policy ssl constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L159)

<a id="constant-constant-minisql-platform-tls-schannel-cert-chain-policy-status-bytes-const-cert-chain-policy-status-bytes-24-src-minisql-platform-tls-schannel-ml-1711677839"></a>
### CERT_CHAIN_POLICY_STATUS_BYTES

```ml
const CERT_CHAIN_POLICY_STATUS_BYTES = 24
```

Defines the cert chain policy status bytes constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L173)

<a id="constant-constant-minisql-platform-tls-schannel-cert-close-store-force-flag-const-cert-close-store-force-flag-1-src-minisql-platform-tls-schannel-ml-3812168"></a>
### CERT_CLOSE_STORE_FORCE_FLAG

```ml
const CERT_CLOSE_STORE_FORCE_FLAG = 1
```

Defines the cert close store force flag constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L153)

<a id="constant-constant-minisql-platform-tls-schannel-cert-encoding-const-cert-encoding-65537-src-minisql-platform-tls-schannel-ml-1906473067"></a>
### CERT_ENCODING

```ml
const CERT_ENCODING = 65537
```

Defines the cert encoding constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L147)

<a id="constant-constant-minisql-platform-tls-schannel-cert-find-has-private-key-const-cert-find-has-private-key-1376256-src-minisql-platform-tls-schannel-ml-565596787"></a>
### CERT_FIND_HAS_PRIVATE_KEY

```ml
const CERT_FIND_HAS_PRIVATE_KEY = 1376256
```

Defines the cert find has private key constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L151)

<a id="constant-constant-minisql-platform-tls-schannel-cert-find-sha1-hash-const-cert-find-sha1-hash-65536-src-minisql-platform-tls-schannel-ml-1293487926"></a>
### CERT_FIND_SHA1_HASH

```ml
const CERT_FIND_SHA1_HASH = 65536
```

Defines the cert find sha1 hash constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L149)

<a id="constant-constant-minisql-platform-tls-schannel-cert-sha256-hash-prop-id-const-cert-sha256-hash-prop-id-107-src-minisql-platform-tls-schannel-ml-1511477427"></a>
### CERT_SHA256_HASH_PROP_ID

```ml
const CERT_SHA256_HASH_PROP_ID = 107
```

Defines the cert sha256 hash prop id constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L157)

<a id="constant-constant-minisql-platform-tls-schannel-cert-store-prov-system-w-const-cert-store-prov-system-w-10-src-minisql-platform-tls-schannel-ml-767056178"></a>
### CERT_STORE_PROV_SYSTEM_W

```ml
const CERT_STORE_PROV_SYSTEM_W = 10
```

Defines the cert store prov system w constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L137)

<a id="constant-constant-minisql-platform-tls-schannel-cert-system-store-current-user-const-cert-system-store-current-user-65536-src-minisql-platform-tls-schannel-ml-746770388"></a>
### CERT_SYSTEM_STORE_CURRENT_USER

```ml
const CERT_SYSTEM_STORE_CURRENT_USER = 65536
```

Defines the cert system store current user constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L139)

<a id="constant-constant-minisql-platform-tls-schannel-cert-system-store-local-machine-const-cert-system-store-local-machine-131072-src-minisql-platform-tls-schannel-ml-1234582743"></a>
### CERT_SYSTEM_STORE_LOCAL_MACHINE

```ml
const CERT_SYSTEM_STORE_LOCAL_MACHINE = 131072
```

Defines the cert system store local machine constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L141)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-certclosestore-extern-function-certclosestore-store-as-ptr-flags-as-u32-from-crypt32-dll-symbol-certclosestore-returns-bool-src-minisql-platform-tls-schannel-ml-747576702"></a>
### CertCloseStore

```ml
extern function CertCloseStore(store as ptr, flags as u32) from "crypt32.dll" symbol "CertCloseStore" returns bool
```

Closes a Windows certificate store.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `store` | `ptr` | — | store value consumed by this operation. |
| `flags` | `u32` | — | Bit flags controlling the operation. |


**Returns:** Native bool result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L403)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-certfindcertificateinstore-extern-function-certfindcertificateinstore-store-as-ptr-encodingtype-as-u32-findflags-as-u32-findtype-as-u32-findparameter-as-ptr-previouscontext-as-ptr-from-crypt32-dll-symbol-certfindcertificateinstore-returns-ptr-src-minisql-platform-tls-schannel-ml-1484773070"></a>
### CertFindCertificateInStore

```ml
extern function CertFindCertificateInStore(store as ptr, encodingType as u32, findFlags as u32, findType as u32, findParameter as ptr, previousContext as ptr) from "crypt32.dll" symbol "CertFindCertificateInStore" returns ptr
```

Searches a certificate store using a pointer-valued search parameter.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `store` | `ptr` | — | store value consumed by this operation. |
| `encodingType` | `u32` | — | encodingType value consumed by this operation. |
| `findFlags` | `u32` | — | findFlags value consumed by this operation. |
| `findType` | `u32` | — | findType value consumed by this operation. |
| `findParameter` | `ptr` | — | findParameter value consumed by this operation. |
| `previousContext` | `ptr` | — | previousContext value consumed by this operation. |


**Returns:** Native ptr result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L385)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-certfindcertificateinstorebytes-extern-function-certfindcertificateinstorebytes-store-as-ptr-encodingtype-as-u32-findflags-as-u32-findtype-as-u32-findparameter-as-bytes-previouscontext-as-ptr-from-crypt32-dll-symbol-certfindcertificateinstore-returns-ptr-src-minisql-platform-tls-schannel-ml-934856813"></a>
### CertFindCertificateInStoreBytes

```ml
extern function CertFindCertificateInStoreBytes(store as ptr, encodingType as u32, findFlags as u32, findType as u32, findParameter as bytes, previousContext as ptr) from "crypt32.dll" symbol "CertFindCertificateInStore" returns ptr
```

Searches a certificate store using a byte-encoded search parameter.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `store` | `ptr` | — | store value consumed by this operation. |
| `encodingType` | `u32` | — | encodingType value consumed by this operation. |
| `findFlags` | `u32` | — | findFlags value consumed by this operation. |
| `findType` | `u32` | — | findType value consumed by this operation. |
| `findParameter` | `bytes` | — | findParameter value consumed by this operation. |
| `previousContext` | `ptr` | — | previousContext value consumed by this operation. |


**Returns:** Native ptr result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L394)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-certfreecertificatechain-extern-function-certfreecertificatechain-chaincontext-as-ptr-from-crypt32-dll-symbol-certfreecertificatechain-returns-void-src-minisql-platform-tls-schannel-ml-1738904051"></a>
### CertFreeCertificateChain

```ml
extern function CertFreeCertificateChain(chainContext as ptr) from "crypt32.dll" symbol "CertFreeCertificateChain" returns void
```

Releases a certificate chain returned by CertGetCertificateChain.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chainContext` | `ptr` | — | chainContext value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L437)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-certfreecertificatecontext-extern-function-certfreecertificatecontext-context-as-ptr-from-crypt32-dll-symbol-certfreecertificatecontext-returns-bool-src-minisql-platform-tls-schannel-ml-120701258"></a>
### CertFreeCertificateContext

```ml
extern function CertFreeCertificateContext(context as ptr) from "crypt32.dll" symbol "CertFreeCertificateContext" returns bool
```

Releases one Windows certificate context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `ptr` | — | Context that carries state for the operation. |


**Returns:** Native bool result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L398)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-certgetcertificatechain-extern-function-certgetcertificatechain-chainengine-as-ptr-certificatecontext-as-ptr-currenttime-as-ptr-additionalstore-as-ptr-chainparameters-as-bytes-flags-as-u32-reserved-as-ptr-chaincontext-as-bytes-from-crypt32-dll-symbol-certgetcertificatechain-returns-bool-src-minisql-platform-tls-schannel-ml-1036708586"></a>
### CertGetCertificateChain

```ml
extern function CertGetCertificateChain(chainEngine as ptr, certificateContext as ptr, currentTime as ptr, additionalStore as ptr, chainParameters as bytes, flags as u32, reserved as ptr, chainContext as bytes) from "crypt32.dll" symbol "CertGetCertificateChain" returns bool
```

Builds and cryptographically verifies the peer certificate chain.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chainEngine` | `ptr` | — | chainEngine value consumed by this operation. |
| `certificateContext` | `ptr` | — | certificateContext value consumed by this operation. |
| `currentTime` | `ptr` | — | currentTime value consumed by this operation. |
| `additionalStore` | `ptr` | — | additionalStore value consumed by this operation. |
| `chainParameters` | `bytes` | — | chainParameters value consumed by this operation. |
| `flags` | `u32` | — | Bit flags controlling the operation. |
| `reserved` | `ptr` | — | reserved value consumed by this operation. |
| `chainContext` | `bytes` | — | chainContext value consumed by this operation. |


**Returns:** Native bool result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L427)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-certgetcertificatecontextproperty-extern-function-certgetcertificatecontextproperty-context-as-ptr-propertyid-as-u32-data-as-bytes-size-as-bytes-from-crypt32-dll-symbol-certgetcertificatecontextproperty-returns-bool-src-minisql-platform-tls-schannel-ml-1391439614"></a>
### CertGetCertificateContextProperty

```ml
extern function CertGetCertificateContextProperty(context as ptr, propertyId as u32, data as bytes, size as bytes) from "crypt32.dll" symbol "CertGetCertificateContextProperty" returns bool
```

Reads a property such as the SHA-256 digest from a certificate context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `ptr` | — | Context that carries state for the operation. |
| `propertyId` | `u32` | — | Identifier of property. |
| `data` | `bytes` | — | Input data consumed by the operation. |
| `size` | `bytes` | — | Size in the units required by the operation. |


**Returns:** Native bool result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L416)

<a id="function-function-minisql-platform-tls-schannel-certificatereferencekind-function-certificatereferencekind-certificatereference-src-minisql-platform-tls-schannel-ml-1613637714"></a>
### certificateReferenceKind

```ml
function certificateReferenceKind(certificateReference)
```

Returns the scheme portion of a server certificate reference.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `certificateReference` | `dynamic` | — | certificateReference value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L793)

<a id="function-function-minisql-platform-tls-schannel-certificatereferencevalue-function-certificatereferencevalue-certificatereference-src-minisql-platform-tls-schannel-ml-1890242676"></a>
### certificateReferenceValue

```ml
function certificateReferenceValue(certificateReference)
```

Returns the value portion of a server certificate reference.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `certificateReference` | `dynamic` | — | certificateReference value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L800)

<a id="function-function-minisql-platform-tls-schannel-certificatesha256-function-certificatesha256-certificatecontext-src-minisql-platform-tls-schannel-ml-981855244"></a>
### certificateSha256

```ml
function certificateSha256(certificateContext)
```

Reads the SHA-256 digest of a certificate's complete DER encoding.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `certificateContext` | `dynamic` | — | certificateContext value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L956)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-certopenstore-extern-function-certopenstore-storeprovider-as-ptr-encodingtype-as-u32-cryptprovider-as-ptr-flags-as-u32-parameter-as-wstr-from-crypt32-dll-symbol-certopenstore-returns-ptr-src-minisql-platform-tls-schannel-ml-48527432"></a>
### CertOpenStore

```ml
extern function CertOpenStore(storeProvider as ptr, encodingType as u32, cryptProvider as ptr, flags as u32, parameter as wstr) from "crypt32.dll" symbol "CertOpenStore" returns ptr
```

Opens a Windows certificate store by provider and location.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `storeProvider` | `ptr` | — | storeProvider value consumed by this operation. |
| `encodingType` | `u32` | — | encodingType value consumed by this operation. |
| `cryptProvider` | `ptr` | — | cryptProvider value consumed by this operation. |
| `flags` | `u32` | — | Bit flags controlling the operation. |
| `parameter` | `wstr` | — | parameter value consumed by this operation. |


**Returns:** Native ptr result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L376)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-certverifycertificatechainpolicy-extern-function-certverifycertificatechainpolicy-policyoid-as-ptr-chaincontext-as-ptr-policyparameters-as-bytes-policystatus-as-bytes-from-crypt32-dll-symbol-certverifycertificatechainpolicy-returns-bool-src-minisql-platform-tls-schannel-ml-888689620"></a>
### CertVerifyCertificateChainPolicy

```ml
extern function CertVerifyCertificateChainPolicy(policyOid as ptr, chainContext as ptr, policyParameters as bytes, policyStatus as bytes) from "crypt32.dll" symbol "CertVerifyCertificateChainPolicy" returns bool
```

Applies hostname, lifetime, EKU, and trust policy to a built certificate chain.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `policyOid` | `ptr` | — | Identifier of policy o. |
| `chainContext` | `ptr` | — | chainContext value consumed by this operation. |
| `policyParameters` | `bytes` | — | policyParameters value consumed by this operation. |
| `policyStatus` | `bytes` | — | policyStatus value consumed by this operation. |


**Returns:** Native bool result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L434)

<a id="function-function-minisql-platform-tls-schannel-closecontext-function-closecontext-context-src-minisql-platform-tls-schannel-ml-2119613575"></a>
### closeContext

```ml
function closeContext(context)
```

Releases a full TLS context and wipes retained record and certificate data.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1622)

<a id="function-function-minisql-platform-tls-schannel-closecredential-function-closecredential-credential-src-minisql-platform-tls-schannel-ml-237272821"></a>
### closeCredential

```ml
function closeCredential(credential)
```

Releases a credential and wipes or closes every retained native dependency.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `credential` | `dynamic` | — | credential value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L863)

<a id="function-function-minisql-platform-tls-schannel-componentname-function-componentname-src-minisql-platform-tls-schannel-ml-1639215810"></a>
### componentName

```ml
function componentName()
```

Returns the stable module-catalog component identifier.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1647)

<a id="function-function-minisql-platform-tls-schannel-connectclient-function-connectclient-sockethandle-servername-src-minisql-platform-tls-schannel-ml-812775935"></a>
### connectClient

```ml
function connectClient(socketHandle, serverName)
```

Connects with Windows root-store validation and mandatory hostname checking.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1211)

<a id="function-function-minisql-platform-tls-schannel-connectclientpinned-function-connectclientpinned-sockethandle-servername-pintext-src-minisql-platform-tls-schannel-ml-992632231"></a>
### connectClientPinned

```ml
function connectClientPinned(socketHandle, serverName, pinText)
```

Connects with exact SHA-256 leaf pinning, including self-signed certificates.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |
| `pinText` | `dynamic` | — | pinText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1221)

<a id="function-function-minisql-platform-tls-schannel-connectclientpolicy-function-connectclientpolicy-sockethandle-policy-src-minisql-platform-tls-schannel-ml-902041009"></a>
### connectClientPolicy

```ml
function connectClientPolicy(socketHandle, policy)
```

Completes a client handshake under an explicit, fail-closed TLS policy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |
| `policy` | `dynamic` | — | policy value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1159)

<a id="function-function-minisql-platform-tls-schannel-constanttimeequals-function-constanttimeequals-left-right-src-minisql-platform-tls-schannel-ml-1591556041"></a>
### constantTimeEquals

```ml
function constantTimeEquals(left, right)
```

Compares fixed-size security values without data-dependent early returns.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L913)

<a id="function-function-minisql-platform-tls-schannel-contextflagsclient-function-contextflagsclient-src-minisql-platform-tls-schannel-ml-1228820002"></a>
### contextFlagsClient

```ml
function contextFlagsClient()
```

Returns the client SSPI flags required for confidential ordered streams.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L901)

<a id="function-function-minisql-platform-tls-schannel-contextflagsserver-function-contextflagsserver-src-minisql-platform-tls-schannel-ml-1138730"></a>
### contextFlagsServer

```ml
function contextFlagsServer()
```

Returns the server SSPI flags required for confidential ordered streams.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L906)

<a id="function-function-minisql-platform-tls-schannel-copyrange-function-copyrange-source-offset-count-operation-src-minisql-platform-tls-schannel-ml-1278556928"></a>
### copyRange

```ml
function copyRange(source, offset, count, operation)
```

Copies a checked byte range without exposing pointer arithmetic to callers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `count` | `dynamic` | — | Number of items or units to process. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L576)

<a id="function-function-minisql-platform-tls-schannel-createsecbuffer-function-createsecbuffer-buffertype-payload-src-minisql-platform-tls-schannel-ml-1245751478"></a>
### createSecBuffer

```ml
function createSecBuffer(bufferType, payload)
```

Builds a single native SecBuffer over caller-owned bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bufferType` | `dynamic` | — | bufferType value consumed by this operation. |
| `payload` | `dynamic` | — | payload value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L495)

<a id="function-function-minisql-platform-tls-schannel-createsecbufferarray-function-createsecbufferarray-count-src-minisql-platform-tls-schannel-ml-1777012091"></a>
### createSecBufferArray

```ml
function createSecBufferArray(count)
```

Allocates a bounded contiguous array of native SecBuffer structures.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L554)

<a id="function-function-minisql-platform-tls-schannel-createsecbufferdesc-function-createsecbufferdesc-buffer-src-minisql-platform-tls-schannel-ml-569926268"></a>
### createSecBufferDesc

```ml
function createSecBufferDesc(buffer)
```

Builds a one-element SecBufferDesc for an SSPI call.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L506)

<a id="function-function-minisql-platform-tls-schannel-createsecbufferdescforarray-function-createsecbufferdescforarray-buffers-count-src-minisql-platform-tls-schannel-ml-1795558720"></a>
### createSecBufferDescForArray

```ml
function createSecBufferDescForArray(buffers, count)
```

Builds a SecBufferDesc that references a validated buffer array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffers` | `dynamic` | — | buffers value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L562)

<a id="constant-constant-minisql-platform-tls-schannel-cred-handle-size-const-cred-handle-size-16-src-minisql-platform-tls-schannel-ml-228525862"></a>
### CRED_HANDLE_SIZE

```ml
const CRED_HANDLE_SIZE = 16
```

Defines the cred handle size constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L87)

<a id="constant-constant-minisql-platform-tls-schannel-crypt-user-keyset-const-crypt-user-keyset-4096-src-minisql-platform-tls-schannel-ml-682426926"></a>
### CRYPT_USER_KEYSET

```ml
const CRYPT_USER_KEYSET = 4096
```

Defines the crypt user keyset constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L155)

<a id="function-function-minisql-platform-tls-schannel-cryptblob-function-cryptblob-data-src-minisql-platform-tls-schannel-ml-1677427840"></a>
### cryptBlob

```ml
function cryptBlob(data)
```

Builds the native CRYPT_DATA_BLOB view used for PKCS#12 import.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L660)

<a id="constant-constant-minisql-platform-tls-schannel-crypto-settings-bytes-const-crypto-settings-bytes-48-src-minisql-platform-tls-schannel-ml-993644595"></a>
### CRYPTO_SETTINGS_BYTES

```ml
const CRYPTO_SETTINGS_BYTES = 48
```

Defines the crypto settings bytes constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L104)

<a id="function-function-minisql-platform-tls-schannel-decryptbuffered-function-decryptbuffered-context-src-minisql-platform-tls-schannel-ml-1695071335"></a>
### decryptBuffered

```ml
function decryptBuffered(context)
```

Authenticates one already-buffered TLS record without reading the socket.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1427)

<a id="function-function-minisql-platform-tls-schannel-decrypteddata-function-decrypteddata-inputbytes-buffers-src-minisql-platform-tls-schannel-ml-313577530"></a>
### decryptedData

```ml
function decryptedData(inputBytes, buffers)
```

Copies every plaintext SECBUFFER_DATA segment produced by Schannel.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `inputBytes` | `dynamic` | — | inputBytes value consumed by this operation. |
| `buffers` | `dynamic` | — | buffers value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1324)

<a id="function-function-minisql-platform-tls-schannel-decryptextra-function-decryptextra-inputbytes-buffers-src-minisql-platform-tls-schannel-ml-1086638242"></a>
### decryptExtra

```ml
function decryptExtra(inputBytes, buffers)
```

Returns encrypted bytes that Schannel did not consume from the current record.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `inputBytes` | `dynamic` | — | inputBytes value consumed by this operation. |
| `buffers` | `dynamic` | — | buffers value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1304)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-decryptmessage-extern-function-decryptmessage-contexthandle-as-bytes-message-as-bytes-sequencenumber-as-u32-qualityofprotection-as-bytes-from-secur32-dll-symbol-decryptmessage-returns-i32-src-minisql-platform-tls-schannel-ml-1090434851"></a>
### DecryptMessage

```ml
extern function DecryptMessage(contextHandle as bytes, message as bytes, sequenceNumber as u32, qualityOfProtection as bytes) from "secur32.dll" symbol "DecryptMessage" returns i32
```

Authenticates and decrypts one TLS record with the negotiated AEAD keys.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `contextHandle` | `bytes` | — | contextHandle value consumed by this operation. |
| `message` | `bytes` | — | Human-readable message associated with the operation. |
| `sequenceNumber` | `u32` | — | sequenceNumber value consumed by this operation. |
| `qualityOfProtection` | `bytes` | — | qualityOfProtection value consumed by this operation. |


**Returns:** Native i32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L353)

<a id="function-function-minisql-platform-tls-schannel-decryptnext-function-decryptnext-context-sockethandle-src-minisql-platform-tls-schannel-ml-2041571336"></a>
### decryptNext

```ml
function decryptNext(context, socketHandle)
```

Receives and authenticates records until plaintext or a clean close is available.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1378)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-deletesecuritycontext-extern-function-deletesecuritycontext-contexthandle-as-bytes-from-secur32-dll-symbol-deletesecuritycontext-returns-i32-src-minisql-platform-tls-schannel-ml-2088786761"></a>
### DeleteSecurityContext

```ml
extern function DeleteSecurityContext(contextHandle as bytes) from "secur32.dll" symbol "DeleteSecurityContext" returns i32
```

Releases an SSPI security-context handle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `contextHandle` | `bytes` | — | contextHandle value consumed by this operation. |


**Returns:** Native i32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L368)

<a id="function-function-minisql-platform-tls-schannel-disablednistkeyexchangecrypto-function-disablednistkeyexchangecrypto-src-minisql-platform-tls-schannel-ml-484931352"></a>
### disabledNistKeyExchangeCrypto

```ml
function disabledNistKeyExchangeCrypto()
```

Builds Schannel blacklist entries for every NIST ECDHE group so X25519 is the only remaining enabled TLS 1.3 key-share family in the MiniSQL profile.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L937)

<a id="function-function-minisql-platform-tls-schannel-encryptchunk-function-encryptchunk-context-plain-src-minisql-platform-tls-schannel-ml-1423490839"></a>
### encryptChunk

```ml
function encryptChunk(context, plain)
```

Builds one Schannel stream record and applies negotiated AEAD protection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `plain` | `dynamic` | — | plain value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1536)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-encryptmessage-extern-function-encryptmessage-contexthandle-as-bytes-qualityofprotection-as-u32-message-as-bytes-sequencenumber-as-u32-from-secur32-dll-symbol-encryptmessage-returns-i32-src-minisql-platform-tls-schannel-ml-846215358"></a>
### EncryptMessage

```ml
extern function EncryptMessage(contextHandle as bytes, qualityOfProtection as u32, message as bytes, sequenceNumber as u32) from "secur32.dll" symbol "EncryptMessage" returns i32
```

Authenticates and encrypts one plaintext record with the negotiated AEAD keys.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `contextHandle` | `bytes` | — | contextHandle value consumed by this operation. |
| `qualityOfProtection` | `u32` | — | qualityOfProtection value consumed by this operation. |
| `message` | `bytes` | — | Human-readable message associated with the operation. |
| `sequenceNumber` | `u32` | — | sequenceNumber value consumed by this operation. |


**Returns:** Native i32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L346)

<a id="function-function-minisql-platform-tls-schannel-environmentsecret-function-environmentsecret-name-src-minisql-platform-tls-schannel-ml-1665837919"></a>
### environmentSecret

```ml
function environmentSecret(name)
```

Reads an environment secret into wipeable bytes instead of a long-lived string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L701)

<a id="function-function-minisql-platform-tls-schannel-fail-function-fail-operation-message-src-minisql-platform-tls-schannel-ml-1267476774"></a>
### fail

```ml
function fail(operation, message)
```

Creates a transport-scoped TLS error with consistent operation context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L451)

<a id="function-function-minisql-platform-tls-schannel-findcertificateinstore-function-findcertificateinstore-store-thumbprinthash-src-minisql-platform-tls-schannel-ml-1241221238"></a>
### findCertificateInStore

```ml
function findCertificateInStore(store, thumbprintHash)
```

Locates a certificate by its exact SHA-1 store thumbprint.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `store` | `dynamic` | — | store value consumed by this operation. |
| `thumbprintHash` | `dynamic` | — | thumbprintHash value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L737)

<a id="function-function-minisql-platform-tls-schannel-finishcontext-function-finishcontext-context-src-minisql-platform-tls-schannel-ml-931390447"></a>
### finishContext

```ml
function finishContext(context)
```

Finishes a context only after protocol, cipher, group, and certificate checks pass.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1089)

<a id="function-function-minisql-platform-tls-schannel-fragmentlimit-function-fragmentlimit-context-length-src-minisql-platform-tls-schannel-ml-713663217"></a>
### fragmentLimit

```ml
function fragmentLimit(context, length)
```

Selects a safe plaintext record size and supports deterministic fragmentation tests.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `length` | `dynamic` | — | length value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1517)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-freecredentialshandle-extern-function-freecredentialshandle-credentialhandle-as-bytes-from-secur32-dll-symbol-freecredentialshandle-returns-i32-src-minisql-platform-tls-schannel-ml-11388429"></a>
### FreeCredentialsHandle

```ml
extern function FreeCredentialsHandle(credentialHandle as bytes) from "secur32.dll" symbol "FreeCredentialsHandle" returns i32
```

Releases an SSPI credential handle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `credentialHandle` | `bytes` | — | credentialHandle value consumed by this operation. |


**Returns:** Native i32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L258)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-getenvironmentvariablea-extern-function-getenvironmentvariablea-name-as-cstr-buffer-as-bytes-size-as-u32-from-kernel32-dll-symbol-getenvironmentvariablea-returns-u32-src-minisql-platform-tls-schannel-ml-74015213"></a>
### GetEnvironmentVariableA

```ml
extern function GetEnvironmentVariableA(name as cstr, buffer as bytes, size as u32) from "kernel32.dll" symbol "GetEnvironmentVariableA" returns u32
```

Reads a process environment variable into caller-owned memory.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `cstr` | — | Name of the affected item. |
| `buffer` | `bytes` | — | Buffer that receives or supplies the operation data. |
| `size` | `u32` | — | Size in the units required by the operation. |


**Returns:** Native u32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L443)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-getlasterror-extern-function-getlasterror-from-kernel32-dll-symbol-getlasterror-returns-u32-src-minisql-platform-tls-schannel-ml-1124760838"></a>
### GetLastError

```ml
extern function GetLastError() from "kernel32.dll" symbol "GetLastError" returns u32
```

Returns the calling thread's latest Win32 error code.


**Returns:** Native u32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L446)

<a id="function-function-minisql-platform-tls-schannel-handshakeextra-function-handshakeextra-inputbytes-buffers-src-minisql-platform-tls-schannel-ml-29220442"></a>
### handshakeExtra

```ml
function handshakeExtra(inputBytes, buffers)
```

Preserves unconsumed bytes reported through SECBUFFER_EXTRA.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `inputBytes` | `dynamic` | — | inputBytes value consumed by this operation. |
| `buffers` | `dynamic` | — | buffers value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1139)

<a id="function-function-minisql-platform-tls-schannel-handshakeoutputtoken-function-handshakeoutputtoken-outputbuffer-tokenbytes-operation-src-minisql-platform-tls-schannel-ml-1119920264"></a>
### handshakeOutputToken

```ml
function handshakeOutputToken(outputBuffer, tokenBytes, operation)
```

Copies the exact SSPI output token from its bounded backing storage.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `outputBuffer` | `dynamic` | — | outputBuffer value consumed by this operation. |
| `tokenBytes` | `dynamic` | — | tokenBytes value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L892)

<a id="function-function-minisql-platform-tls-schannel-hexvalue-function-hexvalue-value-src-minisql-platform-tls-schannel-ml-1695189329"></a>
### hexValue

```ml
function hexValue(value)
```

Maps one ASCII hexadecimal digit to its numeric value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L622)

<a id="function-function-minisql-platform-tls-schannel-initialclienttoken-function-initialclienttoken-credential-servername-context-src-minisql-platform-tls-schannel-ml-1338895568"></a>
### initialClientToken

```ml
function initialClientToken(credential, serverName, context)
```

Creates the initial ClientHello and initializes a full TLS context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `credential` | `dynamic` | — | credential value consumed by this operation. |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1114)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-initializesecuritycontextw-extern-function-initializesecuritycontextw-credentialhandle-as-bytes-contexthandle-as-ptr-targetname-as-wstr-contextreq-as-u32-reserved1-as-u32-targetdatarep-as-u32-inputdesc-as-ptr-reserved2-as-u32-newcontext-as-bytes-outputdesc-as-bytes-contextattr-as-bytes-expiry-as-bytes-from-secur32-dll-symbol-initializesecuritycontextw-returns-i32-src-minisql-platform-tls-schannel-ml-1077422429"></a>
### InitializeSecurityContextW

```ml
extern function InitializeSecurityContextW(credentialHandle as bytes, contextHandle as ptr, targetName as wstr, contextReq as u32, reserved1 as u32, targetDataRep as u32, inputDesc as ptr, reserved2 as u32, newContext as bytes, outputDesc as bytes, contextAttr as bytes, expiry as bytes) from "secur32.dll" symbol "InitializeSecurityContextW" returns i32
```

Starts a client handshake without an existing context or inbound token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `credentialHandle` | `bytes` | — | credentialHandle value consumed by this operation. |
| `contextHandle` | `ptr` | — | contextHandle value consumed by this operation. |
| `targetName` | `wstr` | — | targetName value consumed by this operation. |
| `contextReq` | `u32` | — | contextReq value consumed by this operation. |
| `reserved1` | `u32` | — | reserved1 value consumed by this operation. |
| `targetDataRep` | `u32` | — | targetDataRep value consumed by this operation. |
| `inputDesc` | `ptr` | — | inputDesc value consumed by this operation. |
| `reserved2` | `u32` | — | reserved2 value consumed by this operation. |
| `newContext` | `bytes` | — | newContext value consumed by this operation. |
| `outputDesc` | `bytes` | — | outputDesc value consumed by this operation. |
| `contextAttr` | `bytes` | — | contextAttr value consumed by this operation. |
| `expiry` | `bytes` | — | expiry value consumed by this operation. |


**Returns:** Native i32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L273)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-initializesecuritycontextwcontinue-extern-function-initializesecuritycontextwcontinue-credentialhandle-as-bytes-contexthandle-as-bytes-targetname-as-wstr-contextreq-as-u32-reserved1-as-u32-targetdatarep-as-u32-inputdesc-as-bytes-reserved2-as-u32-newcontext-as-bytes-outputdesc-as-bytes-contextattr-as-bytes-expiry-as-bytes-from-secur32-dll-symbol-initializesecuritycontextw-returns-i32-src-minisql-platform-tls-schannel-ml-709780837"></a>
### InitializeSecurityContextWContinue

```ml
extern function InitializeSecurityContextWContinue(credentialHandle as bytes, contextHandle as bytes, targetName as wstr, contextReq as u32, reserved1 as u32, targetDataRep as u32, inputDesc as bytes, reserved2 as u32, newContext as bytes, outputDesc as bytes, contextAttr as bytes, expiry as bytes) from "secur32.dll" symbol "InitializeSecurityContextW" returns i32
```

Advances a client handshake using an existing context and peer input.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `credentialHandle` | `bytes` | — | credentialHandle value consumed by this operation. |
| `contextHandle` | `bytes` | — | contextHandle value consumed by this operation. |
| `targetName` | `wstr` | — | targetName value consumed by this operation. |
| `contextReq` | `u32` | — | contextReq value consumed by this operation. |
| `reserved1` | `u32` | — | reserved1 value consumed by this operation. |
| `targetDataRep` | `u32` | — | targetDataRep value consumed by this operation. |
| `inputDesc` | `bytes` | — | inputDesc value consumed by this operation. |
| `reserved2` | `u32` | — | reserved2 value consumed by this operation. |
| `newContext` | `bytes` | — | newContext value consumed by this operation. |
| `outputDesc` | `bytes` | — | outputDesc value consumed by this operation. |
| `contextAttr` | `bytes` | — | contextAttr value consumed by this operation. |
| `expiry` | `bytes` | — | expiry value consumed by this operation. |


**Returns:** Native i32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L288)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-initializesecuritycontextwshutdown-extern-function-initializesecuritycontextwshutdown-credentialhandle-as-bytes-contexthandle-as-bytes-targetname-as-wstr-contextreq-as-u32-reserved1-as-u32-targetdatarep-as-u32-inputdesc-as-ptr-reserved2-as-u32-newcontext-as-bytes-outputdesc-as-bytes-contextattr-as-bytes-expiry-as-bytes-from-secur32-dll-symbol-initializesecuritycontextw-returns-i32-src-minisql-platform-tls-schannel-ml-5597342"></a>
### InitializeSecurityContextWShutdown

```ml
extern function InitializeSecurityContextWShutdown(credentialHandle as bytes, contextHandle as bytes, targetName as wstr, contextReq as u32, reserved1 as u32, targetDataRep as u32, inputDesc as ptr, reserved2 as u32, newContext as bytes, outputDesc as bytes, contextAttr as bytes, expiry as bytes) from "secur32.dll" symbol "InitializeSecurityContextW" returns i32
```

Produces the client-side close_notify token after applying SCHANNEL_SHUTDOWN.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `credentialHandle` | `bytes` | — | credentialHandle value consumed by this operation. |
| `contextHandle` | `bytes` | — | contextHandle value consumed by this operation. |
| `targetName` | `wstr` | — | targetName value consumed by this operation. |
| `contextReq` | `u32` | — | contextReq value consumed by this operation. |
| `reserved1` | `u32` | — | reserved1 value consumed by this operation. |
| `targetDataRep` | `u32` | — | targetDataRep value consumed by this operation. |
| `inputDesc` | `ptr` | — | inputDesc value consumed by this operation. |
| `reserved2` | `u32` | — | reserved2 value consumed by this operation. |
| `newContext` | `bytes` | — | newContext value consumed by this operation. |
| `outputDesc` | `bytes` | — | outputDesc value consumed by this operation. |
| `contextAttr` | `bytes` | — | contextAttr value consumed by this operation. |
| `expiry` | `bytes` | — | expiry value consumed by this operation. |


**Returns:** Native i32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L303)

<a id="function-function-minisql-platform-tls-schannel-inputtokendesc-function-inputtokendesc-inputbytes-src-minisql-platform-tls-schannel-ml-329094865"></a>
### inputTokenDesc

```ml
function inputTokenDesc(inputBytes)
```

Wraps received handshake bytes in a two-buffer SSPI input descriptor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `inputBytes` | `dynamic` | — | inputBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1127)

<a id="constant-constant-minisql-platform-tls-schannel-invalid-argument-const-invalid-argument-9001-src-minisql-platform-tls-schannel-ml-981675853"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Native Schannel transport for MiniSQL. The module owns the SSPI handles,


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L16)

<a id="constant-constant-minisql-platform-tls-schannel-isc-req-confidentiality-const-isc-req-confidentiality-16-src-minisql-platform-tls-schannel-ml-1301422750"></a>
### ISC_REQ_CONFIDENTIALITY

```ml
const ISC_REQ_CONFIDENTIALITY = 16
```

Defines the isc req confidentiality constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L51)

<a id="constant-constant-minisql-platform-tls-schannel-isc-req-extended-error-const-isc-req-extended-error-16384-src-minisql-platform-tls-schannel-ml-1848234221"></a>
### ISC_REQ_EXTENDED_ERROR

```ml
const ISC_REQ_EXTENDED_ERROR = 16384
```

Defines the isc req extended error constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L53)

<a id="constant-constant-minisql-platform-tls-schannel-isc-req-replay-detect-const-isc-req-replay-detect-4-src-minisql-platform-tls-schannel-ml-1701783189"></a>
### ISC_REQ_REPLAY_DETECT

```ml
const ISC_REQ_REPLAY_DETECT = 4
```

Defines the isc req replay detect constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L49)

<a id="constant-constant-minisql-platform-tls-schannel-isc-req-sequence-detect-const-isc-req-sequence-detect-8-src-minisql-platform-tls-schannel-ml-537372353"></a>
### ISC_REQ_SEQUENCE_DETECT

```ml
const ISC_REQ_SEQUENCE_DETECT = 8
```

Defines the isc req sequence detect constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L47)

<a id="constant-constant-minisql-platform-tls-schannel-isc-req-stream-const-isc-req-stream-32768-src-minisql-platform-tls-schannel-ml-536118413"></a>
### ISC_REQ_STREAM

```ml
const ISC_REQ_STREAM = 32768
```

Defines the isc req stream constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L55)

<a id="function-function-minisql-platform-tls-schannel-iscredential-function-iscredential-value-src-minisql-platform-tls-schannel-ml-449756297"></a>
### isCredential

```ml
function isCredential(value)
```

Reports whether a value owns a Schannel credential handle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L464)

<a id="function-function-minisql-platform-tls-schannel-isimplemented-function-isimplemented-src-minisql-platform-tls-schannel-ml-2056998706"></a>
### isImplemented

```ml
function isImplemented()
```

Reports that the native TLS provider is implemented.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1657)

<a id="function-function-minisql-platform-tls-schannel-istlscontext-function-istlscontext-value-src-minisql-platform-tls-schannel-ml-1211528465"></a>
### isTlsContext

```ml
function isTlsContext(value)
```

Reports whether a value is an established native TLS context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L470)

<a id="function-function-minisql-platform-tls-schannel-loadpfxcertificate-function-loadpfxcertificate-path-passwordbytes-src-minisql-platform-tls-schannel-ml-733853157"></a>
### loadPfxCertificate

```ml
function loadPfxCertificate(path, passwordBytes)
```

Imports a bounded PKCS#12 identity and selects its private-key certificate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `passwordBytes` | `dynamic` | — | passwordBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L771)

<a id="function-function-minisql-platform-tls-schannel-loadstorecertificate-function-loadstorecertificate-thumbprint-src-minisql-platform-tls-schannel-ml-923180181"></a>
### loadStoreCertificate

```ml
function loadStoreCertificate(thumbprint)
```

Resolves a store certificate reference and verifies that a private key is available.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `thumbprint` | `dynamic` | — | thumbprint value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L746)

<a id="function-function-minisql-platform-tls-schannel-opensystemstore-function-opensystemstore-location-src-minisql-platform-tls-schannel-ml-681589913"></a>
### openSystemStore

```ml
function openSystemStore(location)
```

Opens the selected current-user or local-machine certificate store.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `location` | `dynamic` | — | location value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L728)

<a id="function-function-minisql-platform-tls-schannel-passwordtext-function-passwordtext-passwordbytes-src-minisql-platform-tls-schannel-ml-763896860"></a>
### passwordText

```ml
function passwordText(passwordBytes)
```

Decodes temporary password bytes for the Windows PKCS#12 API.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `passwordBytes` | `dynamic` | — | passwordBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L718)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-pfximportcertstore-extern-function-pfximportcertstore-pfxblob-as-bytes-password-as-wstr-flags-as-u32-from-crypt32-dll-symbol-pfximportcertstore-returns-ptr-src-minisql-platform-tls-schannel-ml-943667487"></a>
### PFXImportCertStore

```ml
extern function PFXImportCertStore(pfxBlob as bytes, password as wstr, flags as u32) from "crypt32.dll" symbol "PFXImportCertStore" returns ptr
```

Imports an encrypted PKCS#12 identity into a temporary certificate store.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pfxBlob` | `bytes` | — | pfxBlob value consumed by this operation. |
| `password` | `wstr` | — | password value consumed by this operation. |
| `flags` | `u32` | — | Bit flags controlling the operation. |


**Returns:** Native ptr result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L409)

<a id="function-function-minisql-platform-tls-schannel-pfxpasswordfromenvironment-function-pfxpasswordfromenvironment-src-minisql-platform-tls-schannel-ml-1154062866"></a>
### pfxPasswordFromEnvironment

```ml
function pfxPasswordFromEnvironment()
```

Loads the optional PKCS#12 password from the dedicated environment variable.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L712)

<a id="constant-constant-minisql-platform-tls-schannel-pkcs-7-asn-encoding-const-pkcs-7-asn-encoding-65536-src-minisql-platform-tls-schannel-ml-1793984282"></a>
### PKCS_7_ASN_ENCODING

```ml
const PKCS_7_ASN_ENCODING = 65536
```

Defines the pkcs 7 asn encoding constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L145)

<a id="function-function-minisql-platform-tls-schannel-popavailableplaintext-function-popavailableplaintext-context-maximum-src-minisql-platform-tls-schannel-ml-1432039087"></a>
### popAvailablePlaintext

```ml
function popAvailablePlaintext(context, maximum)
```

Removes up to a requested amount of queued plaintext.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `maximum` | `dynamic` | — | maximum value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1293)

<a id="function-function-minisql-platform-tls-schannel-popplaintext-function-popplaintext-context-count-src-minisql-platform-tls-schannel-ml-1662944760"></a>
### popPlaintext

```ml
function popPlaintext(context, count)
```

Removes an exact plaintext prefix from the connection queue.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1279)

<a id="function-function-minisql-platform-tls-schannel-processposthandshake-function-processposthandshake-context-sockethandle-inputbytes-buffers-src-minisql-platform-tls-schannel-ml-1002841596"></a>
### processPostHandshake

```ml
function processPostHandshake(context, socketHandle, inputBytes, buffers)
```

Lets Schannel process a TLS 1.3 post-handshake ticket or KeyUpdate message. Schannel reports these through SEC_I_RENEGOTIATE even though TLS 1.3 has no legacy renegotiation. A single SSPI continuation updates traffic keys and may emit an acknowledgement; any attempt to start a multi-flight renegotiation is rejected because MiniSQL does not request post-handshake client authentication.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |
| `inputBytes` | `dynamic` | — | inputBytes value consumed by this operation. |
| `buffers` | `dynamic` | — | buffers value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1348)

<a id="function-function-minisql-platform-tls-schannel-providername-function-providername-src-minisql-platform-tls-schannel-ml-2135133170"></a>
### providerName

```ml
function providerName()
```

Identifies the operating-system TLS provider used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1642)

<a id="extern_function-extern-function-minisql-platform-tls-schannel-querycontextattributesw-extern-function-querycontextattributesw-contexthandle-as-bytes-attribute-as-u32-buffer-as-bytes-from-secur32-dll-symbol-querycontextattributesw-returns-i32-src-minisql-platform-tls-schannel-ml-852909729"></a>
### QueryContextAttributesW

```ml
extern function QueryContextAttributesW(contextHandle as bytes, attribute as u32, buffer as bytes) from "secur32.dll" symbol "QueryContextAttributesW" returns i32
```

Reads an attribute from an established SSPI context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `contextHandle` | `bytes` | — | contextHandle value consumed by this operation. |
| `attribute` | `u32` | — | attribute value consumed by this operation. |
| `buffer` | `bytes` | — | Buffer that receives or supplies the operation data. |


**Returns:** Native i32 result produced by the call.

[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L359)

<a id="function-function-minisql-platform-tls-schannel-querystreamsizes-function-querystreamsizes-context-src-minisql-platform-tls-schannel-ml-1851377863"></a>
### queryStreamSizes

```ml
function queryStreamSizes(context)
```

Queries and validates Schannel TLS record framing limits.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1042)

<a id="function-function-minisql-platform-tls-schannel-readpointer-function-readpointer-source-offset-src-minisql-platform-tls-schannel-ml-1008755342"></a>
### readPointer

```ml
function readPointer(source, offset)
```

Reads a checked native 64-bit pointer from an ABI structure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L486)

<a id="function-function-minisql-platform-tls-schannel-receiveavailable-function-receiveavailable-context-sockethandle-maximum-src-minisql-platform-tls-schannel-ml-657157980"></a>
### receiveAvailable

```ml
function receiveAvailable(context, socketHandle, maximum)
```

Returns up to a bounded amount of authenticated plaintext.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |
| `maximum` | `dynamic` | — | maximum value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1458)

<a id="function-function-minisql-platform-tls-schannel-receiveexact-function-receiveexact-context-sockethandle-count-src-minisql-platform-tls-schannel-ml-1699918117"></a>
### receiveExact

```ml
function receiveExact(context, socketHandle, count)
```

Accumulates authenticated plaintext until the requested frame length is satisfied.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1493)

<a id="function-function-minisql-platform-tls-schannel-remotecertificatecontext-function-remotecertificatecontext-context-src-minisql-platform-tls-schannel-ml-1734964695"></a>
### remoteCertificateContext

```ml
function remoteCertificateContext(context)
```

Queries the peer leaf certificate context owned by the completed Schannel context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L968)

<a id="constant-constant-minisql-platform-tls-schannel-sch-cred-auto-cred-validation-const-sch-cred-auto-cred-validation-32-src-minisql-platform-tls-schannel-ml-1688535088"></a>
### SCH_CRED_AUTO_CRED_VALIDATION

```ml
const SCH_CRED_AUTO_CRED_VALIDATION = 32
```

Defines the sch cred auto cred validation constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L112)

<a id="constant-constant-minisql-platform-tls-schannel-sch-cred-manual-cred-validation-const-sch-cred-manual-cred-validation-8-src-minisql-platform-tls-schannel-ml-1225975257"></a>
### SCH_CRED_MANUAL_CRED_VALIDATION

```ml
const SCH_CRED_MANUAL_CRED_VALIDATION = 8
```

Defines the sch cred manual cred validation constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L108)

<a id="constant-constant-minisql-platform-tls-schannel-sch-cred-no-default-creds-const-sch-cred-no-default-creds-16-src-minisql-platform-tls-schannel-ml-1477087094"></a>
### SCH_CRED_NO_DEFAULT_CREDS

```ml
const SCH_CRED_NO_DEFAULT_CREDS = 16
```

Defines the sch cred no default creds constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L110)

<a id="constant-constant-minisql-platform-tls-schannel-sch-credentials-bytes-const-sch-credentials-bytes-72-src-minisql-platform-tls-schannel-ml-601107936"></a>
### SCH_CREDENTIALS_BYTES

```ml
const SCH_CREDENTIALS_BYTES = 72
```

Defines the sch credentials bytes constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L100)

<a id="constant-constant-minisql-platform-tls-schannel-sch-credentials-version-const-sch-credentials-version-5-src-minisql-platform-tls-schannel-ml-1977236624"></a>
### SCH_CREDENTIALS_VERSION

```ml
const SCH_CREDENTIALS_VERSION = 5
```

Defines the sch credentials version constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L98)

<a id="constant-constant-minisql-platform-tls-schannel-sch-use-strong-crypto-const-sch-use-strong-crypto-4194304-src-minisql-platform-tls-schannel-ml-847165904"></a>
### SCH_USE_STRONG_CRYPTO

```ml
const SCH_USE_STRONG_CRYPTO = 4194304
```

Defines the sch use strong crypto constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L114)

<a id="constant-constant-minisql-platform-tls-schannel-schannel-shutdown-const-schannel-shutdown-1-src-minisql-platform-tls-schannel-ml-1058586416"></a>
### SCHANNEL_SHUTDOWN

```ml
const SCHANNEL_SHUTDOWN = 1
```

Defines the schannel shutdown constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L132)

- [minisql.platform.tls_schannel.SchannelCredential](Type-minisql-platform-tls-schannel-schannelcredential-768685008.md) — struct
<a id="function-function-minisql-platform-tls-schannel-schannelcredentialbytes-function-schannelcredentialbytes-certificatecontext-inbound-manualvalidation-src-minisql-platform-tls-schannel-ml-507510378"></a>
### schannelCredentialBytes

```ml
function schannelCredentialBytes(certificateContext, inbound, manualValidation)
```

Materializes the crypto-agile SCH_CREDENTIALS ABI and restricts it to TLS 1.3.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `certificateContext` | `dynamic` | — | certificateContext value consumed by this operation. |
| `inbound` | `dynamic` | — | inbound value consumed by this operation. |
| `manualValidation` | `dynamic` | — | manualValidation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L672)

<a id="constant-constant-minisql-platform-tls-schannel-sec-buffer-desc-size-const-sec-buffer-desc-size-16-src-minisql-platform-tls-schannel-ml-1530098476"></a>
### SEC_BUFFER_DESC_SIZE

```ml
const SEC_BUFFER_DESC_SIZE = 16
```

Defines the sec buffer desc size constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L85)

<a id="constant-constant-minisql-platform-tls-schannel-sec-buffer-size-const-sec-buffer-size-16-src-minisql-platform-tls-schannel-ml-1906826302"></a>
### SEC_BUFFER_SIZE

```ml
const SEC_BUFFER_SIZE = 16
```

Defines the sec buffer size constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L83)

<a id="constant-constant-minisql-platform-tls-schannel-sec-e-cert-unknown-const-sec-e-cert-unknown-2146893017-src-minisql-platform-tls-schannel-ml-2100269913"></a>
### SEC_E_CERT_UNKNOWN

```ml
const SEC_E_CERT_UNKNOWN = -2146893017
```

Defines the sec e cert unknown constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L37)

<a id="constant-constant-minisql-platform-tls-schannel-sec-e-incomplete-message-const-sec-e-incomplete-message-2146893032-src-minisql-platform-tls-schannel-ml-2126861628"></a>
### SEC_E_INCOMPLETE_MESSAGE

```ml
const SEC_E_INCOMPLETE_MESSAGE = -2146893032
```

Defines the sec e incomplete message constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L31)

<a id="constant-constant-minisql-platform-tls-schannel-sec-e-invalid-token-const-sec-e-invalid-token-2146893048-src-minisql-platform-tls-schannel-ml-1899781289"></a>
### SEC_E_INVALID_TOKEN

```ml
const SEC_E_INVALID_TOKEN = -2146893048
```

Defines the sec e invalid token constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L29)

<a id="constant-constant-minisql-platform-tls-schannel-sec-e-ok-const-sec-e-ok-0-src-minisql-platform-tls-schannel-ml-1178848323"></a>
### SEC_E_OK

```ml
const SEC_E_OK = 0
```

Defines the sec e ok constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L21)

<a id="constant-constant-minisql-platform-tls-schannel-sec-e-untrusted-root-const-sec-e-untrusted-root-2146893019-src-minisql-platform-tls-schannel-ml-135906055"></a>
### SEC_E_UNTRUSTED_ROOT

```ml
const SEC_E_UNTRUSTED_ROOT = -2146893019
```

Defines the sec e untrusted root constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L35)

<a id="constant-constant-minisql-platform-tls-schannel-sec-e-wrong-principal-const-sec-e-wrong-principal-2146893022-src-minisql-platform-tls-schannel-ml-1550280701"></a>
### SEC_E_WRONG_PRINCIPAL

```ml
const SEC_E_WRONG_PRINCIPAL = -2146893022
```

Defines the sec e wrong principal constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L33)

<a id="constant-constant-minisql-platform-tls-schannel-sec-i-context-expired-const-sec-i-context-expired-590615-src-minisql-platform-tls-schannel-ml-1467446977"></a>
### SEC_I_CONTEXT_EXPIRED

```ml
const SEC_I_CONTEXT_EXPIRED = 590615
```

Defines the sec i context expired constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L25)

<a id="constant-constant-minisql-platform-tls-schannel-sec-i-continue-needed-const-sec-i-continue-needed-590610-src-minisql-platform-tls-schannel-ml-1685660204"></a>
### SEC_I_CONTINUE_NEEDED

```ml
const SEC_I_CONTINUE_NEEDED = 590610
```

Defines the sec i continue needed constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L23)

<a id="constant-constant-minisql-platform-tls-schannel-sec-i-renegotiate-const-sec-i-renegotiate-590625-src-minisql-platform-tls-schannel-ml-849103908"></a>
### SEC_I_RENEGOTIATE

```ml
const SEC_I_RENEGOTIATE = 590625
```

Defines the sec i renegotiate constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L27)

<a id="constant-constant-minisql-platform-tls-schannel-secbuffer-data-const-secbuffer-data-1-src-minisql-platform-tls-schannel-ml-1191381754"></a>
### SECBUFFER_DATA

```ml
const SECBUFFER_DATA = 1
```

Defines the secbuffer data constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L69)

<a id="constant-constant-minisql-platform-tls-schannel-secbuffer-empty-const-secbuffer-empty-0-src-minisql-platform-tls-schannel-ml-403223241"></a>
### SECBUFFER_EMPTY

```ml
const SECBUFFER_EMPTY = 0
```

Defines the secbuffer empty constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L67)

<a id="constant-constant-minisql-platform-tls-schannel-secbuffer-extra-const-secbuffer-extra-5-src-minisql-platform-tls-schannel-ml-1987290112"></a>
### SECBUFFER_EXTRA

```ml
const SECBUFFER_EXTRA = 5
```

Defines the secbuffer extra constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L75)

<a id="constant-constant-minisql-platform-tls-schannel-secbuffer-missing-const-secbuffer-missing-4-src-minisql-platform-tls-schannel-ml-1913047293"></a>
### SECBUFFER_MISSING

```ml
const SECBUFFER_MISSING = 4
```

Defines the secbuffer missing constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L73)

<a id="constant-constant-minisql-platform-tls-schannel-secbuffer-stream-header-const-secbuffer-stream-header-7-src-minisql-platform-tls-schannel-ml-1530570538"></a>
### SECBUFFER_STREAM_HEADER

```ml
const SECBUFFER_STREAM_HEADER = 7
```

Defines the secbuffer stream header constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L79)

<a id="constant-constant-minisql-platform-tls-schannel-secbuffer-stream-trailer-const-secbuffer-stream-trailer-6-src-minisql-platform-tls-schannel-ml-224024745"></a>
### SECBUFFER_STREAM_TRAILER

```ml
const SECBUFFER_STREAM_TRAILER = 6
```

Defines the secbuffer stream trailer constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L77)

<a id="constant-constant-minisql-platform-tls-schannel-secbuffer-token-const-secbuffer-token-2-src-minisql-platform-tls-schannel-ml-1001993963"></a>
### SECBUFFER_TOKEN

```ml
const SECBUFFER_TOKEN = 2
```

Defines the secbuffer token constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L71)

<a id="constant-constant-minisql-platform-tls-schannel-secbuffer-version-const-secbuffer-version-0-src-minisql-platform-tls-schannel-ml-1858361289"></a>
### SECBUFFER_VERSION

```ml
const SECBUFFER_VERSION = 0
```

Defines the secbuffer version constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L81)

<a id="function-function-minisql-platform-tls-schannel-secbufferlength-function-secbufferlength-target-index-src-minisql-platform-tls-schannel-ml-238397537"></a>
### secBufferLength

```ml
function secBufferLength(target, index)
```

Reads the byte count stored in a SecBuffer array element.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `dynamic` | — | target value consumed by this operation. |
| `index` | `dynamic` | — | Zero-based index of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L534)

<a id="function-function-minisql-platform-tls-schannel-secbufferpointer-function-secbufferpointer-target-index-src-minisql-platform-tls-schannel-ml-9427763"></a>
### secBufferPointer

```ml
function secBufferPointer(target, index)
```

Reads the native data pointer stored in a SecBuffer array element.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `dynamic` | — | target value consumed by this operation. |
| `index` | `dynamic` | — | Zero-based index of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L548)

<a id="function-function-minisql-platform-tls-schannel-secbuffertype-function-secbuffertype-target-index-src-minisql-platform-tls-schannel-ml-1553210693"></a>
### secBufferType

```ml
function secBufferType(target, index)
```

Reads the buffer type stored in a SecBuffer array element.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `dynamic` | — | target value consumed by this operation. |
| `index` | `dynamic` | — | Zero-based index of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L541)

<a id="constant-constant-minisql-platform-tls-schannel-secpkg-attr-cipher-info-const-secpkg-attr-cipher-info-100-src-minisql-platform-tls-schannel-ml-366764112"></a>
### SECPKG_ATTR_CIPHER_INFO

```ml
const SECPKG_ATTR_CIPHER_INFO = 100
```

Defines the secpkg attr cipher info constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L130)

<a id="constant-constant-minisql-platform-tls-schannel-secpkg-attr-connection-info-const-secpkg-attr-connection-info-90-src-minisql-platform-tls-schannel-ml-1754958728"></a>
### SECPKG_ATTR_CONNECTION_INFO

```ml
const SECPKG_ATTR_CONNECTION_INFO = 90
```

Defines the secpkg attr connection info constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L128)

<a id="constant-constant-minisql-platform-tls-schannel-secpkg-attr-remote-cert-context-const-secpkg-attr-remote-cert-context-83-src-minisql-platform-tls-schannel-ml-558713732"></a>
### SECPKG_ATTR_REMOTE_CERT_CONTEXT

```ml
const SECPKG_ATTR_REMOTE_CERT_CONTEXT = 83
```

Defines the secpkg attr remote cert context constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L126)

<a id="constant-constant-minisql-platform-tls-schannel-secpkg-attr-stream-sizes-const-secpkg-attr-stream-sizes-4-src-minisql-platform-tls-schannel-ml-653800085"></a>
### SECPKG_ATTR_STREAM_SIZES

```ml
const SECPKG_ATTR_STREAM_SIZES = 4
```

Defines the secpkg attr stream sizes constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L124)

<a id="constant-constant-minisql-platform-tls-schannel-secpkg-cipher-info-bytes-const-secpkg-cipher-info-bytes-680-src-minisql-platform-tls-schannel-ml-1471983021"></a>
### SECPKG_CIPHER_INFO_BYTES

```ml
const SECPKG_CIPHER_INFO_BYTES = 680
```

Defines the secpkg cipher info bytes constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L134)

<a id="constant-constant-minisql-platform-tls-schannel-secpkg-cred-inbound-const-secpkg-cred-inbound-1-src-minisql-platform-tls-schannel-ml-1309242952"></a>
### SECPKG_CRED_INBOUND

```ml
const SECPKG_CRED_INBOUND = 1
```

Defines the secpkg cred inbound constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L39)

<a id="constant-constant-minisql-platform-tls-schannel-secpkg-cred-outbound-const-secpkg-cred-outbound-2-src-minisql-platform-tls-schannel-ml-142246683"></a>
### SECPKG_CRED_OUTBOUND

```ml
const SECPKG_CRED_OUTBOUND = 2
```

Defines the secpkg cred outbound constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L41)

<a id="constant-constant-minisql-platform-tls-schannel-security-flag-ignore-unknown-ca-const-security-flag-ignore-unknown-ca-256-src-minisql-platform-tls-schannel-ml-1566566786"></a>
### SECURITY_FLAG_IGNORE_UNKNOWN_CA

```ml
const SECURITY_FLAG_IGNORE_UNKNOWN_CA = 256
```

Defines the security flag ignore unknown ca constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L165)

<a id="constant-constant-minisql-platform-tls-schannel-security-native-drep-const-security-native-drep-16-src-minisql-platform-tls-schannel-ml-359287236"></a>
### SECURITY_NATIVE_DREP

```ml
const SECURITY_NATIVE_DREP = 16
```

Defines the security native drep constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L45)

<a id="function-function-minisql-platform-tls-schannel-sendall-function-sendall-context-sockethandle-data-src-minisql-platform-tls-schannel-ml-1981254942"></a>
### sendAll

```ml
function sendAll(context, socketHandle, data)
```

Encrypts and writes all plaintext using bounded TLS records.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1568)

<a id="constant-constant-minisql-platform-tls-schannel-server-auth-oid-const-server-auth-oid-1-3-6-1-5-5-7-3-1-src-minisql-platform-tls-schannel-ml-1455009017"></a>
### SERVER_AUTH_OID

```ml
const SERVER_AUTH_OID = "1.3.6.1.5.5.7.3.1"
```

Defines the server auth oid constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L175)

<a id="function-function-minisql-platform-tls-schannel-shutdown-function-shutdown-context-sockethandle-src-minisql-platform-tls-schannel-ml-253928368"></a>
### shutdown

```ml
function shutdown(context, socketHandle)
```

Sends an authenticated TLS close_notify alert before the TCP socket is closed.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |
| `socketHandle` | `dynamic` | — | socketHandle value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1591)

<a id="constant-constant-minisql-platform-tls-schannel-sp-prot-legacy-client-const-sp-prot-legacy-client-2730-src-minisql-platform-tls-schannel-ml-653099279"></a>
### SP_PROT_LEGACY_CLIENT

```ml
const SP_PROT_LEGACY_CLIENT = 2730
```

Defines the sp prot legacy client constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L122)

<a id="constant-constant-minisql-platform-tls-schannel-sp-prot-legacy-server-const-sp-prot-legacy-server-1365-src-minisql-platform-tls-schannel-ml-1767724992"></a>
### SP_PROT_LEGACY_SERVER

```ml
const SP_PROT_LEGACY_SERVER = 1365
```

Defines the sp prot legacy server constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L120)

<a id="constant-constant-minisql-platform-tls-schannel-sp-prot-tls1-3-client-const-sp-prot-tls1-3-client-8192-src-minisql-platform-tls-schannel-ml-2032595723"></a>
### SP_PROT_TLS1_3_CLIENT

```ml
const SP_PROT_TLS1_3_CLIENT = 8192
```

Defines the sp prot tls1 3 client constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L118)

<a id="constant-constant-minisql-platform-tls-schannel-sp-prot-tls1-3-server-const-sp-prot-tls1-3-server-4096-src-minisql-platform-tls-schannel-ml-479122738"></a>
### SP_PROT_TLS1_3_SERVER

```ml
const SP_PROT_TLS1_3_SERVER = 4096
```

Defines the sp prot tls1 3 server constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L116)

<a id="constant-constant-minisql-platform-tls-schannel-ssl-policy-extra-bytes-const-ssl-policy-extra-bytes-24-src-minisql-platform-tls-schannel-ml-2028669071"></a>
### SSL_POLICY_EXTRA_BYTES

```ml
const SSL_POLICY_EXTRA_BYTES = 24
```

Defines the ssl policy extra bytes constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L169)

<a id="function-function-minisql-platform-tls-schannel-startswith-function-startswith-text-prefix-src-minisql-platform-tls-schannel-ml-604486121"></a>
### startsWith

```ml
function startsWith(text, prefix)
```

Compares a UTF-8 string prefix without locale-dependent conversions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |
| `prefix` | `dynamic` | — | prefix value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L596)

<a id="function-function-minisql-platform-tls-schannel-statusfailure-function-statusfailure-operation-status-src-minisql-platform-tls-schannel-ml-2075952791"></a>
### statusFailure

```ml
function statusFailure(operation, status)
```

Converts a native Schannel status code into a MiniSQL TLS error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `status` | `dynamic` | — | status value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L458)

<a id="function-function-minisql-platform-tls-schannel-substring-function-substring-text-offset-count-src-minisql-platform-tls-schannel-ml-1137035465"></a>
### substring

```ml
function substring(text, offset, count)
```

Extracts and validates a UTF-8 substring by byte offset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L611)

<a id="function-function-minisql-platform-tls-schannel-targetmilestone-function-targetmilestone-src-minisql-platform-tls-schannel-ml-776647836"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone that introduced the native TLS provider.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1652)

<a id="function-function-minisql-platform-tls-schannel-thumbprintbytes-function-thumbprintbytes-thumbprint-src-minisql-platform-tls-schannel-ml-822185517"></a>
### thumbprintBytes

```ml
function thumbprintBytes(thumbprint)
```

Normalizes a displayed SHA-1 certificate thumbprint into exactly 20 bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `thumbprint` | `dynamic` | — | thumbprint value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L631)

<a id="constant-constant-minisql-platform-tls-schannel-timestamp-size-const-timestamp-size-8-src-minisql-platform-tls-schannel-ml-1117919931"></a>
### TIMESTAMP_SIZE

```ml
const TIMESTAMP_SIZE = 8
```

Defines the timestamp size constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L89)

<a id="constant-constant-minisql-platform-tls-schannel-tls-error-const-tls-error-9034-src-minisql-platform-tls-schannel-ml-1564317781"></a>
### TLS_ERROR

```ml
const TLS_ERROR = 9034
```

Defines the tls error constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L18)

<a id="constant-constant-minisql-platform-tls-schannel-tls-key-exchange-usage-const-tls-key-exchange-usage-0-src-minisql-platform-tls-schannel-ml-65616001"></a>
### TLS_KEY_EXCHANGE_USAGE

```ml
const TLS_KEY_EXCHANGE_USAGE = 0
```

Defines the tls key exchange usage constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L106)

<a id="constant-constant-minisql-platform-tls-schannel-tls-max-pfx-bytes-const-tls-max-pfx-bytes-16777216-src-minisql-platform-tls-schannel-ml-152750486"></a>
### TLS_MAX_PFX_BYTES

```ml
const TLS_MAX_PFX_BYTES = 16777216
```

Defines the tls max pfx bytes constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L95)

<a id="constant-constant-minisql-platform-tls-schannel-tls-network-receive-bytes-const-tls-network-receive-bytes-65536-src-minisql-platform-tls-schannel-ml-536958070"></a>
### TLS_NETWORK_RECEIVE_BYTES

```ml
const TLS_NETWORK_RECEIVE_BYTES = 65536
```

Defines the tls network receive bytes constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L93)

<a id="constant-constant-minisql-platform-tls-schannel-tls-parameters-bytes-const-tls-parameters-bytes-40-src-minisql-platform-tls-schannel-ml-1921367881"></a>
### TLS_PARAMETERS_BYTES

```ml
const TLS_PARAMETERS_BYTES = 40
```

Defines the tls parameters bytes constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L102)

<a id="constant-constant-minisql-platform-tls-schannel-tls-token-bytes-const-tls-token-bytes-65536-src-minisql-platform-tls-schannel-ml-780243310"></a>
### TLS_TOKEN_BYTES

```ml
const TLS_TOKEN_BYTES = 65536
```

Defines the tls token bytes constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L91)

- [minisql.platform.tls_schannel.TlsContext](Type-minisql-platform-tls-schannel-tlscontext-2102611005.md) — struct
<a id="constant-constant-minisql-platform-tls-schannel-unisp-package-const-unisp-package-microsoft-unified-security-protocol-provider-src-minisql-platform-tls-schannel-ml-946949442"></a>
### UNISP_PACKAGE

```ml
const UNISP_PACKAGE = "Microsoft Unified Security Protocol Provider"
```

Defines the unisp package constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L43)

<a id="function-function-minisql-platform-tls-schannel-validatepinnedx509-function-validatepinnedx509-certificatecontext-servername-src-minisql-platform-tls-schannel-ml-1598140120"></a>
### validatePinnedX509

```ml
function validatePinnedX509(certificateContext, serverName)
```

Builds a Windows X.509 chain and checks time, EKU, signature, and DNS name. Pin mode ignores only the unknown-root result so an exact self-signed leaf can authenticate the server; every other SSL chain-policy failure remains fatal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `certificateContext` | `dynamic` | — | certificateContext value consumed by this operation. |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L983)

<a id="function-function-minisql-platform-tls-schannel-verifyciphersuite-function-verifyciphersuite-context-src-minisql-platform-tls-schannel-ml-1232154671"></a>
### verifyCipherSuite

```ml
function verifyCipherSuite(context)
```

Cross-checks Schannel's negotiated cipher-suite report against the wire policy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1068)

<a id="function-function-minisql-platform-tls-schannel-verifypeercertificate-function-verifypeercertificate-context-src-minisql-platform-tls-schannel-ml-1431291647"></a>
### verifyPeerCertificate

```ml
function verifyPeerCertificate(context)
```

Authenticates the peer leaf using either Schannel system trust or exact pinning.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1024)

<a id="function-function-minisql-platform-tls-schannel-verifytls13-function-verifytls13-context-src-minisql-platform-tls-schannel-ml-1403447211"></a>
### verifyTls13

```ml
function verifyTls13(context)
```

Cross-checks the negotiated protocol and exact AEAD cipher against policy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `dynamic` | — | Context that carries state for the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L1055)

<a id="function-function-minisql-platform-tls-schannel-wideservername-function-wideservername-servername-src-minisql-platform-tls-schannel-ml-776969738"></a>
### wideServerName

```ml
function wideServerName(serverName)
```

Encodes an ASCII DNS name as a null-terminated UTF-16LE buffer for CryptoAPI.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L924)

<a id="function-function-minisql-platform-tls-schannel-writepointer-function-writepointer-target-offset-pointervalue-src-minisql-platform-tls-schannel-ml-2142923894"></a>
### writePointer

```ml
function writePointer(target, offset, pointerValue)
```

Writes a native 64-bit pointer into an ABI structure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `dynamic` | — | target value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `pointerValue` | `dynamic` | — | pointerValue value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L478)

<a id="function-function-minisql-platform-tls-schannel-writesecbuffer-function-writesecbuffer-target-index-buffertype-pointervalue-length-src-minisql-platform-tls-schannel-ml-1749821979"></a>
### writeSecBuffer

```ml
function writeSecBuffer(target, index, bufferType, pointerValue, length)
```

Populates one element of a contiguous native SecBuffer array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `dynamic` | — | target value consumed by this operation. |
| `index` | `dynamic` | — | Zero-based index of the affected item. |
| `bufferType` | `dynamic` | — | bufferType value consumed by this operation. |
| `pointerValue` | `dynamic` | — | pointerValue value consumed by this operation. |
| `length` | `dynamic` | — | length value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L521)

<a id="constant-constant-minisql-platform-tls-schannel-x509-asn-encoding-const-x509-asn-encoding-1-src-minisql-platform-tls-schannel-ml-2131919448"></a>
### X509_ASN_ENCODING

```ml
const X509_ASN_ENCODING = 1
```

Defines the x509 asn encoding constant used by the minisql platform tls schannel module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L143)
