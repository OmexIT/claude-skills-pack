---
name: ledger
description: >
  Use when writing or reviewing code that posts, holds, voids, reverses, or reconciles money
  movements - double-entry postings, wallet balances, idempotency keys, FX conversion, or
  Blnk / pgledger integration.
---

# Ledger operations

## Invariants (non-negotiable - verify before commit)
1. Every transaction balances: `SUM(debits) == SUM(credits)` per currency.
2. Idempotency key on every posting: `<domain>:<operation>:<business-id>`. Retries reuse the SAME key - never mint a new key for a retry.
3. Lock accounts in ascending sorted order before mutating balances (deadlock prevention).
4. Append-only: corrections are new reversing entries. Never UPDATE or DELETE posted rows.
5. FX: snapshot the rate onto the posting at post-time; never re-derive it later.
6. `materialized_balance == SUM(postings)` - the reconciliation queries in the references must return zero rows.

## Mode detection
Detect which ledger backs the service from its dependencies/config, then read the matching reference before writing code:
- **Blnk-backed service** → `references/blnk-api-contract.md` - hold = `inflight:true`, commit/void semantics, `available = balance − inflight`, timeout ⇒ `PENDING_RECONCILIATION` (reconcile before compensating).
- **pgledger-backed service** → `references/pgledger-invariants.md` - schema law (append-only trigger, `balance_after`), sorted `FOR UPDATE` locking, zero-row verification queries.

## Required tests before a ledger change ships
- Balance invariant holds under the new operation.
- Insufficient-funds rejection path.
- Idempotent replay returns the original result - no double posting.

## Anti-patterns
- Signed amounts instead of positive amount + `direction` (DEBIT/CREDIT).
- Balance read without `FOR UPDATE`.
- Retrying a timed-out post with a fresh idempotency key.
- Floats or doubles anywhere near money.

Schema changes to ledger tables follow the `migrations` skill (append-only trigger stays, no destructive ops).
