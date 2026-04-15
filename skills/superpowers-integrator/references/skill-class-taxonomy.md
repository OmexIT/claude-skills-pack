# Skill Class Taxonomy

**Single source of truth** for how custom skills integrate with superpowers. This file defines the skill classes, the superpowers workflow that fits each class, and the heuristics used to classify a skill.

When superpowers ships a new skill, the user's learned a better pattern, or a new class of domain skill emerges, edit this file AND `templates/blocks.md` AND `references/integration-checklist.md`, then re-run `/superpowers-integrator skills/*/` to propagate the change across the entire pack.

---

## Classes

### 1. code-generator

**What it does**: creates new code files (Java, TS, Python, Go, etc.) from a spec or short prompt.

**Example skills in this pack**: `temporal-workflow`, `api-first`

**Superpowers workflow**:

| Phase | Superpowers skill | Required |
|---|---|---|
| Pre-1 | superpowers:brainstorming | Recommended |
| Pre-2 | superpowers:writing-plans | Mandatory (multi-file output) |
| Pre-3 | superpowers:using-git-worktrees | Mandatory (isolation) |
| Pre-4 | superpowers:test-driven-development | MANDATORY |
| Exec  | (invoke target skill) | — |
| Exec+ | superpowers:subagent-driven-development OR superpowers:dispatching-parallel-agents | Optional |
| Post-1 | superpowers:verification-before-completion | MANDATORY |
| Post-2 | superpowers:requesting-code-review | MANDATORY |

**Detection heuristics**:
- Output contract `produces:` includes code file types (`.java`, `.ts`, `.tsx`, `.py`, `.go`, `.kt`)
- Description uses: "generate", "scaffold", "create", "build", "implement"
- Does NOT match a more specific class (money-critical, sql, reviewer, etc.)

---

### 2. code-generator-money-critical

**What it does**: creates money-moving code — ledgers, payment flows, wallets, settlement, escrow, FX conversion, reconciliation.

**Example skills in this pack**: `fintech-ledger`

**Superpowers workflow**: same steps as `code-generator` BUT every step is **non-negotiable**. The skill should refuse to proceed if the user tries to skip brainstorming or TDD. Additional rigor:

- Brainstorming must explicitly cover: balance invariants, compensation paths, FX snapshots, idempotency keys, lock ordering
- TDD must produce Testcontainers integration tests asserting balance invariants BEFORE any service code
- Verification must run the reconciliation query and paste actual zero-delta output
- Code review is non-negotiable — no direct merges

**Detection heuristics**:
- Name contains: `ledger`, `payment`, `wallet`, `settlement`, `saga`, `escrow`, `balance`, `money`
- Description mentions: `BigDecimal`, `double-entry`, `reconciliation`, `pgledger`, `blnk`, `idempotency key`, `posting`, `debit credit`
- Fintech domain context: Kifiya, Onbilia, PayserFlow

---

### 3. code-generator-sql

**What it does**: creates SQL migrations, schema changes, DDL, backfill scripts.

**Example skills in this pack**: `db-migration`

**Superpowers workflow**:

| Phase | Superpowers skill | Required |
|---|---|---|
| Pre-1 | superpowers:brainstorming | Recommended for destructive ops |
| Pre-2 | superpowers:writing-plans | Mandatory for multi-phase migrations |
| Pre-3 | superpowers:using-git-worktrees | Optional |
| Pre-4 | **Write verification SQL first** (replaces TDD) | Mandatory |
| Exec | (invoke target skill) sequential only | — |
| Post-1 | superpowers:verification-before-completion | MANDATORY — must run migration + test rollback |
| Post-2 | superpowers:requesting-code-review | MANDATORY for schema changes |

**Detection heuristics**:
- Name contains: `migration`, `schema`, `changelog`, `liquibase`, `flyway`, `ddl`
- Output contract produces `.sql` files
- Description mentions: migration, rollback, `CONCURRENTLY`, `NOT VALID`, liquibase, flyway

**Special rule**: destructive operations (`DROP TABLE`, `DROP COLUMN`, column renames) require explicit user confirmation. The skill must refuse if confirmation is bypassed.

---

### 4. reviewer

**What it does**: produces findings/audit reports against existing code. Read-only, never generates fixes inline.

**Example skills in this pack**: `arch-review`, `code-audit`, `security-review`, `performance-review`, `ux-review`, `docs-review`, `metrics-review`, `evidence-review`

**Superpowers workflow**:

| Phase | Superpowers skill | Required |
|---|---|---|
| Pre    | (none — reviewers can be invoked directly) | — |
| Exec   | (invoke target skill) produces findings | — |
| Post-1 | superpowers:systematic-debugging (per finding) | MANDATORY for CRITICAL/HIGH |
| Post-2 | superpowers:writing-plans (remediation plan) | Recommended |
| Post-3 | Chain to a code-generator skill for fixes | — |
| Post-4 | superpowers:requesting-code-review (after fixes) | MANDATORY |
| Post-5 | superpowers:finishing-a-development-branch | Optional |

**Detection heuristics**:
- Description uses: "review", "audit", "analyze", "findings", "evaluate"
- Output contract produces markdown findings/reports (NOT code file paths)
- Name contains: `review`, `audit`, `analysis`, `check`

**Hard rule**: reviewer-class skills NEVER produce inline fixes. They produce findings. Fixes happen in a separate pass through a code-generator skill.

---

### 5. refactor

**What it does**: modifies existing code without adding new features (extract, inline, rename, restructure).

**Example skills in this pack**: (none yet)

**Superpowers workflow**:

| Phase | Superpowers skill | Required |
|---|---|---|
| Pre-1 | superpowers:brainstorming | MANDATORY (why refactor? what's the risk?) |
| Pre-2 | superpowers:writing-plans | Mandatory |
| Pre-3 | superpowers:test-driven-development | MANDATORY — characterization tests FIRST |
| Pre-4 | superpowers:using-git-worktrees | Mandatory |
| Exec  | (invoke target skill) | — |
| Post-1 | superpowers:verification-before-completion | MANDATORY — characterization tests still pass |
| Post-2 | superpowers:requesting-code-review | MANDATORY |

**Detection heuristics**:
- Description uses: "refactor", "restructure", "clean up", "extract", "inline", "rename"
- Modifies existing files only, creates few/no new ones

---

### 6. debugger

**What it does**: diagnoses issues, reproduces bugs, identifies root cause, proposes fixes.

**Example skills in this pack**: `debug-triage`

**Superpowers workflow**:

| Phase | Superpowers skill | Required |
|---|---|---|
| Pre-1 | superpowers:systematic-debugging | MANDATORY — primary workflow |
| Pre-2 | superpowers:test-driven-development | MANDATORY — regression test FIRST |
| Exec | (invoke target skill) against root cause | — |
| Post-1 | superpowers:verification-before-completion | MANDATORY — both regression test passes AND original bug no longer reproduces |
| Post-2 | superpowers:requesting-code-review | Recommended |

**Detection heuristics**:
- Name contains: `debug`, `triage`, `root-cause`, `bisect`
- Description uses: "debug", "diagnose", "reproduction", "bisection", "root cause"

---

### 7. planner

**What it does**: produces docs, plans, designs, RFCs, ADRs — no code.

**Example skills in this pack**: `prd`, `design-doc`, `adr`, `user-flow`, `flow-map`, `api-design`, `data-design`, `infra-design`, `search-design`, `ticket-breakdown`, `experiment-design`, `decision-matrix`, `migration-plan`, `onboarding-doc`, `runbook`, `test-plan`, `spec-panel`, `linkedin-post`, `stakeholder-update`, `sprint-retro`, `postmortem`, `release-notes`, `incident-response`, `monitoring-plan`, `tech-debt-assessment`, `mobile-dev`, `go-to-market`, `opportunity-assessment`, `competitive-analysis`, `onboarding-doc`

**Superpowers workflow**:

| Phase | Superpowers skill | Required |
|---|---|---|
| Pre-1 | superpowers:brainstorming | MANDATORY for creative work |
| Pre-2 | superpowers:writing-plans | Optional (if document is itself a plan) |
| Exec | (invoke target skill) | — |
| Post | superpowers:verification-before-completion (quality gate) | Recommended |

**Detection heuristics**:
- Output contract produces only markdown/yaml/structured docs
- No code file paths in `produces:`
- Name often contains: `prd`, `plan`, `doc`, `design`, `adr`, `rfc`, `update`, `retro`, `post`, `review` (when it's a structured doc not a code review)

**NOT used**: `superpowers:test-driven-development`, `superpowers:using-git-worktrees`, `superpowers:requesting-code-review`. Including these in a planner-class skill is an anti-pattern — flag it in the audit.

---

## Meta-Class: integrator

The `superpowers-integrator` skill itself is a meta-class. It reads other skills and produces upgrades. It does NOT need a "Before You Start" block because it IS the skill that adds those blocks. Exclude it from audit runs (`--exclude superpowers-integrator`).

---

## How to Add a New Class

1. Identify the pattern: multiple skills share the same superpowers workflow variation that doesn't fit an existing class
2. Add a new section to this file (above): name, purpose, example skills, workflow table, detection heuristics, hard rules
3. Add a matching block template to `templates/blocks.md`
4. Add class-specific checks to `references/integration-checklist.md`
5. Re-run `/superpowers-integrator skills/*/ --audit-only` to identify which skills now classify into the new class
6. Review and apply upgrades

## How to Update an Existing Class

1. Edit this file (the table and detection heuristics)
2. Edit `templates/blocks.md` (the rendered block)
3. Edit `references/integration-checklist.md` (the audit checks)
4. Re-run `/superpowers-integrator skills/*/ --audit-only` to see which skills now fail the audit
5. Apply upgrades
