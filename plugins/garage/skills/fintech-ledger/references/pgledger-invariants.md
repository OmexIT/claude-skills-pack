# pgledger and PostgreSQL ledger invariants

Two related modes. Do not mix their object names; detect which one the repository installs.

1. The upstream `pgr0ss/pgledger` SQL project.
2. A service-owned PostgreSQL double-entry schema, sometimes also called pgledger locally.

## Upstream pgledger

Upstream pgledger is an evolving SQL implementation distributed from
<https://github.com/pgr0ss/pgledger>. Pin the exact revision in the application and inspect its
installed SQL before writing queries or migrations.

At the reviewed revision, public usage is through functions and views such as
`pgledger_create_account`, `pgledger_create_transfer`, `pgledger_accounts_view`,
`pgledger_transfers_view`, and `pgledger_entries_view`. Underlying table names and signatures are
not a stable contract unless the pinned revision says so.

- Use upstream creation functions, not direct inserts.
- Keep transfers in the same database transaction as related application state when atomicity is
  the reason for choosing pgledger.
- Each account is single-currency. Currency conversion is balanced transfers per currency, with the
  rate snapshotted on the application's operation record.
- Upstream uses its own prefixed identifiers. Do not rewrite them to the house TSID convention.
- Application tables (operation records, idempotency, outbox) live beside upstream objects with
  their own names and house conventions; they never alter upstream tables.
- Verify upgrade scripts against the pinned revision; do not patch upstream tables with house
  migrations.

## Service-owned ledger schema

Names vary; these invariants do not:

- Every transaction balances per currency: total debits equal total credits.
- Posting insertion and any materialized balance update are atomic.
- Entries are append-only, enforced by a database trigger. Corrections are new linked reversals.
- A unique domain idempotency key identifies the complete intended operation; a replay with
  different intent is a conflict, not a success.
- All affected accounts are locked in ascending ID order (`ORDER BY id FOR UPDATE`) before balance
  mutation.
- Each account has one currency and a defined normal balance direction.
- Negative available balances are rejected unless an explicit account policy allows them.
- Positive amounts and explicit debit or credit direction are enforced by constraints.
- Append-only behavior and idempotency are protected in the database, not only in application code.

`balance_after` can aid audit and historical reconstruction, but only if locking and ordering make
it trustworthy. If the schema stores it, verify the chain of previous and next balances per account.

## Verification queries

Adapt names and normal-balance rules to the installed schema. Each must return zero rows.

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
         SUM(CASE WHEN a.normal_balance = p.direction THEN p.amount ELSE -p.amount END) AS balance
  FROM ledger_postings p
  JOIN ledger_accounts a ON a.id = p.account_id
  GROUP BY p.account_id
)
SELECT a.id
FROM ledger_accounts a
LEFT JOIN derived d ON d.account_id = a.id
WHERE a.balance <> COALESCE(d.balance, 0);
```

Postings in a currency other than their account's:

```sql
SELECT p.id
FROM ledger_postings p
JOIN ledger_accounts a ON a.id = p.account_id
WHERE p.currency <> a.currency;
```

Add operation-specific checks for reversal linkage and `balance_after` continuity where those fields
exist. Run these in integration tests and on a schedule; a non-empty result raises an alert and
marks the affected balances stale until resolved.
