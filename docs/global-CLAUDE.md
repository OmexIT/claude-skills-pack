# Canonical copy of ~/.claude/CLAUDE.md — keep the two in sync.
# Every rule below comes from a correction given repeatedly in real sessions.

## Voice & output
- No em-dashes. No AI cliches ("delve", "leverage", "seamless", "robust"). No emoji in code, commits, or docs.
- No robotic scaffolding ("What I need from each team (by [date])"). Write like a person.
- Business-facing docs use plain language — no tech jargon (RabbitMQ, DTO) for product/finance readers.
- Never mention Claude/AI in commits, PRs, branch names, or code comments. No "Generated with Claude Code" footers.

## Simplicity (the standing law)
- Smallest change that solves the problem. If two solutions work, pick the simpler.
- Check what the framework already provides before writing anything (Spring Boot auth, validation, scheduling, retry all exist).
- No speculative abstractions: no single-implementation interfaces, wrappers, factories, feature flags, config knobs, or readiness checks unless explicitly requested.
- Reuse before adding: if ≥80% of what's needed exists, extend or refactor it — never a parallel copy.

## Scope & completeness
- Implement what was asked, fully — no half fixes, no patchwork, no mock/stub UIs presented as done.
- No leftovers: stale files, commented-out code, unused imports, dead tables. Cleanup is part of the task.
- No drive-by refactors, no CI/settings changes, no touching curated content (menu text, product copy) unless asked.
- When instructions conflict with reality: stop and flag — don't improvise silently.

## Testing
- Test business behavior only. No DTO/getter tests, no framework tests, no log-assertion tests, no snapshot abuse.
- Deterministic, fast, independent. A small suite of high-value tests beats coverage theater.

## Verification & autonomy
- Never claim done without running the verification command and showing its output.
- Proceed autonomously through routine steps; don't stop unless blocked. When blocked, state exactly what's needed.

## Stack invariants (Java)
- Money = BigDecimal / NUMERIC. Time = Instant / OffsetDateTime / TIMESTAMPTZ. Never double or Date.
- IDs: TSID internal, UUIDv7 external. Read the repo before assuming versions (work: Java 21 + Boot 3 + Maven; personal: Java 25 + Boot 4 + Gradle).

## Durable state
- Plans and their checkboxes in docs/ are the session state. Update them as work progresses so "what's pending?" is answerable after any context reset.
