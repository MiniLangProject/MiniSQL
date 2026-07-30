# ADR-0045: byte secrets and no-echo input

Decision: the secure client accepts passwords as mutable byte buffers obtained
from a Windows console read with echo disabled. String compatibility helpers
remain library-only for old tests, but user-facing commands prompt. Every
intermediate secret is explicitly overwritten.
