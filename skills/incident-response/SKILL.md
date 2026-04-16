---
name: incident-response
description: "Run an incident response workflow — stabilize service, gather facts, assign roles, produce status updates, and track mitigations and follow-ups. Use when handling an incident, outage, SEV, production issue, or status update."
argument-hint: "[incident title]"
disable-model-invocation: true
---

# Incident response

## First priority: stabilize

1. Stop the bleeding (rollback, disable feature flag, scale, rate limit)
2. Confirm impact and scope
3. Preserve evidence (logs, dashboards, deploy diff)

**Validation checkpoint:** Confirm mitigation is working by verifying the primary symptom (error rate, latency, or availability metric) has returned to baseline or is trending toward it before moving to the investigation phase.

## Severity definitions

- **SEV-1**: Service down or major data loss. All hands. External communication required.
- **SEV-2**: Significant degradation affecting many users. Dedicated response team.
- **SEV-3**: Partial impact, workaround exists. Normal priority response.
- **SEV-4**: Minor issue, low impact. Track and fix in normal workflow.

## Roles (suggest if not assigned)

- **Incident commander (IC)**: Owns the timeline, coordinates actions, makes decisions
- **Comms lead**: Writes status updates, communicates with stakeholders and customers
- **Tech lead / subject-matter owner**: Investigates root cause, implements mitigations

## Escalation criteria

- Escalate to SEV-1 if: impact is growing, mitigation is not working after 15 min, data integrity is at risk
- Escalate to leadership if: customer-facing for >30 min, data breach suspected, revenue impact confirmed
- Bring in additional teams if: root cause spans multiple services, fix requires expertise not on the call

## Key principles

- **Mitigate first, investigate second.** Stop user impact before chasing root cause.
- **One decision-maker.** The IC makes calls during the incident. Debate happens in the postmortem.

## Comms cadence

- **SEV-1**: Internal updates every 15 minutes. External updates as situation changes.
- **SEV-2**: Internal updates every 30 minutes. External updates if user-facing.
- **SEV-3/4**: Update ticket/channel when meaningful progress occurs.

## Quality bar

- Severity is assessed and communicated within first 10 minutes
- Roles are assigned (not assumed)
- Status updates follow the incident update format shown below
- Running list of hypotheses, mitigations tried, and outcomes is maintained
- Next steps are always specific — never end an update with "still investigating" without stating exactly what is being investigated next

**Validation checkpoint:** Before declaring an incident resolved, confirm all of the following: (1) primary metrics are at pre-incident baseline for at least 10 minutes, (2) no related alerts are firing, (3) a postmortem owner and date are assigned.

## Workflow context

- Typically follows: Alerts, user reports, monitoring dashboards
- Feeds into: `/postmortem`, `/debug-triage`
- Related: `/runbook` (operational procedures), `/monitoring-plan` (alert configuration)

## Output

Keep a running list of:
- hypotheses
- mitigations tried
- current status
- next steps

Use the following format for all status updates:

```markdown
# Incident update: <title>

**Severity:** SEV-?
**Status:** Investigating | Identified | Monitoring | Resolved
**Start time:** <time>
**Owner/IC:** <name>

## Customer impact
- Who is affected: <user segment, region, or percentage>
- What is broken: <specific failure the user sees>
- Workaround (if any): <steps users can take>

## What we know
- Symptoms: <observable behavior>
- Error messages: <exact error text or codes>
- Affected services/regions: <list>

## What we've done
- Mitigations attempted: <action taken>
- Results: <outcome of each action>

## Current hypothesis
- <your best current theory for root cause>

## Next steps (ordered)
1. <specific next action with owner>
2. <follow-up action>

## Links
- Dashboard: <url>
- Logs: <url>
- Deploy/PR: <url>
```

### Example: completed incident update

```markdown
# Incident update: Checkout API 500s

**Severity:** SEV-2
**Status:** Monitoring
**Start time:** 2025-03-14 09:42 UTC
**Owner/IC:** @jchen

## Customer impact
- Who is affected: ~12% of checkout attempts in US-East
- What is broken: Checkout returns HTTP 500 after payment step
- Workaround (if any): Retry after 30 seconds usually succeeds

## What we know
- Symptoms: Spike in 500s on POST /api/checkout/complete starting 09:40 UTC
- Error messages: "connection pool exhausted" in payment-service logs
- Affected services/regions: payment-service (US-East-1)

## What we've done
- Mitigations attempted: Increased connection pool from 50 to 200, restarted payment-service pods
- Results: Error rate dropped from 12% to 0.3% after pool resize. Pod restart had no effect.

## Current hypothesis
- Deploy v2.14.3 (09:38 UTC) added a new DB query in the checkout path that holds connections 3x longer, exhausting the pool under load.

## Next steps (ordered)
1. @jchen: Verify by comparing connection hold times between v2.14.2 and v2.14.3
2. @mlee: Prepare rollback to v2.14.2 if connection pool fix does not hold under peak traffic
3. @jchen: Write postmortem draft by EOD

## Links
- Dashboard: https://grafana.internal/d/checkout-health
- Logs: https://logs.internal/payment-service?from=2025-03-14T09:30
- Deploy/PR: https://github.com/org/repo/pull/4821
```

## Output contract

```yaml
produces:
  - type: "incident-plan"
    format: "markdown"
    path: "claudedocs/<feature>-incident-response.md"
    sections: [severity, roles, stabilization, communication]
```
