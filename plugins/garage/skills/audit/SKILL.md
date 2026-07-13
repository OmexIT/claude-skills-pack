---
name: audit
description: >
  Use when reviewing code, a diff, a module, an architecture, or a design/spec document against
  house standards - including multi-expert panel reviews ("review with a DDD expert and an
  asset-finance expert"). Also when running a removal-first simplification sweep: "what can we
  remove", "product simplification review".
---

# Audit - evidence-mandatory review

Scope from arguments: a branch/diff, a module path, or a document. Default lenses: **correctness, simplicity, architecture**. Additional lenses on request: `api`, `db`, `security`, `perf`, `tests`, `debt`, `ddd` - or a named expert panel.

## Finding protocol (references/review-dimensions.md)
- Every finding: **Location** (file:line, command, or subsystem) / **Evidence** (code or config quote, scoped search result, test output, log, or reproducible absence proof) / Issue / Impact / Recommendation / Effort.
- Findings without reproducible evidence are rejected. Purely stylistic findings where a linter exists are discarded. Rank by impact: P1 = broken behavior, money, security, privacy, or data loss; P2 = material production or maintainability risk; P3 = bounded improvement.
- Dispatch: inline for a normal diff - lens fan-out costs more than it returns. For large scopes
  (multi-module, whole service), use parallel review agents only when the runtime supports them
  and the user or repository policy permits delegation. Give each one lens and require at most
  ~10 protocol-format findings; merge and dedupe before ranking.

## Simplicity lens (always on)
Flag speculative abstractions, single-implementation interfaces, unnecessary wrappers/factories, unused flexibility, readiness/ceremony that adds complexity without value, tests that test the framework. Recommend deletions, not only additions - an audit that only adds work has failed half its job.

## Architecture lens (Java/Spring)
Dependency direction · `@Transactional` pitfalls (private methods, `this.` proxy bypass) · transaction boundaries around external calls · entity exposure at the API edge · Modulith module boundaries · value objects for money and ids. Use the greppable anti-pattern table; propose ArchUnit rules for repeat offenders.

References: `references/arch-invariants.md` for the review rules,
`references/clean-architecture-patterns.md` for examples, and
`references/archunit-setup.md` for executable boundary checks.

## Doc/spec audit mode
For PRDs, specs, and plans: spec-smells scan (vague metrics, solution-as-requirement, missing non-goals, untestable criteria, TBD without owner), requirement-coverage check, and - when requested - a panel of named domain experts. Findings quote the document or show the scoped absence of required content.

## Simplification sweep mode
"simplification sweep", "what can we remove", "product simplification review": removal-first review of the whole application (or a named area). Hunt across features (speculative, partial, duplicate capabilities, low-value settings), user journeys (steps, decisions, and forms that can collapse), backend (duplicate logic, unnecessary abstractions, unjustified async, redundant persistence, excessive config), frontend (duplicate components, screens, state), and database (redundant tables, unused columns and indexes). Output a ranked remove / simplify / consolidate list - each item with evidence, user or business impact, effort, and risk - plus remaining-debt notes. Descoping flows through `spec` (PRD updates), execution through `build`.

## Output
Ranked findings, each independently actionable. Close with: fix-now (P1/P2) vs ticket-for-later. When asked to "fix all findings": save or update the plan, then execute the authorized fixes via `build`.

Complements any platform-native diff review: audit reviews against house standards and
architecture. Run both before significant merges.
