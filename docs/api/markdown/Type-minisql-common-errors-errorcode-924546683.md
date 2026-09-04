# `minisql.common.errors.ErrorCode`

[Home](README.md) · [Source file](File-src-minisql-common-errors-ml-2050242304.md)

<a id="enum-enum-minisql-common-errors-errorcode-enum-errorcode-src-minisql-common-errors-ml-862079105"></a>
## ErrorCode

```ml
enum ErrorCode
```

Defines the error code enumeration used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L12)

## Members

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-archivestate-archivestate-9031-src-minisql-common-errors-ml-1114679977"></a>
### ArchiveState

```ml
ArchiveState = 9031
```

Archive or replication state is inconsistent.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L78)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-authenticationfailed-authenticationfailed-9027-src-minisql-common-errors-ml-1899008248"></a>
### AuthenticationFailed

```ml
AuthenticationFailed = 9027
```

Authentication failed variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L70)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-authenticationrequired-authenticationrequired-9028-src-minisql-common-errors-ml-1797892883"></a>
### AuthenticationRequired

```ml
AuthenticationRequired = 9028
```

Authentication required variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L72)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-bindingerror-bindingerror-9020-src-minisql-common-errors-ml-1475147811"></a>
### BindingError

```ml
BindingError = 9020
```

Binding error variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L56)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-bufferpoolexhausted-bufferpoolexhausted-9009-src-minisql-common-errors-ml-1081767134"></a>
### BufferPoolExhausted

```ml
BufferPoolExhausted = 9009
```

Buffer pool exhausted variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L34)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-closedhandle-closedhandle-9008-src-minisql-common-errors-ml-1051251775"></a>
### ClosedHandle

```ml
ClosedHandle = 9008
```

Closed handle variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L32)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-constraintviolation-constraintviolation-9021-src-minisql-common-errors-ml-1615959532"></a>
### ConstraintViolation

```ml
ConstraintViolation = 9021
```

Constraint violation variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L58)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-corruptdata-corruptdata-9004-src-minisql-common-errors-ml-1969041531"></a>
### CorruptData

```ml
CorruptData = 9004
```

Corrupt data variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L24)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-ddlstate-ddlstate-9023-src-minisql-common-errors-ml-244032800"></a>
### DdlState

```ml
DdlState = 9023
```

Ddl state variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L62)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-duplicatekey-duplicatekey-9022-src-minisql-common-errors-ml-227921503"></a>
### DuplicateKey

```ml
DuplicateKey = 9022
```

Duplicate key variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L60)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-indexcorrupt-indexcorrupt-9024-src-minisql-common-errors-ml-15963363"></a>
### IndexCorrupt

```ml
IndexCorrupt = 9024
```

Index corrupt variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L64)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-invalidargument-invalidargument-9001-src-minisql-common-errors-ml-88386094"></a>
### InvalidArgument

```ml
InvalidArgument = 9001
```

Invalid argument variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L18)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-invalidconfiguration-invalidconfiguration-9002-src-minisql-common-errors-ml-1528462819"></a>
### InvalidConfiguration

```ml
InvalidConfiguration = 9002
```

Invalid configuration variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L20)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-iofailure-iofailure-9005-src-minisql-common-errors-ml-300566518"></a>
### IoFailure

```ml
IoFailure = 9005
```

Io failure variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L26)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-lockconflict-lockconflict-9007-src-minisql-common-errors-ml-527732162"></a>
### LockConflict

```ml
LockConflict = 9007
```

Lock conflict variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L30)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-locktimeout-locktimeout-9032-src-minisql-common-errors-ml-470092392"></a>
### LockTimeout

```ml
LockTimeout = 9032
```

A logical lock wait exceeded its configured deadline.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L80)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-networkfailure-networkfailure-9026-src-minisql-common-errors-ml-1232106167"></a>
### NetworkFailure

```ml
NetworkFailure = 9026
```

Network failure variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L68)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-notimplemented-notimplemented-9000-src-minisql-common-errors-ml-122690429"></a>
### NotImplemented

```ml
NotImplemented = 9000
```

Not implemented variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L16)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-objectexists-objectexists-9013-src-minisql-common-errors-ml-563272993"></a>
### ObjectExists

```ml
ObjectExists = 9013
```

Object exists variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L42)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-objectnotfound-objectnotfound-9014-src-minisql-common-errors-ml-2013375764"></a>
### ObjectNotFound

```ml
ObjectNotFound = 9014
```

Object not found variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L44)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-ok-ok-0-src-minisql-common-errors-ml-1137997482"></a>
### Ok

```ml
Ok = 0
```

Ok variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L14)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-pagefull-pagefull-9015-src-minisql-common-errors-ml-1523544297"></a>
### PageFull

```ml
PageFull = 9015
```

Page full variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L46)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-permissiondenied-permissiondenied-9029-src-minisql-common-errors-ml-1716100472"></a>
### PermissionDenied

```ml
PermissionDenied = 9029
```

Permission denied variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L74)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-pinnedpage-pinnedpage-9010-src-minisql-common-errors-ml-211855954"></a>
### PinnedPage

```ml
PinnedPage = 9010
```

Pinned page variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L36)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-protocolfailure-protocolfailure-9006-src-minisql-common-errors-ml-2042484233"></a>
### ProtocolFailure

```ml
ProtocolFailure = 9006
```

Protocol failure variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L28)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-querycancelled-querycancelled-9035-src-minisql-common-errors-ml-492289445"></a>
### QueryCancelled

```ml
QueryCancelled = 9035
```

An administrator cancelled the active statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L86)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-querytimeout-querytimeout-9036-src-minisql-common-errors-ml-1183624550"></a>
### QueryTimeout

```ml
QueryTimeout = 9036
```

The configured execution deadline expired.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L88)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-readonlyviolation-readonlyviolation-9012-src-minisql-common-errors-ml-625816830"></a>
### ReadOnlyViolation

```ml
ReadOnlyViolation = 9012
```

Read only violation variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L40)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-resourcelimit-resourcelimit-9037-src-minisql-common-errors-ml-530485661"></a>
### ResourceLimit

```ml
ResourceLimit = 9037
```

A configured process, result, or temporary-storage budget was exhausted.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L90)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-rownotfound-rownotfound-9016-src-minisql-common-errors-ml-1143695802"></a>
### RowNotFound

```ml
RowNotFound = 9016
```

Row not found variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L48)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-securitystate-securitystate-9030-src-minisql-common-errors-ml-475174078"></a>
### SecurityState

```ml
SecurityState = 9030
```

Security state variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L76)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-sqlsyntax-sqlsyntax-9019-src-minisql-common-errors-ml-546829449"></a>
### SqlSyntax

```ml
SqlSyntax = 9019
```

Sql syntax variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L54)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-stalereference-stalereference-9018-src-minisql-common-errors-ml-1066393168"></a>
### StaleReference

```ml
StaleReference = 9018
```

Stale reference variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L52)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-standbystate-standbystate-9033-src-minisql-common-errors-ml-1094502277"></a>
### StandbyState

```ml
StandbyState = 9033
```

A standby cannot execute the requested writable operation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L82)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-tlsfailure-tlsfailure-9034-src-minisql-common-errors-ml-1220213212"></a>
### TlsFailure

```ml
TlsFailure = 9034
```

Native TLS setup or transport failed.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L84)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-transactionstate-transactionstate-9011-src-minisql-common-errors-ml-725876339"></a>
### TransactionState

```ml
TransactionState = 9011
```

Transaction state variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L38)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-typemismatch-typemismatch-9017-src-minisql-common-errors-ml-516801631"></a>
### TypeMismatch

```ml
TypeMismatch = 9017
```

Type mismatch variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L50)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-unsupportedformat-unsupportedformat-9003-src-minisql-common-errors-ml-1947631860"></a>
### UnsupportedFormat

```ml
UnsupportedFormat = 9003
```

Unsupported format variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L22)

<a id="enum_variant-enum-variant-minisql-common-errors-errorcode-unsupportedsql-unsupportedsql-9025-src-minisql-common-errors-ml-935619350"></a>
### UnsupportedSql

```ml
UnsupportedSql = 9025
```

Unsupported sql variant of the error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/errors.ml#L66)
