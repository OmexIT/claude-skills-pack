---
name: runbook
description: "Use when the user wants an operational runbook, operations or on-call guide, or playbook for deploying, scaling, recovering, or operating a service."
---

# Runbook

Write procedures an on-call engineer can follow at 3am to deploy, scale, diagnose, and recover the
service without reading its source.

## Inputs (ask only if missing)
- Service name, purpose, components, dependencies, data stores
- Deployment process and environments
- Known failure modes and the alerts that fire for them (from `monitoring-plan` if it exists)
- Escalation contacts

## Rules
1. **Organize by symptom**: "error-rate page on checkout", not "connection pool exhaustion". The
   reader knows the alert, not the cause. One section per alert that pages.
2. **Copy-pasteable commands** taken from the real repo, scripts, and tooling; verify each against
   the repo rather than inventing flags. If a step needs judgment, give the decision criteria.
3. **Verify after every action**: what output, metric, or log line proves the step worked.
4. **Destructive steps** (deleting data, killing queries, restoring a backup, failover, replaying
   or reversing money movements) state the blast radius, who must approve, and how to undo or
   restore. Never a bare destructive command.
5. **Every section ends with an escalation path**: when to escalate, to whom, how.
6. **Freshness**: record a last-verified date and owner; a stale runbook gives false confidence.

## Output
Fill `assets/runbook.md`; drop sections that do not apply.

## Workflow context
- `monitoring-plan` decides what fires and why; this skill says what a human does when it fires.
- Used during `incident-response`; gaps found there come back through `postmortem` action items.
- Follows `infra-design` or `design-doc`.

## Output contract
```yaml
produces:
  - type: "runbook"
    format: "markdown"
    path: "claudedocs/<feature>-runbook.md"
    sections: [deployment, scaling, failure_recovery, common_operations]
```
