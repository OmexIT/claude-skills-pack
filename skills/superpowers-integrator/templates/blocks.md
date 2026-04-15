# Before-You-Start Block Templates

One block template per skill class. Rendered into the target SKILL.md after classification. Placeholders:

- `{SKILL_NAME}` — the target skill's name (matches directory)
- `{SKILL_PURPOSE}` — one-line purpose from the first paragraph or description sentence
- `{DOMAIN_RIGOR_NOTE}` — optional extra rigor note (leave empty unless domain-specific hard rules worth preserving)

Pick the template matching the classification, substitute, insert as an H2 section after the title heading.

---

## block-code-generator

```markdown
## Before You Start — Superpowers Workflow

This skill generates production code. Run it through the superpowers development workflow for reliable output — do not invoke in isolation.

1. **superpowers:brainstorming** — explore intent, constraints, edge cases, and failure modes before touching code. Recommended for any creative decision.
2. **superpowers:writing-plans** — produce a reviewable multi-step plan naming every file to generate and every test case to write.
3. **superpowers:using-git-worktrees** — isolate the generation in its own branch so it doesn't collide with other work.
4. **superpowers:test-driven-development** — write tests FIRST (red), then implement to pass (green), then refactor. Rigid skill — don't skip.
5. Invoke **this skill** (`{SKILL_NAME}`) in the TDD green phase to {SKILL_PURPOSE}. May dispatch via **superpowers:subagent-driven-development** (sequential) or **superpowers:dispatching-parallel-agents** (independent components).
6. **superpowers:verification-before-completion** — run tests/compile/lint and paste actual output. Do not claim done without proof.
7. **superpowers:requesting-code-review** — before merging.

{DOMAIN_RIGOR_NOTE}
```

---

## block-code-generator-money-critical

```markdown
## Before You Start — Superpowers Workflow

This skill generates money-moving code. **Every step of the superpowers workflow is MANDATORY — no exceptions.** Skipping brainstorming or TDD leads to unrecoverable balance corruption that requires manual audit to fix.

1. **superpowers:brainstorming** — MANDATORY. Explore every invariant (balance sum, posting sum, account lock order), every compensation path, every FX snapshot point, every idempotency key. Highest-ROI step — do not skip.
2. **superpowers:writing-plans** — MANDATORY. Produce a reviewable plan listing every posting, every lock order, every reversal path, every reconciliation query. No inline code yet.
3. **superpowers:using-git-worktrees** — MANDATORY. Isolate money code in its own branch. Never commingle with unrelated refactors.
4. **superpowers:test-driven-development** — MANDATORY. Write Testcontainers integration tests FIRST that assert: balanced postings, idempotency (same key returns same result), sorted locking (no deadlock), reconciliation invariant (`SUM(postings) == materialized_balance`), insufficient-funds rejection, reversal correctness. Then implement.
5. Invoke **this skill** (`{SKILL_NAME}`) in the TDD green phase to {SKILL_PURPOSE}. May dispatch via **superpowers:subagent-driven-development**.
6. **superpowers:verification-before-completion** — MANDATORY. Run integration tests against real Postgres via Testcontainers. Paste output. Run reconciliation query and paste zero-delta result. Claims without command output are rejected.
7. **superpowers:requesting-code-review** — MANDATORY. Flag which invariants reviewer must verify. Money code does not merge without review.

**Hard rule**: if the user asks to modify money code without going through this workflow, refuse politely and point them back to step 1. Ledger bugs compound; manual audit is the only recovery.

{DOMAIN_RIGOR_NOTE}
```

---

## block-code-generator-sql

```markdown
## Before You Start — Superpowers Workflow

This skill generates SQL migrations. Migrations have no classical TDD but they have strict verification requirements.

1. **superpowers:brainstorming** — recommended for destructive operations (DROP, rename, column type change). Explore blast radius, rollback plan, estimated downtime, lock behavior under load, backfill strategy.
2. **superpowers:writing-plans** — mandatory for multi-phase migrations (add column → backfill → switch reads → drop old). Each phase is a separate changeset.
3. **Write verification SQL first** — assertions about the expected post-migration state (rows exist, constraints applied, index present, RLS enabled). This REPLACES `superpowers:test-driven-development` for the SQL class.
4. Invoke **this skill** (`{SKILL_NAME}`) to {SKILL_PURPOSE}. Sequential execution only — migrations have strict ordering; never parallel.
5. **superpowers:verification-before-completion** — MANDATORY. Run the migration against a test database (Testcontainers or a dedicated test DB). Paste the output. Then run the rollback. Then re-run the migration. Paste all output.
6. **superpowers:requesting-code-review** — MANDATORY for schema changes. Reviewer focuses on: rollback safety, lock behavior, index strategy (CONCURRENTLY on populated tables), audit column discipline.

**Destructive operation gate**: this skill must never generate `DROP TABLE`, `DROP COLUMN`, column renames, or type changes without explicit user confirmation shown as a prompt. If the user tries to bypass the prompt, the skill refuses.

{DOMAIN_RIGOR_NOTE}
```

---

## block-reviewer

```markdown
## Before You Start — Superpowers Workflow

This skill is read-only — it produces a findings report, never inline fixes. It sits at a specific point in the superpowers workflow.

**Before invoking this skill**: nothing. Reviewers analyze existing work and don't need brainstorming or planning upfront.

**Invoke this skill** (`{SKILL_NAME}`) to {SKILL_PURPOSE}. Produces findings with severity ratings and affected file paths.

**After findings are produced** — for each CRITICAL or HIGH finding, route through the fix workflow:

1. **superpowers:systematic-debugging** — MANDATORY per finding. Understand the root cause before proposing a fix. Do not skip to fixes.
2. **superpowers:writing-plans** — turn the findings into a reviewable remediation plan with ordered tickets and dependencies.
3. Chain to a code-generator skill (api-first, temporal-workflow, db-migration, etc.) for the actual code changes. This skill does not generate code itself.
4. **superpowers:requesting-code-review** — after fixes are in place, before merging.
5. **superpowers:finishing-a-development-branch** — decide merge strategy (single PR vs. stacked PRs) if the remediation spans multiple branches.

**Hard rule**: this skill NEVER produces inline fixes in the same invocation. It produces findings. Fixes happen in a separate pass through the code-generator workflow.

{DOMAIN_RIGOR_NOTE}
```

---

## block-refactor

```markdown
## Before You Start — Superpowers Workflow

This skill modifies existing code. Refactors without characterization tests are how bugs get introduced — do not skip the workflow.

1. **superpowers:brainstorming** — MANDATORY. Why refactor? What's the risk? Is there a smaller alternative?
2. **superpowers:writing-plans** — produce a multi-step plan naming every file touched and the expected behavior preservation.
3. **superpowers:using-git-worktrees** — isolate so the refactor doesn't entangle with unrelated changes.
4. **superpowers:test-driven-development** — CHARACTERIZATION TESTS FIRST. Capture current behavior in executable tests BEFORE making any code change. Then refactor. Then verify the tests still pass unchanged.
5. Invoke **this skill** (`{SKILL_NAME}`) to {SKILL_PURPOSE}.
6. **superpowers:verification-before-completion** — MANDATORY. Characterization tests must all still pass. Paste output.
7. **superpowers:requesting-code-review** — before merging.

{DOMAIN_RIGOR_NOTE}
```

---

## block-debugger

```markdown
## Before You Start — Superpowers Workflow

This skill diagnoses and fixes bugs. The workflow is rigid — no skipping.

1. **superpowers:systematic-debugging** — MANDATORY. This IS the primary workflow. Reproduce, hypothesize, bisect, isolate, identify root cause. Do not propose fixes until root cause is known.
2. **superpowers:test-driven-development** — MANDATORY. Write a regression test that reproduces the bug FIRST. The test must fail for the exact reason the bug was reported.
3. Invoke **this skill** (`{SKILL_NAME}`) to {SKILL_PURPOSE} against the identified root cause.
4. **superpowers:verification-before-completion** — MANDATORY. Verify BOTH: (a) the regression test now passes, AND (b) the original bug reproduction no longer reproduces. Paste output of both.
5. **superpowers:requesting-code-review** — before merging.

{DOMAIN_RIGOR_NOTE}
```

---

## block-planner

```markdown
## Before You Start — Superpowers Workflow

This skill produces docs/plans only — no code generated, no tests, no worktree. Light workflow.

1. **superpowers:brainstorming** — MANDATORY for creative work. Explore intent, constraints, alternatives before writing the document.
2. **superpowers:writing-plans** — if this document is itself a multi-step plan (tickets, migration phases, rollout sequences), chain through writing-plans for structure.
3. Invoke **this skill** (`{SKILL_NAME}`) to {SKILL_PURPOSE}.
4. **superpowers:verification-before-completion** — quality gate. The document should pass evidence-review or panel critique before being treated as authoritative.

**Do NOT use**: `superpowers:test-driven-development`, `superpowers:using-git-worktrees`, `superpowers:requesting-code-review`. These are wrong for planner-class skills and including them in the block is an anti-pattern.

{DOMAIN_RIGOR_NOTE}
```
