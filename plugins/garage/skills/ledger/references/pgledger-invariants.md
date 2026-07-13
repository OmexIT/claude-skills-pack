# pgledger and PostgreSQL ledger invariants

This reference covers two related modes:

1. The upstream `pgr0ss/pgledger` SQL project.
2. A service-owned PostgreSQL double-entry schema sometimes called pgledger locally.

Do not mix their object names. Detect which mode the repository actually installs.

## Upstream pgledger

Upstream pgledger is an evolving SQL implementation distributed from
<https://github.com/pgr0ss/pgledger>. Pin the exact revision in the application and inspect its
installed SQL before writing queries or migrations.

At the reviewed revision, public usage is based on functions and views such as
`pgledger_create_account`, `pgledger_create_transfer`, `pgledger_accounts_view`,
`pgledger_transfers_view`, and `pgledger_entries_view`. Underlying table names and signatures are
not a stable contract unless the pinned revision says they are.

- Use upstream creation functions rather than direct inserts.
- Keep transfers in the same database transaction as related application state when atomicity is
  the reason for choosing pgledger.
- Each account is single-currency. Currency conversion uses balanced transfers for each currency,
  with an explicit snapshotted rate in the application operation record.
- Upstream uses its own prefixed identifiers. Do not rewrite them to the pack's TSID convention.
- Verify upgrade scripts and compatibility against the pinned revision; do not patch upstream
  tables with generic house migrations.

## Service-owned ledger schema

For a local schema, names vary but these invariants do not:

- Every transaction balances per currency: total debits equal total credits.
- Posting insertion and any materialized balance update are atomic.
- Entries are append-only. Corrections use new linked reversal entries.
- A unique domain idempotency key identifies the complete intended operation.
- Lock all affected accounts in a canonical ascending order before balance mutation.
- Each account has one currency and a defined normal balance direction.
- Negative available balances are rejected unless an explicit account policy allows them.
- Positive posting amounts and explicit debit or credit direction are enforced by constraints.
- Append-only behavior and idempotency are protected in the database, not only in application code.

`balance_after` can aid audit and historical reconstruction, but concurrency and ordering must make
it trustworthy. If the schema stores it, verify every entry's previous and next balance chain.

## Verification query patterns

Adapt names and normal-balance rules to the installed schema. These queries must return zero rows.

Unbalanced transactions:

```sql
SELECT transaction_id, currency
FROM ledger_postings
GROUP BY transaction_id, currency
HAVING SUM(CASE WHEN direction = 'DEBIT' THEN amount ELSE -amount END) <> 0;
```

Materialized balance drift with account-aware sign:

```sql
WITH derived AS (
  SELECT p.account_id,
         SUM(
           CASE
             WHEN a.normal_balance = p.direction THEN p.amount
             ELSE -p.amount
           END
         ) AS balance
  FROM ledger_postings p
  JOIN ledger_accounts a ON a.id = p.account_id
  GROUP BY p.account_id
)
SELECT a.id
FROM ledger_accounts a
LEFT JOIN derived d ON d.account_id = a.id
WHERE a.balance <> COALESCE(d.balance, 0);
```

Duplicate operation keys with different intent:

```sql
SELECT idempotency_key
FROM ledger_transactions
GROUP BY idempotency_key
HAVING COUNT(*) > 1;
```

A unique constraint should normally make the last query impossible. Add operation-specific checks
for reversal linkage, currency, and `balance_after` chain continuity where those fields exist.
