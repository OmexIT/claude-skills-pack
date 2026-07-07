---
name: audit
description: >
  Use when reviewing code, a diff, a module, an architecture, or a design/spec document against
  house standards — including multi-expert panel reviews ("review with a DDD expert and an
  asset-finance expert").
argument-hint: "[diff | module path | doc path] [--lens ...]"
---

# Audit — evidence-mandatory review

Scope from arguments: a branch/diff, a module path, or a document. Default lenses: **correctness, simplicity, architecture**. Additional lenses on request: `api`, `db`, `security`, `perf`, `tests`, `debt`, `ddd` — or a named expert panel.

## Finding protocol (references/review-dimensions.md)
- Every finding: **Location** (file:line) / **Evidence** (exact code quote) / Issue / Impact / Recommendation / Effort.
- Findings without evidence are rejected. Purely stylistic findings where a linter exists are discarded. Rank by severity: P1 = broken behavior, money, or security.

## Simplicity lens (always on)
Flag speculative abstractions, single-implementation interfaces, unnecessary wrappers/factories, unused flexibility, readiness/ceremony that adds complexity without value, tests that test the framework. Recommend deletions, not only additions — an audit that only adds work has failed half its job.

## Architecture lens (Java/Spring — references/arch-invariants.md)
Dependency direction · `@Transactional` pitfalls (private methods, `this.` proxy bypass) · transaction boundaries around external calls · entity exposure at the API edge · Modulith module boundaries · value objects for money and ids. Use the greppable anti-pattern table; propose ArchUnit rules for repeat offenders.

## Doc/spec audit mode
For PRDs, specs, and plans: spec-smells scan (vague metrics, solution-as-requirement, missing non-goals, untestable criteria, TBD without owner), requirement-coverage check, and — when requested — a panel of named domain experts. Findings must quote the document.

## Output
Ranked findings, each independently actionable. Close with: fix-now (P1/P2) vs ticket-for-later. When asked to "fix all findings": convert to a plan and execute via `build` — never fix silently inside the audit.

Complements `/code-review` (bug-hunting on diffs): audit reviews against house standards and architecture. Run both before significant merges.
