---
name: sprint-retro
description: Facilitate a sprint retrospective with structured reflection, pattern identification, and actionable improvements. Triggers: "retro", "retrospective", "sprint review", "what went well", "team reflection".
argument-hint: "[sprint / iteration / project]"
disable-model-invocation: true
---

# Sprint retrospective

## What I'll do
Facilitate a structured retrospective that surfaces what worked, what didn't, and produces specific action items that actually get done.

## Inputs I'll use (ask only if missing)
- Sprint/iteration scope (what was planned vs delivered)
- Team observations (what went well, what was frustrating)
- Previous retro action items (were they completed?)
- Incidents or surprises during the sprint

## How I'll think about this
1. **Patterns over incidents**: A single bad deploy is an anecdote. Three sprints of unstable deploys is a pattern. Focus on recurring themes, not one-off events.
2. **Systems over individuals**: "Our deploy pipeline doesn't catch config errors" is actionable. "Alice broke prod" is blame. Focus on what the system allowed to happen.
3. **Action items must be SMART**: Specific, measurable, assignable, relevant, time-bound. "Improve testing" is not an action item. "Add integration tests for payment flow by next Friday, owned by Bob" is.
4. **Limit action items**: 2-3 action items that get done beats 10 that get forgotten. Focus on the highest-leverage changes.
5. **Close the loop**: Start every retro by reviewing last sprint's action items. If they weren't completed, understand why before adding new ones.

## Anti-patterns to flag
- Blame language or individual call-outs
- "We should be more careful" as an action item
- More than 5 action items (none will get done)
- Never reviewing previous action items
- Only discussing what went wrong (celebrate wins too)
- Same issues appearing retro after retro without resolution

## Quality bar
- Previous action items are reviewed with status
- Themes are identified from individual observations
- Action items are specific, owned, and time-bound
- No more than 3 action items per retro
- Both wins and improvement areas are captured
- Systemic patterns are identified over individual incidents

## Workflow context
- Typically follows: Sprint completion
- Feeds into: Next sprint planning, `/tech-debt-assessment`, process improvements
- Related: `/postmortem` (incident-specific reflection)

## Output
Fill `templates/sprint-retro.md`.

## Output contract
```yaml
produces:
  - type: "retrospective"
    format: "markdown"
    path: "claudedocs/<feature>-sprint-retro.md"
    sections: [wins, improvements, patterns, action_items]
```
