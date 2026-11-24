# Statistics format v1

> Historical statistics baseline. The current writer uses sidecar version 5;
> see the [development upgrade guide](../release/UPGRADE.md). Statistics
> versions are independent of [database storage v2](database-meta-v2.md), and
> this short v1 sketch is not a complete description of the current writer.

File: `catalog/statistics.tbl`. Protected-envelope magic `MSSTAT01`, version 1, kind 50. The payload stores database UUID, generation, table records and column records. Native-range lengths/counts are bounded before allocation. CRC failure, unknown reserved fields, wrong identity and trailing data are fatal.
