---
name: temporal
description: >
  Use when writing or changing Temporal workflows or activities in Java - SAGA compensation,
  retry policies, signals, workflow versioning, replay/determinism issues, or Spring Boot wiring.
---

# Temporal workflows (Java SDK)

## House patterns
- **SAGA**: register each compensation before its forward step, reconcile unknown financial outcomes before reversing, and run compensations in reverse order. Catch the SDK failures produced by the actual call path; never swallow replay or cancellation failures.
- **Retry profiles** - choose by side-effect class, not by service:
  - `LIMITED` - external-API writes: a small bounded attempt count, provider-aware backoff, and durable idempotency.
  - `DEFAULT` - internal idempotent operations, still bounded by workflow deadlines.
  - `READ` - transient reads only when retries cannot amplify load or violate provider limits.
- **State machines**: when several real brands or jurisdictions share a proven configurable shape, pass a validated immutable versioned config snapshot into the workflow; otherwise use plain code.
- **Spring wiring**: use the repository's version-compatible Temporal Spring integration and worker registration. Workflow code never touches Spring beans directly; activities may.
- **Versioning**: use `Workflow.getVersion` for command-producing behavior changes that old histories can replay through. `continueAsNew` carries forward only durable state.
- **Signal races**: wait for domain queues to drain and, when handlers can block, `Workflow.await(Workflow::isEveryHandlerFinished)` before completing or continuing as new.

## Before writing code
Read `references/temporal-patterns.md` - versioning rules, continueAsNew criteria, child-workflow vs activity decision rule, fail-closed dynamic dispatch, and the failure-modes table (symptom → diagnosis → fix).

## Tests
Use `TestWorkflowEnvironment` for changed workflow behavior, ordering assertions for sagas, and recorded-history replay for command-affecting version changes. Add only the proof relevant to the change.
