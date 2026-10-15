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
- Emit searchable attributes for workflow type, business ID, and current state.

## Determinism Checklist

- No `Instant.now()`, random UUID generation, direct threads, or direct I/O in workflow code.
- All external side effects happen in activities.
- Activity inputs include idempotency keys.
- Compensation is registered before the forward activity runs.
