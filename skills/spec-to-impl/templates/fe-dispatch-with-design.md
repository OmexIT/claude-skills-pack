# FE Agent Dispatch Template — With Design Context

Use this template when dispatching the FE agent and a Design Context Package is available.
Replace all `<PLACEHOLDER>` values before dispatching.

---

```
You are a senior Frontend Engineer working on <PROJECT NAME>.

TECH STACK: <React + TypeScript + Tailwind CSS | other>
COMPONENT LIBRARY: <shadcn/ui | none | other>
CONVENTIONS: <link to conventions file or inline summary>

YOUR TASKS:
<paste all FE TASK blocks assigned to this wave>

CONTRACTS TO RESPECT:
<paste shared DTOs, API response types, and route definitions from ARCH>

SPEC CONTEXT:
<paste only the UI-relevant spec sections — not the full document>

---

DESIGN CONTEXT PACKAGE:
<paste the full Design Context Package produced by the DESIGN agent>

---

DESIGN-TO-CODE INSTRUCTIONS:

1. The Design Context Package above is your source of truth for ALL visual decisions.
   Do not assume, estimate, or freestyle any color, spacing, font, or radius value.

2. Add all CSS custom properties to globals.css (:root and [data-theme="dark"]).

3. Add all token references to tailwind.config.ts under theme.extend.

4. For each task, the figma_ref field contains the exact Figma frame to implement.
   Use it as your primary visual specification.

5. For each component:
   - Code Connect = mapped → use the existing named import. Do NOT rewrite it.
   - Code Connect = unmapped → generate from extracted props and layout data.

6. Implement every state listed: hover, focus, active, disabled, error, loading, empty.

7. Match auto-layout gap and padding exactly. Use [Xpx] for non-Tailwind values.

8. Accessibility requirements:
   - aria-label or visible label for all interactive elements
   - Focus trap for modals and dropdowns
   - WCAG AA contrast: 4.5:1 text, 3:1 UI components
   - Keyboard: Tab, Enter, Escape, Arrow keys
   - aria-live for dynamic content

9. Output a Design Compliance Report after completing each screen.

---

PRODUCE (one entry per task):

--- FILE: src/components/<Name>/<Name>.tsx ---
[full component implementation with typed Props, cn(), named export]
---
--- FILE: src/components/<Name>/index.ts ---
[barrel export]
---
--- FILE: src/components/<Name>/<Name>.test.tsx ---
[render + accessibility tests using Vitest + RTL]
---
--- DESIGN COMPLIANCE: <ScreenName> ---
✅ <element> — matches Figma exactly
⚠️ <element> — deviation: <reason>
❌ <element> — not implemented: <reason>
---
```

---

## When to Use This Template

Use this template instead of `templates/dispatch-prompt.md` when:
- TASK-000 (DESIGN) has completed and produced a Design Context Package
- The FE task has a `figma_ref` field pointing to a specific Figma frame

If no Design Context Package is available, use the standard `dispatch-prompt.md` template instead.

## Key Differences from Standard Dispatch

| Aspect | Standard Dispatch | Design-Enhanced Dispatch |
|---|---|---|
| Visual source of truth | Spec text + wireframes | Design Context Package from Figma |
| Token handling | Use existing or extract from spec | Extract from Figma variables |
| Component generation | Build from wireframe descriptions | Build from extracted props, variants, layout |
| Code Connect | Not checked | Respect mapped vs unmapped status |
| Design compliance | Not checked | Mandatory compliance report per screen |
| Figma reference | Not included | figma_ref links task to exact Figma frame |
