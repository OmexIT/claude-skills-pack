# PRD: <feature name>

Status: Draft | Approved | Superseded
Owner: <person or team>
Version: 0.1
Last updated: YYYY-MM-DD

Sections marked "when relevant" are deleted when they do not apply. Never pad them.

## Change log

| Version | Date | Change | Decision or evidence |
|---|---|---|---|
| 0.1 | YYYY-MM-DD | Initial scope | <link or source> |

## Problem and evidence

Who is blocked, what are they trying to do, and what happens today? Include the smallest useful
evidence: user report, operational data, policy, contract, or observed workflow.

## Why now

The trigger and the cost of waiting. If there is no credible reason, say so and recommend not
prioritizing it.

## Goals and success measures

| Goal | Measure | Baseline | Target | Window and owner |
|---|---|---|---|---|
| G-01 | <observable outcome> | <current, or how it will be established> | <target> | <window, owner> |

Add a guardrail row only when a goal could be met by harming something else.

## Non-goals

- NG-01: <explicitly excluded capability or persona>

## Negative constraints (when relevant)

- NC-01: Do not change <owned module, contract, copy, CI, or external system>.
- NC-02: This component must not become the system of record for <external fact>.

## Ownership and source of truth (when relevant)

| Concern | Owner or system of record | This feature may | This feature must not |
|---|---|---|---|
| <fact or process> | <service, provider, legal source> | <read/write boundary> | <forbidden ownership> |

## User flow

The shortest happy path in numbered steps. Add a failure or recovery flow only when it changes
requirements.

## Requirements

### FR-001: <requirement title> [P0]

Requirement: <observable behavior, not an implementation mechanism>.

Acceptance criteria:

- Given <context>, when <action>, then <observable result>.
- Given <invalid or failed condition>, when <action>, then <safe result and recovery>.

Edge cases:

- <boundary, duplicate, timeout, empty, or concurrency case>
- <second materially different case>

Source of truth or dependency: <owner and contract, when relevant>.

Repeat only for independently testable requirements. Keep priorities honest; P1 and later can be
deferred instead of padded into the first release. A superseded requirement keeps its ID and
says what replaced it.

## Non-functional requirements (when relevant)

Only categories this feature changes.

| ID | Category | Testable requirement | Verification |
|---|---|---|---|
| NFR-001 | Reliability, security, privacy, accessibility, performance, or compliance | <specific bound or invariant> | <test, review, or evidence> |

## Data and integration changes (when relevant)

- Public API or event contract, including compatibility.
- Persistence and migration impact, including restore or rollback.
- Money movement and idempotency behavior.
- External provider outcome and unknown-state handling.
- Data classification, retention, tenant, and audit requirements.

## UX states (user-facing work only)

Loading, empty, validation, failure, stale, permission denied, success, responsive behavior,
keyboard behavior, and reduced motion, as relevant.

## Rollout and operations (when relevant)

Only what the change needs: deployment order, mixed-version safety, migration or backfill,
monitoring, support notes, recovery, and removal of temporary rollout machinery. No feature flag
unless there is a present rollout or risk-control need and a named removal owner.

## Open questions

| ID | Question | Owner | Due | Blocks |
|---|---|---|---|---|
| OQ-001 | <unresolved decision> | <owner> | YYYY-MM-DD | <requirement or no> |

## Definition of ready

- [ ] Problem, user, evidence, and why-now are credible.
- [ ] Smallest useful scope is explicit; non-goals are present, negative constraints where needed.
- [ ] Ownership and systems of record are unambiguous.
- [ ] Every non-trivial P0 requirement has testable acceptance criteria and two materially different edge cases.
- [ ] Relevant failure, timeout, duplicate, recovery, and accessibility behavior is defined.
- [ ] Destructive, security, privacy, financial, regulatory, and external-provider risks have an
      owner and a verification path.
- [ ] Open questions that block implementation are resolved.
- [ ] Success measures have a baseline or a plan to establish one.
