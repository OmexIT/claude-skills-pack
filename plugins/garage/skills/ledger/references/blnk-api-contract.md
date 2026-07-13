# Blnk adapter contract

Blnk evolves independently of this pack. Confirm request fields, endpoint paths, response states,
and deployed version against the current Blnk documentation and the target environment before
implementation. Do not generate an adapter solely from this reference.

## Adapter responsibilities

- Create or resolve balances by a stable domain reference.
- Record transfers with a domain-owned unique transaction `reference`.
- Create inflight holds and commit or void them.
- Record reversals as new immutable transactions.
- Query by transaction ID and reference, follow parent transactions, and reconcile state.
- Persist enough operation evidence to recover after a timeout or webhook gap.

Keep provider terminology inside the adapter. The application port should express domain
operations and explicit outcomes such as applied, inflight, rejected, and pending reconciliation.

## Transaction and inflight mapping

- A transaction request uses `reference` for provider idempotency and includes the authoritative
  source, destination, amount, currency, and precision.
- `inflight: true` reserves funds and yields an `INFLIGHT` transaction once processed.
- Committing an inflight transaction creates an immutable `APPLIED` child; voiding creates a
  `VOID` child. Follow `parent_transaction` rather than mutating local history.
- Partial commit and scheduled inflight behavior are version-dependent. Use them only when the
  deployed version and business flow explicitly require them.
- Available funds account for inflight debit balance. Never authorize spend from the posted
  balance alone.
- Queue and `skip_queue` modes have different response timing. A queued acknowledgement is not an
  applied transaction.

Current upstream overview:
<https://docs.blnkfinance.com/transactions/introduction> and
<https://docs.blnkfinance.com/transactions/transaction-lifecycle>.

## Authentication and transport

- Read the base URL, authentication mode, key, and timeouts from secure configuration.
- `X-Blnk-Key` is used when the deployed Blnk instance enables secure mode.
- Never log credentials or unredacted sensitive metadata.
- Bound calls with operation-appropriate timeouts and record request start, response, and error
  classification for reconciliation.

## Idempotency and duplicate references

- The domain service creates one stable reference per business operation. A retry reuses it.
- A duplicate-reference response is not sufficient proof that this request already succeeded.
- Fetch the original transaction by reference and compare at least the business operation,
  source, destination, amount or precise amount, currency, and intended operation type.
- If every invariant matches, return or reconcile to the original provider result.
- If any invariant differs, fail closed as an idempotency conflict and alert. Never accept a
  different transaction merely because the reference collides.
- Do not mint a new reference after a timeout or duplicate response.

## Durable operation record

Persist before or atomically with dispatch, as the architecture allows:

- Domain operation ID and stable Blnk reference.
- Provider transaction and parent IDs when known.
- Source and destination references.
- Amount, precision, and currency.
- Intended operation: transfer, hold, commit, void, or reversal.
- Provider and domain status, attempts, and timestamps.
- A hash or canonical snapshot of the identity fields used for duplicate comparison.

## Unknown and reconciliation behavior

- A timeout, connection reset, ambiguous 5xx, or missing webhook after dispatch can mean the
  provider applied the mutation. Mark it `PENDING_RECONCILIATION`.
- Reconcile by stable reference and transaction lineage before retrying, compensating, or telling
  the caller the operation failed.
- Reconciliation is idempotent and can transition only from observed provider evidence.
- A compensation is a new referenced transaction. It never edits or deletes provider history.
- Alert on unresolved inflight operations, mismatched duplicate references, and reconciliation age.

Provider docs describe lookup by reference and transaction lineage; adapter tests should exercise
the exact behavior of the deployed Blnk version.
