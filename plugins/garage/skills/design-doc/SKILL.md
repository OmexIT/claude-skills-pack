---
name: design-doc
description: "Use when the user wants a system design doc or RFC written for a feature, or a quick gap check of one: requirements, constraints, architecture, data model, APIs, rollout, and risks. A rigorous multi-expert review before implementation belongs to spec-panel."
---

# Design doc (RFC)

A design doc decides how a feature or system will be built, with the alternatives weighed. It takes the what and why from a `prd` as given; a single decision that needs a lasting record goes in an `adr`.

## Modes
- **Write**: produce the doc from `assets/design-doc.md`, keeping only the sections this design needs.
- **Review**: for an existing doc, list concrete gaps and proposed fixes in severity order; do not rewrite it unasked.

Ask only what is missing: the problem and user, 1-3 measurable outcomes, hard constraints (deadline, compatibility, latency, cost, compliance), and what is out of scope. Read the code the design touches before proposing anything; reuse existing modules and framework features before adding components.

## Rules
- Requirements and non-goals before architecture.
- At least two real alternatives, including "extend what exists" when it is plausible, each with honest trade-offs. No straw men.
- Data model first: entities, ownership, keys, access patterns. Follow the house rules where the stack applies: money as `BigDecimal` / `NUMERIC`, time as `Instant` or `OffsetDateTime` / `TIMESTAMPTZ`, internal IDs as TSID `BIGINT`, external IDs as UUIDv7, API errors as RFC 9457 Problem Details. Leave schema and contract detail to `data-design`, `api-design`, and `db-migration`.
- For each external call or async step, state its failure semantics (timeout, duplicate, partial success, unknown outcome) and what the system does then. Choose retries, idempotency, or compensation from those semantics; never assume success.
- Rollout covers compatibility, migration, and a rollback or restore path. Feature flags, staged exposure, and new dashboards only when the risk calls for them.
- Test strategy names the business behaviors and failure modes to prove, not a layer checklist.
- End with open questions (owner each) and a 5-10 item review checklist reviewers can verify quickly.

## Workflow context
- `prd` says what and why; `design-doc` says how; `adr` records one decision; `decision-matrix` compares options when the choice is hard.
- Depth lives in `api-design`, `data-design`, `infra-design`, `migration-plan`.
- Feeds `ticket-breakdown`, `test-plan`, `security-review`, `performance-review`, `spec-to-impl`.

## Output contract
```yaml
produces:
  - type: "design-doc"
    format: "markdown"
    path: "claudedocs/<feature>-design-doc.md"
    sections: [requirements, architecture, data_model, apis, rollout, risks]
    handoff: "Write claudedocs/handoff-design-doc-<timestamp>.yaml - suggest: spec-to-impl, test-plan, security-review"
```
