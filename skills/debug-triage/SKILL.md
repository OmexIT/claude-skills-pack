---
name: debug-triage
description: Triage a bug or production issue into a clear investigation plan: reproduction, hypotheses, logs/metrics to check, bisection strategy, and a minimal safe fix. Triggers: "bug triage", "debug this", "investigate issue", "production bug".
argument-hint: "[bug report / error message]"
effort: high
---

# Debug triage

## Inputs
- Bug report / user steps / screenshots (if any)
- Error messages or stack traces
- Environment (prod/staging/local), version, feature flags
- Recent changes (deploy, config change, migration)

## How I'll think about this
1. **Reproduce before hypothesizing**: If you can't reproduce it, you can't confirm a fix. Establish exact reproduction steps first.
2. **Correlate with recent changes**: Most bugs follow a deploy, config change, or migration. Check the timeline — what changed right before the bug appeared?
3. **Rank hypotheses by likelihood**: Start with the simplest explanation. Database issues, config errors, and missing null checks cause more bugs than race conditions.
4. **Fastest checks first**: For each hypothesis, identify the single fastest check to confirm or eliminate it. Don't build a fix until you've confirmed the root cause.
5. **Minimal safe fix**: Fix the bug with the smallest possible change. A larger refactor can follow — the priority is stopping the bleeding.
6. **Prevent recurrence**: Every fix should include a regression test and, if applicable, a monitoring improvement so the same failure is caught automatically next time.

## Anti-patterns to flag
- Guessing and deploying fixes without confirming the root cause
- "Shotgun debugging" — changing multiple things at once
- Fixing the symptom instead of the cause (e.g., catching and swallowing the exception)
- Not adding a regression test after the fix
- Not checking if the same bug exists in similar code paths

## Quality bar
- Reproduction steps are specific enough that anyone can follow them
- Hypotheses are ranked with reasoning (not just listed)
- Each hypothesis has a concrete check to confirm or eliminate it
- Fix strategy is minimal and safe, with rollback plan
- Regression test idea is included
- Rollout/verification plan confirms the fix works in production

## Workflow context
- Typically follows: `/incident-response` (during incident), bug reports
- Feeds into: `/postmortem` (if severe), `/test-plan` (regression tests)
- Related: `code-review:code-review` (review the fix)

## Output
Use `templates/triage-report.md`.

## Parallel Investigation

For complex bugs with multiple possible root causes, investigate hypotheses in parallel:

```
Phase 1: Reproduce + gather context (sequential — must confirm before investigating)
    ↓
Phase 2: Parallel hypothesis investigation (when 3+ hypotheses exist)
  ┌──────────────┬──────────────┬──────────────┐
  │ Hypothesis 1 │ Hypothesis 2 │ Hypothesis 3 │
  │ (most likely)│ (second)     │ (third)      │
  └──────┬───────┴──────┬───────┴──────┬───────┘
         └──────────────┼──────────────┘
                        ↓
Phase 3: Root cause confirmed → minimal fix (sequential)
```

- Each hypothesis investigation runs as a separate Agent call
- Use `model: sonnet` for log/code analysis, `model: opus` for complex reasoning
- First agent to confirm root cause signals others to stop (via task completion)
- Inherently sequential bugs (dependency chains) should NOT be parallelized

## Learning & Memory

After triage completes, save:
- Bug patterns specific to this project (common failure modes)
- Effective investigation techniques for this technology stack
- Root causes that were non-obvious (help future triage of similar symptoms)
- Monitoring gaps discovered that should be added

## Output contract
```yaml
produces:
  - type: "triage"
    format: "markdown"
    path: "claudedocs/<feature>-debug-triage.md"
    sections: [reproduction, hypotheses, investigation_plan, fix_strategy]
    handoff: "Write claudedocs/handoff-debug-triage-<timestamp>.yaml — suggest: postmortem, test-plan"
```
