# Runnable teaching examples

Run these against a **new, disposable teaching database** using matching
MiniSQL executables from the manual's pinned source revision. Start the server,
then run the scripts in order with the native console:

```sh
./build/bin-linux/minisql --script 7432 docs/manual/examples/01-create-shop.sql
./build/bin-linux/minisql --script 7432 docs/manual/examples/02-query-shop.sql
./build/bin-linux/minisql --script 7432 docs/manual/examples/03-transactions.sql
./build/bin-linux/minisql --script 7432 docs/manual/examples/04-query-workshop.sql
```

On Windows use `build\bin\minisql.exe` and Windows path separators as needed.
These are SQL files; do not paste the shell commands into an SQL worksheet.

| File | Result |
|---|---|
| `01-create-shop.sql` | Four tables, four customers, five products, four orders, six order items. Run once in an empty database. |
| `02-query-shop.sql` | Filters, ordering, NULL, joins, grouped counts and quantities, LIMIT, DECIMAL coefficient display. Read-only. |
| `03-transactions.sql` | Savepoints, full rollback and INSERT/UPDATE/DELETE RETURNING. Final fixture remains unchanged. |
| `04-query-workshop.sql` | CTEs, outer-join anti-matching, ROW_NUMBER, CASE/COALESCE and recursion. Read-only. |

The common schema uses `orders.order_status` because `STATUS` is reserved.
Identifiers are explicit and remain unchanged. The price fields demonstrate
exact decimal input/storage, while arithmetic examples use integer quantities:
the pinned implementation has documented DECIMAL arithmetic and result-format
limitations. A wire price of `7990` in a known scale-2 column means `79.90`.

To reproduce all expected results and the deliberately documented edge cases,
run `../tools/validate_examples.py` as described in the manual README. That
runner creates its own fresh database; it does not use a server you already run.
