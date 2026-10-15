---
name: postmortem
description: "Use only when the user explicitly asks for a postmortem, RCA, or incident review after an incident is resolved."
---

# Postmortem (blameless)

## Inputs
- Incident start and end time, and the incident log from `incident-response` if one exists
- Customer impact (who, how, how long)
- Symptoms, mitigation steps, and links to dashboards, logs, deploys

## Rules
1. **Systems, not people**: "the deploy process allowed an untested config change", not a name.
2. **Causes beyond the trigger**: ask why the system allowed it, why it was not caught, why it was not
   detected sooner. Record contributing factors separately from root causes.
3. **Precise timeline**: minute-level, in UTC, each entry with its source (log, deploy, alert, chat).
   Mark when impact started, when it was detected, when mitigated, and when resolved.
4. **Money and data incidents**: state which records or transactions were affected, how they were
   reconciled or corrected, and whether any remain open.
5. **Action items are specific, owned, dated, and verifiable**: "add a burn-rate page on checkout
   errors, owner Platform, due <date>, verified by a test alert". "Be more careful" is not an action.
6. **Near misses count**: record what almost went wrong.

## Anti-patterns to flag
- Blame language; a single root cause when contributing factors exist
- Action items without owner, date, or verification method
- No detection or response gap analysis

## Output
Fill `assets/postmortem.md`.

## Workflow context
- Follows `incident-response` once the incident is resolved; `debug-triage` supplies the investigation detail.
- Action items feed `monitoring-plan`, `runbook`, and `test-plan`.

## Output contract
```yaml
produces:
  - type: "postmortem"
    format: "markdown"
    path: "claudedocs/<feature>-postmortem.md"
    sections: [timeline, root_causes, contributing_factors, action_items]
```
