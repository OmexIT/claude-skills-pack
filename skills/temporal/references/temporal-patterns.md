# Temporal Workflow Patterns

Use these patterns when generating Java Temporal workflows.

## Versioning

- Never change completed workflow history semantics in place.
- Use `Workflow.getVersion` around workflow-logic changes that affect command history.
- Keep old branches until all in-flight executions that can hit them have completed.
- Prefer new activity names for materially different side effects.

## Continue As New

Use `Workflow.continueAsNew(...)` when:

- A polling loop can run indefinitely.
- History length grows with each signal or timer.
- The workflow owns a recurring business process.

Carry forward only durable state needed for the next run. Rebuild derived state from inputs or queries.

## Signals And Queries

- Signals mutate workflow state and must be deterministic.
- Queries never mutate state.
- Drain or reject late signals before workflow completion when the caller expects a final state.
- Validate signal payloads before adding them to pending work queues.

## Child Workflows

Use child workflows when a sub-process needs independent retry, visibility, cancellation, or lifecycle ownership. Use activities when the work is a bounded side effect.

## Dynamic Dispatch

For config-driven state machines:

- Parse config outside workflow code or pass immutable config into the workflow input.
- Map config transitions to explicit activity calls.
- Keep unknown transition handling fail-closed.
- Emit search attributes (`Workflow.upsertTypedSearchAttributes`) for workflow type, business ID, and current state.

## Determinism Checklist

- No `Instant.now()` (use `Workflow.currentTimeMillis()`), random UUID generation, direct threads, or direct I/O in workflow code.
- All external side effects happen in activities.
- Activity inputs include idempotency keys.
- Compensation is registered before the forward activity runs.

## Failure modes (symptom → diagnosis → fix)

| Symptom | Diagnosis | Fix |
|---|---|---|
| Workflow replay fails after redeploy | Non-deterministic code path added | Move to activity; gate with `Workflow.getVersion()` |
| Activity stuck for hours after worker crash | Long StartToCloseTimeout, no HeartbeatTimeout | Set `HeartbeatTimeout` in `ActivityOptions` and call `Activity.getExecutionContext().heartbeat(...)` in long-running activities |
| Compensation doesn't run | Exception caught and swallowed | Catch only `ActivityFailure`/`ChildWorkflowFailure`/`ApplicationFailure`; let others propagate |
| Duplicate side-effects on retry | Activity not idempotent | Idempotency key at entry; dedupe at DB layer |
| Signal race with completion | Signal arrives after `@WorkflowMethod` returns | Drain first: `Workflow.await(() -> pendingSignals.isEmpty())`; plus `Workflow.await(Workflow::isEveryHandlerFinished)` (SDK >=1.25) for in-flight handlers |
| History grows unbounded | Long-running loop without continueAsNew | `Workflow.continueAsNew(...)` at checkpoint |

## Never inside a workflow
Spring beans called directly (use activities) · `Thread.sleep` (use `Workflow.sleep`) · `UUID.randomUUID()` (use `Workflow.randomUUID()`) · catching `Throwable` (masks replay failures) · activity calls or state mutation inside query handlers · retry and compensation logic mixed in one activity.
