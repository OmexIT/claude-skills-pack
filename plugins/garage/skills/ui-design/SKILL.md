---
name: ui-design
description: "Use when the user wants UI or UX design artifacts: design the UI for a spec, wireframes, screens, layouts, component specs, design tokens, a design system, typography, color, or spacing systems, for web, Flutter, React Native, or AngularJS."
---

# UI design

> Delegation, model labels, and task tracking below use Claude Code notation. In Codex or another client, follow `../../references/cross-client.md`.

Turns a spec, panel analysis, or brief into buildable design artifacts in `design/` for the FE
agent in `spec-to-impl`.

## Workflow context
- Follows `prd`, `design-doc`, `user-flow` (user journeys), `flow-map` (system paths); reads their handoffs.
- Feeds `spec-to-impl` (FE) and `verify-impl` (selector registry).
- Review mode here critiques design artifacts (tokens, wireframes, specs) before build. Usability
  evaluation of a built UI or a heuristic or accessibility audit belongs to `ux-review`.

## 1. Pick the mode

| Request | Run |
|---|---|
| Spec or "design this screen / feature" | Setup, then phases 1 to 4, then handoff |
| No spec, or `--brief` | Brief (section 8) first |
| "Design system", "style guide", "tokens", `--design-system`, `--tokens-only` | Design system (section 9) |
| "Design this component" | Component design (section 10) |
| "Review / critique this design", `--review` | Design review (section 11) |
| "Dark mode", "responsive", `--dark-mode` | Variants (section 12) |
| "Handoff", "ready for dev", `--handoff` | Developer handoff (section 13) |
| "Revise SCR-001" | Revision (section 14) |

Other flags: `--no-wireframes`, `--no-a11y` (record the skip as an open risk), `--mobile-first`
(375px primary), `--platform react|flutter|react-native|angular` (default react),
`--output-dir <dir>` (default `design/`), `--stitch`, `--figma <url|key>`, `--design-md <path>`,
`--manual` (force a design source).

## 2. Setup

1. Read upstream handoffs: `ls -t claudedocs/handoff-*.yaml 2>/dev/null | head -5`. Use `prd`,
   `design-doc`, `user-flow`, and `flow-map` outputs to pre-fill context and skip their questions.
2. Detect the design source unless a flag forces one: Stitch MCP tools, Figma MCP tools, a
   `DESIGN.md`, else manual. Read `references/design-tool-integration.md` when the source is not
   manual.
3. Read each input file: screens, actors, data fields, states, interactions, error cases, stack
   hints. Merge multiple files as panels of one product with shared components.
4. Scan the codebase for an existing design system before designing anything:
   ```bash
   find . \( -path '*/components/*' -name '*.tsx' -o -path '*/widgets/*' -name '*.dart' \) -not -path '*/node_modules/*' | head -30
   find . \( -name 'tailwind.config*' -o -name 'theme.*' -o -name 'tokens.*' -o -name 'colors.dart' \) -not -path '*/node_modules/*' | head -10
   ```
   If one exists, extend it: its token names, components, breakpoints, and libraries win. A new
   Button, Modal, Input, Avatar, Badge, Card, or Toast next to an existing one is a blocker.
5. Detect the stack and versions. Read `references/platform-patterns.md` when the target is not
   plain React web, or when choosing state, styling, accessibility APIs, or test locators.
6. Confirm in a few lines: files and panels, screen and flow counts, stack, design source, existing
   design system found or not, and which roles will run.

## 3. Roles and fan-out

| Role | Model | Owns | Persona and rules |
|---|---|---|---|
| `UX_LEAD` | `opus` | Inventory, IA, flows, ambiguities, final synthesis | `references/ux-lead.md` |
| `UI_DESIGNER` | `sonnet` | Wireframes, state frames, visual spec, tokens | `references/ui-designer-comp-arch-a11y-copy.md` |
| `COPY` | `haiku` | All UI strings | same file |
| `COMP_ARCH` | `opus` | Component tree, props, state, selector registry | same file |
| `A11Y` | `sonnet` | Contrast, non-color cues, keyboard, focus, motion | same file |

Roles are lenses, not a requirement to fan out. For small scope (one screen, one component, tokens
only, a revision) run the roles inline in one pass, reading only the persona files you need. Fan
out only for multi-screen or multi-panel work, and only where the client supports subagents:

1. `UX_LEAD` alone (everything else depends on its inventory).
2. `UI_DESIGNER` and `COPY` in parallel (`COPY` may run with `run_in_background: true`).
3. `COMP_ARCH` and `A11Y` in parallel.
4. `UX_LEAD` synthesizes and resolves conflicts.

Track one task per phase when the run spans several screens.

## 4. Phase 1: Analyse (UX_LEAD)

Produce `design/ux/ux-inventory.md`, `design/ux/ia-map.md`, and `design/ux/flows.md`:

```
SCR-001  <name>   entry: <...>  goal: <...>  data: <...>  actions: <...>  exits: <...>
                  states: empty | loading | populated | error | success | stale | readonly
FLOW-001 <name>   actor: <role>  SCR-001 -> (action) -> SCR-002   errors: <...>  edge: <...>
FIELDS   screen | field | type | validation | required
[UX-AMB-001] <question needing a product decision>
```

Gate: surface ambiguities before designing. Resolve critical ones (navigation model, primary CTA,
auth gate, money semantics) with the user first.

## 5. Phase 1.5: Generate or import (skipped when manual)

Follow `references/design-tool-integration.md` for the detected source. Stitch generates screens
from the inventory; Figma supplies structure, variables, and components; `DESIGN.md` supplies the
token base. Generated output covers only the happy path and has no accessibility, so phases 2 to 4
always run. Report what was generated or imported (screens, tokens, Stitch project and screen
IDs) before continuing.

## 6. Phase 2: Design (UI_DESIGNER, COPY)

- Wireframe each screen with a spec sidebar, plus a frame per state (loading, empty, error, and
  partial or stale where data can be incomplete). Refine generated screens instead of redrawing
  them. Notation and example: `references/token-schema-and-wireframe-notation.md`.
- Visual spec and tokens in `design/visual-spec/tokens.md` using the schema in the same reference:
  semantic color roles with light and dark values, type, spacing, radius, elevation, motion.
- Copy spec in `design/copy/copy-spec.md`: titles, labels, hints, errors, empty and success
  states, button labels.

Design rules that apply everywhere:

- Semantic tokens only (`--color-error-text`, never `--color-red`); no raw values in specs.
- Color is never the only cue: every status, error, and change indicator also has text, an icon,
  or a glyph.
- Every animation uses motion tokens, animates opacity or transform, and states its
  reduced-motion behavior.
- States: empty explains and offers the next action; loading uses a size-stable skeleton; error
  says what happened and how to recover and keeps entered data; success says what happens next and
  is not auto-dismissed if the user must read or act on it.
- Money and irreversible actions: no optimistic success. Show pending until the server confirms;
  an unknown result stays pending until reconciled. Prevent double submit. Cached money values
  are labeled stale with a last-updated time, and money mutations are never queued offline without
  a reviewed idempotency, ordering, and reconciliation design.
- Forms: validate on blur, errors inline under the field, never clear input on failure, multi-step
  forms show progress and allow back without data loss.
- Long or unbounded lists are designed for windowed rendering; image dimensions are specified.
- Breakpoints come from the project; otherwise 375, 768, 1024, 1280. Never hide a critical action
  at any breakpoint.
- For iGaming products read `references/igaming-design-patterns.md` before designing odds, live,
  bet slip, wallet, casino, or responsible-gambling surfaces.

## 7. Phase 3 and 4: Components (COMP_ARCH) and accessibility (A11Y)

COMP_ARCH, in `design/components/`:
- `component-tree.md`: pages, feature components (list, item, skeleton, empty state, form,
  detail), shared UI, hooks or providers, following the project's structure.
- `component-specs.md`: one card per component from `assets/component-spec.md`, starting with
  "reused from existing".
- `state-model.md`: server and client state per feature, using the project's libraries.
- `testid-registry.md`: the selector registry. Read `references/ui-selector-conventions.md`:
  role plus accessible name or label first; a test ID only as a justified fallback with its reason.

A11Y, in `design/a11y/a11y-spec.md`, against WCAG 2.2 AA (`references/accessibility-standards.md`):
contrast per pair per theme, non-color cues, keyboard spec, roles and names, live regions, focus
management, reduced motion, target sizes, and an issues list HIGH, MEDIUM, LOW with fixes. HIGH
issues are listed as open in the handoff.

## 8. Phase 0.5: Brief (no spec, or `--brief`)

Ask once, all together, only for what is missing: product and use case, primary user and context,
the one primary action, platform, existing design system or brand, references, visual tone, hard
constraints (stack, accessibility, RTL, regulation). Confirm the brief, then run Phase 1.

## 9. Phase 4.5: Design system (`--design-system`, `--tokens-only`)

Read `references/design-system-agent.md` and fill `assets/design-system-spec.md` (and
`assets/style-guide.md` for a one-page version). `--tokens-only` produces just
`design/visual-spec/tokens.md`. Output: `design/design-system-spec.md`.

## 10. Phase 5: Component design

Read `references/component-design-agent.md`: brief, variant matrix, Component Card, per-state
interaction, edge cases.

## 11. Phase 6: Design review (`--review`)

Read `references/design-review-agent.md` and fill `assets/design-review-report.md` into
`design/design-review-report.md`. Lenses: hierarchy, consistency, typography, color and contrast,
spacing and layout, states, interaction and motion. Every finding cites the artifact and gives a
fix. A clean review is a valid result.

## 12. Phase 7: Variants

- Dark mode: its own palette, not an inversion. Surfaces get lighter as they rise; soften brand
  saturation; avoid pure black and pure white text; re-run contrast for every pair. Output both
  values per token.
- Responsive: per screen, state navigation, grid, sidebar, and card layout at each breakpoint.

## 13. Phase 8: Developer handoff (`--handoff`)

Fill `assets/developer-handoff.md` into `design/developer-handoff.md`, alongside the handoff YAML.

## 14. Revision

Re-run only the affected roles, update the affected files, and follow cascades (a color token
change re-runs contrast; a renamed control updates the selector registry and the tests in
`e2e/test-plan.yaml`). Report what changed and what downstream artifacts need updating.

## 15. Handoff package

After a full run, write `design/DESIGN.md` (format in `references/design-tool-integration.md`).
Summarize for the user: screens, components, selectors, design source, files for the FE agent in
reading order (tokens, component tree, component specs, copy spec, wireframes, Stitch screens if
any, `DESIGN.md`), the selector registry for `verify-impl`, Stitch IDs if any, and open HIGH
issues. Then write the manifest:

```yaml
# claudedocs/handoff-ui-design-<timestamp>.yaml
source_skill: "ui-design"
design_source: "<stitch | figma | design-md | manual>"
artifacts:
  - path: "design/components/component-tree.md"
    type: "component-tree"
  - path: "design/components/testid-registry.md"
    type: "testid-registry"
  - path: "design/visual-spec/tokens.md"
    type: "design-tokens"
  - path: "design/a11y/a11y-spec.md"
    type: "a11y-spec"
  - path: "design/DESIGN.md"
    type: "design-md"
    note: "Portable design system spec -- importable by Stitch and other tools"
  - path: "design/stitch-screens/"
    type: "stitch-screen-specs"
    note: "Screen structure from get_screen() (Stitch mode only)"
    conditional: "only if design_source == stitch"
stitch:                                    # present only when design_source == stitch
  project_id: "<Stitch project ID>"
  design_system_id: "<Stitch design system asset ID>"
  screens:
    - screen_id: "<Stitch screen ID>"
      instance_id: "<Stitch screen instance ID>"
      ref: "SCR-XXX"
      resource_name: "projects/{p}/screens/{s}"
quality_assessment: "Complete, <n> a11y issues to resolve"
suggested_next:
  - skill: "spec-to-impl"
    context: "Design artifacts ready. <n> components, <n> selectors. Stitch project <id> if any."
  - skill: "figma:figma-generate-design"
    context: "<n> screens with wireframes, <n> tokens, <n> components in design/."
  - skill: "verify-impl"
    context: "testid-registry.md lists <n> elements with role/label locators and justified test IDs."
```

Output tree under `design/`: `ux/` (ia-map, flows, ux-inventory), `wireframes/` (SCR-XXX.md, Figma
PNGs), `visual-spec/` (tokens, visual-spec), `copy/copy-spec.md`, `components/` (component-tree,
component-specs, state-model, testid-registry), `stitch-screens/` (Stitch only), `a11y/a11y-spec.md`,
`DESIGN.md`.

## Output contract
```yaml
produces:
  - type: ui-design
    format: markdown
    path: "design/"
    sections: [ux_inventory, ia_map, wireframes, tokens, visual_spec, copy, components, testids, a11y]
  - type: testid-registry
    format: markdown
    path: "design/components/testid-registry.md"
    consumed_by: "verify-impl"
  - type: design-tokens
    format: markdown
    path: "design/visual-spec/tokens.md"
    consumed_by: "spec-to-impl FE agent"
  - type: design-md
    format: markdown
    path: "design/DESIGN.md"
    consumed_by: "spec-to-impl FE agent, other design tools"
  - type: stitch-screen-specs
    format: markdown
    path: "design/stitch-screens/"
    consumed_by: "spec-to-impl FE agent (as reference, not scaffolding)"
    conditional: "only when design_source == stitch"
  - type: stitch-reference
    format: yaml
    path: "embedded in handoff YAML (stitch block)"
    consumed_by: "spec-to-impl FE agent, verify-impl"
    conditional: "only when design_source == stitch"
    note: "project_id, design_system_id, screen_ids for live Stitch API queries"
  - type: design-system-spec
    format: markdown
    path: "design/design-system-spec.md"
    consumed_by: "spec-to-impl FE agent, figma:figma-implement-design"
    conditional: "only when --design-system or Phase 4.5 runs"
  - type: design-review-report
    format: markdown
    path: "design/design-review-report.md"
    consumed_by: "spec-to-impl, finalize"
    conditional: "only when --review or Phase 6 runs"
  - type: developer-handoff
    format: markdown
    path: "design/developer-handoff.md"
    consumed_by: "spec-to-impl FE agent, figma:figma-implement-design"
    conditional: "only when --handoff or Phase 8 runs"
```
