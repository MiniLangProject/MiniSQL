# WAL archive v1

`archive.manifest` is a protected envelope with magic `MSARC001`, kind 80,
version 1. It records database ID, page size, generation, base-end LSN,
latest-end LSN, current WAL file name, length and CRC-32C. WAL generation files
are complete validated prefixes. `standby.state` is a protected envelope with
magic `MSSTB001`, kind 81, version 1 and records database ID, archive generation
and applied LSN.
