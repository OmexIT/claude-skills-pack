---
name: code-audit
description: "Use when existing implementation code needs a rigorous review: code audit, code review, code quality, code smells, SOLID or duplication concerns, security or performance of a module, production readiness, or a second opinion on code that already exists."
---

# Code Audit: Implementation Review

> Delegation, model labels, and task tracking below use Claude Code notation. In Codex or another client, follow `../../references/cross-client.md`.

Breadth review of code that already exists: 11 dimensions, evidence-backed findings, a quality
scorecard, and an improvement roadmap. Read-only: it produces findings, never inline fixes.

## When to use a neighbour instead

| Request | Skill |
|---|---|
| Spec, PRD, or RFC before implementation | `spec-panel` |
| Java/Spring boundary, dependency-direction, or transaction-scope deep dive | `arch-review` (or chain after this audit) |
| Threat model or deep auth/data-exposure review | `security-review` |
| SLO-driven latency or throughput analysis, load-test plan | `performance-review` |
| Final proof gate: does the evidence justify calling the work done | `evidence-review` |
| Prioritizing debt across a codebase by cost of delay | `tech-debt-assessment` (consumes this audit's Tier 2/3) |
| Quick correctness pass on a pending diff | `code-review:code-review` (official plugin) |

"Is this production-ready" and "does this follow our patterns" stay here.

## 0. Scope

Parse the target from the request: file paths, a directory, a feature ("the payment module"), or a
PR or branch. Ask only what the request and repo cannot answer: scope, primary concern (quality,
security, performance, architecture, all), and context (pre-merge, debt audit, incident, onboarding).

Confirm in a few lines: scope (files, approximate lines), language and framework, test files found,
recent activity, and the dimensions that will run.

## 1. Lenses and fan-out

| ID | Lens | Dimension in `references/review-dimensions.md` | Label | Runs when |
|---|---|---|---|---|
| `LEAD` | Orchestration and synthesis | all | `opus` | Always |
| `SMELL` | Code smells, SOLID | 1, 2 | `sonnet` | Always |
| `DUP` | Duplication | 3 | `sonnet` | Always |
| `ALGO` | Algorithms, data structures | 4 | `sonnet` | Always |
| `SEC` | Security breadth | 5 | `opus` | Always |
| `PERF` | Performance and reliability breadth | 6 | `sonnet` | Always |
| `PATTERN` | Design pattern fitness | 7 | `sonnet` | Module or larger |
| `ARCH` | Architecture conformance | 8 | `opus` | Module or larger |
| `TECH` | Technology and lifecycle | 9 | `sonnet` | Dependencies in scope |
| `SKEPTIC` | Challenge assumptions | 10 | `opus` | Always |
| `TESTING` | Test coverage and quality | 11 | `sonnet` | Always |

**Fan-out is conditional.** A few files or a single module: `LEAD` runs the lenses inline in one
pass. Fan out only for large scope (several modules, a full codebase): dispatch the active lenses as
parallel Agent calls in one message (`general-purpose` unless a matching reviewer type is
installed), each given the Evidence Manifest verbatim, its dimension section, only the files it
needs, and the finding format. `LEAD` waits for all of them, then synthesizes. When the user asks
specifically about Java/Spring architecture, chain to `arch-review` rather than deepening `ARCH`.

## 2. Phase 1 - Evidence gathering (gate before analysis)

Findings come from real files and real command output, not memory.

1. **Enumerate and read.** Glob the source, test, and migration files in scope. Read every in-scope
   source file up to about 50; beyond that, sample by dependency centrality and record the
   rationale. Read all in-scope tests and the shared code the target depends on.
2. **Map usage.** Grep reverse imports and instantiation sites (who calls this), API surface
   (controllers, listeners, jobs), and persistence surface (entities, tables, migrations).
3. **Git context.** `git log --oneline -30 -- <target>` and `git shortlog -sn -- <target>` for churn
   and ownership; `git blame` only on suspicious hotspots.
4. **Conventions.** Read AGENTS.md / CLAUDE.md (root and nested), build files (exact versions), lint
   and format configs, ArchUnit or Modulith tests, and ADRs. The project's conventions win over
   personal style.
5. **Prior audits.** Read `claudedocs/*-code-audit.md` for this target if present; note fixed,
   reopened, and ignored findings. Reopened findings get a severity boost.
6. **Run what is cheap and safe.** The project's test, lint, or dependency-scan commands when they
   are read-only and fast. Record command and result.
7. **Research only where it changes a finding.** When a finding depends on version-specific
   behavior, a deprecation, an advisory, or an EOL date, confirm it with context7 or the official
   source and cite the URL. Never invent URLs; an uncited claim is labelled "stack heuristic".

**Gate:** produce the Evidence Manifest (read `references/roadmap-templates.md` for the template)
before analysis. Anything that blocked evidence gathering goes under Blockers, not silently skipped.

## 3. Phase 2 - Analysis

Read `references/review-dimensions.md` before analysis. It holds the finding format, evidence
rules, severity scale, house-law checks, and the per-dimension protocols. The rules that matter
most:

- Evidence can be a code or config quote, scoped search output, test, log, trace, query plan, or a
  reproducible absence (paths and terms searched). No evidence, no finding.
- Static thresholds (method length, class size, parameter count, package metrics, dependency age)
  are investigation leads. They become findings only with verified impact.
- Resilience controls are judged from failure semantics, never by a blanket rule; a fabricated
  success fallback for a failed mutation is itself a finding.
- Include POSITIVE findings for code worth keeping.

## 4. Phases 3 to 5 - Scorecard, roadmap, report

Read `references/roadmap-templates.md` for the scorecard, findings summary, action tiers,
refactoring plan, and report header.

1. Score each dimension from the evidence (N/A with reason when it did not apply).
2. Rank and deduplicate findings by root cause; separate fix-now from later work.
3. Group into Tier 1 (CRITICAL + HIGH), Tier 2 (MEDIUM), Tier 3 (LOW); write a refactoring plan for
   each Tier 1 finding.
4. Save to `claudedocs/<target-name>-code-audit.md` with the report header and action tracker.

Tell the user where the report is and the next steps: root-cause the CRITICAL findings
(`debug-triage`), turn findings into tickets (`ticket-breakdown`), fix through the matching
implementation skill (`api-first`, `temporal-workflow`, `fintech-ledger`), review the fix, then
`finalize`.

## Gates and anti-patterns

- Findings only. A fix requested in the same pass goes through root-cause analysis, a remediation
  plan, and an implementation skill.
- A clean audit is valid when the manifest shows what was checked. Do not invent findings to look
  thorough, and do not rubber-stamp: complexity raises scrutiny.
- Severity follows impact and likelihood. One CRITICAL architectural flaw outranks fifty naming
  nits; never bikeshed style a formatter already settles.
- Recommendations are concrete ("persist the reference before retrying in
  `TransferAdapter.send():84`"), not generic ("add error handling").
- Do not flag code for skipping a pattern when the simple approach is correct.
- Every applicable dimension is evaluated or marked N/A with a reason; the Skeptic's challenges
  target load-bearing assumptions, including whether the code needs to exist.
- Each Tier 1 finding has a refactoring plan with tests and a verification step.

## Workflow context

- Upstream: any implemented code, typically after `spec-to-impl` or before `finalize`.
- Downstream: `debug-triage`, `ticket-breakdown`, implementation skills for fixes, `test-plan` for coverage gaps.
- Deep dives: `arch-review`, `security-review`, `performance-review`; debt prioritization: `tech-debt-assessment`.

## Output contract

```yaml
produces:
  - type: "code-audit"
    format: "markdown"
    path: "claudedocs/<target-name>-code-audit.md"
    sections:
      - scope-and-context
      - codebase-investigation
      - internet-research
      - code-smells-findings
      - solid-violations
      - duplication-report
      - algorithm-analysis
      - security-checklist
      - performance-checklist
      - design-pattern-fitness
      - architecture-conformance
      - technology-evaluation
      - skeptic-challenges
      - quality-scorecard
      - findings-summary
      - improvement-roadmap-tier-1
      - improvement-roadmap-tier-2
      - improvement-roadmap-tier-3
      - refactoring-plans
      - recommended-reading
      - action-tracker
  handoff: "Write claudedocs/handoff-code-audit-<timestamp>.yaml - suggest: debug-triage (root cause), ticket-breakdown (remediation plan), api-first/temporal-workflow/fintech-ledger (for fixes), arch-review (deeper structure), code review, finalize"
```
