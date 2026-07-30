# 9. Security before DCL

Until users/roles/authentication exist, MiniSQL MUST:

- bind only to loopback
- reject remote bind configuration
- accept no user-supplied file paths through SQL
- map SQL objects to internal IDs
- validate frame lengths before allocation
- impose statement, nesting, result-batch, row and LOB limits
- avoid shell execution and dynamic MiniLang code execution
- redact sensitive values and internal paths from normal client errors
- use exclusive database ownership/lock rules
- fuzz lexer, parser and protocol decoders
- fail closed for unknown format/protocol versions and feature flags

DCL and TLS are not retrofitted assumptions: protocol/session boundaries are stubbed
from M0 so authentication can be added without rewriting the engine core.
