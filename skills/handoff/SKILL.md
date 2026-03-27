---
name: handoff
description: >
  Inter-skill artifact protocol. Defines how skills discover and consume prior skill outputs,
  handle multi-artifact handoffs, track artifact lifecycle, and clean up after consumption.
  Not a slash command — loaded automatically to enable skill chaining.
user-invocable: false
---

# Skill Handoff Protocol (auto-guidance)

This skill is loaded automatically. It defines how skills produce structured outputs, how downstream skills discover and consume them, and how artifacts are cleaned up after successful implementation.

---

## 1. Producing a Handoff Manifest

Every skill that generates output MUST write a handoff manifest as its **final step**.

### 1.1 Manifest Location and Naming

```
claudedocs/handoff-<skill-name>-<feature>-<timestamp>.yaml
```

Examples:
```
claudedocs/handoff-prd-payment-links-20260327T140000.yaml
claudedocs/handoff-ui-design-money-request-20260327T143000.yaml
claudedocs/handoff-spec-to-impl-payment-links-20260327T160000.yaml
```

### 1.2 How to Write

After producing your primary output(s), write the handoff manifest using the Write tool:

```bash
mkdir -p claudedocs
# Write the YAML using the schema in Section 2
```

This is not optional. Without a handoff manifest, downstream skills cannot discover your output and will ask redundant questions or miss context entirely.

---

## 2. Handoff Manifest Schema

```yaml
schema_version: "2.0"
source_skill: "<skill-name>"
feature: "<feature or project name>"
timestamp: "<ISO 8601 UTC>"

# ── Artifact Manifest ──────────────────────────────────────
# Every file or directory produced by this skill.
# Multi-artifact skills (ui-design, spec-to-impl) list ALL outputs.
artifacts:
  - path: "<relative path to file or directory>"
    type: "<artifact type from Standard Output Types table>"
    status: "ready"            # ready | in-progress | failed
    summary: "<one-line description>"
    consumed_by:               # which downstream skills need this artifact
      - "<skill-name>"
    key_sections:              # sections that downstream skills should read
      - "<section name>"
    conditional: "<condition>" # omit if always produced

# ── Quality Gate ───────────────────────────────────────────
quality:
  status: "complete"           # complete | partial | has-ambiguities | blocked
  ambiguities: []              # list of unresolved questions
  blockers: []                 # list of issues preventing downstream consumption

# ── Downstream Suggestions ─────────────────────────────────
# Which skills should run next and what context they need.
suggested_next:
  - skill: "<downstream skill name>"
    reason: "<why this skill should run next>"
    context: "<specific guidance — what to focus on, what's ready>"
    reads:                     # which artifacts from this manifest it needs
      - "<artifact path>"

# ── Upstream References ─────────────────────────────────────
# Which handoff manifests this skill consumed (forms a DAG).
consumed_from:
  - "<path to upstream handoff manifest>"

# ── Lifecycle ───────────────────────────────────────────────
lifecycle:
  archivable_after:            # skills that must consume before archiving
    - "<skill-name>"
  archive_policy: "after-finalize"  # after-finalize | after-all-consumed | manual

# ── Tool-Specific Extensions ───────────────────────────────
# Optional blocks for design tools, CI systems, etc.
# stitch: { ... }             # Stitch MCP references (ui-design)
# figma: { ... }              # Figma MCP references (figma-to-code)
```

### 2.1 Artifact Status Values

| Status | Meaning | Downstream behavior |
|---|---|---|
| `ready` | Artifact is complete and consumable | Read and use immediately |
| `in-progress` | Skill is still producing this artifact | Wait or skip — check back later |
| `failed` | Artifact generation failed | Do not consume; surface to user |

### 2.2 Quality Status Values

| Status | Meaning | Downstream behavior |
|---|---|---|
| `complete` | All artifacts ready, no open questions | Proceed normally |
| `partial` | Some artifacts ready, others in-progress | Consume ready artifacts, wait on others |
| `has-ambiguities` | Artifacts produced but with unresolved questions | Consume but flag ambiguities to user |
| `blocked` | Cannot proceed until user resolves an issue | Do not consume; surface blockers |

---

## 3. Consuming Handoff Manifests

On activation, every skill MUST run this discovery protocol:

### 3.1 Discovery — Find Relevant Upstream Manifests

```bash
# Step 1: List all handoff manifests, most recent first
ls -t claudedocs/handoff-*.yaml 2>/dev/null | head -10
```

```python
# Step 2: For each manifest, check if this skill is in suggested_next[].skill
# Step 3: For each match, check quality.status != "blocked"
# Step 4: For each match, read the artifacts where status == "ready"
```

### 3.2 Consumption Protocol

1. **Discover** — Find manifests where `suggested_next[].skill` matches this skill's name
2. **Filter** — Skip manifests where `quality.status == "blocked"`
3. **Read artifacts** — For each suggested_next entry, read the files listed in `reads[]`
4. **Use context** — Apply the `context` field to understand what the upstream skill recommends
5. **Skip questions** — Do not ask the user for information that upstream artifacts already provide
6. **Record** — Add the consumed manifest path to your own `consumed_from[]` when you write your handoff

### 3.3 Handling Partial Handoffs

When an upstream manifest has `quality.status == "partial"`:

- **Consume** artifacts with `status: "ready"` — proceed with what's available
- **Skip** artifacts with `status: "in-progress"` — do not block on them
- **Report** to the user: "Upstream <skill> has <n> artifacts in progress. Proceeding with <n> ready artifacts."
- If a critical artifact is `in-progress` (e.g., the schema design when you're the BE agent), **wait** and re-check after a delay

### 3.4 Graceful Degradation

Skills MUST work without handoff manifests. If no relevant manifests are found:
- Ask the user for the information that upstream artifacts would have provided
- Proceed normally — the skill is self-contained, just less informed

---

## 4. Multi-Artifact Skills

Skills that produce multiple files (ui-design, spec-to-impl, figma-to-code) use the same schema — they just have more entries in `artifacts[]`.

### 4.1 Example: ui-design Handoff

```yaml
schema_version: "2.0"
source_skill: "ui-design"
feature: "money-request"
timestamp: "2026-03-27T14:30:00Z"

artifacts:
  - path: "design/ux/ux-inventory.md"
    type: "ui-design"
    status: "ready"
    summary: "Screen inventory with fields, states, and user flows"
    consumed_by: ["spec-to-impl"]
  - path: "design/components/component-tree.md"
    type: "ui-design"
    status: "ready"
    summary: "Component hierarchy with props, states, and interactions"
    consumed_by: ["spec-to-impl"]
  - path: "design/components/testid-registry.md"
    type: "testid-registry"
    status: "ready"
    summary: "44 data-testid selectors for Playwright"
    consumed_by: ["verify-impl", "spec-to-impl"]
  - path: "design/visual-spec/tokens.md"
    type: "design-tokens"
    status: "ready"
    summary: "Color, spacing, typography, radius tokens"
    consumed_by: ["spec-to-impl"]
  - path: "design/a11y/a11y-spec.md"
    type: "ui-design"
    status: "ready"
    summary: "WCAG AA compliance spec with 3 issues to resolve"
    consumed_by: ["spec-to-impl", "ux-review"]
  - path: "design/DESIGN.md"
    type: "design-md"
    status: "ready"
    summary: "Portable design system spec"
    consumed_by: ["spec-to-impl", "figma-to-code"]

quality:
  status: "complete"
  ambiguities: []

suggested_next:
  - skill: "spec-to-impl"
    reason: "Design artifacts ready for FE implementation"
    context: "6 components, 44 testIDs, 3 screens. Consume design/DESIGN.md for tokens and design/components/ for component specs."
    reads:
      - "design/DESIGN.md"
      - "design/components/component-tree.md"
      - "design/components/testid-registry.md"
      - "design/visual-spec/tokens.md"
  - skill: "verify-impl"
    reason: "testIDs ready for Playwright selectors"
    context: "testid-registry.md has 44 selectors"
    reads:
      - "design/components/testid-registry.md"

lifecycle:
  archivable_after: ["spec-to-impl", "verify-impl"]
  archive_policy: "after-finalize"
```

### 4.2 Example: spec-to-impl Handoff

```yaml
schema_version: "2.0"
source_skill: "spec-to-impl"
feature: "money-request"
timestamp: "2026-03-27T16:00:00Z"

artifacts:
  - path: "src/main/java/com/app/moneyrequest/"
    type: "code"
    status: "ready"
    summary: "Backend service: controller, service, repository, DTOs"
    consumed_by: ["verify-impl", "pr-review", "code-audit"]
  - path: "src/main/resources/db/migration/V001__money_request.sql"
    type: "code"
    status: "ready"
    summary: "Liquibase migration for money_request tables"
    consumed_by: ["verify-impl"]
  - path: "src/ui/pages/MoneyRequest/"
    type: "code"
    status: "ready"
    summary: "React components for money request flow"
    consumed_by: ["verify-impl", "pr-review"]
  - path: "e2e/test-plan.yaml"
    type: "test-plan"
    status: "ready"
    summary: "12 test cases across API, DB, and UI layers"
    consumed_by: ["verify-impl"]
  - path: "docs/observability-contract.md"
    type: "architecture"
    status: "ready"
    summary: "Logging, metrics, and tracing requirements"
    consumed_by: ["monitoring-plan"]

quality:
  status: "complete"
  ambiguities: []

consumed_from:
  - "claudedocs/handoff-prd-money-request-20260327T120000.yaml"
  - "claudedocs/handoff-ui-design-money-request-20260327T143000.yaml"

suggested_next:
  - skill: "verify-impl"
    reason: "Implementation complete, ready for live verification"
    context: "e2e/test-plan.yaml has 12 TCs. All P0 FRs covered. Run all 3 layers."
    reads:
      - "e2e/test-plan.yaml"
  - skill: "finalize"
    reason: "After verification passes, commit and PR"
    context: "3 agent branches to merge: feature/be-task-002, feature/dba-task-003, feature/fe-task-004"
    reads: []

lifecycle:
  archivable_after: ["verify-impl", "finalize"]
  archive_policy: "after-finalize"
```

---

## 5. Artifact Lifecycle and Cleanup

### 5.1 Lifecycle Stages

```
PRODUCED → CONSUMED → ARCHIVED
   ↑           ↑          ↑
   Skill    Downstream   /finalize
   writes   skills read  archives
```

### 5.2 What Gets Cleaned Up

| Artifact Type | Location | Cleanup Strategy |
|---|---|---|
| Handoff manifests | `claudedocs/handoff-*.yaml` | **Never delete** — audit trail |
| Primary outputs | `claudedocs/<feature>-*.md` | **Archive** after `/finalize` completes |
| Design artifacts | `design/` | **Archive** after `/finalize` completes |
| Test plans | `e2e/test-plan.yaml` | **Keep** — needed for regression testing |
| Test evidence | `e2e/reports/`, screenshots | **Keep** — needed for evidence review |
| Worktree branches | `.worktrees/` | **Delete** after merge (handled by spec-to-impl) |

### 5.3 Archive Protocol

The `/finalize` skill runs this after a successful commit + PR:

```bash
# 1. Create archive directory
ARCHIVE="claudedocs/.archive/$(date +%Y%m%d-%H%M%S)-<feature>"
mkdir -p "$ARCHIVE"

# 2. Move primary outputs (NOT handoff manifests)
mv claudedocs/<feature>-*.md "$ARCHIVE/" 2>/dev/null

# 3. Move design artifacts if present
[ -d design/ ] && mv design/ "$ARCHIVE/design/" 2>/dev/null

# 4. Report
echo "Archived to: $ARCHIVE"
echo "Handoff manifests preserved in claudedocs/ (audit trail)"
echo "Test artifacts preserved in e2e/ (regression)"
```

### 5.4 Safety Rules

1. **Never delete handoff manifests** — they form the audit trail for the skill chain
2. **Never auto-delete** — always archive (move), never `rm`
3. **Archive only after finalize** — not after individual skill completion
4. **Preserve test artifacts** — `e2e/test-plan.yaml`, screenshots, and reports stay for regression
5. **Ask before archiving design/** — design artifacts may be referenced by ongoing implementation
6. Add `claudedocs/.archive/` to `.gitignore` — archived artifacts are local working state

### 5.5 Reference Tracking

A handoff manifest's `lifecycle.archivable_after` field lists which skills must consume the artifacts before they can be archived. The `/finalize` skill checks this:

```python
# Before archiving, verify all consumers have consumed
for manifest in handoff_manifests:
    required = manifest.lifecycle.archivable_after
    consumed_by_skills = [m.source_skill for m in all_manifests
                          if manifest.path in m.consumed_from]
    if not all(s in consumed_by_skills for s in required):
        print(f"⚠️ {manifest.path} not yet consumed by: {missing}")
        # Do not archive — still needed
```

---

## 6. Skill Chain Examples

```
/prd → writes handoff-prd-payment-links-20260327T120000.yaml
  → artifacts: [{path: "claudedocs/payment-links-prd.md", status: "ready"}]
  → suggests: design-doc, ticket-breakdown, spec-to-impl
  → context for design-doc: "3 new API endpoints, payment link CRUD + expiry"

/ui-design → reads handoff-prd-*.yaml, writes handoff-ui-design-*.yaml
  → artifacts: [6 files in design/ — all status: "ready"]
  → suggests: spec-to-impl, verify-impl
  → consumed_from: ["claudedocs/handoff-prd-payment-links-*.yaml"]

/spec-to-impl → reads handoff-prd-*.yaml AND handoff-ui-design-*.yaml
  → writes handoff-spec-to-impl-*.yaml
  → artifacts: [code + test-plan + obs-contract — all status: "ready"]
  → suggests: verify-impl, finalize
  → consumed_from: [both upstream manifests]

/verify-impl → reads handoff-spec-to-impl-*.yaml
  → writes handoff-verify-impl-*.yaml
  → suggests: finalize, evidence-review

/finalize → reads handoff-verify-impl-*.yaml
  → produces: commit + PR
  → archives: claudedocs/<feature>-*.md, design/ → claudedocs/.archive/
  → preserves: handoff manifests (audit), e2e/ artifacts (regression)
```

---

## 7. Rules

1. Handoff manifests are lightweight pointers (< 80 lines), NOT copies of the output
2. The actual output lives at the `path` referenced in `artifacts[]`
3. Skills consume artifacts by reading the referenced paths, NOT by relying on conversation context
4. Handoff manifests are **never deleted** — they form an audit trail
5. Primary artifacts are **archived** (not deleted) after `/finalize` completes
6. Skills MUST work without handoff manifests (graceful degradation) — they just ask more questions
7. Timestamps use ISO 8601 UTC format for sorting: `2026-03-27T14:00:00Z`
8. Feature names in filenames use kebab-case: `payment-links`, `money-request`
9. Multi-artifact skills list ALL outputs in `artifacts[]` with per-artifact status
10. Partial handoffs (`quality.status: "partial"`) are valid — downstream skills consume what's ready

---

## 8. Standard Output Types

| Type | Produced By | Consumed By |
|---|---|---|
| **Discovery** | | |
| `assessment` | /opportunity-assessment, /tech-debt-assessment | /prd, /decision-matrix, /ticket-breakdown |
| `analysis` | /competitive-analysis | /prd, /go-to-market |
| **Planning** | | |
| `prd` | /prd | /design-doc, /ticket-breakdown, /spec-to-impl, /spec-panel |
| `design-doc` | /design-doc | /spec-to-impl, /test-plan, /security-review, /api-design |
| `adr` | /adr | /design-doc |
| `user-flow` | /user-flow | /flow-map, /ux-review, /test-plan, /ui-design |
| `flow-map` | /flow-map | /spec-to-impl, /test-plan |
| `api-design` | /api-design | /spec-to-impl, /test-plan, /spec-panel |
| `data-design` | /data-design | /spec-to-impl (DBA agent), /migration-plan |
| `search-design` | /search-design | /spec-to-impl, /data-design |
| `infra-design` | /infra-design | /spec-to-impl (DEVOPS agent), /monitoring-plan |
| `tickets` | /ticket-breakdown | /spec-to-impl |
| `experiment-plan` | /experiment-design | /ticket-breakdown, /metrics-review |
| `decision` | /decision-matrix | /adr, /design-doc |
| `migration-plan` | /migration-plan | /ticket-breakdown, /test-plan, /runbook |
| `mobile-guidance` | /mobile-dev | /spec-to-impl (mobile agents) |
| **Implementation** | | |
| `spec-manifest` | /spec-to-impl (Phase 1) | /spec-to-impl (Phase 2+) |
| `architecture` | /spec-to-impl (ARCH) | /spec-to-impl (all agents) |
| `test-plan` | /spec-to-impl (QA), /test-plan | /verify-impl, /spec-to-impl |
| `code` | /spec-to-impl (BE/FE/DBA) | /verify-impl, /finalize, /pr-review |
| `verification` | /verify-impl | /finalize, /evidence-review |
| **Quality** | | |
| `panel-analysis` | /spec-panel | /spec-to-impl, /ticket-breakdown, /test-plan |
| `code-audit` | /code-audit | /finalize, /tech-debt-assessment, /test-plan |
| `pr-review` | /pr-review | /release-notes |
| `security-review` | /security-review | /finalize, /test-plan |
| `performance-review` | /performance-review | /test-plan, /monitoring-plan |
| `ux-review` | /ux-review | /ticket-breakdown, /pr-review |
| `docs-review` | /docs-review | /finalize |
| `metrics-review` | /metrics-review | /experiment-design |
| `evidence-review` | /evidence-review | /finalize |
| `triage` | /debug-triage | /postmortem, /test-plan |
| **Design tools** | | |
| `ui-design` | /ui-design | /spec-to-impl (FE), /ux-review |
| `component-tree` | /ui-design | /spec-to-impl (FE) |
| `testid-registry` | /ui-design | /verify-impl, /spec-to-impl (FE) |
| `design-tokens` | /ui-design, /figma-to-code | /spec-to-impl (FE) |
| `a11y-spec` | /ui-design | /spec-to-impl (FE), /ux-review |
| `design-md` | /ui-design | /spec-to-impl (FE), /figma-to-code |
| `stitch-reference` | /ui-design (Stitch mode) | /spec-to-impl (FE), /verify-impl |
| `stitch-screen-specs` | /ui-design (Stitch mode) | /spec-to-impl (FE) |
| `react-components` | /figma-to-code | /verify-impl, /finalize, /code-audit |
| `code-connect-mappings` | /figma-to-code | /finalize |
