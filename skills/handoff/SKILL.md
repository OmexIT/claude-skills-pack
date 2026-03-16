---
name: handoff
description: >
  Inter-skill artifact protocol. Defines how skills discover and consume prior skill outputs.
  Not a slash command — loaded automatically to enable skill chaining.
user-invocable: false
---

# Skill Handoff Protocol (auto-guidance)

This skill is loaded automatically. It defines how skills produce structured outputs and how downstream skills discover and consume them.

## Protocol

### 1. Producing a Handoff Artifact

Every skill that generates output SHOULD write a handoff artifact:

```
claudedocs/handoff-<skill-name>-<timestamp>.yaml
```

Example: `claudedocs/handoff-prd-20260316T100000.yaml`

### 2. Handoff Artifact Schema

```yaml
source_skill: "<skill-name>"
timestamp: "<ISO 8601>"
project: "<project or feature name>"

artifacts:
  - path: "<relative path to produced file>"
    type: "<prd | design-doc | adr | test-plan | spec-manifest | architecture | tickets | code | review>"
    summary: "<one-line description>"
    key_sections:
      - "<section name that downstream skills care about>"

quality_assessment: "<Complete | Partial | Has ambiguities>"
ambiguities: []  # list any unresolved questions

suggested_next:
  - skill: "<downstream skill name>"
    reason: "<why this skill should run next>"
    context: "<specific guidance for that skill>"

output_contract:
  format: "<markdown | yaml | json | code>"
  schema_version: "1.0"
```

### 3. Consuming Handoff Artifacts

On activation, every skill SHOULD:

1. **Check** `claudedocs/handoff-*.yaml` for recent artifacts (last 24 hours)
2. **Filter** by `suggested_next` to find artifacts addressed to this skill
3. **Read** the referenced artifact files via their `path` field
4. **Use** the `context` field to understand what the upstream skill recommends
5. **Skip** asking questions that the upstream artifact already answers

```bash
# Discovery command
ls -t claudedocs/handoff-*.yaml 2>/dev/null | head -5
```

### 4. Skill Chain Examples

```
/prd → writes handoff-prd-*.yaml
  → suggests: design-doc, ticket-breakdown
  → context for design-doc: "Focus on API design — 3 new endpoints identified"

/design-doc → reads handoff-prd-*.yaml, writes handoff-design-doc-*.yaml
  → suggests: spec-to-impl, test-plan, security-review
  → context for spec-to-impl: "Architecture decided: monolith, 4 new services"

/spec-to-impl → reads both upstream handoffs, writes handoff-spec-to-impl-*.yaml
  → suggests: verify-impl, finalize
  → context for verify-impl: "e2e/test-plan.yaml generated, 12 test cases"
  → artifacts: [{path: "e2e/test-plan.yaml", type: "test-plan"}]

/verify-impl → reads handoff-spec-to-impl-*.yaml
  → suggests: finalize, evidence-review
  → context for finalize: "All 12 TCs passed, ready for commit"

/finalize → reads handoff-verify-impl-*.yaml
  → produces: commit + PR
```

### 5. Rules

- Handoff artifacts are lightweight pointers (< 50 lines), NOT copies of the output
- The actual output lives at the `path` referenced in `artifacts[]`
- Skills consume artifacts by reading the referenced paths, NOT by relying on conversation context
- Handoff files are never deleted — they form an audit trail
- Skills should work without handoff files (graceful degradation) — they just ask more questions
- Timestamps use ISO 8601 format for sorting: `2026-03-16T10:00:00Z`

### 6. Standard Output Types

| Type | Produced By | Consumed By |
|---|---|---|
| `prd` | /prd | /design-doc, /ticket-breakdown, /spec-to-impl |
| `design-doc` | /design-doc | /spec-to-impl, /test-plan, /security-review, /api-design |
| `adr` | /adr | /design-doc |
| `tickets` | /ticket-breakdown | /spec-to-impl |
| `spec-manifest` | /spec-to-impl (Phase 1) | /spec-to-impl (Phase 2+) |
| `test-plan` | /spec-to-impl (QA), /test-plan | /verify-impl |
| `architecture` | /spec-to-impl (ARCH) | /spec-to-impl (all agents) |
| `code` | /spec-to-impl (BE/FE/DBA) | /verify-impl, /finalize, /pr-review |
| `verification` | /verify-impl | /finalize, /evidence-review |
| `review` | /pr-review, /security-review, /evidence-review | /finalize |
| `flow-map` | /flow-map | /spec-to-impl, /test-plan |
| `data-design` | /data-design | /spec-to-impl (DBA agent) |
| `infra-design` | /infra-design | /spec-to-impl (DEVOPS agent) |
| `mobile-guidance` | /mobile-dev | /spec-to-impl (mobile agents) |
