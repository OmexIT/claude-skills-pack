---
name: design-doc
description: Create or review a system design doc / RFC for a feature: requirements, constraints, architecture, data model, APIs, rollout, risks, and test plan. Triggers: "design doc", "RFC", "system design", "architecture plan".
argument-hint: "[feature name]"
effort: high
---

# Design doc (RFC)

## How to use
- If you say: "Write a design doc for ___", produce a complete doc using the template in `templates/design-doc.md`.
- If you give an existing doc, review it and propose concrete improvements.

## Minimal clarifications (only if needed)
- Who is the user and what problem are we solving?
- What does success look like (1-3 measurable outcomes)?
- Key constraints (deadline, compatibility, latency, cost, compliance)?
- What's explicitly out of scope?

## How I'll think about this
1. **Requirements before architecture**: Resist jumping to solutions. Nail down what must be true before deciding how to build it.
2. **Consider alternatives seriously**: At least 2 alternatives with genuine pros/cons. Don't present one option as a foregone conclusion with straw-man alternatives.
3. **Design for failure**: Every external dependency will fail. Every network call will timeout. Design the happy path, then design what happens when each component breaks.
4. **Data model drives everything**: Get the data model right first. APIs, UX, and performance characteristics flow from how data is structured and accessed.
5. **Think about day-2 operations**: How will this be deployed? Monitored? Debugged at 3am? Rolled back? Migrated in the future?

## Anti-patterns to flag
- Presenting only one option as the obvious choice
- Missing failure mode analysis ("what if the queue backs up?")
- No migration or rollback plan
- APIs designed around implementation rather than consumer needs
- Observability as an afterthought

## Quality bar
The doc should be review-ready:
- Clear requirements and non-goals
- At least 2 alternatives considered with honest trade-offs
- Data model + APIs (or key interfaces)
- Failure modes and mitigations
- Rollout plan (feature flags, backwards compatibility, migration)
- Observability plan (logs/metrics/traces)
- Test strategy

## Workflow context
- Typically follows: `/prd`, `/adr`
- Feeds into: `/ticket-breakdown`, `/test-plan`, `/security-review`, `/performance-review`
- Related: `/api-design` (API-specific depth)

## Deliverables
1. The filled-out design doc
2. A short "Open questions" section (bullet list)
3. A "Review checklist" with 5-10 items reviewers can quickly verify

## Learning & Memory

After design doc creation completes, save:
- Architecture decisions made and the constraints that drove them
- Design tradeoffs evaluated and which factors tipped the balance
- Constraint patterns that recur across projects (latency budgets, compliance requirements, team capabilities)

## Output contract
```yaml
produces:
  - type: "design-doc"
    format: "markdown"
    path: "claudedocs/<feature>-design-doc.md"
    sections: [requirements, architecture, data_model, apis, rollout, risks]
    handoff: "Write claudedocs/handoff-design-doc-<timestamp>.yaml — suggest: spec-to-impl, test-plan, security-review"
```
