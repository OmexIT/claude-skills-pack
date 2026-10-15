---
name: adr
description: "Use when the user wants to record an architecture decision, write an ADR or decision record, or explain why a technology, data model, boundary, or pattern was chosen over alternatives."
---

# ADR (Architecture Decision Record)

An ADR records one decision that is hard to reverse, so a later reader understands why it was made and when to revisit it. It records a choice; it does not run the comparison (`decision-matrix`) or design the system (`design-doc`).

Write one for: choosing a framework, library, or infrastructure; changing a data model, API contract, or system boundary; adopting or abandoning a pattern; any choice a new team member would ask "why?" about.

## Steps
1. Find the repo's ADR home and format (`docs/adr/`, `docs/decisions/`, numbered files) and match it, including numbering. Otherwise use `assets/adr.md`.
2. Check for an earlier ADR on the same subject. If this decision replaces it, set the old one to "Superseded by ADR-NNN" instead of editing its content.
3. Write it in under two pages. Detailed analysis belongs in a linked `decision-matrix` or `design-doc`.

## Rules
- Context gets the most words: the forces, constraints, and requirements that made this a decision.
- Each alternative has real pros, not only cons. One listed option means the decision was not evaluated; say so or ask.
- Consequences are concrete, including the costs accepted and what would trigger a revisit.
- Status is Proposed until the owner accepts it. Do not mark a decision Accepted on the user's behalf.

## Workflow context
- `decision-matrix` compares options; `adr` records the outcome; `design-doc` holds the full design.
- Usually follows `design-doc` or `decision-matrix`; feeds `design-doc` and `ticket-breakdown` as cited context.

## Output contract
```yaml
produces:
  - type: "adr"
    format: "markdown"
    path: "claudedocs/<feature>-adr.md"
    sections: [context, decision, alternatives, consequences]
    handoff: "Write claudedocs/handoff-adr-<timestamp>.yaml - suggest: design-doc"
```
