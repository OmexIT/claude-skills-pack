---
name: ticket-breakdown
description: "Use when the user wants a PRD or design doc broken into tracker-ready epics and tickets for a team to pick up: work breakdown, Jira tickets, or Linear issues, rather than implemented now."
---

# Ticket breakdown

Turn a spec into work items people can be assigned, track, and ship safely. This produces tickets for a tracker; implementing the spec now, with agent tasks and waves, is `spec-to-impl`.

## Steps
1. Read the spec and the code it touches. List assumptions you had to make; ask before guessing on anything that changes the shape of the work.
2. Find the critical path and the riskiest unknowns. Unknowns get a time-boxed spike ticket with a question to answer, not an estimate.
3. Slice vertically: each ticket delivers a thin end-to-end behavior (API, UI, and test together) that can merge on its own. Avoid "all backend, then all frontend".
4. Sequence so risky and blocking work lands first and every merged ticket leaves main releasable.
5. Include the work people forget only when the spec needs it: migrations and backfills, removal of temporary rollout code, alerts, docs.
6. Match the tracker's conventions if the user names one (title format, labels, estimate scale).

## Rules
- Each ticket: outcome-focused title, acceptance criteria tied to spec IDs where they exist, test notes, explicit dependencies, and a size. Split anything over about three days.
- A ticket is ready when someone outside the discussion could pick it up without a meeting.
- No ticket for speculative work the spec does not ask for (abstractions, flags, readiness checks).

## Workflow context
- `ticket-breakdown` writes tickets for a team; `spec-to-impl` plans and builds the code now.
- Follows `prd` or `design-doc`; feeds `test-plan` and the team's tracker.

## Output
Fill `assets/ticket-breakdown.md`.

## Output contract
```yaml
produces:
  - type: "tickets"
    format: "markdown"
    path: "claudedocs/<feature>-ticket-breakdown.md"
    sections: [epics, tickets, acceptance_criteria, dependencies, sequencing]
    handoff: "Write claudedocs/handoff-ticket-breakdown-<timestamp>.yaml - suggest: spec-to-impl"
```
