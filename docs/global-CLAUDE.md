# Optional reference for personal ~/.claude/CLAUDE.md instructions.
# Adopt deliberately; local global instructions may differ across machines and clients.

# Global engineering rules (all projects)

## Voice & output
- No em-dashes. No AI cliches ("delve", "leverage", "seamless", "robust"). No emoji in code, commits, or docs.
- No robotic scaffolding ("What I need from each team (by [date])"). Write like a person.
- Business-facing docs use plain language: no tech jargon (RabbitMQ, DTO) for product or finance readers.
- Never mention Claude/AI in commits, PRs, branch names, or code comments. No "Generated with Claude Code" footers.

## Simplicity (the standing law)
- Smallest change that solves the problem. If two solutions work, pick the simpler.
- Check what the framework already provides before writing anything (Spring Boot auth, validation, scheduling, retry all exist).
- No speculative abstractions: no single-implementation interfaces, wrappers, factories, config knobs, or readiness checks without a present consumer. Feature flags need a current rollout or risk-control purpose, an owner, and a removal plan.
- Reuse before adding: if most of what's needed already exists, extend or refactor it. Treat 80% as a rough prompt to inspect, not a numeric gate. Never write a parallel copy.

## Scope & completeness
- Implement what was asked, fully. No half fixes, no patchwork, no mock/stub UIs presented as done.
- No leftovers: stale files, commented-out code, unused imports, dead tables. Cleanup is part of the task.
- No drive-by refactors, no CI/settings changes, no touching curated content (menu text, product copy) unless asked.
- When instructions conflict with reality: stop and flag. Don't improvise silently.
- Comments and JavaDocs explain why (business rules, constraints), never restate code; delete stale ones with every change; no TODOs without a tracked follow-up.

## Testing
- Test business behavior only. No DTO/getter tests, no framework tests, no log-assertion tests, no snapshot abuse.
- Deterministic, fast, independent. A small suite of high-value tests beats coverage theater.

## Verification & autonomy
- Never claim done without running the verification command and showing its output.
- Proceed autonomously through routine steps; don't stop unless blocked. When blocked, state exactly what's needed.

## Stack invariants (Java)
- In domain code, money = BigDecimal / NUMERIC and instants = Instant / OffsetDateTime / TIMESTAMPTZ. Adapt legacy or provider types at boundaries rather than spreading double or Date through the domain.
- For service-owned house schemas, TSID is internal and UUIDv7 is public. Keep third-party schema identifiers intact. Read the repo before assuming stack versions; they differ per workspace.

## Durable state
- Plans and their checkboxes in docs/ are the session state. Update them as work progresses so "what's pending?" is answerable after any context reset.
