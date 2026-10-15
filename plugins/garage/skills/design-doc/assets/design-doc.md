# Design: <title>

Status: Draft | In review | Accepted
Owner: <name> | PRD: <link> | Last updated: YYYY-MM-DD

Delete any section marked "when relevant" that does not apply.

## Summary
What we are building, why now, and how we will know it worked (1-3 measurable outcomes).

## Requirements
- Functional: R1, R2 (or link the PRD requirement IDs)
- Non-functional: only the bounds this design must meet (latency, availability, cost, compliance)
- Non-goals:
- Constraints and assumptions:

## Proposed design
### Components and data flow
What runs where, who calls whom, and what is synchronous vs asynchronous. Add a diagram when it
explains more than prose.

### Data model
Entities, owner of each fact, keys and indexes, access patterns, migration or backfill needs.

### APIs and events (when relevant)
Operations, request and response shapes, error contract, compatibility with existing consumers.

### Failure handling
| Dependency or step | Failure semantics | System behavior | Recovery |
|---|---|---|---|
| <call, queue, job> | <timeout, duplicate, partial, unknown outcome> | <what we do> | <retry, reconcile, compensate, alert> |

## Alternatives considered
| Option | Pros | Cons | Why not chosen |
|---|---|---|---|
| <extend existing> | | | |
| <option B> | | | |

## Rollout and rollback
Deployment order, mixed-version safety, migration steps, and how to roll back or restore. Flags or
staged exposure only when the risk needs them, with a removal owner.

## Security and privacy (when relevant)
Authentication and authorization, data classification, abuse cases.

## Observability (when relevant)
The signals that tell us this works or is failing in production, and who acts on them.

## Test strategy
Business behaviors and failure modes to prove, and at which level each is cheapest to prove.

## Risks
| Risk | Mitigation | Owner |
|---|---|---|

## Open questions
| Question | Owner | Blocks |
|---|---|---|

## Review checklist
- [ ] <5-10 items a reviewer can verify quickly>
