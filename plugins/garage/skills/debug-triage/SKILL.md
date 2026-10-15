---
name: debug-triage
description: "Use when something is broken and the cause is not yet established: a bug report, a pasted stack trace or error log, a failing or flaky test, a crash, hang, or regression, \"X is not working\", or \"why is this happening\", before any fix is proposed."
---

# Debug triage

> Delegation, model labels, and task tracking below use Claude Code notation. In Codex or another client, follow `../../references/cross-client.md`.

Cause already established (applying a reviewed finding, a fix the user has diagnosed)? Implement it
directly; this skill is for finding the cause.

## Inputs
Bug report or steps, error messages and stack traces, environment (prod/staging/local), version and
flag state, recent deploys, config changes, or migrations.

## Steps (do not skip)
1. **Establish the failure first.** Reproduce it when safe and record exact steps. For production-only,
   destructive, intermittent, or expired failures, capture a precise evidence signature (error,
   timestamps, IDs, affected tenants) and build the closest safe falsifiable proxy (a failing test,
   a replayed request against local) instead of forcing reproduction in production.
2. **Fast checks** before deep dives: flag state, recent deploy, config change, or migration, the log
   signature around the failure window, a working-versus-failing account or data diff.
3. **Hypotheses**: two or three, ranked with reasoning, each with the cheapest check that confirms
   or kills it. Read the actual code path; never patch from symptom pattern-matching.
4. **Bisect** when history matters and the checkout or environment can be isolated safely
   (`git bisect`, toggling recent changes).
5. **Root cause before fix.** No code fix until a hypothesis is confirmed by evidence. During an active
   incident, mitigation (rollback, flag off) may come first; that belongs to `incident-response` and
   does not replace finding the cause.
6. **Minimal fix at the root cause**, not where the symptom surfaced. One change at a time, no
   drive-by refactors, and strip temporary logging or debug flags before committing. Check whether the
   same defect exists in sibling code paths.
7. **Regression test** that fails without the fix and passes with it.
8. **Three failed fixes: stop changing code.** Write down what is known and unknown, discard disproved
   hypotheses, and re-question the model of the system before another change.

When the user asked "why" rather than "fix it", or another skill (for example `verify-impl`) routed the
failure here, the diagnosis is the deliverable: report it and let the user choose the fix.

Money and data bugs: confirm whether bad writes already happened (wrong balances, duplicate
postings). A code fix does not repair data; list affected records and propose a reviewed correction
with a restore path, and never rewrite data without explicit confirmation.

## Parallel hypotheses
Investigate inline by default. Only when three or more independent hypotheses each need substantial
log or code reading, run one agent per hypothesis and stop the others once one is confirmed.
Dependent hypotheses (B only matters if A is true) stay sequential.

## Output
Fill `assets/triage-report.md`.

## Workflow context
- `incident-response` handles an active outage (mitigate first); this skill finds the cause; `postmortem` reviews after resolution.
- Receives failures from `verify-impl`; feeds regression cases to `test-plan` and severe cases to `postmortem`.

## Output contract
```yaml
produces:
  - type: "triage"
    format: "markdown"
    path: "claudedocs/<feature>-debug-triage.md"
    sections: [reproduction, hypotheses, investigation_plan, fix_strategy]
    handoff: "Write claudedocs/handoff-debug-triage-<timestamp>.yaml - suggest: postmortem, test-plan"
```
