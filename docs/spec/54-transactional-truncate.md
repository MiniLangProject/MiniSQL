# Transactional TRUNCATE

M42 accepts:

```sql
TRUNCATE [TABLE] name [RESTART IDENTITY]
```

TRUNCATE MUST participate in normal transaction, WAL, recovery, lock,
authorization and foreign-key rules. M42 implements it as staged logical row
deletion, not as an immediate physical file swap. RESTART IDENTITY follows the
current visible-max identity model. `CONTINUE IDENTITY` MUST fail closed until
persistent sequence objects are introduced.
