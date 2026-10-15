---
name: stakeholder-update
description: "Use only when the user explicitly asks for a stakeholder, exec, investor, or weekly status update covering progress, risks, and decisions needed."
---

# Stakeholder update

A short status update a busy reader can act on after the first three lines: where things stand, what you need from them, and what could go wrong.

Ask only what is missing: the project, the audience (leadership, partner teams, investors, board), the period, and the facts (progress, risks, blockers, decisions needed). Pull facts from tickets, PRs, or notes the user points to; never invent numbers or dates.

## Rules
- Open with status (on track, at risk, or blocked), one sentence on why, and the ask if there is one.
- Asks are explicit: the decision or help needed, from whom, and by when. Never bury them below progress.
- Progress is concrete: what shipped, what moved, against what was planned. Use numbers where they exist.
- Every risk comes with what is being done about it. Include bad news; an all-green update loses trust.
- Write in plain language for product, finance, and leadership readers. No engineering jargon, ticket keys, or internal shorthand unless the audience uses them. Sound like a person writing to colleagues, not a form being filled in: no labels like "Action required" or "What I need from each team".
- Fit on one screen. If the user has a previous update, keep its structure so readers know where to look.

## Workflow context
- `stakeholder-update` reports progress outward; `sprint-retro` is the team's own reflection; `go-to-market` plans a launch.

## Output
Fill `assets/stakeholder-update.md`, dropping empty sections.

## Output contract
```yaml
produces:
  - type: "status-update"
    format: "markdown"
    path: "claudedocs/<feature>-stakeholder-update.md"
    sections: [progress, blockers, decisions_needed, next_steps]
```
