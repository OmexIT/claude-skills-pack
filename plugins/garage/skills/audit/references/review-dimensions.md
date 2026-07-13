# Review dimensions

Use this reference to run an evidence-backed review. A checklist item is a question to
investigate, not a defect by itself.

## Evidence protocol

Every finding contains:

1. **Location**: file and line, command, endpoint, migration, or subsystem.
2. **Evidence**: the smallest reproducible proof. This can be a code or config quote, scoped
   search output, failing test, runtime log, trace, query result, or absence proof that names the
   paths and terms searched.
3. **Issue**: the violated behavior, invariant, decision, or requirement.
4. **Impact**: the concrete user, business, operational, security, or maintenance consequence.
5. **Recommendation**: the smallest corrective action.
6. **Effort**: S, M, or L, with uncertainty called out.

Do not report:

- Style that an existing formatter or linter can settle.
- A theoretical risk with no reachable path or violated invariant.
- A line-count, complexity, duplication, or dependency-age threshold without verified impact.
- A missing artifact that is not required by the repository, user, regulation, or delivery flow.

## Severity

| Rank | Meaning |
|---|---|
| P1 | Broken production behavior; money, security, privacy, tenant isolation, or data-loss risk; unsafe release blocker. |
| P2 | Material correctness, reliability, operability, or maintainability risk with a credible path to impact. |
| P3 | Bounded improvement that reduces real complexity or future failure cost. |

Severity follows impact and likelihood, not pattern names. A deprecated API, duplicated block,
or missing circuit breaker is not automatically P1 or P2.

## Review sequence

1. Establish scope: branch or base, modules, documents, and explicit exclusions.
2. Read repository instructions, current requirements, architecture decisions, and verification
   commands that govern the scope.
3. Map the changed or reviewed execution paths before judging individual files.
4. Run the default lenses: correctness, simplicity, architecture.
5. Add only lenses relevant to the scope.
6. Verify each candidate finding and actively search for disconfirming evidence.
7. Rank, deduplicate by root cause, and separate fix-now from later work.

## Correctness lens

- Trace requirements and acceptance criteria to the actual path, including validation and error
  responses.
- Check boundary values, null or empty input, invalid state transitions, partial failure, retry,
  timeout, cancellation, and recovery.
- For concurrent code, identify shared mutable state, lock ordering, uniqueness boundaries, and
  lost-update or duplicate-delivery paths.
- For money movement, prove balanced entries, durable idempotency, immutable history, and
  fail-closed handling for unknown provider outcomes.
- For tenant or authorization boundaries, verify enforcement at every entry and persistence path,
  not only in UI or controller code.
- Compare behavior with the real system of record. Do not assume the reviewed service owns a fact
  controlled by another service, provider, regulator, or legal document.

## Simplicity lens

- Look for functionality that can be removed, combined, or implemented with an existing framework
  capability.
- Flag abstractions with no current consumer, parallel implementations, pass-through wrappers,
  unused flags, redundant persistence, and ceremony that does not change an outcome.
- Duplication is a signal. Extract when it repeats knowledge that can drift, or when a third use
  establishes a stable abstraction. Two similar blocks can remain clearer than a premature shared
  mechanism.
- Prefer deleting obsolete code and tests over wrapping them in compatibility layers unless
  compatibility is an explicit requirement.
- Account for operational simplicity: queues, caches, schedulers, retries, and extra services each
  need a proven need and ownership model.

## Architecture lens

- Identify ownership boundaries and dependency direction before applying a named architecture.
- Keep domain decisions separate from transport, persistence, provider, and framework mechanics
  where the repository has that boundary.
- Verify database transaction scope. Remote calls inside transactions need an explicit consistency
  design; remote mutations that time out need durable unknown-state handling.
- Check module cycles, cross-module persistence access, duplicated sources of truth, and static
  coupling that bypasses public ports.
- Use events only when a boundary, lifecycle, or audit requirement justifies asynchronous
  semantics. A method call is often the simpler in-process design.
- In Java/Spring projects, route to `arch-invariants.md`; use `archunit-setup.md` only for accepted,
  recurring boundaries.

## API lens

- Verify status codes, validation, error shape, pagination, idempotency, authorization, and
  backward compatibility against OpenAPI or the existing public contract.
- Reject leaking database IDs, persistence entities, provider errors, stack traces, or internal
  topology.
- Confirm time zones, decimal serialization, currency precision, and stable public identifiers.
- New fields should have defined optionality and default behavior. Removing or changing fields
  needs an explicit compatibility decision.
- Reuse the repository's client and error conventions after detecting actual framework versions.

## Database lens

- Verify constraints enforce invariants that must survive application bugs: uniqueness, foreign
  keys, checks, nullability, tenant boundaries, and append-only rules.
- Review migration order, lock level, table size, transaction behavior, rollback or restore story,
  and mixed-version deployment safety.
- Destructive operations require explicit authorization. A no-op rollback is not a rollback.
- Backfills must be resumable or provably bounded, observable, throttled when needed, and followed
  by a query that proves completion.
- Query and index concerns require the real plan or workload evidence. Do not report N+1 or missing
  indexes from naming alone.

## Security and privacy lens

- Trace authentication, authorization, tenant isolation, input handling, output encoding, secret
  access, logging, and audit evidence across the complete path.
- Check for broken object-level authorization, over-broad roles, mass assignment, injection,
  request forgery, unsafe deserialization, path traversal, and sensitive data in logs or errors.
- Use the exact dependency graph and official advisories or the ecosystem scanner. Do not infer a
  vulnerability from a package name or a different version.
- Verify cryptographic and credential choices against the current platform or provider guidance.
  Never propose home-grown cryptography.

## Performance and reliability lens

- Start from an SLO, profile, trace, query plan, load test, or observed resource constraint.
- Check algorithmic growth, repeated I/O, unbounded collections or histories, connection and thread
  pool exhaustion, retry amplification, hot locks, and missing pagination or backpressure.
- Choose timeout, retry, bulkhead, circuit-breaker, or cache behavior from operation semantics.
  Never return a fabricated success for a failed mutating call.
- A hard numeric threshold is a review lead unless the repository or SLO makes it a requirement.

## Test lens

- Tests should prove public behavior and the risky failure path, not getters, framework behavior,
  logging, private methods, or incidental DOM structure.
- Multiple assertions are acceptable when they describe one behavior. Random data is acceptable
  when seeded, recorded, or not behaviorally significant. Conditional setup is a smell only when it
  hides which path is exercised.
- Look for missing regression coverage, false-positive mocks, tests that never reach production
  wiring, flaky time or concurrency assumptions, and stale tests for deleted behavior.
- UI tests prefer role, label, and accessible-name locators. A missing `data-testid` is not a defect
  when a stable semantic locator exists.
- Report actual commands and outputs. Do not infer that tests pass from their presence.

## Dependency and lifecycle lens

1. Detect exact language, runtime, framework, and package versions from the checkout and resolved
   dependency graph.
2. Run the ecosystem's official or established vulnerability scanner when available.
3. Confirm support, deprecation, migration, and security status with current primary sources:
   official lifecycle pages, release notes, API docs, and advisories.
4. Distinguish vendor support from community support and direct from transitive dependencies.
5. Report only reachable or policy-relevant impact. Newer is not automatically safer or better.

Do not maintain a static EOL table in this pack. Lifecycle dates and vendor policies drift.
Do not call a framework style deprecated unless its current official documentation says so.

## Document and specification lens

- Confirm the problem, user, measurable outcome, non-goals, ownership, source of truth, negative
  constraints, acceptance criteria, edge cases, rollout, and open-question owners.
- Distinguish intended behavior from current implementation. Drift can be a code defect, stale
  document, approved but undocumented change, or unresolved decision.
- Quote the relevant text, or show a scoped search proving required content is absent.
- Avoid solution-as-requirement, vague metrics, fixed technical choices without rationale, and
  speculative flags, analytics, or infrastructure.

## Output example

```text
P1 - Timed-out transfer retries with a new reference
Location: src/.../TransferAdapter.java:84
Evidence: retry() calls newReference() after ProviderTimeout
Issue: the second request can post a second transfer while the first outcome is unknown
Impact: customer balance can be debited twice
Recommendation: persist PENDING_RECONCILIATION, reuse the original reference, and reconcile first
Effort: M
```

Close with reviewed scope, verification run, unresolved evidence gaps, fix-now findings, and later
work. A clean review is valid when the evidence supports it.
