# PRD: <feature name>

Status: Draft | Approved | Superseded
Owner: <person or team>
Version: 0.1
Last updated: YYYY-MM-DD

## Change log

| Version | Date | Change | Decision or evidence |
|---|---|---|---|
| 0.1 | YYYY-MM-DD | Initial scope | <link or source> |

## Problem and evidence

Who is blocked, what are they trying to do, and what happens today? Include the smallest useful
evidence: user report, operational data, policy, contract, or observed workflow.

## Why now

State the trigger and the cost of waiting. Delete this proposal if there is no credible reason to
prioritize it.

## Goals and success measures

| Goal | Measure | Baseline | Target | Measurement window and owner |
|---|---|---|---|---|
| G-01 | <observable outcome> | <current> | <target> | <window, owner> |

## Non-goals

- NG-01: <explicitly excluded capability or persona>

## Negative constraints

- NC-01: Do not change <owned module, contract, copy, CI, or external system>.
- NC-02: This component must not become the system of record for <external fact>.

## Ownership and source of truth

| Concern | Owner or system of record | This feature may | This feature must not |
|---|---|---|---|
| <fact or process> | <service, provider, legal source> | <read/write boundary> | <forbidden ownership> |

## User flow

Describe the shortest happy path in numbered steps. Add a failure or recovery flow only when it
changes requirements.

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

Repeat this section only for independently testable requirements. Keep priorities honest; P1 and
later requirements can be deferred instead of padded into the first release.

## Non-functional requirements

Include only categories changed by this feature. Delete unused rows.

| ID | Category | Testable requirement | Verification |
|---|---|---|---|
| NFR-001 | Reliability, security, privacy, accessibility, performance, or compliance | <specific bound or invariant> | <command, test, review, or evidence> |

## Data and integration changes

Include only when applicable:

- Public API or event contract, including compatibility.
- Persistence and migration impact, including restore or rollback.
- Money movement and idempotency behavior.
- External provider outcome and unknown-state handling.
- Data classification, retention, tenant, and audit requirements.

## UX states

Include only for user-facing work: loading, empty, validation, failure, stale, permission denied,
success, responsive behavior, keyboard behavior, and reduced motion where relevant.

## Rollout and operations

Include only what the change needs: deployment order, mixed-version safety, migration or backfill,
monitoring, alerts, support notes, recovery, and removal of temporary rollout machinery. Do not add
a feature flag unless there is a present rollout or risk-control need and a named removal owner.

## Open questions

| ID | Question | Owner | Due | Blocks |
|---|---|---|---|---|
| OQ-001 | <unresolved decision> | <owner> | YYYY-MM-DD | <requirement or no> |

## Definition of ready

- [ ] Problem, user, evidence, and why-now are credible.
- [ ] Smallest useful scope is explicit; non-goals and negative constraints are present.
- [ ] Ownership and systems of record are unambiguous.
- [ ] Every non-trivial P0 requirement has testable acceptance criteria and at least two materially different edge cases; atomic rules contain no filler.
- [ ] Relevant failure, timeout, duplicate, recovery, and accessibility behavior is defined.
- [ ] Destructive, security, privacy, financial, regulatory, and external-provider risks have an
      owner and verification path.
- [ ] Open questions that block implementation are resolved.
- [ ] Success measures have a baseline or a plan to establish one.
