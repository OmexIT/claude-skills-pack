---
name: ticket-breakdown
description: Break a PRD or design doc into epics and engineering tickets with acceptance criteria, dependencies, sequencing, and rollout steps. Triggers: "break this into tickets", "work breakdown", "engineering plan", "Jira tickets", "Linear issues".
argument-hint: "[PRD / design doc link or text]"
---

# Ticket breakdown

## Goal
Turn a spec into implementable work items that can be assigned, tracked, and shipped safely.

## What I'll do
- Identify the critical path
- Split work into thin, shippable slices
- Add acceptance criteria and test notes per ticket
- Call out dependencies and risks
- Provide a suggested rollout sequence

## How I'll think about this
1. **Slice vertically, not horizontally**: Each ticket should deliver a thin end-to-end slice of value (API + UI + test), not a horizontal layer ("build all the APIs, then all the UI").
2. **Size for 1-3 days**: If a ticket takes longer than 3 days, it should be split. Large tickets hide risk and block code review.
3. **Identify unknowns early**: Create spike/investigation tickets for areas with high uncertainty. Don't estimate what you don't understand — explore first.
4. **Sequence for risk reduction**: Ship the riskiest or most uncertain work first. Get feedback early, not after building everything.
5. **Include the boring stuff**: Migration tickets, feature flag cleanup, monitoring setup, documentation — these are real work that needs tracking.
6. **Definition of ready**: Each ticket should have enough context that any team member could pick it up without a 30-minute conversation.

## Anti-patterns to flag
- Mega-tickets that bundle 5+ days of unrelated work
- Missing acceptance criteria ("implement feature X" with no definition of done)
- Horizontal slicing ("backend sprint" then "frontend sprint")
- Forgetting cleanup tickets (remove feature flags, delete old code paths)
- No spike tickets for genuinely unknown technical areas

## Quality bar
- Every ticket has: clear title, acceptance criteria, test notes, and size estimate
- No ticket exceeds 3 days of estimated work
- Dependencies between tickets are explicit
- Critical path is identified and sequenced
- Spike tickets exist for areas with high uncertainty
- Rollout sequence accounts for feature flags and staged release

## Workflow context
- Typically follows: `/prd`, `/design-doc`
- Feeds into: `/test-plan`, `/pr-review`
- Related: `/experiment-design` (rollout sequencing)

## Output
Use `templates/ticket-breakdown.md`.
