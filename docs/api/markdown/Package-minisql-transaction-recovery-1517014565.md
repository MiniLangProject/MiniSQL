# Package `minisql.transaction.recovery`

[Home](README.md) · [Packages](Packages.md)

## Files

- [src/minisql/transaction/recovery.ml](File-src-minisql-transaction-recovery-ml-1551350049.md)

## Symbols

- [`minisql.transaction.recovery.applyPage`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-applypage-function-applypage-record-destination-forceredo-src-minisql-transaction-recovery-ml-1140321084) — function
- [`minisql.transaction.recovery.buildStatuses`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-buildstatuses-function-buildstatuses-records-startlsn-src-minisql-transaction-recovery-ml-1495084111) — function
- [`minisql.transaction.recovery.componentName`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-componentname-function-componentname-src-minisql-transaction-recovery-ml-1452025212) — function
- [`minisql.transaction.recovery.CORRUPT_DATA`](File-src-minisql-transaction-recovery-ml-1551350049.md#constant-constant-minisql-transaction-recovery-corrupt-data-const-corrupt-data-9004-src-minisql-transaction-recovery-ml-891917980) — constant
- [`minisql.transaction.recovery.fail`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-fail-function-fail-code-operation-message-src-minisql-transaction-recovery-ml-1982310551) — function
- [`minisql.transaction.recovery.findStatus`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-findstatus-function-findstatus-statuses-transactionid-src-minisql-transaction-recovery-ml-442597899) — function
- [`minisql.transaction.recovery.findTarget`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-findtarget-function-findtarget-targets-fileid-src-minisql-transaction-recovery-ml-605586401) — function
- [`minisql.transaction.recovery.INVALID_ARGUMENT`](File-src-minisql-transaction-recovery-ml-1551350049.md#constant-constant-minisql-transaction-recovery-invalid-argument-const-invalid-argument-9001-src-minisql-transaction-recovery-ml-1271194969) — constant
- [`minisql.transaction.recovery.isCommitted`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-iscommitted-function-iscommitted-statuses-transactionid-src-minisql-transaction-recovery-ml-1900494759) — function
- [`minisql.transaction.recovery.isImplemented`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-isimplemented-function-isimplemented-src-minisql-transaction-recovery-ml-1303940012) — function
- [`minisql.transaction.recovery.recover`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-recover-function-recover-log-targets-startlsn-src-minisql-transaction-recovery-ml-334849867) — function
- [`minisql.transaction.recovery.recoverPath`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-recoverpath-function-recoverpath-path-segmentbytes-targets-startlsn-src-minisql-transaction-recovery-ml-1900136110) — function
- [`minisql.transaction.recovery.recoverScan`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-recoverscan-function-recoverscan-scanresult-targets-startlsn-src-minisql-transaction-recovery-ml-2043594785) — function
- [`minisql.transaction.recovery.recoverScanForced`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-recoverscanforced-function-recoverscanforced-scanresult-targets-src-minisql-transaction-recovery-ml-1135472736) — function
- [`minisql.transaction.recovery.recoverScanMode`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-recoverscanmode-function-recoverscanmode-scanresult-targets-startlsn-forceredo-src-minisql-transaction-recovery-ml-1688749078) — function
- [`minisql.transaction.recovery.RecoveryResult`](Type-minisql-transaction-recovery-recoveryresult-147029803.md) — struct
- [`minisql.transaction.recovery.RecoveryTarget`](Type-minisql-transaction-recovery-recoverytarget-1578539379.md) — struct
- [`minisql.transaction.recovery.retiredTarget`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-retiredtarget-function-retiredtarget-fileid-src-minisql-transaction-recovery-ml-1830130769) — function
- [`minisql.transaction.recovery.target`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-target-function-target-fileid-pagedfile-src-minisql-transaction-recovery-ml-1544692000) — function
- [`minisql.transaction.recovery.targetMilestone`](File-src-minisql-transaction-recovery-ml-1551350049.md#function-function-minisql-transaction-recovery-targetmilestone-function-targetmilestone-src-minisql-transaction-recovery-ml-969420042) — function
- [`minisql.transaction.recovery.TransactionStatus`](Type-minisql-transaction-recovery-transactionstatus-2076451289.md) — struct
