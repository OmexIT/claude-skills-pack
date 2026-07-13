---
name: debug
description: >
  Use when investigating any bug, error, crash, stack trace, failing or flaky test, incident,
  regression, unexpected behavior, or "why is this happening" question - before
  proposing or applying a fix.
---

# Debugging

Discipline (rigid - do not skip steps):

1. **Establish the failure first.** Reproduce it when safe. For production-only, destructive, intermittent, or expired failures, capture a precise evidence signature and build the closest safe falsifiable proxy instead of forcing reproduction.
2. **Fast checks** before deep dives: feature-flag state, recent deploy / config change / migration, log signature around the failure window, working-vs-failing account or tenant diff.
3. **Hypotheses**: form 2–3, rank by likelihood, test the cheapest-to-falsify first. Read the actual code path - never patch from symptom pattern-matching.
4. **Bisect** when history matters and the checkout or environment can be isolated safely (`git bisect`, or toggling recent changes).
5. **Minimal fix at the root cause** - not where the symptom surfaced. No drive-by refactors in the fix commit. Strip any instrumentation added during the investigation (temporary logging, prints, debug flags) before committing.
6. **Regression test** that fails without the fix and passes with it.
7. **Three failed fixes = stop modifying and reassess.** Write down what is known and unknown, discard disproved hypotheses, and re-question the model before another change.

When the user asked "why is this happening" rather than "fix it", or when another skill (e.g. `e2e`) routed the failure here for diagnosis: the diagnosis is the deliverable. Report findings and hand the fix to `build`.
