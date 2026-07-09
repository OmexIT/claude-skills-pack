# Ops quick tables - incidents, postmortems, runbooks

Reference knowledge (not a skill - read when production is on fire or when writing ops docs).

## Severity & comms

| SEV | Meaning | Response | Internal updates |
|---|---|---|---|
| 1 | Service down or data loss | All hands; external comms required | every 15 min |
| 2 | Major degradation, many users | Dedicated response team | every 30 min |
| 3 | Partial impact, workaround exists | Normal priority | on progress |
| 4 | Minor | Normal workflow | ticket |

Escalate to SEV-1 when impact is growing, mitigation hasn't worked after 15 min, or data
integrity is at risk. Escalate to leadership when customer-facing >30 min, breach suspected,
or revenue impact confirmed.

## Incident discipline
- Mitigate first (rollback, flag off, scale, rate-limit), investigate second.
- One incident commander makes calls; debate after resolution.
- Preserve evidence before it rotates: logs, dashboards, deploy diff.
- Keep a running timeline plus hypotheses/mitigations list as you go.
- Never end an update with "still investigating" without naming what is being checked next.

## Postmortem (blameless)
- Systems language, not names: "the deploy process allowed an untested config change".
- Multiple contributing causes; minute-level timeline with sources; detection-gap analysis
  ("how should this have been caught earlier?"). Near-misses count.
- Action items must be specific, owned, time-bound, verifiable. "Improve monitoring" and
  "be more careful" are not action items.

## Runbook rules
- Organize by symptom ("error rate alert fired"), not cause ("connection exhaustion").
- Every action has a verification step ("restart, then confirm health returns 200").
- Every section ends with an escalation path - no dead ends.
- Copy-pasteable commands with realistic values; "last verified" date or delete the runbook.
