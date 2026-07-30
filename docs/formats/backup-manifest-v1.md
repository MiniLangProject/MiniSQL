# Backup manifest format v1

File: `backup.manifest`. Protected-envelope magic `MSBKP001`, version 1, kind 60. Payload header contains database UUID, page size, entry count and reserved zero bytes. Each entry contains a validated relative path, unsigned length and CRC-32C. Limits: 4,096 files, 64 MiB per file, 256 MiB total, 240 UTF-8 path bytes. Absolute paths, drive paths and parent traversal are rejected.
