# Blnk adapter contract

Blnk evolves independently of this pack. Confirm request fields, endpoint paths, response states,
and the deployed version against the current Blnk documentation and the target environment before
implementation. Do not generate an adapter solely from this reference.

## Adapter responsibilities

- Create or resolve balances by a stable domain reference.
- Record transfers with a domain-owned unique transaction `reference`.
- Create inflight holds and commit or void them.
- Record reversals as new immutable transactions.
- Query by transaction ID and reference, follow parent transactions, and reconcile state.
- Persist enough operation evidence to recover after a timeout or webhook gap.

Keep provider terminology inside the adapter. The application port expresses domain operations and
explicit outcomes such as applied, inflight, rejected, and pending reconciliation.

## Transaction and inflight mapping

- A transaction request uses `reference` for provider idempotency and carries the authoritative
  source, destination, amount, currency, and precision. Prefer the precise integer amount field when
  the deployed version offers it; never build the amount through `double`.
- `inflight: true` reserves funds and yields an `INFLIGHT` transaction once processed.
- Committing an inflight transaction creates an immutable `APPLIED` child; voiding creates a `VOID`
  child. Follow `parent_transaction` rather than mutating local history.
- Partial commit and scheduled inflight expiry are version-dependent. Use them only when the
  deployed version and the business flow require them.
- Available funds account for the inflight debit balance. Never authorize spend from the posted
  balance alone.
- Queue and `skip_queue` modes differ in response timing. A queued acknowledgement is not an applied
  transaction.

Upstream overview: <https://docs.blnkfinance.com/transactions/introduction> and
<https://docs.blnkfinance.com/transactions/transaction-lifecycle>.

## Authentication and transport

- Read base URL, auth mode, key, and timeouts from secure configuration. `X-Blnk-Key` is used when
  the deployed instance enables secure mode.
- Reuse the project's configured HTTP client (`RestClient`, `WebClient`, or what the repo already
  uses); do not add a second client stack.
- Never log credentials or unredacted sensitive metadata.
- Bound calls with operation-appropriate timeouts and record request start, response, and error
  classification for reconciliation.
- Do not wrap the HTTP call in a database transaction. Persist the operation record, commit,
  dispatch, then record the observed outcome.

## Idempotency and duplicate references

- The domain service creates one stable reference per business operation. A retry reuses it.
- A duplicate-reference response is not proof that this request already succeeded. Fetch the
  original transaction by reference and compare the business operation, source, destination, amount
  or precise amount, currency, and intended operation type.
- If every field matches, return or reconcile to the original provider result.
- If any field differs, fail closed as an idempotency conflict and alert. Never accept a different
  transaction because the reference collides.
- Do not mint a new reference after a timeout or a duplicate response.

## Durable operation record

Persist before or atomically with dispatch, in a local table separate from provider data:

- Domain operation ID and stable Blnk reference.
- Provider transaction and parent IDs when known.
- Source and destination references.
- Amount, precision, and currency.
- Intended operation: transfer, hold, commit, void, or reversal.
- Provider and domain status, attempts, and timestamps (`TIMESTAMPTZ`).
- A hash or canonical snapshot of the identity fields used for duplicate comparison.

## Balances shown to users

- A balance fetched from Blnk or cached locally carries its as-of time.
- If Blnk is unreachable, the cached value is past its freshness limit, or the account has an open
  reconciliation mismatch, return the balance marked stale and refuse debits, holds, and payouts
  until a fresh read or reconciliation succeeds. Credits may still be recorded through the normal
  idempotent path.

## Unknown results and reconciliation

- A timeout, connection reset, ambiguous 5xx, or missing webhook after dispatch can mean the provider
  applied the mutation. Mark it `PENDING_RECONCILIATION`.
- Reconcile by stable reference and transaction lineage before retrying, compensating, or telling
  the caller the operation failed.
- Reconciliation is idempotent and transitions only from observed provider evidence.
- A compensation is a new referenced transaction. It never edits or deletes provider history.
- Scheduled reconciliation compares provider balances and transactions with the local operation
  records; a mismatch raises an alert and marks the affected balances stale (see above).
- Alert on unresolved inflight operations, mismatched duplicate references, and reconciliation age.

Adapter tests should exercise the exact behavior of the deployed Blnk version: duplicate reference
with matching and differing intent, timeout then reconcile, inflight commit and void.
