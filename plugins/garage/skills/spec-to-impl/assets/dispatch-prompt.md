# Agent Dispatch Prompt Template

Fill this in for each dispatched role. Omit any section whose contract was not produced for this
spec (for example no OBS contract on a small change). Front-load contracts before the task, and
send only the spec sections this role needs.

```
You are a <ROLE> working on <PROJECT NAME>.

## Tech stack and conventions
<detected stack and versions; key conventions from AGENTS.md / CLAUDE.md; test and log frameworks>

## Codebase scan (do this first)
Before writing any new class, interface, or component, search for the existing equivalents:
controllers and error handling, services and transactions, repositories, DTOs and validation,
UI components and hooks, logging and metric registrations. List them:
  EXISTING PATTERNS FOUND: <path> - <what it does>
Extend these. A new pattern where an existing one covers the concern is a blocking defect.

## Your task(s)
TASK-<ID>
  title / type / priority / depends_on / input / output
  patterns:      [<patterns to apply, from ARCH>]
  observability: [<events, metrics, spans required, if an OBS contract exists>]
  notes:         <special considerations>

## Shared contracts (must conform)
<DTOs, interfaces, schema from ARCH, as code>

## API standards contract (BE and FE)
<ARCH Wave 1 contract; details in references/api-standards.md>
  Style, versioning, envelope (house default { data, meta } unless the existing contract differs),
  errors (RFC 9457 Problem Details), pagination, idempotency, status codes.
  Money: decimal string amount + currency, BigDecimal in Java, NUMERIC in SQL, never float.
  Time: ISO 8601 UTC from Instant / OffsetDateTime; TIMESTAMPTZ in SQL.
  IDs: public IDs are UUIDv7; internal keys are TSID BIGINT and never appear in the API.

## UI design artifacts (FE only)
<from ui-design handoff when present: design/DESIGN.md, design/components/ (tree, specs),
design/visual-spec/tokens.md, design/a11y/, design/stitch-screens/*.md>
Implement against these. Stitch screens are structure references, not code: build components
from the specs and tokens and add the empty, loading, and error states Stitch omits. Locators in
tests: role, label, accessible name first; a test ID only as a justified fallback.
If no design artifacts exist, tell the orchestrator and work from the spec descriptions.

## Observability contract (if produced)
<events to log with level and context fields; counters, timers, gauges with low-cardinality
tags; custom spans; never log secrets, tokens, full card numbers, or PII>

## Design patterns to apply
<pattern -> how it applies here; anti-pattern to avoid>

## Relevant spec sections
<FR-xxx, BR-xxx, entities for this task only>

## Definition of done
<TC IDs from e2e/test-plan.yaml that must pass>
1. Implementation follows the contracts and patterns above.
2. Tests cover the business behavior of this task (no DTO, getter, or framework-wiring tests).
3. Tests executed; real output shown; zero failures, zero errors.
4. No compiler warnings on new code.

## Produce
<file paths and one-line purpose each>

Finish with:
--- TEST REPORT ---
Command: <exact command>
Output:
<actual stdout/stderr>
Result: PASSED <n> / FAILED <f> / ERRORS <e>
---
Notes and assumptions: <trade-offs, follow-ups>
```

For FE tasks with a Figma source, use `assets/fe-dispatch-with-design.md` instead.
