---
name: sprint-retro
description: "Use only when the user explicitly asks to run a sprint retrospective or team reflection on what went well and what to change."
---

# Sprint retrospective

Turn a sprint's observations into at most three changes the team will actually make.

Ask only what is missing: planned versus delivered, the team's observations, incidents or unplanned work, and the previous retro's action items.

## Rules
- Start with last retro's action items and their status. If one was not done, find out why before adding new ones; a repeat item needs a different approach, not a new deadline.
- Group observations into themes and look for patterns across sprints; a one-off is noted, a recurring problem gets the time.
- Describe what the process or system allowed, never who is to blame. Rewrite personal call-outs in neutral terms.
- Capture what went well too, and what made it work, so it is kept on purpose.
- At most three action items. Each one is specific, has one owner and a date, and says how the team will know it worked. "Be more careful" or "improve testing" is not an action item.

## Workflow context
- `sprint-retro` reviews how the team worked; `postmortem` reviews a specific incident; `stakeholder-update` reports outward.
- Recurring technical themes can feed `tech-debt-assessment`.

## Output
Fill `assets/sprint-retro.md`.

## Output contract
```yaml
produces:
  - type: "retrospective"
    format: "markdown"
    path: "claudedocs/<feature>-sprint-retro.md"
    sections: [wins, improvements, patterns, action_items]
```
