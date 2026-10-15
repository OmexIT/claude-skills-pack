---
name: incident-response
description: "Use only when the user explicitly asks to run or coordinate incident response for an active outage, SEV, or production incident that is still affecting users."
---

# Incident response

If the organization or repo has its own incident process and severity scale, follow it; the
defaults below fill gaps.

## First priority: stabilize
- Stop user impact with the least risky reversible lever: roll back, turn off the flag, scale, rate
  limit, fail over. Investigating the cause waits.
- Money flows: pause the affected money movement rather than retrying blindly; reconcile before
  re-enabling, and treat unknown outcomes as unknown, not failed.
- Irreversible mitigations (data fixes, deleting queues, forced failover with data loss) need the
  IC's explicit decision and a stated restore path.
- Preserve evidence before it rotates: logs, dashboards, deploy diff, timestamps.

## Severity (default scale)
- **SEV-1**: service down, major data loss or integrity risk, or money moving incorrectly. All hands;
  external comms.
- **SEV-2**: significant degradation for many users. Dedicated responders.
- **SEV-3**: partial impact with a workaround. Normal priority.
- **SEV-4**: minor; track in the normal workflow.

Raise severity when impact grows, mitigation has not worked after about 15 minutes, data integrity is
at risk, or a breach is suspected. Bring in another team when the cause spans its services.

## Roles (suggest if not assigned)
- **Incident commander**: owns decisions and the timeline; one decision-maker.
- **Comms lead**: status updates to stakeholders and customers.
- **Tech lead**: investigates and applies mitigations.

## Comms cadence
- SEV-1: internal every 15 minutes, external as the situation changes.
- SEV-2: internal every 30 minutes, external if user-facing.
- SEV-3/4: update the ticket or channel on meaningful progress.

Every update says what is being done next and when the next update comes; never "still investigating"
alone.

## Output
Use `assets/incident-update.md` for each update, and keep a running, timestamped log (UTC) of
hypotheses, mitigations tried and their outcomes, current status, and next steps. That log becomes
the `postmortem` timeline.

## Workflow context
- This skill runs the live incident; `postmortem` reviews it after resolution; `debug-triage` finds the root cause once impact is contained.
- Uses `runbook` procedures and `monitoring-plan` signals.

## Output contract
```yaml
produces:
  - type: "incident-plan"
    format: "markdown"
    path: "claudedocs/<feature>-incident-response.md"
    sections: [severity, roles, stabilization, communication]
```
