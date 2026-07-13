---
name: debug
description: >
  Use when investigating any bug, error, crash, stack trace, failing or flaky test, incident,
  regression, unexpected behavior, or "why is this happening" question - before
  proposing or applying a fix.
---

# Debugging

Discipline (rigid - do not skip steps):

1. **Reproduce first.** A bug you can't reproduce is a bug you can't verify fixed. Capture the exact failing command, request, or input.
2. **Fast checks** before deep dives: feature-flag state, recent deploy / config change / migration, log signature around the failure window, working-vs-failing account or tenant diff.
3. **Hypotheses**: form 2–3, rank by likelihood, test the cheapest-to-falsify first. Read the actual code path - never patch from symptom pattern-matching.
4. **Bisect** when history matters (`git bisect`, or toggling recent changes).
5. **Minimal fix at the root cause** - not where the symptom surfaced. No drive-by refactors in the fix commit. Strip any instrumentation added during the investigation (temporary logging, prints, debug flags) before committing.
6. **Regression test** that fails without the fix and passes with it.
7. **Three failed fixes = stop.** Write down what is known/unknown and re-question the diagnosis - the bug is in your model of the system.

When the user asked "why is this happening" rather than "fix it", or when another skill (e.g. `e2e`) routed the failure here for diagnosis: the diagnosis is the deliverable. Report findings and hand the fix to `build`.
