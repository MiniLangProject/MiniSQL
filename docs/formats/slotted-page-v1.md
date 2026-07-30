# Slotted-page payload format v1

The common MiniSQL page header occupies bytes 0-63. Slots begin at byte 64 and are 8 bytes:

| Relative offset | Size | Field |
|---:|---:|---|
| 0 | 2 | record body offset |
| 2 | 2 | record body length |
| 4 | 2 | state flags |
| 6 | 2 | generation |

Record bodies grow down from the page end. Slot indices remain stable across compaction.
States include live, deleted, forwarding root, forwarding internal and moved. Deleted slots
may be reused only with their advanced generation; generation 65535 is retired rather than
wrapped.
