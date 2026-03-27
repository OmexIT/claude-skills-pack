---
name: adr
description: Write an Architecture Decision Record (ADR) capturing context, decision, alternatives, and consequences. Triggers: "ADR", "decision record", "why did we choose", "architecture decision".
argument-hint: "[decision title]"
effort: high
---

# ADR (Architecture Decision Record)

## What I'll do
Capture an architectural decision so future readers understand *why* the choice was made, what alternatives existed, and what trade-offs were accepted.

## When to write an ADR
- Choosing between frameworks, libraries, or infrastructure
- Changing a data model, API contract, or system boundary
- Adopting or abandoning a pattern (monolith → microservices, REST → GraphQL)
- Any decision that would be hard to reverse and that a new team member would ask "why?"

## How I'll think about this
1. **Context over conclusion**: Spend more time explaining the forces at play (constraints, requirements, team capabilities, timeline) than the decision itself.
2. **Evaluate alternatives honestly**: Each alternative should have real pros — not straw-man options designed to make the chosen one look good.
3. **Name the trade-offs**: Every decision has costs. State them explicitly so future readers can re-evaluate if circumstances change.
4. **Keep it short**: An ADR is a decision record, not a design doc. If it exceeds 2 pages, consider splitting out the detailed analysis.

## Anti-patterns to flag
- Writing an ADR *after* implementation just to check a box (context is already lost)
- Only one alternative listed (signals the decision wasn't actually evaluated)
- Vague consequences ("this might cause issues later")
- Missing links to related ADRs or design docs

## Quality bar
- A new team member can read this in 5 minutes and understand why the decision was made
- Alternatives have genuine pros, not just cons
- Consequences are concrete and specific
- Status field is set correctly (Proposed / Accepted / Superseded)
- Links to related ADRs or design docs if they exist

## Workflow context
- Typically follows: `/design-doc` (for decisions surfaced during design)
- Feeds into: `/design-doc` (as referenced context), `/ticket-breakdown`
- Related: `/opportunity-assessment` (strategic decisions)

## Output
Create an ADR using `templates/adr.md`. Keep it short and specific.

## Learning & Memory

After ADR creation completes, save:
- Decision patterns that recur across the codebase (technology choices, architectural styles, integration approaches)
- Alternatives considered and why they were rejected, for reuse in future similar decisions
- Context that informed the decision (constraints, team capabilities, timelines) to detect when circumstances change enough to revisit

## Output contract
```yaml
produces:
  - type: "adr"
    format: "markdown"
    path: "claudedocs/<feature>-adr.md"
    sections: [context, decision, alternatives, consequences]
    handoff: "Write claudedocs/handoff-adr-<timestamp>.yaml — suggest: design-doc"
```
