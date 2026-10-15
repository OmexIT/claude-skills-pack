# Temporal Java workflow patterns

Detect the exact Java SDK and server versions before using APIs from examples. Workflow code must
stay deterministic across replay and safe across deployments with open executions.

## Determinism and versioning

- Workflow code must not perform direct I/O, call Spring beans, start threads, or read changing
  process configuration. External side effects belong in activities or child workflows.
- Use `Workflow.getVersion` for a command-producing logic change that existing histories can replay
  through. Pure refactors that keep the same commands need no marker.
- Keep old version branches until no retained or open history can execute them, following the
  repository's worker deployment strategy.
- Prefer a new activity name for a materially different side effect.
- Replay recorded representative histories (`WorkflowReplayer`) before deploying a versioned change.

## Saga compensation

- Register compensation before invoking the forward side effect, so a timeout after dispatch still
  has a recovery path. Each compensation must succeed when there is nothing to undo.
- Compensation runs in reverse order and is independently idempotent.
- Catch the SDK failure types produced by the specific activity or child-workflow call, compensate,
  then rethrow or map deliberately. Do not catch `Throwable` or swallow replay and cancellation
  failures. On cancellation, run compensation inside `Workflow.newDetachedCancellationScope`.
- An unknown financial result is reconciled before compensation. Do not reverse a transfer merely
  because the initiating activity timed out.
- Persist or derive stable operation keys for forward and compensating activities.

## Retry policies

Retries are per operation, not per service name:

- External writes: small bounded attempt count, backoff aware of provider rate limits, durable
  idempotency. List business rejection error types as non-retryable.
- Internal idempotent writes: bounded by the workflow's business deadline and operational load.
- Reads: retry only transient failures, with a cap that cannot amplify an incident.
- Long-running activities: start-to-close and heartbeat timeouts, with heartbeated progress.

`RetryOptions.setDoNotRetry` matches the failure's error type: the type string of an
`ApplicationFailure`, or the exception class name for other exceptions thrown from an activity. It
does not match `ApplicationFailure` itself. Do not rely on a workflow execution timeout as the only
retry bound.

## Signals, updates, and queries

- Query handlers read state only; they never block, mutate, or call activities.
- Validate signal and update payloads before adding domain work (update validators where used).
- Handlers can run before the main workflow method and can block. Coordinate shared state
  deterministically.
- Before returning or continuing as new, wait for domain work queues and, when handlers may still be
  running, for every handler:

```java
Workflow.await(() -> pendingWork.isEmpty());
Workflow.await(Workflow::isEveryHandlerFinished);
```

- `isEveryHandlerFinished` exists in recent SDK versions; on an older SDK, track in-flight handlers
  with a counter and await zero, or upgrade.
- Use an unfinished-handler policy only when abandonment is intentional and safe.

Current guidance: <https://docs.temporal.io/develop/java/workflows/message-passing>.

## Continue as new

Use continue-as-new when an ongoing loop, messages, or timers would grow history without bound.
Check `Workflow.getInfo().isContinueAsNewSuggested()` where the SDK provides it, or a history-length
threshold well below the server's hard limit.

- Carry only durable workflow state required by the next run; rebuild derived state.
- Finish message handlers first.
- Preserve deduplication state needed across runs, or use stable update IDs where supported.
- Do not call continue-as-new from an update handler.

## Activities versus child workflows

- An activity for a bounded side effect owned by the parent workflow.
- A child workflow when the sub-process needs its own lifecycle, visibility, cancellation, retry
  policy, signals, or independent ownership.
- Do not create a child workflow only to wrap one activity.

## Config-driven state machines

Only when several real brands, jurisdictions, or products share a proven state-machine shape.

- Resolve and validate config outside workflow execution, then pass an immutable versioned snapshot
  or a stable config reference whose content cannot change during replay.
- Map allowed transitions to explicit activity or child-workflow calls.
- An unknown state, action, or target fails closed.
- Record searchable business ID, workflow type, and current state when the installed SDK supports the
  typed search-attribute API.

Plain code is clearer for one stable flow.

## Failure-mode table

| Symptom | Verify | Corrective direction |
|---|---|---|
| Replay fails after deploy | A new path produces different commands for old history | Restore compatibility and gate the change with `getVersion` |
| Activity appears stuck | Timeouts, worker availability, heartbeat progress | Set bounded timeouts and heartbeat long-running work |
| Compensation is missing | Registration order, caught failure type, unknown provider state | Register first, reconcile unknown outcomes, compensate in reverse |
| Duplicate side effect | Activity idempotency and stable operation key | Dedupe at the authoritative boundary and reuse the key |
| Workflow closes during handler work | Domain queue and handler completion conditions | Await both pending work and every handler |
| History grows without bound | Loop, signal, update, and timer count | Continue as new at a tested checkpoint |
| Retries amplify an outage | Attempt count, backoff, non-retryable classification | Bound and classify the per-operation retry policy |

## Verification

- `TestWorkflowEnvironment` for state, time skipping, retry, signal, cancellation, and compensation.
- Ordering assertions for forward and reverse compensation steps.
- Idempotency and unknown-outcome tests around activities that mutate external systems.
- Replay tests from production-like histories for command-affecting changes.
- Integration checks for worker registration, task queues, data conversion, and search attributes
  when those changed.
