# ADR-0008: Canonical varints and CRC-32C

Status: accepted for M2.

MiniSQL uses canonical unsigned LEB128 plus ZigZag for signed compact values and CRC-32C
for accidental-corruption detection. Full-width 64-bit values continue to use explicit
word pairs. Non-canonical forms are rejected so every integer has exactly one byte
representation. CRC-32C is fast enough for the initial implementation and has stable
external reference vectors; it is not used as a security MAC.
