# Slotted-page payload format v2

The common MiniSQL page header remains bytes 0..63. Each slot-directory entry
is eight bytes, starting at `64 + 8 * slotId`:

| Relative offset | Size | Field |
|---:|---:|---|
| 0 | 2 | U16 record offset relative to the page, divisible by 8 |
| 2 | 2 | U16 logical record length, excluding allocation padding |
| 4 | 2 | U16 slot state |
| 6 | 2 | U16 generation, 1..65535 |

All integer fields use little-endian byte order. Slot states retain their
defined values: 0 live, 1 deleted, 2 forwarding root, 3 internal forwarding,
and 4 moved. These are enumerated states, not combinable flags. Deleted slots
have zero offset and length. Their generation advances on deletion; generation
65535 is retired rather than wrapped.

## Aligned allocation

Each nondeleted record occupies `align8(logicalLength)` bytes. Its body begins
at an eight-byte-aligned offset. Any bytes between its logical end and the end
of this allocation must be zero. This permits arbitrary nonempty record bodies,
including forwarding records and catalog payloads, without changing what a
caller reads back from the slot. Row-format-v2 bodies already have aligned
lengths and therefore need no additional slot-level padding.

The slot directory grows upward while aligned record allocations grow downward
from the page end. `freeStart = 64 + 8 * slotCount`; `freeEnd` is eight-byte
aligned. The reusable contiguous free-space count is `freeEnd - freeStart`.
An insertion requires the aligned allocation plus eight directory bytes when
no deleted slot can be reused. Insert, update and compaction all use the same
allocation-size calculation.

Validation includes padding bytes in overlap and compactness checks: allocated
ranges must cover exactly `[freeEnd, pageSize)` without gaps or overlap, and all
padding must be zero. Nonaligned offsets, malformed lengths or nonzero padding
are rejected even when the common page checksums are otherwise valid.

Compaction can relocate bodies but preserves slot IDs and generations. All
mutations are built on a working page and validated before replacing the input,
so a failed insertion or update leaves the original bytes unchanged.

## Example

On an empty 4096-byte page, inserting a three-byte record allocates eight bytes
at offset 4088. Its slot records length 3, and bytes 4091..4095 are zero padding.
After a nine-byte record is inserted, that record owns sixteen bytes beginning
at 4072. The two slots occupy 16 bytes and the two allocations occupy 24 bytes;
the remaining free space is `4096 - 64 - 16 - 24 = 3992` bytes.

The page-header version is unchanged. Database/table format version 2 selects
this payload contract. Legacy databases are rejected; this patch provides no
legacy import or in-place conversion.
