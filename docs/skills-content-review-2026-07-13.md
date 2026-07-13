# Skills content review

Date: 2026-07-13
Scope: all 12 skills, every bundled reference and script, both plugin manifests, both
marketplace indexes, Claude hooks, root guidance, and install documentation.

## Outcome

The pack has a sound 12-skill shape, but its content review found several rules that were
internally contradictory, too absolute to be safe across repositories, or stale against the
current upstream behavior. The remediation keeps the existing skill set and removes ceremony
instead of adding more skills.

## Findings and disposition

| Severity | Area | Finding | Disposition |
|---|---|---|---|
| P1 | Ledger and iGaming | A duplicate Blnk reference was treated as success without proving the original request matched. Stale wallet balances could remain actionable. | Fetch and compare the original operation before deduplication. Mark stale balances and disable money mutations until authority is restored. |
| P1 | Migrations | The Liquibase backfill put `runInTransaction:false` on an invalid standalone comment and represented an irreversible backfill with a no-op rollback. | Put the attribute on the changeset line, document the runner precondition for top-level transaction control, and remove fake rollback claims. |
| P1 | Mobile | The global mobile note queued all offline money mutations, which can duplicate or reorder financial operations. | Permit cached reads with a stale marker. Queue mutations only when a reviewed durable idempotency and reconciliation design exists. |
| P2 | Audit | Every finding required an exact code quote, which made absence, configuration, runtime, and test evidence impossible. Static thresholds were treated as defects without impact proof. | Accept code, config, search, test, log, or reproducible absence evidence. Treat thresholds as investigation leads. |
| P2 | Architecture | Every remote call required a circuit breaker and deterministic fallback, including unsafe cached fallbacks for mutations. Every state change required an event. | Select resilience controls from failure semantics. Never fabricate a success fallback. Use events only across a real boundary or when the domain needs them. |
| P2 | Specification | The skill declared every PRD authoritative even when implementation or decisions proved it stale. Its default template mandated speculative flags, analytics, and fixed NFRs. | Reconcile intended behavior with live evidence, classify drift before editing, and replace the template with a lean conditional asset. |
| P2 | Planning and shipping | Planning stopped without a formal ticket even when the user request was explicit. Shipping assumed every delivery used push, PR, and merge. | Accept a clear user request as source scope. Follow discovered repository policy and perform only the delivery actions requested. |
| P2 | E2E | A non-trivial change automatically failed when verification found no defects, encouraging invented issues. A large YAML output contract contradicted the pack's no-ceremony rule. | Judge evidence coverage, not issue count. Remove the YAML contract and keep the verification matrix in the existing plan or PR. |
| P2 | UI selectors | Two duplicated references required `data-testid` on every interactive element. | Centralize one selector guide and prefer role, label, and accessible-name locators, using test IDs only as a justified fallback. |
| P2 | Spring API | `RestClient`, `.formatted()`, and a full three-layer test suite were mandatory regardless of detected Java and Spring versions. TSIDs were described as both internal and exposed. | Detect the stack, reuse its HTTP client, keep TSIDs private, and select tests proportionate to the change. |
| P2 | Temporal | The skill drained only an application queue before completion and omitted Temporal's unfinished-handler condition. Retry profiles were too broad. | Wait for both domain work and `Workflow.isEveryHandlerFinished()`. Bound retries by operation semantics and provider limits. |
| P2 | pgledger | The reference mixed local wrapper tables with upstream pgledger objects and treated an evolving upstream schema as fixed. | Separate local wrapper invariants from upstream names and require verification against the installed revision. |
| P2 | Hooks | Destructive-command patterns missed common option variants. Sensitive-file coverage omitted common private-key and keystore suffixes. | Normalize the covered command forms, add paired tests, and expand sensitive-name and suffix coverage. |
| P2 | Usage audit | The maintenance script created a directory before parsing arguments and wrote raw prompt excerpts by default. Even `--help` mutated the filesystem. | Make the default run read-only, parse help without side effects, and require an explicit sensitive corpus export directory. |
| P3 | iGaming design | Hard-coded red/green colors, mandatory pulsing, universal navigation rules, and universal responsible-gambling placement overrode brand, accessibility, product, and jurisdiction evidence. | Use semantic tokens, redundant non-color cues, reduced-motion handling, and jurisdiction-specific approved requirements. |
| P3 | Build standards | Cleanup instructions could imply destructive database drops without confirmation. | Separate code cleanup from destructive schema cleanup and require an approved migration and restore story. |
| P3 | Compatibility docs | The install review still described version 1.1.0 as waiting to be pushed after it had already shipped. | Record the prior release as published and document the content-remediation version separately. |

## Source checks

- Testing Library ranks accessible queries above test IDs and recommends test IDs only when
  semantic queries do not work: <https://testing-library.com/docs/queries/about/>.
- Spring documents `RestClient` as available since Framework 6.1:
  <https://docs.spring.io/spring-framework/docs/6.1.x/javadoc-api/org/springframework/web/client/RestClient.html>.
- Temporal documents waiting for `Workflow.isEveryHandlerFinished()` before a workflow returns:
  <https://docs.temporal.io/develop/java/workflows/message-passing>.
- Blnk documents unique transaction references and lookup by reference for verification:
  <https://docs.blnkfinance.com/transactions/introduction>.
- Liquibase documents formatted SQL syntax as `--changeset author:id runInTransaction:false`:
  <https://docs.liquibase.com/oss/reference-guide-4-33/changelog-attributes/runintransaction>.
- PostgreSQL permits transaction control in a `DO` block only when it runs outside a transaction
  block: <https://www.postgresql.org/docs/current/sql-do.html>.
- pgledger's current public contract is its functions, views, and pinned SQL revision:
  <https://github.com/pgr0ss/pgledger>.

## Deliberate non-changes

- The 12-skill topology remains intact. No reviewed skill was redundant enough to remove.
- `debug`, the ArchUnit setup, clean-architecture examples, post-edit formatter, marketplace
  topology, and Codex hook non-parity were consistent and need no behavior change.
- Per-skill `agents/openai.yaml` files remain omitted. The plugin already supplies a shared Codex
  interface and adding 12 more metadata files would not improve routing enough to justify drift.

## Validation ledger

Completed against the remediated checkout:

- [x] All 12 skill frontmatters and descriptions pass the Codex skill validator.
- [x] Every cited local resource exists. The duplicate selector references and E2E YAML output
      contract are removed.
- [x] Claude Code validates the marketplace and nested plugin. The Codex plugin validator passes.
- [x] Both plugin manifests report version 1.2.0.
- [x] Hook smoke tests pass 33/33. Python execution and shell syntax checks pass.
- [x] The usage audit passes a synthetic summary and opt-in corpus-export test; its default run and
      `--help` perform no write.
- [x] A fresh isolated Codex home discovers, installs, and enables `garage@garage` 1.2.0, caches
      exactly 12 skills, and its cached plugin matches the source checkout byte-for-byte.
- [x] JSON parsing, local-resource checks, forbidden-pattern scans, and `git diff --check` pass.
