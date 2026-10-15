---
name: handoff
description: "Use when a skill needs to find, read, or write a handoff manifest in claudedocs, chain its output into the next skill, or clean up artifacts that downstream skills have consumed."
---

# Skill Handoff Protocol

Skills whose output contract has a `handoff:` line write a handoff manifest so downstream skills
can find it without relying on conversation context. Skills that end in a document for people
(assessments, launch plans, runbooks, incident notes, updates, posts) have no such line and skip the manifest. Skills that start work read the manifests meant for them. The
path convention, field names, and status values below are a shared interface used across the
pack: do not rename or extend them.

## Writing a manifest

Write it as the final step, after the primary outputs exist (`mkdir -p claudedocs` first).

**Path:** `claudedocs/handoff-<skill-name>-<feature>-<timestamp>.yaml`
for example `claudedocs/handoff-prd-payment-links-20260327T140000.yaml`.
Feature names are kebab-case. Some skills' output contracts omit the feature segment
(`handoff-<skill-name>-<timestamp>.yaml`); discovery globs `handoff-*.yaml`, so both are found.
The filename timestamp is compact UTC (`20260327T140000`); the `timestamp` field is ISO 8601 UTC
(`2026-03-27T14:00:00Z`).

**Schema (v2.0):**

```yaml
schema_version: "2.0"
source_skill: "<skill-name>"
feature: "<feature or project name>"
timestamp: "<ISO 8601 UTC>"

artifacts:                     # every file or directory produced; multi-artifact skills list all
  - path: "<relative path to file or directory>"
    type: "<artifact type, see Output types>"
    status: "ready"            # ready | in-progress | failed
    summary: "<one-line description>"
    consumed_by: ["<skill-name>"]
    key_sections: ["<section name>"]   # optional: sections downstream should read
    conditional: "<condition>"         # optional: omit if always produced

quality:
  status: "complete"           # complete | partial | has-ambiguities | blocked
  ambiguities: []              # unresolved questions
  blockers: []                 # issues preventing downstream consumption

suggested_next:
  - skill: "<downstream skill name>"
    reason: "<why it should run next>"
    context: "<what to focus on, what is ready>"
    reads: ["<artifact path from this manifest>"]

consumed_from:                 # upstream manifests this skill read (forms a DAG)
  - "<path to upstream handoff manifest>"

lifecycle:
  archivable_after: ["<skill-name>"]   # skills that must consume before archiving
  archive_policy: "after-finalize"     # after-finalize | after-all-consumed | manual

# Optional tool extensions:
# stitch: { ... }              # Stitch references (ui-design)
# figma:  { ... }              # see Figma block below
```

**Status values:**

| Field | Value | Downstream behavior |
|---|---|---|
| `artifacts[].status` | `ready` | Read and use |
| | `in-progress` | Skip for now; do not block on it |
| | `failed` | Do not consume; tell the user |
| `quality.status` | `complete` | Proceed normally |
| | `partial` | Use `ready` artifacts, skip the rest |
| | `has-ambiguities` | Use the artifacts, surface the ambiguities to the user |
| | `blocked` | Do not consume; surface `blockers` |

**Figma block** (written by `figma:figma-generate-design`, read by `spec-to-impl` FE work and
`figma:figma-implement-design`):

```yaml
figma:
  file_key: "<Figma file key>"
  file_url: "<full Figma URL>"
  pages:
    - page_name: "<page name>"
      screens:
        - screen_name: "<screen name>"
          node_id: "<frame node ID>"
          viewport: "<375px | 768px | 1440px>"
          route_suggestion: "<frontend route>"
          screenshot_path: "<path to screenshot PNG>"
  component_map:
    - component_name: "<design component name>"
      component_key: "<Figma component key>"
      node_ids: ["<node IDs where used>"]
      variant_used: "<variant name>"
  variable_bindings:
    - token_name: "<CSS custom property name>"
      variable_key: "<Figma variable key>"
      value: "<resolved value>"
  generation_method: "<make | use_figma | combined>"
```

Consumers call `get_design_context(fileKey, nodeId)` per screen and map `variable_bindings` to
CSS custom properties or theme tokens.

## Reading manifests

1. `ls -t claudedocs/handoff-*.yaml 2>/dev/null | head -10`
2. Keep manifests whose `suggested_next[].skill` names this skill. Skip `quality.status: blocked`
   and report its blockers.
3. Read the files in that entry's `reads[]` and apply its `context`.
4. Do not ask the user for anything the artifacts already answer.
5. Add each manifest you used to your own `consumed_from[]`.
6. For `partial`, tell the user how many artifacts were ready and which you skipped. If one you
   cannot proceed without is still `in-progress`, ask the user rather than guessing.

With no relevant manifest, the skill still runs: ask the user for what the artifacts would have
provided.

## Rules

- A manifest is a pointer (under about 80 lines), never a copy of the output; the content lives
  at each artifact `path`.
- Manifests are never deleted: they are the audit trail of the chain.
- Primary artifacts are archived (moved), never deleted, and only after `finalize` succeeds.

## Lifecycle and archiving

`finalize` archives, after its commit succeeds, the artifacts whose consumers have all run: a
manifest is archivable when every skill in `lifecycle.archivable_after` appears as the
`source_skill` of a manifest that lists it in `consumed_from`. If any is missing, warn and leave
the artifacts in place.

| Artifact | Location | Treatment |
|---|---|---|
| Handoff manifests | `claudedocs/handoff-*.yaml` | Keep (audit trail) |
| Primary outputs | `claudedocs/<feature>-*.md` | Move to `claudedocs/.archive/<timestamp>-<feature>/` |
| Design artifacts | `design/` | Archive only after asking: implementation may still use them |
| Test plan and evidence | `e2e/test-plan.yaml`, `e2e/reports/`, screenshots | Keep (regression and evidence) |
| Agent worktrees | `.worktrees/` | Removed after merge by `spec-to-impl` |

Add `claudedocs/.archive/` to `.gitignore`: archived artifacts are local working state.

## Output types

Use these names for `artifacts[].type`:

- Discovery: `assessment`, `analysis`
- Planning: `prd`, `design-doc`, `adr`, `user-flow`, `flow-map`, `api-design`, `data-design`,
  `search-design`, `infra-design`, `tickets`, `experiment-plan`, `decision`, `migration-plan`,
  `mobile-guidance`
- Implementation: `spec-manifest`, `architecture`, `test-plan`, `code`, `verification`
- Quality: `panel-analysis`, `code-audit`, `code-review`, `security-review`, `performance-review`,
  `ux-review`, `docs-review`, `metrics-review`, `evidence-review`, `triage`
- Design tools: `ui-design`, `component-tree`, `testid-registry`, `design-tokens`, `a11y-spec`,
  `design-md`, `stitch-reference`, `stitch-screen-specs`, `figma-design`, `react-components`,
  `code-connect-mappings`

Most types are named after the skill that produces them. Not obvious from the name:
`assessment` (`opportunity-assessment`, `tech-debt-assessment`), `analysis`
(`competitive-analysis`), `tickets` (`ticket-breakdown`), `experiment-plan`
(`experiment-design`), `decision` (`decision-matrix`), `mobile-guidance` (`mobile-dev`),
`panel-analysis` (`spec-panel`), `triage` (`debug-triage`), `verification` (`verify-impl`),
`spec-manifest` / `architecture` / `code` (`spec-to-impl`), the design-tool types (`ui-design`,
or the official Figma plugin skills for `figma-design`, `react-components`,
`code-connect-mappings`).
