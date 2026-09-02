# `src/minisql/common/uuid.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.common.uuid`](Package-minisql-common-uuid-362882266.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `std/crypto.ml` as `crypto` → `../MiniLangCompilerML/std/crypto.ml` — external dependency
- `std/crypto/aes_gcm.ml` as `aes_gcm` → `../MiniLangCompilerML/std/crypto/aes_gcm.ml` — external dependency
- `std/uuid.ml` as `uuid_api` → `../MiniLangCompilerML/std/uuid.ml` — external dependency

## Declarations

- [minisql.common.uuid.AeadPacket](Type-minisql-common-uuid-aeadpacket-1150244255.md) — struct
<a id="constant-constant-minisql-common-uuid-aes-gcm-nonce-bytes-const-aes-gcm-nonce-bytes-12-src-minisql-common-uuid-ml-1824586300"></a>
### AES_GCM_NONCE_BYTES

```ml
const AES_GCM_NONCE_BYTES = 12
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L33)

<a id="constant-constant-minisql-common-uuid-aes-gcm-tag-bytes-const-aes-gcm-tag-bytes-16-src-minisql-common-uuid-ml-663786028"></a>
### AES_GCM_TAG_BYTES

```ml
const AES_GCM_TAG_BYTES = 16
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L34)

<a id="constant-constant-minisql-common-uuid-auth-nonce-bytes-const-auth-nonce-bytes-32-src-minisql-common-uuid-ml-531540344"></a>
### AUTH_NONCE_BYTES

```ml
const AUTH_NONCE_BYTES = 32
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L27)

<a id="constant-constant-minisql-common-uuid-auth-scheme-legacy-const-auth-scheme-legacy-1-src-minisql-common-uuid-ml-1540627870"></a>
### AUTH_SCHEME_LEGACY

```ml
const AUTH_SCHEME_LEGACY = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L25)

<a id="constant-constant-minisql-common-uuid-auth-scheme-scram-sha256-const-auth-scheme-scram-sha256-2-src-minisql-common-uuid-ml-976696171"></a>
### AUTH_SCHEME_SCRAM_SHA256

```ml
const AUTH_SCHEME_SCRAM_SHA256 = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L26)

<a id="constant-constant-minisql-common-uuid-authentication-failed-const-authentication-failed-9027-src-minisql-common-uuid-ml-424372815"></a>
### AUTHENTICATION_FAILED

```ml
const AUTHENTICATION_FAILED = 9027
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L17)

<a id="function-function-minisql-common-uuid-authenticationfailure-function-authenticationfailure-src-minisql-common-uuid-ml-708460816"></a>
### authenticationFailure

```ml
function authenticationFailure()
```

Performs the authentication failure operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L757)

<a id="function-function-minisql-common-uuid-authenticationscheme-function-authenticationscheme-credential-src-minisql-common-uuid-ml-1414162749"></a>
### authenticationScheme

```ml
function authenticationScheme(credential)
```

Returns the wire authentication scheme implied by persisted credential material. Length is the backwards-compatible discriminator in catalog v1.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `credential` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L335)

<a id="function-function-minisql-common-uuid-authmodeinfo-function-authmodeinfo-nonce-aad-tag-datalength-src-minisql-common-uuid-ml-1604481321"></a>
### authModeInfo

```ml
function authModeInfo(nonce, aad, tag, dataLength)
```

Performs the auth mode info operation for this module. Inputs: `nonce`, `aad`, `tag`, `dataLength`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `nonce` | `dynamic` | — |  |
| `aad` | `dynamic` | — |  |
| `tag` | `dynamic` | — |  |
| `dataLength` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L673)

<a id="function-function-minisql-common-uuid-authproof-function-authproof-verifier-nonce-username-label-src-minisql-common-uuid-ml-1073916209"></a>
### authProof

```ml
function authProof(verifier, nonce, username, label)
```

Performs the auth proof operation for this module. Inputs: `verifier`, `nonce`, `username`, `label`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `verifier` | `dynamic` | — |  |
| `nonce` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |
| `label` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L458)

<a id="constant-constant-minisql-common-uuid-bcrypt-alg-handle-hmac-flag-const-bcrypt-alg-handle-hmac-flag-8-src-minisql-common-uuid-ml-1040902093"></a>
### BCRYPT_ALG_HANDLE_HMAC_FLAG

```ml
const BCRYPT_ALG_HANDLE_HMAC_FLAG = 8
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L31)

<a id="constant-constant-minisql-common-uuid-bcrypt-auth-mode-info-bytes-const-bcrypt-auth-mode-info-bytes-88-src-minisql-common-uuid-ml-1519533489"></a>
### BCRYPT_AUTH_MODE_INFO_BYTES

```ml
const BCRYPT_AUTH_MODE_INFO_BYTES = 88
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L35)

<a id="constant-constant-minisql-common-uuid-bcrypt-use-system-preferred-rng-const-bcrypt-use-system-preferred-rng-2-src-minisql-common-uuid-ml-1008996683"></a>
### BCRYPT_USE_SYSTEM_PREFERRED_RNG

```ml
const BCRYPT_USE_SYSTEM_PREFERRED_RNG = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L32)

<a id="extern_function-extern-function-minisql-common-uuid-bcryptclosealgorithmprovider-extern-function-bcryptclosealgorithmprovider-algorithm-as-ptr-flags-as-u32-from-bcrypt-dll-symbol-bcryptclosealgorithmprovider-returns-i32-src-minisql-common-uuid-ml-380193502"></a>
### BCryptCloseAlgorithmProvider

```ml
extern function BCryptCloseAlgorithmProvider(algorithm as ptr, flags as u32) from "bcrypt.dll" symbol "BCryptCloseAlgorithmProvider" returns i32
```

Closes an algorithm-provider handle and returns its NTSTATUS result.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `algorithm` | `ptr` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L47)

<a id="extern_function-extern-function-minisql-common-uuid-bcryptcreatehash-extern-function-bcryptcreatehash-algorithm-as-ptr-hashout-as-bytes-hashobject-as-bytes-hashobjectlength-as-u32-secret-as-ptr-secretlength-as-u32-flags-as-u32-from-bcrypt-dll-symbol-bcryptcreatehash-returns-i32-src-minisql-common-uuid-ml-1313116512"></a>
### BCryptCreateHash

```ml
extern function BCryptCreateHash(algorithm as ptr, hashOut as bytes, hashObject as bytes, hashObjectLength as u32, secret as ptr, secretLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptCreateHash" returns i32
```

Allocates a keyed or unkeyed CNG hash object and writes its handle to `hashOut`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `algorithm` | `ptr` | — |  |
| `hashOut` | `bytes` | — |  |
| `hashObject` | `bytes` | — |  |
| `hashObjectLength` | `u32` | — |  |
| `secret` | `ptr` | — |  |
| `secretLength` | `u32` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L61)

<a id="extern_function-extern-function-minisql-common-uuid-bcryptdecrypt-extern-function-bcryptdecrypt-key-as-ptr-input-as-bytes-inputlength-as-u32-paddinginfo-as-bytes-iv-as-ptr-ivlength-as-u32-output-as-bytes-outputlength-as-u32-resultlength-as-bytes-flags-as-u32-from-bcrypt-dll-symbol-bcryptdecrypt-returns-i32-src-minisql-common-uuid-ml-757458927"></a>
### BCryptDecrypt

```ml
extern function BCryptDecrypt(key as ptr, input as bytes, inputLength as u32, paddingInfo as bytes, iv as ptr, ivLength as u32, output as bytes, outputLength as u32, resultLength as bytes, flags as u32) from "bcrypt.dll" symbol "BCryptDecrypt" returns i32
```

Authenticates and decrypts one buffer, returning NTSTATUS on tag mismatch or failure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `ptr` | — |  |
| `input` | `bytes` | — |  |
| `inputLength` | `u32` | — |  |
| `paddingInfo` | `bytes` | — |  |
| `iv` | `ptr` | — |  |
| `ivLength` | `u32` | — |  |
| `output` | `bytes` | — |  |
| `outputLength` | `u32` | — |  |
| `resultLength` | `bytes` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L59)

<a id="extern_function-extern-function-minisql-common-uuid-bcryptderivekeypbkdf2-extern-function-bcryptderivekeypbkdf2-algorithm-as-ptr-secret-as-bytes-secretlength-as-u32-salt-as-bytes-saltlength-as-u32-iterations-as-u64-output-as-bytes-outputlength-as-u32-flags-as-u32-from-bcrypt-dll-symbol-bcryptderivekeypbkdf2-returns-i32-src-minisql-common-uuid-ml-369480865"></a>
### BCryptDeriveKeyPBKDF2

```ml
extern function BCryptDeriveKeyPBKDF2(algorithm as ptr, secret as bytes, secretLength as u32, salt as bytes, saltLength as u32, iterations as u64, output as bytes, outputLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptDeriveKeyPBKDF2" returns i32
```

Derives `outputLength` PBKDF2 bytes from the supplied secret, salt, and iteration count.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `algorithm` | `ptr` | — |  |
| `secret` | `bytes` | — |  |
| `secretLength` | `u32` | — |  |
| `salt` | `bytes` | — |  |
| `saltLength` | `u32` | — |  |
| `iterations` | `u64` | — |  |
| `output` | `bytes` | — |  |
| `outputLength` | `u32` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L45)

<a id="extern_function-extern-function-minisql-common-uuid-bcryptdestroyhash-extern-function-bcryptdestroyhash-hash-as-ptr-from-bcrypt-dll-symbol-bcryptdestroyhash-returns-i32-src-minisql-common-uuid-ml-487174622"></a>
### BCryptDestroyHash

```ml
extern function BCryptDestroyHash(hash as ptr) from "bcrypt.dll" symbol "BCryptDestroyHash" returns i32
```

Destroys a CNG hash handle and returns its NTSTATUS result.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hash` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L67)

<a id="extern_function-extern-function-minisql-common-uuid-bcryptdestroykey-extern-function-bcryptdestroykey-key-as-ptr-from-bcrypt-dll-symbol-bcryptdestroykey-returns-i32-src-minisql-common-uuid-ml-1835198388"></a>
### BCryptDestroyKey

```ml
extern function BCryptDestroyKey(key as ptr) from "bcrypt.dll" symbol "BCryptDestroyKey" returns i32
```

Destroys a CNG symmetric-key handle and returns its NTSTATUS result.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L55)

<a id="extern_function-extern-function-minisql-common-uuid-bcryptencrypt-extern-function-bcryptencrypt-key-as-ptr-input-as-bytes-inputlength-as-u32-paddinginfo-as-bytes-iv-as-ptr-ivlength-as-u32-output-as-bytes-outputlength-as-u32-resultlength-as-bytes-flags-as-u32-from-bcrypt-dll-symbol-bcryptencrypt-returns-i32-src-minisql-common-uuid-ml-282512647"></a>
### BCryptEncrypt

```ml
extern function BCryptEncrypt(key as ptr, input as bytes, inputLength as u32, paddingInfo as bytes, iv as ptr, ivLength as u32, output as bytes, outputLength as u32, resultLength as bytes, flags as u32) from "bcrypt.dll" symbol "BCryptEncrypt" returns i32
```

Encrypts one buffer with the supplied key, AEAD metadata, and output bounds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `ptr` | — |  |
| `input` | `bytes` | — |  |
| `inputLength` | `u32` | — |  |
| `paddingInfo` | `bytes` | — |  |
| `iv` | `ptr` | — |  |
| `ivLength` | `u32` | — |  |
| `output` | `bytes` | — |  |
| `outputLength` | `u32` | — |  |
| `resultLength` | `bytes` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L57)

<a id="extern_function-extern-function-minisql-common-uuid-bcryptfinishhash-extern-function-bcryptfinishhash-hash-as-ptr-output-as-bytes-outputlength-as-u32-flags-as-u32-from-bcrypt-dll-symbol-bcryptfinishhash-returns-i32-src-minisql-common-uuid-ml-785077071"></a>
### BCryptFinishHash

```ml
extern function BCryptFinishHash(hash as ptr, output as bytes, outputLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptFinishHash" returns i32
```

Finalizes a CNG hash into the bounded output buffer and returns NTSTATUS.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hash` | `ptr` | — |  |
| `output` | `bytes` | — |  |
| `outputLength` | `u32` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L65)

<a id="extern_function-extern-function-minisql-common-uuid-bcryptgeneratesymmetrickey-extern-function-bcryptgeneratesymmetrickey-algorithm-as-ptr-keyout-as-bytes-keyobject-as-bytes-keyobjectlength-as-u32-secret-as-bytes-secretlength-as-u32-flags-as-u32-from-bcrypt-dll-symbol-bcryptgeneratesymmetrickey-returns-i32-src-minisql-common-uuid-ml-697467311"></a>
### BCryptGenerateSymmetricKey

```ml
extern function BCryptGenerateSymmetricKey(algorithm as ptr, keyOut as bytes, keyObject as bytes, keyObjectLength as u32, secret as bytes, secretLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptGenerateSymmetricKey" returns i32
```

Expands secret bytes into a CNG symmetric-key object and returns its handle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `algorithm` | `ptr` | — |  |
| `keyOut` | `bytes` | — |  |
| `keyObject` | `bytes` | — |  |
| `keyObjectLength` | `u32` | — |  |
| `secret` | `bytes` | — |  |
| `secretLength` | `u32` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L53)

<a id="extern_function-extern-function-minisql-common-uuid-bcryptgenrandom-extern-function-bcryptgenrandom-algorithm-as-ptr-buffer-as-bytes-count-as-u32-flags-as-u32-from-bcrypt-dll-symbol-bcryptgenrandom-returns-i32-src-minisql-common-uuid-ml-253216805"></a>
### BCryptGenRandom

```ml
extern function BCryptGenRandom(algorithm as ptr, buffer as bytes, count as u32, flags as u32) from "bcrypt.dll" symbol "BCryptGenRandom" returns i32
```

Fills `buffer` with cryptographically secure random bytes and returns NTSTATUS.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `algorithm` | `ptr` | — |  |
| `buffer` | `bytes` | — |  |
| `count` | `u32` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L41)

<a id="extern_function-extern-function-minisql-common-uuid-bcryptgetproperty-extern-function-bcryptgetproperty-object-as-ptr-propertyname-as-wstr-output-as-bytes-outputlength-as-u32-resultlength-as-bytes-flags-as-u32-from-bcrypt-dll-symbol-bcryptgetproperty-returns-i32-src-minisql-common-uuid-ml-862825824"></a>
### BCryptGetProperty

```ml
extern function BCryptGetProperty(object as ptr, propertyName as wstr, output as bytes, outputLength as u32, resultLength as bytes, flags as u32) from "bcrypt.dll" symbol "BCryptGetProperty" returns i32
```

Reads a named CNG property into `output` and reports the produced length.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `object` | `ptr` | — |  |
| `propertyName` | `wstr` | — |  |
| `output` | `bytes` | — |  |
| `outputLength` | `u32` | — |  |
| `resultLength` | `bytes` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L49)

<a id="extern_function-extern-function-minisql-common-uuid-bcrypthashdata-extern-function-bcrypthashdata-hash-as-ptr-input-as-bytes-inputlength-as-u32-flags-as-u32-from-bcrypt-dll-symbol-bcrypthashdata-returns-i32-src-minisql-common-uuid-ml-1964116126"></a>
### BCryptHashData

```ml
extern function BCryptHashData(hash as ptr, input as bytes, inputLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptHashData" returns i32
```

Incorporates `inputLength` bytes into the in-progress CNG hash.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hash` | `ptr` | — |  |
| `input` | `bytes` | — |  |
| `inputLength` | `u32` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L63)

<a id="extern_function-extern-function-minisql-common-uuid-bcryptopenalgorithmprovider-extern-function-bcryptopenalgorithmprovider-handleout-as-bytes-algorithmid-as-wstr-implementation-as-wstr-flags-as-u32-from-bcrypt-dll-symbol-bcryptopenalgorithmprovider-returns-i32-src-minisql-common-uuid-ml-695754952"></a>
### BCryptOpenAlgorithmProvider

```ml
extern function BCryptOpenAlgorithmProvider(handleOut as bytes, algorithmId as wstr, implementation as wstr, flags as u32) from "bcrypt.dll" symbol "BCryptOpenAlgorithmProvider" returns i32
```

Opens the requested CNG algorithm provider and writes its handle to `handleOut`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handleOut` | `bytes` | — |  |
| `algorithmId` | `wstr` | — |  |
| `implementation` | `wstr` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L43)

<a id="extern_function-extern-function-minisql-common-uuid-bcryptsetproperty-extern-function-bcryptsetproperty-object-as-ptr-propertyname-as-wstr-input-as-bytes-inputlength-as-u32-flags-as-u32-from-bcrypt-dll-symbol-bcryptsetproperty-returns-i32-src-minisql-common-uuid-ml-203120914"></a>
### BCryptSetProperty

```ml
extern function BCryptSetProperty(object as ptr, propertyName as wstr, input as bytes, inputLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptSetProperty" returns i32
```

Updates a named CNG property from the supplied byte representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `object` | `ptr` | — |  |
| `propertyName` | `wstr` | — |  |
| `input` | `bytes` | — |  |
| `inputLength` | `u32` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L51)

<a id="function-function-minisql-common-uuid-closeaesgcm-function-closeaesgcm-state-src-minisql-common-uuid-ml-69705125"></a>
### closeAesGcm

```ml
function closeAesGcm(state)
```

Closes the aes gcm. Inputs: `state`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L634)

<a id="extern_function-extern-function-minisql-common-uuid-cocreateguid-extern-function-cocreateguid-buffer-as-bytes-from-ole32-dll-symbol-cocreateguid-returns-i32-src-minisql-common-uuid-ml-524876179"></a>
### CoCreateGuid

```ml
extern function CoCreateGuid(buffer as bytes) from "ole32.dll" symbol "CoCreateGuid" returns i32
```

Writes a new RFC-compatible GUID to `buffer` and returns the HRESULT status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L39)

<a id="function-function-minisql-common-uuid-componentname-function-componentname-src-minisql-common-uuid-ml-1136681416"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L763)

<a id="function-function-minisql-common-uuid-constanttimeequals-function-constanttimeequals-left-right-src-minisql-common-uuid-ml-1441361977"></a>
### constantTimeEquals

```ml
function constantTimeEquals(left, right)
```

Performs the constant time equals operation for this module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L322)

<a id="function-function-minisql-common-uuid-create-function-create-src-minisql-common-uuid-ml-622113340"></a>
### create

```ml
function create()
```

Creates the requested value. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L96)

<a id="function-function-minisql-common-uuid-createpasswordmaterial-function-createpasswordmaterial-password-src-minisql-common-uuid-ml-1560751545"></a>
### createPasswordMaterial

```ml
function createPasswordMaterial(password)
```

Creates the password material. Inputs: `password`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `password` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L249)

<a id="function-function-minisql-common-uuid-createpasswordmaterialbytes-function-createpasswordmaterialbytes-passwordbytes-src-minisql-common-uuid-ml-1472981518"></a>
### createPasswordMaterialBytes

```ml
function createPasswordMaterialBytes(passwordBytes)
```

Creates the password material bytes. Inputs: `passwordBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `passwordBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L234)

<a id="constant-constant-minisql-common-uuid-default-pbkdf2-iterations-const-default-pbkdf2-iterations-600000-src-minisql-common-uuid-ml-1769710915"></a>
### DEFAULT_PBKDF2_ITERATIONS

```ml
const DEFAULT_PBKDF2_ITERATIONS = 600000
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L28)

<a id="function-function-minisql-common-uuid-derivekey-synchronized-function-derivekey-secret-salt-iterations-outputlength-src-minisql-common-uuid-ml-1938893919"></a>
### deriveKey

```ml
synchronized function deriveKey(secret, salt, iterations, outputLength)
```

Performs the PBKDF2 sequence under the same process-wide monitor as all other CNG calls, protecting compiler-managed native argument buffers. Inputs: `secret`, `salt`, `iterations`, `outputLength`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `secret` | `dynamic` | — |  |
| `salt` | `dynamic` | — |  |
| `iterations` | `dynamic` | — |  |
| `outputLength` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L179)

<a id="function-function-minisql-common-uuid-equals-function-equals-left-right-src-minisql-common-uuid-ml-1940324165"></a>
### equals

```ml
function equals(left, right)
```

Compares the s. Inputs: `left`, `right`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L120)

<a id="function-function-minisql-common-uuid-fail-function-fail-code-operation-message-src-minisql-common-uuid-ml-1285503545"></a>
### fail

```ml
function fail(code, operation, message)
```

Creates the module's structured error with operation context. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L90)

<a id="function-function-minisql-common-uuid-hmacsha256-synchronized-function-hmacsha256-key-input-src-minisql-common-uuid-ml-706360499"></a>
### hmacSha256

```ml
synchronized function hmacSha256(key, input)
```

Performs the HMAC provider lifecycle under the native-crypto monitor. Inputs: `key`, `input`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — |  |
| `input` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L504)

<a id="constant-constant-minisql-common-uuid-invalid-argument-const-invalid-argument-9001-src-minisql-common-uuid-ml-297786311"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Cryptographic utility layer for identifiers, password verification, message authentication, and authenticated encryption. Random material comes from the operating system; secret comparisons use constant-time native primitives.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L15)

<a id="constant-constant-minisql-common-uuid-io-failure-const-io-failure-9005-src-minisql-common-uuid-ml-340718919"></a>
### IO_FAILURE

```ml
const IO_FAILURE = 9005
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L16)

<a id="function-function-minisql-common-uuid-isaeadpacket-function-isaeadpacket-value-src-minisql-common-uuid-ml-476358729"></a>
### isAeadPacket

```ml
function isAeadPacket(value)
```

Evaluates whether the supplied input satisfies the aead packet predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L751)

<a id="function-function-minisql-common-uuid-isimplemented-function-isimplemented-src-minisql-common-uuid-ml-707123216"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L775)

<a id="constant-constant-minisql-common-uuid-max-pbkdf2-iterations-const-max-pbkdf2-iterations-5000000-src-minisql-common-uuid-ml-2023220400"></a>
### MAX_PBKDF2_ITERATIONS

```ml
const MAX_PBKDF2_ITERATIONS = 5000000
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L30)

<a id="constant-constant-minisql-common-uuid-min-pbkdf2-iterations-const-min-pbkdf2-iterations-10000-src-minisql-common-uuid-ml-1285971028"></a>
### MIN_PBKDF2_ITERATIONS

```ml
const MIN_PBKDF2_ITERATIONS = 10000
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L29)

<a id="function-function-minisql-common-uuid-nativehandle-function-nativehandle-handlebytes-operation-src-minisql-common-uuid-ml-1777666770"></a>
### nativeHandle

```ml
function nativeHandle(handleBytes, operation)
```

Performs the native handle operation for this module. Inputs: `handleBytes`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handleBytes` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L596)

<a id="function-function-minisql-common-uuid-openaesgcm-function-openaesgcm-keybytes-src-minisql-common-uuid-ml-1165519534"></a>
### openAesGcm

```ml
function openAesGcm(keyBytes)
```

Opens the aes gcm. Inputs: `keyBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keyBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L604)

<a id="function-function-minisql-common-uuid-opensha256hmac-function-opensha256hmac-src-minisql-common-uuid-ml-1248782724"></a>
### openSha256Hmac

```ml
function openSha256Hmac()
```

Opens the sha256 hmac. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L163)

<a id="function-function-minisql-common-uuid-parsehex-function-parsehex-text-src-minisql-common-uuid-ml-1061204819"></a>
### parseHex

```ml
function parseHex(text)
```

Parses the hex. Inputs: `text`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L138)

<a id="constant-constant-minisql-common-uuid-password-credential-bytes-const-password-credential-bytes-64-src-minisql-common-uuid-ml-2095181411"></a>
### PASSWORD_CREDENTIAL_BYTES

```ml
const PASSWORD_CREDENTIAL_BYTES = 64
```

New credentials keep a SCRAM-style StoredKey and ServerKey rather than a password-equivalent verifier. Legacy 32-byte verifiers remain readable so a database can be upgraded without invalidating every account at once.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L24)

<a id="constant-constant-minisql-common-uuid-password-salt-bytes-const-password-salt-bytes-16-src-minisql-common-uuid-ml-1198248304"></a>
### PASSWORD_SALT_BYTES

```ml
const PASSWORD_SALT_BYTES = 16
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L19)

<a id="constant-constant-minisql-common-uuid-password-verifier-bytes-const-password-verifier-bytes-32-src-minisql-common-uuid-ml-167314654"></a>
### PASSWORD_VERIFIER_BYTES

```ml
const PASSWORD_VERIFIER_BYTES = 32
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L20)

- [minisql.common.uuid.PasswordMaterial](Type-minisql-common-uuid-passwordmaterial-1953062680.md) — struct
<a id="function-function-minisql-common-uuid-randombytes-synchronized-function-randombytes-count-src-minisql-common-uuid-ml-1700952893"></a>
### randomBytes

```ml
synchronized function randomBytes(count)
```

Performs the random bytes operation under the common native-crypto monitor. Inputs: `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L147)

<a id="function-function-minisql-common-uuid-scramclientproof-function-scramclientproof-saltedpassword-nonce-username-src-minisql-common-uuid-ml-256654331"></a>
### scramClientProof

```ml
function scramClientProof(saltedPassword, nonce, username)
```

Creates the client proof from the password-derived salted secret. The proof does not disclose that secret to a server storing only StoredKey/ServerKey.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `saltedPassword` | `dynamic` | — |  |
| `nonce` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L369)

<a id="function-function-minisql-common-uuid-scramcredential-function-scramcredential-saltedpassword-src-minisql-common-uuid-ml-937153390"></a>
### scramCredential

```ml
function scramCredential(saltedPassword)
```

Derives the non-password-equivalent StoredKey || ServerKey representation used by the hardened authentication scheme.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `saltedPassword` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L344)

<a id="function-function-minisql-common-uuid-scramserverprooffromcredential-function-scramserverprooffromcredential-credential-nonce-username-src-minisql-common-uuid-ml-1742649256"></a>
### scramServerProofFromCredential

```ml
function scramServerProofFromCredential(credential, nonce, username)
```

Computes the server's transcript signature. A client derives the same ServerKey from its password and rejects a credential-phishing endpoint.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `credential` | `dynamic` | — |  |
| `nonce` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L416)

<a id="function-function-minisql-common-uuid-scramserverprooffrompassword-function-scramserverprooffrompassword-saltedpassword-nonce-username-src-minisql-common-uuid-ml-1541025011"></a>
### scramServerProofFromPassword

```ml
function scramServerProofFromPassword(saltedPassword, nonce, username)
```

Derives the reciprocal server proof from a client-owned salted password.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `saltedPassword` | `dynamic` | — |  |
| `nonce` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L428)

<a id="function-function-minisql-common-uuid-scramsessionsecretfromcredential-function-scramsessionsecretfromcredential-credential-nonce-username-src-minisql-common-uuid-ml-1105645176"></a>
### scramSessionSecretFromCredential

```ml
function scramSessionSecretFromCredential(credential, nonce, username)
```

Derives a shared session secret from both stored halves. Possession of this value alone is insufficient to generate a valid future client proof.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `credential` | `dynamic` | — |  |
| `nonce` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L438)

<a id="function-function-minisql-common-uuid-scramsessionsecretfrompassword-function-scramsessionsecretfrompassword-saltedpassword-nonce-username-src-minisql-common-uuid-ml-275649243"></a>
### scramSessionSecretFromPassword

```ml
function scramSessionSecretFromPassword(saltedPassword, nonce, username)
```

Derives the shared session secret from a client-owned salted password.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `saltedPassword` | `dynamic` | — |  |
| `nonce` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L448)

<a id="function-function-minisql-common-uuid-scramtranscript-function-scramtranscript-nonce-username-src-minisql-common-uuid-ml-1247213635"></a>
### scramTranscript

```ml
function scramTranscript(nonce, username)
```

Produces the single transcript shared by client proof, server proof and transport-key derivation. Domain separation prevents cross-protocol reuse.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `nonce` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L361)

<a id="function-function-minisql-common-uuid-sequencebytes-function-sequencebytes-sequence-src-minisql-common-uuid-ml-1765847813"></a>
### sequenceBytes

```ml
function sequenceBytes(sequence)
```

Performs the sequence bytes operation for this module. Inputs: `sequence`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sequence` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L572)

<a id="function-function-minisql-common-uuid-sha256-synchronized-function-sha256-input-src-minisql-common-uuid-ml-1582142376"></a>
### sha256

```ml
synchronized function sha256(input)
```

Performs the SHA-256 provider lifecycle under the native-crypto monitor. Inputs: `input`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L469)

<a id="function-function-minisql-common-uuid-targetmilestone-function-targetmilestone-src-minisql-common-uuid-ml-135178886"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L769)

<a id="function-function-minisql-common-uuid-tohex-function-tohex-value-src-minisql-common-uuid-ml-1261156297"></a>
### toHex

```ml
function toHex(value)
```

Converts the hex. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L131)

<a id="function-function-minisql-common-uuid-transportassociateddata-function-transportassociateddata-messagetype-flags-requestid-sequence-payloadlength-src-minisql-common-uuid-ml-1838685649"></a>
### transportAssociatedData

```ml
function transportAssociatedData(messageType, flags, requestId, sequence, payloadLength)
```

Performs the transport associated data operation for this module. Inputs: `messageType`, `flags`, `requestId`, `sequence`, `payloadLength`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `messageType` | `dynamic` | — |  |
| `flags` | `dynamic` | — |  |
| `requestId` | `dynamic` | — |  |
| `sequence` | `dynamic` | — |  |
| `payloadLength` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L660)

<a id="function-function-minisql-common-uuid-transportdecrypt-synchronized-function-transportdecrypt-key-sequence-messagetype-flags-requestid-ciphertext-tag-src-minisql-common-uuid-ml-798815898"></a>
### transportDecrypt

```ml
synchronized function transportDecrypt(key, sequence, messageType, flags, requestId, ciphertext, tag)
```

Authenticates and decrypts one transport frame under the synchronized native guard. Header fields form associated data; tag failure returns AuthenticationFailed.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — |  |
| `sequence` | `dynamic` | — |  |
| `messageType` | `dynamic` | — |  |
| `flags` | `dynamic` | — |  |
| `requestId` | `dynamic` | — |  |
| `ciphertext` | `dynamic` | — |  |
| `tag` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L720)

<a id="function-function-minisql-common-uuid-transportencrypt-synchronized-function-transportencrypt-key-sequence-messagetype-flags-requestid-plaintext-src-minisql-common-uuid-ml-543060365"></a>
### transportEncrypt

```ml
synchronized function transportEncrypt(key, sequence, messageType, flags, requestId, plaintext)
```

The CNG AEAD setup passes pointers into several managed temporary buffers. All synchronized functions share MiniLang's recursive process monitor, so AES, PBKDF2, SHA, HMAC, and RNG native sequences cannot overlap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — |  |
| `sequence` | `dynamic` | — |  |
| `messageType` | `dynamic` | — |  |
| `flags` | `dynamic` | — |  |
| `requestId` | `dynamic` | — |  |
| `plaintext` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L690)

<a id="function-function-minisql-common-uuid-transportkey-function-transportkey-verifier-nonce-username-label-src-minisql-common-uuid-ml-1453655573"></a>
### transportKey

```ml
function transportKey(verifier, nonce, username, label)
```

Performs the transport key operation for this module. Inputs: `verifier`, `nonce`, `username`, `label`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `verifier` | `dynamic` | — |  |
| `nonce` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |
| `label` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L540)

<a id="function-function-minisql-common-uuid-transportnonce-function-transportnonce-key-sequence-src-minisql-common-uuid-ml-1306717174"></a>
### transportNonce

```ml
function transportNonce(key, sequence)
```

Performs the transport nonce operation for this module. Inputs: `key`, `sequence`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — |  |
| `sequence` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L646)

<a id="function-function-minisql-common-uuid-transporttag-function-transporttag-key-messagetype-flags-requestid-sequence-authenticated-src-minisql-common-uuid-ml-246267829"></a>
### transportTag

```ml
function transportTag(key, messageType, flags, requestId, sequence, authenticated)
```

Compatibility keyed authenticator used by the M30 audit-chain format. The domain, frame fields and authenticated bytes are all included so tags from one purpose cannot be replayed in another purpose. Performs the transport tag operation for this module. Inputs: `key`, `messageType`, `flags`, `requestId`, `sequence`, `authenticated`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — |  |
| `messageType` | `dynamic` | — |  |
| `flags` | `dynamic` | — |  |
| `requestId` | `dynamic` | — |  |
| `sequence` | `dynamic` | — |  |
| `authenticated` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L553)

<a id="function-function-minisql-common-uuid-utf16ascii-function-utf16ascii-text-src-minisql-common-uuid-ml-1589900535"></a>
### utf16Ascii

```ml
function utf16Ascii(text)
```

Performs the utf16 ascii operation for this module. Inputs: `text`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L581)

<a id="function-function-minisql-common-uuid-validate-function-validate-value-src-minisql-common-uuid-ml-594413105"></a>
### validate

```ml
function validate(value)
```

Validates the requested value. Inputs: `value`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L111)

<a id="function-function-minisql-common-uuid-validatepassword-function-validatepassword-password-operation-src-minisql-common-uuid-ml-1723286562"></a>
### validatePassword

```ml
function validatePassword(password, operation)
```

Validates the password. Inputs: `password`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `password` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L227)

<a id="function-function-minisql-common-uuid-validatepasswordbytes-function-validatepasswordbytes-passwordbytes-operation-src-minisql-common-uuid-ml-1213368049"></a>
### validatePasswordBytes

```ml
function validatePasswordBytes(passwordBytes, operation)
```

Validates the password bytes. Inputs: `passwordBytes`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `passwordBytes` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L209)

<a id="function-function-minisql-common-uuid-verifypassword-function-verifypassword-password-salt-iterations-expected-src-minisql-common-uuid-ml-1735102989"></a>
### verifyPassword

```ml
function verifyPassword(password, salt, iterations, expected)
```

Verifies the password. Inputs: `password`, `salt`, `iterations`, `expected`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `password` | `dynamic` | — |  |
| `salt` | `dynamic` | — |  |
| `iterations` | `dynamic` | — |  |
| `expected` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L298)

<a id="function-function-minisql-common-uuid-verifypasswordbytes-function-verifypasswordbytes-passwordbytes-salt-iterations-expected-src-minisql-common-uuid-ml-1422455410"></a>
### verifyPasswordBytes

```ml
function verifyPasswordBytes(passwordBytes, salt, iterations, expected)
```

Verifies the password bytes. Inputs: `passwordBytes`, `salt`, `iterations`, `expected`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `passwordBytes` | `dynamic` | — |  |
| `salt` | `dynamic` | — |  |
| `iterations` | `dynamic` | — |  |
| `expected` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L274)

<a id="function-function-minisql-common-uuid-verifyscramclientproof-function-verifyscramclientproof-credential-nonce-username-proof-src-minisql-common-uuid-ml-830430578"></a>
### verifyScramClientProof

```ml
function verifyScramClientProof(credential, nonce, username, proof)
```

Verifies a hardened client proof without reconstructing or storing the password-equivalent salted secret.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `credential` | `dynamic` | — |  |
| `nonce` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |
| `proof` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L392)

<a id="function-function-minisql-common-uuid-wipepasswordmaterial-function-wipepasswordmaterial-material-src-minisql-common-uuid-ml-220067909"></a>
### wipePasswordMaterial

```ml
function wipePasswordMaterial(material)
```

Performs the wipe password material operation for this module. Inputs: `material`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `material` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L264)

<a id="function-function-minisql-common-uuid-wipesecret-function-wipesecret-secret-src-minisql-common-uuid-ml-1761080720"></a>
### wipeSecret

```ml
function wipeSecret(secret)
```

Performs the wipe secret operation for this module. Inputs: `secret`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `secret` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/uuid.ml#L201)
