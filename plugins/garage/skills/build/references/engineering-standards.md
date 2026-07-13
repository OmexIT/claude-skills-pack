# Engineering implementation standards

The full implementation standard, loaded by `build` once per feature. The always-on floor
lives in the global rules. Mechanically checkable rules belong in linters, Spotless/Prettier,
and ArchUnit (the audit skill proposes ArchUnit rules for repeat offenders); this document
carries the judgment calls.

## Before writing code
- Review what you will touch: architecture, schema, APIs, UI components, existing tests. Never implement blind.
- If most of what's needed exists, extend or refactor it. Treat 80% as a rough recon heuristic, not arithmetic. Never create a parallel implementation.
- Match existing naming, structure, style, and error handling. Consistency beats personal preference.
- Refactor existing code when that simplifies the design; don't build alongside it.

## Principles
KISS, DRY, YAGNI, SOLID, composition over inheritance, separation of concerns. Patterns only
when they solve a present problem. Nothing speculative: no abstractions, interfaces, wrappers,
factories, hooks, providers, utility classes, configuration, extension points, or feature
flags without a consumer today. Every new piece of code has a clear, immediate purpose.
Success is a focused product solving the core problem with the simplest correct
implementation - never feature, class, service, or pattern count. When a sophisticated
solution and a simpler one both fully satisfy the requirements, the simpler one wins.

## Backend
- Business logic in the domain/service layer; controllers thin (parse, call, map); repositories persist only; infrastructure stays out of the domain; constructor injection.
- APIs: follow the house style (`spring-api` skill); reuse existing request/response models; no duplicate endpoints; validation and error handling consistent across the service.
- Database: normalize appropriately; reuse existing tables and relationships; migrations minimal and clean (`migrations` skill governs the how); greenfield repos edit the existing changeset instead of stacking migration history. Plan removal of obsolete structures, but perform destructive database changes only with explicit approval, a safe deployment sequence, and a restore or forward-fix story.
- Performance: no N+1 queries (check repository call sites when adding loops over aggregates); no premature optimization. Optimize only on profiling or real usage evidence.
- Asynchronous processing (queues, events, scheduled jobs) only when a synchronous flow demonstrably cannot meet the need - async is complexity, not a default.

## Frontend
- Components: small, focused, reusable; no pass-through wrappers that add no value; composition over deep nesting; eliminate duplicated UI.
- State: local by default; global only when genuinely shared; derive instead of storing computed values; never duplicate state; minimize prop drilling (compose or colocate instead).
- UI: reuse the design system; consistent spacing, typography, colors, interaction patterns; no animation or visual complexity that doesn't improve usability.
- Forms: reuse existing form components and validation; validation consistent with the backend contract.
- API integration: one shared client, centralized networking, consistent loading/success/error handling, no redundant calls.

## Refactoring within the touched scope
Remove dead code, unused components, obsolete utilities, duplicated logic and validation,
stale configuration, unused feature flags, and deprecated APIs made obsolete by the requested
change. Consolidate similar implementations when the shared rule is stable. No temporary
implementations, placeholder code, or compatibility layers unless explicitly required. Do not
turn cleanup into an unrelated refactor.

## Tests
- Verify business behavior through the public surface. Backend: business rules, minimal mocking, no framework tests. Frontend: user-visible behavior and interactions; no implementation details, snapshot abuse, or brittle DOM assertions.
- Small, readable, deterministic, fast, independent; one behavior per test; no duplicated setup or fixtures that don't pay for themselves; no coverage-percentage chasing.
- Delete obsolete and duplicate tests together with the code they covered.

## JavaDocs & comments
- JavaDoc only where it adds meaning: public APIs, extension points, complex business rules, non-obvious behavior. Explain why and how to use, never restate the code. Update or delete alongside every code change.
- Nothing on trivial getters, setters, constructors, or self-explanatory methods.
- Comments carry what code cannot: rationale, business rules, assumptions, constraints, edge cases. Never narrate mechanics. No TODOs without a tracked follow-up.
- Prefer self-documenting code: expressive names, small focused methods, clear structure.

## Completion checklist (gates every slice)
- [ ] No duplicate code introduced; existing functionality reused where it existed.
- [ ] No abstraction without a present consumer.
- [ ] Dead code, unused components, and obsolete tests deleted with the change.
- [ ] JavaDocs/comments updated or removed; none stale or narrating mechanics.
- [ ] Frontend and backend contracts consistent (validation, error shapes).
- [ ] Database delta minimal; obsolete structures removed when approved, otherwise tracked with an owner and safe removal plan.
- [ ] The result is simpler than or equal to what preceded it, and understandable by another engineer within minutes.
