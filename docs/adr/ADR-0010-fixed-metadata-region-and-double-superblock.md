# ADR-0010: Fixed metadata region and double superblock

Status: accepted for M4.

Every paged file reserves two 4096-byte metadata copies and begins data at offset 8192,
regardless of the selected page size. This avoids a bootstrap paradox: page size can be
read before page addressing is known. Alternating generations make metadata publication
recoverable after a torn or interrupted write. The latest valid generation wins; extra
tail data is uncommitted and removed.
