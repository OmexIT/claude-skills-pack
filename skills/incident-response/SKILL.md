---
name: incident-response
description: Run an incident response workflow: stabilize service, gather facts, assign roles, produce status updates, and track mitigations and follow-ups. Triggers: "incident", "outage", "SEV", "production issue", "status update".
argument-hint: "[incident title]"
disable-model-invocation: true
---

# Incident response

## First priority: stabilize
- Stop the bleeding (rollback, disable feature flag, scale, rate limit)
- Confirm impact and scope
- Preserve evidence (logs, dashboards, deploy diff)

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
- Escalate to SEV-1 if: impact is growing, mitigation isn't working after 15 min, data integrity is at risk
- Escalate to leadership if: customer-facing for >30 min, data breach suspected, revenue impact confirmed
- Bring in additional teams if: root cause spans multiple services, fix requires expertise not on the call

## How I'll think about this
1. **Mitigate first, investigate second**: The goal is to stop user impact. Understanding the root cause can wait until the fire is out.
2. **Communicate early and often**: A vague update ("we're investigating") is better than silence. Stakeholders need to know you're aware.
3. **One decision-maker**: The IC makes calls. Debate slows response. Disagree after the incident is resolved.
4. **Preserve evidence before it rotates**: Logs, metrics, and deploy diffs expire. Capture them immediately.
5. **Document as you go**: Don't rely on memory for the postmortem. Keep a running timeline.

## Comms cadence
- **SEV-1**: Internal updates every 15 minutes. External updates as situation changes.
- **SEV-2**: Internal updates every 30 minutes. External updates if user-facing.
- **SEV-3/4**: Update ticket/channel when meaningful progress occurs.

## Quality bar
- Severity is assessed and communicated within first 10 minutes
- Roles are assigned (not assumed)
- Status updates follow a consistent format (use template)
- Running list of hypotheses, mitigations tried, and outcomes is maintained
- Next steps are always clear — never end an update with "still investigating" without saying what specifically is being investigated next

## Workflow context
- Typically follows: Alerts, user reports, monitoring dashboards
- Feeds into: `/postmortem`, `/debug-triage`
- Related: `/runbook` (operational procedures), `/monitoring-plan` (alert configuration)

## Output
Use `templates/incident-update.md` for updates, and keep a running list of:
- hypotheses
- mitigations tried
- current status
- next steps
