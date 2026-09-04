# `minisql.platform.tls_schannel.SchannelCredential`

[Home](README.md) · [Source file](File-src-minisql-platform-tls-schannel-ml-61867785.md)

<a id="struct-struct-minisql-platform-tls-schannel-schannelcredential-struct-schannelcredential-src-minisql-platform-tls-schannel-ml-1759740047"></a>
## SchannelCredential

```ml
struct SchannelCredential
```

Owns an acquired Schannel credential and every allocation whose lifetime it requires.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L178)

## Members

<a id="field-field-minisql-platform-tls-schannel-schannelcredential-certificatecontext-certificatecontext-src-minisql-platform-tls-schannel-ml-839070668"></a>
### certificateContext

```ml
certificateContext
```

Server leaf certificate context, or void for a client credential.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L188)

<a id="field-field-minisql-platform-tls-schannel-schannelcredential-certificatestore-certificatestore-src-minisql-platform-tls-schannel-ml-1735067620"></a>
### certificateStore

```ml
certificateStore
```

Certificate store kept open while the server credential is usable.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L190)

<a id="field-field-minisql-platform-tls-schannel-schannelcredential-closed-closed-src-minisql-platform-tls-schannel-ml-1078778028"></a>
### closed

```ml
closed
```

Prevents duplicate native-handle release.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L186)

<a id="field-field-minisql-platform-tls-schannel-schannelcredential-credentialbytes-credentialbytes-src-minisql-platform-tls-schannel-ml-1782258520"></a>
### credentialBytes

```ml
credentialBytes
```

SCH_CREDENTIALS structure retained for the native credential lifetime.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L192)

<a id="field-field-minisql-platform-tls-schannel-schannelcredential-disabledcrypto-disabledcrypto-src-minisql-platform-tls-schannel-ml-514766534"></a>
### disabledCrypto

```ml
disabledCrypto
```

CRYPTO_SETTINGS array that disables every key-exchange group except X25519.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L200)

<a id="field-field-minisql-platform-tls-schannel-schannelcredential-disabledcryptostrings-disabledcryptostrings-src-minisql-platform-tls-schannel-ml-1769730296"></a>
### disabledCryptoStrings

```ml
disabledCryptoStrings
```

Algorithm-name buffers referenced by the disabled crypto settings.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L202)

<a id="field-field-minisql-platform-tls-schannel-schannelcredential-expiry-expiry-src-minisql-platform-tls-schannel-ml-1758699258"></a>
### expiry

```ml
expiry
```

Credential expiry timestamp returned by SSPI.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L182)

<a id="field-field-minisql-platform-tls-schannel-schannelcredential-handle-handle-src-minisql-platform-tls-schannel-ml-1832030028"></a>
### handle

```ml
handle
```

SSPI CredHandle encoded in native-layout bytes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L180)

<a id="field-field-minisql-platform-tls-schannel-schannelcredential-inbound-inbound-src-minisql-platform-tls-schannel-ml-806563080"></a>
### inbound

```ml
inbound
```

Distinguishes a server credential from a client credential.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L184)

<a id="field-field-minisql-platform-tls-schannel-schannelcredential-manualvalidation-manualvalidation-src-minisql-platform-tls-schannel-ml-1439219238"></a>
### manualValidation

```ml
manualValidation
```

Selects explicit chain and pin validation for a client credential.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L204)

<a id="field-field-minisql-platform-tls-schannel-schannelcredential-pfxbytes-pfxbytes-src-minisql-platform-tls-schannel-ml-207598218"></a>
### pfxBytes

```ml
pfxBytes
```

Imported PFX payload retained and wiped when the credential closes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L196)

<a id="field-field-minisql-platform-tls-schannel-schannelcredential-pinnedcertificatepointers-pinnedcertificatepointers-src-minisql-platform-tls-schannel-ml-1384399656"></a>
### pinnedCertificatePointers

```ml
pinnedCertificatePointers
```

Native pointer array that pins the configured server certificate.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L194)

<a id="field-field-minisql-platform-tls-schannel-schannelcredential-tlsparameters-tlsparameters-src-minisql-platform-tls-schannel-ml-1048415260"></a>
### tlsParameters

```ml
tlsParameters
```

TLS_PARAMETERS structure that restricts negotiation to TLS 1.3.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/tls_schannel.ml#L198)
