# pgledger Invariants

Generated pgledger-mode code must preserve these invariants.

## Transaction Invariants

- Every ledger transaction is balanced: total debits equal total credits.
- Postings are inserted atomically in one database transaction.
- Postings are append-only. Corrections are represented by new reversing postings.
- Each domain operation has a unique idempotency key.

## Account Invariants

- Account balances are derived from postings or updated from postings in the same transaction.
- Account locks are acquired in canonical account ID order.
- Currency is part of the account identity; do not post cross-currency entries without an FX transaction model.
- Negative balances are rejected unless the account type explicitly allows overdraft.

## Schema Requirements

- `ledger_accounts`: immutable account identity, owner reference, currency, account type.
- `ledger_transactions`: domain operation ID, idempotency key, status, created timestamp.
- `ledger_postings`: transaction ID, account ID, direction, amount, currency, immutable audit fields.
- Unique constraint on idempotency key.
- Check constraints for positive posting amounts and valid directions.

## Verification Queries

Balanced transaction:

```sql
SELECT transaction_id
FROM ledger_postings
GROUP BY transaction_id
HAVING SUM(CASE WHEN direction = 'DEBIT' THEN amount ELSE -amount END) <> 0;
```

Materialized balance drift:

```sql
SELECT a.id
FROM ledger_accounts a
JOIN (
  SELECT account_id,
         SUM(CASE WHEN direction = 'CREDIT' THEN amount ELSE -amount END) AS derived_balance
  FROM ledger_postings
  GROUP BY account_id
) p ON p.account_id = a.id
WHERE a.balance <> p.derived_balance;
```

Both queries must return zero rows.
