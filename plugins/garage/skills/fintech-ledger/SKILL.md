---
name: fintech-ledger
description: "Use when work touches money movement or balances: double-entry ledger postings, wallet credit or debit, holds, capture, refunds, settlement, payouts, collections, float, multi-currency or FX, reconciliation, balance mismatches, Blnk, pgledger, or ledger tables."
---

# Fintech ledger: double-entry operations

Builds or changes ledger operations (post, hold, capture, void, reverse, reconcile) on Blnk, upstream
pgledger, or a service-owned PostgreSQL ledger. Ledger bugs do not self-correct: they compound into
balance mismatches that need a manual audit, so the gates below are not optional.

## Gates

1. Pin the operation before code: which accounts move, currency and scale, FX snapshot, idempotency
   key, compensation path, and what happens on a timeout or partial failure.
2. Write a short plan: every posting (debit and credit), lock order, reversal path, and the
   reconciliation query that proves it. Keep ledger changes out of unrelated refactors.
3. Write integration tests first against real Postgres (Testcontainers) or the provider's test
   instance, then implement. If asked to change a ledger path "quickly", still write the invariant
   tests; say why instead of skipping them.
4. Verify before claiming done: run the integration suite and the reconciliation queries; both must
   come back clean (zero mismatch rows).
5. In the summary, list the invariants the reviewer must check and link the engine's docs.

## Mode detection

Detect from dependencies, config, and migrations, then read the matching reference before writing
code. Ask when the signals conflict or are absent.

- **Blnk** (Blnk client or base URL in config): read `references/blnk-api-contract.md`.
- **Upstream pgledger** (installed `pgledger_*` functions and views from `pgr0ss/pgledger`): read
  `references/pgledger-invariants.md`. Use its functions; never patch its tables with house migrations.
- **Service-owned ledger schema** (local `ledger_accounts` / `ledger_postings` style tables, sometimes
  also called pgledger locally): read `references/pgledger-invariants.md`, and read
  `references/service-ledger-scaffold.md` when creating the schema or the posting service.

Keep local wrapper tables (operation records, idempotency, outbox) separate from upstream pgledger or
provider objects, and verify names against the installed revision, not this skill.

## Invariants (all modes)

1. **Balanced**: debits equal credits per currency for every transaction, written atomically.
2. **Idempotent**: one stable key per business operation (`<domain>:<operation>:<business-id>`),
   reused on every retry. A duplicate key is success only after the original operation is fetched and
   its accounts, amount, currency, and operation type match; any difference is an idempotency
   conflict that fails closed and alerts.
3. **Unknown is not failure**: a timeout or ambiguous 5xx after dispatch is `PENDING_RECONCILIATION`.
   Reconcile by reference before retrying, compensating, or telling the caller it failed. Never retry
   with a new key.
4. **Append-only**: corrections are new linked reversal entries; never UPDATE or DELETE posted rows.
5. **Locking**: a service-owned ledger locks every affected account in ascending ID order with
   `ORDER BY id FOR UPDATE` before reading balances. Provider-backed ledgers use the provider's
   concurrency contract.
6. **Currency**: each account has one currency. FX is two balanced legs (one per currency) through FX
   accounts, with the rate snapshotted on the operation record at post time and never re-derived.
7. **Available funds** subtract held or inflight debits; never authorize spend from the posted
   balance alone. Negative available balance is rejected unless the account policy allows overdraft.
8. **Reconciliation**: the materialized balance equals the signed sum of postings using the account's
   normal balance, and the reference's verification queries return zero rows.
9. **Stale balances**: a balance read from a cache, snapshot, or a provider that cannot currently be
   reached carries its as-of time. When it is stale or its account has an open reconciliation
   mismatch, show it as stale and block debits, holds, and payouts against it until reconciled.
10. **Money types**: `BigDecimal` in Java with scale from the currency or asset contract, `NUMERIC` in
    SQL, integer minor units only where the provider's API requires them. Never `double` or `float`.
11. **Events**: when downstream consumers exist, write the domain event through the repository's
    outbox in the same transaction as the posting. Do not publish before the posting commits.

Never hold a database transaction open across a provider HTTP call: persist the operation record,
commit, dispatch, then record the outcome.

## Required tests

- Balanced postings and the reconciliation query for the new operation.
- Insufficient-funds rejection.
- Idempotent replay returns the original result with no second posting; same key with different
  intent is rejected.
- Reversal correctness, and for providers, the timeout path ending in `PENDING_RECONCILIATION`.
- Concurrent posts on the same accounts when the change touches locking.

Schema changes to ledger tables also follow `db-migration` (append-only trigger stays, no
destructive operations without confirmation and a restore story).

## Output contract

```yaml
produces:
  - type: "code"
    format: "java"
    paths:
      - "src/main/java/.../ledger/{Service}.java"
      - "src/main/java/.../ledger/{Repository}.java"
      - "src/main/java/.../ledger/events/*.java"    # domain events
      - "src/main/java/.../ledger/dto/*.java"       # commands + DTOs
  - type: "migration"
    format: "sql"
    paths:
      - "src/main/resources/db/changelog/changes/sql/ledger-NNN-description.sql"  # service-owned schema only
  - type: "test"
    format: "java"
    paths:
      - "src/test-integration/java/.../ledger/{Service}IntegrationTest.java"  # Testcontainers
  - type: "doc"
    format: "markdown"
    path: "docs/ledger/{operation}.md"
  handoff: "Write claudedocs/handoff-fintech-ledger-<timestamp>.yaml - suggest: temporal-workflow (if compensation needed), verify-impl, monitoring-plan"
```

## Workflow context

- `db-migration` writes the ledger changeset; `temporal-workflow` owns multi-step orchestration and
  compensation around ledger calls; this skill owns posting semantics and reconciliation.

## Anti-patterns (never generate)

- Single-leg postings, or one transfer whose legs are in different currencies.
- Signed amounts instead of a positive amount plus explicit debit or credit direction.
- Balance read before mutation without the lock, or locks taken in unspecified order
  (`WHERE id = ANY(...) FOR UPDATE` without `ORDER BY`).
- Treating a duplicate-reference or unique-violation response as success without comparing intent.
- Retrying a timed-out post with a fresh idempotency key.
- Summing an account's full posting history inside every post as a "check": run reconciliation
  queries in tests and on a schedule instead.
