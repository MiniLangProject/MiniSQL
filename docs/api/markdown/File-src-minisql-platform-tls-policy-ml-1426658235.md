# `src/minisql/platform/tls_policy.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql platform tls policy facilities for this project.

Package: [`minisql.platform.tls_policy`](Package-minisql-platform-tls-policy-231492379.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)

## Declarations

<a id="function-function-minisql-platform-tls-policy-appendhandshakebytes-function-appendhandshakebytes-left-right-src-minisql-platform-tls-policy-ml-962026581"></a>
### appendHandshakeBytes

```ml
function appendHandshakeBytes(left, right)
```

Appends a bounded handshake fragment without exposing unbounded allocations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L241)

- [minisql.platform.tls_policy.CertificatePolicy](Type-minisql-platform-tls-policy-certificatepolicy-307377760.md) — struct
<a id="function-function-minisql-platform-tls-policy-cipherallowed-function-cipherallowed-policy-wireid-src-minisql-platform-tls-policy-ml-1568283782"></a>
### cipherAllowed

```ml
function cipherAllowed(policy, wireId)
```

Returns whether a cipher suite is explicitly allowed by the policy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `policy` | `dynamic` | — | policy value consumed by this operation. |
| `wireId` | `dynamic` | — | Identifier of wire. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L346)

<a id="function-function-minisql-platform-tls-policy-ciphersuitebyid-function-ciphersuitebyid-wireid-src-minisql-platform-tls-policy-ml-68173372"></a>
### cipherSuiteById

```ml
function cipherSuiteById(wireId)
```

Finds a registered cipher suite by its wire identifier.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `wireId` | `dynamic` | — | Identifier of wire. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L132)

<a id="function-function-minisql-platform-tls-policy-collecthandshakemessages-function-collecthandshakemessages-transcript-src-minisql-platform-tls-policy-ml-904750060"></a>
### collectHandshakeMessages

```ml
function collectHandshakeMessages(transcript)
```

Extracts plaintext handshake payloads from complete TLS records in one direction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transcript` | `dynamic` | — | transcript value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L303)

<a id="function-function-minisql-platform-tls-policy-componentname-function-componentname-src-minisql-platform-tls-policy-ml-2115096750"></a>
### componentName

```ml
function componentName()
```

Returns the stable module name used by diagnostics and documentation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L383)

<a id="function-function-minisql-platform-tls-policy-defaultclientpolicy-function-defaultclientpolicy-servername-src-minisql-platform-tls-policy-ml-269088350"></a>
### defaultClientPolicy

```ml
function defaultClientPolicy(serverName)
```

Creates the current default client policy using the Windows root store.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L218)

<a id="function-function-minisql-platform-tls-policy-defaultserverpolicy-function-defaultserverpolicy-src-minisql-platform-tls-policy-ml-66125718"></a>
### defaultServerPolicy

```ml
function defaultServerPolicy()
```

Creates the server-side algorithm policy; servers do not validate a peer certificate.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L234)

<a id="function-function-minisql-platform-tls-policy-fail-function-fail-operation-message-src-minisql-platform-tls-policy-ml-2090509478"></a>
### fail

```ml
function fail(operation, message)
```

Creates a structured TLS-policy failure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L106)

<a id="function-function-minisql-platform-tls-policy-groupallowed-function-groupallowed-policy-wireid-src-minisql-platform-tls-policy-ml-944474028"></a>
### groupAllowed

```ml
function groupAllowed(policy, wireId)
```

Returns whether a named group is explicitly allowed by the policy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `policy` | `dynamic` | — | policy value consumed by this operation. |
| `wireId` | `dynamic` | — | Identifier of wire. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L356)

<a id="function-function-minisql-platform-tls-policy-groupbyid-function-groupbyid-wireid-src-minisql-platform-tls-policy-ml-1009707552"></a>
### groupById

```ml
function groupById(wireId)
```

Finds a registered named group by its wire identifier.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `wireId` | `dynamic` | — | Identifier of wire. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L143)

<a id="function-function-minisql-platform-tls-policy-hexvalue-function-hexvalue-value-src-minisql-platform-tls-policy-ml-309886941"></a>
### hexValue

```ml
function hexValue(value)
```

Converts one ASCII hexadecimal digit to its numeric value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L154)

<a id="constant-constant-minisql-platform-tls-policy-invalid-argument-const-invalid-argument-9001-src-minisql-platform-tls-policy-ml-1201749365"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

This module is the fail-closed MiniSQL TLS profile. Schannel performs the


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L13)

<a id="function-function-minisql-platform-tls-policy-ishelloretryrequest-function-ishelloretryrequest-body-src-minisql-platform-tls-policy-ml-1565169796"></a>
### isHelloRetryRequest

```ml
function isHelloRetryRequest(body)
```

Returns true for the RFC 8446 HelloRetryRequest sentinel random value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `body` | `dynamic` | — | body value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L252)

<a id="function-function-minisql-platform-tls-policy-isimplemented-function-isimplemented-src-minisql-platform-tls-policy-ml-1668845638"></a>
### isImplemented

```ml
function isImplemented()
```

Reports that the native TLS policy implementation is available.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L393)

<a id="constant-constant-minisql-platform-tls-policy-key-share-extension-const-key-share-extension-51-src-minisql-platform-tls-policy-ml-2032381577"></a>
### KEY_SHARE_EXTENSION

```ml
const KEY_SHARE_EXTENSION = 51
```

Defines the key share extension constant used by the minisql platform tls policy module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L31)

<a id="constant-constant-minisql-platform-tls-policy-max-handshake-transcript-bytes-const-max-handshake-transcript-bytes-262144-src-minisql-platform-tls-policy-ml-501584060"></a>
### MAX_HANDSHAKE_TRANSCRIPT_BYTES

```ml
const MAX_HANDSHAKE_TRANSCRIPT_BYTES = 262144
```

Defines the max handshake transcript bytes constant used by the minisql platform tls policy module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L33)

<a id="function-function-minisql-platform-tls-policy-parseserverhellobody-function-parseserverhellobody-body-src-minisql-platform-tls-policy-ml-1201788246"></a>
### parseServerHelloBody

```ml
function parseServerHelloBody(body)
```

Parses one complete ServerHello body and returns only policy-relevant fields.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `body` | `dynamic` | — | body value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L263)

<a id="function-function-minisql-platform-tls-policy-parsesha256pin-function-parsesha256pin-text-src-minisql-platform-tls-policy-ml-515183321"></a>
### parseSha256Pin

```ml
function parseSha256Pin(text)
```

Parses an exact SHA-256 certificate pin, accepting an optional sha256 prefix.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L163)

<a id="function-function-minisql-platform-tls-policy-pinnedcertificatepolicy-function-pinnedcertificatepolicy-servername-pintext-src-minisql-platform-tls-policy-ml-354626578"></a>
### pinnedCertificatePolicy

```ml
function pinnedCertificatePolicy(serverName, pinText)
```

Builds exact leaf-certificate pinning for private or self-signed deployments.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |
| `pinText` | `dynamic` | — | pinText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L189)

<a id="function-function-minisql-platform-tls-policy-pinnedclientpolicy-function-pinnedclientpolicy-servername-pintext-src-minisql-platform-tls-policy-ml-568447664"></a>
### pinnedClientPolicy

```ml
function pinnedClientPolicy(serverName, pinText)
```

Creates the current client policy for exact SHA-256 certificate pinning.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |
| `pinText` | `dynamic` | — | pinText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L227)

<a id="constant-constant-minisql-platform-tls-policy-server-hello-message-const-server-hello-message-2-src-minisql-platform-tls-policy-ml-1548680213"></a>
### SERVER_HELLO_MESSAGE

```ml
const SERVER_HELLO_MESSAGE = 2
```

Defines the server hello message constant used by the minisql platform tls policy module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L27)

<a id="function-function-minisql-platform-tls-policy-serverhelloselection-function-serverhelloselection-transcript-src-minisql-platform-tls-policy-ml-1895599636"></a>
### serverHelloSelection

```ml
function serverHelloSelection(transcript)
```

Finds the final non-HelloRetryRequest ServerHello in a directional transcript.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transcript` | `dynamic` | — | transcript value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L324)

- [minisql.platform.tls_policy.ServerHelloSelection](Type-minisql-platform-tls-policy-serverhelloselection-91121722.md) — struct
<a id="constant-constant-minisql-platform-tls-policy-supported-versions-extension-const-supported-versions-extension-43-src-minisql-platform-tls-policy-ml-123873466"></a>
### SUPPORTED_VERSIONS_EXTENSION

```ml
const SUPPORTED_VERSIONS_EXTENSION = 43
```

Defines the supported versions extension constant used by the minisql platform tls policy module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L29)

<a id="function-function-minisql-platform-tls-policy-supportedciphersuites-function-supportedciphersuites-src-minisql-platform-tls-policy-ml-756521814"></a>
### supportedCipherSuites

```ml
function supportedCipherSuites()
```

Returns the complete compiled cipher registry; new versions extend this list.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L121)

<a id="function-function-minisql-platform-tls-policy-supportedgroups-function-supportedgroups-src-minisql-platform-tls-policy-ml-562626362"></a>
### supportedGroups

```ml
function supportedGroups()
```

Returns the complete compiled named-group registry; new versions extend this list.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L126)

<a id="function-function-minisql-platform-tls-policy-systemcertificatepolicy-function-systemcertificatepolicy-servername-src-minisql-platform-tls-policy-ml-1122491638"></a>
### systemCertificatePolicy

```ml
function systemCertificatePolicy(serverName)
```

Builds Windows trust-store validation with mandatory DNS-name verification.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `serverName` | `dynamic` | — | serverName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L181)

<a id="function-function-minisql-platform-tls-policy-targetmilestone-function-targetmilestone-src-minisql-platform-tls-policy-ml-1899501528"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the implementation milestone for native TLS 1.3.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L388)

<a id="constant-constant-minisql-platform-tls-policy-tls-1-2-legacy-version-const-tls-1-2-legacy-version-771-src-minisql-platform-tls-policy-ml-1952019474"></a>
### TLS_1_2_LEGACY_VERSION

```ml
const TLS_1_2_LEGACY_VERSION = 771
```

Defines the tls 1 2 legacy version constant used by the minisql platform tls policy module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L17)

<a id="constant-constant-minisql-platform-tls-policy-tls-1-3-version-const-tls-1-3-version-772-src-minisql-platform-tls-policy-ml-983625961"></a>
### TLS_1_3_VERSION

```ml
const TLS_1_3_VERSION = 772
```

Defines the tls 1 3 version constant used by the minisql platform tls policy module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L19)

<a id="constant-constant-minisql-platform-tls-policy-tls-aes-256-gcm-sha384-id-const-tls-aes-256-gcm-sha384-id-4866-src-minisql-platform-tls-policy-ml-58146971"></a>
### TLS_AES_256_GCM_SHA384_ID

```ml
const TLS_AES_256_GCM_SHA384_ID = 4866
```

Defines the tls aes 256 gcm sha384 id constant used by the minisql platform tls policy module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L21)

<a id="constant-constant-minisql-platform-tls-policy-tls-error-const-tls-error-9034-src-minisql-platform-tls-policy-ml-1099767985"></a>
### TLS_ERROR

```ml
const TLS_ERROR = 9034
```

Defines the tls error constant used by the minisql platform tls policy module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L15)

<a id="constant-constant-minisql-platform-tls-policy-tls-handshake-record-const-tls-handshake-record-22-src-minisql-platform-tls-policy-ml-2101176863"></a>
### TLS_HANDSHAKE_RECORD

```ml
const TLS_HANDSHAKE_RECORD = 22
```

Defines the tls handshake record constant used by the minisql platform tls policy module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L25)

<a id="function-function-minisql-platform-tls-policy-tlsaes256gcmsha384-function-tlsaes256gcmsha384-src-minisql-platform-tls-policy-ml-460685846"></a>
### tlsAes256GcmSha384

```ml
function tlsAes256GcmSha384()
```

Returns the only cipher suite enabled by the MiniSQL 1.0 TLS profile.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L111)

- [minisql.platform.tls_policy.TlsCipherSuite](Type-minisql-platform-tls-policy-tlsciphersuite-1550476789.md) — struct
- [minisql.platform.tls_policy.TlsNamedGroup](Type-minisql-platform-tls-policy-tlsnamedgroup-327531472.md) — struct
- [minisql.platform.tls_policy.TlsPolicy](Type-minisql-platform-tls-policy-tlspolicy-1409561862.md) — struct
<a id="function-function-minisql-platform-tls-policy-validate-function-validate-policy-src-minisql-platform-tls-policy-ml-614052436"></a>
### validate

```ml
function validate(policy)
```

Validates the complete policy without silently substituting algorithms.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `policy` | `dynamic` | — | policy value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L198)

<a id="function-function-minisql-platform-tls-policy-verifyserverhello-function-verifyserverhello-policy-transcript-src-minisql-platform-tls-policy-ml-834869930"></a>
### verifyServerHello

```ml
function verifyServerHello(policy, transcript)
```

Enforces the negotiated ServerHello against every fail-closed policy dimension.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `policy` | `dynamic` | — | policy value consumed by this operation. |
| `transcript` | `dynamic` | — | transcript value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L366)

<a id="function-function-minisql-platform-tls-policy-x25519-function-x25519-src-minisql-platform-tls-policy-ml-1408556718"></a>
### x25519

```ml
function x25519()
```

Returns the only key-exchange group enabled by the MiniSQL 1.0 TLS profile.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L116)

<a id="constant-constant-minisql-platform-tls-policy-x25519-id-const-x25519-id-29-src-minisql-platform-tls-policy-ml-424577532"></a>
### X25519_ID

```ml
const X25519_ID = 29
```

Defines the x25519 id constant used by the minisql platform tls policy module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_policy.ml#L23)
