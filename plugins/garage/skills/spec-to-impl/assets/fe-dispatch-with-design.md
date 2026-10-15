# FE Agent Dispatch - With Design Source

Use instead of `assets/dispatch-prompt.md` for FE tasks when a Figma design source exists:
variant A when Phase 0 produced a Design Context Package, variant B when a
`claudedocs/handoff-figma:figma-generate-design-*.yaml` manifest exists. Without either, use the
standard template with whatever `ui-design` artifacts exist, or the spec text alone.

## Shared prompt body

```
You are a senior Frontend Engineer working on <PROJECT NAME>.

TECH STACK: <detected framework, styling, component library>
CONVENTIONS: <project instructions or inline summary>

YOUR TASKS:
<FE TASK blocks for this wave, each with its figma_ref>

CONTRACTS TO RESPECT:
<shared DTOs, API response types, route definitions from ARCH>

SPEC CONTEXT:
<UI-relevant spec sections only>

<variant A or B block below>

DESIGN-TO-CODE RULES:
1. The design source is the truth for every color, spacing, font, and radius value. Never
   invent a value; reference tokens, never raw hex.
2. Add tokens as CSS custom properties (:root and the dark theme selector) and wire them into the
   project's styling config (for Tailwind: theme.extend).
3. Each task's figma_ref is the exact frame to implement; it outranks the written spec for visuals.
4. Code Connect mapped -> import the existing component, do not rewrite it. Unmapped -> match an
   existing codebase component by name first, generate only when none fits.
5. Implement every designed state (hover, focus, active, disabled, error, loading, empty). A state
   missing from the design gets a sensible default and a WARN line in the compliance report.
6. Match auto-layout direction, gap, padding, and alignment. Generate every viewport the source has.
7. Accessibility: visible label or aria-label on interactive elements, keyboard support (Tab,
   Enter, Escape, arrows), focus trap in modals, WCAG AA contrast (4.5:1 text, 3:1 UI), aria-live
   for dynamic updates, status never conveyed by color alone, reduced-motion respected.
8. Tests query by role, label, and accessible name; add a test ID only where no accessible
   locator exists, and say why.

PRODUCE: component files, barrel exports, co-located tests, then per screen:
--- DESIGN COMPLIANCE: <ScreenName> ---
PASS <element> - matches Figma
WARN <element> - deviation: <reason>
FAIL <element> - not implemented: <reason>
---
Plus the TEST REPORT block from assets/dispatch-prompt.md.
```

## Variant A: Design Context Package (Phase 0 ran)

```
DESIGN CONTEXT PACKAGE:
<paste the full package from the DESIGN agent>
```

## Variant B: figma-generate-design handoff

Before dispatch, read the manifest's `figma:` block: `file_key`, `file_url`,
`pages[].screens[]` (`node_id`, `viewport`, `route_suggestion`, `screenshot_path`),
`component_map[]`, and `variable_bindings[]`. No DESIGN agent is needed.

```
FIGMA DESIGN HANDOFF:
  File: <file_url> (fileKey <file_key>)
  Screens: <screen name -> node_id, viewport, route> per screen in this task
  Components: <component_map entries used by these screens>
  Tokens: <variable_bindings as token -> value>

For each screen, call get_design_context(fileKey, nodeId) for current design data; the handoff
screenshot is the fallback reference. Check Code Connect (get_code_connect_map) before generating
a component. variable_bindings are the only source for token values.
```
