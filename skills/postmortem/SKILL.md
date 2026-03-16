---
name: postmortem
description: Produce a blameless incident postmortem: timeline, customer impact, root causes, contributing factors, detection gaps, and prioritized action items. Triggers: "postmortem", "RCA", "incident review".
argument-hint: "[incident title]"
disable-model-invocation: true
---

# Postmortem (blameless)

## Inputs
- Incident start/end time
- Customer impact (who, how, how long)
- Symptoms and mitigation steps
- Links to dashboards/logs (if available)

## How I'll think about this
1. **Blameless means systems-focused**: "The deploy process allowed an untested config change" not "Alice pushed a bad config." People make mistakes; systems should catch them.
2. **Multiple root causes**: Most incidents have contributing factors, not a single root cause. Dig deeper than the proximate trigger. Why did the system allow it? Why wasn't it caught? Why wasn't it detected sooner?
3. **Timeline precision matters**: Vague timelines ("around 2pm") make it impossible to correlate events. Be precise — it reveals patterns in detection gaps and response speed.
4. **Near-misses count**: If something almost went wrong but didn't, document it. Near-misses are free lessons.
5. **Action items must be specific**: "Improve monitoring" is not an action item. "Add alert for error rate >5% on /api/payments endpoint, owned by Platform team, due March 15" is.

## Anti-patterns to flag
- Blame language ("X should have known better")
- Single root cause when contributing factors exist
- Action items without owners, due dates, or verification criteria
- "We'll be more careful next time" as a corrective action
- Missing detection/response gap analysis

## Quality bar
- Timeline has minute-level precision with source (logs, deploys, alerts)
- Root causes go beyond the proximate trigger to systemic factors
- Contributing factors are identified (what made the incident worse or harder to detect)
- Detection gap analysis: how should this have been caught earlier?
- Every action item is: specific, owned, time-bound, and has a verification method
- Lessons learned are genuine insights, not restatements of what happened

## Workflow context
- Typically follows: `/incident-response`
- Feeds into: `/monitoring-plan`, `/test-plan`, `/runbook` updates
- Related: `/debug-triage` (investigation details)

## Output
Fill `templates/postmortem.md` and ensure action items meet the quality bar above.

## Output contract
```yaml
produces:
  - type: "postmortem"
    format: "markdown"
    path: "claudedocs/<feature>-postmortem.md"
    sections: [timeline, root_causes, contributing_factors, action_items]
```
