# pgledger Invariants

Generated pgledger-mode code must preserve these invariants.

The tables described here are the domain wrapper tables layered over pgledger; native pgledger objects are `pgledger_accounts` / `pgledger_transfers` / `pgledger_entries` (query via `pgledger_entries_view` and `account_current_balance`).

## Transaction Invariants

- Every ledger transaction is balanced: total debits equal total credits.
- Postings are inserted atomically in one database transaction.
- Postings are append-only. Corrections are represented by new reversing postings.
- Each domain operation has a unique idempotency key.

## Account Invariants

- Account balances are derived from postings or updated from postings in the same transaction.
- Account locks are acquired via `SELECT ... FOR UPDATE` in canonical (ascending) account ID order.
- Currency is part of the account identity; do not post cross-currency entries without an FX transaction model.
- Negative balances are rejected unless the account type explicitly allows overdraft.

## Schema Requirements

- `ledger_accounts`: immutable account identity, owner reference, currency, account type.
- `ledger_transactions`: domain operation ID, idempotency key, status, created timestamp.
- `ledger_postings`: transaction ID, account ID, direction, amount, currency, `balance_after` (snapshot of the account balance after the posting), immutable audit fields.
- Append-only is enforced by a database trigger that rejects UPDATE and DELETE on `ledger_postings`.
- Unique constraint on idempotency key.
- Check constraints for positive posting amounts and valid directions.

## Verification Queries

Balanced transaction:

```sql
SELECT transaction_id
FROM ledger_postings
GROUP BY transaction_id, currency
HAVING SUM(CASE WHEN direction = 'DEBIT' THEN amount ELSE -amount END) <> 0;
```

Materialized balance drift (assumes balances are stored credit-normal; for debit-normal account types flip the sign, or join account type into the CASE):

```sql
SELECT a.id
FROM ledger_accounts a
LEFT JOIN (
  SELECT account_id,
         SUM(CASE WHEN direction = 'CREDIT' THEN amount ELSE -amount END) AS derived_balance
  FROM ledger_postings
  GROUP BY account_id
) p ON p.account_id = a.id
WHERE a.balance <> COALESCE(p.derived_balance, 0);
```

Both queries must return zero rows.
