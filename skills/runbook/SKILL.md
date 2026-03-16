---
name: runbook
description: Generate an operational runbook for a service or system covering deployment, scaling, failure recovery, and common operations. Triggers: "runbook", "operations guide", "how to deploy", "on-call guide", "playbook".
argument-hint: "[service / system]"
---

# Runbook

## What I'll do
Produce an operational runbook that an on-call engineer can follow at 3am to deploy, scale, debug, and recover the service without needing to read the source code.

## Inputs I'll use (ask only if missing)
- Service/system name and purpose
- Architecture overview (components, dependencies, data stores)
- Deployment process (CI/CD, manual steps, environments)
- Known failure modes and their symptoms
- Monitoring and alerting setup

## How I'll think about this
1. **Write for the stressed, sleep-deprived on-call engineer**: Clear steps, no ambiguity, copy-pasteable commands. If a step requires judgment, provide decision criteria.
2. **Symptoms before solutions**: Organize by "what you're seeing" (alert fired, users reporting errors, latency spike) not by "what's wrong" (database connection exhaustion). The on-call engineer knows the symptom, not the cause.
3. **Include verification at every step**: After each action, explain how to confirm it worked. "Restart the service" is incomplete — "Restart the service and verify logs show `Service started` and health check returns 200" is a runbook.
4. **Escalation paths are mandatory**: Every section should end with "if this doesn't resolve it, escalate to X." No dead ends.
5. **Keep it current or delete it**: An outdated runbook is worse than no runbook — it gives false confidence. Include a "last verified" date and review schedule.

## Anti-patterns to flag
- Steps that assume deep system knowledge ("fix the replication lag")
- Missing escalation paths (what if the runbook doesn't solve it?)
- Commands without explanation (copy-paste without understanding is dangerous)
- No verification steps after actions
- Stale information without review dates

## Quality bar
- An engineer unfamiliar with the service can follow every procedure
- Every action has a verification step
- Every section has an escalation path
- Commands are copy-pasteable with realistic values
- Common failure modes are covered with symptom-based lookup
- Last verified date is included; review cadence is set

## Workflow context
- Typically follows: Service deployment, `/design-doc`
- Feeds into: `/incident-response` (referenced during incidents), `/postmortem` (runbook gaps identified)
- Related: `/monitoring-plan` (alerting that triggers runbook procedures)

## Output
Fill `templates/runbook.md`.

## Output contract
```yaml
produces:
  - type: "runbook"
    format: "markdown"
    path: "claudedocs/<feature>-runbook.md"
    sections: [deployment, scaling, failure_recovery, common_operations]
```
